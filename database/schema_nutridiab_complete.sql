-- ============================================
-- ESQUEMA COMPLETO NUTRIDIAB CON VERIFICACIÓN
-- ============================================

-- Crear schema
CREATE SCHEMA IF NOT EXISTS nutridiab;

-- ============================================
-- TABLA: usuarios (ACTUALIZADA)
-- ============================================
CREATE TABLE IF NOT EXISTS nutridiab.usuarios (
  "usuario ID" SERIAL PRIMARY KEY,
  "remoteJid" VARCHAR(255) UNIQUE NOT NULL,
  
  -- Datos básicos
  "nombre" VARCHAR(255),
  "apellido" VARCHAR(255),
  "email" VARCHAR(255),
  "telefono" VARCHAR(50),
  "fecha_nacimiento" DATE,
  "Tipo ID" VARCHAR(50), -- DNI, Pasaporte, etc.
  
  -- Datos médicos
  "tipo_diabetes" VARCHAR(50), -- 'tipo1', 'tipo2', 'gestacional', 'otro'
  "anios_diagnostico" INTEGER,
  "usa_insulina" BOOLEAN DEFAULT FALSE,
  "medicamentos" TEXT,
  
  -- Verificación
  "AceptoTerminos" BOOLEAN DEFAULT FALSE,
  "msgaceptacion" TEXT,
  "aceptadoel" TIMESTAMP WITH TIME ZONE,
  "datos_completos" BOOLEAN DEFAULT FALSE,
  "email_verificado" BOOLEAN DEFAULT FALSE,
  "token_verificacion" VARCHAR(255),
  "token_expira" TIMESTAMP WITH TIME ZONE,
  
  -- Estado y control
  "Activo" BOOLEAN DEFAULT TRUE,
  "Bloqueado" BOOLEAN DEFAULT FALSE,
  "invitado" BOOLEAN DEFAULT FALSE,
  "Lenguaje" VARCHAR(10) DEFAULT 'es', -- 'es', 'en', 'pt', etc.
  
  -- Pagos y suscripción
  "ultpago" DATE,
  
  -- Metadata
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "ultimo_acceso" TIMESTAMP WITH TIME ZONE
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_usuarios_remotejid ON nutridiab.usuarios("remoteJid");
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON nutridiab.usuarios("email");
CREATE INDEX IF NOT EXISTS idx_usuarios_token ON nutridiab.usuarios("token_verificacion");
CREATE INDEX IF NOT EXISTS idx_usuarios_activo ON nutridiab.usuarios("Activo");
CREATE INDEX IF NOT EXISTS idx_usuarios_bloqueado ON nutridiab.usuarios("Bloqueado");

-- Comentarios en tabla
COMMENT ON TABLE nutridiab.usuarios IS 'Tabla principal de usuarios con verificación y control de acceso';
COMMENT ON COLUMN nutridiab.usuarios."Activo" IS 'Usuario activo en el sistema (puede ser desactivado temporalmente)';
COMMENT ON COLUMN nutridiab.usuarios."Bloqueado" IS 'Usuario bloqueado permanentemente (por incumplimiento o pago)';
COMMENT ON COLUMN nutridiab.usuarios."invitado" IS 'Usuario en modo prueba/invitado con funcionalidad limitada';
COMMENT ON COLUMN nutridiab.usuarios."Lenguaje" IS 'Idioma preferido del usuario (es, en, pt, etc.)';
COMMENT ON COLUMN nutridiab.usuarios."ultpago" IS 'Fecha del último pago/suscripción del usuario';
COMMENT ON COLUMN nutridiab.usuarios."datos_completos" IS 'Indica si el usuario completó todos sus datos personales';

-- ============================================
-- TABLA: Consultas (sin cambios)
-- ============================================
CREATE TABLE IF NOT EXISTS nutridiab."Consultas" (
  "id" SERIAL PRIMARY KEY,
  "tipo" VARCHAR(20) NOT NULL,
  "usuario ID" INTEGER REFERENCES nutridiab.usuarios("usuario ID"),
  "resultado" TEXT NOT NULL,
  "Costo" NUMERIC(10, 6),
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_consultas_usuario ON nutridiab."Consultas"("usuario ID");
CREATE INDEX IF NOT EXISTS idx_consultas_fecha ON nutridiab."Consultas"("created_at");
CREATE INDEX IF NOT EXISTS idx_consultas_tipo ON nutridiab."Consultas"("tipo");

-- ============================================
-- TABLA: mensajes (ACTUALIZADA)
-- ============================================
CREATE TABLE IF NOT EXISTS nutridiab.mensajes (
  "id" SERIAL PRIMARY KEY,
  "CODIGO" VARCHAR(50) UNIQUE NOT NULL,
  "Texto" TEXT NOT NULL,
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Mensajes existentes + nuevos
INSERT INTO nutridiab.mensajes ("CODIGO", "Texto") VALUES
('BIENVENIDA', '¡Hola! 👋 Soy Nutridiab, tu asistente nutricional especializado en diabetes. Estoy aquí para ayudarte a calcular los hidratos de carbono de tus alimentos. 🍽️'),
('SERVICIO', 'Puedo analizar:
📝 Texto: Descríbeme tu comida
📸 Imagen: Envíame una foto de tu plato
🎤 Audio: Cuéntame qué comiste'),
('TERMINOS', '⚠️ IMPORTANTE: Este servicio es solo informativo y no reemplaza la opinión de tu médico o nutricionista. Los cálculos son aproximaciones basadas en IA.

Para continuar, necesito que aceptes estos términos.'),
('ACEPTA', '¿Aceptas los términos y condiciones? Responde "Acepto" o "Sí" para continuar.'),
('RESPONDEACEPTA', '✅ ¡Perfecto! Ahora necesito que completes tus datos personales para brindarte un mejor servicio.'),
('RESPONDENO', '❌ Por favor, responde "Acepto" para poder usar el servicio. Los términos son necesarios para continuar.'),
('NOENTENDI', '🤔 No entendí tu mensaje. ¿Podrías describirme mejor qué alimento o comida consumiste?'),

-- NUEVOS MENSAJES PARA VERIFICACIÓN
('DATOS_INCOMPLETOS', '📋 Para usar el servicio, necesito que completes tu perfil con algunos datos personales.

Esto me ayudará a brindarte recomendaciones más precisas según tu tipo de diabetes y necesidades. 👨‍⚕️

Por favor, ingresa tus datos aquí: 
{{enlace}}

⏰ Este enlace es válido por 24 horas.'),

('EMAIL_NO_VERIFICADO', '📧 Necesitas verificar tu email antes de continuar.

Te envié un email de verificación a: {{email}}

Por favor revisa tu bandeja de entrada y haz click en el enlace de verificación.

¿No recibiste el email? Responde "reenviar" y te lo envío nuevamente.'),

('BIENVENIDA_VERIFICADO', '🎉 ¡Perfecto {{nombre}}! Tus datos están completos y verificados.

Ya puedes empezar a enviarme información sobre tus alimentos:
• Envía una foto de tu plato 📸
• Descríbeme lo que comiste 📝
• Graba un audio contándome 🎤

¡Estoy listo para ayudarte! 🍽️')

ON CONFLICT ("CODIGO") DO UPDATE SET
  "Texto" = EXCLUDED."Texto";

-- ============================================
-- TABLA: tokens_acceso (NUEVA)
-- ============================================
CREATE TABLE IF NOT EXISTS nutridiab.tokens_acceso (
  "id" SERIAL PRIMARY KEY,
  "usuario ID" INTEGER REFERENCES nutridiab.usuarios("usuario ID"),
  "token" VARCHAR(255) UNIQUE NOT NULL,
  "tipo" VARCHAR(50) NOT NULL, -- 'registro', 'verificacion_email', 'reset_password'
  "usado" BOOLEAN DEFAULT FALSE,
  "expira" TIMESTAMP WITH TIME ZONE NOT NULL,
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "usado_en" TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_tokens_token ON nutridiab.tokens_acceso("token");
CREATE INDEX IF NOT EXISTS idx_tokens_usuario ON nutridiab.tokens_acceso("usuario ID");
CREATE INDEX IF NOT EXISTS idx_tokens_expira ON nutridiab.tokens_acceso("expira");

-- ============================================
-- FUNCIÓN: Generar token único
-- ============================================
CREATE OR REPLACE FUNCTION nutridiab.generar_token()
RETURNS VARCHAR(255) AS $$
DECLARE
  token VARCHAR(255);
  existe BOOLEAN;
BEGIN
  LOOP
    -- Genera un token aleatorio de 64 caracteres
    token := encode(gen_random_bytes(32), 'hex');
    
    -- Verifica si ya existe
    SELECT EXISTS(SELECT 1 FROM nutridiab.tokens_acceso WHERE token = token) INTO existe;
    
    -- Si no existe, retorna
    IF NOT existe THEN
      RETURN token;
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCIÓN: Validar token
-- ============================================
CREATE OR REPLACE FUNCTION nutridiab.validar_token(p_token VARCHAR(255))
RETURNS TABLE(
  valido BOOLEAN,
  usuario_id INTEGER,
  tipo VARCHAR(50),
  expiro BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    NOT ta.usado AND ta.expira > NOW() AS valido,
    ta."usuario ID" AS usuario_id,
    ta.tipo,
    ta.expira < NOW() AS expiro
  FROM nutridiab.tokens_acceso ta
  WHERE ta.token = p_token
  LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCIÓN: Marcar token como usado
-- ============================================
CREATE OR REPLACE FUNCTION nutridiab.usar_token(p_token VARCHAR(255))
RETURNS BOOLEAN AS $$
DECLARE
  rows_affected INTEGER;
BEGIN
  UPDATE nutridiab.tokens_acceso
  SET usado = TRUE, usado_en = NOW()
  WHERE token = p_token 
    AND usado = FALSE 
    AND expira > NOW();
  
  GET DIAGNOSTICS rows_affected = ROW_COUNT;
  RETURN rows_affected > 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCIÓN: Verificar datos completos
-- ============================================
CREATE OR REPLACE FUNCTION nutridiab.verificar_datos_usuario(p_usuario_id INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
  datos_ok BOOLEAN;
BEGIN
  SELECT 
    nombre IS NOT NULL AND nombre != '' AND
    apellido IS NOT NULL AND apellido != '' AND
    email IS NOT NULL AND email != '' AND
    tipo_diabetes IS NOT NULL
  INTO datos_ok
  FROM nutridiab.usuarios
  WHERE "usuario ID" = p_usuario_id;
  
  -- Actualizar campo datos_completos
  UPDATE nutridiab.usuarios
  SET datos_completos = datos_ok
  WHERE "usuario ID" = p_usuario_id;
  
  RETURN COALESCE(datos_ok, FALSE);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGER: Actualizar updated_at
-- ============================================
CREATE OR REPLACE FUNCTION nutridiab.actualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER usuarios_updated_at
  BEFORE UPDATE ON nutridiab.usuarios
  FOR EACH ROW
  EXECUTE FUNCTION nutridiab.actualizar_timestamp();

-- ============================================
-- FUNCIÓN: Limpiar tokens expirados
-- ============================================
CREATE OR REPLACE FUNCTION nutridiab.limpiar_tokens_expirados()
RETURNS INTEGER AS $$
DECLARE
  rows_deleted INTEGER;
BEGIN
  DELETE FROM nutridiab.tokens_acceso
  WHERE expira < NOW() - INTERVAL '7 days';
  
  GET DIAGNOSTICS rows_deleted = ROW_COUNT;
  RETURN rows_deleted;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCIÓN: Puede usar el servicio
-- ============================================
CREATE OR REPLACE FUNCTION nutridiab.puede_usar_servicio(p_usuario_id INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
  puede BOOLEAN;
BEGIN
  SELECT 
    "Activo" = TRUE AND 
    "Bloqueado" = FALSE AND
    "AceptoTerminos" = TRUE AND
    datos_completos = TRUE
  INTO puede
  FROM nutridiab.usuarios
  WHERE "usuario ID" = p_usuario_id;
  
  RETURN COALESCE(puede, FALSE);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCIÓN: Bloquear usuario
-- ============================================
CREATE OR REPLACE FUNCTION nutridiab.bloquear_usuario(p_usuario_id INTEGER, p_motivo TEXT DEFAULT NULL)
RETURNS BOOLEAN AS $$
DECLARE
  rows_affected INTEGER;
BEGIN
  UPDATE nutridiab.usuarios
  SET 
    "Bloqueado" = TRUE,
    "Activo" = FALSE,
    updated_at = NOW()
  WHERE "usuario ID" = p_usuario_id;
  
  GET DIAGNOSTICS rows_affected = ROW_COUNT;
  
  -- Opcional: Registrar motivo en una tabla de logs (por implementar)
  -- INSERT INTO nutridiab.logs_bloqueos ("usuario ID", motivo, fecha) VALUES (p_usuario_id, p_motivo, NOW());
  
  RETURN rows_affected > 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCIÓN: Activar usuario
-- ============================================
CREATE OR REPLACE FUNCTION nutridiab.activar_usuario(p_usuario_id INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
  rows_affected INTEGER;
BEGIN
  UPDATE nutridiab.usuarios
  SET 
    "Activo" = TRUE,
    "Bloqueado" = FALSE,
    updated_at = NOW()
  WHERE "usuario ID" = p_usuario_id;
  
  GET DIAGNOSTICS rows_affected = ROW_COUNT;
  RETURN rows_affected > 0;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- VISTA: Usuarios con estado de verificación
-- ============================================
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
  u."invitado",
  u."Lenguaje",
  u."ultpago",
  u.created_at,
  u.ultimo_acceso,
  CASE 
    WHEN u."Bloqueado" THEN 'bloqueado'
    WHEN NOT u."Activo" THEN 'inactivo'
    WHEN NOT u."AceptoTerminos" THEN 'pendiente_terminos'
    WHEN NOT u.datos_completos THEN 'pendiente_datos'
    WHEN NOT u.email_verificado THEN 'pendiente_email'
    ELSE 'activo'
  END AS estado,
  COUNT(c.id) AS total_consultas,
  MAX(c.created_at) AS ultima_consulta,
  COALESCE(SUM(c."Costo"), 0) AS costo_total
FROM nutridiab.usuarios u
LEFT JOIN nutridiab."Consultas" c ON u."usuario ID" = c."usuario ID"
GROUP BY u."usuario ID";

-- ============================================
-- DATOS DE EJEMPLO (OPCIONAL - COMENTAR EN PRODUCCIÓN)
-- ============================================
-- INSERT INTO nutridiab.usuarios ("remoteJid", nombre, apellido, email, tipo_diabetes, "AceptoTerminos", datos_completos, email_verificado)
-- VALUES ('5491155555555@s.whatsapp.net', 'Juan', 'Pérez', 'juan@example.com', 'tipo2', TRUE, TRUE, TRUE);

-- ============================================
-- PERMISOS COMPLETOS PARA POSTGRES Y CONEXIONES EXTERNAS
-- ============================================
-- Estos permisos son CRÍTICOS para que n8n pueda conectarse

-- 1. Permisos sobre el schema
GRANT USAGE ON SCHEMA nutridiab TO postgres;
GRANT ALL PRIVILEGES ON SCHEMA nutridiab TO postgres;

-- 2. Permisos sobre todas las tablas
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA nutridiab TO postgres;

-- 3. Permisos sobre secuencias (para IDs autoincrementales)
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA nutridiab TO postgres;

-- 4. Permisos sobre funciones
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA nutridiab TO postgres;

-- 5. Cambiar owner de todas las tablas a postgres (MUY IMPORTANTE)
ALTER TABLE nutridiab.usuarios OWNER TO postgres;
ALTER TABLE nutridiab."Consultas" OWNER TO postgres;
ALTER TABLE nutridiab.mensajes OWNER TO postgres;
ALTER TABLE nutridiab.tokens_acceso OWNER TO postgres;

-- 6. Cambiar owner de secuencias
ALTER SEQUENCE nutridiab.usuarios_usuario\ ID_seq OWNER TO postgres;
ALTER SEQUENCE nutridiab."Consultas_id_seq" OWNER TO postgres;
ALTER SEQUENCE nutridiab.mensajes_id_seq OWNER TO postgres;
ALTER SEQUENCE nutridiab.tokens_acceso_id_seq OWNER TO postgres;

-- 7. Permisos por defecto para objetos futuros
ALTER DEFAULT PRIVILEGES IN SCHEMA nutridiab GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA nutridiab GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA nutridiab GRANT ALL ON FUNCTIONS TO postgres;

-- 8. CRÍTICO: Desactivar RLS (Row Level Security) para conexiones externas
ALTER TABLE nutridiab.usuarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE nutridiab."Consultas" DISABLE ROW LEVEL SECURITY;
ALTER TABLE nutridiab.mensajes DISABLE ROW LEVEL SECURITY;
ALTER TABLE nutridiab.tokens_acceso DISABLE ROW LEVEL SECURITY;

-- 9. Si usas un usuario específico para aplicaciones (recomendado)
-- Descomenta y reemplaza 'app_user' con tu usuario:
/*
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_user') THEN
    GRANT USAGE ON SCHEMA nutridiab TO app_user;
    GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA nutridiab TO app_user;
    GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA nutridiab TO app_user;
    GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA nutridiab TO app_user;
    
    ALTER DEFAULT PRIVILEGES IN SCHEMA nutridiab GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;
    ALTER DEFAULT PRIVILEGES IN SCHEMA nutridiab GRANT USAGE, SELECT ON SEQUENCES TO app_user;
  END IF;
END $$;
*/

-- ============================================
-- VERIFICACIÓN DE INTEGRIDAD
-- ============================================
DO $$
BEGIN
  -- Verificar tablas
  ASSERT (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'nutridiab' AND table_name = 'usuarios') = 1,
    'ERROR: Tabla usuarios no creada';
  ASSERT (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'nutridiab' AND table_name = 'Consultas') = 1,
    'ERROR: Tabla Consultas no creada';
  ASSERT (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'nutridiab' AND table_name = 'tokens_acceso') = 1,
    'ERROR: Tabla tokens_acceso no creada';
  ASSERT (SELECT COUNT(*) FROM nutridiab.mensajes) >= 10,
    'ERROR: Mensajes no insertados correctamente';
  
  -- Verificar permisos
  ASSERT (SELECT has_schema_privilege('postgres', 'nutridiab', 'USAGE')),
    'ERROR: postgres no tiene permisos sobre schema nutridiab';
  ASSERT (SELECT has_table_privilege('postgres', 'nutridiab.usuarios', 'SELECT')),
    'ERROR: postgres no puede hacer SELECT en usuarios';
  
  RAISE NOTICE '✅ Schema nutridiab creado correctamente';
  RAISE NOTICE '✅ Tablas: usuarios, Consultas, mensajes, tokens_acceso';
  RAISE NOTICE '✅ Funciones: generar_token, validar_token, usar_token, verificar_datos_usuario, puede_usar_servicio, bloquear_usuario, activar_usuario';
  RAISE NOTICE '✅ Vista: vista_usuarios_estado';
  RAISE NOTICE '✅ Permisos configurados para postgres';
  RAISE NOTICE '';
  RAISE NOTICE '📝 SIGUIENTE PASO: Verifica la conexión desde n8n o tu aplicación';
END $$;

-- ============================================
-- VERIFICACIÓN DE PERMISOS (Para debugging)
-- ============================================
-- Ejecuta esto para verificar permisos en todas las tablas:
/*
SELECT 
    schemaname,
    tablename,
    tableowner,
    has_table_privilege('postgres', schemaname||'.'||tablename, 'SELECT') as puede_select,
    has_table_privilege('postgres', schemaname||'.'||tablename, 'INSERT') as puede_insert,
    has_table_privilege('postgres', schemaname||'.'||tablename, 'UPDATE') as puede_update,
    has_table_privilege('postgres', schemaname||'.'||tablename, 'DELETE') as puede_delete
FROM pg_tables
WHERE schemaname = 'nutridiab'
ORDER BY tablename;

-- Todas las columnas deben mostrar 'true' ✅
*/

