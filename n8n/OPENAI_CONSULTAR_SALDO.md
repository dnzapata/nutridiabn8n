# 🔍 Workflow: Consultar Saldo OpenAI

Este workflow permite consultar información sobre tu saldo y facturación de OpenAI mediante la API.

## 📋 Descripción

El workflow consulta el endpoint de facturación de OpenAI para obtener información sobre:
- Límites de facturación (hard limit, soft limit)
- Información de suscripción
- Estado de método de pago
- Información de organización

## 🚀 Configuración

### Paso 1: Importar el Workflow

1. Abre n8n: https://wf.zynaptic.tech
2. Ve a **Workflows** → **Import from File**
3. Selecciona el archivo: `n8n/workflows/openai-consultar-saldo.json`
4. El workflow se importará con el nombre "Consultar Saldo OpenAI"

### Paso 2: Configurar la API Key de OpenAI

**Opción A: Usar Variable de Entorno (Recomendado)**

1. En n8n, ve a **Settings** → **Environment Variables**
2. Crea una variable llamada `OPENAI_API_KEY`
3. Asigna el valor de tu API key de OpenAI
4. El workflow ya está configurado para usar `{{ $env.OPENAI_API_KEY }}`

**Opción B: Configurar en el Nodo HTTP Request**

1. Abre el nodo **"HTTP Request - OpenAI Usage"**
2. En la sección **Headers**, modifica el valor de `Authorization`:
   ```
   Bearer sk-tu-api-key-aqui
   ```
3. O usa una credencial de tipo "Header Auth" en n8n

### Paso 3: Activar el Workflow

1. Activa el workflow usando el toggle en la parte superior
2. Copia la URL del webhook que se genera automáticamente

## 📡 Uso

### Endpoint

```
GET https://wf.zynaptic.tech/webhook/openai/balance
```

### Ejemplo de Petición

```bash
curl -X GET https://wf.zynaptic.tech/webhook/openai/balance
```

### Respuesta Exitosa

```json
{
  "success": true,
  "timestamp": "2025-11-28T18:59:43.794Z",
  "source": "OpenAI API",
  "data": {
    "object": "billing_subscription",
    "has_payment_method": true,
    "soft_limit_usd": 5.0,
    "hard_limit_usd": 10.0,
    "system_hard_limit_usd": 10.0,
    "access_until": 1733011200,
    "plan": {
      "title": "Pay as you go",
      "id": "payg"
    }
  },
  "billing": {
    "hard_limit_usd": 10.0,
    "soft_limit_usd": 5.0,
    "system_hard_limit_usd": 10.0
  },
  "subscription": {
    "has_payment_method": true,
    "plan": {
      "title": "Pay as you go",
      "id": "payg"
    },
    "access_until": 1733011200
  }
}
```

### Respuesta con Error

```json
{
  "success": false,
  "timestamp": "2025-11-28T18:59:43.794Z",
  "error": {
    "message": "Invalid API key",
    "type": "invalid_request_error",
    "statusCode": 401
  },
  "note": "Asegúrate de tener configurada tu API key de OpenAI correctamente"
}
```

## 🔧 Estructura del Workflow

```
Webhook (GET) 
  → HTTP Request (OpenAI API)
    → Code (Formatear Respuesta)
      → Respond to Webhook
```

### Nodos

1. **Webhook Consultar Saldo**: Recibe la petición GET
2. **HTTP Request - OpenAI Usage**: Consulta el endpoint de facturación de OpenAI
3. **Formatear Respuesta**: Procesa y formatea la respuesta
4. **Respond to Webhook**: Devuelve la respuesta JSON

## ⚠️ Notas Importantes

1. **API Key**: Necesitas una API key válida de OpenAI. Puedes obtenerla en: https://platform.openai.com/api-keys

2. **Permisos**: El endpoint `/v1/dashboard/billing/subscription` requiere que tu API key tenga permisos de facturación.

3. **Límites de Rate**: OpenAI tiene límites de rate limiting. No hagas demasiadas peticiones seguidas.

4. **Seguridad**: 
   - Nunca expongas tu API key en el código
   - Usa variables de entorno o credenciales de n8n
   - Considera agregar autenticación al webhook si es necesario

## 🔄 Alternativas

Si el endpoint de facturación no está disponible, puedes modificar el workflow para usar otros endpoints:

- **Uso de tokens**: `https://api.openai.com/v1/usage` (requiere permisos especiales)
- **Organizaciones**: `https://api.openai.com/v1/organizations`

## 📚 Referencias

- [OpenAI API Documentation](https://platform.openai.com/docs/api-reference)
- [OpenAI Billing Documentation](https://platform.openai.com/docs/guides/billing)
- [n8n HTTP Request Node](https://docs.n8n.io/integrations/builtin/core-nodes/n8n-nodes-base.httprequest/)

## 🐛 Solución de Problemas

### Error 401: Unauthorized
- Verifica que tu API key sea correcta
- Asegúrate de que la API key tenga permisos de facturación

### Error 404: Not Found
- El endpoint puede haber cambiado
- Verifica la documentación actualizada de OpenAI

### Error de Timeout
- El timeout está configurado en 10 segundos
- Puedes aumentarlo en las opciones del nodo HTTP Request

## 📝 Changelog

- **2025-11-28**: Creación inicial del workflow
  - Endpoint: `/v1/dashboard/billing/subscription`
  - Manejo de errores mejorado
  - Formateo de respuesta estructurado
