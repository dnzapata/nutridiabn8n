# 🔧 Solución: Lista de Usuarios No Se Muestra

## 📋 Problema Identificado

El endpoint `/webhook/nutridiab/admin/usuarios` estaba devolviendo **un solo objeto de usuario** en lugar de **un array de usuarios**.

### Diagnóstico Realizado

✅ **Status del endpoint**: 200 OK (funcionando)  
✅ **Base de datos**: Conectada correctamente  
✅ **Workflow**: Activo en n8n  
❌ **Formato de respuesta**: Incorrecto

### Respuesta Actual (Incorrecta)
```json
{
  "id": 7,
  "nombre": "Daniel",
  "apellido": "Zapata",
  "email": "admin@nutridiab.com",
  ...
}
```

### Respuesta Esperada (Correcta)
```json
[
  {
    "id": 7,
    "nombre": "Daniel",
    "apellido": "Zapata",
    "email": "admin@nutridiab.com",
    ...
  },
  {
    "id": 2,
    "nombre": "María",
    "apellido": "López",
    ...
  }
]
```

## 🛠️ Solución Aplicada

### Cambio en el Workflow

**Archivo modificado**: `n8n/workflows/nutridiab-admin-usuarios.json`

**Nodo**: "Transformar Datos" (Code Node)

**Cambio realizado**:

#### ❌ Código Anterior (Incorrecto)
```javascript
return usuarios.map(user => ({ json: user }));
```

Este código devolvía múltiples items a n8n, pero el nodo "Responder" con `={{ $json }}` solo toma el primer item.

#### ✅ Código Nuevo (Correcto)
```javascript
// Retornar un solo objeto con el array de usuarios
// Esto permite que el nodo Responder devuelva el array completo
return [{ json: usuarios }];
```

Este código devuelve un solo item que contiene el array completo de usuarios.

## 📝 Pasos para Aplicar la Solución

### Opción 1: Re-importar el Workflow (Recomendado)

1. **Abre n8n**: https://wf.zynaptic.tech

2. **Busca el workflow actual**: "Nutridiab - Admin Usuarios"

3. **Desactívalo** (toggle en OFF)

4. **Borra el workflow antiguo** o renómbralo a "Nutridiab - Admin Usuarios (OLD)"

5. **Importa el workflow corregido**:
   - Click en el menú (tres puntos) → "Import from File"
   - Selecciona: `n8n/workflows/nutridiab-admin-usuarios.json`

6. **Configura las credenciales de PostgreSQL**:
   - Abre el nodo "Postgres Usuarios"
   - Selecciona tu credencial de Supabase
   - Guarda

7. **Activa el workflow** (toggle en ON)

8. **Verifica que funcione**:
   ```bash
   curl https://wf.zynaptic.tech/webhook/nutridiab/admin/usuarios
   ```

### Opción 2: Editar el Workflow Manualmente

1. **Abre el workflow** en n8n

2. **Abre el nodo "Transformar Datos"**

3. **Busca la última línea del código**:
   ```javascript
   return usuarios.map(user => ({ json: user }));
   ```

4. **Reemplázala por**:
   ```javascript
   // Retornar un solo objeto con el array de usuarios
   return [{ json: usuarios }];
   ```

5. **Guarda** el nodo (Save)

6. **Guarda** el workflow

7. **Prueba** el workflow:
   - Click en "Execute Workflow"
   - Verifica que devuelva un array

## ✅ Verificación

### 1. Probar el Endpoint Directamente

**Script de prueba**: `scripts/test_usuarios_endpoint.ps1`

```powershell
powershell -ExecutionPolicy Bypass -File scripts\test_usuarios_endpoint.ps1
```

**Resultado esperado**:
- Status Code: 200
- Respuesta es un array con N elementos

### 2. Probar desde el Frontend

1. **Inicia el frontend**:
   ```bash
   cd frontend
   npm run dev
   ```

2. **Abre el navegador**: http://localhost:5173

3. **Inicia sesión** como administrador:
   - Usuario: `admin@nutridiab.com`
   - Contraseña: (tu contraseña de administrador)

4. **Ve a la página de Usuarios**: Menú → Usuarios

5. **Verifica**:
   - ✅ Se muestra la lista de usuarios
   - ✅ Se muestra el contador: "Total de usuarios registrados: N"
   - ✅ La tabla muestra todos los usuarios

### 3. Probar con cURL

```bash
curl https://wf.zynaptic.tech/webhook/nutridiab/admin/usuarios
```

**Resultado esperado**: Array JSON con todos los usuarios

## 🔍 Debugging

Si después de aplicar la solución todavía no se muestran los usuarios:

### 1. Verifica el Workflow en n8n

- [ ] El workflow está **ACTIVO** (toggle verde)
- [ ] Las credenciales de PostgreSQL están configuradas
- [ ] El nodo "Transformar Datos" tiene el código correcto
- [ ] No hay errores en las últimas ejecuciones

### 2. Revisa la Consola del Navegador

```javascript
// Abre DevTools (F12) y ejecuta:
fetch('https://wf.zynaptic.tech/webhook/nutridiab/admin/usuarios')
  .then(r => r.json())
  .then(data => {
    console.log('Tipo:', Array.isArray(data) ? 'Array' : 'Object');
    console.log('Datos:', data);
  });
```

### 3. Usa la Página de Debug

Visita: http://localhost:5173/users-debug

Esta página muestra información detallada sobre la respuesta del API.

### 4. Revisa los Logs de n8n

```bash
docker-compose logs -f n8n
```

Busca errores en las ejecuciones del workflow.

## 📚 Archivos Relacionados

- ✅ `n8n/workflows/nutridiab-admin-usuarios.json` - Workflow corregido
- ✅ `scripts/test_usuarios_endpoint.ps1` - Script de prueba
- 📄 `frontend/src/pages/Users.jsx` - Componente de usuarios
- 📄 `frontend/src/pages/Users-debug.jsx` - Página de debug
- 📄 `frontend/src/services/nutridiabApi.js` - Servicio API

## 🎯 Resumen

**Problema**: El nodo "Responder" en n8n solo devolvía el primer usuario porque usaba `{{ $json }}` que toma el primer item cuando hay múltiples items.

**Solución**: Cambiar el código del nodo "Transformar Datos" para devolver un solo item que contenga el array completo de usuarios: `return [{ json: usuarios }];`

**Resultado**: El endpoint ahora devuelve correctamente un array con todos los usuarios, permitiendo que el frontend los muestre en la tabla.

---

**Fecha**: 25 de Noviembre de 2025  
**Estado**: ✅ Solución aplicada y documentada

