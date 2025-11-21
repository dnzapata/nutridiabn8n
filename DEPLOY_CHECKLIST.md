# ✅ Checklist de Deploy - Nutridiab en Dokploy

Usa esta lista para asegurarte de completar todos los pasos del deploy. **Nutridiab: aplicación de control nutricional para diabéticos**.

---

## 📋 Pre-Deploy

- [ ] Tienes acceso SSH a tu VPS de Hostinger
- [ ] Dokploy está instalado y corriendo
- [ ] Tienes un dominio configurado
- [ ] El dominio apunta a la IP de tu VPS (DNS configurado)
- [ ] Tienes las credenciales de APIs:
  - [ ] OpenAI API Key
  - [ ] OpenRouter API Key
  - [ ] Evolution API (WhatsApp) configurada
  - [ ] Proyecto en Supabase creado

---

## 🔐 Paso 1: Generar Claves

- [ ] Generar N8N_ENCRYPTION_KEY:
  ```bash
  openssl rand -hex 32
  ```
  Resultado: `________________________________`

- [ ] Crear password fuerte para PostgreSQL
  Password: `________________________________`

---

## 🚀 Paso 2: Deploy en Dokploy

- [ ] Crear nuevo proyecto en Dokploy
- [ ] Nombre del proyecto: `nutridiab-n8n`
- [ ] Tipo: `Docker Compose`
- [ ] Copiar contenido de `docker-compose.dokploy.yml`
- [ ] Configurar variables de entorno (ver `env.dokploy.template`)
- [ ] Click en **Deploy**
- [ ] Esperar a que servicios estén **Running** (verde)

**URLs de verificación**:
- [ ] PostgreSQL running: ✅
- [ ] n8n running: ✅

---

## 🌐 Paso 3: Configurar Dominio

- [ ] Ir a Domains & SSL en Dokploy
- [ ] Agregar dominio: `_______________________________`
- [ ] Habilitar SSL/TLS (Let's Encrypt)
- [ ] Configurar Port: `5678`
- [ ] Save y esperar certificado SSL (5-10 min)
- [ ] Verificar: `https://tu-dominio.com` carga n8n ✅

---

## 👤 Paso 4: Configurar n8n

- [ ] Abrir: `https://tu-dominio.com`
- [ ] Completar registro inicial:
  - Email: `_______________________________`
  - Password: `_______________________________`
  - Nombre: `_______________________________`
- [ ] Login exitoso ✅

---

## 📥 Paso 5: Importar Workflow

- [ ] En n8n: Workflows → Import from File
- [ ] Copiar contenido de `n8n/workflows/nutridiab.json`
- [ ] Pegar y hacer click en Import
- [ ] Workflow "nutridiab" visible en lista ✅

---

## 🔑 Paso 6: Configurar Credenciales

### Supabase

- [ ] Settings → Credentials → Add Credential
- [ ] Tipo: Supabase API
- [ ] Host: `tu-proyecto.supabase.co`
- [ ] Service API Key: `eyJ...`
- [ ] Test Connection ✅
- [ ] Save

### OpenAI

- [ ] Add Credential → OpenAI API
- [ ] API Key: `sk-...`
- [ ] Test ✅
- [ ] Save

### OpenRouter

- [ ] Add Credential → OpenRouter API
- [ ] API Key: `sk-or-...`
- [ ] Test ✅
- [ ] Save

---

## 🗄️ Paso 7: Crear Base de Datos Supabase

- [ ] Ir a supabase.com → Tu proyecto
- [ ] SQL Editor → New Query
- [ ] Copiar y ejecutar SQL de `DEPLOY_DOKPLOY.md` (Paso 6.2)
- [ ] Verificar tablas creadas:
  - [ ] `nutridiab.usuarios` existe
  - [ ] `nutridiab.Consultas` existe
  - [ ] `nutridiab.mensajes` existe y tiene datos

**Verificación**:
```sql
SELECT COUNT(*) FROM nutridiab.mensajes;
```
Resultado esperado: 7 filas ✅

---

## 🔄 Paso 8: Configurar Workflow

En n8n, abrir workflow "nutridiab":

- [ ] Nodo "Get a row" (Supabase) → Seleccionar credencial
- [ ] Nodo "Create a row" (Supabase) → Seleccionar credencial
- [ ] Nodo "Update a row" (Supabase) → Seleccionar credencial
- [ ] Nodo "Guardar Consulta..." (3 nodos) → Seleccionar credencial
- [ ] Nodo "OpenAI Chat Model" → Seleccionar credencial
- [ ] Nodo "OpenRouter Chat Model" (2 nodos) → Seleccionar credencial
- [ ] Nodo "Transcribe audio" → Seleccionar credencial

---

## ✅ Paso 9: Activar Workflow

- [ ] En workflow "nutridiab"
- [ ] Click en toggle "Inactive" (arriba derecha)
- [ ] Cambiar a "Active" (verde) ✅
- [ ] No hay errores visibles

---

## 📱 Paso 10: Configurar WhatsApp (Evolution API)

- [ ] Evolution API instalada y corriendo
- [ ] Instancia creada
- [ ] QR escaneado y conectado
- [ ] Obtener datos:
  - Server URL: `_______________________________`
  - Instance ID: `_______________________________`
  - API Key: `_______________________________`

- [ ] Configurar webhook en Evolution API:
  ```
  https://tu-dominio.com/webhook/1d1fc275-745b-43bd-84b0-8a4ddf594612
  ```

---

## 🧪 Paso 11: Pruebas

### Test 1: Nuevo Usuario

- [ ] Enviar mensaje por WhatsApp: "Hola"
- [ ] Recibir mensaje de bienvenida ✅
- [ ] Verificar en Supabase:
  ```sql
  SELECT * FROM nutridiab.usuarios ORDER BY created_at DESC LIMIT 1;
  ```
  Usuario creado ✅

### Test 2: Aceptar Términos

- [ ] Responder: "Acepto"
- [ ] Recibir confirmación ✅
- [ ] Verificar en Supabase:
  ```sql
  SELECT "AceptoTerminos" FROM nutridiab.usuarios WHERE remoteJid = 'tu_numero@s.whatsapp.net';
  ```
  Resultado: `true` ✅

### Test 3: Consulta de Texto

- [ ] Enviar: "Una manzana"
- [ ] Recibir análisis de hidratos ✅
- [ ] Verificar en Supabase:
  ```sql
  SELECT * FROM nutridiab."Consultas" WHERE tipo = 'texto' ORDER BY created_at DESC LIMIT 1;
  ```
  Consulta guardada ✅

### Test 4: Consulta con Imagen

- [ ] Enviar foto de un plato de comida
- [ ] Recibir análisis ✅
- [ ] Verificar consulta tipo 'imagen' en DB ✅

### Test 5: Consulta con Audio

- [ ] Enviar audio describiendo comida
- [ ] Recibir análisis ✅
- [ ] Verificar consulta tipo 'audio' en DB ✅

---

## 📊 Paso 12: Deploy Frontend (Opcional)

- [ ] Build del frontend:
  ```bash
  cd frontend
  npm run build
  ```
- [ ] Desplegar en Dokploy o hosting estático
- [ ] Configurar dominio: `admin.tu-dominio.com`
- [ ] Verificar dashboard accesible ✅

---

## 🔒 Paso 13: Seguridad

- [ ] Cambiar passwords por defecto
- [ ] Activar firewall en VPS:
  ```bash
  ufw allow 22/tcp
  ufw allow 80/tcp
  ufw allow 443/tcp
  ufw enable
  ```
- [ ] Configurar backups automáticos
- [ ] (Opcional) Activar N8N_BASIC_AUTH
- [ ] (Opcional) Restringir acceso por IP

---

## 📈 Paso 14: Monitoreo

- [ ] Configurar alertas en Dokploy
- [ ] Verificar logs funcionan correctamente
- [ ] Setup backup automático (crontab)
- [ ] Documentar credenciales en lugar seguro

**Backup configurado**:
```bash
0 2 * * * /root/backup.sh >> /var/log/backup.log 2>&1
```

---

## 🎉 Deploy Completado

- [ ] Sistema funcionando correctamente
- [ ] Usuarios pueden registrarse
- [ ] Consultas se procesan correctamente
- [ ] Datos se guardan en Supabase
- [ ] Costos se registran
- [ ] SSL activo (HTTPS)
- [ ] Monitoreo configurado
- [ ] Backups activos

**Fecha de deploy**: `____/____/________`  
**Deployed by**: `_______________________________`  
**URL producción**: `https://_______________________________`

---

## 📝 Notas del Deploy

```
Agregar aquí cualquier nota importante, cambios realizados,
problemas encontrados y sus soluciones, etc.






```

---

## 🆘 Contactos de Soporte

- VPS Support: https://www.hostinger.com/support
- Dokploy Docs: https://docs.dokploy.com/
- n8n Community: https://community.n8n.io/
- Supabase Support: https://supabase.com/support

---

**✅ Deploy verificado y funcional**

Firma: __________________ Fecha: ____/____/________

