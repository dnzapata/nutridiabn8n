# ⚡ Cómo Implementar la Verificación de Usuario

Guía rápida para agregar el flujo de verificación al workflow existente de Nutridiab (aplicación de control nutricional para diabéticos).

---

## 📋 Pasos Rápidos

### 1️⃣ Actualizar Base de Datos (5 minutos)

**En Supabase SQL Editor**, ejecuta:

```sql
-- Ejecutar TODO el contenido de:
database/schema_nutridiab_complete.sql
```

Esto agregará:
- ✅ Nuevos campos a tabla `usuarios`
- ✅ Nueva tabla `tokens_acceso`
- ✅ Funciones de validación
- ✅ Mensajes actualizados

**Verificar**:

```sql
-- Debería retornar TRUE
SELECT EXISTS (
  SELECT 1 FROM information_schema.columns 
  WHERE table_schema = 'nutridiab' 
    AND table_name = 'usuarios' 
    AND column_name = 'datos_completos'
);
```

---

### 2️⃣ Configurar Frontend (Ya está listo! ✅)

El frontend ya tiene:
- ✅ Formulario de registro (`/registro`)
- ✅ Página de éxito (`/registro-exitoso`)
- ✅ Validación de tokens
- ✅ Estilos completos

**Solo necesitas**:

```bash
# Si no lo hiciste antes
cd frontend
npm install
npm run dev
```

**Rutas creadas**:
- `http://localhost:5173/registro?token=abc123`
- `http://localhost:5173/registro-exitoso`

---

### 3️⃣ Crear Workflows en n8n (30 minutos)

#### A. Workflow: Generar Token

**Nombre**: `NutriDiab - Generate Token`  
**Webhook**: `POST /webhook/nutridiab/generate-token`

**Nodos**:

1. **Webhook** (POST)
2. **Supabase - Execute Query**:

```sql
INSERT INTO nutridiab.tokens_acceso (
  "usuario ID", 
  token, 
  tipo, 
  expira
)
VALUES (
  {{ $json.body.usuario_id }},
  encode(gen_random_bytes(32), 'hex'),
  '{{ $json.body.tipo || "registro" }}',
  NOW() + INTERVAL '24 hours'
)
RETURNING token, expira, "usuario ID";
```

3. **Code - Construir URL**:

```javascript
const token = $json[0].token;
const baseUrl = 'https://tu-dominio.com'; // CAMBIAR
const url = `${baseUrl}/registro?token=${token}`;

return {
  success: true,
  url,
  token,
  expira: $json[0].expira
};
```

4. **Respond to Webhook**

---

#### B. Workflow: Validar Token

**Nombre**: `NutriDiab - Validate Token`  
**Webhook**: `POST /webhook/nutridiab/validate-token`

**Nodos**:

1. **Webhook** (POST)
2. **Supabase - Execute Query**:

```sql
SELECT 
  ta.*,
  u."usuario ID",
  u.nombre,
  u.apellido,
  u.email,
  u.telefono,
  u.fecha_nacimiento,
  u.tipo_diabetes,
  u.anios_diagnostico,
  u.usa_insulina,
  u.medicamentos
FROM nutridiab.tokens_acceso ta
LEFT JOIN nutridiab.usuarios u ON ta."usuario ID" = u."usuario ID"
WHERE ta.token = '{{ $json.body.token }}'
LIMIT 1;
```

3. **Code - Validar**:

```javascript
const tokenData = $json[0];

if (!tokenData) {
  return {
    valid: false,
    message: 'Token no encontrado'
  };
}

const now = new Date();
const expira = new Date(tokenData.expira);
const expired = now > expira;
const usado = tokenData.usado;

if (usado) {
  return {
    valid: false,
    expired: false,
    message: 'Token ya usado'
  };
}

if (expired) {
  return {
    valid: false,
    expired: true,
    message: 'Token expirado'
  };
}

return {
  valid: true,
  expired: false,
  user: {
    usuario_id: tokenData['usuario ID'],
    nombre: tokenData.nombre,
    apellido: tokenData.apellido,
    email: tokenData.email,
    telefono: tokenData.telefono,
    fecha_nacimiento: tokenData.fecha_nacimiento,
    tipo_diabetes: tokenData.tipo_diabetes,
    anios_diagnostico: tokenData.anios_diagnostico,
    usa_insulina: tokenData.usa_insulina,
    medicamentos: tokenData.medicamentos
  }
};
```

4. **Respond to Webhook**

---

#### C. Workflow: Completar Registro

**Nombre**: `NutriDiab - Complete Registration`  
**Webhook**: `POST /webhook/nutridiab/complete-registration`

**Nodos**:

1. **Webhook** (POST)

2. **HTTP Request - Validar Token**:
```
URL: http://n8n:5678/webhook/nutridiab/validate-token
Method: POST
Body: { "token": "={{ $json.body.token }}" }
```

3. **IF - Token Válido**:
```
{{ $json.valid }} equals true
```

4. **Supabase - Update Usuario**:

```sql
UPDATE nutridiab.usuarios
SET 
  nombre = '{{ $('Webhook').item.json.body.nombre }}',
  apellido = '{{ $('Webhook').item.json.body.apellido }}',
  email = '{{ $('Webhook').item.json.body.email }}',
  telefono = '{{ $('Webhook').item.json.body.telefono }}',
  fecha_nacimiento = '{{ $('Webhook').item.json.body.fecha_nacimiento }}',
  tipo_diabetes = '{{ $('Webhook').item.json.body.tipo_diabetes }}',
  anios_diagnostico = {{ $('Webhook').item.json.body.anios_diagnostico || null }},
  usa_insulina = {{ $('Webhook').item.json.body.usa_insulina || false }},
  medicamentos = '{{ $('Webhook').item.json.body.medicamentos }}',
  datos_completos = TRUE,
  updated_at = NOW()
WHERE "usuario ID" = {{ $('HTTP Request').item.json.user.usuario_id }}
RETURNING *;
```

5. **Supabase - Marcar Token Usado**:

```sql
UPDATE nutridiab.tokens_acceso
SET usado = TRUE, usado_en = NOW()
WHERE token = '{{ $('Webhook').item.json.body.token }}';
```

6. **Code - Preparar Respuesta**:

```javascript
return {
  success: true,
  message: 'Registro completado',
  user: $('Supabase').first().json
};
```

7. **Respond to Webhook**

---

### 4️⃣ Modificar Workflow Principal (15 minutos)

En tu workflow `nutridiab.json` existente:

**Después del nodo "Get a row"**, agregar:

#### Nodo: "Verificar Estado Usuario" (Code)

```javascript
const usuario = $('Get a row').first().json;

// Si no hay usuario, es nuevo (flujo existente)
if (!usuario || !usuario['usuario ID']) {
  return {
    estado: 'nuevo',
    proceder: false,
    mensaje_codigo: null
  };
}

// Usuario existe - verificar datos
const datosCompletos = usuario.datos_completos || false;
const emailVerificado = usuario.email_verificado || false;
const aceptoTerminos = usuario.AceptoTerminos || false;

let estado, mensajeCodigo;

if (!aceptoTerminos) {
  return {
    estado: 'pendiente_terminos',
    proceder: false,
    mensaje_codigo: null
  };
}

if (!datosCompletos) {
  return {
    estado: 'pendiente_datos',
    proceder: false,
    mensaje_codigo: 'DATOS_INCOMPLETOS',
    usuario_id: usuario['usuario ID']
  };
}

if (!emailVerificado) {
  return {
    estado: 'pendiente_email',
    proceder: false,
    mensaje_codigo: 'EMAIL_NO_VERIFICADO',
    email: usuario.email
  };
}

// Todo OK - continuar normal
return {
  estado: 'activo',
  proceder: true,
  mensaje_codigo: null,
  nombre: usuario.nombre
};
```

#### Nodo: "IF Usuario Listo" (IF)

**Condición**: `{{ $json.proceder }} equals true`

- **true** → Continuar a "Switch" (flujo normal)
- **false** → Ir a "Manejar Pendientes"

#### Nodo: "Manejar Pendientes" (Switch)

**Cases**:

1. **pendiente_terminos** → Flujo existente de términos
2. **pendiente_datos** → Nuevo flujo de datos
3. **pendiente_email** → Nuevo flujo de email

**Case pendiente_datos** → Conectar a:

1. **HTTP Request - Generar Token**:
```
URL: http://n8n:5678/webhook/nutridiab/generate-token
Method: POST
Body: {
  "usuario_id": "={{ $json.usuario_id }}",
  "tipo": "registro"
}
```

2. **Leer Mensaje DATOS_INCOMPLETOS** (Execute Workflow):
```
Workflow: LeerMensajeNutridiab
Input: { "CODIGO": "DATOS_INCOMPLETOS" }
```

3. **Code - Reemplazar Variables**:

```javascript
const mensaje = $('Leer Mensaje DATOS_INCOMPLETOS').first().json.Texto;
const url = $('HTTP Request').first().json.url;

return {
  texto: mensaje.replace('{{enlace}}', url)
};
```

4. **Responder WhatsApp** (HTTP Request a Evolution API)

---

### 5️⃣ Testing (10 minutos)

#### Test Frontend

```bash
# Generar un token manual en Supabase
INSERT INTO nutridiab.tokens_acceso (
  "usuario ID", token, tipo, expira
) VALUES (
  1, 'test123', 'registro', NOW() + INTERVAL '24 hours'
) RETURNING token;

# Probar en navegador
http://localhost:5173/registro?token=test123
```

#### Test Workflows

```bash
# Test Generar Token
curl -X POST https://wf.zynaptic.tech/webhook/nutridiab/generate-token \
  -H "Content-Type: application/json" \
  -d '{"usuario_id": 1, "tipo": "registro"}'

# Test Validar Token
curl -X POST https://wf.zynaptic.tech/webhook/nutridiab/validate-token \
  -H "Content-Type: application/json" \
  -d '{"token": "test123"}'
```

---

## ✅ Checklist de Implementación

### Base de Datos
- [ ] Schema actualizado en Supabase
- [ ] Funciones creadas
- [ ] Mensajes actualizados
- [ ] Verificado con queries de test

### Frontend
- [ ] Código desplegado
- [ ] Rutas funcionando
- [ ] Formulario accesible
- [ ] Estilos aplicados

### n8n Workflows
- [ ] Workflow "Generate Token" creado y activo
- [ ] Workflow "Validate Token" creado y activo
- [ ] Workflow "Complete Registration" creado y activo
- [ ] Workflow principal modificado
- [ ] Nodo "Verificar Estado Usuario" agregado
- [ ] Switch "Manejar Pendientes" configurado

### Testing
- [ ] Token se genera correctamente
- [ ] URL de registro funciona
- [ ] Formulario se llena y envía
- [ ] Datos se guardan en Supabase
- [ ] WhatsApp recibe confirmación
- [ ] Usuario puede usar el servicio

### Producción
- [ ] Variable `FRONTEND_URL` configurada en n8n
- [ ] SSL activo en frontend
- [ ] Tokens expiran correctamente
- [ ] Emails se envían (si implementado)

---

## 🐛 Problemas Comunes

### "Token no válido"

**Causa**: Token expiró o ya se usó

**Solución**: 
```sql
-- Verificar estado del token
SELECT * FROM nutridiab.tokens_acceso WHERE token = 'tu_token';

-- Si expiró, generar uno nuevo desde WhatsApp
```

### "Formulario no guarda"

**Causa**: Workflow no activo o credenciales incorrectas

**Solución**:
1. Verificar workflow "Complete Registration" está Active
2. Verificar logs en n8n → Executions
3. Verificar credenciales de Supabase

### "Usuario sigue pidiendo datos"

**Causa**: Campo `datos_completos` no se actualizó

**Solución**:
```sql
-- Verificar estado
SELECT 
  "usuario ID", 
  nombre, 
  email, 
  datos_completos, 
  email_verificado 
FROM nutridiab.usuarios 
WHERE remoteJid = 'numero@s.whatsapp.net';

-- Forzar actualización si todo está correcto
UPDATE nutridiab.usuarios 
SET datos_completos = TRUE, email_verificado = TRUE
WHERE "usuario ID" = 1;
```

---

## 📚 Documentación Completa

- `n8n/FLUJO_VERIFICACION_USUARIO.md` - Flujo detallado
- `database/schema_nutridiab_complete.sql` - Schema completo
- `frontend/src/pages/UserRegistration.jsx` - Código del formulario

---

## 🎯 Próximos Pasos

Después de implementar esto, puedes agregar:

1. **Verificación de Email** - Enviar email con link
2. **Recordatorios** - Si usuario no completa en X días
3. **Dashboard de Admin** - Ver estado de usuarios
4. **Análisis** - % de completitud, abandono, etc.

---

**¿Necesitas ayuda?** Revisa los logs en:
- n8n: Executions tab
- Frontend: Console del navegador (F12)
- Supabase: Logs tab

**Tiempo total estimado**: 1 hora

¡Éxito con la implementación! 🚀

