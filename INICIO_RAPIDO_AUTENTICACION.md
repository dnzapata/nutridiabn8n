# 🚀 Inicio Rápido - Sistema de Autenticación

## Lo que se ha hecho

Se ha implementado un sistema completo de login con usuario y contraseña. Ahora:

- ✅ No hay página de inicio, va directo al login
- ✅ Hay roles: Administrador y Usuario
- ✅ Solo administradores pueden ver el Dashboard
- ✅ Usuario creado: `dnzapata` con contraseña `Fl100190`

## Instalación en 3 Pasos

### 1. Base de Datos (5 minutos)

Conéctate a PostgreSQL y ejecuta:

```bash
psql -h tu-host -U postgres -d postgres

# Dentro de psql:
\i database/migration_add_auth_roles.sql
```

### 2. n8n (5 minutos)

1. Ve a tu n8n: `https://wf.zynaptic.tech`
2. Importa estos 4 archivos (están en `n8n/workflows/`):
   - `nutridiab-auth-login.json`
   - `nutridiab-auth-validate.json`
   - `nutridiab-auth-logout.json`
   - `nutridiab-auth-check-admin.json`
3. Activa cada uno (toggle "Active" arriba a la derecha)

### 3. Probar (2 minutos)

1. Abre la app: `http://localhost:5173`
2. Login:
   - **Usuario:** `dnzapata`
   - **Contraseña:** `Fl100190`
3. ¡Listo! Deberías ver el Dashboard

## Si algo falla

### Error: "Usuario o contraseña incorrectos"

1. Verifica que ejecutaste el SQL correctamente
2. En PostgreSQL ejecuta:
```sql
SELECT username, rol FROM nutridiab.usuarios WHERE username = 'dnzapata';
```

### Error: "Network Error"

1. Verifica que los workflows de n8n están activos
2. Verifica la URL en `frontend/src/services/api.js`

### Error: "No puedo acceder al Dashboard"

1. Verifica que el usuario tiene rol 'administrador':
```sql
SELECT username, rol FROM nutridiab.usuarios WHERE username = 'dnzapata';
```

## Archivos importantes

- **INSTRUCCIONES_DEPLOY.md** - Guía detallada paso a paso
- **SISTEMA_AUTENTICACION.md** - Documentación técnica completa
- **RESUMEN_CAMBIOS_AUTENTICACION.md** - Lista de todos los cambios

## Crear más usuarios administradores

### Opción 1: Usar el script

```bash
cd scripts
node generate-password-hash.js "MiContraseña123"
# Copia el SQL que muestra y ejecútalo en PostgreSQL
```

### Opción 2: SQL directo

```sql
-- Genera el hash en: https://bcrypt-generator.com/
-- Con 10 rounds

INSERT INTO nutridiab.usuarios (
  "remoteJid", "username", "password_hash",
  "nombre", "apellido", "email", "rol",
  "Activo", "AceptoTerminos", "datos_completos", "email_verificado"
)
VALUES (
  'nuevo@nutridiab.system',
  'nuevo_usuario',
  '$2b$10$...', -- Tu hash aquí
  'Nombre',
  'Apellido',
  'email@example.com',
  'administrador',
  TRUE, TRUE, TRUE, TRUE
);
```

## Seguridad en Producción

⚠️ **IMPORTANTE:** Cambia la contraseña de `dnzapata` en producción:

```bash
# Genera nuevo hash
node scripts/generate-password-hash.js "TuNuevaContraseñaSegura"

# Ejecuta en PostgreSQL
UPDATE nutridiab.usuarios 
SET password_hash = '$2b$10$...' -- El hash generado
WHERE username = 'dnzapata';
```

## Estructura del Login

```
┌─────────────────────────────────────┐
│         Usuario ingresa             │
│     username + password             │
└─────────┬───────────────────────────┘
          │
          ▼
┌─────────────────────────────────────┐
│    Frontend envía a n8n             │
│    POST /webhook/.../auth/login     │
└─────────┬───────────────────────────┘
          │
          ▼
┌─────────────────────────────────────┐
│   n8n ejecuta función SQL           │
│   login_usuario()                   │
└─────────┬───────────────────────────┘
          │
          ▼
┌─────────────────────────────────────┐
│   PostgreSQL valida con bcrypt      │
│   Genera token de sesión            │
└─────────┬───────────────────────────┘
          │
          ▼
┌─────────────────────────────────────┐
│   Token guardado en localStorage    │
│   Redirige al Dashboard             │
└─────────────────────────────────────┘
```

## ¿Necesitas ayuda?

1. Lee **INSTRUCCIONES_DEPLOY.md** - tiene solución a problemas comunes
2. Revisa los logs de:
   - PostgreSQL
   - n8n
   - Console del navegador (F12)

## Características

### ✨ Incluye:

- Login moderno y animado
- Sesiones con tokens (duran 7 días)
- Logout en el navbar
- Protección de rutas automática
- Mensajes de error claros
- Responsive (móvil y desktop)

### 🔒 Seguridad:

- Contraseñas con bcrypt
- Tokens únicos de 64 caracteres
- Validación en cada request
- Sesiones pueden ser invalidadas
- Verificación de roles

---

¡Ya está todo listo! Solo sigue los 3 pasos de arriba. 🎉

