# Nutridiab Frontend

Frontend de la aplicación Nutridiab construido con React + Vite. **Aplicación para el control nutricional de diabéticos**.

## 🚀 Inicio Rápido

### Instalación

```bash
npm install
```

### Desarrollo

```bash
npm run dev
```

La aplicación estará disponible en http://localhost:5173

### Build para Producción

```bash
npm run build
```

Los archivos optimizados estarán en la carpeta `dist/`.

### Preview de Producción

```bash
npm run preview
```

## 📁 Estructura del Proyecto

```
frontend/
├── public/              # Archivos estáticos
├── src/
│   ├── components/      # Componentes reutilizables
│   │   └── Layout.jsx   # Layout principal con navbar y footer
│   ├── pages/           # Páginas de la aplicación
│   │   ├── Home.jsx     # Página de inicio
│   │   ├── Items.jsx    # Gestión de items (CRUD)
│   │   └── About.jsx    # Información del proyecto
│   ├── services/        # Servicios y APIs
│   │   └── api.js       # Configuración de axios y llamadas a n8n
│   ├── App.jsx          # Componente principal
│   ├── App.css          # Estilos globales
│   ├── main.jsx         # Punto de entrada
│   └── index.css        # Reset y estilos base
├── index.html           # HTML principal
├── vite.config.js       # Configuración de Vite
└── package.json         # Dependencias
```

## 🔧 Configuración

### Variables de Entorno

Crea un archivo `.env` en la carpeta frontend:

```env
VITE_API_URL=http://localhost:5678
VITE_APP_NAME=NutriDia
```

### Proxy Configuration

El archivo `vite.config.js` incluye un proxy para el desarrollo:

```javascript
proxy: {
  '/webhook': {
    target: 'http://localhost:5678',
    changeOrigin: true,
  }
}
```

Esto permite hacer llamadas a `/webhook/*` desde el frontend sin problemas de CORS.

## 📡 Integración con n8n

### Servicio API

El archivo `src/services/api.js` contiene todas las funciones para comunicarse con n8n:

```javascript
import { apiService } from './services/api';

// Health check
await apiService.healthCheck();

// Obtener items
const items = await apiService.getItems();

// Crear item
await apiService.createItem({ name: 'Test', description: 'Desc' });
```

### Agregar Nuevos Endpoints

1. Crea el workflow en n8n con un webhook
2. Agrega la función en `src/services/api.js`:

```javascript
export const apiService = {
  // ... otros métodos
  
  newEndpoint: async (data) => {
    try {
      const response = await api.post('/webhook/new-endpoint', data);
      return response.data;
    } catch (error) {
      throw error;
    }
  },
};
```

3. Úsalo en tus componentes:

```javascript
import { apiService } from '../services/api';

const result = await apiService.newEndpoint({ key: 'value' });
```

## 🎨 Estilos

El proyecto utiliza CSS puro con variables CSS para temas:

```css
:root {
  --primary-color: #4CAF50;
  --secondary-color: #2196F3;
  --danger-color: #f44336;
  /* ... más variables */
}
```

Para modificar el tema, edita las variables en `src/App.css`.

## 📦 Dependencias Principales

- **React 18**: Librería UI
- **React Router DOM**: Enrutamiento
- **Axios**: Cliente HTTP
- **Vite**: Build tool y dev server

## 🔍 Desarrollo

### Agregar Nueva Página

1. Crea el componente en `src/pages/`:

```jsx
// src/pages/NewPage.jsx
function NewPage() {
  return (
    <div>
      <h1>Nueva Página</h1>
    </div>
  );
}

export default NewPage;
```

2. Agrega la ruta en `src/App.jsx`:

```jsx
import NewPage from './pages/NewPage'

<Routes>
  <Route path="/new-page" element={<NewPage />} />
</Routes>
```

3. Agrega el link en el navbar (`src/components/Layout.jsx`):

```jsx
<Link to="/new-page" className="navbar-link">
  Nueva Página
</Link>
```

## 🐛 Debugging

### Ver Peticiones HTTP

Abre las DevTools del navegador → Network tab para ver todas las peticiones a n8n.

### Logs de Axios

Los interceptores en `api.js` ya incluyen logs automáticos de errores.

## 📝 Notas

- El proxy de Vite solo funciona en desarrollo
- Para producción, configura CORS en n8n o usa un reverse proxy
- Los webhooks de n8n deben estar activos para que funcionen las peticiones

## 🚀 Deploy

### Build

```bash
npm run build
```

### Opciones de Deploy

- **Netlify**: Arrastra la carpeta `dist/`
- **Vercel**: Conecta el repositorio
- **GitHub Pages**: Usa `gh-pages`
- **Server propio**: Sirve la carpeta `dist/` con nginx o similar

## 📚 Recursos

- [Documentación de Vite](https://vitejs.dev/)
- [Documentación de React](https://react.dev/)
- [Documentación de React Router](https://reactrouter.com/)
- [Documentación de Axios](https://axios-http.com/)

