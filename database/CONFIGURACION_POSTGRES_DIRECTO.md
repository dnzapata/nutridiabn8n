# 🐘 Configuración PostgreSQL Directo para Nutridiab

## 📝 Información General

Esta guía es para conectar **PostgreSQL directo** (no Supabase) desde:
- ✅ n8n
- ✅ DBeaver
- ✅ Cualquier aplicación

---

## PASO 1: Crear Base de Datos (Si no existe)

### Opción A: Desde Terminal/PowerShell

```bash
# Conectar a PostgreSQL
psql -U postgres

# Crear base de datos
CREATE DATABASE nutridiab;

# Conectar a la base
\c nutridiab

# Salir
\q
```

### Opción B: Desde DBeaver

1. Click derecho en la conexión PostgreSQL
2. **SQL Editor** → **New SQL Script**
3. Ejecutar:
```sql
CREATE DATABASE nutridiab
    WITH 
    ENCODING = 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TEMPLATE = template0;
```

---

## PASO 2: Ejecutar Schema Completo

### Desde DBeaver (Recomendado):

1. Conectar a la base de datos `nutridiab`
2. **SQL Editor** → **Open SQL Script**
3. Seleccionar: `database/schema_nutridiab_complete.sql`
4. Click en **Execute SQL Statement** (▶ o Ctrl+Enter)
5. Verificar mensajes de éxito en la consola

### Desde Terminal:

```bash
# Windows (PowerShell)
psql -U postgres -d nutridiab -f "C:\software\nutridiabn8n8\database\schema_nutridiab_complete.sql"

# Linux/Mac
psql -U postgres -d nutridiab -f "/path/to/schema_nutridiab_complete.sql"
```

---

## PASO 3: Configurar Usuario para Aplicaciones (Recomendado)

Por seguridad, NO uses el usuario `postgres` en producción. Crea un usuario específico:

### 3.1 Crear Usuario para n8n

```sql
-- Crear usuario
CREATE USER n8n_user WITH PASSWORD 'tu_password_seguro_aqui';

-- Otorgar permisos sobre el schema
GRANT USAGE ON SCHEMA nutridiab TO n8n_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA nutridiab TO n8n_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA nutridiab TO n8n_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA nutridiab TO n8n_user;

-- Permisos para objetos futuros
ALTER DEFAULT PRIVILEGES IN SCHEMA nutridiab 
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO n8n_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA nutridiab 
  GRANT USAGE, SELECT ON SEQUENCES TO n8n_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA nutridiab 
  GRANT EXECUTE ON FUNCTIONS TO n8n_user;

-- Verificar permisos
SELECT 
    'nutridiab.usuarios' as tabla,
    has_table_privilege('n8n_user', 'nutridiab.usuarios', 'SELECT') as select,
    has_table_privilege('n8n_user', 'nutridiab.usuarios', 'INSERT') as insert,
    has_table_privilege('n8n_user', 'nutridiab.usuarios', 'UPDATE') as update,
    has_table_privilege('n8n_user', 'nutridiab.usuarios', 'DELETE') as delete;

-- Todos deben retornar 'true' ✅
```

---

## PASO 4: Configurar Conexión en DBeaver

### 4.1 Crear Nueva Conexión

1. Click en **Database** → **New Database Connection**
2. Seleccionar **PostgreSQL**
3. Click **Next**

### 4.2 Configuración de Conexión

```
┌────────────────────────────────────────┐
│ Main                                   │
├────────────────────────────────────────┤
│ Host:         localhost                │
│               (o IP de tu servidor)    │
│ Port:         5432                     │
│ Database:     nutridiab                │
│ Username:     postgres                 │
│               (o n8n_user)             │
│ Password:     [tu_password]            │
└────────────────────────────────────────┘
```

### 4.3 Configuración SSL (Si es necesario)

**Pestaña "SSL"**:
```
☐ Use SSL (solo si tu servidor lo requiere)

Si usas SSL:
✅ SSL Mode: require (o prefer)
```

### 4.4 Configuración Driver Properties

**Pestaña "Driver properties"**:

⚠️ **IMPORTANTE**: Para evitar el error de TimeZone:

```
Name: TimeZone
Value: UTC

O eliminar esta propiedad completamente.
```

### 4.5 Test Connection

1. Click en **Test Connection**
2. Debe mostrar: ✅ **Connected**
3. Si aparece error, verifica:
   - Host y puerto correctos
   - Usuario y password correctos
   - Base de datos existe
   - PostgreSQL está corriendo

---

## PASO 5: Configurar Conexión en n8n

### 5.1 Crear Credencial PostgreSQL

1. Ve a https://wf.zynaptic.tech (o tu instancia n8n)
2. Click en tu avatar → **Credentials**
3. **+ New Credential**
4. Buscar y seleccionar: **"Postgres"**

### 5.2 Configuración de la Credencial

```
┌────────────────────────────────────────┐
│ Credential name                        │
│ PostgreSQL Nutridiab                   │
├────────────────────────────────────────┤
│ Host                                   │
│ localhost                              │
│ (o IP/dominio de tu servidor)         │
├────────────────────────────────────────┤
│ Database                               │
│ nutridiab                              │
├────────────────────────────────────────┤
│ User                                   │
│ n8n_user                               │
│ (o postgres para desarrollo)          │
├────────────────────────────────────────┤
│ Password                               │
│ [tu_password]                          │
├────────────────────────────────────────┤
│ Port                                   │
│ 5432                                   │
├────────────────────────────────────────┤
│ SSL                                    │
│ ☐ Allow (solo si es necesario)        │
└────────────────────────────────────────┘
```

**Additional Fields** (Click "Add Field"):
```
Schema: nutridiab
```

O mejor:
```
Additional Options → Execute Query → 
Search Path: nutridiab,public
```

### 5.3 Test de Credencial

1. Click **"Save"**
2. n8n intentará conectarse
3. Si hay error, verifica:
   - Host accesible desde n8n (firewall, red)
   - Puerto 5432 abierto
   - Usuario y password correctos
   - PostgreSQL permite conexiones remotas (si aplica)

---

## PASO 6: Test de Conexión desde n8n

### 6.1 Crear Workflow de Prueba

1. Nuevo workflow en n8n
2. Agregar nodo **"Postgres"**
3. Seleccionar credencial creada
4. **Operation**: Execute Query
5. **Query**:

```sql
-- Test básico
SELECT 
  current_database() as database,
  current_schema() as schema,
  current_user as user,
  version() as postgres_version;
```

6. Click **"Execute Node"**

**Debe retornar**:
```json
{
  "database": "nutridiab",
  "schema": "nutridiab",
  "user": "n8n_user",
  "postgres_version": "PostgreSQL 14.x ..."
}
```

### 6.2 Test de Tablas

```sql
-- Ver tablas del schema
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'nutridiab'
ORDER BY table_name;
```

**Debe retornar**:
- Consultas
- mensajes
- tokens_acceso
- usuarios

### 6.3 Test de Permisos

```sql
-- Verificar permisos
SELECT 
    tablename,
    has_table_privilege(current_user, 'nutridiab.'||tablename, 'SELECT') as puede_select,
    has_table_privilege(current_user, 'nutridiab.'||tablename, 'INSERT') as puede_insert,
    has_table_privilege(current_user, 'nutridiab.'||tablename, 'UPDATE') as puede_update
FROM pg_tables
WHERE schemaname = 'nutridiab';
```

**Todas las columnas deben mostrar `true`** ✅

---

## PASO 7: Workflows de PostgreSQL

Usa los workflows con **nodos Postgres** (no Supabase):

### Workflows Disponibles:

```
✅ generate-token-workflow.json
✅ validate-token-workflow.json
✅ nutridiab-admin-stats.json
✅ nutridiab-admin-usuarios.json
✅ nutridiab-admin-consultas.json
```

### Configuración de Workflows:

1. **Importar** workflow en n8n
2. Abrir cada **nodo Postgres**
3. **Credentials** → Seleccionar: "PostgreSQL Nutridiab"
4. Verificar que las queries usen: `nutridiab.tabla_nombre`
5. **Guardar** workflow
6. **Activar** (toggle verde)

---

## 🔧 Configuración Avanzada

### Permitir Conexiones Remotas

Si n8n está en otro servidor, edita `postgresql.conf`:

```conf
# /etc/postgresql/14/main/postgresql.conf (Linux)
# C:\Program Files\PostgreSQL\14\data\postgresql.conf (Windows)

listen_addresses = '*'  # O la IP específica
```

Y `pg_hba.conf`:

```conf
# /etc/postgresql/14/main/pg_hba.conf

# Permitir conexiones desde red específica
host    nutridiab    n8n_user    192.168.1.0/24    md5

# O desde cualquier IP (menos seguro)
host    nutridiab    n8n_user    0.0.0.0/0         md5
```

**Reiniciar PostgreSQL**:
```bash
# Linux
sudo systemctl restart postgresql

# Windows
# Services → PostgreSQL → Restart
```

---

## 🚨 Troubleshooting

### Error: "Could not connect to server"

**Causa**: PostgreSQL no está corriendo o no es accesible

**Solución**:
```bash
# Linux - Verificar estado
sudo systemctl status postgresql

# Windows - Verificar servicio
services.msc → PostgreSQL 14

# Test de conexión local
psql -U postgres -d nutridiab -c "SELECT 1;"
```

### Error: "password authentication failed"

**Causa**: Usuario o password incorrectos

**Solución**:
```sql
-- Cambiar password
ALTER USER n8n_user WITH PASSWORD 'nuevo_password';
```

### Error: "FATAL: database 'nutridiab' does not exist"

**Causa**: Base de datos no creada

**Solución**:
```sql
CREATE DATABASE nutridiab;
```

### Error: "schema 'nutridiab' does not exist"

**Causa**: Schema no ejecutado

**Solución**:
```bash
psql -U postgres -d nutridiab -f schema_nutridiab_complete.sql
```

### Error: "permission denied for table"

**Causa**: Usuario sin permisos

**Solución**:
```sql
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA nutridiab TO n8n_user;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA nutridiab TO n8n_user;
```

### Error: "TimeZone 'America/Buenos_Aires' not recognized"

**Causa**: DBeaver configurado con timezone inválido

**Solución**:
- Driver Properties → TimeZone: `UTC`
- O eliminar la propiedad TimeZone

---

## ✅ Checklist de Verificación

### PostgreSQL:
- [ ] PostgreSQL instalado y corriendo
- [ ] Base de datos `nutridiab` creada
- [ ] Schema ejecutado exitosamente
- [ ] Usuario `n8n_user` creado (o usando postgres)
- [ ] Permisos otorgados al usuario

### DBeaver:
- [ ] Conexión creada
- [ ] Test connection exitoso
- [ ] Puede ver tablas del schema nutridiab
- [ ] Puede ejecutar queries SELECT/INSERT

### n8n:
- [ ] Credencial PostgreSQL creada
- [ ] Test de conexión exitoso
- [ ] Workflows importados
- [ ] Nodos configurados con credencial
- [ ] Workflows activos

---

## 📊 Comparación: PostgreSQL Directo vs Supabase

| Aspecto | PostgreSQL Directo | Supabase |
|---------|-------------------|----------|
| **Setup** | Manual | Automático |
| **SSL** | Opcional | Requerido |
| **RLS** | No usa por defecto | Activo por defecto |
| **API REST** | No (solo SQL) | Sí (incluida) |
| **Permisos** | Más simple | Más complejo |
| **Hosting** | Auto-hospedado | Cloud/Auto-hospedado |
| **Costo** | Gratis (tu servidor) | Gratis tier / Paid |
| **Backup** | Manual | Automático (en cloud) |

---

## 🎯 Datos de Prueba

Para probar la aplicación:

```sql
-- Insertar usuario de prueba
INSERT INTO nutridiab.usuarios (
  "remoteJid",
  nombre,
  apellido,
  email,
  tipo_diabetes,
  "AceptoTerminos",
  datos_completos,
  "Activo"
) VALUES (
  '5491155555555@s.whatsapp.net',
  'Juan',
  'Pérez',
  'juan@test.com',
  'tipo2',
  TRUE,
  TRUE,
  TRUE
) RETURNING "usuario ID";

-- Insertar consultas de prueba (reemplaza usuario_id con el ID retornado)
INSERT INTO nutridiab."Consultas" ("tipo", "usuario ID", "resultado", "Costo")
VALUES 
  ('texto', 1, 'Empanada de carne: ~25g hidratos', 0.002),
  ('imagen', 1, 'Plato de pasta: ~65g hidratos', 0.015),
  ('audio', 1, 'Pizza mediana: ~80g hidratos', 0.008);

-- Verificar
SELECT * FROM nutridiab.vista_usuarios_estado;
```

---

## 📝 Configuración de Producción

### Recomendaciones:

1. **Usuario específico**: NO usar `postgres` en producción
2. **Password fuerte**: Mínimo 16 caracteres, aleatorio
3. **Firewall**: Solo permitir IPs necesarias
4. **SSL**: Activar en producción
5. **Backups**: Configurar backups automáticos
6. **Monitoring**: Log de conexiones y queries lentas

### Backup Automático:

```bash
# Linux - Cron job
0 2 * * * pg_dump -U postgres nutridiab > /backups/nutridiab_$(date +\%Y\%m\%d).sql

# Windows - Task Scheduler
pg_dump -U postgres nutridiab > C:\backups\nutridiab_%date%.sql
```

---

## 🔐 Seguridad

### 1. Cambiar Password por Defecto

```sql
ALTER USER postgres WITH PASSWORD 'password_muy_seguro_aqui';
```

### 2. Limitar Conexiones

```sql
-- Solo permitir N conexiones
ALTER USER n8n_user CONNECTION LIMIT 10;
```

### 3. Auditoría

```sql
-- Habilitar log de conexiones
-- En postgresql.conf:
log_connections = on
log_disconnections = on
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
```

---

**Versión**: 1.0  
**Compatible con**: PostgreSQL 12+, n8n, DBeaver  
**Proyecto**: Nutridiab - Control Nutricional para Diabéticos  
**Fecha**: 2025-11-23


