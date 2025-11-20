# 🚀 Guía de Inicio Rápido

Esta guía te ayudará a tener tu aplicación corriendo en menos de 5 minutos.

## 📋 Prerrequisitos

Asegúrate de tener instalado:

- ✅ Node.js 18+ ([Descargar](https://nodejs.org/))
- ✅ Docker Desktop ([Descargar](https://www.docker.com/products/docker-desktop))
- ✅ Git

## 🎯 Pasos de Instalación

### 1️⃣ Configurar Variables de Entorno (30 segundos)

El archivo `.env` ya está creado con valores por defecto. Si necesitas modificarlo:

```env
N8N_PORT=5678
VITE_API_URL=http://localhost:5678
```

### 2️⃣ Iniciar n8n Backend (1 minuto)

```bash
# Desde la raíz del proyecto
docker-compose up -d
```

Espera a que el contenedor inicie (verás el log "Editor is now accessible").

✅ Verifica: Abre http://localhost:5678 en tu navegador

### 3️⃣ Configurar n8n Primera Vez (2 minutos)

1. Abre http://localhost:5678
2. Completa el formulario de registro (solo primera vez)
3. Importa los workflows de ejemplo:
   - Click en **"Workflows"** en el menú
   - Click en **"Import from File"**
   - Selecciona `n8n/workflows/health-check.json`
   - Repite para `crud-example.json`
4. Activa los workflows (toggle en cada uno)

### 4️⃣ Iniciar Frontend React (1 minuto)

```bash
# Abre una nueva terminal
cd frontend

# Instala dependencias (solo primera vez)
npm install

# Inicia el servidor de desarrollo
npm run dev
```

✅ Frontend disponible en: http://localhost:5173

## 🎉 ¡Listo!

Tu aplicación está corriendo. Ahora puedes:

1. **Ver la página de inicio**: http://localhost:5173
2. **Probar el CRUD**: http://localhost:5173/items
3. **Editar workflows**: http://localhost:5678

## 🧪 Verificar que Todo Funciona

### Test 1: Health Check

1. Ve a http://localhost:5173
2. Deberías ver "✓ Backend conectado correctamente"
3. Si ves un error, verifica que n8n esté corriendo

### Test 2: Crear un Item

1. Ve a http://localhost:5173/items
2. Click en "➕ Nuevo Item"
3. Completa el formulario
4. Click en "Crear Item"
5. Deberías ver el nuevo item en la lista

## 🐛 Solución de Problemas Comunes

### Error: "No se pudo conectar con el backend"

```bash
# Verifica que n8n esté corriendo
docker ps

# Deberías ver un contenedor llamado "nutridiabn8n"
# Si no está, inicia n8n:
docker-compose up -d

# Ver logs de n8n:
docker-compose logs -f
```

### Error: "Cannot GET /webhook/health"

El workflow no está activo en n8n:
1. Ve a http://localhost:5678
2. Abre el workflow "Health Check"
3. Activa el toggle en la esquina superior derecha
4. Debería aparecer en verde "Active"

### Error: "Port 5678 already in use"

Ya tienes algo corriendo en el puerto 5678:

```bash
# En Windows
netstat -ano | findstr :5678

# Detén el proceso o cambia el puerto en .env
N8N_PORT=5679
```

### Frontend no carga / Pantalla blanca

```bash
# Limpia caché e instala de nuevo
cd frontend
rm -rf node_modules package-lock.json
npm install
npm run dev
```

## 📚 Siguientes Pasos

Ahora que tu aplicación está funcionando:

1. **Explora los workflows**: Abre n8n y revisa cómo funcionan
2. **Modifica el frontend**: Edita componentes en `frontend/src/`
3. **Crea nuevos workflows**: Diseña tu propia lógica de negocio
4. **Lee la documentación**: Revisa README.md para más detalles

## 🆘 ¿Necesitas Ayuda?

- 📖 Revisa el [README.md](README.md) principal
- 🔍 Ve la [documentación de n8n](https://docs.n8n.io/)
- 💬 Abre un issue en GitHub

## 🎓 Recursos Útiles

### Comandos Útiles

```bash
# Ver logs de n8n
docker-compose logs -f

# Detener n8n
docker-compose down

# Reiniciar n8n
docker-compose restart

# Reconstruir (si cambias docker-compose.yml)
docker-compose up -d --build
```

### Estructura de URLs

- **Frontend**: http://localhost:5173
- **n8n Editor**: http://localhost:5678
- **Webhooks**: http://localhost:5678/webhook/{nombre}

### Archivos Importantes

- `docker-compose.yml` - Configuración de n8n
- `frontend/src/services/api.js` - Llamadas al backend
- `n8n/workflows/` - Workflows de ejemplo
- `.env` - Variables de entorno

---

**¡Happy Coding! 🚀**

Si todo funcionó correctamente, ya puedes empezar a desarrollar tu aplicación.

