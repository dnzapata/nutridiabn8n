# NutriDia - SPA React + n8n Backend

Proyecto Full Stack utilizando React como frontend y n8n como backend para automatización y lógica de negocio.

## 🚀 Estructura del Proyecto

```
nutridiabn8n8/
├── frontend/              # Aplicación React SPA
├── n8n/                   # Configuración y workflows de n8n
├── docker-compose.yml     # Orquestación de servicios
└── README.md
```

## 📋 Requisitos Previos

- Node.js >= 18.x
- Docker y Docker Compose
- npm o yarn

## 🛠️ Instalación y Configuración

### 1. Clonar y configurar variables de entorno

```bash
# Copiar archivo de ejemplo
cp .env.example .env

# Editar .env con tus configuraciones
```

### 2. Iniciar n8n con Docker

```bash
docker-compose up -d
```

n8n estará disponible en: http://localhost:5678

### 3. Instalar y ejecutar Frontend

```bash
cd frontend
npm install
npm run dev
```

Frontend disponible en: http://localhost:5173

## 🔧 Configuración de n8n

### Acceso Inicial

1. Visita http://localhost:5678
2. Crea tu cuenta de administrador
3. Los workflows se guardarán automáticamente en `./n8n/data`

### Webhooks

Los webhooks de n8n siguen este formato:
```
http://localhost:5678/webhook/{nombre-webhook}
```

## 📡 Integración Frontend - Backend

El frontend está configurado para comunicarse con n8n mediante:

- **API Service**: `frontend/src/services/api.js`
- **Base URL**: Configurada en variables de entorno
- **Endpoints**: Definidos en workflows de n8n

### Ejemplo de llamada desde React:

```javascript
import api from './services/api';

// GET request
const data = await api.get('/webhook/get-data');

// POST request
const result = await api.post('/webhook/create-item', {
  name: 'Example',
  value: 123
});
```

## 🎯 Workflows Disponibles

Los workflows de ejemplo se encuentran en `n8n/workflows/`:

- **health-check**: Verificación de estado del backend
- **crud-example**: Operaciones CRUD básicas
- **nutridiab**: 🩺 **Sistema completo** de asistente nutricional para diabéticos vía WhatsApp
  - Procesa texto, imágenes y audio
  - Calcula hidratos de carbono con IA
  - Gestión de usuarios y términos
  - Base de datos en Supabase
  - Ver documentación completa en `n8n/NUTRIDIAB.md`

## 🚀 Despliegue

### Desarrollo Local
```bash
docker-compose up -d
cd frontend && npm run dev
```

### Producción con Dokploy (VPS)
```bash
# Ver guía completa en DEPLOY_DOKPLOY.md
# Docker Compose específico: docker-compose.dokploy.yml
# Checklist paso a paso: DEPLOY_CHECKLIST.md
```

### Producción Genérica
```bash
docker-compose -f docker-compose.prod.yml up -d
cd frontend && npm run build
```

## 📚 Documentación Adicional

- [n8n Documentation](https://docs.n8n.io/)
- [React Documentation](https://react.dev/)

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 🩺 NutriDiab - Proyecto Destacado

Este repositorio incluye **NutriDiab**, un asistente de IA completo para análisis nutricional:

### Características:
- 💬 Chatbot vía WhatsApp
- 📸 Análisis de imágenes de comidas (Vision AI)
- 🎤 Transcripción y análisis de audio
- 🤖 IA (GPT-4) para calcular hidratos de carbono
- 📊 Dashboard de administración en React
- 💾 Base de datos PostgreSQL (Supabase)
- 💰 Control de costos de API
- 👥 Gestión de usuarios y términos
- ✅ **NUEVO**: Verificación de datos personales
- 🔐 **NUEVO**: Sistema de enlaces tokenizados
- 📧 **NUEVO**: Validación de email
- 📝 **NUEVO**: Formulario de registro web

### Documentación:
- **`n8n/NUTRIDIAB.md`** - Documentación completa del workflow
- **`INTEGRACION_NUTRIDIAB.md`** - Guía de integración frontend-backend

### Dashboard Admin:
Accede a http://localhost:5173/dashboard para ver:
- Estadísticas en tiempo real
- Usuarios registrados
- Consultas realizadas
- Análisis de costos

---

## 📝 Licencia

MIT License - ver archivo LICENSE para más detalles

