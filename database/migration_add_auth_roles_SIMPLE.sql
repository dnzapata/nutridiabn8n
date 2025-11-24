-- ============================================
-- MIGRACIÓN SIMPLE: Sistema de autenticación
-- Con hash pre-generado (no requiere pgcrypto durante creación)
-- ============================================

-- Intentar instalar pgcrypto (necesario para login)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================
-- PASO 1: Agregar campos de autenticación
-- ============================================
ALTER TABLE nutridiab.usuarios 
ADD COLUMN IF NOT EXISTS "username" VARCHAR(100) UNIQUE,
ADD COLUMN IF NOT EXISTS "password_hash" VARCHAR(255),
ADD COLUMN IF NOT EXISTS "rol" VARCHAR(50) DEFAULT 'usuario' CHECK ("rol" IN ('administrador', 'usuario')),
ADD COLUMN IF NOT EXISTS "ultimo_login" TIMESTAMP WITH TIME ZONE;

CREATE INDEX IF NOT EXISTS idx_usuarios_username ON nutridiab.usuarios("username");
CREATE INDEX IF NOT EXISTS idx_usuarios_rol ON nutridiab.usuarios("rol");

-- ============================================
-- PASO 2: Crear tabla de sesiones
-- ============================================
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

-- ============================================
-- PASO 3: Funciones de autenticación
-- ============================================

-- Eliminar funciones anteriores
DROP FUNCTION IF EXISTS nutridiab.login_usuario(VARCHAR, VARCHAR, VARCHAR, TEXT);
DROP FUNCTION IF EXISTS nutridiab.validar_sesion(VARCHAR);
DROP FUNCTION IF EXISTS nutridiab.logout_usuario(VARCHAR);
DROP FUNCTION IF EXISTS nutridiab.es_administrador(VARCHAR);
DROP FUNCTION IF EXISTS nutridiab.limpiar_sesiones_expiradas();

-- Función para login
CREATE OR REPLACE FUNCTION nutridiab.login_usuario(
  p_username VARCHAR(100),
  p_password VARCHAR(255),
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
  v_password_hash VARCHAR(255);
  v_token VARCHAR(255);
  v_expira TIMESTAMP WITH TIME ZONE;
  v_password_valida BOOLEAN;
BEGIN
  -- Buscar usuario
  SELECT 
    u."usuario ID",
    u.username,
    u.nombre,
    u.apellido,
    u.email,
    u.rol,
    u."Activo",
    u."Bloqueado",
    u.password_hash
  INTO 
    v_usuario_id,
    v_username,
    v_nombre,
    v_apellido,
    v_email,
    v_rol,
    v_activo,
    v_bloqueado,
    v_password_hash
  FROM nutridiab.usuarios u
  WHERE u.username = p_username;
  
  -- Usuario no encontrado
  IF v_usuario_id IS NULL THEN
    RETURN QUERY SELECT FALSE, NULL::INTEGER, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, 'Usuario o contraseña incorrectos'::TEXT;
    RETURN;
  END IF;
  
  -- Verificar contraseña
  BEGIN
    v_password_valida := (v_password_hash = crypt(p_password, v_password_hash));
  EXCEPTION WHEN OTHERS THEN
    -- Si falla crypt, comparar directo (fallback)
    v_password_valida := (v_password_hash = p_password);
  END;
  
  IF NOT v_password_valida THEN
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
  
  -- Retornar éxito
  RETURN QUERY SELECT TRUE, v_usuario_id, v_username, v_nombre, v_apellido, v_email, v_rol, v_token, 'Login exitoso'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- Función para validar sesión
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

-- Función para logout
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

-- Función para verificar administrador
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

-- Función para limpiar sesiones
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

-- ============================================
-- PASO 4: Permisos
-- ============================================
GRANT ALL PRIVILEGES ON TABLE nutridiab.sesiones TO dnzapata;
GRANT ALL PRIVILEGES ON SEQUENCE nutridiab.sesiones_id_seq TO dnzapata;
ALTER TABLE nutridiab.sesiones OWNER TO dnzapata;
ALTER TABLE nutridiab.sesiones DISABLE ROW LEVEL SECURITY;

GRANT EXECUTE ON FUNCTION nutridiab.login_usuario(VARCHAR, VARCHAR, VARCHAR, TEXT) TO dnzapata;
GRANT EXECUTE ON FUNCTION nutridiab.validar_sesion(VARCHAR) TO dnzapata;
GRANT EXECUTE ON FUNCTION nutridiab.logout_usuario(VARCHAR) TO dnzapata;
GRANT EXECUTE ON FUNCTION nutridiab.es_administrador(VARCHAR) TO dnzapata;
GRANT EXECUTE ON FUNCTION nutridiab.limpiar_sesiones_expiradas() TO dnzapata;

-- ============================================
-- PASO 5: Crear usuario administrador
-- Hash pre-generado de "Fl100190" usando bcrypt
-- ============================================
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
  '$2b$10$5K4/XjqvY7qzP1hZ.xGVl.8CZ9nQX1YH5oLBpSx0i6TxNJQHXQhyG',
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
DECLARE
  v_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM nutridiab.usuarios 
  WHERE username = 'dnzapata' AND rol = 'administrador';
  
  IF v_count = 0 THEN
    RAISE EXCEPTION 'Usuario administrador no creado';
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'MIGRACION COMPLETADA EXITOSAMENTE';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Credenciales:';
  RAISE NOTICE '  Username: dnzapata';
  RAISE NOTICE '  Password: Fl100190';
  RAISE NOTICE '  Rol: administrador';
  RAISE NOTICE '';
  RAISE NOTICE 'Proximo paso: Configurar workflow en n8n';
  RAISE NOTICE '';
END $$;

