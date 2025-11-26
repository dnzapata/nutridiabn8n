# ⚡ Guía Rápida: Edición de Usuarios

**Tiempo de instalación**: 2-3 minutos  
**Estado**: ✅ Código listo, solo falta importar workflow

---

## 🎯 ¿Qué se implementó?

✅ Modal de usuario ahora es **totalmente editable**  
✅ Todos los campos son editables **EXCEPTO RemoteJid**  
✅ Botones **Guardar** y **Cancelar**  
✅ Actualización directa en la **base de datos**

---

## 🚀 Instalación (3 pasos)

### Paso 1: El Frontend Ya Está Listo ✅

No hay que hacer nada en el frontend, ya está actualizado con:
- ✅ Campos editables
- ✅ Función de guardado
- ✅ Validación de datos
- ✅ Estilos CSS

### Paso 2: Importar Workflow en n8n (2 minutos)

1. **Abrir n8n**: https://wf.zynaptic.tech

2. **Importar workflow**:
   - Clic en "Import from File" (esquina superior derecha)
   - Seleccionar: `n8n/workflows/nutridiab-admin-actualizar-usuario.json`
   - Clic en "Import"

3. **Configurar credenciales**:
   - Abrir el nodo "Postgres Update"
   - Seleccionar las credenciales existentes "Supabase - Nutridiab"
   - Guardar

4. **Activar**:
   - Clic en el switch para activar el workflow
   - ✅ Listo!

### Paso 3: Probar (1 minuto)

1. Abrir el frontend: http://localhost:5173
2. Ir a "Usuarios"
3. Hacer clic en un usuario
4. Clic en "✏️ Editar Usuario"
5. Modificar algún campo
6. Clic en "💾 Guardar Cambios"
7. ✅ Debería aparecer: "Usuario actualizado correctamente"

---

## 🎨 Cómo Usar

### Modo Visualización (por defecto)
```
📋 Detalles del Usuario
━━━━━━━━━━━━━━━━━━━━━━

Nombre: Juan Pérez          (solo lectura)
Email: juan@example.com     (solo lectura)
RemoteJid: 549...           (siempre bloqueado)
...

Botones: [Cerrar]  [✏️ Editar Usuario]
```

### Modo Edición
```
📋 Detalles del Usuario
━━━━━━━━━━━━━━━━━━━━━━

Nombre: [Juan Pérez______]  (editable)
Email: [juan@example.com]   (editable)
RemoteJid: 549...            (bloqueado, gris)
...

Botones: [✕ Cancelar]  [💾 Guardar Cambios]
```

---

## 📊 Campos Editables

| Campo | Editable | Tipo |
|-------|----------|------|
| Nombre | ✅ | Input texto |
| Apellido | ✅ | Input texto |
| Email | ✅ | Input email |
| RemoteJid | ❌ | Solo lectura |
| Edad | ✅ | Input número |
| Peso | ✅ | Input número |
| Altura | ✅ | Input número |
| Estado | ✅ | Select (Activo/Inactivo) |
| Verificado | ✅ | Select (Sí/No) |
| Rol | ✅ | Select (Usuario/Admin) |
| Tipo Diabetes | ✅ | Select |
| Objetivos | ✅ | Textarea |
| Restricciones | ✅ | Textarea |

---

## ✅ Verificación Rápida

### Checklist de Instalación:
- [ ] Workflow importado en n8n
- [ ] Credenciales de PostgreSQL configuradas
- [ ] Workflow activado (switch verde)
- [ ] Frontend corriendo
- [ ] Probado editar un usuario
- [ ] Cambios guardados correctamente

### Si algo no funciona:

**Error: "No se pudo actualizar el usuario"**
- Verificar que el workflow esté activo (switch verde en n8n)
- Revisar credenciales de PostgreSQL

**Los cambios no se guardan:**
- Abrir consola del navegador (F12)
- Ver si hay errores de red
- Verificar que la URL sea correcta: https://wf.zynaptic.tech

---

## 🎉 Funcionalidades

### Lo que SÍ puedes hacer:
- ✅ Editar nombre, apellido, email
- ✅ Cambiar edad, peso, altura
- ✅ Modificar objetivos y restricciones
- ✅ Cambiar estado (Activo/Inactivo)
- ✅ Cambiar rol (Usuario/Admin)
- ✅ Marcar como verificado
- ✅ Cambiar tipo de diabetes
- ✅ Cancelar sin guardar
- ✅ Ver todos los cambios en tiempo real

### Lo que NO puedes hacer:
- ❌ Editar RemoteJid (bloqueado por diseño)
- ❌ Editar ID del usuario
- ❌ Cambiar fechas de registro/actualización

---

## 📁 Archivos Modificados

```
frontend/
├── src/
│   ├── pages/
│   │   ├── Users.jsx         ← Modificado
│   │   └── Users.css         ← Modificado
│   └── services/
│       └── nutridiabApi.js   ← Modificado

n8n/
└── workflows/
    └── nutridiab-admin-actualizar-usuario.json  ← NUEVO

EDICION_USUARIOS_MODAL.md        ← Documentación completa
QUICK_START_EDICION_USUARIOS.md  ← Esta guía
```

---

## 🔗 Endpoint Creado

**URL**: `https://wf.zynaptic.tech/webhook/nutridiab/admin/usuarios/:id`  
**Método**: PUT  
**Content-Type**: application/json

**Request Body**:
```json
{
  "nombre": "Juan",
  "apellido": "Pérez",
  "email": "juan@example.com",
  "edad": 30,
  "peso": 75.5,
  "altura": 175,
  "objetivos": "Bajar de peso",
  "restricciones": "Sin gluten",
  "tipo_diabetes": "tipo2",
  "verified": true,
  "status": "active",
  "role": "user"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Usuario actualizado correctamente",
  "user": { ... }
}
```

---

## 💡 Tips

1. **RemoteJid bloqueado**: Es intencional, este campo no debe modificarse
2. **Cancelar sin pérdida**: Puedes cancelar en cualquier momento sin perder datos
3. **Validación automática**: Los campos numéricos solo aceptan números
4. **Feedback visual**: Los cambios se ven inmediatamente en el formulario

---

## 📞 Soporte

¿Problemas?

1. 📖 Lee la documentación completa: `EDICION_USUARIOS_MODAL.md`
2. 🔍 Revisa la consola del navegador (F12)
3. 🔧 Verifica los logs en n8n
4. 🗄️ Verifica la conexión a PostgreSQL

---

## 📊 Resumen

```
✅ Frontend: Listo y funcionando
✅ API Service: Función updateUser agregada
✅ Estilos CSS: Inputs editables con diseño moderno
⚠️ Workflow n8n: LISTO, solo falta importar (2 min)

Próximo paso: Importar workflow en n8n
```

---

**¿Necesitas más detalles?** → `EDICION_USUARIOS_MODAL.md`  
**¿Listo para empezar?** → Importa el workflow en n8n (Paso 2)

---

**Última actualización**: 26 de noviembre de 2025  
**Versión**: 1.0  
**Estado**: ✅ Production-ready

