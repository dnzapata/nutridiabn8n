# ⚡ Solución Rápida: Usuarios no aparecen

## 🎯 Pasos Rápidos (5 minutos)

### 1️⃣ Agregar campos a la base de datos
```bash
psql -U dnzapata -d nutridiab -f database/agregar_campos_usuario_frontend.sql
```

### 2️⃣ Crear usuarios de prueba
```bash
psql -U dnzapata -d nutridiab -f database/crear_usuarios_prueba.sql
```

### 3️⃣ Importar workflow actualizado en n8n

1. Abre n8n: https://wf.zynaptic.tech
2. Ve a **Workflows**
3. Busca **"Nutridiab - Admin Usuarios"**
4. Si existe: Ábrelo y reemplaza con el contenido de `n8n/workflows/nutridiab-admin-usuarios.json`
5. Si NO existe: Click en **"+ Add workflow"** → **Import** → Selecciona el archivo JSON

### 4️⃣ Configurar credenciales en n8n

En el nodo **"Postgres Usuarios"**:
- Click en el nodo
- Selecciona tus credenciales de Postgres/Supabase
- Si no tienes, créalas con los datos de tu base de datos

### 5️⃣ Activar el workflow

- Asegúrate de que el toggle esté **ACTIVADO** (arriba a la derecha)
- Click en **"Save"**

### 6️⃣ Probar

Ejecuta el workflow manualmente en n8n para verificar que funciona:
- Click en **"Execute Workflow"**
- Verifica que devuelve datos en el nodo **"Transformar Datos"**

### 7️⃣ Verificar en el frontend

```bash
cd frontend
npm run dev
```

Abre: http://localhost:5173/users

## ✅ ¿Funcionó?

Deberías ver:
- ✅ Total de usuarios registrados: 7
- ✅ Lista con Juan, María, Carlos, Ana, Luis, Pedro y Admin
- ✅ Cada usuario con sus datos completos

## ❌ ¿Aún no funciona?

### Opción A: Verificar que hay usuarios
```bash
psql -U dnzapata -d nutridiab -f database/verificar_usuarios.sql
```

Si muestra 0 usuarios, ejecuta nuevamente el paso 2.

### Opción B: Probar el endpoint directamente
```bash
curl https://wf.zynaptic.tech/webhook/nutridiab/admin/usuarios
```

Debe devolver un JSON con usuarios. Si no:
- Verifica que el workflow esté **ACTIVADO**
- Revisa las credenciales de Postgres en n8n
- Mira los logs de ejecución en n8n → **Executions**

### Opción C: Revisar la consola del navegador

Presiona F12 en el navegador:
- Ve a la pestaña **Network**
- Busca la petición a `/webhook/nutridiab/admin/usuarios`
- Verifica el Status Code (debe ser 200)
- Revisa la Response (debe ser un array de usuarios)

## 📚 Documentación Completa

Para más detalles, consulta:
- `n8n/SOLUCIONAR_USUARIOS_NO_APARECEN.md` - Guía completa
- `database/verificar_usuarios.sql` - Script de verificación
- `database/crear_usuarios_prueba.sql` - Crear datos de prueba

## 🆘 Errores Comunes

**"column does not exist: edad"**
→ Ejecuta: `database/agregar_campos_usuario_frontend.sql`

**"column does not exist: rol"**
→ Ejecuta: `database/migration_add_auth_roles_SIMPLE.sql`

**"Total de usuarios registrados: 0"**
→ Ejecuta: `database/crear_usuarios_prueba.sql`

**"Network error"**
→ Verifica que el workflow esté activado en n8n

**"401 Unauthorized"**
→ Verifica que estás logueado como administrador

