# ⚡ Guía Rápida: Cambio de Contraseña

**Tiempo**: Ya está implementado  
**Estado**: ✅ Código listo

---

## 🎯 ¿Qué se agregó?

✅ Campo "Nueva Contraseña" en el modal de edición de usuario  
✅ Hash bcrypt automático (seguro)  
✅ Opcional: dejar vacío para no cambiar  
✅ Actualización directa en base de datos

---

## 🎨 Cómo Usar

### 1. Editar Usuario
```
1. Abrir modal de un usuario
2. Clic en "Editar Usuario"
3. Verás un nuevo campo: "Nueva Contraseña"
```

### 2. Cambiar Contraseña
```
┌──────────────────────────────────┐
│ Nueva Contraseña:                │
│ [●●●●●●●●●●●●]                   │
│ 💡 Dejar vacío si no deseas     │
│    cambiar la contraseña         │
└──────────────────────────────────┘

- Ingresar nueva contraseña
- Guardar cambios
- ✅ Contraseña actualizada
```

### 3. NO Cambiar Contraseña
```
┌──────────────────────────────────┐
│ Nueva Contraseña:                │
│ [____________________________]   │
│ 💡 Dejar vacío si no deseas     │
│    cambiar la contraseña         │
└──────────────────────────────────┘

- Dejar el campo vacío
- Actualizar otros campos
- Guardar cambios
- ✅ Contraseña NO cambia
```

---

## 🔒 Seguridad

### ✅ Implementado:
- **Hash bcrypt**: Contraseña hasheada automáticamente
- **Input oculto**: Tipo password (●●●●●)
- **Opcional**: No obligatorio cambiar
- **Validación**: Solo actualiza si se proporciona

### Cómo Funciona:
```
Contraseña ingresada: "MiContraseña123"
         ↓
Hash bcrypt generado: "$2a$06$rounds...hashedpassword..."
         ↓
Solo el hash se guarda en BD
         ↓
Contraseña original se descarta
```

---

## 📋 Ejemplos

### Ejemplo 1: Solo cambiar contraseña
```javascript
1. Abrir usuario
2. Editar
3. Ingresar nueva contraseña: "Segura456"
4. Guardar
✅ Solo la contraseña cambia
```

### Ejemplo 2: Actualizar perfil sin cambiar contraseña
```javascript
1. Abrir usuario
2. Editar
3. Cambiar nombre, email, edad
4. Dejar contraseña VACÍA
5. Guardar
✅ Perfil actualizado, contraseña igual
```

### Ejemplo 3: Actualizar todo incluyendo contraseña
```javascript
1. Abrir usuario
2. Editar
3. Cambiar nombre: "Juan Actualizado"
4. Cambiar email: "juan.nuevo@example.com"
5. Ingresar nueva contraseña: "Nueva789"
6. Guardar
✅ Todo actualizado incluyendo contraseña
```

---

## ⚠️ Importante

### ✅ Sí puedes:
- Cambiar contraseña de cualquier usuario
- Dejar vacío para no cambiar
- Combinar con otros campos

### ❌ No puedes:
- Ver la contraseña actual
- Recuperar contraseña olvidada (aún)
- Ver historial de contraseñas

---

## 🚀 Instalación

### Frontend: ✅ Ya está listo

No hay que hacer nada, ya está implementado.

### Workflow n8n: ⚠️ Requiere actualización

**Opción A - Re-importar** (más fácil):
1. Ir a n8n
2. Eliminar workflow actual
3. Importar: `n8n/workflows/nutridiab-admin-actualizar-usuario.json`
4. Activar

**Opción B - Editar manual** (ver documentación completa)

---

## 🧪 Verificación Rápida

### Prueba 1: Cambiar contraseña
```
1. Editar usuario de prueba
2. Ingresar contraseña: "Test123"
3. Guardar
4. Intentar login con nueva contraseña
✅ Debería funcionar
```

### Prueba 2: No cambiar contraseña
```
1. Editar usuario
2. Cambiar nombre
3. Dejar contraseña VACÍA
4. Guardar
5. Intentar login con contraseña ANTERIOR
✅ Debería seguir funcionando
```

---

## 📞 Solución de Problemas

### "La contraseña no cambió"
- Verificar que ingresaste algo (no vacío)
- Verificar que el workflow esté actualizado
- Revisar logs en n8n

### "No puedo iniciar sesión"
- La contraseña es sensible a mayúsculas
- Verificar que se guardó correctamente
- Revisar en BD si el hash cambió

### "El campo no aparece"
- Asegúrate de estar en modo edición
- Debe aparecer después de "RemoteJid"
- Solo visible en modo edición

---

## 📝 Checklist

- [ ] Frontend actualizado
- [ ] Workflow re-importado en n8n
- [ ] Probado cambiar contraseña
- [ ] Probado NO cambiar contraseña
- [ ] Verificado login con nueva contraseña

---

## 🎉 Listo!

El campo de contraseña está integrado en el modal de edición.

**Próximo paso**: Re-importar workflow en n8n

---

**Documentación completa**: `CAMBIO_CONTRASENA_USUARIOS.md`  
**Última actualización**: 26 de noviembre de 2025  
**Estado**: ✅ Funcional

