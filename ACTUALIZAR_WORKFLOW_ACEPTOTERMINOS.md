# 🔧 Actualizar Workflow n8n - Campo AceptoTerminos

**Fecha**: 26 de noviembre de 2025  
**Problema**: El workflow en producción devuelve `acepto_terminos` pero falta el campo `aceptadoel`  
**Estado**: ⚠️ REQUIERE ACCIÓN

---

## 🔍 Diagnóstico

### ✅ Lo que funciona:
- El endpoint devuelve `acepto_terminos = true/false`
- El frontend ahora es compatible con ambos formatos: `AceptoTerminos` y `acepto_terminos`

### ❌ Lo que falta:
- El endpoint **NO** devuelve el campo `aceptadoel` (fecha de aceptación)
- El workflow en producción usa el formato viejo

---

## 🚀 Solución: Actualizar el Workflow en n8n

### Opción A: Editar Manualmente (Recomendado)

#### Paso 1: Abrir el Workflow

1. Ve a: https://wf.zynaptic.tech
2. Busca el workflow: **"Nutridiab - Admin Usuarios"**
3. Haz clic para editar

#### Paso 2: Actualizar la Query SQL

En el nodo **"Postgres Usuarios"**, busca la línea que dice:

```sql
u."AceptoTerminos",
```

Y **justo después** agrega:

```sql
u.aceptadoel,
```

La query completa debería verse así:

```sql
SELECT 
  u."usuario ID",
  u.nombre,
  u.apellido,
  u.email,
  u."remoteJid",
  u.edad,
  u.peso,
  u.altura,
  u.objetivos,
  u.restricciones,
  u.rol,
  u."AceptoTerminos",
  u.aceptadoel,              -- ⬅️ AGREGAR ESTA LÍNEA
  u.datos_completos,
  u.email_verificado,
  u."Activo",
  u."Bloqueado",
  u.tipo_diabetes,
  u.created_at,
  u.updated_at,
  u.ultimo_acceso,
  COUNT(c.id) as total_consultas,
  COALESCE(SUM(c."Costo"), 0) as costo_total,
  MAX(c.created_at) as ultima_consulta
FROM nutridiab.usuarios u
LEFT JOIN nutridiab."Consultas" c ON u."usuario ID" = c."usuario ID"
GROUP BY u."usuario ID", u.rol
ORDER BY u.created_at DESC
LIMIT 100;
```

#### Paso 3: Actualizar el Código de Transformación

En el nodo **"Transformar Datos"**, busca la línea:

```javascript
acepto_terminos: item.json.AceptoTerminos || false,
```

Y **justo después** agrega:

```javascript
aceptadoel: item.json.aceptadoel || null,
```

El código completo debería verse así (extracto relevante):

```javascript
const user = {
    id: item.json['usuario ID'],
    nombre: item.json.nombre || '',
    apellido: item.json.apellido || '',
    email: item.json.email || '',
    remotejid: item.json.remoteJid || '',
    remoteJid: item.json.remoteJid || '',  // Agregar esta línea también
    telefono: item.json.remoteJid || '',
    edad: item.json.edad || null,
    peso: item.json.peso || null,
    altura: item.json.altura || null,
    objetivos: item.json.objetivos || '',
    restricciones: item.json.restricciones || '',
    status: item.json.Activo ? 'active' : 'inactive',
    verified: item.json.email_verificado || false,
    role: item.json.rol === 'administrador' ? 'admin' : 'user',
    acepto_terminos: item.json.AceptoTerminos || false,
    aceptadoel: item.json.aceptadoel || null,  // ⬅️ AGREGAR ESTA LÍNEA
    datos_completos: item.json.datos_completos || false,
    bloqueado: item.json.Bloqueado || false,
    tipo_diabetes: item.json.tipo_diabetes || '',
    created_at: item.json.created_at,
    updated_at: item.json.updated_at,
    ultimo_acceso: item.json.ultimo_acceso,
    total_consultas: parseInt(item.json.total_consultas) || 0,
    costo_total: parseFloat(item.json.costo_total) || 0,
    ultima_consulta: item.json.ultima_consulta
};
```

#### Paso 4: Guardar y Probar

1. Haz clic en **"Save"** en la esquina superior derecha
2. Haz clic en **"Execute Workflow"** para probar
3. Verifica que la respuesta incluya el campo `aceptadoel`

---

### Opción B: Re-importar el Workflow Completo

1. Ve a n8n: https://wf.zynaptic.tech
2. Busca el workflow "Nutridiab - Admin Usuarios"
3. **Exporta el workflow actual** (backup por si acaso)
4. Desactiva el workflow
5. Borra o renombra el workflow actual
6. Importa el nuevo: `n8n/workflows/nutridiab-admin-usuarios.json`
7. Configura las credenciales de PostgreSQL
8. Activa el workflow

---

## 🧪 Verificación

### Paso 1: Ejecutar el Script de Diagnóstico

```powershell
powershell -ExecutionPolicy Bypass -File scripts\test_aceptoterminos.ps1
```

**Deberías ver**:
```
[IMPORTANTE] acepto_terminos = True
[IMPORTANTE] aceptadoel = 2025-11-26T10:30:00.000Z  ← NUEVO
```

### Paso 2: Verificar en el Frontend

1. Abre el frontend: http://localhost:5173
2. Inicia sesión como admin
3. Ve a "Usuarios"
4. Haz clic en un usuario que haya aceptado términos
5. **Deberías ver**:
   - ✅ Aceptó Términos: ✓ Sí
   - ✅ Fecha de Aceptación: [fecha] ← **ESTO DEBERÍA APARECER AHORA**

---

## 📊 Estado Actual

| Campo | En Base de Datos | En Workflow | En Frontend | Estado |
|-------|------------------|-------------|-------------|--------|
| `AceptoTerminos` | ✅ Existe | ✅ Se consulta | ✅ Compatible | ✅ OK |
| `acepto_terminos` | N/A | ✅ Se devuelve | ✅ Compatible | ✅ OK |
| `aceptadoel` | ✅ Existe | ❌ NO se consulta | ✅ Compatible | ⚠️ FALTA |

---

## 🎯 Resultado Esperado

Después de actualizar el workflow, el endpoint debería devolver:

```json
{
  "id": 7,
  "nombre": "Daniel",
  "apellido": "Zapata",
  "acepto_terminos": true,
  "aceptadoel": "2025-11-23T22:12:50.472Z",  ← NUEVO
  ...
}
```

Y en el frontend se mostrará:

```
Estado de la Cuenta
├─ Aceptó Términos: ✓ Sí
├─ Fecha de Aceptación: 23 de noviembre de 2025, 10:12 PM  ← NUEVO
├─ Fecha de Registro: 23 de noviembre de 2025, 10:12 PM
└─ Última Actualización: 25 de noviembre de 2025, 08:25 PM
```

---

## ⚠️ Importante

- ✅ El **frontend ya está actualizado** y es compatible con ambos formatos
- ⚠️ El **workflow en n8n necesita ser actualizado** manualmente
- 📝 El archivo `n8n/workflows/nutridiab-admin-usuarios.json` ya tiene los cambios correctos
- 🔄 Solo falta importar/aplicar los cambios en el workflow de producción

---

## 📝 Notas

### ¿Por qué dos nombres diferentes?

- **Base de datos**: Usa `"AceptoTerminos"` (con comillas y mayúsculas por PostgreSQL)
- **API actual**: Devuelve `acepto_terminos` (formato snake_case)
- **API actualizado**: Debería devolver `acepto_terminos` + `aceptadoel`
- **Frontend**: Ahora acepta ambos formatos por compatibilidad

### Recomendación futura

Considerar estandarizar los nombres de campos en el futuro:
- Opción 1: Todo en camelCase (`aceptoTerminos`)
- Opción 2: Todo en snake_case (`acepto_terminos`)
- Opción 3: Mantener nombres exactos de la BD (`AceptoTerminos`)

---

**Próximo paso**: Actualiza el workflow en n8n siguiendo los pasos de la Opción A o B.

