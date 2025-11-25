# 🔍 Diagnóstico: Usuarios No Aparecen (Workflow Funciona)

## 📋 Situación
- ✅ El workflow de n8n se ejecuta sin errores
- ❌ El frontend no muestra usuarios (Total: 0)

## 🔬 Diagnóstico Paso a Paso

### Paso 1: Probar el endpoint directamente

Ejecuta el script de prueba:

**Windows (PowerShell):**
```powershell
.\scripts\test_usuarios_api.ps1
```

Esto te mostrará:
- Si el endpoint responde
- Qué formato tiene la respuesta
- Cuántos usuarios devuelve
- La estructura de los datos

**Resultado esperado:**
```json
[
  {
    "id": 1,
    "nombre": "Juan",
    "apellido": "Pérez",
    "email": "juan@example.com",
    "status": "active",
    "role": "user",
    ...
  }
]
```

### Paso 2: Verificar la respuesta en n8n

1. Abre n8n: https://wf.zynaptic.tech
2. Ve al workflow **"Nutridiab - Admin Usuarios"**
3. Click en **"Execute Workflow"**
4. Verifica cada nodo:

**Nodo "Postgres Usuarios":**
- ¿Devuelve datos?
- ¿Cuántas filas?
- ¿Los nombres de columnas son correctos?

Debe mostrar algo como:
```json
{
  "usuario ID": 1,
  "nombre": "Juan",
  "apellido": "Pérez",
  "remoteJid": "5491123456789@s.whatsapp.net",
  "rol": "usuario",
  "Activo": true,
  ...
}
```

**Nodo "Transformar Datos":**
- ¿Convierte los datos correctamente?
- ¿Los campos tienen los nombres correctos?

Debe mostrar:
```json
{
  "id": 1,
  "nombre": "Juan",
  "apellido": "Pérez",
  "remotejid": "5491123456789@s.whatsapp.net",
  "status": "active",
  "role": "user",
  ...
}
```

**Nodo "Responder":**
- ¿Devuelve el array completo?
- ¿El formato es JSON válido?

### Paso 3: Usar la página de debug

He creado una página especial para debugging:

1. Abre: http://localhost:5173/users-debug
2. Verifica el panel de debug que muestra:
   - ✅ Raw API Response
   - ✅ Users array length
   - ✅ Total users
   - ✅ Loading state
   - ✅ Error messages

Esto te dirá exactamente qué está recibiendo el frontend.

### Paso 4: Revisar la consola del navegador

1. Presiona **F12** en el navegador
2. Ve a la pestaña **Console**
3. Busca mensajes que empiecen con:
   - 🔍 Fetching users...
   - 📦 Raw Response:
   - 📦 Response Type:
   - 📦 Is Array:
   - ✅ Response is array, length:
   - 👥 Final users data:

4. Ve a la pestaña **Network**
5. Busca la petición a `/webhook/nutridiab/admin/usuarios`
6. Click en ella y revisa:
   - **Headers** → Status Code (debe ser 200)
   - **Response** → Debe ser un array JSON
   - **Preview** → Vista estructurada de los datos

## 🔍 Problemas Comunes

### Problema 1: El endpoint devuelve un objeto vacío `{}`

**Causa:** El nodo "Postgres Usuarios" no devuelve datos

**Solución:**
1. Verifica que hay usuarios en la BD:
   ```sql
   SELECT COUNT(*) FROM nutridiab.usuarios;
   ```
2. Si no hay usuarios, crea algunos:
   ```bash
   psql -U dnzapata -d nutridiab -f database/crear_usuarios_prueba.sql
   ```

### Problema 2: El endpoint devuelve datos pero con nombres de columnas incorrectos

**Causa:** El nodo "Transformar Datos" no funciona correctamente

**Solución:**
1. Verifica que el nodo "Transformar Datos" existe en el workflow
2. Revisa el código JavaScript en ese nodo
3. Asegúrate de que está conectado entre "Postgres Usuarios" y "Responder"

### Problema 3: El endpoint devuelve un array pero los objetos tienen estructura diferente

**Causa:** El mapeo de campos está incorrecto

**Solución:**
Verifica que el código del nodo "Transformar Datos" tenga este formato:

```javascript
const usuarios = [];

for (const item of $input.all()) {
  const user = {
    id: item.json['usuario ID'],
    nombre: item.json.nombre || '',
    apellido: item.json.apellido || '',
    email: item.json.email || '',
    remotejid: item.json.remoteJid || '',
    status: item.json.Activo ? 'active' : 'inactive',
    verified: item.json.email_verificado || false,
    role: item.json.rol === 'administrador' ? 'admin' : 'user',
    // ... más campos
  };
  usuarios.push(user);
}

return usuarios.map(user => ({ json: user }));
```

### Problema 4: CORS Error

**Causa:** n8n no permite peticiones desde el frontend

**Solución:**
Configura n8n con:
```bash
N8N_CORS_ORIGIN=*
```

O específicamente:
```bash
N8N_CORS_ORIGIN=http://localhost:5173,https://tu-dominio.com
```

### Problema 5: El webhook no responde (404 Not Found)

**Causa:** El workflow no está activado

**Solución:**
1. Ve a n8n → Workflows → Nutridiab - Admin Usuarios
2. Asegúrate de que el **toggle esté activado** (arriba a la derecha)
3. Verifica que el webhook path sea: `/webhook/nutridiab/admin/usuarios`

### Problema 6: El frontend no hace la petición

**Causa:** Problema con la configuración de la API

**Solución:**
Verifica en `frontend/src/services/api.js`:
```javascript
const API_URL = isDevelopment 
  ? '' // Proxy de Vite
  : 'https://wf.zynaptic.tech';
```

Y en `frontend/vite.config.js`:
```javascript
server: {
  proxy: {
    '/webhook': {
      target: 'https://wf.zynaptic.tech',
      changeOrigin: true
    }
  }
}
```

## 📊 Checklist de Verificación

- [ ] El workflow está activado en n8n
- [ ] El workflow se ejecuta sin errores
- [ ] El nodo "Postgres Usuarios" devuelve datos
- [ ] El nodo "Transformar Datos" existe y está conectado
- [ ] Los nombres de campos están correctamente mapeados
- [ ] El endpoint responde con status 200
- [ ] La respuesta es un array JSON válido
- [ ] Cada objeto en el array tiene la estructura correcta
- [ ] No hay errores de CORS
- [ ] El frontend hace la petición correctamente
- [ ] La consola del navegador muestra los logs de debug

## 🎯 Próximos Pasos

1. **Ejecuta el script de prueba:**
   ```powershell
   .\scripts\test_usuarios_api.ps1
   ```

2. **Abre la página de debug:**
   ```
   http://localhost:5173/users-debug
   ```

3. **Revisa la consola del navegador (F12)**

4. **Comparte los resultados:**
   - ¿Qué muestra el script de prueba?
   - ¿Qué muestra la página de debug?
   - ¿Qué errores aparecen en la consola?

Con esta información podremos identificar exactamente dónde está el problema.


