# ⚙️ Configuración de n8n - Usuario dnzapata

## 🎯 Resumen Rápido

**Usuario de Base de Datos**: `dnzapata`  
**Workflows Listos**: 6 workflows con nodos PostgreSQL  
**Workflows Eliminados**: 7 workflows obsoletos (con Supabase API)

---

## ✅ Checklist de Configuración

### 1. Base de Datos

- [ ] El usuario `dnzapata` existe en la base de datos
- [ ] Se ejecutó el script `schema_nutridiab_complete.sql`
- [ ] Se verificaron los permisos con el query de verificación
- [ ] El usuario `dnzapata` es owner del schema `nutridiab`
- [ ] RLS está desactivado en todas las tablas

**Script para verificar**:
```bash
psql -U postgres -d postgres -f database/schema_nutridiab_complete.sql
```

### 2. Credenciales en n8n

- [ ] Crear credencial PostgreSQL en n8n
- [ ] Configurar los siguientes datos:

```
Nombre: Supabase - Nutridiab (dnzapata)
Host: db.xxxxx.supabase.co
Port: 5432
Database: postgres
User: dnzapata
Password: [tu contraseña]
SSL: ✓ Enabled
```

- [ ] Probar conexión (debe ser exitosa ✅)
- [ ] Copiar el ID de la credencial

### 3. Importar Workflows

- [ ] Importar los 6 workflows desde `n8n/workflows/`
- [ ] Actualizar el credential ID en cada workflow

**Workflows a importar**:

1. ✅ `generate-token-workflow.json`
2. ✅ `validate-token-workflow.json`  
3. ✅ `nutridiab-admin-consultas.json`
4. ✅ `nutridiab-admin-stats.json`
5. ✅ `nutridiab-admin-usuarios.json`
6. ✅ `health-check.json`

### 4. Configurar Credenciales en Workflows

En cada workflow, busca la sección `credentials` y actualiza:

```json
"credentials": {
  "postgres": {
    "id": "TU_CREDENTIAL_ID_AQUI",
    "name": "Supabase - Nutridiab (dnzapata)"
  }
}
```

**Forma rápida**: Usa búsqueda y reemplazo en VS Code:
- Buscar: `"id": "YOUR_CREDENTIAL_ID"`
- Reemplazar por: `"id": "TU_ID_REAL"`

### 5. Activar Workflows

- [ ] Activar cada workflow en n8n
- [ ] Verificar que cada webhook genera su URL correctamente

### 6. Probar Endpoints

Probar cada endpoint para verificar que funcionan:

#### Health Check
```bash
curl http://localhost:5678/webhook/health
```

**Respuesta esperada**:
```json
{
  "status": "ok",
  "timestamp": "2025-11-23T...",
  "service": "n8n-backend",
  "version": "1.0.0"
}
```

#### Generar Token
```bash
curl -X POST http://localhost:5678/webhook/nutridiab/generate-token \
  -H "Content-Type: application/json" \
  -d '{"usuario_id": 1}'
```

**Respuesta esperada**:
```json
{
  "success": true,
  "token": "abc123...",
  "enlace": "http://localhost:5173/registro?token=abc123...",
  "expira": "2025-11-24T...",
  "mensaje": "📋 Para completar tu registro..."
}
```

#### Admin - Estadísticas
```bash
curl http://localhost:5678/webhook/nutridiab/admin/stats
```

---

## 📋 Estructura de los Workflows

### 1. Generate Token Workflow

**Endpoint**: `POST /nutridiab/generate-token`

**Nodos**:
- Webhook (trigger)
- PostgreSQL - Generar Token (ejecuta INSERT)
- Code - Construir Respuesta
- Respond to Webhook

**Query SQL**:
```sql
INSERT INTO nutridiab.tokens_acceso ("usuario ID", token, tipo, expira)
VALUES (
  {{ $json.usuario_id }},
  encode(gen_random_bytes(32), 'hex'),
  'registro',
  NOW() + INTERVAL '24 hours'
)
RETURNING token, expira;
```

### 2. Validate Token Workflow

**Endpoint**: `POST /nutridiab/validate-and-save`

**Nodos**:
- Webhook (trigger)
- PostgreSQL - Validar Token
- IF - ¿Token válido?
- PostgreSQL - Actualizar Usuario
- PostgreSQL - Marcar Token Usado
- Code - Respuestas (éxito/error)
- Respond to Webhook (2 nodos)

### 3. Admin Consultas

**Endpoint**: `GET /nutridiab/admin/consultas`

**Nodos**:
- Webhook (trigger)
- PostgreSQL - Consultas (SELECT con JOIN)
- Respond to Webhook

### 4. Admin Stats

**Endpoint**: `GET /nutridiab/admin/stats`

**Nodos**:
- Webhook (trigger)
- PostgreSQL - Stats (múltiples COUNT/SUM)
- Respond to Webhook

### 5. Admin Usuarios

**Endpoint**: `GET /nutridiab/admin/usuarios`

**Nodos**:
- Webhook (trigger)
- PostgreSQL - Usuarios (SELECT con GROUP BY)
- Respond to Webhook

### 6. Health Check

**Endpoint**: `GET /health`

**Nodos**:
- Webhook (trigger)
- Code - Generate Response
- Respond to Webhook

---

## 🔧 Configuración Avanzada

### Variables de Entorno en n8n

Puedes configurar estas variables en tu archivo `.env`:

```env
# Base de datos
DB_POSTGRESDB_HOST=db.xxxxx.supabase.co
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=postgres
DB_POSTGRESDB_USER=dnzapata
DB_POSTGRESDB_PASSWORD=tu_password
DB_POSTGRESDB_SSL=true

# Frontend URL (para enlaces de registro)
FRONTEND_URL=http://localhost:5173

# n8n Configuration
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=tu_password_admin
```

### Usar Variables en Workflows

En el nodo "Construir Respuesta" del workflow de generar token, puedes usar:

```javascript
const frontend_url = process.env.FRONTEND_URL || 'http://localhost:5173';
```

---

## 🐛 Solución de Problemas Comunes

### Error: "Could not connect to database"

**Solución**:
1. Verifica que el host sea correcto (debe incluir `.supabase.co`)
2. Verifica que SSL esté habilitado
3. Verifica que el usuario y contraseña sean correctos
4. Verifica que el puerto sea 5432

### Error: "permission denied for schema nutridiab"

**Solución**:
```sql
GRANT USAGE ON SCHEMA nutridiab TO dnzapata;
GRANT ALL PRIVILEGES ON SCHEMA nutridiab TO dnzapata;
```

### Error: "relation does not exist"

**Solución**:
1. Verifica que el schema esté creado
2. Asegúrate de usar comillas dobles en nombres con espacios:
   ```sql
   SELECT "usuario ID" FROM nutridiab.usuarios
   ```

### Error: "function does not exist"

**Solución**:
```sql
-- Verificar que las funciones existan
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'nutridiab';
```

### Workflow no responde

**Solución**:
1. Verifica que el workflow esté activo (toggle en ON)
2. Verifica que la URL del webhook sea correcta
3. Revisa los logs de ejecución en n8n
4. Verifica que la credencial esté correctamente asignada

---

## 📊 Monitoreo y Logs

### Ver ejecuciones en n8n

1. Ve a **Executions** en el menú lateral
2. Filtra por workflow
3. Revisa las ejecuciones fallidas (🔴)
4. Click en cada ejecución para ver detalles

### Queries útiles para debugging

**Ver tokens generados**:
```sql
SELECT * FROM nutridiab.tokens_acceso 
ORDER BY created_at DESC 
LIMIT 10;
```

**Ver usuarios recientes**:
```sql
SELECT "usuario ID", nombre, email, created_at 
FROM nutridiab.usuarios 
ORDER BY created_at DESC 
LIMIT 10;
```

**Ver consultas recientes**:
```sql
SELECT c.id, c.tipo, u.nombre, c.created_at
FROM nutridiab."Consultas" c
JOIN nutridiab.usuarios u ON c."usuario ID" = u."usuario ID"
ORDER BY c.created_at DESC
LIMIT 10;
```

**Verificar permisos del usuario**:
```sql
SELECT 
    tablename,
    has_table_privilege('dnzapata', 'nutridiab.'||tablename, 'SELECT') as puede_select,
    has_table_privilege('dnzapata', 'nutridiab.'||tablename, 'INSERT') as puede_insert,
    has_table_privilege('dnzapata', 'nutridiab.'||tablename, 'UPDATE') as puede_update
FROM pg_tables
WHERE schemaname = 'nutridiab';
```

---

## 🔄 Actualizaciones Futuras

### Agregar nuevos workflows

1. Crea el workflow en n8n
2. Exporta como JSON
3. Guarda en `n8n/workflows/`
4. Asegúrate de usar nodos PostgreSQL (no Supabase)
5. Documenta el endpoint y funcionalidad

### Modificar queries existentes

1. Edita el workflow en n8n
2. Prueba la ejecución
3. Exporta el workflow actualizado
4. Reemplaza el archivo JSON

### Agregar nuevas funciones en la BD

1. Crea la función en `schema_nutridiab_complete.sql`
2. Ejecuta el script o solo la función nueva
3. Actualiza los workflows que la usen
4. Documenta la función

---

## 📞 Recursos Adicionales

### Documentación

- [n8n PostgreSQL Node](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.postgres/)
- [Supabase Database](https://supabase.com/docs/guides/database)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

### Scripts útiles

- `database/schema_nutridiab_complete.sql` - Schema completo
- `database/update_permissions_dnzapata.sql` - Actualizar permisos
- `database/README_PERMISOS.md` - Guía de permisos detallada

### Archivos de configuración

- `.env` - Variables de entorno
- `n8n/workflows/*.json` - Workflows de n8n
- `database/*.sql` - Scripts de base de datos

---

**✅ Una vez completado el checklist, tu sistema estará completamente configurado y listo para usar!**

---

**Última actualización**: Noviembre 2025  
**Usuario configurado**: dnzapata  
**Workflows activos**: 6  
**Base de datos**: Supabase (PostgreSQL)

