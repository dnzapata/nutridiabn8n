# 🔐 Flujo de Verificación de Usuario - NutriDiab

## 📋 Descripción

Este documento explica el flujo completo de verificación de datos del usuario antes de permitirle usar NutriDiab.

---

## 🎯 Objetivo

Asegurar que cada usuario tenga:
1. ✅ Datos personales completos (nombre, apellido, email)
2. ✅ Datos médicos básicos (tipo de diabetes)
3. ✅ Email verificado

---

## 🔄 Flujo Completo

```
Usuario envía mensaje por WhatsApp
          ↓
  ┌───────────────────┐
  │ 1. Usuario existe?│
  └───────┬───────────┘
          │
    NO ────┤──── SÍ
    ↓               ↓
Registro      ┌─────────────────────┐
nuevo         │ 2. Aceptó términos? │
              └──────┬──────────────┘
                     │
               NO ────┤──── SÍ
               ↓               ↓
      Enviar términos    ┌──────────────────────┐
                        │ 3. Datos completos?  │
                        └───────┬──────────────┘
                                │
                          NO ────┤──── SÍ
                          ↓               ↓
                  Generar Token      ┌─────────────────┐
                  Enviar enlace      │ 4. Email verif? │
                        ↓            └────┬────────────┘
        https://app.com/registro          │
           ?token=abc123          NO ──────┤──── SÍ
                                  ↓               ↓
                          Solicitar verif.  ┌──────────┐
                                           │ 5. LISTO │
                                           │ Procesar │
                                           └──────────┘
```

---

## 📊 Cambios en la Base de Datos

### Tabla `usuarios` Actualizada

Nuevos campos agregados:

```sql
-- Datos personales
nombre VARCHAR(255)
apellido VARCHAR(255)
email VARCHAR(255)
telefono VARCHAR(50)
fecha_nacimiento DATE

-- Datos médicos
tipo_diabetes VARCHAR(50)
anios_diagnostico INTEGER
usa_insulina BOOLEAN
medicamentos TEXT

-- Verificación
datos_completos BOOLEAN
email_verificado BOOLEAN
token_verificacion VARCHAR(255)
token_expira TIMESTAMP
```

### Nueva Tabla `tokens_acceso`

```sql
CREATE TABLE nutridiab.tokens_acceso (
  id SERIAL PRIMARY KEY,
  usuario_id INTEGER REFERENCES usuarios,
  token VARCHAR(255) UNIQUE,
  tipo VARCHAR(50),  -- 'registro', 'verificacion_email'
  usado BOOLEAN DEFAULT FALSE,
  expira TIMESTAMP,
  created_at TIMESTAMP,
  usado_en TIMESTAMP
);
```

---

## 🔧 Workflows de n8n Necesarios

### 1. Workflow Principal (Modificado)

**Archivo**: `nutridiab.json`

**Nuevos Nodos a Agregar**:

#### Nodo: "Verificar Estado Usuario"

**Posición**: Después de "Get a row" y antes del Switch

**Tipo**: Code Node

```javascript
// Verificar estado del usuario
const usuario = $('Get a row').first().json;

if (!usuario || !usuario['usuario ID']) {
  return {
    estado: 'nuevo',
    proceder: false
  };
}

// Usuario existe - verificar datos
const datosCompletos = usuario.datos_completos || false;
const emailVerificado = usuario.email_verificado || false;
const aceptoTerminos = usuario.AceptoTerminos || false;

let estado, mensaje;

if (!aceptoTerminos) {
  estado = 'pendiente_terminos';
  mensaje = 'TERMINOS';
} else if (!datosCompletos) {
  estado = 'pendiente_datos';
  mensaje = 'DATOS_INCOMPLETOS';
} else if (!emailVerificado) {
  estado = 'pendiente_email';
  mensaje = 'EMAIL_NO_VERIFICADO';
} else {
  estado = 'activo';
  mensaje = null;
}

return {
  estado,
  mensaje,
  proceder: estado === 'activo',
  usuario_id: usuario['usuario ID'],
  nombre: usuario.nombre,
  email: usuario.email
};
```

#### Nodo: "IF Usuario Verificado"

**Tipo**: IF Node

**Condición**: `{{ $json.proceder }} equals true`

**Salidas**:
- **true**: Continuar al Switch (procesar mensaje)
- **false**: Ir a "Manejar Usuario No Verificado"

#### Nodo: "Manejar Usuario No Verificado"

**Tipo**: Switch Node

**Cases**:
1. `pendiente_terminos` → Flujo existente de términos
2. `pendiente_datos` → Generar Token y Enviar Enlace
3. `pendiente_email` → Enviar Recordatorio Email

---

### 2. Nuevo Workflow: "Generar Token Registro"

**Endpoint**: `POST /webhook/nutridiab/generate-token`

**Flujo**:

```
Webhook → Supabase (Generar Token) → Code (Construir URL) → Respond
```

**Nodo Supabase - Execute Query**:

```sql
-- Generar token
INSERT INTO nutridiab.tokens_acceso (
  "usuario ID", 
  token, 
  tipo, 
  expira
)
VALUES (
  {{ $json.body.usuario_id }},
  nutridiab.generar_token(),
  'registro',
  NOW() + INTERVAL '24 hours'
)
RETURNING token, expira;
```

**Nodo Code - Construir URL**:

```javascript
const token = $json[0].token;
const baseUrl = process.env.FRONTEND_URL || 'https://app.nutridiab.com';
const url = `${baseUrl}/registro?token=${token}`;

return {
  success: true,
  url,
  expira: $json[0].expira
};
```

---

### 3. Nuevo Workflow: "Validar Token"

**Endpoint**: `POST /webhook/nutridiab/validate-token`

**Flujo**:

```
Webhook → Supabase (Validar) → Code (Formatear) → Respond
```

**Nodo Supabase - Execute Query**:

```sql
SELECT * FROM nutridiab.validar_token({{ $json.body.token }});
```

**Response**:

```json
{
  "valid": true/false,
  "expired": true/false,
  "user": {
    "usuario ID": 123,
    "nombre": "...",
    "email": "..."
  }
}
```

---

### 4. Nuevo Workflow: "Completar Registro"

**Endpoint**: `POST /webhook/nutridiab/complete-registration`

**Flujo**:

```
Webhook → Validar Token → Update Usuario → Marcar Token Usado → Enviar Email → WhatsApp Confirmación → Respond
```

**Nodo Supabase - Update**:

```sql
UPDATE nutridiab.usuarios
SET 
  nombre = {{ $json.body.nombre }},
  apellido = {{ $json.body.apellido }},
  email = {{ $json.body.email }},
  telefono = {{ $json.body.telefono }},
  fecha_nacimiento = {{ $json.body.fecha_nacimiento }},
  tipo_diabetes = {{ $json.body.tipo_diabetes }},
  anios_diagnostico = {{ $json.body.anios_diagnostico }},
  usa_insulina = {{ $json.body.usa_insulina }},
  medicamentos = {{ $json.body.medicamentos }},
  datos_completos = TRUE,
  updated_at = NOW()
WHERE "usuario ID" = (
  SELECT "usuario ID" FROM nutridiab.tokens_acceso 
  WHERE token = {{ $json.body.token }} AND usado = FALSE
)
RETURNING *;
```

**Nodo WhatsApp Confirmación**:

Enviar mensaje:
```
¡Perfecto {{nombre}}! ✅

Tus datos están completos. Solo falta un último paso:

📧 Verifica tu email
Te enviamos un email de verificación a: {{email}}

Haz click en el enlace del email y podrás empezar a usar NutriDiab.

¿No recibiste el email? Responde "reenviar"
```

---

### 5. Nuevo Workflow: "Enviar Email Verificación"

**Endpoint**: `POST /webhook/nutridiab/send-verification-email`

**Flujo**:

```
Webhook → Generar Token Email → Send Email (SMTP/SendGrid) → Respond
```

**Template Email**:

```html
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: linear-gradient(135deg, #667eea, #764ba2); color: white; padding: 30px; text-align: center; border-radius: 8px 8px 0 0; }
    .content { background: white; padding: 30px; border: 1px solid #e0e0e0; }
    .button { display: inline-block; background: #4CAF50; color: white; padding: 15px 30px; text-decoration: none; border-radius: 8px; margin: 20px 0; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🩺 NutriDiab</h1>
      <p>Verifica tu email</p>
    </div>
    <div class="content">
      <h2>Hola {{nombre}},</h2>
      <p>Gracias por registrarte en NutriDiab.</p>
      <p>Para completar tu registro, por favor verifica tu email haciendo click en el siguiente botón:</p>
      <p style="text-align: center;">
        <a href="{{verification_link}}" class="button">Verificar Email</a>
      </p>
      <p>O copia este enlace en tu navegador:</p>
      <p style="word-break: break-all; color: #667eea;">{{verification_link}}</p>
      <p>Este enlace expira en 24 horas.</p>
      <hr>
      <p style="color: #999; font-size: 12px;">Si no solicitaste este email, puedes ignorarlo.</p>
    </div>
  </div>
</body>
</html>
```

---

### 6. Nuevo Workflow: "Verificar Email"

**Endpoint**: `GET /webhook/nutridiab/verify-email?token=...`

**Flujo**:

```
Webhook → Validar Token → Update Usuario → Marcar Token → WhatsApp Notif → Redirect
```

**Update**:

```sql
UPDATE nutridiab.usuarios
SET 
  email_verificado = TRUE,
  updated_at = NOW()
WHERE "usuario ID" = (
  SELECT "usuario ID" FROM nutridiab.tokens_acceso 
  WHERE token = {{ $query.token }} 
    AND tipo = 'verificacion_email'
    AND usado = FALSE
);
```

**WhatsApp Notificación**:

```
¡Excelente {{nombre}}! 🎉

Tu email ha sido verificado exitosamente.

Ya puedes empezar a usar NutriDiab. Envíame:
📸 Una foto de tu comida
📝 Una descripción de tu plato
🎤 Un audio contándome qué comiste

¡Estoy listo para ayudarte! 🍽️
```

---

## 📝 Mensajes Personalizados

### Mensaje: Datos Incompletos

```
Hola! 👋

Para brindarte el mejor servicio personalizado, necesito que completes algunos datos básicos.

Esto me ayudará a darte recomendaciones más precisas según tu tipo de diabetes. 💉

Por favor, completa tu perfil aquí:
{{enlace}}

⏰ Este enlace es válido por 24 horas.

¿Necesitas ayuda? Responde "ayuda" y te guiaré paso a paso.
```

### Mensaje: Email No Verificado

```
Casi listo! 📧

Te envié un email de verificación a:
{{email}}

Por favor revisa tu bandeja de entrada (y spam) y haz click en el enlace.

¿No recibiste el email?
Responde "reenviar" y te lo envío de nuevo.

¿Email incorrecto?
Responde "cambiar email" y lo actualizamos.
```

### Mensaje: Bienvenida Usuario Verificado

```
¡Bienvenido {{nombre}}! 🎉

Todo está listo. Ya puedes preguntarme sobre tus alimentos.

Envíame:
📸 Foto de tu plato
📝 Descripción: "Una manzana"
🎤 Audio contándome qué comiste

Te responderé con:
🍽️ Alimentos detectados
🔢 Hidratos de carbono
💬 Recomendaciones personalizadas

¡Empecemos! 🚀
```

---

## 🔐 Seguridad del Token

### Generación

```sql
-- Token aleatorio de 64 caracteres
encode(gen_random_bytes(32), 'hex')
```

### Validación

1. ✅ Token existe
2. ✅ No está usado
3. ✅ No está expirado (< 24 horas)
4. ✅ Tipo correcto

### Una Vez Usado

```sql
UPDATE tokens_acceso
SET usado = TRUE, usado_en = NOW()
WHERE token = '...';
```

---

## 🧪 Testing

### Test 1: Usuario Nuevo (Sin Datos)

```
Input: Usuario nuevo envía "Hola"

Expected:
1. Mensaje de bienvenida
2. Términos y condiciones
3. Usuario responde "Acepto"
4. Recibe enlace de registro
5. Completa formulario
6. Recibe email de verificación
7. Verifica email
8. ¡Listo para usar!
```

### Test 2: Usuario con Datos Incompletos

```
Input: Usuario sin email envía mensaje

Expected:
1. Recibe mensaje: "datos incompletos"
2. Recibe enlace
3. Completa datos faltantes
4. Verifica email
5. ¡Listo!
```

### Test 3: Token Expirado

```
Input: Usuario intenta usar enlace viejo

Expected:
1. "Enlace expirado"
2. "Solicita uno nuevo desde WhatsApp"
```

---

## 📊 Métricas a Monitorear

- Total de usuarios registrados
- % de usuarios con datos completos
- % de emails verificados
- Tokens generados vs usados
- Tiempo promedio de registro
- Tasa de abandono en el formulario

---

## 🐛 Troubleshooting

### "Enlace no funciona"

1. Verificar que frontend esté corriendo
2. Verificar URL en variables de entorno
3. Verificar token en base de datos

### "Email no llega"

1. Verificar credenciales SMTP
2. Verificar email en spam
3. Verificar logs de envío

### "Usuario queda en loop"

1. Verificar campos `datos_completos` y `email_verificado`
2. Ejecutar función `verificar_datos_usuario()`
3. Verificar logs de n8n

---

## 📚 Archivos Relacionados

- `database/schema_nutridiab_complete.sql` - Schema actualizado
- `frontend/src/pages/UserRegistration.jsx` - Formulario
- `n8n/workflows/nutridiab_complete.json` - Workflow actualizado
- `INTEGRACION_VERIFICACION.md` - Guía de integración

---

**Última actualización**: 2025-11-20  
**Versión**: 2.0 - Con verificación de usuario

