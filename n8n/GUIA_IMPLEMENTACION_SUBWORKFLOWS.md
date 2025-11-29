# 🛠️ Guía de Implementación - Sub-Workflows NutriDiab

## 📚 Tabla de Contenidos

1. [Configuración Inicial](#configuración-inicial)
2. [Implementación por Fases](#implementación-por-fases)
3. [Ejemplos de Código por Sub-Workflow](#ejemplos-de-código-por-sub-workflow)
4. [Testing y Validación](#testing-y-validación)
5. [Troubleshooting](#troubleshooting)

---

## 🔧 Configuración Inicial

### Variables de Entorno Necesarias

Agregar a `.env`:

```env
# WhatsApp (Evolution API)
WHATSAPP_SERVER_URL=https://evolution.example.com
WHATSAPP_INSTANCE=nutridiab
WHATSAPP_APIKEY=your_apikey_here

# OpenAI (Whisper)
OPENAI_API_KEY=sk-...

# OpenRouter (GPT-4)
OPENROUTER_API_KEY=sk-or-...

# PostgreSQL (Supabase)
POSTGRES_HOST=db.xxxxxxxx.supabase.co
POSTGRES_PORT=5432
POSTGRES_DB=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_password
```

### Credenciales en n8n

Crear las siguientes credenciales en n8n:

1. **PostgreSQL** (Supabase)
   - Host: `db.xxxxxxxx.supabase.co`
   - Port: `5432`
   - Database: `postgres`
   - User: `postgres`
   - Password: `your_password`
   - SSL: `require`

2. **HTTP Request** (Evolution API)
   - Authentication: `Generic Credential Type`
   - Header Auth
   - Name: `apikey`
   - Value: `your_apikey_here`

3. **OpenAI**
   - API Key: `sk-...`

4. **HTTP Request** (OpenRouter)
   - Authentication: `Generic Credential Type`
   - Header Auth
   - Name: `Authorization`
   - Value: `Bearer sk-or-...`

---

## 📅 Implementación por Fases

### FASE 1: Servicios Comunes (Semana 1)

#### 1.1 nutridiab-service-whatsapp-send.json

**Crear nuevo workflow en n8n**:

```json
{
  "name": "[PROD] [Service] - WhatsApp Send",
  "nodes": [
    {
      "parameters": {
        "mode": "manual",
        "inputFields": {
          "fields": [
            {
              "name": "remoteJid",
              "type": "string",
              "required": true,
              "description": "WhatsApp ID del usuario"
            },
            {
              "name": "mensaje",
              "type": "string",
              "required": true,
              "description": "Mensaje a enviar"
            }
          ]
        }
      },
      "name": "When Executed by Another Workflow",
      "type": "n8n-nodes-base.executeWorkflowTrigger",
      "typeVersion": 1,
      "position": [250, 300]
    },
    {
      "parameters": {
        "jsCode": "// Preparar datos para WhatsApp API\nconst remoteJid = $input.item.json.remoteJid;\nconst mensaje = $input.item.json.mensaje;\n\n// Extraer número sin sufijo @s.whatsapp.net\nconst numero = remoteJid.replace('@s.whatsapp.net', '');\n\nreturn [{\n  json: {\n    number: numero,\n    text: mensaje,\n    remoteJid: remoteJid\n  }\n}];"
      },
      "name": "Preparar Datos",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [450, 300]
    },
    {
      "parameters": {
        "url": "={{ $env.WHATSAPP_SERVER_URL }}/message/sendText/{{ $env.WHATSAPP_INSTANCE }}",
        "authentication": "predefinedCredentialType",
        "nodeCredentialType": "evolutionApi",
        "sendBody": true,
        "specifyBody": "json",
        "jsonBody": "={\n  \"number\": \"{{ $json.number }}\",\n  \"text\": \"{{ $json.text }}\"\n}",
        "options": {
          "retry": {
            "maxRetries": 5,
            "retryInterval": 5000
          },
          "timeout": 10000
        }
      },
      "name": "Enviar a WhatsApp",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4,
      "position": [650, 300],
      "retryOnFail": true,
      "maxTries": 5,
      "waitBetweenTries": 5000
    },
    {
      "parameters": {
        "jsCode": "// Verificar respuesta\nconst response = $input.item.json;\n\nif (response.key && response.key.id) {\n  return [{\n    json: {\n      enviado: true,\n      message_id: response.key.id,\n      timestamp: new Date().toISOString(),\n      remoteJid: $('Preparar Datos').item.json.remoteJid\n    }\n  }];\n} else {\n  throw new Error('No se pudo enviar el mensaje: ' + JSON.stringify(response));\n}"
      },
      "name": "Formatear Respuesta",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [850, 300]
    }
  ],
  "connections": {
    "When Executed by Another Workflow": {
      "main": [[{ "node": "Preparar Datos", "type": "main", "index": 0 }]]
    },
    "Preparar Datos": {
      "main": [[{ "node": "Enviar a WhatsApp", "type": "main", "index": 0 }]]
    },
    "Enviar a WhatsApp": {
      "main": [[{ "node": "Formatear Respuesta", "type": "main", "index": 0 }]]
    }
  }
}
```

**Testing del Sub-Workflow**:

1. Guardar el workflow
2. Ir a "Test workflow" → "Manually"
3. Agregar datos de prueba en el trigger:
```json
{
  "remoteJid": "5491155555555@s.whatsapp.net",
  "mensaje": "Hola! Este es un mensaje de prueba"
}
```
4. Ejecutar y verificar que llegue el mensaje

---

#### 1.2 nutridiab-service-save-consultation.json

```json
{
  "name": "[PROD] [Service] - Save Consultation",
  "nodes": [
    {
      "parameters": {
        "mode": "manual",
        "inputFields": {
          "fields": [
            {
              "name": "usuario_id",
              "type": "number",
              "required": true
            },
            {
              "name": "tipo",
              "type": "string",
              "required": true,
              "description": "texto, imagen o audio"
            },
            {
              "name": "resultado",
              "type": "string",
              "required": true
            },
            {
              "name": "costo",
              "type": "number",
              "required": true
            }
          ]
        }
      },
      "name": "When Executed by Another Workflow",
      "type": "n8n-nodes-base.executeWorkflowTrigger",
      "typeVersion": 1,
      "position": [250, 300]
    },
    {
      "parameters": {
        "operation": "executeQuery",
        "query": "INSERT INTO nutridiab.\"Consultas\" \n(\"usuario ID\", tipo, resultado, \"Costo\", created_at)\nVALUES ($1, $2, $3, $4, NOW())\nRETURNING id, \"usuario ID\", tipo, resultado, \"Costo\", created_at;",
        "additionalFields": {
          "queryParameters": "={{ [\n  $json.usuario_id,\n  $json.tipo,\n  $json.resultado,\n  $json.costo\n] }}"
        }
      },
      "name": "Guardar en BD",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 2.4,
      "position": [450, 300],
      "credentials": {
        "postgres": {
          "id": "1",
          "name": "Supabase - Nutridiab"
        }
      }
    },
    {
      "parameters": {
        "jsCode": "// Formatear respuesta\nconst consulta = $input.item.json;\n\nreturn [{\n  json: {\n    consulta_id: consulta.id,\n    guardado: true,\n    timestamp: consulta.created_at,\n    usuario_id: consulta['usuario ID'],\n    tipo: consulta.tipo,\n    costo: parseFloat(consulta.Costo)\n  }\n}];"
      },
      "name": "Formatear Respuesta",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [650, 300]
    }
  ],
  "connections": {
    "When Executed by Another Workflow": {
      "main": [[{ "node": "Guardar en BD", "type": "main", "index": 0 }]]
    },
    "Guardar en BD": {
      "main": [[{ "node": "Formatear Respuesta", "type": "main", "index": 0 }]]
    }
  }
}
```

**Testing**:
```json
{
  "usuario_id": 1,
  "tipo": "texto",
  "resultado": "🍽️ Test de análisis nutricional",
  "costo": 0.0025
}
```

---

#### 1.3 nutridiab-service-audit-log.json

```json
{
  "name": "[PROD] [Service] - Audit Log",
  "nodes": [
    {
      "parameters": {
        "mode": "manual",
        "inputFields": {
          "fields": [
            {
              "name": "evento",
              "type": "string",
              "required": true
            },
            {
              "name": "usuario_id",
              "type": "number",
              "required": false
            },
            {
              "name": "detalles",
              "type": "json",
              "required": false
            }
          ]
        }
      },
      "name": "When Executed by Another Workflow",
      "type": "n8n-nodes-base.executeWorkflowTrigger",
      "typeVersion": 1,
      "position": [250, 300]
    },
    {
      "parameters": {
        "operation": "executeQuery",
        "query": "INSERT INTO nutridiab.audit_logs \n(evento, usuario_id, detalles, created_at)\nVALUES ($1, $2, $3, NOW())\nRETURNING id, evento, created_at;",
        "additionalFields": {
          "queryParameters": "={{ [\n  $json.evento,\n  $json.usuario_id || null,\n  JSON.stringify($json.detalles || {})\n] }}"
        }
      },
      "name": "Insertar Log",
      "type": "n8n-nodes-base.postgres",
      "typeVersion": 2.4,
      "position": [450, 300]
    },
    {
      "parameters": {
        "jsCode": "return [{\n  json: {\n    log_id: $input.item.json.id,\n    timestamp: $input.item.json.created_at,\n    evento: $input.item.json.evento\n  }\n}];"
      },
      "name": "Formatear",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [650, 300]
    }
  ],
  "connections": {
    "When Executed by Another Workflow": {
      "main": [[{ "node": "Insertar Log", "type": "main", "index": 0 }]]
    },
    "Insertar Log": {
      "main": [[{ "node": "Formatear", "type": "main", "index": 0 }]]
    }
  }
}
```

**Crear tabla en PostgreSQL**:
```sql
CREATE TABLE IF NOT EXISTS nutridiab.audit_logs (
  id SERIAL PRIMARY KEY,
  evento VARCHAR(100) NOT NULL,
  usuario_id INTEGER REFERENCES nutridiab.usuarios("usuario ID"),
  detalles JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_evento ON nutridiab.audit_logs(evento);
CREATE INDEX idx_audit_logs_usuario ON nutridiab.audit_logs(usuario_id);
CREATE INDEX idx_audit_logs_created ON nutridiab.audit_logs(created_at);
```

---

### FASE 2: Procesamiento IA (Semana 2)

#### 2.1 nutridiab-ai-process-text.json

**Workflow completo**:

```json
{
  "name": "[PROD] [IA] - Process Text",
  "nodes": [
    {
      "parameters": {
        "mode": "manual",
        "inputFields": {
          "fields": [
            {
              "name": "texto",
              "type": "string",
              "required": true,
              "description": "Texto a analizar"
            },
            {
              "name": "usuario_id",
              "type": "number",
              "required": true
            }
          ]
        }
      },
      "name": "When Executed by Another Workflow",
      "type": "n8n-nodes-base.executeWorkflowTrigger",
      "typeVersion": 1,
      "position": [250, 300]
    },
    {
      "parameters": {
        "url": "https://openrouter.ai/api/v1/credits",
        "authentication": "predefinedCredentialType",
        "nodeCredentialType": "openRouterApi",
        "options": {}
      },
      "name": "Verificar Saldo Inicial",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4,
      "position": [450, 300]
    },
    {
      "parameters": {
        "jsCode": "const texto = $('When Executed by Another Workflow').item.json.texto;\nconst saldoInicial = $input.item.json.total_credits;\n\nconst systemPrompt = `Eres **NutriDiab**, un asistente de IA especializado en nutrición para personas con diabetes tipo 1 y 2.\n\nTu misión es estimar los hidratos de carbono presentes en alimentos a partir de descripciones de texto.\n\nReglas:\n1. Analiza los alimentos descritos\n2. Estima porciones y hidratos por ítem\n3. Usa bases nutricionales estándar (USDA, FAO, BEDCA)\n4. Devuelve respuesta en texto natural, empática y clara\n\nFormato de respuesta:\n---\n🍽️ **Alimentos detectados:** [lista con peso y gramos de hidratos]\n🔢 **Total de hidratos:** [valor total en gramos]\n💬 **Comentario:** [explicación educativa]\n📊 **Nivel de confianza:** [baja / media / alta]\n⚠️ **Advertencia:** Esta información es orientativa.\n---\n\nMantén un tono cercano, tranquilo y educativo.\nNo des diagnósticos ni ajustes de medicación.`;\n\nreturn [{\n  json: {\n    saldoInicial: saldoInicial,\n    messages: [\n      { role: \"system\", content: systemPrompt },\n      { role: \"user\", content: texto }\n    ]\n  }\n}];"
      },
      "name": "Preparar Prompt",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [650, 300]
    },
    {
      "parameters": {
        "url": "https://openrouter.ai/api/v1/chat/completions",
        "authentication": "predefinedCredentialType",
        "nodeCredentialType": "openRouterApi",
        "sendBody": true,
        "specifyBody": "json",
        "jsonBody": "={\n  \"model\": \"openai/gpt-4-turbo\",\n  \"messages\": {{ JSON.stringify($json.messages) }},\n  \"temperature\": 0.7,\n  \"max_tokens\": 500\n}",
        "options": {
          "timeout": 30000
        }
      },
      "name": "OpenRouter GPT-4",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4,
      "position": [850, 300]
    },
    {
      "parameters": {
        "url": "https://openrouter.ai/api/v1/credits",
        "authentication": "predefinedCredentialType",
        "nodeCredentialType": "openRouterApi",
        "options": {}
      },
      "name": "Verificar Saldo Final",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4,
      "position": [1050, 300]
    },
    {
      "parameters": {
        "jsCode": "const response = $('OpenRouter GPT-4').item.json;\nconst saldoInicial = $('Preparar Prompt').item.json.saldoInicial;\nconst saldoFinal = $input.item.json.total_credits;\n\nconst analisis = response.choices[0].message.content;\nconst costo = saldoInicial - saldoFinal;\n\nreturn [{\n  json: {\n    analisis_nutricional: analisis,\n    costo: costo,\n    tokens_usados: {\n      input: response.usage.prompt_tokens,\n      output: response.usage.completion_tokens,\n      total: response.usage.total_tokens\n    },\n    model: response.model\n  }\n}];"
      },
      "name": "Calcular Costo y Formatear",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [1250, 300]
    }
  ],
  "connections": {
    "When Executed by Another Workflow": {
      "main": [[{ "node": "Verificar Saldo Inicial", "type": "main", "index": 0 }]]
    },
    "Verificar Saldo Inicial": {
      "main": [[{ "node": "Preparar Prompt", "type": "main", "index": 0 }]]
    },
    "Preparar Prompt": {
      "main": [[{ "node": "OpenRouter GPT-4", "type": "main", "index": 0 }]]
    },
    "OpenRouter GPT-4": {
      "main": [[{ "node": "Verificar Saldo Final", "type": "main", "index": 0 }]]
    },
    "Verificar Saldo Final": {
      "main": [[{ "node": "Calcular Costo y Formatear", "type": "main", "index": 0 }]]
    }
  }
}
```

**Testing**:
```json
{
  "texto": "Una empanada de carne al horno",
  "usuario_id": 1
}
```

---

#### 2.2 nutridiab-ai-process-image.json

**Workflow con Vision AI**:

```json
{
  "name": "[PROD] [IA] - Process Image",
  "nodes": [
    {
      "parameters": {
        "mode": "manual",
        "inputFields": {
          "fields": [
            {
              "name": "message_id",
              "type": "string",
              "required": true
            },
            {
              "name": "remoteJid",
              "type": "string",
              "required": true
            },
            {
              "name": "usuario_id",
              "type": "number",
              "required": true
            }
          ]
        }
      },
      "name": "When Executed by Another Workflow",
      "type": "n8n-nodes-base.executeWorkflowTrigger",
      "typeVersion": 1,
      "position": [250, 300]
    },
    {
      "parameters": {
        "url": "={{ $env.WHATSAPP_SERVER_URL }}/message/downloadMediaMessage/{{ $env.WHATSAPP_INSTANCE }}",
        "authentication": "predefinedCredentialType",
        "nodeCredentialType": "evolutionApi",
        "sendBody": true,
        "specifyBody": "json",
        "jsonBody": "={\n  \"key\": {\n    \"id\": \"{{ $json.message_id }}\",\n    \"remoteJid\": \"{{ $json.remoteJid }}\"\n  }\n}",
        "options": {
          "retry": {
            "maxRetries": 5,
            "retryInterval": 5000
          }
        }
      },
      "name": "Descargar Imagen",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4,
      "position": [450, 300],
      "retryOnFail": true
    },
    {
      "parameters": {
        "jsCode": "// Extraer base64 de la respuesta\nconst response = $input.item.json;\nlet base64Image;\n\nif (response.base64) {\n  base64Image = response.base64;\n} else if (response.media && response.media.base64) {\n  base64Image = response.media.base64;\n} else {\n  throw new Error('No se encontró imagen en formato base64');\n}\n\n// Asegurarse de que tenga el prefijo correcto\nif (!base64Image.startsWith('data:image')) {\n  base64Image = 'data:image/jpeg;base64,' + base64Image;\n}\n\nreturn [{\n  json: {\n    image_url: base64Image\n  }\n}];"
      },
      "name": "Preparar Imagen",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [650, 300]
    },
    {
      "parameters": {
        "url": "https://openrouter.ai/api/v1/credits",
        "authentication": "predefinedCredentialType",
        "nodeCredentialType": "openRouterApi"
      },
      "name": "Saldo Inicial",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4,
      "position": [850, 300]
    },
    {
      "parameters": {
        "jsCode": "const imageUrl = $('Preparar Imagen').item.json.image_url;\nconst saldoInicial = $input.item.json.total_credits;\n\nconst systemPrompt = `Eres **NutriDiab**, un asistente especializado en análisis nutricional de imágenes de alimentos.\n\nAnaliza la imagen y estima:\n1. Alimentos visibles\n2. Porciones aproximadas\n3. Hidratos de carbono por alimento\n4. Total de hidratos\n\nFormato:\n🍽️ **Alimentos detectados:** [lista]\n🔢 **Total de hidratos:** [gramos]\n💬 **Comentario:** [educativo]\n📊 **Nivel de confianza:** [baja/media/alta]\n⚠️ **Advertencia:** Esta información es orientativa.`;\n\nreturn [{\n  json: {\n    saldoInicial: saldoInicial,\n    messages: [\n      {\n        role: \"user\",\n        content: [\n          { type: \"text\", text: systemPrompt },\n          { type: \"image_url\", image_url: { url: imageUrl } }\n        ]\n      }\n    ]\n  }\n}];"
      },
      "name": "Preparar Vision Prompt",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [1050, 300]
    },
    {
      "parameters": {
        "url": "https://openrouter.ai/api/v1/chat/completions",
        "authentication": "predefinedCredentialType",
        "nodeCredentialType": "openRouterApi",
        "sendBody": true,
        "specifyBody": "json",
        "jsonBody": "={\n  \"model\": \"openai/gpt-4-vision-preview\",\n  \"messages\": {{ JSON.stringify($json.messages) }},\n  \"max_tokens\": 500\n}",
        "options": {
          "timeout": 60000
        }
      },
      "name": "GPT-4 Vision",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4,
      "position": [1250, 300]
    },
    {
      "parameters": {
        "url": "https://openrouter.ai/api/v1/credits",
        "authentication": "predefinedCredentialType",
        "nodeCredentialType": "openRouterApi"
      },
      "name": "Saldo Final",
      "type": "n8n-nodes-base.httpRequest",
      "typeVersion": 4,
      "position": [1450, 300]
    },
    {
      "parameters": {
        "jsCode": "const response = $('GPT-4 Vision').item.json;\nconst saldoInicial = $('Preparar Vision Prompt').item.json.saldoInicial;\nconst saldoFinal = $input.item.json.total_credits;\n\nconst analisis = response.choices[0].message.content;\nconst costo = saldoInicial - saldoFinal;\n\nreturn [{\n  json: {\n    analisis_nutricional: analisis,\n    costo: costo,\n    imagen_procesada: true,\n    tokens_usados: response.usage\n  }\n}];"
      },
      "name": "Calcular y Formatear",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [1650, 300]
    }
  ],
  "connections": {
    "When Executed by Another Workflow": {
      "main": [[{ "node": "Descargar Imagen", "type": "main", "index": 0 }]]
    },
    "Descargar Imagen": {
      "main": [[{ "node": "Preparar Imagen", "type": "main", "index": 0 }]]
    },
    "Preparar Imagen": {
      "main": [[{ "node": "Saldo Inicial", "type": "main", "index": 0 }]]
    },
    "Saldo Inicial": {
      "main": [[{ "node": "Preparar Vision Prompt", "type": "main", "index": 0 }]]
    },
    "Preparar Vision Prompt": {
      "main": [[{ "node": "GPT-4 Vision", "type": "main", "index": 0 }]]
    },
    "GPT-4 Vision": {
      "main": [[{ "node": "Saldo Final", "type": "main", "index": 0 }]]
    },
    "Saldo Final": {
      "main": [[{ "node": "Calcular y Formatear", "type": "main", "index": 0 }]]
    }
  }
}
```

---

## ✅ Testing y Validación

### Testing Individual de Sub-Workflows

Para cada sub-workflow:

1. **Activar modo "Manually"** en el trigger
2. **Agregar datos de prueba** (pinned data)
3. **Ejecutar y verificar outputs**
4. **Guardar ejecución exitosa** (para usar en desarrollo)

### Testing del Workflow Principal

1. **Crear workflow de prueba**:

```json
{
  "name": "Test - Main Workflow Integration",
  "nodes": [
    {
      "parameters": {},
      "name": "Manual Trigger",
      "type": "n8n-nodes-base.manualTrigger",
      "typeVersion": 1,
      "position": [250, 300]
    },
    {
      "parameters": {
        "jsCode": "return [{\n  json: {\n    texto: 'Una empanada de carne al horno',\n    usuario_id: 1\n  }\n}];"
      },
      "name": "Datos de Prueba",
      "type": "n8n-nodes-base.code",
      "typeVersion": 2,
      "position": [450, 300]
    },
    {
      "parameters": {
        "workflowId": "ID_DEL_SUBWORKFLOW_PROCESS_TEXT",
        "options": {}
      },
      "name": "Llamar Process Text",
      "type": "n8n-nodes-base.executeWorkflow",
      "typeVersion": 1,
      "position": [650, 300]
    }
  ]
}
```

---

## 🔍 Troubleshooting

### Error: "Sub-workflow no encontrado"

**Solución**:
1. Verificar que el sub-workflow esté guardado
2. Verificar el ID del workflow
3. Asegurarse que esté activado

### Error: "Timeout en descarga de media"

**Solución**:
1. Aumentar timeout en nodo HTTP Request a 60s
2. Verificar conectividad con Evolution API
3. Revisar que el message_id sea correcto

### Error: "Insufficient credits (OpenRouter)"

**Solución**:
1. Verificar saldo en https://openrouter.ai/credits
2. Agregar créditos
3. Implementar manejo de error en workflow

### Error: "Invalid image format"

**Solución**:
1. Verificar que la imagen esté en base64
2. Asegurarse que tenga prefijo `data:image/jpeg;base64,`
3. Validar tamaño de imagen (< 20MB)

---

## 📊 Métricas de Éxito

Después de implementar, verificar:

- ✅ Tiempo de respuesta < 5s para texto
- ✅ Tiempo de respuesta < 10s para imagen
- ✅ Tiempo de respuesta < 15s para audio
- ✅ Tasa de éxito > 95%
- ✅ Costos por consulta:
  - Texto: $0.001 - $0.003
  - Imagen: $0.01 - $0.03
  - Audio: $0.005 - $0.015

---

**Documento generado**: 2025-11-26
**Versión**: 1.0

