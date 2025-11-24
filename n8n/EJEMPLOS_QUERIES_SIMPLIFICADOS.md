# 📝 Ejemplos de Queries Simplificados para n8n

Después de configurar el schema por defecto, puedes usar queries más limpios en n8n.

---

## ⚙️ Prerequisito

Ejecutar primero:
```bash
psql -U postgres -d nutridiab -f database/configurar_schema_usuario.sql
```

---

## 🔐 Workflow: Login

### ❌ Antes (con schema explícito)

```sql
SELECT * FROM nutridiab.login_usuario(
  '{{ $json.username }}',
  '{{ $json.password }}',
  '{{ $json.ip }}',
  '{{ $json.userAgent }}'
)
```

### ✅ Después (simplificado)

```sql
SELECT * FROM login_usuario(
  '{{ $json.username }}',
  '{{ $json.password }}',
  '{{ $json.ip }}',
  '{{ $json.userAgent }}'
)
```

---

## 🔍 Workflow: Validar Sesión

### ❌ Antes

```sql
SELECT 
  valida,
  usuario_id,
  username,
  rol,
  expiro
FROM nutridiab.validar_sesion('{{ $json.token }}')
```

### ✅ Después

```sql
SELECT 
  valida,
  usuario_id,
  username,
  rol,
  expiro
FROM validar_sesion('{{ $json.token }}')
```

---

## 🚪 Workflow: Logout

### ❌ Antes

```sql
SELECT nutridiab.logout_usuario('{{ $json.token }}') AS success
```

### ✅ Después

```sql
SELECT logout_usuario('{{ $json.token }}') AS success
```

---

## 👥 Workflow: Listar Usuarios

### ❌ Antes

```sql
SELECT 
  "usuario ID",
  username,
  nombre,
  apellido,
  email,
  rol,
  "Activo",
  "ultimo_login"
FROM nutridiab.usuarios
WHERE "Activo" = TRUE
ORDER BY "ultimo_login" DESC
```

### ✅ Después

```sql
SELECT 
  "usuario ID",
  username,
  nombre,
  apellido,
  email,
  rol,
  "Activo",
  "ultimo_login"
FROM usuarios
WHERE "Activo" = TRUE
ORDER BY "ultimo_login" DESC
```

---

## 📊 Workflow: Estadísticas de Usuarios

### ❌ Antes

```sql
SELECT 
  COUNT(*) FILTER (WHERE "Activo" = TRUE) as activos,
  COUNT(*) FILTER (WHERE "Activo" = FALSE) as inactivos,
  COUNT(*) FILTER (WHERE "Bloqueado" = TRUE) as bloqueados,
  COUNT(DISTINCT rol) as roles
FROM nutridiab.usuarios
```

### ✅ Después

```sql
SELECT 
  COUNT(*) FILTER (WHERE "Activo" = TRUE) as activos,
  COUNT(*) FILTER (WHERE "Activo" = FALSE) as inactivos,
  COUNT(*) FILTER (WHERE "Bloqueado" = TRUE) as bloqueados,
  COUNT(DISTINCT rol) as roles
FROM usuarios
```

---

## 🔑 Workflow: Verificar Administrador

### ❌ Antes

```sql
SELECT nutridiab.es_administrador('{{ $json.token }}') AS es_admin
```

### ✅ Después

```sql
SELECT es_administrador('{{ $json.token }}') AS es_admin
```

---

## 📝 Workflow: Crear Usuario

### ❌ Antes

```sql
INSERT INTO nutridiab.usuarios (
  "remoteJid",
  username,
  password_hash,
  nombre,
  apellido,
  email,
  rol,
  "Activo"
)
VALUES (
  '{{ $json.remoteJid }}',
  '{{ $json.username }}',
  '{{ $json.password_hash }}',
  '{{ $json.nombre }}',
  '{{ $json.apellido }}',
  '{{ $json.email }}',
  '{{ $json.rol || 'usuario' }}',
  TRUE
)
RETURNING "usuario ID", username, email
```

### ✅ Después

```sql
INSERT INTO usuarios (
  "remoteJid",
  username,
  password_hash,
  nombre,
  apellido,
  email,
  rol,
  "Activo"
)
VALUES (
  '{{ $json.remoteJid }}',
  '{{ $json.username }}',
  '{{ $json.password_hash }}',
  '{{ $json.nombre }}',
  '{{ $json.apellido }}',
  '{{ $json.email }}',
  '{{ $json.rol || 'usuario' }}',
  TRUE
)
RETURNING "usuario ID", username, email
```

---

## 🔄 Workflow: Actualizar Usuario

### ❌ Antes

```sql
UPDATE nutridiab.usuarios
SET 
  nombre = '{{ $json.nombre }}',
  apellido = '{{ $json.apellido }}',
  email = '{{ $json.email }}',
  "ultimo_acceso" = NOW()
WHERE "usuario ID" = {{ $json.userId }}
RETURNING *
```

### ✅ Después

```sql
UPDATE usuarios
SET 
  nombre = '{{ $json.nombre }}',
  apellido = '{{ $json.apellido }}',
  email = '{{ $json.email }}',
  "ultimo_acceso" = NOW()
WHERE "usuario ID" = {{ $json.userId }}
RETURNING *
```

---

## 🗑️ Workflow: Limpiar Sesiones Expiradas

### ❌ Antes

```sql
SELECT nutridiab.limpiar_sesiones_expiradas() AS sesiones_eliminadas
```

### ✅ Después

```sql
SELECT limpiar_sesiones_expiradas() AS sesiones_eliminadas
```

---

## 📈 Workflow: Sesiones Activas

### ❌ Antes

```sql
SELECT 
  s.token,
  s.usuario_id,
  u.username,
  u.nombre,
  u.apellido,
  s.ip_address,
  s.created_at,
  s.expira
FROM nutridiab.sesiones s
JOIN nutridiab.usuarios u ON s.usuario_id = u."usuario ID"
WHERE s.activa = TRUE 
  AND s.expira > NOW()
ORDER BY s.created_at DESC
```

### ✅ Después

```sql
SELECT 
  s.token,
  s.usuario_id,
  u.username,
  u.nombre,
  u.apellido,
  s.ip_address,
  s.created_at,
  s.expira
FROM sesiones s
JOIN usuarios u ON s.usuario_id = u."usuario ID"
WHERE s.activa = TRUE 
  AND s.expira > NOW()
ORDER BY s.created_at DESC
```

---

## 🧹 Workflow: Eliminar Usuario (Soft Delete)

### ❌ Antes

```sql
UPDATE nutridiab.usuarios
SET 
  "Activo" = FALSE,
  "ultimo_acceso" = NOW()
WHERE "usuario ID" = {{ $json.userId }}
RETURNING username, email
```

### ✅ Después

```sql
UPDATE usuarios
SET 
  "Activo" = FALSE,
  "ultimo_acceso" = NOW()
WHERE "usuario ID" = {{ $json.userId }}
RETURNING username, email
```

---

## 📊 Comparación de líneas de código

| Workflow | Antes (líneas) | Después (líneas) | Ahorro |
|----------|----------------|------------------|--------|
| Login | 6 | 5 | 17% |
| Validar sesión | 8 | 7 | 13% |
| Listar usuarios | 12 | 11 | 8% |
| **Total promedio** | - | - | **~13%** |

---

## 💡 Beneficios adicionales

### 1. Menos errores de tipeo
```sql
-- Es más fácil escribir:
FROM usuarios

-- Que:
FROM nutridiab.usuarios  ← Podrías olvidar "nutridiab"
```

### 2. Más portable
```sql
-- Si cambias el nombre del schema, solo modificas 1 lugar:
ALTER ROLE dnzapata SET search_path TO nuevo_schema, public;

-- En lugar de buscar/reemplazar en 50+ queries
```

### 3. Código más limpio
```sql
-- Más fácil de leer:
SELECT * FROM login_usuario(...)

-- Que:
SELECT * FROM nutridiab.login_usuario(...)
```

---

## 🎯 Checklist de migración

Para actualizar tus workflows existentes:

- [ ] Ejecutar `configurar_schema_usuario.sql`
- [ ] Reiniciar n8n
- [ ] Workflow: `nutridiab-auth-login` → Quitar `nutridiab.`
- [ ] Workflow: `nutridiab-auth-validate` → Quitar `nutridiab.`
- [ ] Workflow: `nutridiab-auth-logout` → Quitar `nutridiab.`
- [ ] Workflow: `nutridiab-auth-check-admin` → Quitar `nutridiab.`
- [ ] Workflow: `nutridiab-admin-usuarios` → Quitar `nutridiab.`
- [ ] Workflow: `nutridiab-admin-stats` → Quitar `nutridiab.`
- [ ] Workflow: `nutridiab-admin-consultas` → Quitar `nutridiab.`
- [ ] Probar cada workflow actualizado
- [ ] Documentar el cambio

---

## 🔍 Verificación en n8n

Después de configurar el schema, prueba esto en un nodo Postgres:

```sql
-- Test 1: Verificar search_path
SHOW search_path;
-- Debe devolver: nutridiab, public

-- Test 2: Query simple
SELECT COUNT(*) FROM usuarios;
-- Debe funcionar sin error

-- Test 3: Función
SELECT * FROM login_usuario('dnzapata', 'Fl100190');
-- Debe devolver success = true
```

---

## ⚠️ Troubleshooting

### Error: "relation usuarios does not exist"

**Solución:**
1. Verificar que ejecutaste `configurar_schema_usuario.sql`
2. Reiniciar n8n: `docker restart n8n`
3. Verificar en n8n: `SHOW search_path;`

### Error: "function login_usuario does not exist"

**Solución:**
1. Verificar que la función existe: 
   ```sql
   SELECT routine_name FROM information_schema.routines 
   WHERE routine_name = 'login_usuario';
   ```
2. Si no existe, ejecutar: `migration_add_auth_roles_SIMPLE.sql`

### n8n sigue pidiendo el schema

**Solución:**
- Asegúrate de usar el usuario `dnzapata` en las credenciales
- Si usas otro usuario, aplica la configuración a ese usuario:
  ```sql
  ALTER ROLE tu_usuario SET search_path TO nutridiab, public;
  ```

---

## 📚 Referencias

- [Documentación completa](CONFIGURAR_SCHEMA_POSTGRES.md)
- [Script de configuración](../database/configurar_schema_usuario.sql)
- [PostgreSQL search_path docs](https://www.postgresql.org/docs/current/ddl-schemas.html#DDL-SCHEMAS-PATH)

---

✨ **Ahora tus workflows de n8n son más limpios y fáciles de mantener!**

