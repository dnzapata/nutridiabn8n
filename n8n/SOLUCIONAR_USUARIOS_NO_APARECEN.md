# 🔧 Solución: No se muestran usuarios en el frontend

## 📋 Problema
La página de usuarios carga correctamente pero muestra "Total de usuarios registrados: 0" y "No hay usuarios registrados".

## 🔍 Causa
El workflow de n8n no está configurado correctamente o:
1. No está importado en n8n
2. No está activado
3. La consulta SQL tiene errores
4. No hay usuarios en la base de datos
5. Los campos de la base de datos no existen

## ✅ Solución Paso a Paso

### Paso 1: Verificar usuarios en la base de datos

Ejecuta este script para ver si hay usuarios:

```bash
psql -U dnzapata -d nutridiab -f database/verificar_usuarios.sql
```

**Resultado esperado:**
```
 total_usuarios 
----------------
              5
```

Si muestra **0 usuarios**, entonces no hay usuarios en la base de datos. Necesitarás crear usuarios de prueba o esperar a que se registren usuarios reales.

### Paso 2: Agregar campos faltantes

Ejecuta este script para agregar los campos necesarios:

```bash
psql -U dnzapata -d nutridiab -f database/agregar_campos_usuario_frontend.sql
```

**Campos que se agregan:**
- `edad` (INTEGER)
- `peso` (DECIMAL)
- `altura` (DECIMAL)
- `objetivos` (TEXT)
- `restricciones` (TEXT)

### Paso 3: Verificar que el campo `rol` existe

Si no tienes el campo `rol` en tu tabla de usuarios, ejecuta:

```bash
psql -U dnzapata -d nutridiab -f database/migration_add_auth_roles_SIMPLE.sql
```

**NOTA:** Solo ejecuta esto si no has creado el sistema de autenticación todavía.

### Paso 4: Importar el workflow actualizado en n8n

1. Accede a n8n: `https://wf.zynaptic.tech`
2. Ve a **Workflows**
3. Busca el workflow **"Nutridiab - Admin Usuarios"**
4. Si no existe:
   - Click en **"+ Add workflow"**
   - Click en el menú "⋯" → **Import from file**
   - Selecciona: `n8n/workflows/nutridiab-admin-usuarios.json`
5. Si ya existe:
   - Ábrelo
   - Reemplaza el contenido con el archivo actualizado

### Paso 5: Configurar credenciales en n8n

En el nodo **"Postgres Usuarios"**:

1. Click en el nodo
2. En **Credentials**, selecciona tus credenciales de Postgres/Supabase
3. Si no tienes credenciales configuradas:
   - Click en **"Create New"**
   - Nombre: `Supabase - Nutridiab`
   - Host: `tu-proyecto.supabase.co`
   - Database: `postgres`
   - User: `dnzapata` (o tu usuario)
   - Password: tu contraseña
   - Port: `5432`
   - SSL: `allow` o `require`

### Paso 6: Probar el workflow en n8n

1. Abre el workflow **"Nutridiab - Admin Usuarios"**
2. Click en **"Execute Workflow"** en la esquina superior derecha
3. Verifica que el nodo **"Postgres Usuarios"** devuelve datos
4. Verifica que el nodo **"Transformar Datos"** muestra los datos transformados
5. Revisa que los campos tienen el formato correcto:
   ```json
   {
     "id": 1,
     "nombre": "Juan",
     "apellido": "Pérez",
     "email": "juan@example.com",
     "remotejid": "5491123456789@s.whatsapp.net",
     "status": "active",
     "verified": true,
     "role": "user",
     "created_at": "2024-01-15T10:30:00Z"
   }
   ```

### Paso 7: Activar el workflow

1. En el workflow, asegúrate de que está **ACTIVADO** (toggle en la parte superior)
2. El webhook debe estar activo en: `/webhook/nutridiab/admin/usuarios`

### Paso 8: Verificar la URL del webhook

El workflow debe responder en:
```
GET https://wf.zynaptic.tech/webhook/nutridiab/admin/usuarios
```

Puedes probarlo con curl:
```bash
curl -X GET https://wf.zynaptic.tech/webhook/nutridiab/admin/usuarios
```

**Respuesta esperada:**
```json
[
  {
    "id": 1,
    "nombre": "Juan",
    "apellido": "Pérez",
    "email": "juan@example.com",
    ...
  }
]
```

### Paso 9: Verificar configuración del frontend

El frontend debe estar configurado para usar la URL correcta de n8n.

Verifica en `frontend/.env`:
```env
VITE_API_URL=https://wf.zynaptic.tech
```

O en `frontend/vite.config.js`:
```javascript
export default defineConfig({
  server: {
    proxy: {
      '/webhook': {
        target: 'https://wf.zynaptic.tech',
        changeOrigin: true
      }
    }
  }
})
```

### Paso 10: Reiniciar el frontend

```bash
cd frontend
npm run dev
```

Luego accede a: `http://localhost:5173/users`

## 🧪 Crear usuarios de prueba

Si no tienes usuarios en la base de datos, crea algunos de prueba:

```sql
-- Usuario de prueba 1
INSERT INTO nutridiab.usuarios (
  "remoteJid",
  nombre,
  apellido,
  email,
  edad,
  peso,
  altura,
  tipo_diabetes,
  "Activo",
  email_verificado,
  datos_completos,
  rol
) VALUES (
  '5491123456789@s.whatsapp.net',
  'Juan',
  'Pérez',
  'juan@example.com',
  35,
  75.5,
  175,
  'tipo2',
  true,
  true,
  true,
  'usuario'
);

-- Usuario de prueba 2
INSERT INTO nutridiab.usuarios (
  "remoteJid",
  nombre,
  apellido,
  email,
  edad,
  peso,
  altura,
  tipo_diabetes,
  "Activo",
  email_verificado,
  datos_completos,
  rol
) VALUES (
  '5491123456790@s.whatsapp.net',
  'María',
  'González',
  'maria@example.com',
  28,
  62.0,
  165,
  'tipo1',
  true,
  true,
  true,
  'usuario'
);

-- Usuario administrador de prueba
INSERT INTO nutridiab.usuarios (
  "remoteJid",
  nombre,
  apellido,
  email,
  tipo_diabetes,
  "Activo",
  email_verificado,
  datos_completos,
  rol
) VALUES (
  'admin@system',
  'Admin',
  'Sistema',
  'admin@nutridiab.com',
  'tipo2',
  true,
  true,
  true,
  'administrador'
);
```

## 🔍 Debugging

### Ver logs de n8n

1. En n8n, ve a **Executions**
2. Busca la ejecución del workflow **"Nutridiab - Admin Usuarios"**
3. Revisa cada nodo para ver si hay errores

### Errores comunes

#### Error: "column does not exist"
**Solución:** Ejecuta `database/agregar_campos_usuario_frontend.sql`

#### Error: "permission denied"
**Solución:** Verifica que el usuario de la base de datos tiene permisos:
```sql
GRANT SELECT ON nutridiab.usuarios TO dnzapata;
GRANT SELECT ON nutridiab."Consultas" TO dnzapata;
```

#### Error: "workflow not found"
**Solución:** Importa el workflow nuevamente desde el archivo JSON

#### Error de CORS
**Solución:** Verifica que n8n esté configurado para aceptar requests desde tu frontend:
```bash
N8N_CORS_ORIGIN=*
```

### Ver respuesta de la API en el navegador

Abre la consola del navegador (F12) y ve a la pestaña **Network**. Busca la petición a `/webhook/nutridiab/admin/usuarios` y revisa:

1. **Status Code:** Debe ser `200 OK`
2. **Response:** Debe ser un array de usuarios en formato JSON
3. **Headers:** Debe tener `Content-Type: application/json`

## ✅ Checklist Final

- [ ] Usuarios existen en la base de datos
- [ ] Campos `edad`, `peso`, `altura`, `objetivos`, `restricciones` existen
- [ ] Campo `rol` existe en la tabla
- [ ] Workflow importado en n8n
- [ ] Credenciales de Postgres configuradas
- [ ] Workflow activado
- [ ] Webhook responde en `/webhook/nutridiab/admin/usuarios`
- [ ] Frontend configurado con la URL correcta
- [ ] Logs de n8n no muestran errores
- [ ] Respuesta de la API tiene el formato correcto

## 🎯 Resultado Esperado

Después de seguir todos los pasos, deberías ver:

1. **En n8n:** El workflow se ejecuta sin errores y devuelve un array de usuarios
2. **En el navegador:** La página `/users` muestra la lista de usuarios con todos sus datos
3. **En la consola:** No hay errores de red ni de transformación de datos

---

Si después de seguir todos los pasos aún no funciona, revisa:
1. Los logs de n8n
2. La consola del navegador
3. Que el workflow esté realmente **ACTIVADO** (no solo guardado)
4. Que las credenciales de la base de datos sean correctas

