# 🔌 Guía Completa: Conectar con Datos Reales

Esta guía te llevará paso a paso desde la base de datos hasta ver datos reales en tu frontend.

---

## 📋 Resumen de lo que vas a hacer

1. ✅ Configurar base de datos en Supabase
2. ✅ Crear credenciales en n8n
3. ✅ Importar 5 workflows en n8n
4. ✅ Probar endpoints
5. ✅ Configurar frontend
6. ✅ Ver datos reales en el dashboard

**Tiempo estimado**: 30-45 minutos

---

## PASO 1: Configurar Supabase (10 min)

### 1.1 Ejecutar Schema Principal

1. Ve a [Supabase](https://supabase.com) → Tu proyecto
2. **SQL Editor** → **New query**
3. Copia todo el contenido de: `database/schema_nutridiab_complete.sql`
4. Click **"Run"** (Ctrl+Enter)
5. Verifica: ✅ "Success. No rows returned"

### 1.2 Ejecutar Migración de Campos

1. Nueva query en SQL Editor
2. Copia: `database/migration_usuarios_nuevos_campos.sql`
3. **Run**
4. Verifica mensajes de éxito

### 1.3 Verificar Todo Está OK

```sql
-- Ejecuta esto en SQL Editor:

-- 1. Ver tablas
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'nutridiab';
-- Debe mostrar: Consultas, mensajes, tokens_acceso, usuarios

-- 2. Ver estructura de usuarios
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_schema = 'nutridiab' AND table_name = 'usuarios'
ORDER BY ordinal_position;
-- Debe mostrar todos los campos incluyendo Activo, Bloqueado, etc.

-- 3. Verificar funciones
SELECT routine_name 
FROM information_schema.routines 
WHERE routine_schema = 'nutridiab';
-- Debe mostrar: validar_token, usar_token, verificar_datos_usuario, etc.
```

### 1.4 Insertar Usuario de Prueba (opcional)

```sql
-- Usuario de prueba para testing
INSERT INTO nutridiab.usuarios (
  "remoteJid",
  nombre,
  apellido,
  email,
  tipo_diabetes,
  "AceptoTerminos",
  datos_completos,
  email_verificado,
  "Activo"
) VALUES (
  '5491155555555@s.whatsapp.net',
  'Juan',
  'Pérez',
  'juan@test.com',
  'tipo2',
  TRUE,
  TRUE,
  TRUE,
  TRUE
) RETURNING "usuario ID", nombre, email;

-- Guardar el usuario ID que te devuelva
```

---

## PASO 2: Configurar n8n (15 min)

### 2.1 Obtener Datos de Conexión

En Supabase:
- **Settings** → **Database**
- Anota:
  - **Host**: `xxx.supabase.co`
  - **Password**: (tu password de DB)

### 2.2 Crear Credencial

1. Ve a https://wf.zynaptic.tech
2. Click en tu avatar (esquina superior derecha)
3. **Credentials** → **+ New Credential**
4. Busca: `postgres`
5. Selecciona: **Postgres**
6. Completa:

```
Credential name: Supabase - Nutridiab

Host: tu-proyecto.supabase.co
Database: postgres
User: postgres
Password: [TU_PASSWORD_AQUI]
Port: 5432
SSL: Allow ✅

Schema: nutridiab  ← IMPORTANTE
```

7. **Test** → debe mostrar éxito
8. **Save**

### 2.3 Importar Workflows

Importa estos 5 workflows en orden:

#### A) Generate Token Workflow
```
Archivo: n8n/workflows/generate-token-workflow.json
Endpoint: /webhook/nutridiab/generate-token
Método: POST
```

**Configuración**:
- Importar workflow
- Abrir nodo "Supabase - Generar Token"
- Credentials → Select: "Supabase - Nutridiab"
- Guardar nodo
- Abrir nodo "Construir Respuesta"
- Cambiar línea del `frontend_url` a tu dominio
- **Activar workflow** (toggle verde arriba a la derecha)
- **Guardar** (Ctrl+S)

#### B) Validate Token Workflow
```
Archivo: n8n/workflows/validate-token-workflow.json
Endpoint: /webhook/nutridiab/validate-and-save
Método: POST
```

**Configuración**:
- Importar
- Configurar credenciales en 3 nodos:
  - "Supabase - Validar Token"
  - "Supabase - Actualizar Usuario"
  - "Supabase - Marcar Token Usado"
- **Activar**
- **Guardar**

#### C) Admin Stats Workflow
```
Archivo: n8n/workflows/nutridiab-admin-stats.json
Endpoint: /webhook/nutridiab/admin/stats
Método: GET
```

**Configuración**:
- Importar
- Nodo "Postgres Stats" → Credentials: "Supabase - Nutridiab"
- **Activar**
- **Guardar**

#### D) Admin Usuarios Workflow
```
Archivo: n8n/workflows/nutridiab-admin-usuarios.json
Endpoint: /webhook/nutridiab/admin/usuarios
Método: GET
```

**Configuración**:
- Importar
- Nodo "Postgres Usuarios" → Credentials: "Supabase - Nutridiab"
- **Activar**
- **Guardar**

#### E) Admin Consultas Workflow
```
Archivo: n8n/workflows/nutridiab-admin-consultas.json
Endpoint: /webhook/nutridiab/admin/consultas
Método: GET
```

**Configuración**:
- Importar
- Nodo "Postgres Consultas" → Credentials: "Supabase - Nutridiab"
- **Activar**
- **Guardar**

---

## PASO 3: Probar Endpoints (10 min)

### 3.1 Test desde Terminal/PowerShell

```bash
# Test 1: Stats del Dashboard
curl https://wf.zynaptic.tech/webhook/nutridiab/admin/stats

# Debe retornar:
# {
#   "total_usuarios": 1,
#   "usuarios_activos": 1,
#   "total_consultas": 0,
#   "costo_total": 0,
#   ...
# }

# Test 2: Lista de Usuarios
curl https://wf.zynaptic.tech/webhook/nutridiab/admin/usuarios

# Debe retornar array de usuarios:
# [
#   {
#     "usuario ID": 1,
#     "nombre": "Juan",
#     "apellido": "Pérez",
#     ...
#   }
# ]

# Test 3: Generar Token
curl -X POST https://wf.zynaptic.tech/webhook/nutridiab/generate-token \
  -H "Content-Type: application/json" \
  -d "{\"usuario_id\": 1}"

# Debe retornar:
# {
#   "success": true,
#   "token": "abc123...",
#   "enlace": "http://...?token=abc123...",
#   ...
# }
```

### 3.2 Test desde Navegador

Abre en tu navegador:
```
https://wf.zynaptic.tech/webhook/nutridiab/admin/stats
```

Debes ver JSON con las estadísticas.

---

## PASO 4: Configurar Frontend (10 min)

### 4.1 Verificar Variables de Entorno

El archivo `frontend/src/constants/index.js` debe tener:
```javascript
export const API_URL = import.meta.env.VITE_API_URL || 'https://wf.zynaptic.tech';
```

### 4.2 Verificar Servicio API

El archivo `frontend/src/services/nutridiabApi.js` debe tener los endpoints correctos:
```javascript
getStats: async () => {
  const response = await api.get('/webhook/nutridiab/admin/stats');
  return response.data;
}
```

### 4.3 Iniciar Frontend

```bash
cd frontend
npm install  # Si no lo hiciste antes
npm run dev
```

### 4.4 Probar Dashboard

1. Abre: http://localhost:5173
2. Ve a: http://localhost:5173/dashboard
3. Debes ver:
   - **Datos reales** de Supabase
   - Si hay error, verifica que workflows estén activos

---

## PASO 5: Insertar Datos de Prueba (5 min)

Para ver el dashboard con más datos:

```sql
-- En Supabase SQL Editor:

-- 1. Insertar más usuarios
INSERT INTO nutridiab.usuarios ("remoteJid", nombre, apellido, email, tipo_diabetes, "AceptoTerminos", datos_completos, "Activo")
VALUES 
  ('549111111111@s.whatsapp.net', 'María', 'González', 'maria@test.com', 'tipo1', TRUE, TRUE, TRUE),
  ('549122222222@s.whatsapp.net', 'Carlos', 'López', 'carlos@test.com', 'tipo2', TRUE, TRUE, TRUE),
  ('549133333333@s.whatsapp.net', 'Ana', 'Martínez', 'ana@test.com', 'tipo1', TRUE, FALSE, TRUE);

-- 2. Insertar consultas de ejemplo
INSERT INTO nutridiab."Consultas" ("tipo", "usuario ID", "resultado", "Costo")
VALUES 
  ('texto', 1, 'Alimento: Empanada de carne. Hidratos: ~25g', 0.002),
  ('imagen', 1, 'Plato de pasta. Hidratos: ~65g', 0.015),
  ('audio', 2, 'Pizza mediana. Hidratos: ~80g', 0.008),
  ('texto', 2, 'Manzana. Hidratos: ~15g', 0.002),
  ('imagen', 3, 'Ensalada. Hidratos: ~10g', 0.015);

-- 3. Verificar datos insertados
SELECT 
  COUNT(*) as total_usuarios,
  (SELECT COUNT(*) FROM nutridiab."Consultas") as total_consultas
FROM nutridiab.usuarios;
```

---

## PASO 6: Verificación Final

### Checklist Completo

#### Supabase ✅
- [ ] Schema nutridiab creado
- [ ] Tablas creadas (usuarios, Consultas, mensajes, tokens_acceso)
- [ ] Funciones creadas
- [ ] Usuario de prueba insertado
- [ ] Datos de ejemplo insertados

#### n8n ✅
- [ ] Credencial "Supabase - Nutridiab" creada y probada
- [ ] Workflow generate-token importado y activo
- [ ] Workflow validate-token importado y activo
- [ ] Workflow admin-stats importado y activo
- [ ] Workflow admin-usuarios importado y activo
- [ ] Workflow admin-consultas importado y activo
- [ ] Todos los workflows tienen credenciales configuradas
- [ ] Todos los workflows muestran toggle verde (activos)

#### Frontend ✅
- [ ] npm install ejecutado
- [ ] npm run dev funcionando
- [ ] Dashboard abre sin errores
- [ ] Dashboard muestra datos reales (no mock)
- [ ] No hay errores en consola del navegador
- [ ] No hay errores en consola de terminal

#### Endpoints ✅
Probar cada uno desde terminal/navegador:
- [ ] GET /webhook/nutridiab/admin/stats
- [ ] GET /webhook/nutridiab/admin/usuarios
- [ ] GET /webhook/nutridiab/admin/consultas
- [ ] POST /webhook/nutridiab/generate-token
- [ ] POST /webhook/nutridiab/validate-and-save

---

## 🚨 Troubleshooting

### Error: "No se pudo conectar con el backend"

**Causa**: Workflows no activos o credenciales mal configuradas

**Solución**:
1. Ve a n8n → Workflows
2. Verifica que TODOS tengan toggle verde (activos)
3. Abre cada workflow → Ejecutar manualmente (Play button)
4. Si hay error, verifica credenciales en los nodos Postgres

### Error: "Connection refused" o "404"

**Causa**: URL incorrecta o workflow no activo

**Solución**:
```bash
# Verifica que la URL sea correcta:
curl https://wf.zynaptic.tech/webhook/nutridiab/admin/stats

# Si da 404, el workflow no está activo o la ruta es incorrecta
```

### Error: "relation does not exist"

**Causa**: Schema no configurado en credenciales

**Solución**:
1. n8n → Credentials → "Supabase - Nutridiab"
2. Editar → Schema: `nutridiab`
3. Guardar

### Dashboard muestra datos mock

**Causa**: Frontend no puede conectar con n8n o hay error en fetch

**Solución**:
1. Abre consola del navegador (F12)
2. Busca errores en Network tab
3. Verifica que las llamadas API se hagan a la URL correcta
4. Verifica que el servicio nutridiabApi esté importado en Dashboard.jsx

### CORS Error

**Causa**: n8n bloqueando peticiones desde el frontend

**Solución**:
En n8n, cada webhook debe tener:
- Response Mode: "Respond to Webhook"
- No configurar CORS manualmente (n8n lo maneja)

---

## 📊 Verificar que Todo Funciona

### Test Completo desde el Frontend

1. **Abrir Dashboard**: http://localhost:5173/dashboard

2. **Verificar Estadísticas**:
   - Total de usuarios (debe ser > 0)
   - Total de consultas
   - Costos
   - Gráficos con datos reales

3. **Verificar Actividad Reciente**:
   - Lista de consultas recientes
   - Nombres de usuarios
   - Tipos de consulta (texto/imagen/audio)
   - Costos por consulta

4. **Verificar Consola**:
   - Abrir DevTools (F12)
   - Tab Console: No debe haber errores rojos
   - Tab Network: Ver las peticiones a wf.zynaptic.tech exitosas (status 200)

---

## 🎉 ¡Listo!

Si llegaste hasta aquí y todo funciona:

✅ **Base de datos configurada** con schema nutridiab  
✅ **Credenciales en n8n** funcionando  
✅ **5 Workflows activos** procesando peticiones  
✅ **Frontend conectado** mostrando datos reales  
✅ **Dashboard funcional** con estadísticas en vivo  

**Próximo paso**: Conectar el workflow principal de WhatsApp para procesar consultas reales de usuarios.

---

## 📞 Soporte

Si tienes problemas:
1. Revisa la sección Troubleshooting
2. Verifica logs en n8n: Workflows → Executions
3. Verifica logs en Supabase: Logs → Postgres logs
4. Verifica consola del navegador (F12 → Console)

---

**Versión**: 1.0  
**Proyecto**: Nutridiab - Control Nutricional para Diabéticos  
**Fecha**: 2025-11-22

