# ⚡ Deploy Rápido en Dokploy - Nutridiab

Guía ultra-rápida para desplegar Nutridiab (control nutricional para diabéticos) en Dokploy. Para detalles completos ver `DEPLOY_DOKPLOY.md`.

---

## 🎯 Paso 1: Generar Encryption Key (30 segundos)

```bash
openssl rand -hex 32
```

**Guarda el resultado**, lo necesitarás.

---

## 🚀 Paso 2: Crear Proyecto en Dokploy (2 minutos)

1. **New Project** → Nombre: `nutridiab-n8n`
2. **Tipo**: Docker Compose
3. **Compose File**: Copia y pega esto 👇

```yaml
services:
  postgres:
    image: postgres:17-alpine
    restart: unless-stopped
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      start_period: 30s
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - dokploy-network

  n8n:
    image: n8nio/n8n:latest
    restart: unless-stopped
    environment:
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=${POSTGRES_DB}
      - DB_POSTGRESDB_USER=${POSTGRES_USER}
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
      - N8N_HOST=${N8N_HOST}
      - N8N_PORT=${N8N_PORT}
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://${N8N_HOST}/
      - GENERIC_TIMEZONE=${GENERIC_TIMEZONE}
      - N8N_SECURE_COOKIE=false
      - EXECUTIONS_DATA_SAVE_ON_ERROR=${EXECUTIONS_DATA_SAVE_ON_ERROR}
      - EXECUTIONS_DATA_SAVE_ON_SUCCESS=${EXECUTIONS_DATA_SAVE_ON_SUCCESS}
      - EXECUTIONS_DATA_PRUNE=${EXECUTIONS_DATA_PRUNE}
      - EXECUTIONS_DATA_MAX_AGE=${EXECUTIONS_DATA_MAX_AGE}
      - EXECUTIONS_DATA_PRUNE_MAX_COUNT=${EXECUTIONS_DATA_PRUNE_MAX_COUNT}
      - N8N_CONCURRENCY_PRODUCTION_LIMIT=${N8N_CONCURRENCY_PRODUCTION_LIMIT}
    volumes:
      - n8n_data:/home/node/.n8n 
    user: root
    networks:
      - dokploy-network
    depends_on:
      postgres:
        condition: service_healthy

volumes:
  n8n_data:
  postgres_data:

networks:
  dokploy-network:
    external: true
```

4. **Environment Variables** → Pega esto (CAMBIAR VALORES) 👇

```env
POSTGRES_USER=n8n
POSTGRES_PASSWORD=TuPasswordSeguro123!
POSTGRES_DB=n8n
N8N_ENCRYPTION_KEY=tu_clave_del_paso_1_aqui
N8N_HOST=tu-dominio.com
N8N_PORT=5678
GENERIC_TIMEZONE=America/Mexico_City
EXECUTIONS_DATA_SAVE_ON_ERROR=all
EXECUTIONS_DATA_SAVE_ON_SUCCESS=all
EXECUTIONS_DATA_PRUNE=true
EXECUTIONS_DATA_MAX_AGE=336
EXECUTIONS_DATA_PRUNE_MAX_COUNT=10000
N8N_CONCURRENCY_PRODUCTION_LIMIT=10
```

5. **Deploy** → Esperar servicios Running ✅

---

## 🌐 Paso 3: Configurar Dominio (1 minuto)

1. **Domains & SSL** → Add Domain
2. Dominio: `tu-dominio.com`
3. Habilitar **SSL/TLS**
4. Port: `5678`
5. **Save**

Esperar 5-10 min para certificado SSL.

---

## 👤 Paso 4: Setup n8n (2 minutos)

1. Abrir: `https://tu-dominio.com`
2. Crear cuenta:
   - Email: `admin@tudominio.com`
   - Password: (fuerte)
3. Login ✅

---

## 📥 Paso 5: Importar Workflow (1 minuto)

1. **Workflows** → **Import from File**
2. Copiar TODO el contenido de `n8n/workflows/nutridiab.json`
3. Pegar → **Import**
4. Workflow importado ✅

---

## 🗄️ Paso 6: Crear BD en Supabase (3 minutos)

1. Ir a [supabase.com](https://supabase.com) → New Project
2. **SQL Editor** → Pegar esto 👇

```sql
CREATE SCHEMA IF NOT EXISTS nutridiab;

CREATE TABLE nutridiab.usuarios (
  "usuario ID" SERIAL PRIMARY KEY,
  "remoteJid" VARCHAR(255) UNIQUE NOT NULL,
  "AceptoTerminos" BOOLEAN DEFAULT FALSE,
  "msgaceptacion" TEXT,
  "aceptadoel" TIMESTAMP WITH TIME ZONE,
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE nutridiab."Consultas" (
  "id" SERIAL PRIMARY KEY,
  "tipo" VARCHAR(20) NOT NULL,
  "usuario ID" INTEGER REFERENCES nutridiab.usuarios("usuario ID"),
  "resultado" TEXT NOT NULL,
  "Costo" NUMERIC(10, 6),
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE nutridiab.mensajes (
  "id" SERIAL PRIMARY KEY,
  "CODIGO" VARCHAR(50) UNIQUE NOT NULL,
  "Texto" TEXT NOT NULL,
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

INSERT INTO nutridiab.mensajes ("CODIGO", "Texto") VALUES
('BIENVENIDA', '¡Hola! 👋 Soy NutriDiab, tu asistente nutricional.'),
('SERVICIO', 'Puedo analizar:\n📝 Texto\n📸 Imagen\n🎤 Audio'),
('TERMINOS', '⚠️ Este servicio es informativo. ¿Aceptas los términos?'),
('ACEPTA', 'Responde "Acepto" para continuar.'),
('RESPONDEACEPTA', '✅ ¡Perfecto! ¿Qué comiste hoy?'),
('RESPONDENO', '❌ Responde "Acepto" para usar el servicio.'),
('NOENTENDI', '🤔 No entendí. Descríbeme mejor el alimento.');
```

3. **Run** ✅

---

## 🔑 Paso 7: Configurar Credenciales (5 minutos)

En n8n → **Settings** → **Credentials**:

### 1. Supabase
- Type: Supabase API
- Host: `tu-proyecto.supabase.co`
- Service Key: (de Supabase Settings → API)

### 2. OpenAI
- Type: OpenAI API
- API Key: `sk-...`

### 3. OpenRouter
- Type: OpenRouter API
- API Key: `sk-or-...`

---

## ✅ Paso 8: Activar Workflow (30 segundos)

1. Abrir workflow **nutridiab**
2. Para CADA nodo Supabase → Seleccionar credencial
3. Para nodos OpenAI/OpenRouter → Seleccionar credencial
4. Toggle **Active** (arriba derecha) ✅

---

## 🧪 Paso 9: Probar (2 minutos)

Envía mensaje por WhatsApp:
- "Hola" → Recibe bienvenida ✅
- "Acepto" → Recibe confirmación ✅
- "Una manzana" → Recibe análisis ✅

---

## 🎉 ¡Listo!

**Total: ~15-20 minutos**

Sistema funcionando en: `https://tu-dominio.com`

---

## 📚 Siguiente: Detalles Completos

Lee `DEPLOY_DOKPLOY.md` para:
- Configurar backups
- Optimizar seguridad
- Deploy del frontend
- Monitoreo avanzado

---

## 🆘 Problemas?

**n8n no carga:**
- Espera 2-3 min después del deploy
- Verifica logs en Dokploy

**SSL no funciona:**
- Espera 10 min para propagación DNS
- Regenera certificado en Dokploy

**Workflow no responde:**
- Verifica que esté **Active** (verde)
- Revisa credenciales configuradas
- Mira logs: Executions tab en n8n

---

**Checklist completo**: `DEPLOY_CHECKLIST.md`  
**Guía detallada**: `DEPLOY_DOKPLOY.md`

