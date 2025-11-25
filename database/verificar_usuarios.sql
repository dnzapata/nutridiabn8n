-- ============================================
-- SCRIPT PARA VERIFICAR USUARIOS EN LA BASE DE DATOS
-- ============================================

-- 1. Contar total de usuarios
SELECT COUNT(*) as total_usuarios FROM nutridiab.usuarios;

-- 2. Ver primeros 5 usuarios con todos los campos
SELECT 
  "usuario ID",
  nombre,
  apellido,
  email,
  "remoteJid",
  "AceptoTerminos",
  datos_completos,
  email_verificado,
  "Activo",
  "Bloqueado",
  tipo_diabetes,
  created_at
FROM nutridiab.usuarios
LIMIT 5;

-- 3. Ver usuarios con formato simplificado
SELECT 
  "usuario ID" as id,
  nombre,
  apellido,
  email,
  "remoteJid" as telefono,
  CASE 
    WHEN "Activo" = true THEN 'active'
    ELSE 'inactive'
  END as status,
  email_verificado as verified,
  'user' as role,
  created_at,
  updated_at
FROM nutridiab.usuarios
ORDER BY created_at DESC
LIMIT 10;

