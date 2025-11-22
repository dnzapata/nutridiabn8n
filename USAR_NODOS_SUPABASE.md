# 🚀 Guía: Usar Nodos de Supabase en n8n

## ✅ Ventajas de Usar Nodos Supabase

En lugar de conectar directamente a PostgreSQL, usar nodos de Supabase es mucho mejor:

- ✅ **Más fácil**: Solo necesitas URL y API Key
- ✅ **Sin problemas de permisos**: Usa la API REST de Supabase
- ✅ **Sin configurar SSL**: Todo se maneja automáticamente
- ✅ **Más seguro**: Usa autenticación por API Key
- ✅ **Más rápido de configurar**: 2 minutos vs 15 minutos

---

## PASO 1: Ejecutar Funciones RPC en Supabase (5 min)

### 1.1 Ejecutar Script SQL

1. Ve a [Supabase](https://supabase.com) → Tu proyecto
2. **SQL Editor** → **New query**
3. Copia TODO el contenido de: `database/funciones_rpc_supabase.sql`
4. Click **"Run"** (Ctrl+Enter)
5. Verifica mensajes de éxito

### 1.2 Verificar Funciones Creadas

```sql
-- Ejecutar en SQL Editor:
SELECT routine_name 
FROM information_schema.routines
WHERE routine_schema = 'nutridiab' 
  AND routine_name LIKE 'rpc_%'
ORDER BY routine_name;

-- Debe mostrar 7 funciones:
-- rpc_actualizar_usuario
-- rpc_consultas_recientes
-- rpc_dashboard_stats
-- rpc_generar_token
-- rpc_lista_usuarios
-- rpc_usar_token
-- rpc_validar_token
```

---

## PASO 2: Obtener API Key de Supabase (2 min)

### 2.1 En Supabase Dashboard:

1. Ve a **Settings** → **API**
2. Busca la sección **Project API keys**
3. Copia estos 2 valores:

```
Project URL: https://xxxxxxxxxxxxx.supabase.co

anon / public key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
(Es un JWT largo, cópialo completo)
```

**⚠️ IMPORTANTE**: 
- Usa el **anon/public key** (NO el service_role key)
- El service_role key es solo para backend seguro
- Para n8n usa siempre anon key

---

## PASO 3: Crear Credencial en n8n (2 min)

### 3.1 Configuración Súper Simple:

1. Ve a https://wf.zynaptic.tech
2. Click en tu avatar → **Credentials**
3. **+ New Credential** → Buscar **"Supabase"**
4. Selecciona: **"Supabase API"**

### 3.2 Completa SOLO 2 campos:

```
┌──────────────────────────────────────────────┐
│ Credential name                              │
│ Supabase Nutridiab                          │
├──────────────────────────────────────────────┤
│ Host (Project URL)                           │
│ https://xxxxxxxxxxxxx.supabase.co           │
│ (Copia exacto de Supabase)                  │
├──────────────────────────────────────────────┤
│ Service Role Secret                          │
│ eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...    │
│ (Pega el anon/public key completo)          │
└──────────────────────────────────────────────┘
```

5. Click **"Save"**

**No hay botón Test**, pero si los datos son correctos, funcionará.

---

## PASO 4: Importar Workflows con Nodos Supabase (10 min)

### Workflows Nuevos (Usan Supabase):

#### A) Generate Token (Supabase)
```
Archivo: n8n/workflows/supabase-generate-token.json
Endpoint: /webhook/nutridiab/generate-token
Función RPC: rpc_generar_token
```

**Configuración**:
1. Import from File
2. Abrir nodo "Supabase - Generar Token"
3. Credentials → Select: "Supabase Nutridiab"
4. **Operation**: RPC
5. **Function Name**: `rpc_generar_token`
6. Guardar nodo
7. Actualizar frontend_url en nodo "Construir Respuesta"
8. **Activar** (toggle verde)
9. **Guardar** (Ctrl+S)

#### B) Validate and Save (Supabase)
```
Archivo: n8n/workflows/supabase-validate-save.json
Endpoint: /webhook/nutridiab/validate-and-save
Funciones RPC: rpc_validar_token, rpc_actualizar_usuario, rpc_usar_token
```

**Configuración**:
1. Import from File
2. Configurar credenciales en 3 nodos Supabase:
   - "Supabase - Validar Token"
   - "Supabase - Actualizar Usuario"
   - "Supabase - Marcar Token Usado"
3. Todos usan: "Supabase Nutridiab"
4. **Activar**
5. **Guardar**

#### C) Admin Stats (Supabase)
```
Archivo: n8n/workflows/supabase-admin-stats.json
Endpoint: /webhook/nutridiab/admin/stats
Función RPC: rpc_dashboard_stats
```

**Configuración**:
1. Import
2. Nodo "Supabase - Dashboard Stats" → Credentials: "Supabase Nutridiab"
3. **Activar**
4. **Guardar**

#### D) Admin Usuarios (Supabase)
```
Archivo: n8n/workflows/supabase-admin-usuarios.json
Endpoint: /webhook/nutridiab/admin/usuarios
Función RPC: rpc_lista_usuarios
```

**Configuración**:
1. Import
2. Nodo → Credentials: "Supabase Nutridiab"
3. **Activar**
4. **Guardar**

#### E) Admin Consultas (Supabase)
```
Archivo: n8n/workflows/supabase-admin-consultas.json
Endpoint: /webhook/nutridiab/admin/consultas
Función RPC: rpc_consultas_recientes
```

**Configuración**:
1. Import
2. Nodo → Credentials: "Supabase Nutridiab"
3. **Activar**
4. **Guardar**

---

## PASO 5: Probar los Endpoints (5 min)

### Test desde Terminal/PowerShell:

```bash
# Test 1: Stats del Dashboard
curl https://wf.zynaptic.tech/webhook/nutridiab/admin/stats

# Test 2: Lista de Usuarios
curl https://wf.zynaptic.tech/webhook/nutridiab/admin/usuarios

# Test 3: Consultas Recientes
curl https://wf.zynaptic.tech/webhook/nutridiab/admin/consultas

# Test 4: Generar Token (POST)
curl -X POST https://wf.zynaptic.tech/webhook/nutridiab/generate-token \
  -H "Content-Type: application/json" \
  -d "{\"usuario_id\": 1}"
```

Todos deben retornar JSON con datos.

---

## PASO 6: Datos de Prueba en Supabase (5 min)

Si no tienes datos aún:

```sql
-- En Supabase SQL Editor:

-- 1. Insertar usuario de prueba
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

-- Anota el usuario ID que retorna (ejemplo: 1)

-- 2. Insertar consultas de prueba
INSERT INTO nutridiab."Consultas" ("tipo", "usuario ID", "resultado", "Costo")
VALUES 
  ('texto', 1, 'Empanada: ~25g hidratos', 0.002),
  ('imagen', 1, 'Pasta: ~65g hidratos', 0.015),
  ('audio', 1, 'Pizza: ~80g hidratos', 0.008);
```

---

## 🎯 Ventajas Comprobadas

### Antes (PostgreSQL directo):
```
❌ Configurar: Host, Port, Database, User, Password, SSL
❌ Problemas de permisos en schema
❌ Problemas de RLS
❌ "Tenant or user not found"
❌ Timeout de conexión
⏱️ Tiempo: 15-30 minutos de troubleshooting
```

### Ahora (Nodos Supabase):
```
✅ Solo 2 campos: URL + API Key
✅ Sin problemas de permisos
✅ Sin configurar SSL
✅ Funciona de inmediato
✅ Más seguro (API REST)
⏱️ Tiempo: 5 minutos total
```

---

## 📊 Comparación de Nodos

### Nodo Postgres:
```javascript
// Configuración compleja
{
  "operation": "executeQuery",
  "query": "INSERT INTO nutridiab.tokens_acceso (...) VALUES (...)"
}
// Problemas: Permisos, SSL, Schema, RLS
```

### Nodo Supabase:
```javascript
// Configuración simple
{
  "operation": "rpc",
  "functionName": "rpc_generar_token",
  "parameters": {
    "p_usuario_id": 123
  }
}
// Sin problemas, funciona de inmediato
```

---

## 🔍 Cómo Funciona

### Arquitectura:

```
n8n Workflow
    ↓
Nodo Supabase (API REST)
    ↓
Supabase API Endpoint
    ↓
PostgreSQL (ejecuta función RPC)
    ↓
Retorna resultado como JSON
    ↓
n8n recibe datos
```

**Ventajas**:
- Supabase maneja autenticación y permisos
- No necesitas conexión directa a PostgreSQL
- Todo usa HTTPS (seguro)
- API Key controla acceso

---

## ✅ Checklist Completo

### Supabase:
- [ ] Schema nutridiab existe
- [ ] Funciones RPC creadas (7 funciones)
- [ ] Permisos otorgados a anon/authenticated
- [ ] Usuario de prueba insertado
- [ ] URL del proyecto copiada
- [ ] API Key (anon/public) copiada

### n8n:
- [ ] Credencial "Supabase Nutridiab" creada
- [ ] URL y API Key correctos
- [ ] 5 workflows importados
- [ ] Todos los nodos tienen credencial configurada
- [ ] Todos los workflows activos (toggle verde)
- [ ] frontend_url actualizado en generate-token

### Testing:
- [ ] Test de stats (GET)
- [ ] Test de usuarios (GET)
- [ ] Test de consultas (GET)
- [ ] Test de generate-token (POST)
- [ ] Frontend conecta correctamente
- [ ] Dashboard muestra datos reales

---

## 🚨 Troubleshooting

### Error: "Could not connect with these settings"

**Causa**: URL o API Key incorrecta

**Solución**:
1. Verifica URL: Debe ser `https://xxx.supabase.co` (con https://)
2. Verifica API Key: Debe ser el anon/public key (JWT largo)
3. NO uses service_role key

### Error: "Function not found"

**Causa**: Funciones RPC no creadas

**Solución**:
```sql
-- Verificar en Supabase SQL Editor:
SELECT routine_name 
FROM information_schema.routines
WHERE routine_schema = 'nutridiab' 
  AND routine_name LIKE 'rpc_%';

-- Si no hay resultados, ejecuta:
-- database/funciones_rpc_supabase.sql
```

### Error: "Permission denied"

**Causa**: Permisos no otorgados a anon/authenticated

**Solución**:
```sql
-- En Supabase, ejecutar:
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA nutridiab TO anon, authenticated;
```

### Workflow no responde

**Causa**: Workflow no activo

**Solución**:
1. Abrir workflow en n8n
2. Verificar toggle verde (arriba a la derecha)
3. Si está gris, activarlo
4. Guardar

---

## 🎉 ¡Listo!

Si completaste todos los pasos:

✅ **Nodos Supabase** configurados  
✅ **API Key** funcionando  
✅ **Funciones RPC** creadas  
✅ **5 Workflows** activos  
✅ **Dashboard** mostrando datos reales  
✅ **Sin problemas** de permisos  

**Tiempo total**: 20-25 minutos (vs 1-2 horas con PostgreSQL directo)

---

## 📝 Funciones RPC Disponibles

| Función | Parámetros | Retorna | Uso |
|---------|-----------|---------|-----|
| `rpc_generar_token` | p_usuario_id | JSON con token | Generar token de registro |
| `rpc_validar_token` | p_token | JSON con validación | Validar token |
| `rpc_actualizar_usuario` | p_usuario_id, datos... | JSON con usuario | Actualizar datos de usuario |
| `rpc_usar_token` | p_token | JSON con success | Marcar token como usado |
| `rpc_dashboard_stats` | ninguno | JSON con stats | Estadísticas del dashboard |
| `rpc_lista_usuarios` | p_limit (opcional) | JSON array | Lista de usuarios |
| `rpc_consultas_recientes` | p_limit (opcional) | JSON array | Consultas recientes |

---

**Versión**: 2.0 (Nodos Supabase)  
**Proyecto**: Nutridiab - Control Nutricional para Diabéticos  
**Fecha**: 2025-11-22

