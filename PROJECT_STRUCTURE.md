# 📂 Estructura del Proyecto

Este documento describe la organización completa del proyecto NutriDia.

## 🌳 Árbol de Directorios

```
nutridiabn8n8/
│
├── 📁 frontend/                    # Aplicación React SPA
│   ├── 📁 public/                  # Archivos estáticos públicos
│   │   └── vite.svg                # Logo de Vite
│   │
│   ├── 📁 src/                     # Código fuente de React
│   │   ├── 📁 components/          # Componentes reutilizables
│   │   │   ├── Layout.jsx          # Layout principal (navbar + footer)
│   │   │   └── Layout.css          # Estilos del layout
│   │   │
│   │   ├── 📁 pages/               # Páginas/Vistas de la aplicación
│   │   │   ├── Home.jsx            # Página de inicio
│   │   │   ├── Home.css
│   │   │   ├── Items.jsx           # Página de gestión de items (CRUD)
│   │   │   ├── Items.css
│   │   │   ├── About.jsx           # Página informativa
│   │   │   └── About.css
│   │   │
│   │   ├── 📁 services/            # Servicios y lógica de negocio
│   │   │   └── api.js              # Cliente Axios + funciones API
│   │   │
│   │   ├── App.jsx                 # Componente raíz con Router
│   │   ├── App.css                 # Estilos globales y variables CSS
│   │   ├── main.jsx                # Punto de entrada de React
│   │   └── index.css               # Reset y estilos base
│   │
│   ├── .env.example                # Ejemplo de variables de entorno
│   ├── .eslintrc.cjs               # Configuración de ESLint
│   ├── .gitignore                  # Archivos ignorados por Git
│   ├── index.html                  # HTML principal
│   ├── package.json                # Dependencias y scripts
│   ├── vite.config.js              # Configuración de Vite
│   └── README.md                   # Documentación del frontend
│
├── 📁 n8n/                         # Configuración y datos de n8n
│   ├── 📁 data/                    # Datos persistentes (generado por n8n)
│   │   └── .gitkeep
│   │
│   ├── 📁 workflows/               # Workflows de ejemplo
│   │   ├── health-check.json      # Workflow de health check
│   │   └── crud-example.json      # Workflow CRUD de ejemplo
│   │
│   └── README.md                   # Documentación de n8n
│
├── 📁 scripts/                     # Scripts de utilidad
│   ├── setup.sh                    # Script de setup para Linux/Mac
│   └── setup.ps1                   # Script de setup para Windows
│
├── .dockerignore                   # Archivos ignorados por Docker
├── .env                            # Variables de entorno (no en git)
├── .env.example                    # Ejemplo de variables de entorno
├── .gitignore                      # Archivos ignorados por Git
├── CONTRIBUTING.md                 # Guía de contribución
├── docker-compose.yml              # Orquestación de servicios (desarrollo)
├── docker-compose.prod.yml         # Orquestación para producción
├── LICENSE                         # Licencia MIT
├── PROJECT_STRUCTURE.md            # Este archivo
├── QUICK_START.md                  # Guía de inicio rápido
├── README.md                       # Documentación principal
└── WORKFLOWS.md                    # Guía de workflows en n8n
```

## 📝 Descripción de Archivos Clave

### 🔧 Configuración Raíz

| Archivo | Descripción |
|---------|-------------|
| `.env` | Variables de entorno (puerto n8n, API URL, etc.) |
| `.gitignore` | Archivos/carpetas ignorados por Git |
| `docker-compose.yml` | Define el servicio n8n para desarrollo |
| `docker-compose.prod.yml` | Configuración optimizada para producción |

### ⚛️ Frontend (React + Vite)

#### Configuración

| Archivo | Descripción |
|---------|-------------|
| `package.json` | Dependencias y scripts npm |
| `vite.config.js` | Config de Vite (puerto, proxy, plugins) |
| `.eslintrc.cjs` | Reglas de linting para código limpio |
| `index.html` | HTML base (punto de entrada) |

#### Código Fuente

| Archivo/Carpeta | Descripción |
|-----------------|-------------|
| `src/main.jsx` | Punto de entrada React (ReactDOM.render) |
| `src/App.jsx` | Componente raíz con React Router |
| `src/App.css` | Variables CSS y estilos globales |
| `src/components/` | Componentes reutilizables (Layout, etc.) |
| `src/pages/` | Páginas/vistas de la app |
| `src/services/api.js` | Cliente HTTP (Axios) + funciones API |

### 🔄 Backend (n8n)

| Archivo/Carpeta | Descripción |
|-----------------|-------------|
| `n8n/data/` | Datos persistentes de n8n (DB, credenciales) |
| `n8n/workflows/` | Workflows de ejemplo listos para importar |
| `n8n/README.md` | Documentación de workflows y endpoints |

### 📚 Documentación

| Archivo | Propósito | Audiencia |
|---------|-----------|-----------|
| `README.md` | Visión general del proyecto | Todos |
| `QUICK_START.md` | Configuración en 5 minutos | Nuevos usuarios |
| `WORKFLOWS.md` | Crear y trabajar con workflows | Desarrolladores |
| `CONTRIBUTING.md` | Cómo contribuir al proyecto | Colaboradores |
| `PROJECT_STRUCTURE.md` | Esta guía | Desarrolladores |
| `frontend/README.md` | Detalles del frontend | Frontend devs |
| `n8n/README.md` | Detalles de workflows | Backend devs |

### 🛠️ Scripts de Utilidad

| Script | Plataforma | Función |
|--------|-----------|---------|
| `scripts/setup.sh` | Linux/Mac | Setup automático del proyecto |
| `scripts/setup.ps1` | Windows | Setup automático del proyecto |

## 🗂️ Convenciones de Nombres

### Archivos React

- **Componentes**: `PascalCase.jsx` (ej: `Layout.jsx`)
- **Páginas**: `PascalCase.jsx` (ej: `Home.jsx`)
- **Servicios**: `camelCase.js` (ej: `api.js`)
- **Estilos**: `mismo-nombre.css` (ej: `Layout.css`)

### Carpetas

- **Minúsculas**: `components/`, `pages/`, `services/`
- **Plural cuando contiene múltiples**: `components/` no `component/`

### Workflows n8n

- **kebab-case.json**: `health-check.json`, `crud-example.json`

## 📦 Dependencias Principales

### Frontend

```json
{
  "react": "^18.2.0",
  "react-router-dom": "^6.20.0",
  "axios": "^1.6.2",
  "vite": "^5.0.8"
}
```

### Backend

- **n8n**: Última versión vía Docker
- **Docker**: Requerido para ejecutar n8n

## 🔄 Flujo de Datos

```
┌─────────────┐         ┌──────────────┐         ┌────────────┐
│   Browser   │◄────────│     React    │◄────────│  api.js    │
│  (Usuario)  │         │  Components  │         │  (Axios)   │
└─────────────┘         └──────────────┘         └──────┬─────┘
                                                         │
                                                         │ HTTP
                                                         ▼
                                                  ┌─────────────┐
                                                  │     n8n     │
                                                  │  Workflows  │
                                                  └─────────────┘
```

## 🎯 Rutas del Proyecto

### URLs de Desarrollo

| Servicio | URL | Propósito |
|----------|-----|-----------|
| Frontend | http://localhost:5173 | Interfaz de usuario |
| n8n Editor | http://localhost:5678 | Editor de workflows |
| API Webhooks | http://localhost:5678/webhook/* | Endpoints REST |

### Rutas del Frontend

| Ruta | Componente | Descripción |
|------|-----------|-------------|
| `/` | `Home.jsx` | Página de inicio |
| `/items` | `Items.jsx` | Gestión de items (CRUD) |
| `/about` | `About.jsx` | Información del proyecto |

## 🔐 Archivos Sensibles (No en Git)

```
.env
n8n/data/
node_modules/
frontend/dist/
frontend/node_modules/
```

Estos archivos están en `.gitignore` y no se suben al repositorio.

## 📈 Agregar Nuevos Módulos

### Nueva Página

1. Crear `frontend/src/pages/NuevaPagina.jsx`
2. Crear `frontend/src/pages/NuevaPagina.css`
3. Agregar ruta en `App.jsx`
4. Agregar link en `Layout.jsx`

### Nuevo Endpoint n8n

1. Crear workflow en n8n Editor
2. Exportar a `n8n/workflows/nuevo-workflow.json`
3. Agregar función en `frontend/src/services/api.js`
4. Documentar en `n8n/README.md`

### Nuevo Componente

1. Crear `frontend/src/components/NuevoComponente.jsx`
2. Crear `frontend/src/components/NuevoComponente.css`
3. Importar donde se necesite

## 🧹 Limpieza

### Limpiar dependencias

```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
```

### Limpiar Docker

```bash
docker-compose down
docker system prune -a
```

### Limpiar datos de n8n

```bash
# ⚠️ CUIDADO: Esto elimina todos los workflows y datos
rm -rf n8n/data
```

## 📊 Tamaño del Proyecto

- **Frontend (sin node_modules)**: ~100 KB
- **Backend (workflows)**: ~10 KB
- **Documentación**: ~50 KB
- **Total (sin dependencias)**: ~160 KB

Con dependencias:
- **Frontend (con node_modules)**: ~200 MB
- **n8n Docker image**: ~600 MB

## 🔍 Búsqueda de Archivos

### Por Tipo

```bash
# Todos los componentes React
find frontend/src -name "*.jsx"

# Todos los estilos
find frontend/src -name "*.css"

# Workflows de n8n
find n8n/workflows -name "*.json"
```

### Por Contenido

```bash
# Buscar uso de apiService
grep -r "apiService" frontend/src

# Buscar endpoints webhook
grep -r "/webhook/" .
```

## 🎓 Recursos Relacionados

- [React Docs](https://react.dev/)
- [Vite Docs](https://vitejs.dev/)
- [n8n Docs](https://docs.n8n.io/)
- [Docker Docs](https://docs.docker.com/)

---

**Última actualización**: 2025-11-20

