-- ============================================
-- MIGRACIÓN: Agregar Nuevos Campos a Tabla usuarios
-- Schema: nutridiab
-- Fecha: 2025-11-21
-- Descripción: Agrega campos de control de usuario, tipo, lenguaje e invitación
-- ============================================

-- Verificar que estamos en el schema correcto
SET search_path TO nutridiab;

-- ============================================
-- AGREGAR NUEVOS CAMPOS
-- ============================================

-- 1. Campo Activo: Controla si el usuario está activo en el sistema
ALTER TABLE nutridiab.usuarios 
ADD COLUMN IF NOT EXISTS "Activo" BOOLEAN DEFAULT TRUE;

COMMENT ON COLUMN nutridiab.usuarios."Activo" IS 
'Indica si el usuario está activo en el sistema. TRUE = activo, FALSE = inactivo';

-- 2. Campo Bloqueado: Indica si el usuario fue bloqueado por admin
ALTER TABLE nutridiab.usuarios 
ADD COLUMN IF NOT EXISTS "Bloqueado" BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN nutridiab.usuarios."Bloqueado" IS 
'Indica si el usuario fue bloqueado por un administrador. TRUE = bloqueado, FALSE = no bloqueado';

-- 3. Campo Tipo ID: Tipo de identificación del usuario
ALTER TABLE nutridiab.usuarios 
ADD COLUMN IF NOT EXISTS "Tipo ID" VARCHAR(50);

COMMENT ON COLUMN nutridiab.usuarios."Tipo ID" IS 
'Tipo de identificación del usuario (DNI, Pasaporte, Cédula, etc.)';

-- 4. Campo Lenguaje: Idioma preferido del usuario
ALTER TABLE nutridiab.usuarios 
ADD COLUMN IF NOT EXISTS "Lenguaje" VARCHAR(10) DEFAULT 'es';

COMMENT ON COLUMN nutridiab.usuarios."Lenguaje" IS 
'Código de idioma preferido del usuario (es, en, pt, etc.)';

-- 5. Campo invitado: Indica si el usuario llegó por invitación
ALTER TABLE nutridiab.usuarios 
ADD COLUMN IF NOT EXISTS "invitado" BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN nutridiab.usuarios."invitado" IS 
'Indica si el usuario fue invitado por otro usuario. TRUE = invitado, FALSE = registro directo';

-- 6. Campo ultpago: Fecha del último pago realizado
ALTER TABLE nutridiab.usuarios 
ADD COLUMN IF NOT EXISTS "ultpago" DATE;

COMMENT ON COLUMN nutridiab.usuarios."ultpago" IS 
'Fecha del último pago realizado por el usuario (si aplica sistema de pagos)';

-- ============================================
-- CREAR ÍNDICES PARA MEJOR PERFORMANCE
-- ============================================

-- Índice para búsquedas por usuarios activos
CREATE INDEX IF NOT EXISTS idx_usuarios_activo 
ON nutridiab.usuarios("Activo") 
WHERE "Activo" = TRUE;

-- Índice para búsquedas por usuarios bloqueados
CREATE INDEX IF NOT EXISTS idx_usuarios_bloqueado 
ON nutridiab.usuarios("Bloqueado") 
WHERE "Bloqueado" = TRUE;

-- Índice para búsquedas por lenguaje
CREATE INDEX IF NOT EXISTS idx_usuarios_lenguaje 
ON nutridiab.usuarios("Lenguaje");

-- Índice para búsquedas por usuarios invitados
CREATE INDEX IF NOT EXISTS idx_usuarios_invitado 
ON nutridiab.usuarios("invitado") 
WHERE "invitado" = TRUE;

-- Índice para ordenar por fecha de último pago
CREATE INDEX IF NOT EXISTS idx_usuarios_ultpago 
ON nutridiab.usuarios("ultpago");

-- ============================================
-- ACTUALIZAR DATOS EXISTENTES (OPCIONAL)
-- ============================================

-- Establecer todos los usuarios existentes como activos
UPDATE nutridiab.usuarios 
SET "Activo" = TRUE 
WHERE "Activo" IS NULL;

-- Establecer todos los usuarios existentes como no bloqueados
UPDATE nutridiab.usuarios 
SET "Bloqueado" = FALSE 
WHERE "Bloqueado" IS NULL;

-- Establecer lenguaje español por defecto para usuarios existentes
UPDATE nutridiab.usuarios 
SET "Lenguaje" = 'es' 
WHERE "Lenguaje" IS NULL;

-- Establecer usuarios existentes como no invitados
UPDATE nutridiab.usuarios 
SET "invitado" = FALSE 
WHERE "invitado" IS NULL;

-- ============================================
-- ACTUALIZAR VISTA DE ESTADO DE USUARIOS
-- ============================================

-- Recrear la vista para incluir los nuevos campos
CREATE OR REPLACE VIEW nutridiab.vista_usuarios_estado AS
SELECT 
  u."usuario ID",
  u."remoteJid",
  u.nombre,
  u.apellido,
  u.email,
  u."AceptoTerminos",
  u.datos_completos,
  u.email_verificado,
  u."Activo",
  u."Bloqueado",
  u."Tipo ID",
  u."Lenguaje",
  u.invitado,
  u.ultpago,
  u.created_at,
  u.ultimo_acceso,
  CASE 
    WHEN NOT u."Activo" THEN 'inactivo'
    WHEN u."Bloqueado" THEN 'bloqueado'
    WHEN NOT u."AceptoTerminos" THEN 'pendiente_terminos'
    WHEN NOT u.datos_completos THEN 'pendiente_datos'
    WHEN NOT u.email_verificado THEN 'pendiente_email'
    ELSE 'activo'
  END AS estado,
  COUNT(c.id) AS total_consultas,
  MAX(c.created_at) AS ultima_consulta,
  SUM(c."Costo") AS costo_total
FROM nutridiab.usuarios u
LEFT JOIN nutridiab."Consultas" c ON u."usuario ID" = c."usuario ID"
GROUP BY u."usuario ID";

COMMENT ON VIEW nutridiab.vista_usuarios_estado IS 
'Vista consolidada del estado de usuarios incluyendo campos de control y estadísticas';

-- ============================================
-- FUNCIÓN: Verificar si usuario puede usar servicio
-- ============================================

CREATE OR REPLACE FUNCTION nutridiab.puede_usar_servicio(p_usuario_id INTEGER)
RETURNS TABLE(
  puede_usar BOOLEAN,
  razon VARCHAR(255),
  estado VARCHAR(50)
) AS $$
DECLARE
  v_activo BOOLEAN;
  v_bloqueado BOOLEAN;
  v_acepto_terminos BOOLEAN;
  v_datos_completos BOOLEAN;
  v_email_verificado BOOLEAN;
BEGIN
  -- Obtener datos del usuario
  SELECT 
    "Activo",
    "Bloqueado",
    "AceptoTerminos",
    datos_completos,
    email_verificado
  INTO 
    v_activo,
    v_bloqueado,
    v_acepto_terminos,
    v_datos_completos,
    v_email_verificado
  FROM nutridiab.usuarios
  WHERE "usuario ID" = p_usuario_id;
  
  -- Verificar si el usuario existe
  IF NOT FOUND THEN
    RETURN QUERY SELECT FALSE, 'Usuario no encontrado'::VARCHAR(255), 'no_encontrado'::VARCHAR(50);
    RETURN;
  END IF;
  
  -- Verificar si está bloqueado
  IF v_bloqueado THEN
    RETURN QUERY SELECT FALSE, 'Usuario bloqueado por administrador'::VARCHAR(255), 'bloqueado'::VARCHAR(50);
    RETURN;
  END IF;
  
  -- Verificar si está activo
  IF NOT v_activo THEN
    RETURN QUERY SELECT FALSE, 'Usuario inactivo'::VARCHAR(255), 'inactivo'::VARCHAR(50);
    RETURN;
  END IF;
  
  -- Verificar términos
  IF NOT v_acepto_terminos THEN
    RETURN QUERY SELECT FALSE, 'Debe aceptar términos y condiciones'::VARCHAR(255), 'pendiente_terminos'::VARCHAR(50);
    RETURN;
  END IF;
  
  -- Verificar datos completos
  IF NOT v_datos_completos THEN
    RETURN QUERY SELECT FALSE, 'Debe completar datos personales'::VARCHAR(255), 'pendiente_datos'::VARCHAR(50);
    RETURN;
  END IF;
  
  -- Verificar email verificado
  IF NOT v_email_verificado THEN
    RETURN QUERY SELECT FALSE, 'Debe verificar su email'::VARCHAR(255), 'pendiente_email'::VARCHAR(50);
    RETURN;
  END IF;
  
  -- Todo OK, puede usar el servicio
  RETURN QUERY SELECT TRUE, 'Usuario autorizado'::VARCHAR(255), 'activo'::VARCHAR(50);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION nutridiab.puede_usar_servicio IS 
'Verifica si un usuario puede usar el servicio considerando todos los campos de control';

-- ============================================
-- FUNCIÓN: Bloquear/Desbloquear Usuario
-- ============================================

CREATE OR REPLACE FUNCTION nutridiab.bloquear_usuario(
  p_usuario_id INTEGER,
  p_bloquear BOOLEAN DEFAULT TRUE,
  p_razon TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  rows_affected INTEGER;
BEGIN
  UPDATE nutridiab.usuarios
  SET 
    "Bloqueado" = p_bloquear,
    updated_at = NOW()
  WHERE "usuario ID" = p_usuario_id;
  
  GET DIAGNOSTICS rows_affected = ROW_COUNT;
  
  -- TODO: Aquí podrías registrar en una tabla de log la razón del bloqueo
  
  RETURN rows_affected > 0;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION nutridiab.bloquear_usuario IS 
'Bloquea o desbloquea un usuario. p_bloquear=TRUE para bloquear, FALSE para desbloquear';

-- ============================================
-- FUNCIÓN: Activar/Desactivar Usuario
-- ============================================

CREATE OR REPLACE FUNCTION nutridiab.activar_usuario(
  p_usuario_id INTEGER,
  p_activo BOOLEAN DEFAULT TRUE
)
RETURNS BOOLEAN AS $$
DECLARE
  rows_affected INTEGER;
BEGIN
  UPDATE nutridiab.usuarios
  SET 
    "Activo" = p_activo,
    updated_at = NOW()
  WHERE "usuario ID" = p_usuario_id;
  
  GET DIAGNOSTICS rows_affected = ROW_COUNT;
  RETURN rows_affected > 0;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION nutridiab.activar_usuario IS 
'Activa o desactiva un usuario. p_activo=TRUE para activar, FALSE para desactivar';

-- ============================================
-- VERIFICACIÓN DE INTEGRIDAD
-- ============================================

DO $$
DECLARE
  campo_existe BOOLEAN;
BEGIN
  -- Verificar que todos los campos existen
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'nutridiab' 
      AND table_name = 'usuarios' 
      AND column_name = 'Activo'
  ) INTO campo_existe;
  
  IF NOT campo_existe THEN
    RAISE EXCEPTION 'Campo Activo no fue creado';
  END IF;
  
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'nutridiab' 
      AND table_name = 'usuarios' 
      AND column_name = 'Bloqueado'
  ) INTO campo_existe;
  
  IF NOT campo_existe THEN
    RAISE EXCEPTION 'Campo Bloqueado no fue creado';
  END IF;
  
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'nutridiab' 
      AND table_name = 'usuarios' 
      AND column_name = 'Tipo ID'
  ) INTO campo_existe;
  
  IF NOT campo_existe THEN
    RAISE EXCEPTION 'Campo Tipo ID no fue creado';
  END IF;
  
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'nutridiab' 
      AND table_name = 'usuarios' 
      AND column_name = 'Lenguaje'
  ) INTO campo_existe;
  
  IF NOT campo_existe THEN
    RAISE EXCEPTION 'Campo Lenguaje no fue creado';
  END IF;
  
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'nutridiab' 
      AND table_name = 'usuarios' 
      AND column_name = 'invitado'
  ) INTO campo_existe;
  
  IF NOT campo_existe THEN
    RAISE EXCEPTION 'Campo invitado no fue creado';
  END IF;
  
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'nutridiab' 
      AND table_name = 'usuarios' 
      AND column_name = 'ultpago'
  ) INTO campo_existe;
  
  IF NOT campo_existe THEN
    RAISE EXCEPTION 'Campo ultpago no fue creado';
  END IF;
  
  RAISE NOTICE '✅ Migración completada exitosamente';
  RAISE NOTICE '✅ Todos los campos fueron agregados correctamente';
  RAISE NOTICE '✅ Índices creados';
  RAISE NOTICE '✅ Vista actualizada';
  RAISE NOTICE '✅ Funciones de control creadas';
END $$;

-- ============================================
-- MOSTRAR ESTRUCTURA ACTUALIZADA
-- ============================================

SELECT 
  column_name AS "Campo",
  data_type AS "Tipo",
  column_default AS "Default",
  is_nullable AS "Nullable"
FROM information_schema.columns
WHERE table_schema = 'nutridiab' 
  AND table_name = 'usuarios'
  AND column_name IN ('Activo', 'Bloqueado', 'Tipo ID', 'Lenguaje', 'invitado', 'ultpago')
ORDER BY ordinal_position;

-- ============================================
-- FIN DE LA MIGRACIÓN
-- ============================================

