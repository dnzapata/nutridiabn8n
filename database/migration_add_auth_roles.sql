-- ============================================
-- MIGRACIÓN: Agregar sistema de autenticación y roles
-- ============================================

-- 1. Agregar campos de autenticación a la tabla usuarios
ALTER TABLE nutridiab.usuarios 
ADD COLUMN IF NOT EXISTS "username" VARCHAR(100) UNIQUE,
ADD COLUMN IF NOT EXISTS "password_hash" VARCHAR(255),
ADD COLUMN IF NOT EXISTS "rol" VARCHAR(50) DEFAULT 'usuario' CHECK ("rol" IN ('administrador', 'usuario')),
ADD COLUMN IF NOT EXISTS "ultimo_login" TIMESTAMP WITH TIME ZONE;

-- 2. Crear índices para mejorar performance
CREATE INDEX IF NOT EXISTS idx_usuarios_username ON nutridiab.usuarios("username");
CREATE INDEX IF NOT EXISTS idx_usuarios_rol ON nutridiab.usuarios("rol");

-- 3. Agregar comentarios
COMMENT ON COLUMN nutridiab.usuarios."username" IS 'Nombre de usuario para login (único)';
COMMENT ON COLUMN nutridiab.usuarios."password_hash" IS 'Hash bcrypt de la contraseña';
COMMENT ON COLUMN nutridiab.usuarios."rol" IS 'Rol del usuario: administrador o usuario';
COMMENT ON COLUMN nutridiab.usuarios."ultimo_login" IS 'Fecha y hora del último login exitoso';

-- 4. Crear tabla de sesiones para manejo de autenticación
CREATE TABLE IF NOT EXISTS nutridiab.sesiones (
  "id" SERIAL PRIMARY KEY,
  "usuario_id" INTEGER REFERENCES nutridiab.usuarios("usuario ID") ON DELETE CASCADE,
  "token" VARCHAR(255) UNIQUE NOT NULL,
  "ip_address" VARCHAR(45),
  "user_agent" TEXT,
  "expira" TIMESTAMP WITH TIME ZONE NOT NULL,
  "activa" BOOLEAN DEFAULT TRUE,
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sesiones_token ON nutridiab.sesiones("token");
CREATE INDEX IF NOT EXISTS idx_sesiones_usuario ON nutridiab.sesiones("usuario_id");
CREATE INDEX IF NOT EXISTS idx_sesiones_expira ON nutridiab.sesiones("expira");
CREATE INDEX IF NOT EXISTS idx_sesiones_activa ON nutridiab.sesiones("activa");

-- 5. Trigger para actualizar updated_at en sesiones
CREATE TRIGGER sesiones_updated_at
  BEFORE UPDATE ON nutridiab.sesiones
  FOR EACH ROW
  EXECUTE FUNCTION nutridiab.actualizar_timestamp();

-- 6. Función para limpiar sesiones expiradas
CREATE OR REPLACE FUNCTION nutridiab.limpiar_sesiones_expiradas()
RETURNS INTEGER AS $$
DECLARE
  rows_deleted INTEGER;
BEGIN
  DELETE FROM nutridiab.sesiones
  WHERE expira < NOW() OR (activa = FALSE AND updated_at < NOW() - INTERVAL '7 days');
  
  GET DIAGNOSTICS rows_deleted = ROW_COUNT;
  RETURN rows_deleted;
END;
$$ LANGUAGE plpgsql;

-- 7. Función para validar credenciales y crear sesión
CREATE OR REPLACE FUNCTION nutridiab.login_usuario(
  p_username VARCHAR(100),
  p_password_hash VARCHAR(255),
  p_ip_address VARCHAR(45) DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL
)
RETURNS TABLE(
  success BOOLEAN,
  user_id INTEGER,
  username VARCHAR(100),
  nombre VARCHAR(255),
  apellido VARCHAR(255),
  email VARCHAR(255),
  rol VARCHAR(50),
  token VARCHAR(255),
  message TEXT
) AS $$
DECLARE
  v_usuario_id INTEGER;
  v_username VARCHAR(100);
  v_nombre VARCHAR(255);
  v_apellido VARCHAR(255);
  v_email VARCHAR(255);
  v_rol VARCHAR(50);
  v_activo BOOLEAN;
  v_bloqueado BOOLEAN;
  v_token VARCHAR(255);
  v_expira TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Buscar usuario y verificar contraseña
  SELECT 
    u."usuario ID",
    u.username,
    u.nombre,
    u.apellido,
    u.email,
    u.rol,
    u."Activo",
    u."Bloqueado"
  INTO 
    v_usuario_id,
    v_username,
    v_nombre,
    v_apellido,
    v_email,
    v_rol,
    v_activo,
    v_bloqueado
  FROM nutridiab.usuarios u
  WHERE u.username = p_username 
    AND u.password_hash = p_password_hash;
  
  -- Usuario no encontrado o contraseña incorrecta
  IF v_usuario_id IS NULL THEN
    RETURN QUERY SELECT FALSE, NULL::INTEGER, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, 'Usuario o contraseña incorrectos'::TEXT;
    RETURN;
  END IF;
  
  -- Usuario bloqueado
  IF v_bloqueado = TRUE THEN
    RETURN QUERY SELECT FALSE, NULL::INTEGER, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, 'Usuario bloqueado'::TEXT;
    RETURN;
  END IF;
  
  -- Usuario inactivo
  IF v_activo = FALSE THEN
    RETURN QUERY SELECT FALSE, NULL::INTEGER, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, 'Usuario inactivo'::TEXT;
    RETURN;
  END IF;
  
  -- Generar token de sesión
  v_token := encode(gen_random_bytes(32), 'hex');
  v_expira := NOW() + INTERVAL '7 days';
  
  -- Crear sesión
  INSERT INTO nutridiab.sesiones ("usuario_id", "token", "ip_address", "user_agent", "expira", "activa")
  VALUES (v_usuario_id, v_token, p_ip_address, p_user_agent, v_expira, TRUE);
  
  -- Actualizar último login
  UPDATE nutridiab.usuarios
  SET "ultimo_login" = NOW(), "ultimo_acceso" = NOW()
  WHERE "usuario ID" = v_usuario_id;
  
  -- Retornar éxito con datos del usuario
  RETURN QUERY SELECT TRUE, v_usuario_id, v_username, v_nombre, v_apellido, v_email, v_rol, v_token, 'Login exitoso'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- 8. Función para validar sesión
CREATE OR REPLACE FUNCTION nutridiab.validar_sesion(p_token VARCHAR(255))
RETURNS TABLE(
  valida BOOLEAN,
  usuario_id INTEGER,
  username VARCHAR(100),
  nombre VARCHAR(255),
  apellido VARCHAR(255),
  email VARCHAR(255),
  rol VARCHAR(50),
  expiro BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.activa AND s.expira > NOW() AS valida,
    u."usuario ID" AS usuario_id,
    u.username,
    u.nombre,
    u.apellido,
    u.email,
    u.rol,
    s.expira < NOW() AS expiro
  FROM nutridiab.sesiones s
  JOIN nutridiab.usuarios u ON s.usuario_id = u."usuario ID"
  WHERE s.token = p_token
    AND u."Activo" = TRUE
    AND u."Bloqueado" = FALSE
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- 9. Función para cerrar sesión
CREATE OR REPLACE FUNCTION nutridiab.logout_usuario(p_token VARCHAR(255))
RETURNS BOOLEAN AS $$
DECLARE
  rows_affected INTEGER;
BEGIN
  UPDATE nutridiab.sesiones
  SET activa = FALSE, updated_at = NOW()
  WHERE token = p_token;
  
  GET DIAGNOSTICS rows_affected = ROW_COUNT;
  RETURN rows_affected > 0;
END;
$$ LANGUAGE plpgsql;

-- 10. Función para verificar si usuario es administrador
CREATE OR REPLACE FUNCTION nutridiab.es_administrador(p_token VARCHAR(255))
RETURNS BOOLEAN AS $$
DECLARE
  v_rol VARCHAR(50);
BEGIN
  SELECT u.rol INTO v_rol
  FROM nutridiab.sesiones s
  JOIN nutridiab.usuarios u ON s.usuario_id = u."usuario ID"
  WHERE s.token = p_token
    AND s.activa = TRUE
    AND s.expira > NOW()
    AND u."Activo" = TRUE
    AND u."Bloqueado" = FALSE
  LIMIT 1;
  
  RETURN v_rol = 'administrador';
END;
$$ LANGUAGE plpgsql;

-- 11. Permisos para dnzapata
GRANT ALL PRIVILEGES ON TABLE nutridiab.sesiones TO dnzapata;
GRANT ALL PRIVILEGES ON SEQUENCE nutridiab.sesiones_id_seq TO dnzapata;
ALTER TABLE nutridiab.sesiones OWNER TO dnzapata;
ALTER TABLE nutridiab.sesiones DISABLE ROW LEVEL SECURITY;

GRANT EXECUTE ON FUNCTION nutridiab.limpiar_sesiones_expiradas() TO dnzapata;
GRANT EXECUTE ON FUNCTION nutridiab.login_usuario(VARCHAR, VARCHAR, VARCHAR, TEXT) TO dnzapata;
GRANT EXECUTE ON FUNCTION nutridiab.validar_sesion(VARCHAR) TO dnzapata;
GRANT EXECUTE ON FUNCTION nutridiab.logout_usuario(VARCHAR) TO dnzapata;
GRANT EXECUTE ON FUNCTION nutridiab.es_administrador(VARCHAR) TO dnzapata;

-- 12. Insertar usuario administrador: dnzapata con contraseña Fl100190
-- NOTA: En producción, la contraseña debe ser hasheada usando bcrypt
-- Este es un hash bcrypt de "Fl100190" con salt rounds = 10
-- Generado con: bcrypt.hashSync('Fl100190', 10)
INSERT INTO nutridiab.usuarios (
  "remoteJid",
  "username", 
  "password_hash",
  "nombre",
  "apellido",
  "email",
  "rol",
  "Activo",
  "AceptoTerminos",
  "datos_completos",
  "email_verificado",
  "created_at"
)
VALUES (
  'admin@nutridiab.system',
  'dnzapata',
  '$2b$10$5K4/XjqvY7qzP1hZ.xGVl.8CZ9nQX1YH5oLBpSx0i6TxNJQHXQhyG', -- Hash de 'Fl100190'
  'David',
  'Zapata',
  'admin@nutridiab.com',
  'administrador',
  TRUE,
  TRUE,
  TRUE,
  TRUE,
  NOW()
)
ON CONFLICT ("remoteJid") DO UPDATE SET
  "username" = EXCLUDED."username",
  "password_hash" = EXCLUDED."password_hash",
  "rol" = EXCLUDED."rol",
  "Activo" = EXCLUDED."Activo";

-- ============================================
-- VERIFICACIÓN
-- ============================================
DO $$
BEGIN
  -- Verificar que la columna rol existe
  ASSERT (SELECT COUNT(*) FROM information_schema.columns 
          WHERE table_schema = 'nutridiab' 
          AND table_name = 'usuarios' 
          AND column_name = 'rol') = 1,
    'ERROR: Columna rol no creada';
  
  -- Verificar que la columna username existe
  ASSERT (SELECT COUNT(*) FROM information_schema.columns 
          WHERE table_schema = 'nutridiab' 
          AND table_name = 'usuarios' 
          AND column_name = 'username') = 1,
    'ERROR: Columna username no creada';
  
  -- Verificar que la tabla sesiones existe
  ASSERT (SELECT COUNT(*) FROM information_schema.tables 
          WHERE table_schema = 'nutridiab' 
          AND table_name = 'sesiones') = 1,
    'ERROR: Tabla sesiones no creada';
  
  -- Verificar que el usuario administrador existe
  ASSERT (SELECT COUNT(*) FROM nutridiab.usuarios 
          WHERE username = 'dnzapata' AND rol = 'administrador') = 1,
    'ERROR: Usuario administrador dnzapata no creado';
  
  RAISE NOTICE '✅ Migración completada exitosamente';
  RAISE NOTICE '✅ Sistema de autenticación y roles implementado';
  RAISE NOTICE '✅ Usuario administrador creado: dnzapata';
  RAISE NOTICE '✅ Tabla de sesiones creada';
  RAISE NOTICE '';
  RAISE NOTICE '📝 Credenciales de administrador:';
  RAISE NOTICE '   - Username: dnzapata';
  RAISE NOTICE '   - Password: Fl100190';
  RAISE NOTICE '   - Rol: administrador';
END $$;

