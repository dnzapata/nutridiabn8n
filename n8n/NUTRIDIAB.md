# 🩺 Nutridiab - Workflow de Análisis Nutricional para Diabéticos

## 📋 Descripción General

**Nutridiab** es un asistente de IA especializado en nutrición para personas con diabetes tipo 1 y 2. Funciona vía WhatsApp y puede analizar alimentos mediante:

- 📝 **Texto**: Descripción del alimento ("Una empanada de carne")
- 📸 **Imagen**: Foto del plato de comida
- 🎤 **Audio**: Mensaje de voz describiendo la comida

El sistema calcula los **hidratos de carbono** presentes en los alimentos y proporciona información nutricional relevante.

---

## 🏗️ Arquitectura del Sistema

```
WhatsApp → Evolution API → n8n Webhook → Procesamiento IA → Base de Datos → Respuesta
```

### Componentes:

1. **WhatsApp Business API** (Evolution API)
2. **n8n Workflow** (Lógica de negocio)
3. **OpenAI** (Transcripción de audio)
4. **OpenRouter** (GPT-4 para análisis)
5. **Supabase** (PostgreSQL como base de datos)
6. **LangChain** (Memoria de conversación)

---

## 🔄 Flujo del Workflow

### 1️⃣ Recepción de Mensaje

**Webhook**: `POST /webhook/1d1fc275-745b-43bd-84b0-8a4ddf594612`

Recibe el webhook desde WhatsApp con la estructura:

```json
{
  "server_url": "https://api.whatsapp.com",
  "instance": "instance_id",
  "apikey": "your_api_key",
  "data": {
    "key": {
      "id": "message_id",
      "remoteJid": "5491155555555@s.whatsapp.net"
    },
    "pushName": "Usuario",
    "message": {
      "conversation": "texto del mensaje",
      "imageMessage": {},
      "audioMessage": {}
    }
  }
}
```

---

### 2️⃣ Extracción de Datos

**Nodo**: "Datos Whatsapp"

Extrae y normaliza:
- `remoteJid`: ID único del usuario en WhatsApp
- `chatid`: ID del chat
- `username`: Nombre del usuario
- `conten`: Contenido del mensaje
- `Tipo`: "texto", "imagen" o "audio"
- `messageid`: ID del mensaje para descargar multimedia

---

### 3️⃣ Verificación de Saldo

**Nodo**: "Call 'Saldo Opensource'"

Verifica el saldo disponible para llamadas a las APIs de IA (OpenAI/OpenRouter).

---

### 4️⃣ Verificación de Usuario

**Nodo**: "Get a row" (Supabase)

**Tabla**: `nutridiab.usuarios`

Busca si el usuario existe en la base de datos por `remoteJid`.

**Columnas**:
- `usuario ID` (PK)
- `remoteJid` (unique)
- `AceptoTerminos` (boolean)
- `msgaceptacion` (text)
- `aceptadoel` (timestamp)

---

### 5️⃣ Flujo de Onboarding (Usuario Nuevo)

Si el usuario **NO existe**:

1. **Leer Bienvenida** → Mensaje de bienvenida
2. **Leer Presentación** → Explicación del servicio
3. **Leer TERMINOS** → Términos y condiciones
4. **Leer ACEPTA** → Solicitud de aceptación
5. **Create a row** → Registra al usuario en Supabase
6. **Responder ACEPTA** → Confirmación

---

### 6️⃣ Verificación de Términos (Usuario Existente)

Si el usuario **existe** pero **NO aceptó términos**:

1. **es mensage de texto** → Verifica que sea texto
2. **Analiza respuesta** → IA analiza si acepta los términos
3. **acepta los terminos** → IF true:
   - **Update a row** → Marca `AceptoTerminos = true`
   - **Leer cuando acepta** → Mensaje de confirmación
4. **IF false**:
   - **Leer cuando responde otra cosa** → Insiste en aceptar

---

### 7️⃣ Procesamiento de Consultas (Usuario con Términos Aceptados)

**Nodo Switch**: Detecta el tipo de entrada

#### 📝 TEXTO

1. **AI texto** → Procesa con GPT-4
   - Prompt: Usuario describe el alimento
   - Responde con análisis de hidratos
2. **Responder mensaje** → Envía respuesta por WhatsApp

#### 📸 IMAGEN

1. **Descargar imagen** → Obtiene base64 de la imagen
2. **Convert Imagen** → Convierte a binario
3. **AI Imagen** → Análisis con Vision AI (GPT-4 Vision)
4. **Responder Imagen** → Envía respuesta

#### 🎤 AUDIO

1. **Descargar audio** → Obtiene base64 del audio
2. **Convert audio** → Convierte a binario
3. **Transcribe audio** → OpenAI Whisper transcribe
4. **AI Audio** → Analiza el texto transcrito
5. **Responder audio** → Envía respuesta

---

### 8️⃣ Registro de Consulta

**Nodo**: "Guardar Consulta [Texto|Imagen|Audio]"

**Tabla**: `nutridiab.Consultas`

**Columnas**:
- `id` (PK)
- `tipo`: "texto", "imagen" o "audio"
- `usuario ID` (FK)
- `resultado`: Respuesta generada
- `Costo`: Costo en USD de la consulta
- `created_at` (timestamp)

---

### 9️⃣ Cálculo de Costos

1. **Saldo Opensource [tipo]** → Verifica saldo final
2. **Calcula Costo [tipo]** → `saldo_inicial - saldo_final`
3. Guarda el costo en la tabla `Consultas`

---

## 🤖 Prompt del Sistema (IA)

El asistente **NutriDiab** usa este prompt:

```
Eres **NutriDiab**, un asistente de IA especializado en nutrición 
para personas con diabetes tipo 1 y 2. 

Tu misión es estimar los hidratos de carbono presentes en alimentos 
a partir de:
- (a) imágenes de comidas 
- (b) descripciones de texto sobre alimentos

Reglas:
1. Analiza los alimentos visibles o descritos
2. Estima porciones y hidratos por ítem
3. Usa bases nutricionales estándar (USDA, FAO, BEDCA)
4. Devuelve respuesta en texto natural, empática y clara

Formato de respuesta:
---
🍽️ **Alimentos detectados:** [lista con peso y gramos de hidratos]
🔢 **Total de hidratos:** [valor total en gramos]
💬 **Comentario:** [explicación educativa]
📊 **Nivel de confianza:** [baja / media / alta]
⚠️ **Advertencia:** Esta información es orientativa.
---

Mantén un tono cercano, tranquilo y educativo.
No des diagnósticos ni ajustes de medicación.
```

---

## 📊 Esquema de Base de Datos (Supabase)

### Tabla: `nutridiab.usuarios`

```sql
CREATE TABLE nutridiab.usuarios (
  "usuario ID" SERIAL PRIMARY KEY,
  "remoteJid" VARCHAR(255) UNIQUE NOT NULL,
  "AceptoTerminos" BOOLEAN DEFAULT FALSE,
  "msgaceptacion" TEXT,
  "aceptadoel" TIMESTAMP WITH TIME ZONE,
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Tabla: `nutridiab.Consultas`

```sql
CREATE TABLE nutridiab.Consultas (
  "id" SERIAL PRIMARY KEY,
  "tipo" VARCHAR(20) NOT NULL, -- 'texto', 'imagen', 'audio'
  "usuario ID" INTEGER REFERENCES nutridiab.usuarios("usuario ID"),
  "resultado" TEXT NOT NULL,
  "Costo" NUMERIC(10, 6),
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## 🔐 Configuración Requerida

### 1. WhatsApp API (Evolution API)

Necesitas una instancia de Evolution API configurada:

```env
WHATSAPP_SERVER_URL=https://your-evolution-api.com
WHATSAPP_INSTANCE=your_instance
WHATSAPP_APIKEY=your_api_key
```

### 2. OpenAI API

Para transcripción de audio:

```env
OPENAI_API_KEY=sk-...
```

### 3. OpenRouter API

Para GPT-4 y Vision:

```env
OPENROUTER_API_KEY=sk-or-...
```

### 4. Supabase

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=eyJ...
```

---

## 📈 Métricas y Costos

El sistema registra automáticamente:

- ✅ Número de consultas por usuario
- ✅ Tipo de consulta (texto/imagen/audio)
- ✅ Costo individual por consulta
- ✅ Costo total acumulado
- ✅ Fecha y hora de cada consulta

### Costos Aproximados (OpenRouter GPT-4):

- **Texto**: ~$0.001 - $0.003 por consulta
- **Imagen**: ~$0.01 - $0.03 por consulta
- **Audio**: ~$0.005 - $0.01 (transcripción + análisis)

---

## 🎯 Casos de Uso

### Ejemplo 1: Consulta por Texto

**Usuario escribe**: "Una empanada de carne al horno"

**NutriDiab responde**:
```
🍽️ **Alimentos detectados:** 
Empanada de carne al horno (~80 g, ~25 g de hidratos)

🔢 **Total de hidratos:** ~25 g

💬 **Comentario:** 
La masa es la principal fuente de hidratos. Si es frita, 
puede aumentar un poco.

📊 **Nivel de confianza:** Alta

⚠️ **Advertencia:** 
Esta información es orientativa y no reemplaza la opinión 
de tu profesional de salud.
```

### Ejemplo 2: Consulta por Imagen

**Usuario envía**: Foto de un plato con arroz, pollo y ensalada

**NutriDiab responde**:
```
🍽️ **Alimentos detectados:** 
- Arroz blanco cocido (150 g, ~45 g de hidratos)
- Pechuga de pollo a la plancha (110 g, 0 g)
- Ensalada de lechuga y tomate (90 g, ~5 g)

🔢 **Total de hidratos:** ~50 g

💬 **Comentario:** 
El arroz es el principal aporte de hidratos; el pollo y 
la ensalada tienen impacto mínimo.

📊 **Nivel de confianza:** Media

⚠️ **Advertencia:** 
Esta información es orientativa.
```

### Ejemplo 3: Consulta por Audio

**Usuario envía audio**: "Hola, me comí dos bananas y un yogur"

**NutriDiab**:
1. Transcribe el audio
2. Analiza el contenido
3. Responde con los hidratos

---

## 🔧 Mantenimiento

### Workflows Auxiliares

El workflow principal depende de:

1. **LeerMensajeNutridiab** (ID: `DLxj51eAlmRPl8sv`)
   - Lee mensajes pre-configurados de la BD
   - Códigos: BIENVENIDA, SERVICIO, TERMINOS, ACEPTA, etc.

2. **Saldo Opensource** (ID: `ata9gpgU1ImbcjBq`)
   - Consulta saldo disponible en OpenRouter

### Actualizar Mensajes

Los mensajes están en una tabla de Supabase:

```sql
SELECT * FROM nutridiab.mensajes WHERE CODIGO = 'BIENVENIDA';
```

---

## 🚨 Manejo de Errores

- **Audio no descarga**: Retry 5 veces con delay de 5s
- **Imagen no descarga**: Retry 5 veces con delay de 5s
- **Saldo insuficiente**: No se procesa, se notifica al admin
- **Usuario no acepta términos**: Insiste hasta que acepte

---

## 📚 Recursos Nutricionales

El sistema usa como referencia:

- **USDA FoodData Central** (Base de datos oficial USA)
- **BEDCA** (Base Española de Datos de Composición de Alimentos)
- **FAO/INFOODS** (Organización Mundial)

---

## 🎓 Mejoras Futuras

- [ ] Integración con Telegram
- [ ] Análisis de recetas completas
- [ ] Cálculo de índice glucémico
- [ ] Sugerencias de porciones personalizadas
- [ ] Historial de comidas del usuario
- [ ] Gráficos de consumo diario
- [ ] Alertas de hidratos altos
- [ ] Integración con glucómetros

---

## ⚠️ Disclaimer

Este sistema proporciona **información orientativa** y NO reemplaza:
- Consultas médicas profesionales
- Ajustes de medicación
- Planes nutricionales personalizados
- Tratamiento médico

Siempre consulta con tu médico o nutricionista antes de hacer cambios en tu dieta o tratamiento.

---

**Versión**: 1.0  
**Última actualización**: 2025-11-20  
**Autor**: Nutridiab Team

