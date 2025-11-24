-- ============================================
-- FUNCIÓN DE LOGIN SIN CRYPT (TEMPORAL)
-- Para usar mientras se soluciona el problema con pgcrypto
-- ============================================

-- Eliminar función anterior
DROP FUNCTION IF EXISTS nutridiab.login_usuario(VARCHAR, VARCHAR, VARCHAR, TEXT);

-- Función de login sin crypt - compara directo con hash
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
  v_password_valida BOOLEAN := FALSE;
  v_crypt_result VARCHAR(255);
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
  
  -- Log para debugging (comentar en producción)
  RAISE NOTICE 'Usuario encontrado: %, Hash: %', v_username, SUBSTRING(v_password_hash, 1, 20);
  RAISE NOTICE 'Password recibido: %', p_password;
  
  -- MÉTODO 1: Intentar con crypt() si está disponible
  BEGIN
    v_crypt_result := crypt(p_password, v_password_hash);
    RAISE NOTICE 'crypt() resultado: %', v_crypt_result;
    
    IF v_crypt_result IS NOT NULL AND v_crypt_result != '' THEN
      v_password_valida := (v_crypt_result = v_password_hash);
      RAISE NOTICE 'Validación con crypt: %', v_password_valida;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'crypt() falló: %', SQLERRM;
  END;
  
  -- MÉTODO 2: Si crypt falló, comparar contraseña directa con hash (fallback)
  IF NOT v_password_valida THEN
    v_password_valida := (v_password_hash = p_password);
    RAISE NOTICE 'Validación directa (hash == password): %', v_password_valida;
  END IF;
  
  -- MÉTODO 3: Comparar contraseña directa sin hash (para testing)
  -- Solo para el usuario admin durante desarrollo
  IF NOT v_password_valida AND v_username = 'dnzapata' AND p_password = 'Fl100190' THEN
    v_password_valida := TRUE;
    RAISE NOTICE 'Validación hardcoded para admin: TRUE';
  END IF;
  
  -- Verificar resultado
  IF NOT v_password_valida THEN
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
  
  -- Generar token de sesión
  BEGIN
    v_token := encode(gen_random_bytes(32), 'hex');
  EXCEPTION WHEN OTHERS THEN
    -- Si gen_random_bytes no funciona, usar md5 como alternativa
    v_token := md5(random()::text || clock_timestamp()::text || p_username);
  END;
  
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

-- Mensaje de finalización
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'FUNCIÓN DE LOGIN ACTUALIZADA';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Esta versión incluye:';
  RAISE NOTICE '  1. Intento con crypt() si está disponible';
  RAISE NOTICE '  2. Fallback a comparación directa de hash';
  RAISE NOTICE '  3. Bypass temporal para admin (dnzapata/Fl100190)';
  RAISE NOTICE '  4. Logs detallados para debugging';
  RAISE NOTICE '';
  RAISE NOTICE 'NOTA: Los RAISE NOTICE son solo para debugging';
  RAISE NOTICE 'Comentar/eliminar en producción';
  RAISE NOTICE '';
END $$;

