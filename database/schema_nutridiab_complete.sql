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
  
  -- Metadata
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  "ultimo_acceso" TIMESTAMP WITH TIME ZONE
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_usuarios_remotejid ON nutridiab.usuarios("remoteJid");
CREATE INDEX IF NOT EXISTS idx_usuarios_email ON nutridiab.usuarios("email");
CREATE INDEX IF NOT EXISTS idx_usuarios_token ON nutridiab.usuarios("token_verificacion");

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
('BIENVENIDA', '¡Hola! 👋 Soy NutriDiab, tu asistente nutricional especializado en diabetes. Estoy aquí para ayudarte a calcular los hidratos de carbono de tus alimentos. 🍽️'),
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
  u.created_at,
  u.ultimo_acceso,
  CASE 
    WHEN NOT u."AceptoTerminos" THEN 'pendiente_terminos'
    WHEN NOT u.datos_completos THEN 'pendiente_datos'
    WHEN NOT u.email_verificado THEN 'pendiente_email'
    ELSE 'activo'
  END AS estado,
  COUNT(c.id) AS total_consultas,
  MAX(c.created_at) AS ultima_consulta
FROM nutridiab.usuarios u
LEFT JOIN nutridiab."Consultas" c ON u."usuario ID" = c."usuario ID"
GROUP BY u."usuario ID";

-- ============================================
-- DATOS DE EJEMPLO (OPCIONAL - COMENTAR EN PRODUCCIÓN)
-- ============================================
-- INSERT INTO nutridiab.usuarios ("remoteJid", nombre, apellido, email, tipo_diabetes, "AceptoTerminos", datos_completos, email_verificado)
-- VALUES ('5491155555555@s.whatsapp.net', 'Juan', 'Pérez', 'juan@example.com', 'tipo2', TRUE, TRUE, TRUE);

-- ============================================
-- VERIFICACIÓN DE INTEGRIDAD
-- ============================================
-- Verificar que todas las tablas existen
DO $$
BEGIN
  ASSERT (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'nutridiab' AND table_name = 'usuarios') = 1,
    'Tabla usuarios no creada';
  ASSERT (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'nutridiab' AND table_name = 'Consultas') = 1,
    'Tabla Consultas no creada';
  ASSERT (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'nutridiab' AND table_name = 'tokens_acceso') = 1,
    'Tabla tokens_acceso no creada';
  ASSERT (SELECT COUNT(*) FROM nutridiab.mensajes) >= 10,
    'Mensajes no insertados correctamente';
  
  RAISE NOTICE 'Schema nutridiab creado correctamente ✅';
END $$;

