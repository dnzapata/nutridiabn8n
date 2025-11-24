# 🚀 EMPEZAR AQUÍ - Solución al error de gen_salt()

## ❌ Tu error

```
✗ Error: function gen_salt(unknown, integer) does not exist
```

---

## ✅ SOLUCIÓN EN 1 COMANDO

### Paso 1: Diagnosticar automáticamente

```bash
psql -U dnzapata -d nutridiab -f database/autoconfig_login.sql
```

Este script te dirá **exactamente** qué comando ejecutar según tu configuración.

---

### Paso 2: Ejecutar el comando recomendado

El script anterior te mostrará uno de estos comandos:

#### OPCIÓN A: Si tienes pgcrypto (mejor)
```bash
psql -U dnzapata -d nutridiab -f database/migration_add_auth_roles_SIMPLE.sql
```

#### OPCIÓN B: Si necesitas instalar pgcrypto
```bash
psql -U postgres -d nutridiab -f database/instalar_pgcrypto.sql
# Luego:
psql -U dnzapata -d nutridiab -f database/migration_add_auth_roles_SIMPLE.sql
```

#### OPCIÓN C: Si NO puedes instalar pgcrypto (más simple)
```bash
psql -U dnzapata -d nutridiab -f database/login_simple_directo.sql
```

---

## 🎯 Si tienes prisa (1 minuto)

**Ejecuta esto y listo:**

```bash
psql -U dnzapata -d nutridiab -f database/login_simple_directo.sql
```

Este script:
- ✅ Funciona SIN pgcrypto
- ✅ Crea la función de login
- ✅ Configura el usuario admin
- ✅ Prueba automáticamente el login
- ✅ Te muestra el resultado

---

## 🐳 Si usas Docker

```bash
# Ver contenedores corriendo
docker ps

# Ejecutar el script (reemplaza <container-name>)
docker exec -i <container-name> psql -U dnzapata -d nutridiab < database/login_simple_directo.sql

# O conectarte y ejecutar manualmente
docker exec -it <container-name> psql -U dnzapata -d nutridiab
\i database/login_simple_directo.sql
```

---

## 💻 Si usas PGAdmin / Supabase / GUI

1. **Abrir SQL Editor**
2. **Copiar contenido** de `database/login_simple_directo.sql`
3. **Ejecutar** (F5 o botón ▶️)
4. **Ver resultado** en la salida

---

## ✅ Verificar que funciona

Después de ejecutar cualquiera de los scripts:

```sql
-- Test del login
SELECT 
  success,
  username,
  rol,
  message
FROM nutridiab.login_usuario('dnzapata', 'Fl100190');
```

**Resultado esperado:**
```
success | username  | rol            | message
--------|-----------|----------------|-------------
true    | dnzapata  | administrador  | Login exitoso
```

---

## 📁 Archivos creados (en orden de utilidad)

| Archivo | Para qué sirve | Cuándo usarlo |
|---------|---------------|---------------|
| `autoconfig_login.sql` | 🔍 Diagnostica y recomienda | **Empieza aquí** |
| `login_simple_directo.sql` | ⚡ Solución rápida sin pgcrypto | Si tienes prisa |
| `instalar_pgcrypto.sql` | 🔐 Instala pgcrypto | Si eres admin/superusuario |
| `login_sin_crypt.sql` | 🛡️ Login robusto con fallbacks | Si quieres múltiples opciones |
| `diagnostico_crypt.sql` | 🔬 Pruebas detalladas | Para debugging profundo |
| `actualizar_hash_admin.sql` | 🔑 Actualiza password del admin | Si el hash está corrupto |

---

## 🆘 Troubleshooting rápido

### Error: "permission denied"
```bash
# Usa el usuario postgres
psql -U postgres -d nutridiab -f database/login_simple_directo.sql
```

### Error: "database does not exist"
```bash
# Verifica el nombre de tu base de datos
psql -U dnzapata -l

# Cambia "nutridiab" por el nombre correcto
```

### Error: "connection refused"
```bash
# Verifica que PostgreSQL esté corriendo
docker ps               # Si usas Docker
systemctl status postgresql   # Si es nativo en Linux
```

### Error: "schema nutridiab does not exist"
```sql
-- Crear el schema primero
CREATE SCHEMA IF NOT EXISTS nutridiab;
```

---

## 🔄 Siguiente paso después del login

Una vez que `login_usuario()` funcione:

1. ✅ **Configurar n8n**
   - Crear workflow de login
   - Apuntar a la función `nutridiab.login_usuario()`

2. ✅ **Probar desde frontend**
   - Actualizar `frontend/src/services/api.js`
   - Hacer POST al endpoint de n8n

3. ✅ **Limpiar código de desarrollo**
   - Eliminar logs `RAISE NOTICE`
   - Remover bypass hardcoded del admin
   - Actualizar documentación

---

## 💡 Tip Pro

Para ver todos los logs y debugging en tiempo real:

```sql
-- Habilitar logs detallados (solo en sesión actual)
SET client_min_messages TO NOTICE;

-- Ejecutar login
SELECT * FROM nutridiab.login_usuario('dnzapata', 'Fl100190');

-- Verás todos los RAISE NOTICE en la salida
```

---

## 📞 ¿Necesitas ayuda?

Si después de seguir esta guía sigues teniendo problemas:

1. Ejecuta `autoconfig_login.sql` y copia la salida
2. Ejecuta `diagnostico_crypt.sql` y copia la salida
3. Comparte los mensajes de error exactos

---

## ⚡ TL;DR (Demasiado Largo, No Leí)

```bash
# Ejecuta esto y ya:
psql -U dnzapata -d nutridiab -f database/login_simple_directo.sql

# ¿Funcionó?
psql -U dnzapata -d nutridiab -c "SELECT * FROM nutridiab.login_usuario('dnzapata', 'Fl100190');"
```

✨ **Listo. Ahora puedes continuar con n8n y el frontend.**

