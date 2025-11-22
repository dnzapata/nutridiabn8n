-- ============================================
-- FUNCIONES RPC PARA USAR CON NODOS SUPABASE
-- ============================================
-- Estas funciones pueden ser llamadas desde n8n usando nodos Supabase (RPC)

-- 1. FUNCIÓN: Generar Token de Registro
-- ============================================
CREATE OR REPLACE FUNCTION nutridiab.rpc_generar_token(p_usuario_id INTEGER)
RETURNS JSON AS $$
DECLARE
  v_token VARCHAR(255);
  v_expira TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Generar token único
  v_token := encode(gen_random_bytes(32), 'hex');
  v_expira := NOW() + INTERVAL '24 hours';
  
  -- Insertar token
  INSERT INTO nutridiab.tokens_acceso ("usuario ID", token, tipo, expira)
  VALUES (p_usuario_id, v_token, 'registro', v_expira);
  
  -- Retornar resultado como JSON
  RETURN json_build_object(
    'success', true,
    'token', v_token,
    'expira', v_expira,
    'usuario_id', p_usuario_id
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION nutridiab.rpc_generar_token IS 
'Genera un token único para registro de usuario. Llámalo desde n8n usando Supabase RPC.';

-- 2. FUNCIÓN: Validar Token
-- ============================================
CREATE OR REPLACE FUNCTION nutridiab.rpc_validar_token(p_token VARCHAR(255))
RETURNS JSON AS $$
DECLARE
  v_resultado RECORD;
BEGIN
  -- Validar token
  SELECT * INTO v_resultado FROM nutridiab.validar_token(p_token);
  
  -- Retornar como JSON
  RETURN json_build_object(
    'valido', v_resultado.valido,
    'usuario_id', v_resultado.usuario_id,
    'tipo', v_resultado.tipo,
    'expiro', v_resultado.expiro
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION nutridiab.rpc_validar_token IS 
'Valida un token de acceso. Retorna si es válido, usuario_id y si expiró.';

-- 3. FUNCIÓN: Actualizar Datos de Usuario
-- ============================================
CREATE OR REPLACE FUNCTION nutridiab.rpc_actualizar_usuario(
  p_usuario_id INTEGER,
  p_nombre VARCHAR(255),
  p_apellido VARCHAR(255),
  p_email VARCHAR(255),
  p_telefono VARCHAR(50) DEFAULT NULL,
  p_fecha_nacimiento DATE DEFAULT NULL,
  p_tipo_diabetes VARCHAR(50) DEFAULT NULL,
  p_anios_diagnostico INTEGER DEFAULT NULL,
  p_usa_insulina BOOLEAN DEFAULT FALSE,
  p_medicamentos TEXT DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
  v_usuario RECORD;
BEGIN
  -- Actualizar usuario
  UPDATE nutridiab.usuarios
  SET 
    nombre = p_nombre,
    apellido = p_apellido,
    email = p_email,
    telefono = COALESCE(p_telefono, telefono),
    fecha_nacimiento = COALESCE(p_fecha_nacimiento, fecha_nacimiento),
    tipo_diabetes = COALESCE(p_tipo_diabetes, tipo_diabetes),
    anios_diagnostico = COALESCE(p_anios_diagnostico, anios_diagnostico),
    usa_insulina = p_usa_insulina,
    medicamentos = COALESCE(p_medicamentos, medicamentos),
    datos_completos = TRUE,
    updated_at = NOW()
  WHERE "usuario ID" = p_usuario_id
  RETURNING * INTO v_usuario;
  
  -- Retornar usuario actualizado
  RETURN row_to_json(v_usuario);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION nutridiab.rpc_actualizar_usuario IS 
'Actualiza datos completos de un usuario y marca datos_completos = TRUE.';

-- 4. FUNCIÓN: Marcar Token como Usado
-- ============================================
CREATE OR REPLACE FUNCTION nutridiab.rpc_usar_token(p_token VARCHAR(255))
RETURNS JSON AS $$
DECLARE
  v_usado BOOLEAN;
BEGIN
  -- Llamar función existente
  v_usado := nutridiab.usar_token(p_token);
  
  -- Retornar resultado
  RETURN json_build_object(
    'success', v_usado,
    'mensaje', CASE 
      WHEN v_usado THEN 'Token marcado como usado'
      ELSE 'Token no encontrado o ya usado'
    END
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION nutridiab.rpc_usar_token IS 
'Marca un token como usado. Retorna true si fue exitoso.';

-- 5. FUNCIÓN: Obtener Estadísticas para Dashboard
-- ============================================
CREATE OR REPLACE FUNCTION nutridiab.rpc_dashboard_stats()
RETURNS JSON AS $$
DECLARE
  v_stats JSON;
BEGIN
  SELECT json_build_object(
    'total_usuarios', (SELECT COUNT(*) FROM nutridiab.usuarios),
    'usuarios_activos', (SELECT COUNT(*) FROM nutridiab.usuarios WHERE "Activo" = TRUE),
    'total_consultas', (SELECT COUNT(*) FROM nutridiab."Consultas"),
    'costo_total', (SELECT COALESCE(SUM("Costo"), 0) FROM nutridiab."Consultas"),
    'consultas_hoy', (SELECT COUNT(*) FROM nutridiab."Consultas" WHERE created_at >= CURRENT_DATE),
    'usuarios_hoy', (SELECT COUNT(*) FROM nutridiab.usuarios WHERE created_at >= CURRENT_DATE),
    'consultas_texto', (SELECT COUNT(*) FROM nutridiab."Consultas" WHERE tipo = 'texto'),
    'consultas_imagen', (SELECT COUNT(*) FROM nutridiab."Consultas" WHERE tipo = 'imagen'),
    'consultas_audio', (SELECT COUNT(*) FROM nutridiab."Consultas" WHERE tipo = 'audio')
  ) INTO v_stats;
  
  RETURN v_stats;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION nutridiab.rpc_dashboard_stats IS 
'Retorna estadísticas completas para el dashboard de administración.';

-- 6. FUNCIÓN: Obtener Lista de Usuarios con Estadísticas
-- ============================================
CREATE OR REPLACE FUNCTION nutridiab.rpc_lista_usuarios(p_limit INTEGER DEFAULT 100)
RETURNS JSON AS $$
DECLARE
  v_usuarios JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO v_usuarios
  FROM (
    SELECT 
      u."usuario ID",
      u.nombre,
      u.apellido,
      u.email,
      u."remoteJid",
      u."AceptoTerminos",
      u.datos_completos,
      u.email_verificado,
      u."Activo",
      u."Bloqueado",
      u.tipo_diabetes,
      u.created_at,
      u.ultimo_acceso,
      COUNT(c.id) as total_consultas,
      COALESCE(SUM(c."Costo"), 0) as costo_total,
      MAX(c.created_at) as ultima_consulta
    FROM nutridiab.usuarios u
    LEFT JOIN nutridiab."Consultas" c ON u."usuario ID" = c."usuario ID"
    GROUP BY u."usuario ID"
    ORDER BY u.created_at DESC
    LIMIT p_limit
  ) t;
  
  RETURN COALESCE(v_usuarios, '[]'::json);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION nutridiab.rpc_lista_usuarios IS 
'Retorna lista de usuarios con sus estadísticas de consultas.';

-- 7. FUNCIÓN: Obtener Consultas Recientes
-- ============================================
CREATE OR REPLACE FUNCTION nutridiab.rpc_consultas_recientes(p_limit INTEGER DEFAULT 50)
RETURNS JSON AS $$
DECLARE
  v_consultas JSON;
BEGIN
  SELECT json_agg(row_to_json(t))
  INTO v_consultas
  FROM (
    SELECT 
      c.id,
      c.tipo,
      c.resultado,
      c."Costo",
      c.created_at,
      u.nombre,
      u.apellido,
      u.email
    FROM nutridiab."Consultas" c
    JOIN nutridiab.usuarios u ON c."usuario ID" = u."usuario ID"
    ORDER BY c.created_at DESC
    LIMIT p_limit
  ) t;
  
  RETURN COALESCE(v_consultas, '[]'::json);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION nutridiab.rpc_consultas_recientes IS 
'Retorna consultas recientes con datos del usuario que las realizó.';

-- ============================================
-- OTORGAR PERMISOS DE EJECUCIÓN
-- ============================================

-- Estas funciones usan SECURITY DEFINER, lo que significa que se ejecutan
-- con los permisos del owner (postgres), no del usuario que las llama.
-- Esto permite que la API de Supabase las ejecute sin problemas de permisos.

GRANT EXECUTE ON FUNCTION nutridiab.rpc_generar_token(INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION nutridiab.rpc_validar_token(VARCHAR) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION nutridiab.rpc_actualizar_usuario(INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, DATE, VARCHAR, INTEGER, BOOLEAN, TEXT) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION nutridiab.rpc_usar_token(VARCHAR) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION nutridiab.rpc_dashboard_stats() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION nutridiab.rpc_lista_usuarios(INTEGER) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION nutridiab.rpc_consultas_recientes(INTEGER) TO anon, authenticated;

-- ============================================
-- VERIFICACIÓN
-- ============================================

-- Probar funciones
DO $$
BEGIN
  RAISE NOTICE '✅ Funciones RPC creadas exitosamente';
  RAISE NOTICE '✅ Puedes llamarlas desde n8n usando nodos Supabase (RPC)';
  RAISE NOTICE '';
  RAISE NOTICE 'Funciones disponibles:';
  RAISE NOTICE '  - nutridiab.rpc_generar_token(usuario_id)';
  RAISE NOTICE '  - nutridiab.rpc_validar_token(token)';
  RAISE NOTICE '  - nutridiab.rpc_actualizar_usuario(...)';
  RAISE NOTICE '  - nutridiab.rpc_usar_token(token)';
  RAISE NOTICE '  - nutridiab.rpc_dashboard_stats()';
  RAISE NOTICE '  - nutridiab.rpc_lista_usuarios(limit)';
  RAISE NOTICE '  - nutridiab.rpc_consultas_recientes(limit)';
END $$;

-- Listar funciones creadas
SELECT 
  routine_name as "Función",
  routine_type as "Tipo"
FROM information_schema.routines
WHERE routine_schema = 'nutridiab' 
  AND routine_name LIKE 'rpc_%'
ORDER BY routine_name;

