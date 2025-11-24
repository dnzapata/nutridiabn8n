# 🚀 Instrucciones de Despliegue - Sistema de Autenticación

## Resumen de Cambios

Se ha implementado un sistema completo de autenticación con las siguientes características:

### ✅ Implementado:

1. **Base de Datos**
   - Sistema de autenticación con usuarios y contraseñas
   - Roles: Administrador y Usuario
   - Tabla de sesiones para tokens
   - Usuario administrador: `dnzapata` / `Fl100190`

2. **Frontend**
   - Página de Login profesional
   - Eliminada página Home (acceso directo al sistema)
   - Dashboard protegido (solo administradores)
   - Sistema de sesiones con AuthContext
   - Botón de logout en el navbar

3. **Backend (n8n)**
   - 4 workflows de autenticación
   - Login con validación de credenciales
   - Validación de sesiones
   - Logout
   - Verificación de roles

---

## 📝 Pasos de Instalación

### 1️⃣ Base de Datos (CRÍTICO - Hacer Primero)

```bash
# Conectar a PostgreSQL/Supabase
psql -h your-host -U postgres -d postgres

# O usando conexión directa
psql postgresql://postgres:password@your-host:5432/postgres

# Ejecutar migración
\i database/migration_add_auth_roles.sql
```

**Verificar que todo se instaló correctamente:**

```sql
-- Verificar que la tabla sesiones existe
SELECT * FROM information_schema.tables 
WHERE table_schema = 'nutridiab' 
AND table_name = 'sesiones';

-- Verificar que el usuario administrador existe
SELECT username, rol FROM nutridiab.usuarios 
WHERE username = 'dnzapata';

-- Debería mostrar:
-- username: dnzapata
-- rol: administrador
```

### 2️⃣ n8n Workflows

**Opción A: Interfaz Web (Recomendado)**

1. Acceder a: `https://wf.zynaptic.tech`
2. Click en "Workflows" → "Import from File"
3. Importar estos 4 archivos (UNO POR UNO):
   ```
   n8n/workflows/nutridiab-auth-login.json
   n8n/workflows/nutridiab-auth-validate.json
   n8n/workflows/nutridiab-auth-logout.json
   n8n/workflows/nutridiab-auth-check-admin.json
   ```
4. **IMPORTANTE:** Para cada workflow:
   - Abrir el workflow
   - Click en el nodo "PostgreSQL"
   - Verificar/configurar credenciales de la base de datos
   - Click en "Save"
   - Click en "Active" (arriba a la derecha) para activarlo

**Opción B: CLI de n8n**

```bash
# Si tienes acceso al servidor de n8n
cd /path/to/n8n

# Importar workflows
n8n import:workflow --input=n8n/workflows/nutridiab-auth-login.json
n8n import:workflow --input=n8n/workflows/nutridiab-auth-validate.json
n8n import:workflow --input=n8n/workflows/nutridiab-auth-logout.json
n8n import:workflow --input=n8n/workflows/nutridiab-auth-check-admin.json
```

### 3️⃣ Frontend

**No requiere cambios adicionales.** Los archivos ya están actualizados.

Solo asegúrate de tener las dependencias instaladas:

```bash
cd frontend

# Si es la primera vez
npm install

# Iniciar desarrollo
npm run dev

# Para producción
npm run build
```

---

## 🧪 Pruebas

### 1. Probar Login

1. Abrir: `http://localhost:5173` (o tu URL de producción)
2. Debe redirigir automáticamente a `/login`
3. Ingresar:
   - **Usuario:** `dnzapata`
   - **Contraseña:** `Fl100190`
4. Click en "Iniciar Sesión"
5. Debe redirigir al Dashboard

### 2. Verificar Permisos de Administrador

- El Dashboard debe ser visible
- En el navbar debe aparecer el badge "Admin" al lado del nombre
- Debe haber un botón "🚪 Salir" en el navbar

### 3. Probar Logout

1. Click en "🚪 Salir"
2. Debe redirigir al Login
3. Intentar acceder a `/dashboard` directamente
4. Debe redirigir nuevamente al Login

### 4. Probar Protección de Rutas

```bash
# Con el navegador, intentar acceder sin login:
http://localhost:5173/dashboard

# Debe redirigir al login
```

---

## 🔧 Configuración de Producción

### Variables de Entorno

Asegúrate de que estas variables estén configuradas:

**Backend (n8n):**
```env
POSTGRES_HOST=your-postgres-host
POSTGRES_PORT=5432
POSTGRES_DB=postgres
POSTGRES_USER=dnzapata
POSTGRES_PASSWORD=your-password
POSTGRES_SCHEMA=nutridiab
```

**Frontend:**
```env
VITE_API_URL=https://wf.zynaptic.tech
```

### Seguridad

1. **Cambiar contraseña del administrador:**

```sql
-- Primero, generar hash de nueva contraseña
-- Usar: node scripts/generate-password-hash.js "NuevaContraseña"

-- Luego actualizar en la base de datos
UPDATE nutridiab.usuarios 
SET password_hash = '$2b$10$...' -- Hash generado
WHERE username = 'dnzapata';
```

2. **Verificar HTTPS:**
   - En producción, asegurarse de usar HTTPS
   - Los tokens se envían en el cuerpo de las peticiones (no en headers)

3. **Configurar CORS en n8n:**
   - Permitir solo tu dominio frontend
   - En n8n settings → Security

---

## 📋 Checklist de Despliegue

Marca cada item al completarlo:

### Base de Datos
- [ ] Ejecutar `migration_add_auth_roles.sql`
- [ ] Verificar que tabla `sesiones` existe
- [ ] Verificar que usuario `dnzapata` existe con rol `administrador`
- [ ] Verificar que funciones SQL están creadas

### n8n
- [ ] Workflow `nutridiab-auth-login` importado y activo
- [ ] Workflow `nutridiab-auth-validate` importado y activo
- [ ] Workflow `nutridiab-auth-logout` importado y activo
- [ ] Workflow `nutridiab-auth-check-admin` importado y activo
- [ ] Credenciales de PostgreSQL configuradas en cada workflow
- [ ] Probar cada endpoint con Postman o curl

### Frontend
- [ ] Dependencias instaladas (`npm install`)
- [ ] Variables de entorno configuradas
- [ ] Build de producción exitoso (`npm run build`)
- [ ] Despliegue en servidor web

### Pruebas
- [ ] Login funciona con `dnzapata` / `Fl100190`
- [ ] Dashboard visible para administrador
- [ ] Logout funciona correctamente
- [ ] Rutas protegidas funcionan (redirigen al login)
- [ ] Usuario sin permisos no puede acceder al Dashboard

### Seguridad
- [ ] Cambiar contraseña de `dnzapata` en producción
- [ ] HTTPS configurado
- [ ] CORS configurado en n8n
- [ ] Tokens con expiración apropiada (7 días por defecto)

---

## 🐛 Solución de Problemas Comunes

### Error: "Usuario o contraseña incorrectos" (pero las credenciales son correctas)

**Causa:** La función de login en PostgreSQL usa `crypt()` para validar contraseñas.

**Solución:**
```sql
-- Verificar que la extensión pgcrypto está habilitada
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Verificar el hash de la contraseña
SELECT password_hash FROM nutridiab.usuarios WHERE username = 'dnzapata';

-- Debería ser: $2b$10$5K4/XjqvY7qzP1hZ.xGVl.8CZ9nQX1YH5oLBpSx0i6TxNJQHXQhyG
```

### Error: "Cannot read property 'rol' of null"

**Causa:** El usuario no está en el contexto de autenticación.

**Solución:**
1. Borrar localStorage del navegador
2. Volver a hacer login
3. Verificar que los workflows de n8n están activos

### Error: "Network Error" al intentar login

**Causa:** Frontend no puede conectar con n8n.

**Solución:**
1. Verificar que n8n está corriendo
2. Verificar la URL en `frontend/src/services/api.js`:
   ```javascript
   baseURL: 'https://wf.zynaptic.tech'
   ```
3. Verificar CORS en n8n

### Error: El Dashboard muestra pero no carga datos

**Causa:** El usuario no tiene rol de administrador.

**Solución:**
```sql
-- Verificar el rol del usuario
SELECT username, rol FROM nutridiab.usuarios WHERE username = 'dnzapata';

-- Si no es 'administrador', actualizar:
UPDATE nutridiab.usuarios 
SET rol = 'administrador' 
WHERE username = 'dnzapata';
```

---

## 📞 Contacto

Si tienes problemas durante el despliegue, verifica:

1. **Logs de PostgreSQL:** Para errores de base de datos
2. **Logs de n8n:** Para errores en workflows
3. **Console del navegador:** Para errores de frontend
4. **Network tab del navegador:** Para ver requests/responses

---

## 🎉 ¡Listo!

Una vez completado el checklist, el sistema de autenticación estará funcionando correctamente.

**Credenciales iniciales:**
- Usuario: `dnzapata`
- Contraseña: `Fl100190`

**⚠️ RECUERDA:** Cambiar la contraseña en producción por seguridad.

