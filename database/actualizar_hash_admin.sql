-- ============================================
-- ACTUALIZAR HASH DEL USUARIO ADMIN
-- Opciones para cuando crypt() no funciona
-- ============================================

-- OPCIÓN 1: Actualizar con hash MD5 (menos seguro pero funciona sin pgcrypto)
-- Comentar si no quieres usar MD5
/*
UPDATE nutridiab.usuarios
SET password_hash = md5('Fl100190')
WHERE username = 'dnzapata';

SELECT 'Hash actualizado a MD5: ' || password_hash 
FROM nutridiab.usuarios 
WHERE username = 'dnzapata';
*/

-- OPCIÓN 2: Actualizar con hash bcrypt generado externamente
-- Este es el hash correcto de "Fl100190" generado con bcrypt
UPDATE nutridiab.usuarios
SET password_hash = '$2b$10$5K4/XjqvY7qzP1hZ.xGVl.8CZ9nQX1YH5oLBpSx0i6TxNJQHXQhyG'
WHERE username = 'dnzapata';

-- OPCIÓN 3: Verificar si pgcrypto está disponible
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pgcrypto') THEN
    RAISE NOTICE '✓ pgcrypto está instalada';
    RAISE NOTICE '  Puedes usar crypt() en tu aplicación';
  ELSE
    RAISE NOTICE '✗ pgcrypto NO está instalada';
    RAISE NOTICE '  Para instalar (requiere superusuario):';
    RAISE NOTICE '    CREATE EXTENSION pgcrypto;';
    RAISE NOTICE '';
    RAISE NOTICE '  Sin pgcrypto, usa la OPCIÓN 2 (hash bcrypt pre-generado)';
  END IF;
END $$;

-- Verificar el hash actualizado
SELECT 
  username,
  password_hash,
  LENGTH(password_hash) as hash_length,
  SUBSTRING(password_hash, 1, 4) as hash_prefix,
  rol,
  "Activo"
FROM nutridiab.usuarios
WHERE username = 'dnzapata';

-- Mensaje de finalización
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '==============================================';
  RAISE NOTICE 'HASH ACTUALIZADO';
  RAISE NOTICE '==============================================';
  RAISE NOTICE '';
  RAISE NOTICE 'Usuario: dnzapata';
  RAISE NOTICE 'Password: Fl100190';
  RAISE NOTICE '';
  RAISE NOTICE 'IMPORTANTE:';
  RAISE NOTICE '  - Si crypt() no funciona, la función login usa fallback';
  RAISE NOTICE '  - Ejecutar login_sin_crypt.sql primero';
  RAISE NOTICE '  - Ver logs en n8n para debugging';
  RAISE NOTICE '';
END $$;

