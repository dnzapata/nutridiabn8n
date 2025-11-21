# 🎯 Guía de Inicio - Nutridiab

¡Bienvenido a tu nuevo proyecto React + n8n! Esta guía te llevará paso a paso desde cero hasta tener tu aplicación funcionando. **Aplicación para el control nutricional de diabéticos**.

---

## ⚡ Opción Rápida: Script Automático

### En Windows (PowerShell):
```powershell
.\scripts\setup.ps1
```

### En Linux/Mac:
```bash
chmod +x scripts/setup.sh
./scripts/setup.sh
```

El script hará todo automáticamente. Si prefieres hacerlo manual, sigue leyendo ⬇️

---

## 📋 Requisitos Previos

Antes de comenzar, verifica que tienes instalado:

### 1. Node.js (v18 o superior)
```bash
node --version
```
Si no está instalado: https://nodejs.org/

### 2. Docker Desktop
```bash
docker --version
```
Si no está instalado: https://www.docker.com/products/docker-desktop

### 3. Git (opcional pero recomendado)
```bash
git --version
```

---

## 🚀 Instalación Manual Paso a Paso

### Paso 1: Configurar Variables de Entorno ⚙️

El archivo `.env` ya existe con configuración por defecto. Si quieres personalizarlo:

```env
# Puerto de n8n
N8N_PORT=5678

# URL del API para el frontend
VITE_API_URL=http://localhost:5678

# Nombre de la aplicación
VITE_APP_NAME=NutriDia
```

---

### Paso 2: Iniciar n8n Backend 🐳

```bash
# Desde la raíz del proyecto
docker-compose up -d
```

**Verificar que esté corriendo:**
```bash
docker ps
```

Deberías ver un contenedor llamado `nutridiabn8n` en estado `Up`.

**Ver logs en tiempo real:**
```bash
docker-compose logs -f
```

**Acceder a n8n:**
Abre tu navegador en: http://localhost:5678

---

### Paso 3: Configurar n8n (Primera vez) 🔧

1. **Abre n8n**: http://localhost:5678

2. **Completa el registro** (primera vez):
   - Email
   - Contraseña
   - Nombre

3. **Importar workflows de ejemplo**:
   
   a. Click en **"Workflows"** en el menú lateral
   
   b. Click en **"Import from File"** (botón arriba a la derecha)
   
   c. Navega a `n8n/workflows/` en tu proyecto
   
   d. Selecciona `health-check.json`
   
   e. Click en "Import"
   
   f. Repite para `crud-example.json`

4. **Activar los workflows**:
   
   a. Abre el workflow "Health Check"
   
   b. Click en el toggle "Inactive/Active" (arriba a la derecha)
   
   c. Debería cambiar a verde "Active"
   
   d. Repite para "CRUD Example"

---

### Paso 4: Instalar Frontend React 📦

```bash
# Navega a la carpeta frontend
cd frontend

# Instala las dependencias (solo primera vez)
npm install
```

**Esto tomará unos minutos...**

---

### Paso 5: Iniciar Frontend 🎨

```bash
# Asegúrate de estar en la carpeta frontend
npm run dev
```

Verás algo como:
```
  VITE v5.0.8  ready in 500 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: use --host to expose
  ➜  press h + enter to show help
```

**Abrir en el navegador:**
http://localhost:5173

---

## ✅ Verificar que Todo Funciona

### Test 1: ¿Frontend carga? ✓

Ve a: http://localhost:5173

Deberías ver la página de inicio de Nutridiab con:
- Navbar verde con logo
- Sección "Estado del Backend"
- Cards de características

### Test 2: ¿Backend conectado? ✓

En la página de inicio, busca:

```
✓ Backend conectado correctamente
Estado: ok
Servicio: n8n-backend
```

Si ves esto, ¡perfecto! ✅

Si ves un error ❌:
- Verifica que n8n esté corriendo: `docker ps`
- Verifica que el workflow esté activo en n8n
- Revisa los logs: `docker-compose logs -f`

### Test 3: ¿CRUD funciona? ✓

1. Ve a: http://localhost:5173/items

2. Click en **"+ Nuevo Item"**

3. Completa el formulario:
   - Nombre: "Mi primer item"
   - Descripción: "Esto es una prueba"

4. Click en **"Crear Item"**

5. Deberías ver el nuevo item en la lista ✅

---

## 🎉 ¡Felicidades!

Tu aplicación está funcionando correctamente. Ahora puedes:

### 🔍 Explorar

- **Frontend**: Navega por las diferentes páginas
- **n8n Editor**: Explora y modifica los workflows
- **Código**: Revisa el código fuente en `frontend/src/`

### 📚 Aprender

- **README.md**: Información general del proyecto
- **WORKFLOWS.md**: Cómo crear workflows en n8n
- **PROJECT_STRUCTURE.md**: Entender la estructura
- **frontend/README.md**: Detalles del frontend

### 🛠️ Desarrollar

1. **Crear nuevas páginas** en `frontend/src/pages/`
2. **Crear workflows** en n8n (http://localhost:5678)
3. **Agregar componentes** en `frontend/src/components/`
4. **Definir endpoints** en n8n workflows

---

## 🆘 Solución de Problemas

### ❌ Error: "No se pudo conectar con el backend"

**Causa**: n8n no está corriendo o workflow inactivo

**Solución**:
```bash
# Verificar Docker
docker ps

# Si no está corriendo
docker-compose up -d

# Ver logs
docker-compose logs -f
```

Luego verifica que el workflow esté **Active** en n8n.

---

### ❌ Error: "Cannot find module 'react'"

**Causa**: Dependencias no instaladas

**Solución**:
```bash
cd frontend
npm install
```

---

### ❌ Error: "Port 5678 is already in use"

**Causa**: Algo más está usando el puerto

**Solución opción 1** - Cambiar puerto:
```env
# En .env
N8N_PORT=5679
```

**Solución opción 2** - Liberar puerto (Windows):
```powershell
# Ver qué usa el puerto
netstat -ano | findstr :5678

# Matar el proceso (reemplaza PID)
taskkill /PID <PID> /F
```

---

### ❌ Error: "npm run dev" no funciona

**Causa**: No estás en la carpeta correcta

**Solución**:
```bash
# Asegúrate de estar en frontend/
cd frontend
npm run dev
```

---

### ❌ Pantalla en blanco en el navegador

**Solución**:
```bash
cd frontend
rm -rf node_modules
npm install
npm run dev
```

---

## 📱 Estructura de URLs

Una vez que todo está funcionando:

| Servicio | URL | Para qué sirve |
|----------|-----|----------------|
| **Frontend** | http://localhost:5173 | Tu aplicación React |
| **n8n Editor** | http://localhost:5678 | Crear/editar workflows |
| **API Health** | http://localhost:5678/webhook/health | Verificar backend |
| **API Items** | http://localhost:5678/webhook/items | Endpoint CRUD |

---

## 🔄 Comandos Útiles

### Docker

```bash
# Ver contenedores corriendo
docker ps

# Ver logs en tiempo real
docker-compose logs -f

# Detener n8n
docker-compose down

# Reiniciar n8n
docker-compose restart

# Eliminar todo y empezar de cero
docker-compose down -v
```

### Frontend

```bash
# Instalar dependencias
npm install

# Modo desarrollo
npm run dev

# Build para producción
npm run build

# Preview de producción
npm run preview

# Linter
npm run lint
```

---

## 🎓 Siguientes Pasos

### Para Beginners 🌱

1. ✅ Completa esta guía
2. 📖 Lee el README.md
3. 🔍 Explora el código en `frontend/src/pages/Home.jsx`
4. 🎨 Modifica los estilos en los archivos `.css`
5. 🔄 Crea un workflow simple en n8n

### Para Developers 💻

1. ✅ Setup completo
2. 📚 Lee WORKFLOWS.md para crear endpoints
3. 🏗️ Lee PROJECT_STRUCTURE.md
4. 🛠️ Crea tu primer endpoint personalizado
5. ⚛️ Desarrolla nuevas páginas en React

### Para Avanzados 🚀

1. ✅ Setup + docs
2. 🗄️ Integra una base de datos (PostgreSQL/MongoDB)
3. 🔐 Implementa autenticación JWT
4. 📧 Agrega notificaciones por email
5. 🐳 Deploy a producción

---

## 💡 Tips Profesionales

### 🔥 Hot Reload

Vite tiene Hot Module Replacement. Cualquier cambio en el código se reflejará instantáneamente en el navegador.

### 🐛 DevTools

Usa React DevTools:
- [Chrome Extension](https://chrome.google.com/webstore/detail/react-developer-tools/fmkadmapgofadopljbjfkapdkoienihi)
- [Firefox Extension](https://addons.mozilla.org/en-US/firefox/addon/react-devtools/)

### 📊 n8n Executions

En n8n, ve a **"Executions"** para ver:
- Historial de todas las ejecuciones
- Datos de entrada/salida
- Errores y warnings
- Tiempo de ejecución

### 🎨 Personalizar Estilos

Los colores principales están en `frontend/src/App.css`:

```css
:root {
  --primary-color: #4CAF50;    /* Verde principal */
  --secondary-color: #2196F3;  /* Azul */
  --danger-color: #f44336;     /* Rojo */
}
```

Cambia estos valores para personalizar toda la app.

---

## 🙋 ¿Necesitas Ayuda?

1. **Revisa la documentación** en los archivos .md
2. **Busca en los issues** de GitHub
3. **Lee los logs** de Docker y la consola del navegador
4. **Consulta la documentación oficial**:
   - [React Docs](https://react.dev/)
   - [n8n Docs](https://docs.n8n.io/)
   - [Vite Docs](https://vitejs.dev/)

---

## 🎊 ¡Listo para Desarrollar!

Ya tienes todo configurado. ¡Es hora de crear algo increíble!

```
     🚀
    /||\
   / || \
  /  ||  \
 /_______\
 
 ¡Feliz Desarrollo!
```

---

**Proyecto**: Nutridiab - Control Nutricional para Diabéticos  
**Stack**: React + n8n  
**Versión**: 1.0.0  
**Última actualización**: 2025-11-20

