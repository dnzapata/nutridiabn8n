# n8n Backend Configuration

Esta carpeta contiene la configuración y workflows de n8n que actúan como backend de la aplicación.

## 📁 Estructura

```
n8n/
├── data/                  # Datos persistentes de n8n (generado automáticamente)
├── workflows/             # Workflows de ejemplo para importar
└── README.md
```

## 🔧 Workflows Disponibles

### 1. Health Check
**Endpoint**: `GET /webhook/health`

Verifica el estado del backend.

**Respuesta**:
```json
{
  "status": "ok",
  "timestamp": "2025-11-20T10:00:00.000Z",
  "service": "n8n-backend"
}
```

### 2. CRUD Operations
**Endpoints**: 
- `GET /webhook/items` - Listar items
- `POST /webhook/items` - Crear item
- `GET /webhook/items/:id` - Obtener item específico
- `PUT /webhook/items/:id` - Actualizar item
- `DELETE /webhook/items/:id` - Eliminar item

### 3. Authentication Flow
**Endpoints**:
- `POST /webhook/auth/login` - Login de usuario
- `POST /webhook/auth/register` - Registro de usuario
- `POST /webhook/auth/logout` - Cerrar sesión

## 📝 Cómo Importar Workflows

1. Inicia n8n: `docker-compose up -d`
2. Accede a https://wf.zynaptic.tech
3. Ve a **Workflows** → **Import from File**
4. Selecciona los archivos JSON de la carpeta `workflows/`

## 🎯 Crear un Nuevo Workflow

1. En n8n, crea un nuevo workflow
2. Agrega un nodo **Webhook**
3. Configura el método HTTP (GET, POST, etc.)
4. Define la ruta del webhook
5. Agrega la lógica de negocio con otros nodos
6. Responde con un nodo **Respond to Webhook**
7. Activa el workflow

## 💡 Ejemplos de Nodos Útiles

- **HTTP Request**: Llamar APIs externas
- **Code**: JavaScript/Python personalizado
- **Function**: Transformar datos
- **IF**: Lógica condicional
- **Switch**: Múltiples condiciones
- **Set**: Establecer variables
- **Database nodes**: MySQL, PostgreSQL, MongoDB
- **Error Trigger**: Manejo de errores

## 🔐 Seguridad

Para producción, considera:

1. Activar autenticación básica en n8n
2. Usar HTTPS
3. Implementar rate limiting
4. Validar entrada de usuarios
5. Usar variables de entorno para secretos

## 📊 Monitoreo

Accede a las ejecuciones en:
- https://wf.zynaptic.tech/executions

Aquí puedes ver:
- Historial de ejecuciones
- Errores y logs
- Tiempo de ejecución
- Datos de entrada/salida

