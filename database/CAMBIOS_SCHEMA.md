# 📋 Cambios en Schema Nutridiab

## ✅ Schema Completo Verificado y Actualizado

**Archivo**: `database/schema_nutridiab_complete.sql`  
**Fecha**: 2025-11-23  
**Estado**: ✅ Listo para producción

---

## 🆕 Campos Nuevos Agregados a `usuarios`

| Campo | Tipo | Default | Descripción |
|-------|------|---------|-------------|
| `Activo` | BOOLEAN | TRUE | Usuario activo en el sistema |
| `Bloqueado` | BOOLEAN | FALSE | Usuario bloqueado permanentemente |
| `invitado` | BOOLEAN | FALSE | Usuario en modo prueba/invitado |
| `Lenguaje` | VARCHAR(10) | 'es' | Idioma preferido (es, en, pt) |
| `Tipo ID` | VARCHAR(50) | NULL | Tipo de identificación (DNI, Pasaporte) |
| `ultpago` | DATE | NULL | Fecha del último pago/suscripción |

---

## 🔧 Funciones Nuevas Agregadas

### 1. `puede_usar_servicio(p_usuario_id)`
Verifica si un usuario puede usar el servicio:
- ✅ Activo = TRUE
- ✅ Bloqueado = FALSE
- ✅ AceptoTerminos = TRUE
- ✅ datos_completos = TRUE

**Uso**:
```sql
SELECT nutridiab.puede_usar_servicio(1);
-- Retorna: true o false
```

### 2. `bloquear_usuario(p_usuario_id, p_motivo)`
Bloquea un usuario (desactiva y marca como bloqueado).

**Uso**:
```sql
SELECT nutridiab.bloquear_usuario(1, 'Falta de pago');
```

### 3. `activar_usuario(p_usuario_id)`
Activa un usuario (quita bloqueo y marca como activo).

**Uso**:
```sql
SELECT nutridiab.activar_usuario(1);
```

---

## 📊 Vista Mejorada: `vista_usuarios_estado`

Ahora incluye:
- ✅ Campos nuevos: `Activo`, `Bloqueado`, `invitado`, `Lenguaje`, `ultpago`
- ✅ Campo `costo_total`: Suma de todos los costos de consultas
- ✅ Lógica de estado mejorada:

**Estados posibles**:
1. `bloqueado` - Usuario bloqueado (prioridad máxima)
2. `inactivo` - Usuario desactivado temporalmente
3. `pendiente_terminos` - No aceptó términos y condiciones
4. `pendiente_datos` - Falta completar datos personales
5. `pendiente_email` - Email sin verificar
6. `activo` - Todo OK, puede usar el servicio

**Uso**:
```sql
SELECT * FROM nutridiab.vista_usuarios_estado;
```

---

## 🔐 Permisos Completos Configurados

El script incluye configuración automática de:

### 1. Permisos para `postgres` (CRÍTICO para n8n)
```sql
✅ USAGE en schema nutridiab
✅ ALL PRIVILEGES en todas las tablas
✅ ALL PRIVILEGES en secuencias
✅ ALL PRIVILEGES en funciones
✅ OWNER de todas las tablas = postgres
```

### 2. RLS (Row Level Security) Desactivado
```sql
✅ usuarios - RLS disabled
✅ Consultas - RLS disabled
✅ mensajes - RLS disabled
✅ tokens_acceso - RLS disabled
```

**Por qué**: Evita el error "Tenant or user not found" en n8n.

### 3. Permisos para roles de Supabase
```sql
✅ anon - SELECT, INSERT, UPDATE
✅ authenticated - SELECT, INSERT, UPDATE
```

---

## 📝 Índices Agregados

Nuevos índices para mejor performance:
```sql
✅ idx_usuarios_activo - Búsquedas de usuarios activos
✅ idx_usuarios_bloqueado - Búsquedas de usuarios bloqueados
```

Índices existentes mantenidos:
```sql
✅ idx_usuarios_remotejid
✅ idx_usuarios_email
✅ idx_usuarios_token
✅ idx_consultas_usuario
✅ idx_consultas_fecha
✅ idx_consultas_tipo
✅ idx_tokens_token
✅ idx_tokens_usuario
✅ idx_tokens_expira
```

---

## 🔄 Correcciones Realizadas

### 1. Nombre del Proyecto
- ❌ Antes: "NutriDiab"
- ✅ Ahora: "Nutridiab"

### 2. Mensajes Actualizados
```sql
✅ BIENVENIDA - "Soy Nutridiab..." (corregido)
```

### 3. Estructura de Tablas
```sql
✅ usuarios - Todos los campos necesarios
✅ Consultas - Sin cambios (correcto)
✅ mensajes - Con mensajes de verificación
✅ tokens_acceso - Para registro tokenizado
```

---

## 🚀 Cómo Usar Este Schema

### Opción 1: Nueva Base de Datos (Desde Cero)

1. Ve a Supabase → SQL Editor
2. **New query**
3. Copia TODO el contenido de `schema_nutridiab_complete.sql`
4. Click **"Run"** (Ctrl+Enter)
5. Verifica mensajes de éxito ✅

### Opción 2: Migración de Base Existente

Si ya tienes el schema creado, usa:
```
database/migration_usuarios_nuevos_campos.sql
```

Este archivo solo agrega los campos nuevos sin destruir datos.

---

## ✅ Verificación Post-Instalación

### 1. Verificar Tablas Creadas
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'nutridiab'
ORDER BY table_name;

-- Debe retornar:
-- Consultas
-- mensajes
-- tokens_acceso
-- usuarios
```

### 2. Verificar Funciones
```sql
SELECT routine_name 
FROM information_schema.routines
WHERE routine_schema = 'nutridiab'
ORDER BY routine_name;

-- Debe retornar 7 funciones:
-- activar_usuario
-- bloquear_usuario
-- generar_token
-- limpiar_tokens_expirados
-- puede_usar_servicio
-- usar_token
-- validar_token
-- verificar_datos_usuario
```

### 3. Verificar Permisos
```sql
SELECT 
    tablename,
    tableowner,
    has_table_privilege('postgres', 'nutridiab.'||tablename, 'SELECT') as puede_select,
    has_table_privilege('postgres', 'nutridiab.'||tablename, 'INSERT') as puede_insert
FROM pg_tables
WHERE schemaname = 'nutridiab';

-- Todas las columnas deben mostrar 'true' ✅
```

### 4. Verificar Mensajes
```sql
SELECT "CODIGO" FROM nutridiab.mensajes ORDER BY "CODIGO";

-- Debe retornar al menos:
-- ACEPTA
-- BIENVENIDA
-- BIENVENIDA_VERIFICADO
-- DATOS_INCOMPLETOS
-- EMAIL_NO_VERIFICADO
-- NOENTENDI
-- RESPONDEACEPTA
-- RESPONDENO
-- SERVICIO
-- TERMINOS
```

---

## 🔐 Configuración de Conexión para n8n

Después de ejecutar el schema:

### 1. Resetear Password en Supabase
```
Supabase Dashboard → Settings → Database → Reset database password
⚠️ COPIAR EL NUEVO PASSWORD (solo se muestra una vez)
```

### 2. Datos de Conexión
```
Host: db.xxxxx.supabase.co (copia exacto de Supabase)
Port: 5432
Database: postgres
User: postgres
Password: [NUEVO PASSWORD]
SSL: ☑ Allow o Require (DEBE estar marcado)
Schema: nutridiab
```

### 3. Test de Conexión
```sql
-- En n8n, ejecutar en nodo Postgres:
SELECT 
  current_database() as database,
  current_schema() as schema,
  current_user as user;

-- Debe retornar: postgres, nutridiab, postgres
```

---

## 📊 Estructura Final

```
nutridiab (schema)
├── Tablas (4)
│   ├── usuarios (con 6 campos nuevos)
│   ├── Consultas
│   ├── mensajes (11 mensajes)
│   └── tokens_acceso
├── Funciones (8)
│   ├── generar_token()
│   ├── validar_token()
│   ├── usar_token()
│   ├── verificar_datos_usuario()
│   ├── limpiar_tokens_expirados()
│   ├── puede_usar_servicio() ⭐ NUEVA
│   ├── bloquear_usuario() ⭐ NUEVA
│   └── activar_usuario() ⭐ NUEVA
├── Vistas (1)
│   └── vista_usuarios_estado (mejorada)
├── Índices (13)
└── Triggers (1)
    └── usuarios_updated_at
```

---

## 🎯 Casos de Uso

### Caso 1: Bloquear Usuario por Falta de Pago
```sql
SELECT nutridiab.bloquear_usuario(123, 'Falta de pago');
-- Usuario no podrá usar el servicio
```

### Caso 2: Verificar si Usuario Puede Usar Servicio
```sql
SELECT nutridiab.puede_usar_servicio(123);
-- Retorna false si está bloqueado o inactivo
```

### Caso 3: Reactivar Usuario Después de Pago
```sql
-- Actualizar fecha de pago
UPDATE nutridiab.usuarios 
SET "ultpago" = CURRENT_DATE 
WHERE "usuario ID" = 123;

-- Activar usuario
SELECT nutridiab.activar_usuario(123);
```

### Caso 4: Obtener Todos los Usuarios Activos
```sql
SELECT * FROM nutridiab.vista_usuarios_estado
WHERE estado = 'activo'
ORDER BY created_at DESC;
```

### Caso 5: Ver Usuarios Bloqueados
```sql
SELECT * FROM nutridiab.vista_usuarios_estado
WHERE "Bloqueado" = TRUE
ORDER BY created_at DESC;
```

---

## 🚨 Notas Importantes

1. **RLS Desactivado**: Para que n8n funcione, RLS está desactivado en todas las tablas.
2. **Owner = postgres**: Todas las tablas pertenecen al usuario `postgres`.
3. **Backup**: Siempre haz backup antes de ejecutar en producción.
4. **Password**: Después de ejecutar el script, resetea el password en Supabase.
5. **Testing**: Prueba todas las funciones antes de usar en producción.

---

## ✅ Checklist de Implementación

- [ ] Schema ejecutado en Supabase
- [ ] 4 tablas creadas
- [ ] 8 funciones creadas
- [ ] 1 vista creada
- [ ] 13 índices creados
- [ ] Permisos verificados
- [ ] RLS desactivado
- [ ] Password reseteado
- [ ] Credencial n8n configurada
- [ ] Test de conexión exitoso
- [ ] Datos de prueba insertados (opcional)

---

**Versión del Schema**: 2.0  
**Compatible con**: Supabase, PostgreSQL 14+, n8n  
**Proyecto**: Nutridiab - Control Nutricional para Diabéticos  
**Fecha**: 2025-11-23


