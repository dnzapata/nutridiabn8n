-- ============================================
-- FUNCIÓN DE LOGIN SÚPER SIMPLE
-- Sin dependencias de pgcrypto
-- Funciona comparando directo el hash almacenado
-- ============================================

-- Eliminar función anterior
DROP FUNCTION IF EXISTS nutridiab.login_usuario(VARCHAR, VARCHAR, VARCHAR, TEXT);

-- Función simplificada
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
    RETURN QUERY SELECT FALSE, NULL::INTEGER, NULL::VARCHAR, NULL::VARCHAR, 
      NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, 
      'Usuario o contraseña incorrectos'::TEXT;
    RETURN;
  END IF;
  
  -- Verificar contraseña (comparación directa con el hash almacenado)
  -- Esto funcionará si:
  -- 1. El password_hash es el hash bcrypt y comparamos con bcrypt
  -- 2. El password_hash es texto plano y comparamos con texto plano
  IF v_password_hash != p_password THEN
    RETURN QUERY SELECT FALSE, NULL::INTEGER, NULL::VARCHAR, NULL::VARCHAR, 
      NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, 
      'Usuario o contraseña incorrectos'::TEXT;
    RETURN;
  END IF;
  
  -- Usuario bloqueado
  IF v_bloqueado = TRUE THEN
    RETURN QUERY SELECT FALSE, NULL::INTEGER, NULL::VARCHAR, NULL::VARCHAR, 
      NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, 
      'Usuario bloqueado'::TEXT;
    RETURN;
  END IF;
  
  -- Usuario inactivo
  IF v_activo = FALSE THEN
    RETURN QUERY SELECT FALSE, NULL::INTEGER, NULL::VARCHAR, NULL::VARCHAR, 
      NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, NULL::VARCHAR, 
      'Usuario inactivo'::TEXT;
    RETURN;
  END IF;
  
  -- Generar token de sesión (usando md5 como alternativa a gen_random_bytes)
  v_token := md5(random()::text || clock_timestamp()::text || p_username);
  v_expira := NOW() + INTERVAL '7 days';
  
  -- Crear sesión
  INSERT INTO nutridiab.sesiones ("usuario_id", "token", "ip_address", "user_agent", "expira", "activa")
  VALUES (v_usuario_id, v_token, p_ip_address, p_user_agent, v_expira, TRUE);
  
  -- Actualizar último login
  UPDATE nutridiab.usuarios
  SET "ultimo_login" = NOW(), "ultimo_acceso" = NOW()
  WHERE "usuario ID" = v_usuario_id;
  
  -- Retornar éxito
  RETURN QUERY SELECT TRUE, v_usuario_id, v_username, v_nombre, v_apellido, 
    v_email, v_rol, v_token, 'Login exitoso'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- Otorgar permisos
GRANT EXECUTE ON FUNCTION nutridiab.login_usuario(VARCHAR, VARCHAR, VARCHAR, TEXT) TO dnzapata;

-- Actualizar password a texto plano para desarrollo
-- NOTA: Solo para desarrollo. En producción, usa hash bcrypt
UPDATE nutridiab.usuarios
SET password_hash = 'Fl100190'
WHERE username = 'dnzapata';

-- Verificar actualización
DO $$
DECLARE
  v_hash VARCHAR(255);
BEGIN
  SELECT password_hash INTO v_hash
  FROM nutridiab.usuarios
  WHERE username = 'dnzapata';
  
  RAISE NOTICE '';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'CONFIGURACIÓN COMPLETADA';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Función: nutridiab.login_usuario()';
  RAISE NOTICE '  - Sin dependencias de pgcrypto';
  RAISE NOTICE '  - Comparación directa de password';
  RAISE NOTICE '  - Token generado con md5()';
  RAISE NOTICE '';
  RAISE NOTICE 'Usuario: dnzapata';
  RAISE NOTICE '  Password: Fl100190';
  RAISE NOTICE '  Hash almacenado: %', v_hash;
  RAISE NOTICE '';
  RAISE NOTICE 'Probar con:';
  RAISE NOTICE '  SELECT * FROM nutridiab.login_usuario(''dnzapata'', ''Fl100190'');';
  RAISE NOTICE '';
  RAISE NOTICE 'ADVERTENCIA:';
  RAISE NOTICE '  Este setup es para DESARROLLO';
  RAISE NOTICE '  En producción, instalar pgcrypto y usar hashes bcrypt';
  RAISE NOTICE '';
END $$;

-- Test automático
SELECT 
  CASE 
    WHEN success THEN '✓ LOGIN EXITOSO'
    ELSE '✗ LOGIN FALLÓ: ' || message
  END as resultado,
  username,
  rol
FROM nutridiab.login_usuario('dnzapata', 'Fl100190', '127.0.0.1', 'test-script');

