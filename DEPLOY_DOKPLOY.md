# 🚀 Deploy de NutriDiab en Dokploy (Hostinger VPS)

Esta guía te ayudará a desplegar tu workflow NutriDiab usando Dokploy en un VPS de Hostinger.

---

## 📋 Requisitos Previos

- ✅ VPS de Hostinger con Dokploy instalado
- ✅ Dominio apuntando al VPS
- ✅ Acceso SSH al servidor
- ✅ Dokploy funcionando correctamente

---

## 🔧 Paso 1: Preparar Variables de Entorno

### 1.1 Generar N8N_ENCRYPTION_KEY

**Desde tu terminal local o SSH**:

```bash
openssl rand -hex 32
```

Guarda este valor, lo necesitarás.

### 1.2 Crear archivo .env en Dokploy

En Dokploy, ve a tu proyecto → **Environment Variables** y agrega:

```env
# PostgreSQL
POSTGRES_USER=n8n
POSTGRES_PASSWORD=TuPasswordSeguro123!@#
POSTGRES_DB=n8n

# n8n Encryption (Usa el que generaste arriba)
N8N_ENCRYPTION_KEY=tu_clave_generada_con_openssl

# Network
N8N_HOST=tu-dominio.com
N8N_PORT=5678
GENERIC_TIMEZONE=America/Mexico_City

# Executions
EXECUTIONS_DATA_SAVE_ON_ERROR=all
EXECUTIONS_DATA_SAVE_ON_SUCCESS=all
EXECUTIONS_DATA_PRUNE=true
EXECUTIONS_DATA_MAX_AGE=336
EXECUTIONS_DATA_PRUNE_MAX_COUNT=10000
N8N_CONCURRENCY_PRODUCTION_LIMIT=10
```

---

## 📦 Paso 2: Deploy en Dokploy

### 2.1 Crear Nuevo Proyecto

1. **En Dokploy**: Click en **"New Project"**
2. **Nombre**: `nutridiab-n8n`
3. **Type**: `Docker Compose`

### 2.2 Copiar Docker Compose

En el campo **Compose File**, pega:

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
      # Configuration PostgreSQL
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=${POSTGRES_DB}
      - DB_POSTGRESDB_USER=${POSTGRES_USER}
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
      
      # SECURITY - Encryption (IMPORTANT)
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
      
      # Network configuration
      - N8N_HOST=${N8N_HOST}
      - N8N_PORT=${N8N_PORT}
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - WEBHOOK_URL=https://${N8N_HOST}/
      - GENERIC_TIMEZONE=${GENERIC_TIMEZONE}
      - N8N_SECURE_COOKIE=false

      # Executions
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

### 2.3 Deploy

1. Click en **"Deploy"**
2. Espera a que los contenedores se inicien
3. Verifica que ambos servicios estén **Running** (verde)

---

## 🌐 Paso 3: Configurar Dominio y SSL

### 3.1 En Dokploy

1. Ve a **Domains & SSL**
2. Agrega tu dominio: `tu-dominio.com`
3. Habilita **SSL/TLS** (Let's Encrypt automático)
4. Configura el **Port**: `5678`
5. **Save**

Dokploy generará automáticamente el certificado SSL.

---

## 📥 Paso 4: Importar Workflow NutriDiab

### 4.1 Primera Vez - Configurar n8n

1. Abre: `https://tu-dominio.com`
2. Completa el registro inicial:
   - Email
   - Password
   - Nombre

### 4.2 Importar Workflow

**Método 1: Desde el Editor**

1. En n8n: **Workflows** → **Import from File**
2. Copia y pega el contenido de `n8n/workflows/nutridiab.json`
3. Click en **Import**

**Método 2: Desde SSH (Recomendado)**

```bash
# Conecta por SSH a tu VPS
ssh root@tu-vps-ip

# Encuentra el ID del contenedor n8n
docker ps | grep n8n

# Copia el workflow al contenedor
docker cp nutridiab.json <container-id>:/home/node/.n8n/

# O usando Dokploy CLI
dokploy exec n8n -- n8n import:workflow --input=/path/to/nutridiab.json
```

---

## 🔐 Paso 5: Configurar Credenciales

Tu workflow necesita credenciales para:

### 5.1 Supabase

1. En n8n: **Settings** → **Credentials** → **Add Credential**
2. Tipo: **Supabase**
3. Configura:
   - Host: `tu-proyecto.supabase.co`
   - Service API Key: (de Supabase)

### 5.2 OpenAI

1. **Add Credential** → **OpenAI**
2. API Key: `sk-...` (tu key de OpenAI)

### 5.3 OpenRouter

1. **Add Credential** → **OpenRouter**
2. API Key: `sk-or-...` (tu key de OpenRouter)

### 5.4 Evolution API (WhatsApp)

Configura las variables en el workflow:
- `server_url`: URL de tu Evolution API
- `instance`: ID de tu instancia
- `apikey`: Tu API key de Evolution

---

## 🗄️ Paso 6: Crear Base de Datos en Supabase

### 6.1 Crear Proyecto en Supabase

1. Ve a [supabase.com](https://supabase.com)
2. **New Project**
3. Nombre: `nutridiab`
4. Password: (guárdalo)
5. Region: Más cercana a tu VPS

### 6.2 Crear Tablas

En **SQL Editor** de Supabase, ejecuta:

```sql
-- Crear schema
CREATE SCHEMA IF NOT EXISTS nutridiab;

-- Tabla de usuarios
CREATE TABLE nutridiab.usuarios (
  "usuario ID" SERIAL PRIMARY KEY,
  "remoteJid" VARCHAR(255) UNIQUE NOT NULL,
  "AceptoTerminos" BOOLEAN DEFAULT FALSE,
  "msgaceptacion" TEXT,
  "aceptadoel" TIMESTAMP WITH TIME ZONE,
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de consultas
CREATE TABLE nutridiab."Consultas" (
  "id" SERIAL PRIMARY KEY,
  "tipo" VARCHAR(20) NOT NULL,
  "usuario ID" INTEGER REFERENCES nutridiab.usuarios("usuario ID"),
  "resultado" TEXT NOT NULL,
  "Costo" NUMERIC(10, 6),
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de mensajes (para onboarding)
CREATE TABLE nutridiab.mensajes (
  "id" SERIAL PRIMARY KEY,
  "CODIGO" VARCHAR(50) UNIQUE NOT NULL,
  "Texto" TEXT NOT NULL,
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar mensajes de ejemplo
INSERT INTO nutridiab.mensajes ("CODIGO", "Texto") VALUES
('BIENVENIDA', '¡Hola! 👋 Soy NutriDiab, tu asistente nutricional especializado en diabetes. Estoy aquí para ayudarte a calcular los hidratos de carbono de tus alimentos. 🍽️'),
('SERVICIO', 'Puedo analizar:\n📝 Texto: Descríbeme tu comida\n📸 Imagen: Envíame una foto de tu plato\n🎤 Audio: Cuéntame qué comiste'),
('TERMINOS', '⚠️ IMPORTANTE: Este servicio es solo informativo y no reemplaza la opinión de tu médico o nutricionista. Los cálculos son aproximaciones basadas en IA.\n\nPara continuar, necesito que aceptes estos términos.'),
('ACEPTA', '¿Aceptas los términos y condiciones? Responde "Acepto" o "Sí" para continuar.'),
('RESPONDEACEPTA', '✅ ¡Perfecto! Ya puedes empezar a enviarme información sobre tus alimentos. ¿Qué comiste hoy?'),
('RESPONDENO', '❌ Por favor, responde "Acepto" para poder usar el servicio. Los términos son necesarios para continuar.'),
('NOENTENDI', '🤔 No entendí tu mensaje. ¿Podrías describirme mejor qué alimento o comida consumiste?');

-- Índices para mejor performance
CREATE INDEX idx_usuarios_remotejid ON nutridiab.usuarios("remoteJid");
CREATE INDEX idx_consultas_usuario ON nutridiab."Consultas"("usuario ID");
CREATE INDEX idx_consultas_fecha ON nutridiab."Consultas"("created_at");
CREATE INDEX idx_consultas_tipo ON nutridiab."Consultas"("tipo");
```

---

## ✅ Paso 7: Activar Workflow

1. En n8n, abre el workflow **nutridiab**
2. Verifica que todas las credenciales estén configuradas
3. Click en el **toggle Active** (arriba a la derecha)
4. Debería ponerse en verde

---

## 🧪 Paso 8: Probar el Sistema

### 8.1 Test desde WhatsApp

1. Envía un mensaje al número de WhatsApp configurado
2. Deberías recibir el mensaje de bienvenida
3. Acepta los términos
4. Envía un mensaje como: "Una manzana"
5. Deberías recibir el análisis de hidratos

### 8.2 Verificar en Supabase

```sql
-- Ver usuarios registrados
SELECT * FROM nutridiab.usuarios ORDER BY created_at DESC;

-- Ver consultas
SELECT * FROM nutridiab."Consultas" ORDER BY created_at DESC LIMIT 10;

-- Ver estadísticas
SELECT 
  tipo,
  COUNT(*) as total,
  AVG("Costo") as costo_promedio
FROM nutridiab."Consultas"
GROUP BY tipo;
```

---

## 📊 Paso 9: Deploy del Frontend React

### 9.1 Build del Frontend

**En tu máquina local**:

```bash
cd frontend

# Configurar variables de producción
echo "VITE_API_URL=https://tu-dominio.com" > .env.production
echo "VITE_APP_NAME=NutriDiab Admin" >> .env.production

# Build
npm run build
```

### 9.2 Deploy en Dokploy

**Opción 1: Proyecto Separado**

1. En Dokploy: **New Project** → **Static Site**
2. Tipo: **React**
3. Build Command: `npm run build`
4. Output Directory: `dist`
5. **Deploy**

**Opción 2: Agregar al Compose (Recomendado)**

Agrega al `docker-compose.dokploy.yml`:

```yaml
  frontend:
    image: node:18-alpine
    working_dir: /app
    volumes:
      - ./frontend:/app
      - /app/node_modules
    command: sh -c "npm install && npm run build && npx serve -s dist -l 3000"
    ports:
      - "3000:3000"
    environment:
      - VITE_API_URL=https://${N8N_HOST}
      - VITE_APP_NAME=NutriDiab Admin
    networks:
      - dokploy-network
```

**Opción 3: Nginx (Mejor Performance)**

Crea `frontend/Dockerfile`:

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

Y `nginx.conf`:

```nginx
server {
    listen 80;
    server_name _;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /webhook/ {
        proxy_pass https://tu-dominio.com/webhook/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## 🔒 Paso 10: Seguridad en Producción

### 10.1 Activar Basic Auth (Opcional)

En las variables de entorno de Dokploy:

```env
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=PasswordSeguro123!
```

### 10.2 Restringir Acceso por IP (Recomendado)

En Dokploy → **Security** → **IP Whitelist**:
- Agrega tu IP
- IP de tu oficina
- IP de WhatsApp API

### 10.3 Configurar Firewall en VPS

```bash
# Solo permite puertos necesarios
ufw allow 22/tcp   # SSH
ufw allow 80/tcp   # HTTP
ufw allow 443/tcp  # HTTPS
ufw enable
```

---

## 📈 Paso 11: Monitoreo

### 11.1 Ver Logs en Dokploy

1. En Dokploy → Tu proyecto
2. **Logs** tab
3. Selecciona servicio: `n8n` o `postgres`
4. Ver logs en tiempo real

### 11.2 Logs desde SSH

```bash
# Ver logs de n8n
docker logs -f <container-name-n8n>

# Ver logs de PostgreSQL
docker logs -f <container-name-postgres>

# Ver últimas 100 líneas
docker logs --tail 100 <container-name>
```

### 11.3 Monitoreo de Recursos

En Dokploy:
- **Metrics** tab
- Ver CPU, RAM, Network
- Configurar alertas

---

## 🔄 Paso 12: Backups

### 12.1 Backup Automático de PostgreSQL

Crea un script `backup.sh`:

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/nutridiab"

mkdir -p $BACKUP_DIR

# Backup de PostgreSQL
docker exec <postgres-container> pg_dump -U n8n n8n > $BACKUP_DIR/db_$DATE.sql

# Backup de n8n workflows
docker exec <n8n-container> tar czf - /home/node/.n8n > $BACKUP_DIR/n8n_$DATE.tar.gz

# Eliminar backups antiguos (más de 7 días)
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup completado: $DATE"
```

Agregar a crontab:

```bash
# Backup diario a las 2 AM
0 2 * * * /root/backup.sh >> /var/log/backup.log 2>&1
```

### 12.2 Restaurar desde Backup

```bash
# Restaurar base de datos
docker exec -i <postgres-container> psql -U n8n n8n < backup.sql

# Restaurar workflows
docker exec -i <n8n-container> tar xzf - -C / < n8n_backup.tar.gz
```

---

## 🐛 Troubleshooting

### Error: "Cannot connect to database"

```bash
# Verificar que PostgreSQL esté corriendo
docker ps | grep postgres

# Ver logs de PostgreSQL
docker logs <postgres-container>

# Verificar variables de entorno
docker exec <n8n-container> env | grep DB
```

### Error: "Webhook not found"

1. Verifica que el workflow esté **Active**
2. Verifica la URL del webhook
3. Revisa logs: `docker logs <n8n-container>`

### Error: "Out of memory"

```bash
# Ver uso de recursos
docker stats

# Aumentar límites en Dokploy
# Settings → Resources → Memory Limit: 2GB
```

### SSL no funciona

1. Verifica que el dominio apunte a tu IP
2. En Dokploy: Domains → Regenerate Certificate
3. Espera 5-10 minutos para propagación DNS

---

## 📚 Recursos Adicionales

- [Dokploy Docs](https://docs.dokploy.com/)
- [n8n Self-Hosting](https://docs.n8n.io/hosting/)
- [PostgreSQL Docker](https://hub.docker.com/_/postgres)
- [Supabase Docs](https://supabase.com/docs)

---

## ✅ Checklist de Deploy

- [ ] VPS de Hostinger configurado
- [ ] Dokploy instalado y funcionando
- [ ] Dominio apuntando al VPS
- [ ] Variables de entorno configuradas
- [ ] N8N_ENCRYPTION_KEY generado
- [ ] Docker Compose desplegado
- [ ] SSL/TLS configurado
- [ ] n8n accesible via HTTPS
- [ ] Cuenta de n8n creada
- [ ] Workflow NutriDiab importado
- [ ] Credenciales configuradas (Supabase, OpenAI, OpenRouter)
- [ ] Base de datos Supabase creada
- [ ] Tablas creadas en Supabase
- [ ] Workflow activado
- [ ] Prueba desde WhatsApp realizada
- [ ] Frontend desplegado (opcional)
- [ ] Backups configurados
- [ ] Monitoreo activado

---

## 🎉 ¡Listo!

Tu sistema NutriDiab está ahora en producción con:

✅ n8n corriendo en tu VPS  
✅ PostgreSQL como base de datos  
✅ SSL/HTTPS configurado  
✅ Backups automáticos  
✅ Monitoreo activo  

**URL de acceso**: https://tu-dominio.com

---

**¿Necesitas ayuda?** Revisa la sección Troubleshooting o los logs en Dokploy.

**Versión**: 1.0 - Deploy con Dokploy  
**Fecha**: 2025-11-20

