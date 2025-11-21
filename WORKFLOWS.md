# 📋 Guía de Workflows en n8n

Esta guía explica cómo crear y trabajar con workflows en n8n para tu aplicación.

## 🎯 ¿Qué es un Workflow?

Un workflow en n8n es un conjunto de nodos conectados que procesan datos de forma secuencial. Cada nodo realiza una tarea específica (recibir petición HTTP, consultar base de datos, enviar email, etc.).

## 🏗️ Estructura Básica de un Workflow para API

```
Webhook → Procesar Datos → Responder
```

### Ejemplo Mínimo

1. **Nodo Webhook**: Recibe la petición HTTP
2. **Nodo Code/Function**: Procesa los datos
3. **Nodo Respond to Webhook**: Envía la respuesta

## 📝 Workflows Incluidos

### 1. Health Check

**Propósito**: Verificar que el backend está funcionando

**Endpoint**: `GET /webhook/health`

**Flujo**:
```
Webhook (GET) → Code (generar respuesta) → Respond
```

**Respuesta**:
```json
{
  "status": "ok",
  "timestamp": "2025-11-20T10:00:00.000Z",
  "service": "n8n-backend",
  "version": "1.0.0"
}
```

### 2. CRUD Example

**Propósito**: Operaciones CRUD básicas (Create, Read, Update, Delete)

**Endpoints**: 
- `GET /webhook/items` - Listar todos los items
- `POST /webhook/items` - Crear nuevo item

**Flujo**:
```
Webhook → IF (GET/POST) → Code (lógica) → Respond
```

## 🛠️ Crear tu Primer Workflow

### Paso 1: Crear Workflow Nuevo

1. Abre n8n: https://wf.zynaptic.tech
2. Click en **"Add workflow"** o el botón **"+"**
3. Dale un nombre descriptivo (ej: "Get Users")

### Paso 2: Agregar Nodo Webhook

1. Click en el botón **"+"** en el canvas
2. Busca **"Webhook"**
3. Configura:
   - **HTTP Method**: GET, POST, etc.
   - **Path**: Nombre único (ej: `users`)
   - **Response Mode**: "Response Node"

### Paso 3: Agregar Lógica

Ejemplo con nodo Code:

```javascript
// Obtener datos del webhook
const method = $input.first().json.method;
const body = $input.first().json.body;

// Tu lógica aquí
if (method === 'GET') {
  // Retornar lista de usuarios (simulado)
  return [
    { id: 1, name: 'Juan', email: 'juan@example.com' },
    { id: 2, name: 'María', email: 'maria@example.com' }
  ];
}

if (method === 'POST') {
  // Crear nuevo usuario
  const newUser = {
    id: Date.now(),
    name: body.name,
    email: body.email,
    createdAt: new Date().toISOString()
  };
  
  return { success: true, user: newUser };
}

return { error: 'Método no soportado' };
```

### Paso 4: Agregar Respuesta

1. Agregar nodo **"Respond to Webhook"**
2. Configurar:
   - **Respond With**: JSON
   - **Response Body**: `={{ $json }}`

### Paso 5: Activar Workflow

1. Click en el toggle en la esquina superior derecha
2. Debería cambiar a verde con texto "Active"
3. Copia la URL del webhook

### Paso 6: Probar

```bash
# En tu terminal o Postman
curl https://wf.zynaptic.tech/webhook/users
```

## 🔄 Tipos de Workflows Comunes

### 1. API REST Simple

```
Webhook → Code → Respond
```

**Uso**: Endpoints simples sin base de datos

### 2. CRUD con Base de Datos

```
Webhook → IF → Database Node → Respond
```

**Uso**: Operaciones con PostgreSQL, MySQL, MongoDB

### 3. Autenticación

```
Webhook → Validate Token → IF Valid → Process → Respond
```

**Uso**: Endpoints protegidos

### 4. Integración con APIs Externas

```
Webhook → HTTP Request → Transform Data → Respond
```

**Uso**: Proxy o agregación de APIs

### 5. Procesamiento Asíncrono

```
Webhook → Queue → Respond (202 Accepted)
         ↓
    Process in Background
```

**Uso**: Tareas largas (envío de emails, generación de reportes)

## 💡 Ejemplos Prácticos

### Ejemplo 1: Login Simple

```javascript
// Nodo Code - Validar Credenciales
const { email, password } = $input.first().json.body;

// Validar (en producción, usa hash y DB)
if (email === 'admin@example.com' && password === 'admin123') {
  return {
    success: true,
    token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    user: {
      id: 1,
      email: email,
      name: 'Administrador'
    }
  };
}

return {
  success: false,
  error: 'Credenciales inválidas'
};
```

### Ejemplo 2: Consultar API Externa

```javascript
// Nodo HTTP Request
// URL: https://api.github.com/users/{{ $json.username }}
// Method: GET

// Luego en Code Node
const githubData = $input.first().json;

return {
  username: githubData.login,
  repos: githubData.public_repos,
  followers: githubData.followers,
  avatar: githubData.avatar_url
};
```

### Ejemplo 3: Validación de Datos

```javascript
// Nodo Code - Validar Input
const { name, email, age } = $input.first().json.body;

// Validaciones
if (!name || name.length < 3) {
  throw new Error('Nombre debe tener al menos 3 caracteres');
}

if (!email || !email.includes('@')) {
  throw new Error('Email inválido');
}

if (!age || age < 18) {
  throw new Error('Debe ser mayor de 18 años');
}

// Si pasa validación
return {
  success: true,
  data: { name, email, age }
};
```

### Ejemplo 4: Paginación

```javascript
// Nodo Code - Implementar Paginación
const query = $input.first().json.query;
const page = parseInt(query.page) || 1;
const limit = parseInt(query.limit) || 10;

// Datos simulados (en producción, consulta DB)
const allItems = Array.from({ length: 50 }, (_, i) => ({
  id: i + 1,
  name: `Item ${i + 1}`
}));

const startIndex = (page - 1) * limit;
const endIndex = startIndex + limit;
const items = allItems.slice(startIndex, endIndex);

return {
  data: items,
  pagination: {
    page: page,
    limit: limit,
    total: allItems.length,
    pages: Math.ceil(allItems.length / limit)
  }
};
```

## 🔧 Nodos Útiles

### Transformación de Datos

- **Code**: JavaScript/Python personalizado
- **Function**: Transformar JSON
- **Set**: Establecer valores

### Bases de Datos

- **PostgreSQL**
- **MySQL**
- **MongoDB**
- **Redis**

### HTTP

- **HTTP Request**: Llamar APIs
- **Webhook**: Recibir peticiones

### Lógica

- **IF**: Condiciones simples
- **Switch**: Múltiples condiciones
- **Merge**: Combinar datos

### Notificaciones

- **Email (SMTP)**
- **Slack**
- **Telegram**
- **Discord**

## 🎨 Mejores Prácticas

### 1. Nombres Descriptivos

```
❌ Webhook1
✅ Get User Profile

❌ Code
✅ Validate Email Format
```

### 2. Manejo de Errores

```javascript
try {
  // Tu lógica
  const result = await someOperation();
  return { success: true, data: result };
} catch (error) {
  return { 
    success: false, 
    error: error.message 
  };
}
```

### 3. Validación de Input

```javascript
// Al inicio de tus nodos Code
const body = $input.first().json.body;

if (!body || typeof body !== 'object') {
  throw new Error('Request body inválido');
}

// Validar campos requeridos
const required = ['name', 'email'];
for (const field of required) {
  if (!body[field]) {
    throw new Error(`Campo ${field} es requerido`);
  }
}
```

### 4. Responses Consistentes

```javascript
// Éxito
return {
  success: true,
  data: result,
  message: 'Operación exitosa'
};

// Error
return {
  success: false,
  error: 'Mensaje de error',
  code: 'ERROR_CODE'
};
```

### 5. Documentar Workflows

- Agrega notas (Sticky Notes) en el canvas
- Describe qué hace cada sección
- Documenta los endpoints en el README

## 🧪 Testing de Workflows

### Método 1: n8n Test

1. Click en **"Execute Workflow"** (botón Play)
2. Agrega datos de prueba
3. Verifica el resultado

### Método 2: curl

```bash
# GET
curl https://wf.zynaptic.tech/webhook/test

# POST
curl -X POST https://wf.zynaptic.tech/webhook/test \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","value":123}'
```

### Método 3: Postman

1. Importa la colección
2. Configura las variables
3. Ejecuta las peticiones

## 📊 Monitoreo

### Ver Ejecuciones

1. Ve a **"Executions"** en n8n
2. Verás todas las ejecuciones recientes
3. Click en una para ver detalles

### Logs

```bash
# Ver logs de n8n en tiempo real
docker-compose logs -f n8n
```

## 🚀 Próximos Pasos

1. **Practica**: Crea workflows simples primero
2. **Experimenta**: Prueba diferentes nodos
3. **Documenta**: Mantén notas de tus workflows
4. **Optimiza**: Mejora el rendimiento con caché y async

## 📚 Recursos

- [Documentación oficial de n8n](https://docs.n8n.io/)
- [Ejemplos de workflows](https://n8n.io/workflows)
- [n8n Community](https://community.n8n.io/)

---

**¡Feliz automatización! 🔄**

