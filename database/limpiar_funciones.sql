-- ============================================
-- SCRIPT: Limpiar funciones existentes
-- ============================================
-- Ejecuta esto ANTES de la migración si tienes errores

-- Eliminar funciones si existen
DROP FUNCTION IF EXISTS nutridiab.login_usuario(VARCHAR, VARCHAR, VARCHAR, TEXT);
DROP FUNCTION IF EXISTS nutridiab.validar_sesion(VARCHAR);
DROP FUNCTION IF EXISTS nutridiab.logout_usuario(VARCHAR);
DROP FUNCTION IF EXISTS nutridiab.es_administrador(VARCHAR);
DROP FUNCTION IF EXISTS nutridiab.limpiar_sesiones_expiradas();

-- Mensaje de confirmación
DO $$
BEGIN
  RAISE NOTICE 'Funciones eliminadas. Ahora puedes ejecutar la migracion.';
END $$;

