-- ============================================
-- CREAR USUARIOS DE PRUEBA
-- ============================================
-- Ejecutar: psql -U dnzapata -d nutridiab -f database/crear_usuarios_prueba.sql

-- Limpiar usuarios de prueba existentes (opcional)
-- DELETE FROM nutridiab.usuarios WHERE email LIKE '%example.com' OR email LIKE '%prueba.com';

-- Usuario de prueba 1: Juan Pérez
INSERT INTO nutridiab.usuarios (
  "remoteJid",
  nombre,
  apellido,
  email,
  edad,
  peso,
  altura,
  objetivos,
  restricciones,
  tipo_diabetes,
  "Activo",
  email_verificado,
  datos_completos,
  "AceptoTerminos",
  rol
) VALUES (
  '5491123456789@s.whatsapp.net',
  'Juan',
  'Pérez',
  'juan@example.com',
  35,
  75.5,
  175,
  'Controlar el nivel de glucosa y mantener un peso saludable',
  'Sin restricciones especiales',
  'tipo2',
  true,
  true,
  true,
  true,
  'usuario'
) ON CONFLICT ("remoteJid") DO NOTHING;

-- Usuario de prueba 2: María González
INSERT INTO nutridiab.usuarios (
  "remoteJid",
  nombre,
  apellido,
  email,
  edad,
  peso,
  altura,
  objetivos,
  restricciones,
  tipo_diabetes,
  "Activo",
  email_verificado,
  datos_completos,
  "AceptoTerminos",
  rol
) VALUES (
  '5491123456790@s.whatsapp.net',
  'María',
  'González',
  'maria@example.com',
  28,
  62.0,
  165,
  'Mantener estable el nivel de azúcar y llevar una dieta balanceada',
  'Alérgica a frutos secos',
  'tipo1',
  true,
  true,
  true,
  true,
  'usuario'
) ON CONFLICT ("remoteJid") DO NOTHING;

-- Usuario de prueba 3: Carlos Rodríguez
INSERT INTO nutridiab.usuarios (
  "remoteJid",
  nombre,
  apellido,
  email,
  edad,
  peso,
  altura,
  objetivos,
  restricciones,
  tipo_diabetes,
  "Activo",
  email_verificado,
  datos_completos,
  "AceptoTerminos",
  rol
) VALUES (
  '5491123456791@s.whatsapp.net',
  'Carlos',
  'Rodríguez',
  'carlos@example.com',
  42,
  88.0,
  180,
  'Perder peso y controlar diabetes',
  'Vegetariano',
  'tipo2',
  true,
  true,
  true,
  true,
  'usuario'
) ON CONFLICT ("remoteJid") DO NOTHING;

-- Usuario de prueba 4: Ana Martínez
INSERT INTO nutridiab.usuarios (
  "remoteJid",
  nombre,
  apellido,
  email,
  edad,
  peso,
  altura,
  objetivos,
  restricciones,
  tipo_diabetes,
  "Activo",
  email_verificado,
  datos_completos,
  "AceptoTerminos",
  rol
) VALUES (
  '5491123456792@s.whatsapp.net',
  'Ana',
  'Martínez',
  'ana@example.com',
  31,
  58.5,
  160,
  'Mantener peso ideal y controlar glucosa',
  'Intolerancia a la lactosa',
  'gestacional',
  true,
  true,
  true,
  true,
  'usuario'
) ON CONFLICT ("remoteJid") DO NOTHING;

-- Usuario de prueba 5: Luis Fernández
INSERT INTO nutridiab.usuarios (
  "remoteJid",
  nombre,
  apellido,
  email,
  edad,
  peso,
  altura,
  objetivos,
  restricciones,
  tipo_diabetes,
  "Activo",
  email_verificado,
  datos_completos,
  "AceptoTerminos",
  rol
) VALUES (
  '5491123456793@s.whatsapp.net',
  'Luis',
  'Fernández',
  'luis@example.com',
  55,
  92.0,
  178,
  'Reducir peso y mejorar control glucémico',
  'Sin gluten',
  'tipo2',
  true,
  true,
  true,
  true,
  'usuario'
) ON CONFLICT ("remoteJid") DO NOTHING;

-- Usuario INACTIVO de prueba 6: Pedro López
INSERT INTO nutridiab.usuarios (
  "remoteJid",
  nombre,
  apellido,
  email,
  edad,
  peso,
  altura,
  tipo_diabetes,
  "Activo",
  email_verificado,
  datos_completos,
  "AceptoTerminos",
  rol
) VALUES (
  '5491123456794@s.whatsapp.net',
  'Pedro',
  'López',
  'pedro@prueba.com',
  40,
  80.0,
  175,
  'tipo2',
  false,  -- INACTIVO
  false,  -- NO VERIFICADO
  true,
  true,
  'usuario'
) ON CONFLICT ("remoteJid") DO NOTHING;

-- Usuario ADMIN de prueba
INSERT INTO nutridiab.usuarios (
  "remoteJid",
  nombre,
  apellido,
  email,
  edad,
  tipo_diabetes,
  "Activo",
  email_verificado,
  datos_completos,
  "AceptoTerminos",
  rol
) VALUES (
  'admin@system',
  'Admin',
  'Sistema',
  'admin@nutridiab.com',
  30,
  'tipo2',
  true,
  true,
  true,
  true,
  'administrador'
) ON CONFLICT ("remoteJid") DO NOTHING;

-- Agregar algunas consultas de ejemplo para los usuarios
INSERT INTO nutridiab."Consultas" (tipo, "usuario ID", resultado, "Costo")
SELECT 
  'texto',
  u."usuario ID",
  'Pizza con queso (2 porciones): 45g de carbohidratos. Recomendación: Controla las porciones.',
  0.002
FROM nutridiab.usuarios u
WHERE u.nombre = 'Juan' AND u.apellido = 'Pérez'
LIMIT 1;

INSERT INTO nutridiab."Consultas" (tipo, "usuario ID", resultado, "Costo")
SELECT 
  'imagen',
  u."usuario ID",
  'Ensalada verde con pollo: 15g de carbohidratos. Excelente opción baja en carbohidratos.',
  0.003
FROM nutridiab.usuarios u
WHERE u.nombre = 'María' AND u.apellido = 'González'
LIMIT 1;

INSERT INTO nutridiab."Consultas" (tipo, "usuario ID", resultado, "Costo")
SELECT 
  'audio',
  u."usuario ID",
  'Arroz integral con verduras (1 taza): 38g de carbohidratos. Buena opción con fibra.',
  0.0025
FROM nutridiab.usuarios u
WHERE u.nombre = 'Carlos' AND u.apellido = 'Rodríguez'
LIMIT 1;

-- Verificar que se crearon los usuarios
SELECT 
  "usuario ID",
  nombre,
  apellido,
  email,
  rol,
  "Activo",
  email_verificado
FROM nutridiab.usuarios
WHERE email LIKE '%example.com' OR email LIKE '%prueba.com' OR email LIKE '%nutridiab.com'
ORDER BY "usuario ID";

-- Mostrar resumen
SELECT 
  COUNT(*) as total_usuarios_prueba
FROM nutridiab.usuarios
WHERE email LIKE '%example.com' OR email LIKE '%prueba.com' OR email LIKE '%nutridiab.com';

\echo '✅ Usuarios de prueba creados exitosamente'
\echo '📊 Puedes verificarlos en el frontend en: /users'

