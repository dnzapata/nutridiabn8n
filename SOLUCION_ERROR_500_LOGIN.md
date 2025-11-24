# 🔧 Solución Error 500 en Login

## 🚨 Problema

```
POST http://localhost:5173/webhook/nutridiab/auth/login 500 (Internal Server Error)
```

## 🔍 Causa

El error 500 en el login puede tener 3 causas:

1. **La migración SQL no se ejecutó** → Las tablas/funciones no existen
2. **El workflow de n8n no está activo** → n8n no puede procesar la petición
3. **Error en la conexión a PostgreSQL** → n8n no puede conectar a la BD

---

## ✅ Solución Paso a Paso

### Paso 1: Verificar la Base de Datos

Conecta a PostgreSQL y ejecuta:

```bash
psql -h tu-host -U postgres -d postgres
```

Luego ejecuta el script de verificación:

```sql
\i VERIFICAR_INSTALACION.sql
```

**O ejecuta estas queries manualmente:**

```sql
-- ¿Existe la tabla sesiones?
SELECT * FROM information_schema.tables 
WHERE table_schema = 'nutridiab' AND table_name = 'sesiones';

-- ¿Existe el usuario dnzapata?
SELECT username, rol FROM nutridiab.usuarios WHERE username = 'dnzapata';

-- ¿Existe la función de login?
SELECT routine_name FROM information_schema.routines 
WHERE routine_schema = 'nutridiab' AND routine_name = 'login_usuario';
```

**Si alguna query no devuelve resultados:**

```bash
# Ejecutar la migración
\i database/migration_add_auth_roles.sql
```

---

### Paso 2: Verificar n8n

#### A. Verificar que n8n está corriendo

Abre tu navegador y ve a: `https://wf.zynaptic.tech`

¿Se abre? 
- ✅ **Sí** → Continúa al paso B
- ❌ **No** → Inicia n8n primero

#### B. Importar los workflows

1. En n8n, click en "Workflows" (menú izquierdo)
2. Click en "Import from File"
3. Importa estos 4 archivos (UNO POR UNO):
   - `n8n/workflows/nutridiab-auth-login.json`
   - `n8n/workflows/nutridiab-auth-validate.json`
   - `n8n/workflows/nutridiab-auth-logout.json`
   - `n8n/workflows/nutridiab-auth-check-admin.json`

#### C. Activar el workflow de login

1. Abre el workflow "NutriDiab - Auth - Login"
2. Click en el nodo "PostgreSQL - Login"
3. **IMPORTANTE:** Configura las credenciales de PostgreSQL:
   - Host: Tu host de PostgreSQL
   - Database: `postgres`
   - User: `dnzapata`
   - Password: Tu password
   - Port: `5432`
   - Schema: `nutridiab`
4. Click en "Test" para probar la conexión
5. Click en "Save" (arriba a la derecha)
6. **Activa el workflow:** Toggle "Active" (arriba a la derecha)

---

### Paso 3: Probar el Endpoint Directamente

Usa curl o Postman para probar el endpoint directamente:

```bash
curl -X POST https://wf.zynaptic.tech/webhook/nutridiab/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "dnzapata",
    "password": "Fl100190"
  }'
```

**Respuesta esperada (éxito):**

```json
{
  "success": true,
  "user_id": 1,
  "username": "dnzapata",
  "nombre": "David",
  "apellido": "Zapata",
  "email": "admin@nutridiab.com",
  "rol": "administrador",
  "token": "abc123...",
  "message": "Login exitoso"
}
```

**Si recibes error:**

Revisa los logs de n8n:
1. En n8n, ve a "Executions" (menú izquierdo)
2. Busca la ejecución más reciente del workflow "NutriDiab - Auth - Login"
3. Click en ella para ver los detalles del error

---

## 🐛 Errores Comunes

### Error: "function nutridiab.login_usuario does not exist"

**Causa:** La migración SQL no se ejecutó.

**Solución:**
```bash
psql -h host -U postgres -d postgres
\i database/migration_add_auth_roles.sql
```

---

### Error: "relation nutridiab.sesiones does not exist"

**Causa:** La tabla sesiones no fue creada.

**Solución:**
```bash
psql -h host -U postgres -d postgres
\i database/migration_add_auth_roles.sql
```

---

### Error: "Workflow not found"

**Causa:** El workflow no está importado o activo en n8n.

**Solución:**
1. Ir a n8n
2. Importar `n8n/workflows/nutridiab-auth-login.json`
3. Activar el workflow

---

### Error: "permission denied for schema nutridiab"

**Causa:** El usuario de PostgreSQL no tiene permisos.

**Solución:**
```sql
-- Dar permisos al usuario
GRANT USAGE ON SCHEMA nutridiab TO dnzapata;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA nutridiab TO dnzapata;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA nutridiab TO dnzapata;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA nutridiab TO dnzapata;
```

---

### Error: "crypt: invalid salt"

**Causa:** La extensión pgcrypto no está instalada o el hash de contraseña está mal.

**Solución:**
```sql
-- Instalar extensión
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Verificar el hash del usuario
SELECT username, password_hash FROM nutridiab.usuarios WHERE username = 'dnzapata';

-- El hash debe empezar con $2b$10$
-- Si no es así, regenerar:
UPDATE nutridiab.usuarios 
SET password_hash = '$2b$10$5K4/XjqvY7qzP1hZ.xGVl.8CZ9nQX1YH5oLBpSx0i6TxNJQHXQhyG'
WHERE username = 'dnzapata';
```

---

## 🔧 Fix Rápido (Si tienes prisa)

Si ya ejecutaste la migración SQL pero no funciona, intenta esto:

### 1. Verificar credenciales en n8n

```sql
-- En PostgreSQL, verifica que el usuario existe
SELECT username, rol FROM nutridiab.usuarios WHERE username = 'dnzapata';
```

### 2. Re-ejecutar la migración (safe)

```sql
-- Esto es seguro, usa ON CONFLICT para no duplicar
\i database/migration_add_auth_roles.sql
```

### 3. Reiniciar n8n

```bash
# Si estás usando Docker
docker restart n8n

# O reinicia el servicio
systemctl restart n8n
```

### 4. Verificar el proxy de Vite

Abre `frontend/vite.config.js` y verifica:

```javascript
proxy: {
  '/webhook': {
    target: 'https://wf.zynaptic.tech', // ← Tu URL de n8n
    changeOrigin: true,
    secure: true,
  }
}
```

### 5. Reiniciar el frontend

```bash
# Detener el servidor (Ctrl+C)
# Luego reiniciar
cd frontend
npm run dev
```

---

## 📋 Checklist de Verificación

Marca cada item:

- [ ] ✅ Ejecuté `migration_add_auth_roles.sql` en PostgreSQL
- [ ] ✅ La tabla `sesiones` existe (`SELECT * FROM nutridiab.sesiones;`)
- [ ] ✅ El usuario `dnzapata` existe con rol `administrador`
- [ ] ✅ La función `login_usuario` existe
- [ ] ✅ n8n está corriendo (`https://wf.zynaptic.tech`)
- [ ] ✅ Importé el workflow `nutridiab-auth-login.json` en n8n
- [ ] ✅ El workflow está **ACTIVO** (toggle verde)
- [ ] ✅ Las credenciales de PostgreSQL están configuradas en el workflow
- [ ] ✅ Probé el endpoint con curl y funciona
- [ ] ✅ El frontend está corriendo (`http://localhost:5173`)

---

## 🎯 Prueba Final

Si todo está correcto:

1. Abre: `http://localhost:5173`
2. Debe mostrar la página de login
3. Ingresa:
   - Usuario: `dnzapata`
   - Contraseña: `Fl100190`
4. Click en "Iniciar Sesión"
5. **Debe redirigir al Dashboard** ✅

---

## 📞 ¿Sigue sin funcionar?

Si después de seguir todos estos pasos sigue el error:

1. **Revisa los logs de n8n:**
   - Ve a "Executions" en n8n
   - Encuentra la ejecución del workflow de login
   - Lee el mensaje de error completo

2. **Revisa los logs de PostgreSQL:**
   ```bash
   # Ver últimos logs
   tail -f /var/log/postgresql/postgresql-*.log
   ```

3. **Revisa la consola del navegador:**
   - Abre DevTools (F12)
   - Ve a la pestaña "Network"
   - Intenta el login
   - Click en la petición "login"
   - Ve a "Response" para ver el error exacto

4. **Verifica la URL:**
   - En `vite.config.js` → ¿La URL de n8n es correcta?
   - ¿n8n está en HTTPS o HTTP?
   - ¿Hay firewall bloqueando la conexión?

---

## 🚀 Una vez solucionado

Cuando el login funcione:

1. ✅ Cambiar la contraseña en producción
2. ✅ Configurar HTTPS si no está configurado
3. ✅ Configurar CORS en n8n si es necesario
4. ✅ Hacer backup de la base de datos

---

**¡Suerte! 🍀**

