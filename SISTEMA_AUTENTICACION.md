# Sistema de Autenticación y Roles - NutriDiab

## 📋 Resumen de Cambios

Se ha implementado un sistema completo de autenticación con roles para el dashboard administrativo de NutriDiab.

### Cambios Principales:

1. **Base de Datos:**
   - Agregados campos: `username`, `password_hash`, `rol`, `ultimo_login`
   - Nueva tabla: `sesiones` para manejo de tokens
   - Funciones SQL para login, validación y logout
   - Usuario administrador creado: `dnzapata`

2. **Frontend:**
   - Nueva página de Login
   - Sistema de autenticación con AuthContext
   - Protección de rutas (ProtectedRoute)
   - Eliminada página Home - acceso directo al sistema
   - Dashboard restringido solo a administradores

3. **Backend (n8n):**
   - 4 nuevos workflows de autenticación
   - Integración con PostgreSQL/Supabase

---

## 🗄️ Base de Datos

### Migración SQL

Ejecutar el archivo:
```bash
database/migration_add_auth_roles.sql
```

Este script:
- ✅ Agrega columnas de autenticación a la tabla `usuarios`
- ✅ Crea tabla `sesiones` para manejo de tokens
- ✅ Crea funciones: `login_usuario`, `validar_sesion`, `logout_usuario`, `es_administrador`
- ✅ Crea usuario administrador: **dnzapata** con contraseña **Fl100190**

### Estructura de Roles

El sistema soporta 2 roles:

| Rol | Descripción | Permisos |
|-----|-------------|----------|
| `administrador` | Acceso completo | Dashboard, estadísticas, gestión de usuarios |
| `usuario` | Acceso limitado | Solo visualización de datos propios |

### Usuario Administrador Inicial

```
Username: dnzapata
Password: Fl100190
Rol: administrador
```

**⚠️ IMPORTANTE:** Cambiar la contraseña después del primer login en producción.

---

## 🔐 Sistema de Autenticación

### Flujo de Login

1. Usuario ingresa username y password en `/login`
2. Frontend envía credenciales a n8n webhook
3. N8n ejecuta función `login_usuario()` en PostgreSQL
4. PostgreSQL valida credenciales usando bcrypt
5. Si es válido, genera token de sesión (válido 7 días)
6. Frontend guarda token en localStorage
7. Usuario redirigido al Dashboard

### Flujo de Validación de Sesión

1. Al cargar la app, AuthContext verifica si hay token
2. Envía token a n8n para validación
3. N8n ejecuta `validar_sesion()` en PostgreSQL
4. PostgreSQL verifica que:
   - Token existe
   - No ha expirado
   - Sesión está activa
   - Usuario está activo y no bloqueado
5. Retorna datos del usuario si es válido

### Flujo de Logout

1. Usuario hace clic en "Salir"
2. Frontend envía token a n8n
3. N8n ejecuta `logout_usuario()` en PostgreSQL
4. PostgreSQL marca sesión como inactiva
5. Frontend limpia localStorage
6. Usuario redirigido al Login

---

## 🎨 Frontend

### Estructura de Archivos

```
frontend/src/
├── context/
│   └── AuthContext.jsx          # Contexto global de autenticación
├── components/
│   ├── Layout.jsx               # Layout con info de usuario y logout
│   ├── Layout.css               # Estilos actualizados
│   └── ProtectedRoute.jsx       # HOC para proteger rutas
├── pages/
│   ├── Login.jsx                # Página de login
│   ├── Login.css                # Estilos de login
│   └── Dashboard.jsx            # Dashboard (solo admins)
└── services/
    └── nutridiabApi.js          # Funciones de API actualizadas
```

### AuthContext

Provee:
- `user`: Datos del usuario autenticado
- `loading`: Estado de carga
- `isAuthenticated`: Boolean de autenticación
- `isAdmin()`: Verifica si es administrador
- `login(username, password)`: Función de login
- `logout()`: Función de logout
- `getToken()`: Obtiene token actual

### ProtectedRoute

Componente que envuelve rutas protegidas:

```jsx
<ProtectedRoute requireAdmin={true}>
  <Dashboard />
</ProtectedRoute>
```

Características:
- Verifica autenticación
- Verifica rol de administrador (si `requireAdmin={true}`)
- Redirige al login si no autenticado
- Muestra mensaje de error si no tiene permisos

---

## 🔄 Workflows de n8n

### 1. nutridiab-auth-login.json

**Endpoint:** `POST /webhook/nutridiab/auth/login`

**Request:**
```json
{
  "username": "dnzapata",
  "password": "Fl100190"
}
```

**Response (éxito):**
```json
{
  "success": true,
  "user_id": 1,
  "username": "dnzapata",
  "nombre": "David",
  "apellido": "Zapata",
  "email": "admin@nutridiab.com",
  "rol": "administrador",
  "token": "abc123...",
  "message": "Login exitoso"
}
```

**Response (error):**
```json
{
  "success": false,
  "message": "Usuario o contraseña incorrectos"
}
```

### 2. nutridiab-auth-validate.json

**Endpoint:** `POST /webhook/nutridiab/auth/validate`

**Request:**
```json
{
  "token": "abc123..."
}
```

**Response:**
```json
{
  "valida": true,
  "usuario_id": 1,
  "username": "dnzapata",
  "nombre": "David",
  "apellido": "Zapata",
  "email": "admin@nutridiab.com",
  "rol": "administrador"
}
```

### 3. nutridiab-auth-logout.json

**Endpoint:** `POST /webhook/nutridiab/auth/logout`

**Request:**
```json
{
  "token": "abc123..."
}
```

**Response:**
```json
{
  "success": true,
  "message": "Sesión cerrada exitosamente"
}
```

### 4. nutridiab-auth-check-admin.json

**Endpoint:** `POST /webhook/nutridiab/auth/check-admin`

**Request:**
```json
{
  "token": "abc123..."
}
```

**Response:**
```json
{
  "es_admin": true
}
```

---

## 🚀 Instalación y Configuración

### Paso 1: Migración de Base de Datos

```bash
# Conectar a PostgreSQL/Supabase
psql -h <host> -U postgres -d postgres

# Ejecutar migración
\i database/migration_add_auth_roles.sql
```

### Paso 2: Importar Workflows en n8n

1. Acceder a n8n: `https://wf.zynaptic.tech`
2. Ir a "Workflows" → "Import from File"
3. Importar los 4 workflows:
   - `n8n/workflows/nutridiab-auth-login.json`
   - `n8n/workflows/nutridiab-auth-validate.json`
   - `n8n/workflows/nutridiab-auth-logout.json`
   - `n8n/workflows/nutridiab-auth-check-admin.json`
4. Activar cada workflow

### Paso 3: Actualizar Frontend

```bash
cd frontend

# Instalar dependencias (si es necesario)
npm install

# Iniciar desarrollo
npm run dev
```

### Paso 4: Probar el Sistema

1. Acceder a: `http://localhost:5173`
2. Automáticamente redirige a `/login`
3. Ingresar credenciales:
   - Username: `dnzapata`
   - Password: `Fl100190`
4. Debe redirigir al Dashboard

---

## 🔒 Seguridad

### Contraseñas

Las contraseñas se almacenan usando **bcrypt** con 10 salt rounds.

**Generar hash de contraseña (Node.js):**
```javascript
const bcrypt = require('bcrypt');
const hash = bcrypt.hashSync('tu_contraseña', 10);
console.log(hash);
```

### Tokens de Sesión

- Generados con `gen_random_bytes(32)` de PostgreSQL
- Codificados en hexadecimal (64 caracteres)
- Validez: 7 días
- Almacenados en tabla `sesiones`

### Protección de Rutas

Todas las rutas del dashboard están protegidas:
- Requieren autenticación
- Dashboard requiere rol de administrador
- Validación en frontend y backend

---

## 📝 Crear Nuevos Usuarios Administradores

### Opción 1: SQL Directo

```sql
INSERT INTO nutridiab.usuarios (
  "remoteJid",
  "username", 
  "password_hash",
  "nombre",
  "apellido",
  "email",
  "rol",
  "Activo",
  "AceptoTerminos",
  "datos_completos",
  "email_verificado"
)
VALUES (
  'admin2@nutridiab.system',
  'nuevo_admin',
  '$2b$10$...', -- Hash de la contraseña
  'Nombre',
  'Apellido',
  'email@example.com',
  'administrador',
  TRUE,
  TRUE,
  TRUE,
  TRUE
);
```

### Opción 2: Node.js Script

```javascript
const bcrypt = require('bcrypt');
const { Client } = require('pg');

async function crearAdmin() {
  const client = new Client({
    host: 'your-host',
    database: 'postgres',
    user: 'dnzapata',
    password: 'your-password',
  });

  await client.connect();

  const passwordHash = bcrypt.hashSync('nueva_contraseña', 10);

  await client.query(`
    INSERT INTO nutridiab.usuarios 
    ("remoteJid", "username", "password_hash", "nombre", "apellido", "email", "rol", "Activo", "AceptoTerminos", "datos_completos", "email_verificado")
    VALUES 
    ($1, $2, $3, $4, $5, $6, $7, TRUE, TRUE, TRUE, TRUE)
  `, [
    'admin@nutridiab.system',
    'nuevo_admin',
    passwordHash,
    'Nombre',
    'Apellido',
    'email@example.com',
    'administrador'
  ]);

  await client.end();
  console.log('✅ Admin creado exitosamente');
}

crearAdmin();
```

---

## 🐛 Troubleshooting

### El login no funciona

1. **Verificar que los workflows están activos:**
   - Ir a n8n y verificar que los workflows de auth están activados

2. **Verificar credenciales de PostgreSQL:**
   - En cada workflow, verificar las credenciales de la base de datos

3. **Verificar que la migración se ejecutó correctamente:**
   ```sql
   SELECT * FROM nutridiab.usuarios WHERE username = 'dnzapata';
   SELECT * FROM information_schema.tables WHERE table_name = 'sesiones';
   ```

### No puedo acceder al Dashboard

1. **Verificar que el usuario es administrador:**
   ```sql
   SELECT username, rol FROM nutridiab.usuarios WHERE username = 'dnzapata';
   ```

2. **Limpiar localStorage:**
   - Abrir DevTools → Application → Local Storage
   - Eliminar `nutridiab_token` y `nutridiab_user`
   - Recargar y volver a hacer login

### Token expirado constantemente

1. **Verificar tiempo del servidor:**
   ```sql
   SELECT NOW();
   ```

2. **Ajustar duración de tokens:**
   En `migration_add_auth_roles.sql`, cambiar:
   ```sql
   v_expira := NOW() + INTERVAL '7 days';
   ```

---

## 📚 Referencia de API

### nutridiabApi.login(username, password)

Inicia sesión con usuario y contraseña.

**Returns:** `{ success, user_id, username, nombre, apellido, email, rol, token, message }`

### nutridiabApi.validateSession(token)

Valida un token de sesión.

**Returns:** `{ valida, usuario_id, username, nombre, apellido, email, rol }`

### nutridiabApi.logout(token)

Cierra sesión.

**Returns:** `{ success, message }`

### nutridiabApi.checkAdmin(token)

Verifica si un usuario es administrador.

**Returns:** `{ es_admin }`

---

## ✅ Checklist de Implementación

- [x] Migración SQL ejecutada
- [x] Usuario administrador creado
- [x] Workflows de n8n importados y activados
- [x] Frontend actualizado
- [x] AuthContext implementado
- [x] Rutas protegidas
- [x] Layout actualizado con logout
- [x] Página de Login creada
- [x] Home eliminado (acceso directo al sistema)
- [ ] Probar login con dnzapata
- [ ] Probar acceso al Dashboard
- [ ] Probar logout
- [ ] Cambiar contraseña del administrador en producción

---

## 📄 Licencia

Este sistema es parte del proyecto NutriDiab.

---

## 📞 Soporte

Para problemas o dudas sobre el sistema de autenticación, contactar al equipo de desarrollo.

