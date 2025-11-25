-- ============================================
-- AUTO-CONFIGURACIÓN DE LOGIN
-- Detecta si pgcrypto está disponible y aplica la mejor solución
-- ============================================

DO $$
DECLARE
  v_tiene_pgcrypto BOOLEAN := FALSE;
  v_puede_instalar BOOLEAN := FALSE;
  v_es_superusuario BOOLEAN := FALSE;
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'AUTO-DIAGNÓSTICO';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '';
  
  -- Verificar si el usuario actual es superusuario
  SELECT usesuper INTO v_es_superusuario
  FROM pg_user
  WHERE usename = current_user;
  
  IF v_es_superusuario THEN
    RAISE NOTICE '✓ Tienes permisos de SUPERUSUARIO';
  ELSE
    RAISE NOTICE '✗ NO tienes permisos de SUPERUSUARIO';
  END IF;
  
  -- Verificar si pgcrypto está instalada
  SELECT EXISTS (
    SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto'
  ) INTO v_tiene_pgcrypto;
  
  IF v_tiene_pgcrypto THEN
    RAISE NOTICE '✓ pgcrypto está instalada';
  ELSE
    RAISE NOTICE '✗ pgcrypto NO está instalada';
  END IF;
  
  -- Verificar si pgcrypto está disponible para instalar
  IF NOT v_tiene_pgcrypto THEN
    SELECT EXISTS (
      SELECT 1 FROM pg_available_extensions WHERE name = 'pgcrypto'
    ) INTO v_puede_instalar;
    
    IF v_puede_instalar THEN
      RAISE NOTICE '✓ pgcrypto está disponible para instalar';
    ELSE
      RAISE NOTICE '✗ pgcrypto NO está disponible en este servidor';
    END IF;
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'RECOMENDACIÓN';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '';
  
  -- Recomendar solución
  IF v_tiene_pgcrypto THEN
    RAISE NOTICE '✅ USAR: migration_add_auth_roles_SIMPLE.sql';
    RAISE NOTICE '   Este es el método más seguro (usa bcrypt)';
    RAISE NOTICE '';
    RAISE NOTICE 'Ejecutar:';
    RAISE NOTICE '   psql -U % -d % -f database/migration_add_auth_roles_SIMPLE.sql', current_user, current_database();
    
  ELSIF v_es_superusuario AND v_puede_instalar THEN
    RAISE NOTICE '✅ INSTALAR pgcrypto primero';
    RAISE NOTICE '   Tienes permisos y la extensión está disponible';
    RAISE NOTICE '';
    RAISE NOTICE 'Ejecutar:';
    RAISE NOTICE '   1. psql -U % -d % -f database/instalar_pgcrypto.sql', current_user, current_database();
    RAISE NOTICE '   2. psql -U % -d % -f database/migration_add_auth_roles_SIMPLE.sql', current_user, current_database();
    
  ELSIF NOT v_es_superusuario AND v_puede_instalar THEN
    RAISE NOTICE '⚠️  NECESITAS AYUDA DEL ADMINISTRADOR';
    RAISE NOTICE '   pgcrypto está disponible pero necesitas permisos';
    RAISE NOTICE '';
    RAISE NOTICE 'Opciones:';
    RAISE NOTICE '   A) Pedir al admin que ejecute:';
    RAISE NOTICE '      CREATE EXTENSION pgcrypto;';
    RAISE NOTICE '';
    RAISE NOTICE '   B) Usar solución sin pgcrypto:';
    RAISE NOTICE '      psql -U % -d % -f database/login_simple_directo.sql', current_user, current_database();
    
  ELSE
    RAISE NOTICE '⚠️  USAR SOLUCIÓN SIN PGCRYPTO';
    RAISE NOTICE '   pgcrypto no está disponible en este servidor';
    RAISE NOTICE '';
    RAISE NOTICE 'Ejecutar:';
    RAISE NOTICE '   psql -U % -d % -f database/login_simple_directo.sql', current_user, current_database();
    RAISE NOTICE '';
    RAISE NOTICE '⚠️  NOTA: Esta solución es solo para DESARROLLO';
    RAISE NOTICE '   Para producción, considera migrar a un servidor con pgcrypto';
  END IF;
  
  RAISE NOTICE '';
  
END $$;

-- Mostrar información del sistema
SELECT 
  version() as postgres_version,
  current_user as usuario_actual,
  current_database() as base_de_datos;

-- Mostrar extensiones instaladas
SELECT 
  extname as extension,
  extversion as version
FROM pg_extension
ORDER BY extname;


