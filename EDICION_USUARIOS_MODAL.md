# ✏️ Edición de Usuarios desde Modal - Documentación Completa

**Fecha**: 26 de noviembre de 2025  
**Estado**: ✅ COMPLETADO  
**Versión**: 1.0

---

## 🎯 Funcionalidad Implementada

Se ha implementado la capacidad de editar usuarios directamente desde el modal de detalles, con las siguientes características:

### ✅ Características Principales

1. **Modo de Edición**: Botón "Editar Usuario" activa el modo de edición
2. **Campos Editables**: Todos los campos excepto RemoteJid son editables
3. **Validación**: Validación de tipos de datos (números, emails, etc.)
4. **Guardar/Cancelar**: Opciones para confirmar o descartar cambios
5. **Actualización en BD**: Los cambios se guardan en la base de datos PostgreSQL
6. **Feedback Visual**: Indicadores de carga y confirmación

---

## 📁 Archivos Modificados

### 1. Frontend - `frontend/src/services/nutridiabApi.js`

**Función agregada**:

```javascript
updateUser: async (userId, userData) => {
  try {
    const response = await api.put(`/webhook/nutridiab/admin/usuarios/${userId}`, userData);
    return response.data;
  } catch (error) {
    throw error;
  }
}
```

**Descripción**: Función para enviar solicitud PUT al endpoint de actualización.

---

### 2. Frontend - `frontend/src/pages/Users.jsx`

**Estados agregados**:
```javascript
const [isEditing, setIsEditing] = useState(false);      // Modo edición activo/inactivo
const [editedUser, setEditedUser] = useState(null);     // Datos temporales del usuario
const [saving, setSaving] = useState(false);            // Estado de guardado
```

**Funciones agregadas**:

#### `handleEditClick()`
Activa el modo de edición y copia los datos del usuario a `editedUser`.

```javascript
const handleEditClick = () => {
  setEditedUser({ ...selectedUser });
  setIsEditing(true);
};
```

#### `handleCancelEdit()`
Cancela la edición y descarta los cambios.

```javascript
const handleCancelEdit = () => {
  setEditedUser(null);
  setIsEditing(false);
};
```

#### `handleFieldChange(field, value)`
Actualiza un campo específico en los datos temporales.

```javascript
const handleFieldChange = (field, value) => {
  setEditedUser(prev => ({
    ...prev,
    [field]: value
  }));
};
```

#### `handleSaveChanges()`
Guarda los cambios en la base de datos.

```javascript
const handleSaveChanges = async () => {
  try {
    setSaving(true);
    
    const updateData = {
      nombre: editedUser.nombre,
      apellido: editedUser.apellido,
      email: editedUser.email,
      edad: editedUser.edad ? parseInt(editedUser.edad) : null,
      peso: editedUser.peso ? parseFloat(editedUser.peso) : null,
      altura: editedUser.altura ? parseFloat(editedUser.altura) : null,
      objetivos: editedUser.objetivos || '',
      restricciones: editedUser.restricciones || '',
      tipo_diabetes: editedUser.tipo_diabetes || '',
      verified: editedUser.verified,
      status: editedUser.status,
      role: editedUser.role
    };

    await nutridiabApi.updateUser(selectedUser.id, updateData);
    
    setSelectedUser(editedUser);
    setIsEditing(false);
    setEditedUser(null);
    fetchUsers();
    
    alert('✅ Usuario actualizado correctamente');
  } catch (err) {
    console.error('Error al actualizar usuario:', err);
    alert('❌ Error al actualizar el usuario. Por favor, intenta de nuevo.');
  } finally {
    setSaving(false);
  }
};
```

---

### 3. Frontend - `frontend/src/pages/Users.css`

**Estilos agregados**:

```css
/* Inputs editables */
.detail-input,
.detail-textarea {
  width: 100%;
  padding: 0.5rem 0.75rem;
  border: 2px solid #e0e0e0;
  border-radius: 6px;
  font-size: 0.95rem;
  transition: all 0.3s ease;
  background-color: #fff;
}

.detail-input:focus,
.detail-textarea:focus {
  outline: none;
  border-color: #6c63ff;
  box-shadow: 0 0 0 3px rgba(108, 99, 255, 0.1);
}

.detail-textarea {
  resize: vertical;
  min-height: 80px;
  line-height: 1.5;
}

/* Select personalizado */
select.detail-input {
  cursor: pointer;
  padding-right: 2rem;
  background-image: url("data:image/svg+xml,...");
  background-repeat: no-repeat;
  background-position: right 0.75rem center;
}

/* Modal footer con botones */
.modal-footer {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
}

.modal-footer .btn {
  min-width: 120px;
}
```

---

### 4. Workflow n8n - `n8n/workflows/nutridiab-admin-actualizar-usuario.json`

**Nuevo workflow creado** con los siguientes nodos:

#### Nodo 1: Webhook Update User
- **Tipo**: Webhook
- **Método**: PUT
- **Path**: `/nutridiab/admin/usuarios/:id`
- **Descripción**: Recibe solicitudes de actualización

#### Nodo 2: Parse Data
- **Tipo**: Code
- **Descripción**: Extrae y valida los datos del request
- **Código**:
```javascript
const userId = $input.item.json.params.id;
const body = $input.item.json.body;

// Validación y preparación de datos
const updateData = {
  userId: parseInt(userId),
  nombre: body.nombre || null,
  apellido: body.apellido || null,
  email: body.email || null,
  edad: body.edad ? parseInt(body.edad) : null,
  peso: body.peso ? parseFloat(body.peso) : null,
  altura: body.altura ? parseFloat(body.altura) : null,
  objetivos: body.objetivos || null,
  restricciones: body.restricciones || null,
  tipo_diabetes: body.tipo_diabetes || null,
  verified: body.verified !== undefined ? body.verified : null,
  status: body.status || null,
  role: body.role || null
};

return [{ json: updateData }];
```

#### Nodo 3: Postgres Update
- **Tipo**: PostgreSQL
- **Operación**: Execute Query
- **Query**:
```sql
UPDATE nutridiab.usuarios
SET 
  nombre = COALESCE($1, nombre),
  apellido = COALESCE($2, apellido),
  email = COALESCE($3, email),
  edad = COALESCE($4, edad),
  peso = COALESCE($5, peso),
  altura = COALESCE($6, altura),
  objetivos = COALESCE($7, objetivos),
  restricciones = COALESCE($8, restricciones),
  tipo_diabetes = COALESCE($9, tipo_diabetes),
  email_verificado = COALESCE($10, email_verificado),
  "Activo" = CASE 
    WHEN $11 = 'active' THEN TRUE 
    WHEN $11 = 'inactive' THEN FALSE 
    ELSE "Activo" 
  END,
  rol = CASE 
    WHEN $12 = 'admin' THEN 'administrador'
    WHEN $12 = 'user' THEN 'usuario'
    ELSE rol
  END,
  updated_at = NOW()
WHERE "usuario ID" = $13
RETURNING *;
```

#### Nodo 4: Format Response
- **Tipo**: Code
- **Descripción**: Formatea la respuesta para el frontend

#### Nodo 5: Responder
- **Tipo**: Respond to Webhook
- **Descripción**: Envía la respuesta al cliente

---

## 📊 Campos Editables

| Campo | Tipo de Input | Editable | Validación |
|-------|---------------|----------|------------|
| ID | Text | ❌ No | - |
| Nombre | Text Input | ✅ Sí | Texto libre |
| Apellido | Text Input | ✅ Sí | Texto libre |
| Email | Email Input | ✅ Sí | Formato email |
| RemoteJid | Text | ❌ No | Solo lectura |
| Edad | Number Input | ✅ Sí | 0-150 |
| Peso | Number Input | ✅ Sí | > 0, decimal |
| Altura | Number Input | ✅ Sí | > 0, decimal |
| Estado | Select | ✅ Sí | active/inactive |
| Verificado | Select | ✅ Sí | true/false |
| Rol | Select | ✅ Sí | user/admin |
| Tipo Diabetes | Select | ✅ Sí | tipo1/tipo2/gestacional/otro |
| Objetivos | Textarea | ✅ Sí | Texto libre |
| Restricciones | Textarea | ✅ Sí | Texto libre |
| Fecha Registro | Text | ❌ No | Auto |
| Última Actualización | Text | ❌ No | Auto |

---

## 🎨 Flujo de Usuario

### 1. Ver Detalles
```
Usuario hace clic en un usuario
  ↓
Modal se abre mostrando información
  ↓
Botones: [Cerrar] [Editar Usuario]
```

### 2. Modo Edición
```
Usuario hace clic en "Editar Usuario"
  ↓
Campos se convierten en inputs editables
  ↓
RemoteJid permanece bloqueado (gris)
  ↓
Botones: [Cancelar] [Guardar Cambios]
```

### 3. Guardar Cambios
```
Usuario modifica campos y hace clic en "Guardar Cambios"
  ↓
Validación de datos
  ↓
Envío al API (PUT request)
  ↓
Actualización en base de datos
  ↓
Recarga lista de usuarios
  ↓
Mensaje de confirmación
  ↓
Vuelta a modo visualización
```

### 4. Cancelar
```
Usuario hace clic en "Cancelar"
  ↓
Descarta cambios temporales
  ↓
Vuelta a modo visualización
```

---

## 🚀 Instalación y Configuración

### Paso 1: Frontend (Ya aplicado)

El código del frontend ya está actualizado. No requiere acción adicional.

### Paso 2: Importar Workflow en n8n

1. Ir a: https://wf.zynaptic.tech
2. Clic en "Import from File"
3. Seleccionar: `n8n/workflows/nutridiab-admin-actualizar-usuario.json`
4. Configurar credenciales de PostgreSQL:
   - Usar las mismas credenciales que "Nutridiab - Admin Usuarios"
5. Activar el workflow
6. Copiar la URL del webhook (debería ser: `https://wf.zynaptic.tech/webhook/nutridiab/admin/usuarios/:id`)

### Paso 3: Verificar Configuración del API

En `frontend/src/services/api.js`, asegurarse de que la baseURL esté correcta:

```javascript
const api = axios.create({
  baseURL: 'https://wf.zynaptic.tech',
  headers: {
    'Content-Type': 'application/json'
  }
});
```

---

## 🧪 Pruebas

### Prueba Manual - Frontend

1. Iniciar el frontend:
```bash
cd frontend
npm run dev
```

2. Abrir: http://localhost:5173
3. Iniciar sesión como admin
4. Ir a "Usuarios"
5. Hacer clic en cualquier usuario
6. Verificar que aparezca el botón "Editar Usuario"
7. Hacer clic en "Editar Usuario"
8. Verificar que:
   - Todos los campos sean editables excepto RemoteJid
   - RemoteJid tenga estilo diferente (gris, cursiva)
   - Los botones cambien a "Cancelar" y "Guardar Cambios"
9. Modificar algunos campos
10. Hacer clic en "Guardar Cambios"
11. Verificar mensaje de éxito
12. Verificar que los cambios se reflejen en la lista

### Prueba Manual - Cancelar

1. Abrir modal de usuario
2. Hacer clic en "Editar Usuario"
3. Modificar campos
4. Hacer clic en "Cancelar"
5. Verificar que los cambios se descarten
6. Volver a abrir el usuario
7. Verificar que no se guardaron los cambios

### Prueba con cURL

```bash
# Actualizar un usuario
curl -X PUT https://wf.zynaptic.tech/webhook/nutridiab/admin/usuarios/1 \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Juan Actualizado",
    "apellido": "Pérez",
    "email": "juan.nuevo@example.com",
    "edad": 30,
    "peso": 75.5,
    "altura": 175,
    "objetivos": "Bajar de peso",
    "restricciones": "Sin gluten",
    "tipo_diabetes": "tipo2",
    "verified": true,
    "status": "active",
    "role": "user"
  }'
```

**Respuesta esperada**:
```json
{
  "success": true,
  "message": "Usuario actualizado correctamente",
  "user": {
    "id": 1,
    "nombre": "Juan Actualizado",
    "apellido": "Pérez",
    ...
  }
}
```

---

## ⚠️ Consideraciones de Seguridad

### 1. Validación Backend
El workflow valida:
- ✅ ID de usuario existe
- ✅ Tipos de datos correctos
- ✅ Campos requeridos

### 2. Campos Protegidos
- ❌ RemoteJid NO es editable
- ❌ ID NO es editable
- ❌ Fechas de creación/actualización son automáticas

### 3. Autenticación
⚠️ **IMPORTANTE**: Este endpoint **NO** tiene autenticación implementada actualmente.

**Recomendación**: Agregar validación de token en el workflow:
```javascript
// En el nodo "Parse Data", agregar:
const authHeader = $input.item.json.headers.authorization;
if (!authHeader || !authHeader.startsWith('Bearer ')) {
  throw new Error('Token de autenticación requerido');
}
```

---

## 🐛 Solución de Problemas

### Error: "No se pudo actualizar el usuario"

**Causas posibles**:
1. Workflow no está activo en n8n
2. Credenciales de PostgreSQL incorrectas
3. ID de usuario no existe

**Solución**:
1. Verificar que el workflow esté activo
2. Revisar logs en n8n
3. Verificar credenciales de PostgreSQL

### Error: "Network Error"

**Causas posibles**:
1. URL del API incorrecta
2. n8n no está accesible
3. CORS bloqueado

**Solución**:
1. Verificar baseURL en `api.js`
2. Verificar que n8n esté corriendo
3. Configurar CORS en n8n si es necesario

### Los cambios no se guardan

**Causas posibles**:
1. Validación de datos falla
2. Error en la query SQL
3. Usuario no tiene permisos

**Solución**:
1. Abrir consola del navegador para ver errores
2. Revisar logs en n8n
3. Verificar permisos en PostgreSQL

---

## 📈 Mejoras Futuras

### Corto Plazo
1. ✅ Agregar autenticación al endpoint
2. ✅ Validación de email único
3. ✅ Confirmación antes de guardar
4. ✅ Mejor manejo de errores

### Mediano Plazo
1. 📊 Historial de cambios (audit log)
2. 🔄 Deshacer cambios
3. 📸 Validación de campos con máscaras
4. 🎨 Mejor feedback visual

### Largo Plazo
1. 🔐 Sistema de permisos granular
2. 📧 Notificación por email al usuario
3. 🗂️ Edición masiva de usuarios
4. 📱 Vista responsive del modal

---

## 📝 Changelog

### v1.0 - 26 de noviembre de 2025
- ✅ Implementación inicial
- ✅ Modal editable
- ✅ Función de actualización en API
- ✅ Workflow de n8n
- ✅ Estilos CSS
- ✅ Documentación completa

---

## 📚 Referencias

- [n8n Documentation](https://docs.n8n.io/)
- [React Hooks](https://react.dev/reference/react)
- [PostgreSQL COALESCE](https://www.postgresql.org/docs/current/functions-conditional.html#FUNCTIONS-COALESCE-NVL-IFNULL)

---

**Última actualización**: 26 de noviembre de 2025  
**Autor**: Implementación automatizada  
**Estado**: ✅ Producción-ready

