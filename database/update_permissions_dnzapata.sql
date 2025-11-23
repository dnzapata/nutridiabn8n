-- ============================================
-- SCRIPT PARA ACTUALIZAR PERMISOS DEL USUARIO dnzapata
-- ============================================
-- Este script solo actualiza permisos, no crea tablas
-- Ejecutar como superusuario o con permisos suficientes

-- ============================================
-- PASO 1: Verificar que el usuario existe
-- ============================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'dnzapata') THEN
    RAISE EXCEPTION 'ERROR: El usuario dnzapata no existe. Créalo primero con: CREATE USER dnzapata WITH PASSWORD ''tu_password'';';
  END IF;
  RAISE NOTICE '✅ Usuario dnzapata existe';
END $$;

-- ============================================
-- PASO 2: Revocar permisos anteriores (limpieza)
-- ============================================
REVOKE ALL ON SCHEMA nutridiab FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA nutridiab FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA nutridiab FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA nutridiab FROM PUBLIC;

RAISE NOTICE '✅ Permisos públicos revocados';

-- ============================================
-- PASO 3: Otorgar permisos al usuario dnzapata
-- ============================================

-- Permisos sobre el schema
GRANT USAGE ON SCHEMA nutridiab TO dnzapata;
GRANT CREATE ON SCHEMA nutridiab TO dnzapata;
GRANT ALL PRIVILEGES ON SCHEMA nutridiab TO dnzapata;

-- Permisos sobre todas las tablas
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA nutridiab TO dnzapata;

-- Permisos sobre secuencias (para IDs autoincrementales)
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA nutridiab TO dnzapata;

-- Permisos sobre todas las funciones
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA nutridiab TO dnzapata;

-- Permisos sobre todas las vistas
GRANT ALL PRIVILEGES ON ALL VIEWS IN SCHEMA nutridiab TO dnzapata;

-- Permisos sobre el schema público (necesario para algunas operaciones)
GRANT USAGE ON SCHEMA public TO dnzapata;

-- ============================================
-- PASO 4: Cambiar ownership
-- ============================================

-- Cambiar owner del schema
ALTER SCHEMA nutridiab OWNER TO dnzapata;

-- Cambiar owner de todas las tablas
ALTER TABLE IF EXISTS nutridiab.usuarios OWNER TO dnzapata;
ALTER TABLE IF EXISTS nutridiab."Consultas" OWNER TO dnzapata;
ALTER TABLE IF EXISTS nutridiab.mensajes OWNER TO dnzapata;
ALTER TABLE IF EXISTS nutridiab.tokens_acceso OWNER TO dnzapata;

-- Cambiar owner de secuencias
ALTER SEQUENCE IF EXISTS nutridiab."usuarios_usuario ID_seq" OWNER TO dnzapata;
ALTER SEQUENCE IF EXISTS nutridiab."Consultas_id_seq" OWNER TO dnzapata;
ALTER SEQUENCE IF EXISTS nutridiab.mensajes_id_seq OWNER TO dnzapata;
ALTER SEQUENCE IF EXISTS nutridiab.tokens_acceso_id_seq OWNER TO dnzapata;

-- Cambiar owner de funciones
ALTER FUNCTION IF EXISTS nutridiab.generar_token() OWNER TO dnzapata;
ALTER FUNCTION IF EXISTS nutridiab.validar_token(VARCHAR) OWNER TO dnzapata;
ALTER FUNCTION IF EXISTS nutridiab.usar_token(VARCHAR) OWNER TO dnzapata;
ALTER FUNCTION IF EXISTS nutridiab.verificar_datos_usuario(INTEGER) OWNER TO dnzapata;
ALTER FUNCTION IF EXISTS nutridiab.puede_usar_servicio(INTEGER) OWNER TO dnzapata;
ALTER FUNCTION IF EXISTS nutridiab.bloquear_usuario(INTEGER, TEXT) OWNER TO dnzapata;
ALTER FUNCTION IF EXISTS nutridiab.activar_usuario(INTEGER) OWNER TO dnzapata;
ALTER FUNCTION IF EXISTS nutridiab.limpiar_tokens_expirados() OWNER TO dnzapata;
ALTER FUNCTION IF EXISTS nutridiab.actualizar_timestamp() OWNER TO dnzapata;

-- Cambiar owner de vista
ALTER VIEW IF EXISTS nutridiab.vista_usuarios_estado OWNER TO dnzapata;

-- ============================================
-- PASO 5: Permisos por defecto para objetos futuros
-- ============================================
ALTER DEFAULT PRIVILEGES IN SCHEMA nutridiab GRANT ALL ON TABLES TO dnzapata;
ALTER DEFAULT PRIVILEGES IN SCHEMA nutridiab GRANT ALL ON SEQUENCES TO dnzapata;
ALTER DEFAULT PRIVILEGES IN SCHEMA nutridiab GRANT ALL ON FUNCTIONS TO dnzapata;
ALTER DEFAULT PRIVILEGES IN SCHEMA nutridiab GRANT ALL ON TYPES TO dnzapata;

-- ============================================
-- PASO 6: Desactivar RLS (Row Level Security)
-- ============================================
ALTER TABLE IF EXISTS nutridiab.usuarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS nutridiab."Consultas" DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS nutridiab.mensajes DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS nutridiab.tokens_acceso DISABLE ROW LEVEL SECURITY;

-- ============================================
-- PASO 7: Permisos específicos sobre funciones
-- ============================================
GRANT EXECUTE ON FUNCTION nutridiab.generar_token() TO dnzapata;
GRANT EXECUTE ON FUNCTION nutridiab.validar_token(VARCHAR) TO dnzapata;
GRANT EXECUTE ON FUNCTION nutridiab.usar_token(VARCHAR) TO dnzapata;
GRANT EXECUTE ON FUNCTION nutridiab.verificar_datos_usuario(INTEGER) TO dnzapata;
GRANT EXECUTE ON FUNCTION nutridiab.puede_usar_servicio(INTEGER) TO dnzapata;
GRANT EXECUTE ON FUNCTION nutridiab.bloquear_usuario(INTEGER, TEXT) TO dnzapata;
GRANT EXECUTE ON FUNCTION nutridiab.activar_usuario(INTEGER) TO dnzapata;
GRANT EXECUTE ON FUNCTION nutridiab.limpiar_tokens_expirados() TO dnzapata;
GRANT EXECUTE ON FUNCTION nutridiab.actualizar_timestamp() TO dnzapata;

-- ============================================
-- PASO 8: VERIFICACIÓN FINAL
-- ============================================
DO $$
DECLARE
  tiene_permisos BOOLEAN;
BEGIN
  -- Verificar permisos sobre schema
  SELECT has_schema_privilege('dnzapata', 'nutridiab', 'USAGE') INTO tiene_permisos;
  IF NOT tiene_permisos THEN
    RAISE EXCEPTION '❌ ERROR: dnzapata no tiene permiso USAGE sobre schema nutridiab';
  END IF;
  
  -- Verificar permisos sobre tabla usuarios
  SELECT has_table_privilege('dnzapata', 'nutridiab.usuarios', 'SELECT') INTO tiene_permisos;
  IF NOT tiene_permisos THEN
    RAISE EXCEPTION '❌ ERROR: dnzapata no puede hacer SELECT en usuarios';
  END IF;
  
  SELECT has_table_privilege('dnzapata', 'nutridiab.usuarios', 'INSERT') INTO tiene_permisos;
  IF NOT tiene_permisos THEN
    RAISE EXCEPTION '❌ ERROR: dnzapata no puede hacer INSERT en usuarios';
  END IF;
  
  SELECT has_table_privilege('dnzapata', 'nutridiab.usuarios', 'UPDATE') INTO tiene_permisos;
  IF NOT tiene_permisos THEN
    RAISE EXCEPTION '❌ ERROR: dnzapata no puede hacer UPDATE en usuarios';
  END IF;
  
  SELECT has_table_privilege('dnzapata', 'nutridiab.usuarios', 'DELETE') INTO tiene_permisos;
  IF NOT tiene_permisos THEN
    RAISE EXCEPTION '❌ ERROR: dnzapata no puede hacer DELETE en usuarios';
  END IF;
  
  RAISE NOTICE '';
  RAISE NOTICE '========================================';
  RAISE NOTICE '✅ PERMISOS ACTUALIZADOS CORRECTAMENTE';
  RAISE NOTICE '========================================';
  RAISE NOTICE '';
  RAISE NOTICE '✅ Usuario: dnzapata';
  RAISE NOTICE '✅ Schema: nutridiab (owner: dnzapata)';
  RAISE NOTICE '✅ Permisos: TODOS (SELECT, INSERT, UPDATE, DELETE, EXECUTE)';
  RAISE NOTICE '✅ RLS: DESACTIVADO';
  RAISE NOTICE '';
  RAISE NOTICE '📝 Configuración para n8n:';
  RAISE NOTICE '   Host: db.xxxxx.supabase.co (tu host de Supabase)';
  RAISE NOTICE '   Port: 5432';
  RAISE NOTICE '   Database: postgres';
  RAISE NOTICE '   User: dnzapata';
  RAISE NOTICE '   Password: [tu contraseña]';
  RAISE NOTICE '   SSL: Enabled';
  RAISE NOTICE '';
  RAISE NOTICE '🔍 Para verificar permisos, ejecuta:';
  RAISE NOTICE '   SELECT * FROM pg_tables WHERE schemaname = ''nutridiab'';';
  RAISE NOTICE '';
END $$;

-- ============================================
-- CONSULTA ÚTIL: Ver todos los permisos actuales
-- ============================================
/*
-- Descomenta para ejecutar después de aplicar los permisos:

SELECT 
    schemaname,
    tablename,
    tableowner,
    has_table_privilege('dnzapata', schemaname||'.'||tablename, 'SELECT') as puede_select,
    has_table_privilege('dnzapata', schemaname||'.'||tablename, 'INSERT') as puede_insert,
    has_table_privilege('dnzapata', schemaname||'.'||tablename, 'UPDATE') as puede_update,
    has_table_privilege('dnzapata', schemaname||'.'||tablename, 'DELETE') as puede_delete
FROM pg_tables
WHERE schemaname = 'nutridiab'
ORDER BY tablename;

-- Todas las columnas deben mostrar 'true' ✅
-- tableowner debe ser 'dnzapata' ✅
*/

