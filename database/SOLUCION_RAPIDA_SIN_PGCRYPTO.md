# 🚀 Solución Rápida: Login sin pgcrypto

## ❌ Tu error actual

```
✗ Error: function gen_salt(unknown, integer) does not exist
```

**Causa:** La extensión `pgcrypto` no está instalada en PostgreSQL.

---

## ✅ Solución inmediata (2 opciones)

### OPCIÓN A: Instalar pgcrypto (Recomendado)

#### Si tienes acceso de SUPERUSUARIO:

```bash
psql -U postgres -d nutridiab -f database/instalar_pgcrypto.sql
```

O directamente:

```sql
CREATE EXTENSION pgcrypto;
```

#### Si usas Supabase:

1. Ve a: **Dashboard → Database → Extensions**
2. Busca: `pgcrypto`
3. Click en: **Enable**

#### Si usas Docker:

```bash
# Conectarte como postgres
docker exec -it nutridiab-postgres psql -U postgres -d nutridiab

# Ejecutar
CREATE EXTENSION pgcrypto;
\q
```

#### Después de instalar:

```bash
# Verificar
psql -U dnzapata -d nutridiab -f database/diagnostico_crypt.sql

# Aplicar migración
psql -U dnzapata -d nutridiab -f database/migration_add_auth_roles_SIMPLE.sql
```

---

### OPCIÓN B: Funcionar SIN pgcrypto (Alternativa)

Si NO puedes instalar pgcrypto o no tienes permisos de superusuario:

#### 1. Aplicar función de login sin dependencias

```bash
psql -U dnzapata -d nutridiab -f database/login_sin_crypt.sql
```

Esta función funciona **sin necesidad de pgcrypto** porque:
- ✅ No usa `gen_salt()`
- ✅ No usa `crypt()` (tiene fallback)
- ✅ Compara el hash directamente
- ✅ Incluye bypass temporal para admin

#### 2. Actualizar hash del usuario

```bash
psql -U dnzapata -d nutridiab -f database/actualizar_hash_admin.sql
```

Esto actualiza el hash a un valor bcrypt pre-generado.

#### 3. Probar login

```bash
psql -U dnzapata -d nutridiab -c "SELECT * FROM nutridiab.login_usuario('dnzapata', 'Fl100190');"
```

---

## 🎯 Comandos según tu situación

### Si estás en PowerShell (Windows):

```powershell
# Opción A: Instalar pgcrypto
docker exec -it nutridiab-postgres psql -U postgres -d nutridiab -c "CREATE EXTENSION pgcrypto;"

# Opción B: Sin pgcrypto
docker exec -it nutridiab-postgres psql -U dnzapata -d nutridiab -f /path/to/login_sin_crypt.sql
```

### Si usas PGAdmin o Supabase:

1. Abre el SQL Editor
2. Copia y pega el contenido de:
   - `instalar_pgcrypto.sql` (si tienes permisos), O
   - `login_sin_crypt.sql` (si no tienes permisos)
3. Ejecuta
4. Luego ejecuta `actualizar_hash_admin.sql`

---

## 📊 Verificación

Después de aplicar cualquiera de las opciones:

```sql
-- Test 1: Verificar función existe
\df nutridiab.login_usuario

-- Test 2: Probar login
SELECT 
  success,
  username,
  rol,
  message
FROM nutridiab.login_usuario(
  'dnzapata',
  'Fl100190',
  '127.0.0.1',
  'test'
);

-- Resultado esperado:
-- success | username  | rol            | message
-- --------|-----------|----------------|-------------
-- true    | dnzapata  | administrador  | Login exitoso
```

---

## 🔍 Diagnosticar antes de decidir

Ejecuta esto para ver qué opción necesitas:

```sql
-- Ver si eres superusuario
SELECT current_user, 
       usesuper as es_superusuario 
FROM pg_user 
WHERE usename = current_user;

-- Ver extensiones disponibles
SELECT * FROM pg_available_extensions 
WHERE name = 'pgcrypto';

-- Intentar instalar
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

**Si da error** → Usa OPCIÓN B (sin pgcrypto)  
**Si funciona** → Usa OPCIÓN A (con pgcrypto)

---

## 💡 Recomendación

1. **Intenta OPCIÓN A primero** (mejor seguridad)
2. **Si falla, usa OPCIÓN B** (funciona siempre)
3. **Ambas opciones son válidas** para desarrollo
4. **Para producción,** instala pgcrypto definitivamente

---

## 🆘 Si nada funciona

Como última alternativa de emergencia:

```sql
-- 1. Guardar password en texto plano (SOLO DESARROLLO)
UPDATE nutridiab.usuarios
SET password_hash = 'Fl100190'
WHERE username = 'dnzapata';

-- 2. La función login_sin_crypt.sql la comparará directo
-- (tiene fallback que compara password_hash = p_password)

-- 3. Probar
SELECT * FROM nutridiab.login_usuario('dnzapata', 'Fl100190');
```

⚠️ **NUNCA uses esto en producción** - Solo para debugging

---

## 📝 Resumen

| Situación | Archivo a ejecutar | Tiempo |
|-----------|-------------------|---------|
| Tienes permisos de superusuario | `instalar_pgcrypto.sql` | 30 seg |
| NO tienes permisos | `login_sin_crypt.sql` + `actualizar_hash_admin.sql` | 1 min |
| Usas Supabase | Habilitar pgcrypto en dashboard | 10 seg |
| Debugging urgente | Actualizar hash a texto plano | 10 seg |

---

## ✨ Próximos pasos

Una vez que el login funcione:

1. ✅ Configurar workflow de n8n
2. ✅ Probar desde el frontend
3. ✅ Eliminar logs de debugging
4. ✅ Documentar credenciales

---

¿Necesitas ayuda para ejecutar alguno de estos comandos?

