-- Verificar que el campo aceptadoel existe y tiene datos
-- Ejecutar en Supabase SQL Editor

SELECT 
  "usuario ID",
  nombre,
  apellido,
  "AceptoTerminos",
  aceptadoel,
  msgaceptacion
FROM nutridiab.usuarios
WHERE "AceptoTerminos" = TRUE
LIMIT 5;

