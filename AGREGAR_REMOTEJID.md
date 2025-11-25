# 📱 Agregar RemoteJid a las Pantallas

## ✅ Cambios Realizados

### Frontend

#### 1. Pantalla de Usuarios (`frontend/src/pages/Users.jsx`)
- ✅ Agregada columna "RemoteJid" en la tabla principal
- ✅ Actualizado el modal de detalles para mostrar "RemoteJid (WhatsApp)"
- ✅ Los cambios ya están aplicados y funcionando

#### 2. Pantalla de Consultas (`frontend/src/pages/Consultas.jsx`)
- ✅ Agregada columna "RemoteJid" en la tabla principal
- ✅ Actualizado el modal de detalles para mostrar "RemoteJid (WhatsApp)"
- ✅ Los cambios ya están aplicados en el código

### Backend (n8n)

#### 3. Workflow de Consultas (`n8n/workflows/nutridiab-admin-consultas.json`)
- ✅ Actualizada la consulta SQL para incluir `u.remotejid`
- ⚠️ **Requiere re-importar en n8n** para que los cambios surtan efecto

## 📋 Pasos para Aplicar los Cambios en n8n

### Opción A: Re-importar el Workflow Completo

1. Ve a n8n: https://wf.zynaptic.tech
2. Busca el workflow "Nutridiab - Admin Consultas Recientes"
3. Haz clic en los tres puntos (...) → **"Duplicate"** (para tener un respaldo)
4. Elimina o desactiva el workflow original
5. Importa el archivo actualizado: `n8n/workflows/nutridiab-admin-consultas.json`
6. Configura las credenciales de PostgreSQL si es necesario
7. Activa el workflow

### Opción B: Editar Manualmente

1. Abre el workflow en n8n: "Nutridiab - Admin Consultas Recientes"
2. Edita el nodo **"Postgres Consultas"**
3. Actualiza la consulta SQL agregando `u.remotejid` en el SELECT:

```sql
-- Consultas recientes con datos de usuario
SELECT 
  c.id,
  c.tipo,
  c.resultado,
  c."Costo",
  c.created_at,
  u.nombre,
  u.apellido,
  u.email,
  u.remotejid        -- ← AGREGAR ESTA LÍNEA
FROM nutridiab."Consultas" c
JOIN nutridiab.usuarios u ON c."usuario ID" = u."usuario ID"
ORDER BY c.created_at DESC
LIMIT {{ $json.query.limit || 50 }};
```

4. Guarda los cambios
5. Activa el workflow si estaba desactivado

## 🧪 Verificar los Cambios

### 1. Probar el endpoint manualmente

```powershell
# Probar que devuelve el remotejid
curl https://wf.zynaptic.tech/webhook/nutridiab/admin/consultas?limit=5
```

**Debería devolver** algo como:

```json
[
  {
    "id": 1,
    "tipo": "imagen",
    "resultado": "...",
    "Costo": 0.0057,
    "created_at": "2025-11-20T...",
    "nombre": "Fernando",
    "apellido": "García",
    "email": "fernando@example.com",
    "remotejid": "5491156183199@s.whatsapp.net"  ← NUEVO CAMPO
  },
  ...
]
```

### 2. Verificar en el Frontend

1. Abre: http://localhost:5173/consultas
2. Deberías ver la columna "RemoteJid" con valores como:
   - `5491156183199@s.whatsapp.net`
   - `72503376502839@lid`
   - `210560822063189@lid`
3. Al hacer clic en una consulta, el modal debería mostrar el "RemoteJid (WhatsApp)"

## 📊 Resultado Esperado

### Pantalla de Usuarios
| ID | Nombre | Apellido | Email | **RemoteJid** | Estado | ... |
|----|--------|----------|-------|---------------|--------|-----|
| 1  | Daniel | Zapata   | admin@... | **admin@nutridiab.system** | ✓ Activo | ... |
| 2  | N/A    | N/A      | N/A   | **5491165009220@s.whatsapp.net** | ✓ Activo | ... |

### Pantalla de Consultas
| ID | Usuario | Email | **RemoteJid** | Tipo | Resultado | ... |
|----|---------|-------|---------------|------|-----------|-----|
| 1  | Fernando García | fernando@... | **5491156183199@s.whatsapp.net** | 📸 imagen | ... | ... |
| 2  | Silvia López | silvia@... | **5491135561965@s.whatsapp.net** | 🎤 audio | ... | ... |

## ✨ Beneficios

- **Identificación clara** de usuarios por su WhatsApp
- **Trazabilidad completa** de consultas por número de teléfono
- **Facilita el soporte** al poder identificar usuarios por su remotejid
- **Consistencia** entre pantallas de usuarios y consultas

---

**Estado actual:**
- ✅ Frontend: Cambios aplicados y funcionando
- ⚠️ Backend: Requiere actualizar el workflow en n8n

**Próximo paso:** Importar el workflow actualizado en n8n para que el remotejid aparezca en la pantalla de consultas.

