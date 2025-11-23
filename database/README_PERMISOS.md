# 🔐 Configuración de Permisos - Usuario dnzapata

## 📋 Resumen

Este documento explica cómo configurar correctamente los permisos del usuario `dnzapata` para acceder a la base de datos Nutridiab desde n8n.

## 🎯 Usuario Configurado

- **Usuario**: `dnzapata`
- **Schema**: `nutridiab`
- **Base de datos**: `postgres` (Supabase)

## 🚀 Pasos de Instalación

### 1. Crear el usuario (si no existe)

Si el usuario `dnzapata` no existe en tu base de datos, créalo primero:

```sql
-- Conectarse como superusuario (postgres)
CREATE USER dnzapata WITH PASSWORD 'tu_password_seguro';
```

### 2. Aplicar el schema completo

Si es una instalación nueva, ejecuta:

```bash
# En tu cliente SQL o psql
psql -U postgres -d postgres -f database/schema_nutridiab_complete.sql
```

Este script:
- ✅ Crea el schema `nutridiab`
- ✅ Crea todas las tablas
- ✅ Crea funciones y triggers
- ✅ Configura permisos para `dnzapata`
- ✅ Establece `dnzapata` como owner

### 3. Actualizar permisos (si ya tienes la BD creada)

Si ya tienes la base de datos y solo necesitas actualizar permisos:

```bash
psql -U postgres -d postgres -f database/update_permissions_dnzapata.sql
```

## 🔍 Verificación de Permisos

### Verificar que el usuario existe:

```sql
SELECT usename, usecreatedb, usesuper 
FROM pg_user 
WHERE usename = 'dnzapata';
```

### Verificar permisos sobre tablas:

```sql
SELECT 
    schemaname,
    tablename,
    tableowner,
    has_table_privilege('dnzapata', schemaname||'.'||tablename, 'SELECT') as puede_select,
    has_table_privilege('dnzapata', schemaname||'.'||tablename, 'INSERT') as puede_insert,
    has_table_privilege('dnzapata', schemaname||'.'||tablename, 'UPDATE') as puede_update,
    has_table_privilege('dnzapata', schemaname||'.'||tablename, 'DELETE') as puede_delete
FROM pg_tables
WHERE schemaname = 'nutridiab'
ORDER BY tablename;
```

**Resultado esperado**: Todas las columnas deben mostrar `true` ✅

### Verificar ownership:

```sql
-- Schema owner
SELECT schema_name, schema_owner 
FROM information_schema.schemata 
WHERE schema_name = 'nutridiab';

-- Debe mostrar: schema_owner = 'dnzapata' ✅
```

### Verificar permisos sobre funciones:

```sql
SELECT 
    routine_name,
    routine_type,
    routine_schema
FROM information_schema.routines
WHERE routine_schema = 'nutridiab'
ORDER BY routine_name;
```

## ⚙️ Configuración en n8n

### Credenciales PostgreSQL

En n8n, crea una nueva credencial PostgreSQL con estos datos:

```
Host: db.xxxxx.supabase.co
Port: 5432
Database: postgres
User: dnzapata
Password: [tu contraseña]
SSL: Enabled (✓)
```

### Probar la conexión

1. Ve a **Settings** > **Credentials**
2. Crea o edita la credencial PostgreSQL
3. Ingresa los datos de conexión
4. Haz clic en **Test Connection**
5. Debe aparecer: ✅ **Connection successful**

## 📦 Workflows Configurados

Los siguientes workflows están listos para usar con el usuario `dnzapata`:

### ✅ Workflows Activos:

1. **`generate-token-workflow.json`**
   - Endpoint: `POST /nutridiab/generate-token`
   - Función: Genera tokens de registro

2. **`validate-token-workflow.json`**
   - Endpoint: `POST /nutridiab/validate-and-save`
   - Función: Valida tokens y guarda datos

3. **`nutridiab-admin-consultas.json`**
   - Endpoint: `GET /nutridiab/admin/consultas`
   - Función: Lista consultas recientes

4. **`nutridiab-admin-stats.json`**
   - Endpoint: `GET /nutridiab/admin/stats`
   - Función: Estadísticas del sistema

5. **`nutridiab-admin-usuarios.json`**
   - Endpoint: `GET /nutridiab/admin/usuarios`
   - Función: Lista usuarios con estadísticas

6. **`health-check.json`**
   - Endpoint: `GET /health`
   - Función: Verificar estado del servicio

### Actualizar credenciales en workflows

En cada workflow, busca la sección `credentials` y actualiza:

```json
"credentials": {
  "postgres": {
    "id": "TU_CREDENTIAL_ID",
    "name": "Supabase - Nutridiab (dnzapata)"
  }
}
```

## 🔧 Solución de Problemas

### Error: "permission denied for schema nutridiab"

```sql
-- Ejecutar como superusuario:
GRANT USAGE ON SCHEMA nutridiab TO dnzapata;
GRANT ALL PRIVILEGES ON SCHEMA nutridiab TO dnzapata;
```

### Error: "permission denied for table usuarios"

```sql
-- Ejecutar como superusuario:
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA nutridiab TO dnzapata;
ALTER TABLE nutridiab.usuarios OWNER TO dnzapata;
```

### Error: "permission denied for sequence"

```sql
-- Ejecutar como superusuario:
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA nutridiab TO dnzapata;
ALTER SEQUENCE nutridiab."usuarios_usuario ID_seq" OWNER TO dnzapata;
```

### Error: "must be owner of function"

```sql
-- Ejecutar como superusuario:
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA nutridiab TO dnzapata;
```

### RLS (Row Level Security) bloqueando acceso

```sql
-- Desactivar RLS:
ALTER TABLE nutridiab.usuarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE nutridiab."Consultas" DISABLE ROW LEVEL SECURITY;
ALTER TABLE nutridiab.mensajes DISABLE ROW LEVEL SECURITY;
ALTER TABLE nutridiab.tokens_acceso DISABLE ROW LEVEL SECURITY;
```

## 📊 Permisos Configurados

El usuario `dnzapata` tiene los siguientes permisos:

- ✅ **USAGE** y **CREATE** en schema `nutridiab`
- ✅ **SELECT, INSERT, UPDATE, DELETE** en todas las tablas
- ✅ **USAGE, SELECT** en todas las secuencias
- ✅ **EXECUTE** en todas las funciones
- ✅ **Owner** del schema y todas las tablas
- ✅ **RLS desactivado** en todas las tablas
- ✅ Permisos por defecto para objetos futuros

## 🔒 Seguridad

### Recomendaciones:

1. **Contraseña segura**: Usa una contraseña compleja para el usuario `dnzapata`
2. **SSL habilitado**: Siempre usa SSL en las conexiones
3. **IP Whitelist**: En Supabase, configura las IPs permitidas
4. **Rotación de contraseñas**: Cambia la contraseña periódicamente
5. **Auditoría**: Revisa regularmente los logs de acceso

### Cambiar contraseña:

```sql
ALTER USER dnzapata WITH PASSWORD 'nueva_password_segura';
```

## 📞 Soporte

Si encuentras problemas, verifica:

1. ✅ El usuario `dnzapata` existe
2. ✅ Los permisos están correctamente asignados
3. ✅ La conexión de red funciona (firewall, SSL)
4. ✅ Las credenciales en n8n son correctas
5. ✅ El RLS está desactivado en las tablas

## 📝 Logs Útiles

### Ver conexiones activas:

```sql
SELECT datname, usename, application_name, client_addr, state
FROM pg_stat_activity
WHERE usename = 'dnzapata';
```

### Ver últimas operaciones:

```sql
SELECT schemaname, tablename, seq_scan, idx_scan, n_tup_ins, n_tup_upd, n_tup_del
FROM pg_stat_user_tables
WHERE schemaname = 'nutridiab';
```

---

**Última actualización**: Noviembre 2025  
**Versión del schema**: 1.0  
**Usuario configurado**: dnzapata

