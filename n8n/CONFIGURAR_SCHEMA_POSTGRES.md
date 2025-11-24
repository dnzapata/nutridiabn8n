# 🔧 Configurar Schema por Defecto en n8n + PostgreSQL

## 🎯 Problema

Cuando usas nodos Postgres en n8n, necesitas especificar el schema `nutridiab` en cada query:

```sql
SELECT * FROM nutridiab.usuarios;  ❌ Repetitivo
```

## ✅ Soluciones

---

### **SOLUCIÓN 1: Configurar usuario PostgreSQL** ⭐ RECOMENDADO

Ejecuta esto **una vez** en PostgreSQL:

```sql
-- Establecer search_path permanente para el usuario
ALTER ROLE dnzapata SET search_path TO nutridiab, public;

-- Verificar
SHOW search_path;

-- Aplicar a sesión actual
SET search_path TO nutridiab, public;
```

**Beneficios:**
- ✅ Configuración única
- ✅ Afecta todas las conexiones
- ✅ Funciona automáticamente en n8n
- ✅ No necesitas modificar queries

**Después de esto, en n8n puedes usar:**

```sql
-- Antes:
SELECT * FROM nutridiab.login_usuario('dnzapata', 'Fl100190');

-- Ahora:
SELECT * FROM login_usuario('dnzapata', 'Fl100190');  ✅ Más limpio
```

---

### **SOLUCIÓN 2: Especificar schema en cada query**

Si no puedes modificar el usuario, usa siempre el schema completo:

**En n8n - Nodo Postgres:**

```json
{
  "operation": "executeQuery",
  "query": "SELECT * FROM nutridiab.login_usuario($1, $2)",
  "parameters": {
    "parameter1": "{{ $json.username }}",
    "parameter2": "{{ $json.password }}"
  }
}
```

**Ventajas:**
- ✅ Explícito y claro
- ✅ No requiere configuración adicional
- ✅ Funciona siempre

**Desventajas:**
- ❌ Repetitivo
- ❌ Más verbose

---

### **SOLUCIÓN 3: Nodo de configuración al inicio**

Agregar un nodo Postgres al inicio de cada workflow:

```
Workflow: nutridiab-auth-login
├─ [1] HTTP Request (Trigger)
├─ [2] Postgres: SET search_path  ← Nuevo
└─ [3] Postgres: SELECT login_usuario()
```

**Nodo 2 - SET search_path:**
```sql
SET search_path TO nutridiab, public;
```

⚠️ **Limitación:** Solo funciona si todos los nodos usan la **misma conexión/sesión**.

---

## 🚀 Implementación para NutriDiab

### Paso 1: Configurar usuario (RECOMENDADO)

Ejecuta este script en tu base de datos:

```bash
psql -U postgres -d nutridiab -f database/configurar_schema_usuario.sql
```

O copia y ejecuta:

```sql
-- Configurar search_path para el usuario dnzapata
ALTER ROLE dnzapata SET search_path TO nutridiab, public;

-- Verificar configuración
SELECT rolname, rolconfig
FROM pg_roles
WHERE rolname = 'dnzapata';

-- Debe mostrar:
-- rolname  | rolconfig
-- ---------|----------------------------------------
-- dnzapata | {search_path=nutridiab,public}
```

---

### Paso 2: Probar en n8n

**Crear workflow de prueba:**

1. **Agregar nodo Postgres**
   - Credentials: Tu conexión PostgreSQL
   - Operation: `Execute Query`
   - Query:
   ```sql
   SHOW search_path;
   ```

2. **Ejecutar y verificar**
   - Debe devolver: `nutridiab, public`

3. **Probar sin schema explícito**
   - Query:
   ```sql
   SELECT * FROM usuarios LIMIT 1;
   ```
   - Debe funcionar sin especificar `nutridiab.usuarios`

---

### Paso 3: Actualizar workflows existentes

Después de configurar el usuario, puedes simplificar tus queries:

#### Workflow: nutridiab-auth-login

**Antes:**
```sql
SELECT * FROM nutridiab.login_usuario(
  '{{ $json.username }}',
  '{{ $json.password }}',
  '{{ $json.ip }}',
  '{{ $json.userAgent }}'
)
```

**Después:**
```sql
SELECT * FROM login_usuario(
  '{{ $json.username }}',
  '{{ $json.password }}',
  '{{ $json.ip }}',
  '{{ $json.userAgent }}'
)
```

#### Workflow: nutridiab-auth-validate

**Antes:**
```sql
SELECT * FROM nutridiab.validar_sesion('{{ $json.token }}')
```

**Después:**
```sql
SELECT * FROM validar_sesion('{{ $json.token }}')
```

---

## 🔍 Verificación

### Test 1: Verificar search_path del usuario

```sql
-- Como usuario dnzapata
SELECT current_user, current_setting('search_path');

-- Resultado esperado:
-- current_user | current_setting
-- -------------|-------------------
-- dnzapata     | nutridiab, public
```

### Test 2: Probar query sin schema

```sql
-- Esto debe funcionar:
SELECT * FROM usuarios LIMIT 1;

-- Si da error "relation usuarios does not exist"
-- → El search_path no está configurado correctamente
```

### Test 3: Probar función sin schema

```sql
-- Esto debe funcionar:
SELECT * FROM login_usuario('dnzapata', 'Fl100190');

-- Si da error "function login_usuario does not exist"
-- → Especifica el schema: nutridiab.login_usuario
```

---

## 📊 Comparación de métodos

| Método | Ventajas | Desventajas | Recomendación |
|--------|----------|-------------|---------------|
| **ALTER ROLE** | Permanente, automático, limpio | Requiere permisos admin | ⭐⭐⭐⭐⭐ |
| **Schema explícito** | Siempre funciona, claro | Repetitivo, verbose | ⭐⭐⭐⭐ |
| **SET en workflow** | Flexible | Puede no persistir entre nodos | ⭐⭐ |

---

## 🛠️ Troubleshooting

### Error: "relation usuarios does not exist"

**Causa:** El search_path no incluye el schema `nutridiab`

**Solución:**
```sql
-- Verificar schema
SELECT current_schema();

-- Listar schemas disponibles
SELECT schema_name FROM information_schema.schemata;

-- Verificar que la tabla existe
SELECT schemaname, tablename 
FROM pg_tables 
WHERE tablename = 'usuarios';

-- Configurar search_path
ALTER ROLE dnzapata SET search_path TO nutridiab, public;
```

### Error: "function login_usuario does not exist"

**Causa:** La función está en el schema `nutridiab` pero no está en el search_path

**Solución:**
```sql
-- Verificar que la función existe
SELECT routine_schema, routine_name
FROM information_schema.routines
WHERE routine_name = 'login_usuario';

-- Usar schema completo temporalmente
SELECT * FROM nutridiab.login_usuario(...);

-- O configurar search_path
ALTER ROLE dnzapata SET search_path TO nutridiab, public;
```

### n8n no reconoce el search_path

**Posible causa:** Necesitas reconectar o reiniciar n8n

**Solución:**
```bash
# Reiniciar n8n
docker restart n8n-container

# O desde npm
npm run stop
npm run start
```

---

## 📝 Script automatizado

Para aplicar la configuración automáticamente:

```bash
# Ejecutar desde el directorio del proyecto
psql -U postgres -d nutridiab -c "ALTER ROLE dnzapata SET search_path TO nutridiab, public;"

# Verificar
psql -U dnzapata -d nutridiab -c "SHOW search_path;"
```

---

## 🎯 Recomendación final

**Para tu proyecto NutriDiab:**

1. ✅ Ejecuta `ALTER ROLE dnzapata SET search_path TO nutridiab, public;`
2. ✅ Reinicia las conexiones de n8n (o reinicia n8n)
3. ✅ Simplifica tus queries eliminando `nutridiab.` de todos los workflows
4. ✅ Mantén documentado que el schema por defecto es `nutridiab`

**Beneficios:**
- Código más limpio
- Menos errores de tipeo
- Más fácil de mantener
- Compatible con herramientas externas

---

## 💡 Tip Pro

Si trabajas con **múltiples schemas**, puedes:

```sql
-- Priorizar búsqueda:
ALTER ROLE dnzapata SET search_path TO nutridiab, analytics, public;

-- Ahora busca en orden:
-- 1. nutridiab
-- 2. analytics
-- 3. public
```

---

## ✅ Checklist de implementación

- [ ] Ejecutar `ALTER ROLE dnzapata SET search_path TO nutridiab, public;`
- [ ] Verificar con `SHOW search_path;`
- [ ] Probar query simple: `SELECT * FROM usuarios LIMIT 1;`
- [ ] Probar función: `SELECT * FROM login_usuario('test', 'test');`
- [ ] Actualizar workflows en n8n (opcional, para limpiar código)
- [ ] Documentar en README del proyecto

---

¿Necesitas ayuda para ejecutar la configuración?

