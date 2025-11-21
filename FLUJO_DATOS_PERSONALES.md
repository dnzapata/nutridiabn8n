# 📋 Flujo de Datos Personales - Nutridiab

## 🎯 Objetivo

Implementar un flujo completo donde usuarios sin datos personales reciban un enlace tokenizado por WhatsApp para completar su perfil en la SPA.

---

## 🔄 Flujo Completo

```
Usuario envía mensaje por WhatsApp
          ↓
┌─────────────────────────┐
│ Workflow Principal      │
│ (nutridiab.json)        │
└───────┬─────────────────┘
        ↓
  ¿Datos completos?
        │
    NO ──┤──── SÍ
    ↓               ↓
┌─────────────────┐   Procesar
│ Generar Token   │   consulta
│ Enviar enlace   │
└────────┬────────┘
         ↓
    WhatsApp:
    "📋 Completa tus datos:
     https://app.com/registro?token=abc123"
         ↓
    Usuario hace click
         ↓
┌─────────────────────────┐
│  SPA React              │
│  /registro?token=abc123 │
└───────┬─────────────────┘
        ↓
   Formulario
   (nombre, email, etc.)
        ↓
    Usuario envía
        ↓
┌─────────────────────────┐
│ Validar Token y Guardar │
│ (validate-and-save)     │
└───────┬─────────────────┘
        ↓
    ✅ Datos guardados
    datos_completos = TRUE
        ↓
    Mensaje de confirmación
```

---

## 📁 Archivos Creados

### 1. Workflows n8n (2 archivos)

#### `n8n/workflows/generate-token-workflow.json`
**Endpoint**: `POST https://wf.zynaptic.tech/webhook/nutridiab/generate-token`

**Función**: Generar token único y crear enlace de registro

**Payload de entrada**:
```json
{
  "usuario_id": 123
}
```

**Respuesta**:
```json
{
  "success": true,
  "token": "abc123...",
  "enlace": "http://localhost:5173/registro?token=abc123...",
  "expira": "2025-11-22T20:00:00Z",
  "mensaje": "📋 Para completar tu registro, ingresa a:\n\nhttp://..."
}
```

#### `n8n/workflows/validate-token-workflow.json`
**Endpoint**: `POST https://wf.zynaptic.tech/webhook/nutridiab/validate-and-save`

**Función**: Validar token y guardar datos del usuario

**Payload de entrada**:
```json
{
  "token": "abc123...",
  "nombre": "Juan",
  "apellido": "Pérez",
  "email": "juan@example.com",
  "telefono": "+5491155555555",
  "fecha_nacimiento": "1980-01-15",
  "tipo_diabetes": "tipo2",
  "anios_diagnostico": 5,
  "usa_insulina": true,
  "medicamentos": "Metformina 850mg"
}
```

**Respuesta exitosa**:
```json
{
  "success": true,
  "message": "Datos guardados exitosamente",
  "usuario": { ... }
}
```

**Respuesta error**:
```json
{
  "success": false,
  "error": "Token inválido o expirado"
}
```

### 2. Componente React

Ya existe en: `frontend/src/pages/UserRegistration.jsx`

---

## 🔧 Implementación Paso a Paso

### PASO 1: Ejecutar Schema en Supabase

Ya está listo en `database/schema_nutridiab_complete.sql`

```sql
-- En Supabase SQL Editor, ejecuta el schema completo
-- Esto crea las tablas, funciones y triggers necesarios
```

### PASO 2: Importar Workflows en n8n

1. Ve a https://wf.zynaptic.tech
2. Workflows → Import from File
3. Importa:
   - `n8n/workflows/generate-token-workflow.json`
   - `n8n/workflows/validate-token-workflow.json`
4. **IMPORTANTE**: Configura tus credenciales de Supabase en cada nodo
5. Activa ambos workflows (toggle verde)

### PASO 3: Modificar Workflow Principal

En tu workflow `nutridiab.json`, después de verificar términos, agrega:

```javascript
// Nodo: Code - Verificar Datos Completos
const remoteJid = $('Datos Whatsapp').item.json.data.key.remoteJid;

// Consultar usuario
const usuario = await $('Supabase').execute({
  query: `
    SELECT "usuario ID", datos_completos, email_verificado 
    FROM nutridiab.usuarios 
    WHERE "remoteJid" = '${remoteJid}'
  `
});

const datosCompletos = usuario[0].datos_completos;
const usuarioId = usuario[0]['usuario ID'];

return {
  json: {
    datos_completos: datosCompletos,
    usuario_id: usuarioId,
    remoteJid: remoteJid
  }
};
```

Luego agrega un nodo **IF**:

```javascript
// Condición: $json.datos_completos === false
```

**Rama SI (datos incompletos)**:

```javascript
// 1. Llamar a generate-token
const response = await $http.request({
  method: 'POST',
  url: 'https://wf.zynaptic.tech/webhook/nutridiab/generate-token',
  body: {
    usuario_id: $json.usuario_id
  }
});

// 2. Enviar mensaje por WhatsApp con el enlace
await $http.request({
  method: 'POST',
  url: `${server_url}/message/sendText/${instance}`,
  headers: {
    'apikey': apikey
  },
  body: {
    number: remoteJid,
    text: response.mensaje
  }
});

return { json: { sent: true } };
```

**Rama NO (datos completos)**:
→ Continuar con el flujo normal de análisis nutricional

### PASO 4: Actualizar Frontend

El componente ya existe, solo necesitas:

1. Agregar la ruta en `App.jsx`:

```jsx
// frontend/src/App.jsx
import UserRegistration from './pages/UserRegistration'

// En las rutas:
<Route path="/registro" element={<UserRegistration />} />
<Route path="/registro-exitoso" element={<RegistroExitoso />} />
```

2. Crear página de éxito `frontend/src/pages/RegistroExitoso.jsx`:

```jsx
function RegistroExitoso() {
  return (
    <div className="registro-exitoso">
      <h1>🎉 ¡Registro Exitoso!</h1>
      <p>Tus datos han sido guardados correctamente.</p>
      <p>Ahora puedes volver a WhatsApp y empezar a usar Nutridiab.</p>
    </div>
  );
}
```

### PASO 5: Configurar URL del Frontend

En el workflow `generate-token-workflow.json`, actualiza la URL:

```javascript
// Cambiar de:
const frontend_url = 'http://localhost:5173';

// A tu dominio:
const frontend_url = 'https://tu-dominio.com';
```

---

## 🧪 Testing

### Test 1: Generar Token

```bash
curl -X POST https://wf.zynaptic.tech/webhook/nutridiab/generate-token \
  -H "Content-Type: application/json" \
  -d '{"usuario_id": 1}'
```

### Test 2: Validar y Guardar

```bash
curl -X POST https://wf.zynaptic.tech/webhook/nutridiab/validate-and-save \
  -H "Content-Type: application/json" \
  -d '{
    "token": "TOKEN_GENERADO",
    "nombre": "Juan",
    "apellido": "Pérez",
    "email": "juan@test.com",
    "telefono": "+5491155555555",
    "fecha_nacimiento": "1980-01-15",
    "tipo_diabetes": "tipo2",
    "anios_diagnostico": 5,
    "usa_insulina": true,
    "medicamentos": "Metformina"
  }'
```

### Test 3: Verificar en Base de Datos

```sql
-- Verificar token generado
SELECT * FROM nutridiab.tokens_acceso 
ORDER BY created_at DESC LIMIT 5;

-- Verificar usuario actualizado
SELECT "usuario ID", nombre, apellido, email, datos_completos
FROM nutridiab.usuarios
WHERE datos_completos = TRUE;
```

---

## 🎨 Ejemplo de Mensaje en WhatsApp

```
📋 ¡Hola! Para brindarte un mejor servicio, necesito que completes algunos datos personales.

Esto me ayudará a darte recomendaciones más precisas según tu tipo de diabetes y necesidades. 👨‍⚕️

👉 Ingresa aquí para completar tu perfil:
https://tu-app.com/registro?token=abc123def456...

⏰ Este enlace es válido por 24 horas.

Una vez que completes tus datos, podrás empezar a usar el servicio completo. 🍽️
```

---

## 🔐 Seguridad

✅ **Tokens únicos**: Cada token es generado con `gen_random_bytes(32)`  
✅ **Expiración**: 24 horas por defecto  
✅ **Uso único**: El token se marca como usado después de guardar datos  
✅ **Validación**: Se verifica token válido antes de aceptar datos  
✅ **Limpieza**: Función para eliminar tokens expirados (>7 días)

---

## 📊 Base de Datos

### Campos verificados para `datos_completos = TRUE`:

- ✅ `nombre` (no NULL, no vacío)
- ✅ `apellido` (no NULL, no vacío)
- ✅ `email` (no NULL, no vacío)
- ✅ `tipo_diabetes` (no NULL)

### Campos opcionales:

- `telefono`
- `fecha_nacimiento`
- `anios_diagnostico`
- `usa_insulina`
- `medicamentos`

---

## 🚀 Deploy en Producción

1. **Actualizar URL del frontend** en `generate-token-workflow.json`
2. **Configurar dominio** en las variables de entorno
3. **Habilitar HTTPS** para el frontend
4. **Configurar CORS** en n8n si es necesario
5. **Ejecutar schema** en Supabase de producción
6. **Importar workflows** en n8n de producción
7. **Actualizar workflow principal** con la lógica de verificación

---

## 📝 Notas

- Los tokens expiran en 24 horas
- Un usuario puede generar múltiples tokens si es necesario
- Solo se acepta el token más reciente no usado
- El campo `datos_completos` se actualiza automáticamente

---

**Creado para**: Nutridiab - Control Nutricional para Diabéticos  
**Fecha**: 2025-11-21  
**Versión**: 1.0

