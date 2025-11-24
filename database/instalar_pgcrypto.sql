-- ============================================
-- INSTALAR EXTENSIÓN pgcrypto
-- Necesaria para funciones crypt() y gen_salt()
-- ============================================

-- IMPORTANTE: Este script requiere permisos de SUPERUSUARIO
-- Si no tienes permisos, contacta al administrador de la base de datos

-- Verificar extensiones disponibles
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'VERIFICANDO EXTENSIONES DISPONIBLES';
  RAISE NOTICE '==============================================';
END $$;

SELECT 
  name,
  installed_version,
  CASE 
    WHEN installed_version IS NOT NULL THEN '✓ Instalada'
    ELSE '✗ No instalada'
  END as estado
FROM pg_available_extensions
WHERE name IN ('pgcrypto', 'uuid-ossp')
ORDER BY name;

-- Intentar instalar pgcrypto
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'INTENTANDO INSTALAR pgcrypto';
  RAISE NOTICE '==============================================';
  
  BEGIN
    CREATE EXTENSION IF NOT EXISTS pgcrypto;
    RAISE NOTICE '✓ pgcrypto instalada exitosamente';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE '✗ Error: No tienes permisos de SUPERUSUARIO';
    RAISE NOTICE '';
    RAISE NOTICE 'Opciones:';
    RAISE NOTICE '  1. Conectarte como postgres:';
    RAISE NOTICE '     psql -U postgres -d nutridiab -c "CREATE EXTENSION pgcrypto;"';
    RAISE NOTICE '';
    RAISE NOTICE '  2. En Supabase:';
    RAISE NOTICE '     Dashboard → Database → Extensions → Habilitar pgcrypto';
    RAISE NOTICE '';
    RAISE NOTICE '  3. En Docker:';
    RAISE NOTICE '     docker exec -it <container> psql -U postgres -d nutridiab';
    RAISE NOTICE '     CREATE EXTENSION pgcrypto;';
    RAISE NOTICE '';
    RAISE NOTICE '  4. Usar login_sin_crypt.sql (funciona SIN pgcrypto)';
  WHEN OTHERS THEN
    RAISE NOTICE '✗ Error inesperado: %', SQLERRM;
  END;
END $$;

-- Verificar instalación
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'VERIFICACIÓN FINAL';
  RAISE NOTICE '==============================================';
  
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto') THEN
    RAISE NOTICE '✓ pgcrypto está instalada y lista para usar';
    RAISE NOTICE '';
    RAISE NOTICE 'Funciones disponibles:';
    RAISE NOTICE '  - crypt(password, salt)';
    RAISE NOTICE '  - gen_salt(type, rounds)';
    RAISE NOTICE '  - encrypt(), decrypt()';
    RAISE NOTICE '  - digest(), hmac()';
    RAISE NOTICE '';
    RAISE NOTICE 'Próximo paso:';
    RAISE NOTICE '  Ejecutar: migration_add_auth_roles_SIMPLE.sql';
  ELSE
    RAISE NOTICE '✗ pgcrypto NO está instalada';
    RAISE NOTICE '';
    RAISE NOTICE 'Alternativa (SIN pgcrypto):';
    RAISE NOTICE '  1. Ejecutar: login_sin_crypt.sql';
    RAISE NOTICE '  2. Ejecutar: actualizar_hash_admin.sql';
    RAISE NOTICE '';
    RAISE NOTICE 'Esto funcionará con hashes pre-generados';
  END IF;
END $$;

-- Probar crypt() si está disponible
DO $$
DECLARE
  v_test_hash VARCHAR(255);
  v_test_result BOOLEAN;
BEGIN
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto') THEN
    RAISE NOTICE '';
    RAISE NOTICE '==============================================';
    RAISE NOTICE 'PRUEBA DE crypt()';
    RAISE NOTICE '==============================================';
    
    BEGIN
      -- Generar hash de prueba
      v_test_hash := crypt('test123', gen_salt('bf', 10));
      RAISE NOTICE '✓ gen_salt() funciona';
      RAISE NOTICE '  Hash generado: %', SUBSTRING(v_test_hash, 1, 30) || '...';
      
      -- Verificar hash
      v_test_result := (crypt('test123', v_test_hash) = v_test_hash);
      
      IF v_test_result THEN
        RAISE NOTICE '✓ crypt() funciona correctamente';
        RAISE NOTICE '';
        RAISE NOTICE '¡Todo listo para usar autenticación segura!';
      ELSE
        RAISE NOTICE '✗ crypt() no verifica correctamente';
      END IF;
      
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE '✗ Error al probar crypt(): %', SQLERRM;
    END;
  END IF;
END $$;

