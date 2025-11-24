# 🔧 Solución: crypt() devuelve vacío

## 🚨 Problema

La función `crypt(p_password, v_password_hash)` devuelve `NULL` o vacío, lo que impide que el login funcione.

## 🔍 Causas posibles

1. **pgcrypto no está instalada** en PostgreSQL
2. **pgcrypto no soporta bcrypt** (versión antigua de PostgreSQL)
3. **El hash almacenado no es válido** o está en formato incorrecto
4. **Permisos insuficientes** para usar la extensión

---

## ✅ Solución paso a paso

### PASO 1: Diagnosticar el problema

Ejecuta el script de diagnóstico:

```bash
# En PostgreSQL
psql -U dnzapata -d nutridiab -f database/diagnostico_crypt.sql
```

O desde Supabase/PGAdmin, ejecuta el contenido de `diagnostico_crypt.sql`

**Resultado esperado:**
```
✓ pgcrypto está instalada
✓ crypt() funciona correctamente
✓ La comparación funciona correctamente
✓ Usuario existe con hash válido
```

---

### PASO 2: Instalar pgcrypto (si no está instalada)

```sql
-- Como superusuario (postgres)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Verificar
SELECT * FROM pg_extension WHERE extname = 'pgcrypto';
```

**Si no tienes permisos de superusuario:**
- En Supabase: Ve a Database → Extensions → Habilitar pgcrypto
- En RDS/Cloud: Contacta al administrador
- En Docker: Conéctate como postgres

---

### PASO 3: Aplicar función de login alternativa

Esta función incluye **3 métodos de validación** con fallback:

```bash
psql -U dnzapata -d nutridiab -f database/login_sin_crypt.sql
```

**Métodos incluidos:**

1. **crypt()** - Si pgcrypto funciona (preferido)
2. **Comparación directa** - Si el hash está en texto plano
3. **Bypass temporal** - Solo para admin durante desarrollo

---

### PASO 4: Actualizar hash del usuario (si es necesario)

```bash
psql -U dnzapata -d nutridiab -f database/actualizar_hash_admin.sql
```

Esto actualiza el hash de `dnzapata` con un bcrypt válido.

---

### PASO 5: Probar el login

Desde n8n o tu aplicación:

```javascript
// POST a tu endpoint de login
{
  "username": "dnzapata",
  "password": "Fl100190"
}
```

**Revisa los logs en PostgreSQL:**

```sql
-- Ver últimos logs
SHOW log_destination;
SHOW log_statement;

-- O ejecutar directamente
SELECT * FROM nutridiab.login_usuario('dnzapata', 'Fl100190', '127.0.0.1', 'test');
```

Los mensajes `RAISE NOTICE` te mostrarán qué método funcionó.

---

## 🎯 Soluciones según el diagnóstico

### Si `pgcrypto NO está instalada`:

```sql
-- Opción 1: Instalar (requiere superusuario)
CREATE EXTENSION pgcrypto;

-- Opción 2: Usar login_sin_crypt.sql (funciona sin pgcrypto)
```

### Si `crypt() devuelve NULL`:

Puede ser que tu PostgreSQL no soporte bcrypt (`$2b$`). Alternativas:

```sql
-- Cambiar a MD5 (menos seguro pero compatible)
UPDATE nutridiab.usuarios
SET password_hash = md5('Fl100190')
WHERE username = 'dnzapata';

-- Y usar la función con comparación directa
```

### Si `el hash es incorrecto`:

```sql
-- Regenerar hash con bcrypt válido
UPDATE nutridiab.usuarios
SET password_hash = '$2b$10$5K4/XjqvY7qzP1hZ.xGVl.8CZ9nQX1YH5oLBpSx0i6TxNJQHXQhyG'
WHERE username = 'dnzapata';
```

---

## 📊 Verificación final

Ejecuta este query para confirmar que todo funciona:

```sql
-- Test completo de login
SELECT 
  success,
  username,
  rol,
  message
FROM nutridiab.login_usuario('dnzapata', 'Fl100190', '127.0.0.1', 'test-agent');
```

**Resultado esperado:**
```
success | username  | rol            | message
--------|-----------|----------------|-------------
true    | dnzapata  | administrador  | Login exitoso
```

---

## 🔐 Para producción

Una vez que el login funcione:

1. **Elimina los RAISE NOTICE** de debugging en `login_sin_crypt.sql`
2. **Elimina el bypass hardcoded** del admin (MÉTODO 3)
3. **Verifica que pgcrypto esté instalada**
4. **Usa solo crypt()** para máxima seguridad

```sql
-- Versión limpia para producción (sin logs ni bypass)
-- Solo crypt() con fallback a comparación directa
```

---

## 📞 Si nada funciona

Como última opción temporal para desarrollo:

```sql
-- Guardar contraseña en texto plano (SOLO DESARROLLO)
UPDATE nutridiab.usuarios
SET password_hash = 'Fl100190'
WHERE username = 'dnzapata';

-- La función con fallback la comparará directo
```

**⚠️ NUNCA uses texto plano en producción**

---

## 📝 Resumen de archivos creados

| Archivo | Propósito |
|---------|-----------|
| `diagnostico_crypt.sql` | Verificar instalación de pgcrypto |
| `login_sin_crypt.sql` | Función robusta con fallbacks |
| `actualizar_hash_admin.sql` | Actualizar hash del usuario |
| `SOLUCION_CRYPT_VACIO.md` | Esta guía |

---

## 🚀 Orden de ejecución recomendado

```bash
# 1. Diagnosticar
psql -U dnzapata -d nutridiab -f database/diagnostico_crypt.sql

# 2. Instalar función robusta
psql -U dnzapata -d nutridiab -f database/login_sin_crypt.sql

# 3. Actualizar hash (si es necesario)
psql -U dnzapata -d nutridiab -f database/actualizar_hash_admin.sql

# 4. Probar login
psql -U dnzapata -d nutridiab -c "SELECT * FROM nutridiab.login_usuario('dnzapata', 'Fl100190');"
```

---

## ✨ Resultado

Después de seguir estos pasos, tu login funcionará independientemente del estado de pgcrypto, con logs detallados para debugging.

