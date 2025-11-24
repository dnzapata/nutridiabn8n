-- ============================================
-- SCRIPT DE VERIFICACIÓN - Sistema de Autenticación
-- ============================================
-- Ejecuta este script para verificar que todo esté instalado correctamente

-- 1. Verificar que la tabla usuarios tiene las columnas nuevas
SELECT 
  column_name, 
  data_type,
  is_nullable
FROM information_schema.columns 
WHERE table_schema = 'nutridiab' 
  AND table_name = 'usuarios'
  AND column_name IN ('username', 'password_hash', 'rol', 'ultimo_login')
ORDER BY column_name;
-- Debe mostrar 4 filas

-- 2. Verificar que la tabla sesiones existe
SELECT 
  table_name,
  table_type
FROM information_schema.tables 
WHERE table_schema = 'nutridiab' 
  AND table_name = 'sesiones';
-- Debe mostrar 1 fila

-- 3. Verificar que el usuario dnzapata existe
SELECT 
  "usuario ID",
  username,
  rol,
  nombre,
  apellido,
  "Activo",
  "Bloqueado",
  created_at
FROM nutridiab.usuarios 
WHERE username = 'dnzapata';
-- Debe mostrar 1 fila con rol = 'administrador'

-- 4. Verificar que la extensión pgcrypto está habilitada
SELECT 
  extname,
  extversion
FROM pg_extension 
WHERE extname = 'pgcrypto';
-- Debe mostrar 1 fila

-- 5. Verificar que las funciones existen
SELECT 
  routine_name,
  routine_type
FROM information_schema.routines 
WHERE routine_schema = 'nutridiab'
  AND routine_name IN (
    'login_usuario',
    'validar_sesion',
    'logout_usuario',
    'es_administrador',
    'limpiar_sesiones_expiradas'
  )
ORDER BY routine_name;
-- Debe mostrar 5 filas

-- 6. Probar la función de login (TEST)
-- IMPORTANTE: Esto es solo una prueba, NO es el login real
SELECT * FROM nutridiab.login_usuario(
  'dnzapata',
  crypt('Fl100190', (SELECT password_hash FROM nutridiab.usuarios WHERE username = 'dnzapata')),
  '127.0.0.1',
  'test'
);
-- Debe mostrar success = true y un token

-- 7. Verificar permisos del usuario dnzapata en PostgreSQL
SELECT 
  grantee,
  privilege_type,
  table_name
FROM information_schema.table_privileges 
WHERE grantee = 'dnzapata'
  AND table_schema = 'nutridiab'
  AND table_name IN ('usuarios', 'sesiones')
ORDER BY table_name, privilege_type;
-- Debe mostrar varios permisos (SELECT, INSERT, UPDATE, DELETE, etc.)

-- ============================================
-- RESULTADOS ESPERADOS
-- ============================================

/*
Si todo está correcto, deberías ver:

✅ Query 1: 4 columnas (username, password_hash, rol, ultimo_login)
✅ Query 2: 1 tabla (sesiones)
✅ Query 3: 1 usuario (dnzapata, rol = administrador)
✅ Query 4: 1 extensión (pgcrypto)
✅ Query 5: 5 funciones (login_usuario, validar_sesion, etc.)
✅ Query 6: success = true con un token generado
✅ Query 7: Múltiples permisos para dnzapata

Si alguna query no devuelve resultados, ejecuta:
  \i database/migration_add_auth_roles.sql
*/

