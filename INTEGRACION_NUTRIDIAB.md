# 🔗 Guía de Integración - Nutridiab Frontend + n8n

Esta guía explica cómo integrar el frontend React con tu workflow de Nutridiab en n8n.

---

## 📊 Arquitectura Actual

```
WhatsApp ──→ Evolution API ──→ n8n Workflow ──→ Supabase
                                     ↓
                                  OpenAI
                                  OpenRouter
```

## 🎯 Arquitectura con Frontend

```
WhatsApp ──→ Evolution API ──→ n8n Workflow ──→ Supabase
                                     ↓              ↑
                                  OpenAI           │
                                  OpenRouter       │
                                                   │
React App ─────→ n8n Admin API ──────────────────┘
```

---

## 🛠️ Paso 1: Crear Endpoints de Admin en n8n

Tu workflow actual maneja mensajes de WhatsApp. Necesitamos crear **workflows adicionales** para que el frontend pueda consultar datos.

### Workflow: Dashboard Stats

**Nombre**: `Nutridiab Admin - Stats`  
**Endpoint**: `GET /webhook/nutridiab/stats`

```javascript
// Nodo Code - Obtener estadísticas
const { query } = $input.first().json;

// Conectar a Supabase y obtener datos
// (Usa nodo Supabase en lugar de código SQL directo)

return {
  totalUsers: 127,
  totalConsultas: 1543,
  totalCost: 45.67,
  consultasHoy: 34,
  newUsersToday: 5
};
```

**Estructura del Workflow**:
```
Webhook (GET) → Supabase (Count usuarios) → Code (Formatear) → Respond
```

---

### Workflow: Get Users

**Nombre**: `NutriDiab Admin - Get Users`  
**Endpoint**: `GET /webhook/nutridiab/users`

```
Webhook (GET) → Supabase (Query usuarios) → Respond
```

**Configuración del Nodo Supabase**:
- **Operation**: Get
- **Table**: `nutridiab.usuarios`
- **Return All**: true
- **Filters**: Ninguno (o agregar paginación)

---

### Workflow: Get Consultas

**Nombre**: `NutriDiab Admin - Get Consultas`  
**Endpoint**: `GET /webhook/nutridiab/consultas`

```
Webhook (GET) → IF (filtrar por userId?) → Supabase → JOIN usuarios → Respond
```

**SQL Query** (si usas Execute Query en Supabase):
```sql
SELECT 
  c.id,
  c.tipo,
  c.resultado,
  c."Costo",
  c.created_at,
  u.remoteJid,
  -- Extraer nombre de remoteJid (antes del @)
  SPLIT_PART(u.remoteJid, '@', 1) as username
FROM nutridiab."Consultas" c
LEFT JOIN nutridiab.usuarios u ON c."usuario ID" = u."usuario ID"
ORDER BY c.created_at DESC
LIMIT {{ $json.query.limit || 50 }}
OFFSET {{ ($json.query.page - 1) * $json.query.limit || 0 }};
```

---

### Workflow: Cost Stats

**Nombre**: `NutriDiab Admin - Cost Stats`  
**Endpoint**: `GET /webhook/nutridiab/costs`

```sql
SELECT 
  DATE(created_at) as fecha,
  COUNT(*) as consultas,
  SUM("Costo") as costo_total,
  AVG("Costo") as costo_promedio
FROM nutridiab."Consultas"
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY fecha DESC;
```

---

### Workflow: Type Stats

**Nombre**: `NutriDiab Admin - Type Stats`  
**Endpoint**: `GET /webhook/nutridiab/stats/types`

```sql
SELECT 
  tipo,
  COUNT(*) as total,
  AVG("Costo") as costo_promedio
FROM nutridiab."Consultas"
GROUP BY tipo;
```

---

## 🔧 Paso 2: Configurar CORS en n8n

Para que el frontend React pueda llamar a los webhooks de n8n, necesitas configurar CORS.

### Opción A: Headers en cada Webhook

En cada nodo **Respond to Webhook**, agrega headers:

```json
{
  "Access-Control-Allow-Origin": "http://localhost:5173",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type"
}
```

### Opción B: Proxy en Vite (Ya configurado)

El archivo `vite.config.js` ya tiene un proxy configurado:

```javascript
proxy: {
  '/webhook': {
    target: 'http://localhost:5678',
    changeOrigin: true,
  }
}
```

Esto significa que las llamadas a `/webhook/*` desde el frontend se redirigen automáticamente a n8n.

---

## 📝 Paso 3: Estructura de Datos Esperada

### Dashboard Stats Response

```json
{
  "totalUsers": 127,
  "totalConsultas": 1543,
  "totalCost": 45.67,
  "avgCostPerQuery": 0.0296,
  "consultasHoy": 34,
  "newUsersToday": 5,
  "tipoStats": {
    "texto": 856,
    "imagen": 412,
    "audio": 275
  }
}
```

### Users Response

```json
{
  "users": [
    {
      "usuario ID": 1,
      "remoteJid": "5491155555555@s.whatsapp.net",
      "AceptoTerminos": true,
      "aceptadoel": "2025-11-15T10:30:00Z",
      "created_at": "2025-11-10T08:00:00Z",
      "totalConsultas": 45,
      "ultimaConsulta": "2025-11-20T14:25:00Z"
    }
  ],
  "total": 127,
  "page": 1,
  "limit": 10
}
```

### Consultas Response

```json
{
  "consultas": [
    {
      "id": 1543,
      "tipo": "texto",
      "usuario ID": 23,
      "username": "549115555555",
      "resultado": "🍽️ **Alimentos detectados:** Empanada...",
      "Costo": 0.002,
      "created_at": "2025-11-20T14:25:00Z"
    }
  ],
  "total": 1543,
  "page": 1,
  "limit": 10
}
```

---

## 🔒 Paso 4: Seguridad (Producción)

### Opción A: Basic Auth en n8n

```env
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=secure_password
```

En el frontend (`api.js`):

```javascript
api.interceptors.request.use((config) => {
  config.auth = {
    username: import.meta.env.VITE_N8N_USER,
    password: import.meta.env.VITE_N8N_PASSWORD
  };
  return config;
});
```

### Opción B: API Key Custom

En cada webhook admin, valida una API key:

```javascript
// Nodo Code - Validar API Key
const apiKey = $json.headers['x-api-key'];
const validKey = 'your-secret-key-here';

if (apiKey !== validKey) {
  return {
    error: 'Unauthorized',
    status: 401
  };
}
```

---

## 📱 Paso 5: Testing

### Test 1: Verificar Webhook de Stats

```bash
curl http://localhost:5678/webhook/nutridiab/stats
```

**Respuesta esperada**: JSON con estadísticas

### Test 2: Desde el Frontend

```javascript
// En la consola del navegador (localhost:5173)
fetch('/webhook/nutridiab/stats')
  .then(r => r.json())
  .then(console.log);
```

### Test 3: Dashboard Completo

1. Inicia n8n: `docker-compose up -d`
2. Inicia frontend: `cd frontend && npm run dev`
3. Abre: http://localhost:5173/dashboard
4. Verifica que se carguen los datos

---

## 🎨 Paso 6: Personalizar el Dashboard

### Agregar Nuevos Datos

1. **Crear endpoint en n8n**:
   - Nuevo workflow con webhook
   - Query a Supabase
   - Respond con JSON

2. **Agregar función en `nutridiabApi.js`**:
```javascript
getNuevoDato: async () => {
  const response = await api.get('/webhook/nutridiab/nuevo-dato');
  return response.data;
}
```

3. **Usar en componente**:
```javascript
const [dato, setDato] = useState(null);

useEffect(() => {
  nutridiabApi.getNuevoDato()
    .then(setDato)
    .catch(console.error);
}, []);
```

---

## 🔄 Paso 7: Actualización en Tiempo Real (Opcional)

### Opción A: Polling

```javascript
// Actualizar cada 30 segundos
useEffect(() => {
  const interval = setInterval(() => {
    fetchDashboardData();
  }, 30000);

  return () => clearInterval(interval);
}, []);
```

### Opción B: WebSockets (Avanzado)

Requiere configurar un servidor WebSocket separado o usar Supabase Realtime.

---

## 📊 Queries SQL Útiles

### Usuarios más activos

```sql
SELECT 
  u.remoteJid,
  COUNT(c.id) as total_consultas,
  SUM(c."Costo") as costo_total,
  MAX(c.created_at) as ultima_consulta
FROM nutridiab.usuarios u
LEFT JOIN nutridiab."Consultas" c ON u."usuario ID" = c."usuario ID"
GROUP BY u."usuario ID", u.remoteJid
ORDER BY total_consultas DESC
LIMIT 10;
```

### Costos por día

```sql
SELECT 
  DATE(created_at) as fecha,
  tipo,
  COUNT(*) as cantidad,
  SUM("Costo") as costo
FROM nutridiab."Consultas"
WHERE created_at >= NOW() - INTERVAL '7 days'
GROUP BY DATE(created_at), tipo
ORDER BY fecha DESC, tipo;
```

### Tasa de conversión (términos aceptados)

```sql
SELECT 
  COUNT(*) as total_usuarios,
  SUM(CASE WHEN "AceptoTerminos" = true THEN 1 ELSE 0 END) as aceptaron,
  ROUND(
    (SUM(CASE WHEN "AceptoTerminos" = true THEN 1 ELSE 0 END)::numeric / COUNT(*)::numeric) * 100,
    2
  ) as porcentaje_aceptacion
FROM nutridiab.usuarios;
```

---

## 🐛 Troubleshooting

### Error: CORS

**Síntoma**: `Access to fetch blocked by CORS policy`

**Solución**: 
1. Verifica que el proxy de Vite esté configurado
2. O agrega headers CORS en n8n

### Error: 404 Not Found

**Síntoma**: `GET /webhook/nutridiab/stats 404`

**Solución**:
1. Verifica que el workflow esté **Active** en n8n
2. Verifica que el path del webhook sea correcto
3. Revisa los logs de n8n: `docker-compose logs -f`

### Error: Empty Response

**Síntoma**: Respuesta vacía `{}`

**Solución**:
1. Verifica que el nodo Supabase tenga datos
2. Revisa las ejecuciones en n8n (Executions tab)
3. Agrega logging en el nodo Code

---

## 🚀 Deploy a Producción

### 1. Variables de Entorno

```env
# .env.production
VITE_API_URL=https://tu-n8n-domain.com
VITE_APP_NAME=NutriDiab Admin
```

### 2. Build del Frontend

```bash
cd frontend
npm run build
```

### 3. Servir con Nginx

```nginx
server {
  listen 80;
  server_name admin.nutridiab.com;

  root /var/www/nutridiab/frontend/dist;
  index index.html;

  location / {
    try_files $uri $uri/ /index.html;
  }

  location /webhook/ {
    proxy_pass http://localhost:5678/webhook/;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
  }
}
```

---

## 📚 Recursos Adicionales

- [n8n API Documentation](https://docs.n8n.io/api/)
- [Supabase Documentation](https://supabase.com/docs)
- [React Query](https://tanstack.com/query/latest) (para caching de datos)
- [Chart.js](https://www.chartjs.org/) (para gráficos)

---

## ✅ Checklist de Integración

- [ ] Workflow de Stats creado y activo
- [ ] Workflow de Users creado y activo
- [ ] Workflow de Consultas creado y activo
- [ ] CORS configurado
- [ ] Frontend conectando correctamente
- [ ] Dashboard mostrando datos reales
- [ ] Seguridad implementada (API Key o Basic Auth)
- [ ] Tests realizados
- [ ] Documentación actualizada

---

**¡Tu sistema NutriDiab está listo para administrarse desde el navegador!** 🎉

