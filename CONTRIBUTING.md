# Guía de Contribución

¡Gracias por tu interés en contribuir a Nutridiab! 🎉

## 🚀 Cómo Contribuir

### 1. Fork el Proyecto

Haz fork del repositorio y clónalo localmente:

```bash
git clone https://github.com/tu-usuario/nutridiabn8n8.git
cd nutridiabn8n8
```

### 2. Configura el Entorno

```bash
# Copia las variables de entorno
cp .env.example .env

# Inicia n8n
docker-compose up -d

# Instala dependencias del frontend
cd frontend
npm install
npm run dev
```

### 3. Crea una Rama

```bash
git checkout -b feature/nueva-funcionalidad
# o
git checkout -b fix/corregir-bug
```

### 4. Haz tus Cambios

- Escribe código limpio y comentado
- Sigue las convenciones de estilo del proyecto
- Asegúrate de que tu código funcione correctamente

### 5. Commit

Usa mensajes de commit descriptivos:

```bash
git add .
git commit -m "feat: agregar nueva funcionalidad X"
# o
git commit -m "fix: corregir bug en Y"
```

Convenciones de commits:
- `feat:` Nueva funcionalidad
- `fix:` Corrección de bug
- `docs:` Cambios en documentación
- `style:` Cambios de formato (no afectan el código)
- `refactor:` Refactorización de código
- `test:` Agregar o modificar tests
- `chore:` Tareas de mantenimiento

### 6. Push y Pull Request

```bash
git push origin feature/nueva-funcionalidad
```

Luego crea un Pull Request en GitHub con:
- Descripción clara de los cambios
- Screenshots si aplica
- Referencias a issues relacionados

## 📋 Estándares de Código

### JavaScript/React

- Usa componentes funcionales con hooks
- Nombres de componentes en PascalCase
- Nombres de archivos en PascalCase para componentes
- Props destructuring cuando sea posible
- Comentarios para lógica compleja

```javascript
// ✅ Bueno
function MyComponent({ title, onSubmit }) {
  const [state, setState] = useState(null);
  
  return <div>{title}</div>;
}

// ❌ Malo
function mycomponent(props) {
  return <div>{props.title}</div>;
}
```

### CSS

- Usa clases descriptivas
- Mobile-first approach
- Variables CSS para colores y tamaños
- BEM naming cuando sea apropiado

```css
/* ✅ Bueno */
.user-card {
  background-color: var(--card-bg);
}

.user-card__title {
  font-size: 18px;
}

/* ❌ Malo */
.uc {
  background-color: #fff;
}
```

### n8n Workflows

- Nombres descriptivos para workflows
- Comentarios en nodos complejos
- Manejo de errores apropiado
- Validación de datos de entrada

## 🧪 Testing

Antes de hacer PR, verifica:

1. El frontend compila sin errores: `npm run build`
2. No hay errores de linting: `npm run lint`
3. La aplicación funciona correctamente en desarrollo
4. Los workflows de n8n están activos y funcionan

## 🐛 Reportar Bugs

Al reportar un bug, incluye:

1. **Descripción clara** del problema
2. **Pasos para reproducir**
3. **Comportamiento esperado**
4. **Comportamiento actual**
5. **Screenshots** si aplica
6. **Entorno**: SO, versión de Node, navegador, etc.

### Template de Bug Report

```markdown
**Descripción del Bug**
Descripción clara y concisa del bug.

**Pasos para Reproducir**
1. Ve a '...'
2. Haz click en '...'
3. Observa el error

**Comportamiento Esperado**
Qué debería pasar.

**Comportamiento Actual**
Qué está pasando.

**Screenshots**
Si aplica, agrega screenshots.

**Entorno:**
- SO: [e.g. Windows 11]
- Navegador: [e.g. Chrome 120]
- Node: [e.g. 18.17.0]
```

## 💡 Sugerir Mejoras

Para sugerir mejoras o nuevas funcionalidades:

1. Revisa que no exista ya un issue similar
2. Crea un issue con el tag `enhancement`
3. Describe claramente la mejora propuesta
4. Explica el beneficio para los usuarios
5. Si es posible, propón una implementación

## 📝 Documentación

La documentación es importante. Si agregas una funcionalidad:

- Actualiza el README si es necesario
- Agrega comentarios en el código
- Documenta nuevos endpoints de API
- Actualiza los workflows de ejemplo

## 🔍 Code Review

Todos los PRs pasan por code review. Esperamos:

- Código limpio y legible
- Sin código comentado innecesario
- Sin console.logs en producción
- Manejo apropiado de errores
- Responsive design

## ❓ Preguntas

Si tienes preguntas sobre cómo contribuir:

1. Revisa la documentación existente
2. Busca en issues cerrados
3. Crea un issue con el tag `question`

## 🙏 Agradecimientos

Cada contribución, grande o pequeña, es valiosa. ¡Gracias por hacer de Nutridiab un mejor proyecto!

---

**Happy Coding! 🚀**

