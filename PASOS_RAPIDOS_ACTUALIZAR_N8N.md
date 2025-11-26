# ⚡ PASOS RÁPIDOS: Actualizar Workflow n8n

**Tiempo estimado**: 2-3 minutos  
**Dificultad**: Muy fácil

---

## 🎯 Objetivo

Agregar el campo `aceptadoel` (fecha de aceptación de términos) al endpoint de usuarios.

---

## 📝 Pasos

### 1️⃣ Abrir n8n

Ir a: **https://wf.zynaptic.tech**

### 2️⃣ Buscar el Workflow

- Buscar: **"Nutridiab - Admin Usuarios"**
- Hacer clic para abrir

### 3️⃣ Editar Nodo "Postgres Usuarios"

1. Hacer clic en el nodo **"Postgres Usuarios"**
2. Buscar esta línea en la query:

```sql
u."AceptoTerminos",
```

3. **Justo después**, agregar:

```sql
u.aceptadoel,
```

**Resultado**:
```sql
u."AceptoTerminos",
u.aceptadoel,         ← ESTA LÍNEA ES NUEVA
u.datos_completos,
```

4. Cerrar el nodo (hacer clic fuera)

### 4️⃣ Editar Nodo "Transformar Datos"

1. Hacer clic en el nodo **"Transformar Datos"**
2. Buscar esta línea en el código JavaScript:

```javascript
acepto_terminos: item.json.AceptoTerminos || false,
```

3. **Justo después**, agregar:

```javascript
aceptadoel: item.json.aceptadoel || null,
```

**Resultado**:
```javascript
acepto_terminos: item.json.AceptoTerminos || false,
aceptadoel: item.json.aceptadoel || null,    ← ESTA LÍNEA ES NUEVA
datos_completos: item.json.datos_completos || false,
```

4. Cerrar el nodo

### 5️⃣ Guardar

- Hacer clic en **"Save"** (esquina superior derecha)

### 6️⃣ Probar

- Hacer clic en **"Execute Workflow"**
- Verificar que no haya errores

---

## ✅ Verificación

### En PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\verificar_aceptoterminos_simple.ps1
```

**Debes ver**:
```
[OK] acepto_terminos: True
[OK] aceptadoel: 2025-11-23T22:12:50.472Z  ← ESTO ES NUEVO
[EXITO] Todo correcto!
```

### En el Frontend:

1. Abrir: http://localhost:5173
2. Ir a "Usuarios"
3. Hacer clic en cualquier usuario
4. **Debe aparecer**: "Fecha de Aceptación: [fecha]"

---

## 🚨 Si hay Problemas

### Error al guardar:

- Verificar que no falten comas (`,`) al final de cada línea
- Verificar que las líneas anteriores tengan coma

### No aparece la fecha:

1. Verificar que el workflow esté activo
2. Ejecutar el script de verificación
3. Revisar los logs en n8n

### El endpoint no responde:

- Verificar credenciales de PostgreSQL
- Verificar que el workflow esté activo
- Probar ejecutar el workflow manualmente

---

## 📋 Checklist

- [ ] Abrir workflow en n8n
- [ ] Agregar `u.aceptadoel,` en el nodo SQL
- [ ] Agregar `aceptadoel: item.json.aceptadoel || null,` en el nodo JS
- [ ] Guardar workflow
- [ ] Ejecutar workflow de prueba
- [ ] Verificar con script de PowerShell
- [ ] Verificar en el frontend

---

## 🎉 Listo!

Una vez completado, el campo "Fecha de Aceptación" aparecerá en los detalles de usuario.

---

**¿Prefieres re-importar?** Ver: `ACTUALIZAR_WORKFLOW_ACEPTOTERMINOS.md`

