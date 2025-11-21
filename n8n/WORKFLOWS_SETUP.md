# 🔧 Configuración de Workflows - Nutridiab

## 📋 Información del Schema

**Schema de Base de Datos**: `nutridiab`

Todas las tablas están en el schema `nutridiab`:
- `nutridiab.usuarios`
- `nutridiab.Consultas`
- `nutridiab.mensajes`
- `nutridiab.tokens_acceso`

---

## 🔌 Credenciales de Supabase en n8n

### Configuración de Postgres/Supabase:

1. Ve a n8n: https://wf.zynaptic.tech
2. Settings → Credentials → New Credential
3. Busca: **Postgres**
4. Configuración:

```
Host: [TU_PROYECTO].supabase.co
Database: postgres
User: postgres
Password: [TU_PASSWORD_SUPABASE]
Port: 5432
SSL: Enabled
Schema: nutridiab  ← IMPORTANTE
```

**Nombre sugerido**: `Supabase - Nutridiab`

---

## 📝 Queries Correctas con Schema

### ✅ Formato Correcto:

```sql
-- Todas las queries deben especificar el schema
SELECT * FROM nutridiab.usuarios WHERE "remoteJid" = 'xxxxx';
INSERT INTO nutridiab.tokens_acceso (...) VALUES (...);
UPDATE nutridiab.usuarios SET datos_completos = TRUE WHERE ...;
```

### ❌ Formato Incorrecto:

```sql
-- Sin especificar schema (NO USAR)
SELECT * FROM usuarios WHERE "remoteJid" = 'xxxxx';
INSERT INTO tokens_acceso (...) VALUES (...);
```

---

## 🔄 Workflows que Necesitas Importar

### 1. Generate Token Workflow
**Archivo**: `n8n/workflows/generate-token-workflow.json`  
**Endpoint**: `POST /webhook/nutridiab/generate-token`

**Query principal**:
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

**Configurar**:
- [ ] Importar workflow en n8n
- [ ] Configurar credencial de Supabase en nodo "Supabase - Generar Token"
- [ ] Actualizar `frontend_url` en nodo "Construir Respuesta" (línea ~54)
- [ ] Activar workflow (toggle verde)
- [ ] Probar con POST a `/webhook/nutridiab/generate-token`

### 2. Validate and Save Workflow
**Archivo**: `n8n/workflows/validate-token-workflow.json`  
**Endpoint**: `POST /webhook/nutridiab/validate-and-save`

**Queries principales**:

1. Validar token:
```sql
SELECT * FROM nutridiab.validar_token('{{ $json.body.token }}');
```

2. Actualizar usuario:
```sql
UPDATE nutridiab.usuarios
SET 
  nombre = '{{ $json.nombre }}',
  apellido = '{{ $json.apellido }}',
  email = '{{ $json.email }}',
  telefono = '{{ $json.telefono }}',
  fecha_nacimiento = '{{ $json.fecha_nacimiento }}',
  tipo_diabetes = '{{ $json.tipo_diabetes }}',
  anios_diagnostico = {{ $json.anios_diagnostico || 'NULL' }},
  usa_insulina = {{ $json.usa_insulina || false }},
  medicamentos = '{{ $json.medicamentos }}',
  datos_completos = TRUE,
  updated_at = NOW()
WHERE "usuario ID" = {{ $json.usuario_id }}
RETURNING *;
```

3. Marcar token usado:
```sql
SELECT nutridiab.usar_token('{{ $json.token }}');
```

**Configurar**:
- [ ] Importar workflow en n8n
- [ ] Configurar credencial de Supabase en todos los nodos de Supabase (3 nodos)
- [ ] Activar workflow (toggle verde)
- [ ] Probar con POST a `/webhook/nutridiab/validate-and-save`

### 3. Workflow Principal (Modificar existente)
**Archivo**: `n8n/workflows/nutridiab.json`

**Query a agregar** (después de verificar términos):

```sql
-- Verificar datos completos del usuario
SELECT 
  "usuario ID", 
  datos_completos, 
  email_verificado,
  nombre,
  "remoteJid"
FROM nutridiab.usuarios 
WHERE "remoteJid" = '{{ $json.remoteJid }}';
```

**Lógica a implementar**:

```javascript
// Nodo IF: ¿Datos completos?
// Condición: {{ $json.datos_completos }} === false

// SI NO tiene datos (rama TRUE):
// 1. HTTP Request a /webhook/nutridiab/generate-token
// 2. Enviar mensaje WhatsApp con enlace

// SI tiene datos (rama FALSE):
// 3. Continuar con análisis nutricional normal
```

---

## 🧪 Testing de Workflows

### Test 1: Verificar Conexión a Supabase

```sql
-- En n8n, crea un workflow de prueba con nodo Postgres
SELECT current_schema(), current_database();

-- Debe retornar: nutridiab, postgres
```

### Test 2: Verificar Tablas

```sql
-- En n8n
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'nutridiab';

-- Debe mostrar: usuarios, Consultas, mensajes, tokens_acceso
```

### Test 3: Test de Usuario Existente

```sql
-- Consultar usuario de prueba
SELECT 
  "usuario ID",
  nombre,
  datos_completos,
  "AceptoTerminos"
FROM nutridiab.usuarios
LIMIT 1;
```

### Test 4: Generar Token (desde terminal)

```bash
curl -X POST https://wf.zynaptic.tech/webhook/nutridiab/generate-token \
  -H "Content-Type: application/json" \
  -d '{"usuario_id": 1}'
```

**Respuesta esperada**:
```json
{
  "success": true,
  "token": "abc123def456...",
  "enlace": "http://localhost:5173/registro?token=abc123...",
  "expira": "2025-11-22T20:00:00Z",
  "mensaje": "📋 Para completar tu registro..."
}
```

### Test 5: Validar y Guardar (desde terminal)

```bash
curl -X POST https://wf.zynaptic.tech/webhook/nutridiab/validate-and-save \
  -H "Content-Type: application/json" \
  -d '{
    "token": "TOKEN_DEL_PASO_ANTERIOR",
    "nombre": "Juan",
    "apellido": "Pérez",
    "email": "juan@test.com",
    "telefono": "+5491155555555",
    "fecha_nacimiento": "1980-01-15",
    "tipo_diabetes": "tipo2",
    "anios_diagnostico": 5,
    "usa_insulina": true,
    "medicamentos": "Metformina 850mg"
  }'
```

**Respuesta esperada**:
```json
{
  "success": true,
  "message": "Datos guardados exitosamente",
  "usuario": {
    "usuario ID": 1,
    "nombre": "Juan",
    "apellido": "Pérez",
    "datos_completos": true,
    ...
  }
}
```

---

## 🔍 Verificación en Base de Datos

### Verificar Token Generado:

```sql
SELECT 
  t.id,
  t.token,
  t."usuario ID",
  t.tipo,
  t.usado,
  t.expira,
  t.created_at,
  u.nombre,
  u."remoteJid"
FROM nutridiab.tokens_acceso t
JOIN nutridiab.usuarios u ON t."usuario ID" = u."usuario ID"
ORDER BY t.created_at DESC
LIMIT 5;
```

### Verificar Datos Guardados:

```sql
SELECT 
  "usuario ID",
  nombre,
  apellido,
  email,
  tipo_diabetes,
  datos_completos,
  email_verificado,
  updated_at
FROM nutridiab.usuarios
WHERE datos_completos = TRUE
ORDER BY updated_at DESC;
```

### Ver Estado de Todos los Usuarios:

```sql
SELECT * FROM nutridiab.vista_usuarios_estado
ORDER BY created_at DESC;
```

---

## 🚨 Troubleshooting

### Error: "relation does not exist"

**Problema**: No encuentra la tabla  
**Solución**: Verifica que el schema sea `nutridiab` en las credenciales

```sql
-- Verifica schema actual
SHOW search_path;

-- Debe incluir: nutridiab, public
```

### Error: "permission denied for schema"

**Problema**: Usuario sin permisos  
**Solución**: Usar usuario `postgres` de Supabase con permisos completos

### Error: "column does not exist"

**Problema**: Nombres de columnas con espacios  
**Solución**: Usar comillas dobles escapadas:

```sql
-- Correcto
"usuario ID"
"remoteJid"
"AceptoTerminos"

-- En JSON de n8n, escapar:
\"usuario ID\"
```

### Token Expirado

```sql
-- Limpiar tokens expirados
SELECT nutridiab.limpiar_tokens_expirados();

-- Ver tokens expirados
SELECT * FROM nutridiab.tokens_acceso
WHERE expira < NOW();
```

---

## 📦 Checklist de Configuración

### Supabase:
- [ ] Schema `nutridiab` creado
- [ ] Tablas creadas (usuarios, Consultas, mensajes, tokens_acceso)
- [ ] Funciones creadas (validar_token, usar_token, verificar_datos_usuario, etc.)
- [ ] Vista creada (vista_usuarios_estado)

### n8n:
- [ ] Credencial de Postgres/Supabase configurada con schema `nutridiab`
- [ ] Workflow "Generate Token" importado y activado
- [ ] Workflow "Validate and Save" importado y activado
- [ ] Workflow principal modificado con verificación de datos
- [ ] URLs actualizadas (frontend_url en generate-token)

### Frontend:
- [ ] Ruta `/registro` configurada
- [ ] Ruta `/registro-exitoso` configurada
- [ ] Variables de entorno con URL de n8n: `https://wf.zynaptic.tech`

### Testing:
- [ ] Test de conexión a Supabase
- [ ] Test de generar token
- [ ] Test de validar y guardar
- [ ] Test del flujo completo desde WhatsApp

---

## 📞 Soporte

Si tienes problemas:

1. **Verifica logs en n8n**: Executions → Ver workflow fallido
2. **Verifica logs en Supabase**: Logs → Postgres logs
3. **Revisa credenciales**: Settings → Credentials → Supabase
4. **Revisa schema**: SQL Editor → `SELECT current_schema();`

---

**Schema**: `nutridiab`  
**Base de datos**: PostgreSQL (Supabase)  
**Proyecto**: Nutridiab - Control Nutricional para Diabéticos  
**Versión**: 1.0  
**Fecha**: 2025-11-21

