-- ============================================
-- DIAGNÓSTICO: Verificar pgcrypto y crypt()
-- ============================================

-- PASO 1: Verificar si pgcrypto está instalada
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto') THEN
    RAISE NOTICE '✓ pgcrypto está instalada';
  ELSE
    RAISE NOTICE '✗ pgcrypto NO está instalada';
    RAISE NOTICE '  Ejecutar: CREATE EXTENSION pgcrypto;';
  END IF;
END $$;

-- PASO 2: Probar crypt() con valores conocidos
DO $$
DECLARE
  v_password_prueba VARCHAR(255);
  v_hash_almacenado VARCHAR(255);
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'PRUEBA DE crypt()';
  RAISE NOTICE '==============================================';
  
  -- Hash pre-generado de "Fl100190"
  v_hash_almacenado := '$2b$10$5K4/XjqvY7qzP1hZ.xGVl.8CZ9nQX1YH5oLBpSx0i6TxNJQHXQhyG';
  
  BEGIN
    v_password_prueba := crypt('Fl100190', v_hash_almacenado);
    
    IF v_password_prueba IS NULL THEN
      RAISE NOTICE '✗ crypt() devolvió NULL';
      RAISE NOTICE '  Posible causa: pgcrypto no soporta bcrypt ($2b$)';
    ELSIF v_password_prueba = '' THEN
      RAISE NOTICE '✗ crypt() devolvió vacío';
    ELSE
      RAISE NOTICE '✓ crypt() funciona correctamente';
      RAISE NOTICE '  Resultado: %', v_password_prueba;
      
      -- Verificar comparación
      IF v_password_prueba = v_hash_almacenado THEN
        RAISE NOTICE '✓ La comparación funciona correctamente';
      ELSE
        RAISE NOTICE '✗ La comparación falló';
        RAISE NOTICE '  Hash almacenado: %', v_hash_almacenado;
        RAISE NOTICE '  Hash generado:   %', v_password_prueba;
      END IF;
    END IF;
  EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE '✗ Error al ejecutar crypt(): %', SQLERRM;
  END;
END $$;

-- PASO 3: Verificar hash del usuario dnzapata
DO $$
DECLARE
  v_password_hash VARCHAR(255);
  v_username VARCHAR(100);
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'VERIFICAR USUARIO dnzapata';
  RAISE NOTICE '==============================================';
  
  SELECT username, password_hash 
  INTO v_username, v_password_hash
  FROM nutridiab.usuarios 
  WHERE username = 'dnzapata';
  
  IF v_username IS NULL THEN
    RAISE NOTICE '✗ Usuario dnzapata no existe';
  ELSIF v_password_hash IS NULL THEN
    RAISE NOTICE '✗ Usuario dnzapata existe pero password_hash es NULL';
  ELSIF LENGTH(v_password_hash) < 20 THEN
    RAISE NOTICE '✗ password_hash es muy corto: %', v_password_hash;
  ELSE
    RAISE NOTICE '✓ Usuario existe con hash válido';
    RAISE NOTICE '  Username: %', v_username;
    RAISE NOTICE '  Hash length: %', LENGTH(v_password_hash);
    RAISE NOTICE '  Hash prefix: %', SUBSTRING(v_password_hash, 1, 10);
  END IF;
END $$;

-- PASO 4: Mostrar versión de PostgreSQL
SELECT version() AS postgres_version;

