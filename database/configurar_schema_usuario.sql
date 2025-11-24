-- ============================================
-- CONFIGURAR SCHEMA POR DEFECTO PARA n8n
-- Establece search_path para el usuario dnzapata
-- ============================================

-- Verificar configuración actual
DO $$
DECLARE
  v_current_search_path TEXT;
  v_rolconfig TEXT[];
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'CONFIGURACIÓN ACTUAL';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '';
  
  -- Search path de la sesión actual
  SELECT current_setting('search_path') INTO v_current_search_path;
  RAISE NOTICE 'Search path actual: %', v_current_search_path;
  
  -- Configuración del rol
  SELECT rolconfig INTO v_rolconfig
  FROM pg_roles
  WHERE rolname = 'dnzapata';
  
  IF v_rolconfig IS NULL THEN
    RAISE NOTICE 'Usuario dnzapata: Sin configuración de search_path';
  ELSE
    RAISE NOTICE 'Configuración del rol: %', v_rolconfig;
  END IF;
  
END $$;

-- Configurar search_path permanente para el usuario
ALTER ROLE dnzapata SET search_path TO nutridiab, public;

-- Aplicar a la sesión actual también
SET search_path TO nutridiab, public;

-- Verificar nueva configuración
DO $$
DECLARE
  v_new_search_path TEXT;
  v_rolconfig TEXT[];
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'NUEVA CONFIGURACIÓN';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '';
  
  -- Nueva configuración de la sesión
  SELECT current_setting('search_path') INTO v_new_search_path;
  RAISE NOTICE '✓ Search path de sesión: %', v_new_search_path;
  
  -- Nueva configuración del rol
  SELECT rolconfig INTO v_rolconfig
  FROM pg_roles
  WHERE rolname = 'dnzapata';
  
  RAISE NOTICE '✓ Configuración permanente del rol: %', v_rolconfig;
  RAISE NOTICE '';
  RAISE NOTICE 'El usuario dnzapata ahora usa automáticamente:';
  RAISE NOTICE '  1. Schema nutridiab (prioridad)';
  RAISE NOTICE '  2. Schema public (fallback)';
  
END $$;

-- Probar búsqueda de tablas
DO $$
DECLARE
  v_tabla_encontrada BOOLEAN;
  v_schema TEXT;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'PRUEBAS DE BÚSQUEDA';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '';
  
  -- Buscar tabla usuarios sin especificar schema
  SELECT schemaname INTO v_schema
  FROM pg_tables
  WHERE tablename = 'usuarios'
    AND schemaname IN ('nutridiab', 'public')
  ORDER BY 
    CASE schemaname 
      WHEN 'nutridiab' THEN 1
      WHEN 'public' THEN 2
    END
  LIMIT 1;
  
  IF v_schema IS NOT NULL THEN
    RAISE NOTICE '✓ Tabla "usuarios" encontrada en schema: %', v_schema;
    RAISE NOTICE '  Query simplificado funcionará: SELECT * FROM usuarios;';
  ELSE
    RAISE NOTICE '✗ Tabla "usuarios" no encontrada';
  END IF;
  
END $$;

-- Probar búsqueda de funciones
DO $$
DECLARE
  v_funcion_schema TEXT;
BEGIN
  RAISE NOTICE '';
  
  -- Buscar función login_usuario
  SELECT routine_schema INTO v_funcion_schema
  FROM information_schema.routines
  WHERE routine_name = 'login_usuario'
    AND routine_schema IN ('nutridiab', 'public')
  ORDER BY 
    CASE routine_schema 
      WHEN 'nutridiab' THEN 1
      WHEN 'public' THEN 2
    END
  LIMIT 1;
  
  IF v_funcion_schema IS NOT NULL THEN
    RAISE NOTICE '✓ Función "login_usuario" encontrada en schema: %', v_funcion_schema;
    RAISE NOTICE '  Query simplificado funcionará: SELECT * FROM login_usuario(...);';
  ELSE
    RAISE NOTICE '✗ Función "login_usuario" no encontrada';
    RAISE NOTICE '  Asegúrate de haber ejecutado migration_add_auth_roles_SIMPLE.sql';
  END IF;
  
END $$;

-- Test funcional: Intentar SELECT simple
DO $$
DECLARE
  v_count INTEGER;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'TEST FUNCIONAL';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '';
  
  BEGIN
    -- Intentar SELECT sin especificar schema
    SELECT COUNT(*) INTO v_count FROM usuarios;
    RAISE NOTICE '✓ SELECT sin schema funciona correctamente';
    RAISE NOTICE '  Total de usuarios: %', v_count;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '✗ SELECT sin schema falló: %', SQLERRM;
    RAISE NOTICE '  Usa: SELECT * FROM nutridiab.usuarios;';
  END;
  
END $$;

-- Información para n8n
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'CONFIGURACIÓN PARA n8n';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Ahora puedes usar en tus workflows:';
  RAISE NOTICE '';
  RAISE NOTICE '  Queries simplificados:';
  RAISE NOTICE '    ✓ SELECT * FROM usuarios';
  RAISE NOTICE '    ✓ SELECT * FROM sesiones';
  RAISE NOTICE '    ✓ INSERT INTO usuarios (...) VALUES (...)';
  RAISE NOTICE '';
  RAISE NOTICE '  Funciones simplificadas:';
  RAISE NOTICE '    ✓ SELECT * FROM login_usuario($1, $2)';
  RAISE NOTICE '    ✓ SELECT * FROM validar_sesion($1)';
  RAISE NOTICE '    ✓ SELECT * FROM logout_usuario($1)';
  RAISE NOTICE '';
  RAISE NOTICE '  En lugar de:';
  RAISE NOTICE '    ✗ SELECT * FROM nutridiab.usuarios';
  RAISE NOTICE '    ✗ SELECT * FROM nutridiab.login_usuario(...)';
  RAISE NOTICE '';
  RAISE NOTICE 'IMPORTANTE:';
  RAISE NOTICE '  - Reinicia las conexiones de n8n para aplicar cambios';
  RAISE NOTICE '  - O reinicia el servicio n8n completamente';
  RAISE NOTICE '';
  RAISE NOTICE 'Comando para reiniciar n8n (Docker):';
  RAISE NOTICE '  docker restart n8n';
  RAISE NOTICE '';
END $$;

-- Resumen final
SELECT 
  rolname AS usuario,
  CASE 
    WHEN rolconfig IS NULL THEN 'Sin configuración'
    ELSE array_to_string(rolconfig, ', ')
  END AS configuracion
FROM pg_roles
WHERE rolname = 'dnzapata';

