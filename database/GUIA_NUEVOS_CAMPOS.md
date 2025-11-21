# 📋 Guía de Uso - Nuevos Campos de Usuario

## Campos Agregados

### 1. **Activo** (BOOLEAN)
- **Propósito**: Controla si el usuario está activo en el sistema
- **Default**: `TRUE`
- **Uso**: Desactivar usuarios sin eliminarlos

```sql
-- Desactivar usuario
UPDATE nutridiab.usuarios 
SET "Activo" = FALSE 
WHERE "usuario ID" = 123;

-- Consultar solo usuarios activos
SELECT * FROM nutridiab.usuarios WHERE "Activo" = TRUE;
```

### 2. **Bloqueado** (BOOLEAN)
- **Propósito**: Indica si el usuario fue bloqueado por administrador
- **Default**: `FALSE`
- **Uso**: Bloquear usuarios por violación de términos

```sql
-- Bloquear usuario (usando función)
SELECT nutridiab.bloquear_usuario(123, TRUE);

-- Desbloquear usuario
SELECT nutridiab.bloquear_usuario(123, FALSE);

-- Consultar usuarios bloqueados
SELECT * FROM nutridiab.usuarios WHERE "Bloqueado" = TRUE;
```

### 3. **Tipo ID** (VARCHAR 50)
- **Propósito**: Tipo de identificación del usuario
- **Default**: `NULL`
- **Valores sugeridos**: 'DNI', 'Pasaporte', 'Cédula', 'RUT', 'RFC', etc.

```sql
-- Actualizar tipo de ID
UPDATE nutridiab.usuarios 
SET "Tipo ID" = 'DNI' 
WHERE "usuario ID" = 123;

-- Consultar por tipo de ID
SELECT * FROM nutridiab.usuarios WHERE "Tipo ID" = 'DNI';
```

### 4. **Lenguaje** (VARCHAR 10)
- **Propósito**: Idioma preferido del usuario
- **Default**: `'es'`
- **Valores sugeridos**: 'es', 'en', 'pt', 'fr', etc. (ISO 639-1)

```sql
-- Actualizar idioma
UPDATE nutridiab.usuarios 
SET "Lenguaje" = 'en' 
WHERE "usuario ID" = 123;

-- Consultar usuarios por idioma
SELECT * FROM nutridiab.usuarios WHERE "Lenguaje" = 'es';

-- Estadísticas de idiomas
SELECT "Lenguaje", COUNT(*) as total
FROM nutridiab.usuarios
GROUP BY "Lenguaje"
ORDER BY total DESC;
```

### 5. **invitado** (BOOLEAN)
- **Propósito**: Indica si el usuario llegó por invitación
- **Default**: `FALSE`
- **Uso**: Seguimiento de programa de referidos

```sql
-- Marcar usuario como invitado
UPDATE nutridiab.usuarios 
SET invitado = TRUE 
WHERE "usuario ID" = 123;

-- Contar usuarios invitados vs directos
SELECT 
  invitado,
  COUNT(*) as total
FROM nutridiab.usuarios
GROUP BY invitado;

-- Usuarios invitados en el último mes
SELECT * FROM nutridiab.usuarios 
WHERE invitado = TRUE 
  AND created_at >= NOW() - INTERVAL '30 days';
```

### 6. **ultpago** (DATE)
- **Propósito**: Fecha del último pago realizado
- **Default**: `NULL`
- **Uso**: Control de suscripciones/pagos

```sql
-- Registrar pago
UPDATE nutridiab.usuarios 
SET ultpago = CURRENT_DATE 
WHERE "usuario ID" = 123;

-- Usuarios con pago vencido (más de 30 días)
SELECT * FROM nutridiab.usuarios 
WHERE ultpago < CURRENT_DATE - INTERVAL '30 days';

-- Usuarios sin pago nunca
SELECT * FROM nutridiab.usuarios WHERE ultpago IS NULL;

-- Próximos a vencer (dentro de 7 días)
SELECT 
  "usuario ID",
  nombre,
  ultpago,
  (ultpago + INTERVAL '30 days') AS proximo_vencimiento
FROM nutridiab.usuarios 
WHERE ultpago IS NOT NULL
  AND (ultpago + INTERVAL '30 days') <= CURRENT_DATE + INTERVAL '7 days'
ORDER BY ultpago;
```

---

## 🔧 Funciones Útiles Creadas

### 1. **puede_usar_servicio()**
Verifica si un usuario puede usar el servicio:

```sql
-- Verificar usuario
SELECT * FROM nutridiab.puede_usar_servicio(123);

-- Resultado ejemplo:
-- puede_usar | razon                    | estado
-- -----------|--------------------------|----------
-- false      | Usuario bloqueado...     | bloqueado
```

**Estados posibles**:
- `no_encontrado`: Usuario no existe
- `bloqueado`: Usuario bloqueado por admin
- `inactivo`: Usuario desactivado
- `pendiente_terminos`: No aceptó términos
- `pendiente_datos`: Datos incompletos
- `pendiente_email`: Email no verificado
- `activo`: Todo OK, puede usar servicio

### 2. **bloquear_usuario()**
Bloquea o desbloquea un usuario:

```sql
-- Bloquear
SELECT nutridiab.bloquear_usuario(123, TRUE);

-- Desbloquear
SELECT nutridiab.bloquear_usuario(123, FALSE);
```

### 3. **activar_usuario()**
Activa o desactiva un usuario:

```sql
-- Desactivar
SELECT nutridiab.activar_usuario(123, FALSE);

-- Activar
SELECT nutridiab.activar_usuario(123, TRUE);
```

---

## 📊 Vista Actualizada

La vista `nutridiab.vista_usuarios_estado` ahora incluye los nuevos campos:

```sql
SELECT * FROM nutridiab.vista_usuarios_estado;
```

**Campos incluidos**:
- Todos los campos anteriores
- `Activo`
- `Bloqueado`
- `Tipo ID`
- `Lenguaje`
- `invitado`
- `ultpago`
- `costo_total` (suma de costos de consultas)

**Estados actualizados**:
- `inactivo`: Usuario no activo
- `bloqueado`: Usuario bloqueado
- `pendiente_terminos`: Sin aceptar términos
- `pendiente_datos`: Sin datos completos
- `pendiente_email`: Sin email verificado
- `activo`: Todo OK

---

## 🎯 Casos de Uso Comunes

### Caso 1: Verificación antes de procesar consulta

```sql
-- En tu workflow n8n, antes de procesar:
SELECT * FROM nutridiab.puede_usar_servicio({{ $json.usuario_id }});

-- Si puede_usar = FALSE, enviar mensaje con la razón
-- Si puede_usar = TRUE, procesar consulta normalmente
```

### Caso 2: Desactivar usuario temporalmente

```sql
-- Desactivar (vacaciones, pausa de servicio)
SELECT nutridiab.activar_usuario(123, FALSE);

-- Reactivar cuando vuelva
SELECT nutridiab.activar_usuario(123, TRUE);
```

### Caso 3: Bloquear por violación de términos

```sql
-- Bloquear usuario
SELECT nutridiab.bloquear_usuario(123, TRUE);

-- El usuario NO podrá usar el servicio
-- Mensaje: "Usuario bloqueado por administrador"
```

### Caso 4: Sistema de pagos

```sql
-- Registrar pago mensual
UPDATE nutridiab.usuarios 
SET ultpago = CURRENT_DATE 
WHERE "usuario ID" = 123;

-- Verificar suscripción activa (últimos 30 días)
SELECT 
  CASE 
    WHEN ultpago IS NULL THEN 'sin_pago'
    WHEN ultpago >= CURRENT_DATE - INTERVAL '30 days' THEN 'activo'
    ELSE 'vencido'
  END AS estado_pago
FROM nutridiab.usuarios
WHERE "usuario ID" = 123;
```

### Caso 5: Programa de referidos

```sql
-- Al registrar usuario invitado
INSERT INTO nutridiab.usuarios (
  "remoteJid",
  invitado,
  "AceptoTerminos"
) VALUES (
  '5491155555555@s.whatsapp.net',
  TRUE,  -- Es invitado
  FALSE
);

-- Estadísticas de referidos
SELECT 
  DATE_TRUNC('month', created_at) as mes,
  COUNT(*) FILTER (WHERE invitado = TRUE) as invitados,
  COUNT(*) FILTER (WHERE invitado = FALSE) as directos
FROM nutridiab.usuarios
GROUP BY mes
ORDER BY mes DESC;
```

### Caso 6: Internacionalización

```sql
-- Obtener mensaje según idioma del usuario
SELECT 
  u."Lenguaje",
  CASE u."Lenguaje"
    WHEN 'es' THEN '¡Hola! Bienvenido a Nutridiab'
    WHEN 'en' THEN 'Hello! Welcome to Nutridiab'
    WHEN 'pt' THEN 'Olá! Bem-vindo ao Nutridiab'
    ELSE '¡Hola! Bienvenido a Nutridiab'
  END as mensaje_bienvenida
FROM nutridiab.usuarios u
WHERE u."usuario ID" = 123;
```

---

## 🔍 Queries Útiles de Administración

### Dashboard de Control

```sql
-- Resumen general
SELECT 
  COUNT(*) as total_usuarios,
  COUNT(*) FILTER (WHERE "Activo" = TRUE) as activos,
  COUNT(*) FILTER (WHERE "Activo" = FALSE) as inactivos,
  COUNT(*) FILTER (WHERE "Bloqueado" = TRUE) as bloqueados,
  COUNT(*) FILTER (WHERE invitado = TRUE) as invitados,
  COUNT(*) FILTER (WHERE ultpago IS NOT NULL) as con_pagos
FROM nutridiab.usuarios;
```

### Usuarios por idioma

```sql
SELECT 
  "Lenguaje",
  COUNT(*) as total,
  ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as porcentaje
FROM nutridiab.usuarios
GROUP BY "Lenguaje"
ORDER BY total DESC;
```

### Usuarios con suscripción próxima a vencer

```sql
SELECT 
  "usuario ID",
  nombre,
  email,
  ultpago,
  (ultpago + INTERVAL '30 days') AS vencimiento,
  CURRENT_DATE - ultpago as dias_desde_pago
FROM nutridiab.usuarios
WHERE ultpago IS NOT NULL
  AND ultpago < CURRENT_DATE
  AND ultpago >= CURRENT_DATE - INTERVAL '35 days'
ORDER BY ultpago;
```

### Usuarios problemáticos (bloqueados o inactivos)

```sql
SELECT 
  "usuario ID",
  nombre,
  email,
  "remoteJid",
  "Activo",
  "Bloqueado",
  updated_at
FROM nutridiab.usuarios
WHERE "Bloqueado" = TRUE OR "Activo" = FALSE
ORDER BY updated_at DESC;
```

---

## 🚀 Integración con n8n

### Ejemplo de Nodo Code en Workflow

```javascript
// Verificar si usuario puede usar servicio
const usuarioId = $json.usuario_id;

const resultado = await $('Postgres').execute({
  query: `SELECT * FROM nutridiab.puede_usar_servicio(${usuarioId})`
});

const puedeUsar = resultado[0].puede_usar;
const razon = resultado[0].razon;
const estado = resultado[0].estado;

if (!puedeUsar) {
  // Enviar mensaje de error por WhatsApp
  return {
    json: {
      error: true,
      mensaje: razon,
      estado: estado
    }
  };
}

// Continuar con el flujo normal
return { json: { ...$ json, puede_continuar: true } };
```

---

## 📝 Notas Importantes

1. **Activo vs Bloqueado**:
   - `Activo=FALSE`: Desactivación temporal (usuario puede reactivarse)
   - `Bloqueado=TRUE`: Bloqueo permanente por admin (requiere desbloqueo manual)

2. **Lenguaje**:
   - Usar códigos ISO 639-1 (2 letras): es, en, pt, fr, de, etc.
   - Default: 'es' (español)

3. **Sistema de Pagos**:
   - `ultpago`: Solo fecha, no hora
   - Calcular vencimiento: `ultpago + INTERVAL '30 days'`
   - NULL = nunca pagó o servicio gratuito

4. **Programa de Referidos**:
   - `invitado=TRUE`: Usuario llegó por invitación
   - `invitado=FALSE`: Registro directo
   - Útil para métricas de crecimiento

---

**Versión**: 1.0  
**Fecha**: 2025-11-21  
**Proyecto**: Nutridiab - Control Nutricional para Diabéticos

