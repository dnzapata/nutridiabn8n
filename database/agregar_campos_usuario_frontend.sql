-- ============================================
-- AGREGAR CAMPOS ADICIONALES PARA EL FRONTEND
-- ============================================

-- Agregar campos si no existen
ALTER TABLE nutridiab.usuarios 
  ADD COLUMN IF NOT EXISTS edad INTEGER,
  ADD COLUMN IF NOT EXISTS peso DECIMAL(5,2),
  ADD COLUMN IF NOT EXISTS altura DECIMAL(5,2),
  ADD COLUMN IF NOT EXISTS objetivos TEXT,
  ADD COLUMN IF NOT EXISTS restricciones TEXT;

-- Comentarios
COMMENT ON COLUMN nutridiab.usuarios.edad IS 'Edad del usuario en años';
COMMENT ON COLUMN nutridiab.usuarios.peso IS 'Peso del usuario en kilogramos';
COMMENT ON COLUMN nutridiab.usuarios.altura IS 'Altura del usuario en centímetros';
COMMENT ON COLUMN nutridiab.usuarios.objetivos IS 'Objetivos nutricionales del usuario';
COMMENT ON COLUMN nutridiab.usuarios.restricciones IS 'Restricciones alimentarias o alergias del usuario';

-- Verificar que los campos fueron agregados
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_schema = 'nutridiab' 
  AND table_name = 'usuarios'
  AND column_name IN ('edad', 'peso', 'altura', 'objetivos', 'restricciones')
ORDER BY column_name;

