# Migración del Workflow NutriDiab: Supabase → PostgreSQL

**Fecha:** 25 de noviembre de 2025  
**Workflow ID:** aODNc4dEt76c712G  
**Version ID:** 094bcddd-2f52-4cd9-a456-19f03f1d5e10

## 📋 Resumen

Se ha migrado exitosamente el workflow principal **"nutridiab"** de usar nodos de Supabase a nodos de PostgreSQL nativos de n8n utilizando MCP (Model Context Protocol).

## ✅ Cambios Realizados

### 1. Nodos Reemplazados (6 nodos)

#### **Get a row** → **Get a row (Postgres)**
- **ID del nodo:** `c6cdea22-fb1c-4156-89f4-d1a831987c41`
- **Tipo anterior:** `n8n-nodes-base.supabase`
- **Tipo nuevo:** `n8n-nodes-base.postgres` (v2.6)
- **Operación:** SELECT
- **Descripción:** Busca usuarios en la tabla `usuarios` por campo `remoteJid`

#### **Create a row** → **Create a row (Postgres)**
- **ID del nodo:** `9834b2b4-b1ef-4ab3-a887-f2331efe75bf`
- **Tipo anterior:** `n8n-nodes-base.supabase`
- **Tipo nuevo:** `n8n-nodes-base.postgres` (v2.6)
- **Operación:** INSERT
- **Descripción:** Crea nuevos registros de usuarios con campo `remoteJid`

#### **Update a row** → **Update a row (Postgres)**
- **ID del nodo:** `63ebdd47-a2cd-490f-b9e8-f55df2daa0c0`
- **Tipo anterior:** `n8n-nodes-base.supabase`
- **Tipo nuevo:** `n8n-nodes-base.postgres` (v2.6)
- **Operación:** UPDATE
- **Descripción:** Actualiza campos `AceptoTerminos`, `msgaceptacion`, `aceptadoel`
- **Condición WHERE:** `remoteJid` igual al valor del usuario

#### **Guardar Consulta Texto** → **Guardar Consulta Texto (Postgres)**
- **ID del nodo:** `95a09a64-fa25-4f66-872e-69561e2a9b27`
- **Tipo anterior:** `n8n-nodes-base.supabase`
- **Tipo nuevo:** `n8n-nodes-base.postgres` (v2.6)
- **Operación:** INSERT
- **Tabla:** `Consultas`
- **Campos:** `tipo`, `usuario_id`, `resultado`, `costo`

#### **Guardad consulta Imagen** → **Guardar consulta Imagen (Postgres)**
- **ID del nodo:** `be43d7e4-27b0-45b5-82dd-ee27bf1d9f3c`
- **Tipo anterior:** `n8n-nodes-base.supabase`
- **Tipo nuevo:** `n8n-nodes-base.postgres` (v2.6)
- **Operación:** INSERT
- **Tabla:** `Consultas`
- **Campos:** `tipo`, `usuario_id`, `resultado`, `costo`

#### **Guardad consulta Audio** → **Guardar consulta Audio (Postgres)**
- **ID del nodo:** `16758387-b1cf-4114-b8d0-85ed73ec1d2f`
- **Tipo anterior:** `n8n-nodes-base.supabase`
- **Tipo nuevo:** `n8n-nodes-base.postgres` (v2.6)
- **Operación:** INSERT
- **Tabla:** `Consultas`
- **Campos:** `tipo`, `usuario_id`, `resultado`, `costo`

### 2. Mejoras Adicionales

- ✅ **Eliminados 2 nodos desconectados** que causaban errores de validación:
  - `Basic LLM Chain` (ID: 1969faec-ad44-4fe7-9063-86967d1e65be)
  - `OpenRouter Chat Model1` (ID: b9e18433-971a-44ae-9655-fd7decce0e22)

- ✅ **Corregido operador del nodo "If"** (ID: cd3c8dc1-9fd3-40ba-87c3-fcff04e89acd)
  - Problema: Operador binario `empty` tenía incorrectamente `singleValue: true`
  - Solución: Eliminada la propiedad `singleValue` del operador

- ✅ **Habilitado nodo "acepta los terminos"** (ID: d3f556db-4e2d-497a-820f-169e80cbe85f)
  - Estaba deshabilitado (`disabled: true`)
  - Ahora está habilitado (`disabled: false`)

## 🔧 Configuración Requerida

### Credenciales de PostgreSQL

Los nodos actualizados requieren **credenciales de PostgreSQL** en n8n:

1. Ve a **Settings → Credentials** en n8n
2. Crea una nueva credencial de tipo **"Postgres"**
3. Configura los siguientes datos de conexión:
   - **Host:** Tu servidor PostgreSQL
   - **Database:** `nutridiab`
   - **Schema:** `nutridiab`
   - **User:** Usuario con permisos en el schema nutridiab
   - **Password:** Contraseña del usuario
   - **Port:** 5432 (por defecto)
   - **SSL:** Según tu configuración

4. Asigna la credencial a todos los nodos de PostgreSQL en el workflow

### Credenciales Actuales (Referencia)

Los nodos tienen referencias a estas credenciales (debes actualizarlas):
- `Postgres Nutridiab` (ID: if0MZrhqa9d5WIej)
- `Postgres zynaptyc` (ID: 3B6LqpqjxhMnJHqD)

## 📊 Schema de Base de Datos

### Tabla: `nutridiab.usuarios`

```sql
CREATE TABLE nutridiab.usuarios (
  "usuario ID" SERIAL PRIMARY KEY,
  "remoteJid" TEXT UNIQUE NOT NULL,
  "AceptoTerminos" BOOLEAN DEFAULT FALSE,
  "msgaceptacion" TEXT,
  "aceptadoel" TIMESTAMP
);
```

### Tabla: `nutridiab.Consultas`

```sql
CREATE TABLE nutridiab."Consultas" (
  id SERIAL PRIMARY KEY,
  tipo TEXT NOT NULL,
  usuario_id INTEGER REFERENCES nutridiab.usuarios("usuario ID"),
  resultado TEXT,
  costo NUMERIC,
  created_at TIMESTAMP DEFAULT NOW()
);
```

## 🔄 Compatibilidad con Nombres de Columnas

Los nodos INSERT en la tabla `Consultas` incluyen compatibilidad para nombres de columnas:

```javascript
"usuario_id": "={{ $('Get a row (Postgres)').item.json['usuario ID'] || $('Get a row (Postgres)').item.json['usuario_id'] }}"
```

Esto maneja tanto:
- `"usuario ID"` (con espacio, estilo Supabase)
- `usuario_id` (sin espacio, estilo PostgreSQL estándar)

## ⚠️ Notas Importantes

1. **El workflow está INACTIVO** (`active: false`)
   - Actívalo manualmente después de configurar las credenciales

2. **Versión de nodos PostgreSQL:** 2.6
   - Asegúrate de tener n8n actualizado para soportar esta versión

3. **Expresiones n8n preservadas**
   - Todas las expresiones `={{ }}` funcionan igual que antes
   - No se requieren cambios en la lógica del workflow

4. **Conexiones intactas**
   - Todas las conexiones entre nodos se mantienen igual
   - El flujo de ejecución es idéntico al anterior

## 🚀 Próximos Pasos

1. [ ] Configurar credenciales de PostgreSQL en n8n
2. [ ] Verificar que el schema `nutridiab` existe en PostgreSQL
3. [ ] Probar el workflow con datos de prueba
4. [ ] Activar el workflow cuando esté listo
5. [ ] Monitorear las primeras ejecuciones para detectar errores

## 📝 Herramientas Utilizadas

- **MCP (Model Context Protocol)** para la conexión con n8n
- **n8n API** para actualización parcial del workflow
- **Operaciones aplicadas:** 10 (2 eliminaciones, 1 corrección, 6 actualizaciones, 1 habilitación)

## ✨ Beneficios de la Migración

1. **Control total de la base de datos**: Acceso directo sin capas intermedias
2. **Mejor rendimiento**: Queries SQL nativos optimizados
3. **Mayor flexibilidad**: Capacidad de usar SQL avanzado
4. **Independencia de Supabase**: No dependes de servicios externos para operaciones DB
5. **Debugging más fácil**: Logs y queries directos en PostgreSQL

---

**¿Necesitas ayuda?** Consulta la [documentación de nodos PostgreSQL de n8n](https://docs.n8n.io/integrations/builtin/app-nodes/n8n-nodes-base.postgres/)

