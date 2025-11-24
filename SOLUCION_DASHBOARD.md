# Solución: Dashboard no carga datos

## 🔍 Problemas Identificados y Solucionados

### 1. ✅ Error de Funciones Faltantes
**Problema**: `nutridiabApi.getStats is not a function`

**Solución**: Se agregaron aliases en `nutridiabApi.js`:
```javascript
getStats: async () => {
  return nutridiabApi.getDashboardStats();
},

getRecentQueries: async (limit = 10) => {
  return nutridiabApi.getRecentActivity(limit);
}
```

### 2. ✅ Rutas Incorrectas
**Problema**: Las rutas del frontend no coincidían con las de n8n

**Antes**: `/webhook/nutridiab/stats`
**Ahora**: `/webhook/nutridiab/admin/stats`

**Solución**: Se actualizaron todas las rutas en `nutridiabApi.js` para incluir `/admin/`:
- `/webhook/nutridiab/admin/stats` - Estadísticas
- `/webhook/nutridiab/admin/usuarios` - Usuarios
- `/webhook/nutridiab/admin/consultas` - Consultas

### 3. ✅ Error CORS
**Problema**: Peticiones bloqueadas por CORS desde `localhost:5173`

**Solución**: Se configuró el proxy de Vite para usar rutas relativas en desarrollo:
```javascript
// En api.js
const isDevelopment = import.meta.env.DEV;
const API_URL = isDevelopment 
  ? '' // Usar proxy de Vite en desarrollo
  : (import.meta.env.VITE_API_URL || 'https://wf.zynaptic.tech');
```

## ⚠️ Pendiente: Configurar Workflows en n8n

### Error 500: Internal Server Error

El error 500 indica que los workflows de n8n **no están configurados o no están activos**.

### 📋 Pasos para Configurar n8n

#### 1. Verificar que n8n esté corriendo

```powershell
# En la raíz del proyecto
docker-compose ps
```

Deberías ver el servicio `n8n` corriendo.

#### 2. Acceder a n8n

Abre tu navegador y ve a: https://wf.zynaptic.tech

#### 3. Configurar Credenciales de PostgreSQL/Supabase

1. En n8n, ve a **Settings** → **Credentials**
2. Haz clic en **Add Credential**
3. Busca y selecciona **Postgres**
4. Rellena los datos de conexión a Supabase:

```
Host: aws-0-us-east-1.pooler.supabase.com
Port: 6543
Database: postgres
User: postgres.dnzapata
Password: [TU_PASSWORD_DE_SUPABASE]
SSL: Enabled
```

5. Guarda la credencial con el nombre: **Supabase - Nutridiab**

#### 4. Importar los Workflows

Para cada archivo en `n8n/workflows/`:

1. Ve a **Workflows** → **+ Add Workflow**
2. Click en el menú **⋮** (tres puntos) → **Import from File**
3. Selecciona el archivo:
   - `nutridiab-admin-stats.json`
   - `nutridiab-admin-usuarios.json`
   - `nutridiab-admin-consultas.json`

4. Después de importar cada workflow:
   - Abre el nodo **Postgres Stats/Usuarios/Consultas**
   - En **Credential to connect with**, selecciona **Supabase - Nutridiab**
   - Guarda el workflow
   - **¡IMPORTANTE!** Activa el workflow con el toggle en la esquina superior derecha

#### 5. Verificar que los Workflows estén Activos

Los workflows deben tener el estado **Active** (verde) para recibir peticiones.

### 🧪 Probar los Endpoints

Puedes probar los endpoints directamente desde el navegador o Postman:

#### Test de Estadísticas:
```
GET https://wf.zynaptic.tech/webhook/nutridiab/admin/stats
```

Debería devolver:
```json
{
  "total_usuarios": 10,
  "usuarios_activos": 8,
  "total_consultas": 150,
  "costo_total": 2.45,
  "consultas_hoy": 5,
  "usuarios_hoy": 1,
  "consultas_texto": 100,
  "consultas_imagen": 40,
  "consultas_audio": 10
}
```

#### Test de Consultas:
```
GET https://wf.zynaptic.tech/webhook/nutridiab/admin/consultas?limit=10
```

#### Test de Usuarios:
```
GET https://wf.zynaptic.tech/webhook/nutridiab/admin/usuarios
```

### 🔄 Reiniciar el Frontend

Una vez que los workflows estén activos, reinicia el servidor de desarrollo:

```powershell
# En la carpeta frontend/
npm run dev
```

Luego actualiza el navegador en http://localhost:5173/dashboard

## ✅ Checklist de Verificación

- [ ] n8n está corriendo (`docker-compose ps`)
- [ ] Credenciales de PostgreSQL configuradas en n8n
- [ ] Workflow `nutridiab-admin-stats` importado y activo
- [ ] Workflow `nutridiab-admin-usuarios` importado y activo
- [ ] Workflow `nutridiab-admin-consultas` importado y activo
- [ ] Los endpoints responden correctamente (sin error 500)
- [ ] Frontend reiniciado después de los cambios
- [ ] Dashboard carga sin errores

## 📝 Notas Adicionales

### Formato de Respuesta de n8n

Los workflows de n8n con **PostgreSQL** devuelven los datos en formato **array**, no como objeto directo:

**Ejemplo de respuesta de PostgreSQL en n8n**:
```json
[
  {
    "total_usuarios": 10,
    "total_consultas": 150,
    "costo_total": 2.45,
    ...
  }
]
```

El código de `Dashboard.jsx` ahora maneja automáticamente estos formatos:
- Si es un **array**, toma el primer elemento
- Si es un **objeto**, lo usa directamente o extrae las propiedades anidadas

### Desarrollo Local

En desarrollo (localhost:5173), el frontend usa el **proxy de Vite** para evitar problemas de CORS. Las peticiones se hacen a rutas relativas y Vite las redirige a `https://wf.zynaptic.tech`.

### Producción

En producción, el frontend usará la URL completa configurada en `VITE_API_URL`.

### Logs de n8n

Si los workflows siguen fallando, revisa los logs:

```powershell
docker-compose logs n8n
```

O ve a https://wf.zynaptic.tech/executions para ver el historial de ejecuciones y errores.

## 🆘 Solución de Problemas

### Si el dashboard muestra "Error al cargar el dashboard"

1. Abre la consola del navegador (F12)
2. Ve a la pestaña **Network**
3. Busca la petición a `/webhook/nutridiab/admin/stats`
4. Verifica el código de respuesta:
   - **500**: Los workflows no están configurados correctamente
   - **404**: Los workflows no existen o no están activos
   - **CORS error**: El proxy de Vite no está funcionando (reinicia el servidor)

### Si ves "Network Error" en la consola

1. Verifica que n8n esté corriendo: `docker-compose ps`
2. Verifica que puedas acceder a https://wf.zynaptic.tech
3. Reinicia el servicio de n8n: `docker-compose restart n8n`

### Si los workflows están activos pero retornan 500

1. Ve a https://wf.zynaptic.tech/executions
2. Busca la ejecución fallida
3. Revisa el error en el nodo de PostgreSQL
4. Verifica que las credenciales sean correctas
5. Verifica que el esquema `nutridiab` exista en la base de datos

## 📚 Recursos

- [Documentación de n8n](https://docs.n8n.io/)
- [Configuración de PostgreSQL en n8n](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.postgres/)
- [Configuración de Webhooks en n8n](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.webhook/)

