# 📅 Plan de Acción - 5 Semanas de Implementación

## 🎯 Objetivo

Implementar la arquitectura modular completa de NutriDiab en 5 semanas, siguiendo metodología ágil con sprints semanales.

---

## 📊 Resumen General

| Semana | Fase | Entregables | Horas | Status |
|--------|------|-------------|-------|--------|
| 1 | Servicios Comunes | 5 sub-workflows | 8h | 🔲 Pendiente |
| 2 | Procesamiento IA | 3 sub-workflows IA | 16h | 🔲 Pendiente |
| 3 | Onboarding | 3 sub-workflows onboarding | 9h | 🔲 Pendiente |
| 4 | Orquestador | 1 workflow principal | 8h | 🔲 Pendiente |
| 5 | Testing & Deploy | Sistema completo | 20h | 🔲 Pendiente |

**Total**: 61 horas (~12.2 horas/semana para 1 dev)

---

## 📅 SEMANA 1: Servicios Comunes

### Objetivo de la Semana
Crear sub-workflows reutilizables que otros workflows usarán.

### Lunes (2 horas)

#### Tarea 1.1: Setup inicial y configuración (1h)
- [ ] Crear credenciales en n8n:
  - PostgreSQL (Supabase)
  - Evolution API (WhatsApp)
  - OpenAI
  - OpenRouter
- [ ] Verificar conectividad de cada credencial
- [ ] Crear carpeta de workflows en Git (si aplica)

**Resultado esperado**: ✅ Todas las credenciales funcionando

#### Tarea 1.2: Crear tabla audit_logs (0.5h)
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

#### Tarea 1.3: Sub-workflow audit-log (0.5h)
- [ ] Crear workflow: `[PROD] [Service] - Audit Log`
- [ ] Agregar Execute Workflow Trigger
- [ ] Agregar nodo INSERT a audit_logs
- [ ] Testear con datos de prueba
- [ ] Exportar JSON a `/n8n/workflows/`

**Testing**:
```json
{
  "evento": "test_evento",
  "usuario_id": 1,
  "detalles": { "test": true }
}
```

---

### Martes (2 horas)

#### Tarea 1.4: Sub-workflow whatsapp-send (2h)
- [ ] Crear workflow: `[PROD] [Service] - WhatsApp Send`
- [ ] Agregar Execute Workflow Trigger con inputs:
  - remoteJid (string)
  - mensaje (string)
- [ ] Agregar nodo Code para preparar datos
- [ ] Agregar HTTP Request a Evolution API
- [ ] Configurar retry: 5 intentos, 5s delay
- [ ] Agregar nodo Code para formatear respuesta
- [ ] Testear envío real a tu WhatsApp
- [ ] Exportar JSON

**Testing**: Enviar mensaje a tu número

**Resultado esperado**: ✅ Recibir mensaje en WhatsApp

---

### Miércoles (2 horas)

#### Tarea 1.5: Sub-workflow save-consultation (2h)
- [ ] Crear workflow: `[PROD] [Service] - Save Consultation`
- [ ] Agregar Execute Workflow Trigger con inputs:
  - usuario_id (number)
  - tipo (string)
  - resultado (string)
  - costo (number)
- [ ] Agregar nodo Postgres INSERT
- [ ] Agregar Execute Workflow call a audit-log
- [ ] Agregar nodo Code para formatear
- [ ] Testear con datos ficticios
- [ ] Exportar JSON

**Testing**:
```json
{
  "usuario_id": 1,
  "tipo": "texto",
  "resultado": "Test análisis",
  "costo": 0.001
}
```

**Resultado esperado**: ✅ Registro en tabla Consultas

---

### Jueves (1 hora)

#### Tarea 1.6: Sub-workflow calculate-cost (0.5h)
- [ ] Crear workflow: `[PROD] [Service] - Calculate Cost`
- [ ] Agregar Execute Workflow Trigger
- [ ] Agregar nodo Code simple
- [ ] Testear cálculo
- [ ] Exportar JSON

**Código**:
```javascript
const costo = $json.saldo_inicial - $json.saldo_final;
return [{ json: { costo: Math.round(costo * 1000000) / 1000000 } }];
```

#### Tarea 1.7: Sub-workflow error-handler (0.5h)
- [ ] Crear workflow: `[PROD] [Service] - Error Handler`
- [ ] Agregar Execute Workflow Trigger
- [ ] Agregar nodo Switch por tipo de error
- [ ] Agregar nodo Code para mensajes
- [ ] Agregar call a audit-log
- [ ] Testear con diferentes tipos de error
- [ ] Exportar JSON

---

### Viernes (1 hora)

#### Tarea 1.8: Testing integrado de servicios (0.5h)
- [ ] Crear workflow de prueba temporal
- [ ] Llamar cada sub-workflow creado
- [ ] Verificar que todos respondan correctamente
- [ ] Documentar outputs de cada uno

#### Tarea 1.9: Documentación de la semana (0.5h)
- [ ] Actualizar README con IDs de workflows
- [ ] Documentar contratos de cada sub-workflow
- [ ] Commit a Git con mensaje descriptivo
- [ ] Revisar checklist de la semana

**Checklist Semana 1**:
- [x] audit-log funcional
- [x] whatsapp-send funcional
- [x] save-consultation funcional
- [x] calculate-cost funcional
- [x] error-handler funcional
- [x] Todos testeados individualmente
- [x] Exportados a JSON
- [x] Documentados

---

## 📅 SEMANA 2: Procesamiento IA

### Objetivo de la Semana
Implementar análisis nutricional con IA para texto, imagen y audio.

### Lunes (4 horas)

#### Tarea 2.1: Verificar APIs de IA (0.5h)
- [ ] Probar OpenRouter API con curl:
```bash
curl https://openrouter.ai/api/v1/chat/completions \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "openai/gpt-4-turbo",
    "messages": [{"role": "user", "content": "Test"}]
  }'
```
- [ ] Probar OpenAI API con curl:
```bash
curl https://api.openai.com/v1/audio/transcriptions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -F model="whisper-1" \
  -F file="@test.mp3"
```

#### Tarea 2.2: Sub-workflow process-text (3.5h)
- [ ] Crear workflow: `[PROD] [IA] - Process Text`
- [ ] Agregar Execute Workflow Trigger
- [ ] Agregar HTTP Request: verificar saldo OpenRouter
- [ ] Agregar nodo Code: preparar prompt sistema NutriDiab
- [ ] Agregar HTTP Request: llamar GPT-4
- [ ] Agregar HTTP Request: verificar saldo final
- [ ] Agregar nodo Code: calcular costo
- [ ] Testear con textos variados:
  - "Una empanada de carne"
  - "Arroz con pollo y ensalada"
  - "Dos bananas y un yogur"
- [ ] Exportar JSON

**Testing detallado**:
1. Input simple: "Manzana"
2. Input complejo: "Plato con 150g arroz, 100g pollo, ensalada"
3. Input ambiguo: "Comida del mediodía"

**Resultado esperado**: 
- ✅ Análisis correcto de hidratos
- ✅ Formato esperado con emojis
- ✅ Costo calculado correctamente

---

### Martes (3 horas)

#### Tarea 2.3: Crear cuenta de prueba en Evolution API (0.5h)
- [ ] Configurar instancia de prueba
- [ ] Vincular número de WhatsApp
- [ ] Probar envío de imagen
- [ ] Obtener message_id de una imagen

#### Tarea 2.4: Sub-workflow process-image base (2.5h)
- [ ] Crear workflow: `[PROD] [IA] - Process Image`
- [ ] Agregar Execute Workflow Trigger
- [ ] Agregar HTTP Request: descargar imagen de WhatsApp
- [ ] Agregar nodo Code: convertir base64
- [ ] Testear solo descarga de imagen
- [ ] Agregar HTTP Request: verificar saldo
- [ ] Exportar JSON (versión parcial)

**Testing**:
1. Enviar imagen de prueba a WhatsApp
2. Capturar message_id del webhook
3. Probar descarga de esa imagen

---

### Miércoles (3 horas)

#### Tarea 2.5: Completar process-image con Vision AI (3h)
- [ ] Agregar nodo Code: preparar prompt para Vision
- [ ] Agregar HTTP Request: GPT-4 Vision
- [ ] Agregar HTTP Request: verificar saldo final
- [ ] Agregar nodo Code: calcular costo
- [ ] Testear con imágenes variadas:
  - Plato de comida casera
  - Fast food (hamburguesa)
  - Frutas
  - Alimento empaquetado con etiqueta
- [ ] Ajustar prompts según resultados
- [ ] Exportar JSON final

**Resultado esperado**:
- ✅ Descarga correcta de imagen
- ✅ Análisis visual preciso
- ✅ Formato consistente con process-text

---

### Jueves (3 horas)

#### Tarea 2.6: Sub-workflow process-audio base (1.5h)
- [ ] Crear workflow: `[PROD] [IA] - Process Audio`
- [ ] Agregar Execute Workflow Trigger
- [ ] Agregar HTTP Request: descargar audio
- [ ] Agregar nodo Code: convertir base64 a archivo
- [ ] Testear descarga

#### Tarea 2.7: Completar process-audio con Whisper (1.5h)
- [ ] Agregar HTTP Request: OpenAI Whisper
- [ ] Agregar Execute Workflow: call a process-text
- [ ] Agregar nodo Code: sumar costos
- [ ] Testear con audios variados:
  - Audio claro: "Comí una empanada"
  - Audio con ruido
  - Audio largo (30 segundos)
- [ ] Exportar JSON

**Testing**:
1. Grabar audio de prueba en WhatsApp
2. Capturar message_id
3. Verificar transcripción correcta
4. Verificar análisis nutricional

---

### Viernes (3 horas)

#### Tarea 2.8: Testing integrado de IAs (1.5h)
- [ ] Crear workflow de prueba
- [ ] Llamar process-text con 5 casos
- [ ] Llamar process-image con 3 imágenes
- [ ] Llamar process-audio con 2 audios
- [ ] Documentar tiempos de respuesta
- [ ] Documentar costos reales

**Métricas a capturar**:
```
Texto:
- Tiempo promedio: ___ segundos
- Costo promedio: $_____

Imagen:
- Tiempo promedio: ___ segundos
- Costo promedio: $_____

Audio:
- Tiempo promedio: ___ segundos
- Costo promedio: $_____
```

#### Tarea 2.9: Optimización de prompts (1h)
- [ ] Revisar outputs de las pruebas
- [ ] Ajustar prompt de sistema si es necesario
- [ ] Reducir max_tokens si respuestas muy largas
- [ ] Testear prompts ajustados

#### Tarea 2.10: Documentación (0.5h)
- [ ] Documentar cada sub-workflow IA
- [ ] Incluir ejemplos de input/output
- [ ] Commit a Git

**Checklist Semana 2**:
- [x] process-text funcional y optimizado
- [x] process-image funcional con Vision AI
- [x] process-audio funcional con Whisper
- [x] Todos testeados con casos reales
- [x] Métricas capturadas
- [x] Documentados

---

## 📅 SEMANA 3: Onboarding y Validación

### Objetivo de la Semana
Implementar flujo de registro y validación de usuarios.

### Lunes (3 horas)

#### Tarea 3.1: Crear tabla de mensajes (0.5h)
```sql
CREATE TABLE IF NOT EXISTS nutridiab.mensajes (
  id SERIAL PRIMARY KEY,
  codigo VARCHAR(50) UNIQUE NOT NULL,
  contenido TEXT NOT NULL,
  descripcion TEXT,
  activo BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar mensajes predefinidos
INSERT INTO nutridiab.mensajes (codigo, contenido, descripcion) VALUES
('BIENVENIDA', '¡Hola! 👋 Bienvenido a *NutriDiab*', 'Mensaje de bienvenida inicial'),
('SERVICIO', 'Soy tu asistente nutricional...', 'Explicación del servicio'),
('TERMINOS', 'Para usar este servicio...', 'Términos y condiciones'),
('ACEPTA', '¿Aceptas los términos? Responde *SÍ* para continuar', 'Solicitud de aceptación'),
('CUANDO_ACEPTA', '¡Excelente! Ya puedes enviarme fotos...', 'Confirmación aceptación'),
('RESPONDE_OTRA_COSA', 'Por favor, responde *SÍ* si aceptas...', 'Insistir aceptación');
```

#### Tarea 3.2: Sub-workflow validate-user (2.5h)
- [ ] Crear workflow: `[PROD] [Service] - Validate User`
- [ ] Agregar Execute Workflow Trigger
- [ ] Agregar Postgres SELECT usuario por remoteJid
- [ ] Agregar IF: ¿usuario existe?
- [ ] Agregar IF: ¿aceptó términos?
- [ ] Agregar nodo Code: formatear resultado
- [ ] Testear con:
  - Usuario inexistente
  - Usuario sin términos
  - Usuario válido
- [ ] Exportar JSON

---

### Martes (3 horas)

#### Tarea 3.3: Sub-workflow onboarding-new-user (3h)
- [ ] Crear workflow: `[PROD] [Onboarding] - New User`
- [ ] Agregar Execute Workflow Trigger
- [ ] Agregar Postgres INSERT nuevo usuario
- [ ] Agregar Postgres SELECT mensajes (BIENVENIDA, etc.)
- [ ] Agregar Loop sobre mensajes
- [ ] Dentro del loop: Execute Workflow whatsapp-send
- [ ] Agregar Wait 2 segundos entre mensajes
- [ ] Agregar Execute Workflow: audit-log
- [ ] Testear con número real
- [ ] Exportar JSON

**Testing**:
1. Usar número de WhatsApp que NO esté en BD
2. Ejecutar workflow
3. Verificar que lleguen 4 mensajes en orden
4. Verificar registro en BD

---

### Miércoles (3 horas)

#### Tarea 3.4: Sub-workflow terms-accept (3h)
- [ ] Crear workflow: `[PROD] [Onboarding] - Terms Accept`
- [ ] Agregar Execute Workflow Trigger
- [ ] Agregar IF: ¿mensaje es texto?
- [ ] Agregar HTTP Request: OpenRouter (analizar aceptación)
- [ ] Agregar IF: ¿acepta términos?
- [ ] Si acepta:
  - Postgres UPDATE AceptoTerminos=true
  - SELECT mensaje CUANDO_ACEPTA
  - Execute Workflow whatsapp-send
- [ ] Si NO acepta:
  - SELECT mensaje RESPONDE_OTRA_COSA
  - Execute Workflow whatsapp-send
- [ ] Agregar Execute Workflow: audit-log
- [ ] Testear con:
  - "Sí acepto"
  - "Acepto los términos"
  - "No gracias"
  - "Hola"
- [ ] Exportar JSON

---

### Jueves (0 horas - Buffer)

**Día de buffer** para recuperar tareas pendientes de Semana 2 o 3.

---

### Viernes (2 horas)

#### Tarea 3.5: Testing flujo completo onboarding (1.5h)
- [ ] Eliminar usuario de prueba de BD
- [ ] Simular mensaje de usuario nuevo
- [ ] Ejecutar validate-user
- [ ] Verificar que llame a onboarding-new-user
- [ ] Responder "Sí acepto"
- [ ] Ejecutar terms-accept
- [ ] Verificar BD: AceptoTerminos = true

#### Tarea 3.6: Documentación (0.5h)
- [ ] Documentar flujo completo de onboarding
- [ ] Crear diagrama de flujo
- [ ] Commit a Git

**Checklist Semana 3**:
- [x] validate-user funcional
- [x] onboarding-new-user funcional
- [x] terms-accept funcional
- [x] Mensajes en BD configurados
- [x] Flujo completo testeado end-to-end
- [x] Documentado

---

## 📅 SEMANA 4: Workflow Principal (Orquestador)

### Objetivo de la Semana
Implementar el workflow principal que orquesta todos los sub-workflows.

### Lunes (2 horas)

#### Tarea 4.1: Diseño del flujo principal (1h)
- [ ] Revisar documentación de Evolution API webhook
- [ ] Diseñar flujo en papel/Excalidraw
- [ ] Identificar todos los puntos de decisión
- [ ] Listar todos los sub-workflows a llamar

#### Tarea 4.2: Crear estructura base (1h)
- [ ] Crear workflow: `[PROD] - NutriDiab Main Webhook`
- [ ] Agregar Webhook Trigger
- [ ] Configurar ruta: `/webhook/nutridiab-main`
- [ ] Agregar nodo Code: extraer datos de WhatsApp
- [ ] Testear recepción de webhook
- [ ] Exportar JSON (versión 0.1)

---

### Martes (2 horas)

#### Tarea 4.3: Implementar validación de usuario (2h)
- [ ] Agregar Execute Workflow: validate-user
- [ ] Agregar IF: ¿usuario válido?
- [ ] Rama FALSE:
  - Si necesita_onboarding: Execute onboarding-new-user
  - Si necesita_terminos: Execute terms-accept
  - Return respuesta apropiada
- [ ] Testear con:
  - Usuario nuevo
  - Usuario sin términos
  - Usuario válido
- [ ] Exportar JSON (versión 0.2)

---

### Miércoles (2 horas)

#### Tarea 4.4: Implementar Switch por tipo de mensaje (2h)
- [ ] Agregar nodo Switch con 3 casos:
  - Case 0: tipo = "texto"
  - Case 1: tipo = "imagen"
  - Case 2: tipo = "audio"
- [ ] Para texto:
  - Execute Workflow: process-text
- [ ] Para imagen:
  - Execute Workflow: process-image
- [ ] Para audio:
  - Execute Workflow: process-audio
- [ ] Testear cada rama
- [ ] Exportar JSON (versión 0.3)

---

### Jueves (1 hora)

#### Tarea 4.5: Implementar envío de respuesta y guardado (1h)
- [ ] Después del Switch, merge las salidas
- [ ] Agregar Execute Workflow: whatsapp-send
- [ ] Agregar Execute Workflow: save-consultation
- [ ] Agregar Execute Workflow: audit-log
- [ ] Agregar Respond to Webhook
- [ ] Testear flujo completo
- [ ] Exportar JSON (versión 1.0)

---

### Viernes (1 hora)

#### Tarea 4.6: Error handling (0.5h)
- [ ] Agregar Error Trigger
- [ ] Conectar a error-handler sub-workflow
- [ ] Testear provocando errores:
  - Sin saldo
  - API caída
  - Datos inválidos

#### Tarea 4.7: Optimización y documentación (0.5h)
- [ ] Revisar tiempos de ejecución
- [ ] Ajustar timeouts si es necesario
- [ ] Documentar workflow principal
- [ ] Commit final a Git

**Checklist Semana 4**:
- [x] Workflow principal funcional
- [x] Integración con todos los sub-workflows
- [x] Switch por tipo de mensaje
- [x] Error handling implementado
- [x] Flujo end-to-end funcional
- [x] Documentado

---

## 📅 SEMANA 5: Testing, Deploy y Optimización

### Objetivo de la Semana
Testear exhaustivamente, optimizar performance y desplegar a producción.

### Lunes (4 horas)

#### Tarea 5.1: Testing funcional exhaustivo (4h)
- [ ] **Escenario 1: Usuario nuevo - texto**
  - Enviar mensaje desde número nuevo
  - Verificar onboarding completo
  - Aceptar términos
  - Enviar consulta de texto
  - Verificar respuesta
  - Verificar registros en BD

- [ ] **Escenario 2: Usuario nuevo - imagen**
  - Repetir con imagen

- [ ] **Escenario 3: Usuario nuevo - audio**
  - Repetir con audio

- [ ] **Escenario 4: Usuario existente - múltiples consultas**
  - Usuario ya registrado
  - Enviar 5 consultas seguidas
  - Verificar todas las respuestas

- [ ] **Escenario 5: Usuario no acepta términos**
  - Responder "No" o texto ambiguo
  - Verificar que insista

- [ ] **Escenario 6: Error de API**
  - Desconectar OpenRouter temporalmente
  - Verificar manejo de error
  - Verificar mensaje al usuario

**Documentar resultados**:
```
Escenario 1: ✅ PASS / ❌ FAIL - Notas: _____
Escenario 2: ✅ PASS / ❌ FAIL - Notas: _____
...
```

---

### Martes (4 horas)

#### Tarea 5.2: Testing de performance (2h)
- [ ] Medir tiempos de respuesta:
```
Texto:
- Usuario nuevo: ___ segundos
- Usuario existente: ___ segundos

Imagen:
- Usuario nuevo: ___ segundos
- Usuario existente: ___ segundos

Audio:
- Usuario nuevo: ___ segundos
- Usuario existente: ___ segundos
```

- [ ] Identificar cuellos de botella
- [ ] Optimizar queries SQL si es necesario
- [ ] Optimizar nodos Code si es posible

#### Tarea 5.3: Testing de carga (2h)
- [ ] Simular 10 consultas concurrentes
- [ ] Verificar que todas se procesen
- [ ] Verificar tiempos de respuesta
- [ ] Verificar consumo de recursos

**Herramienta sugerida**: Postman Collection con requests paralelos

---

### Miércoles (4 horas)

#### Tarea 5.4: Análisis de costos reales (2h)
- [ ] Ejecutar 100 consultas de prueba:
  - 70 texto
  - 25 imagen
  - 5 audio
- [ ] Calcular costos totales
- [ ] Calcular costo promedio por tipo
- [ ] Proyectar costos mensuales:
```
100 usuarios x 30 consultas/mes = 3000 consultas
- 2100 texto x $0.002 = $4.20
- 750 imagen x $0.02 = $15.00
- 150 audio x $0.01 = $1.50
TOTAL: $20.70/mes
```

- [ ] Evaluar si es sostenible
- [ ] Ajustar modelos de IA si es necesario (usar GPT-3.5 en vez de 4?)

#### Tarea 5.5: Documentación final (2h)
- [ ] Crear README principal con:
  - Arquitectura completa
  - Lista de workflows
  - Instrucciones de setup
  - Troubleshooting
- [ ] Actualizar todos los docs
- [ ] Crear diagramas finales
- [ ] Commit a Git

---

### Jueves (4 horas)

#### Tarea 5.6: Preparación para producción (4h)
- [ ] Revisar todas las credenciales
- [ ] Cambiar URLs de desarrollo a producción
- [ ] Configurar variables de entorno
- [ ] Activar todos los workflows
- [ ] Configurar webhook en Evolution API
- [ ] Testear con número de producción
- [ ] Configurar monitoreo:
  - Alertas de error
  - Alertas de costos
  - Dashboard de métricas

---

### Viernes (4 horas)

#### Tarea 5.7: Deploy a producción (2h)
- [ ] Backup de BD
- [ ] Exportar todos los workflows
- [ ] Importar en n8n de producción
- [ ] Verificar todas las conexiones
- [ ] Activar workflows uno por uno
- [ ] Testear flujo completo en producción
- [ ] Monitorear primeras ejecuciones

#### Tarea 5.8: Capacitación (1h)
- [ ] Crear video tutorial de uso
- [ ] Documentar casos de uso comunes
- [ ] Preparar FAQ
- [ ] Compartir con equipo

#### Tarea 5.9: Retrospectiva y cierre (1h)
- [ ] Revisar métricas finales:
```
✅ Workflows implementados: __/25
✅ Tests pasados: __/50
✅ Performance < 5s texto: ✅/❌
✅ Performance < 10s imagen: ✅/❌
✅ Performance < 15s audio: ✅/❌
✅ Costos < $0.015/consulta: ✅/❌
✅ Documentación completa: ✅/❌
```

- [ ] Identificar aprendizajes
- [ ] Documentar mejoras futuras
- [ ] Celebrar 🎉

**Checklist Semana 5**:
- [x] Testing funcional completo
- [x] Testing de performance
- [x] Testing de carga
- [x] Análisis de costos
- [x] Documentación final
- [x] Deploy a producción
- [x] Sistema funcional en producción
- [x] Equipo capacitado

---

## 📊 Métricas de Éxito del Proyecto

### KPIs Técnicos

| Métrica | Target | Real | Status |
|---------|--------|------|--------|
| Workflows creados | 25 | __ | 🔲 |
| Tests pasados | 50 | __ | 🔲 |
| Tiempo respuesta texto | < 5s | __s | 🔲 |
| Tiempo respuesta imagen | < 10s | __s | 🔲 |
| Tiempo respuesta audio | < 15s | __s | 🔲 |
| Tasa de éxito | > 95% | __% | 🔲 |
| Cobertura de tests | > 80% | __% | 🔲 |

### KPIs de Calidad

| Aspecto | Target | Status |
|---------|--------|--------|
| Código documentado | 100% | 🔲 |
| Workflows exportados | 100% | 🔲 |
| Error handling | 100% | 🔲 |
| Logging/audit | 100% | 🔲 |
| Performance optimizado | ✅ | 🔲 |

---

## 🎯 Checklist Final del Proyecto

### Funcionalidad
- [ ] Usuario nuevo puede registrarse
- [ ] Usuario puede aceptar términos
- [ ] Usuario puede enviar consulta de texto
- [ ] Usuario puede enviar consulta de imagen
- [ ] Usuario puede enviar consulta de audio
- [ ] Usuario recibe respuesta nutricional
- [ ] Consultas se guardan en BD
- [ ] Costos se calculan correctamente
- [ ] Errores se manejan gracefully

### Calidad
- [ ] Todos los workflows testeados
- [ ] Todos los workflows documentados
- [ ] Todos los workflows exportados a JSON
- [ ] Error handling en todos los flujos críticos
- [ ] Audit log en todos los eventos importantes
- [ ] Performance dentro de targets

### Operacional
- [ ] Credenciales configuradas
- [ ] Variables de entorno configuradas
- [ ] Monitoreo configurado
- [ ] Alertas configuradas
- [ ] Backup configurado
- [ ] Equipo capacitado

### Documentación
- [ ] README principal
- [ ] Arquitectura documentada
- [ ] Cada sub-workflow documentado
- [ ] Troubleshooting guide
- [ ] FAQ creada
- [ ] Video tutorial

---

## 📚 Recursos Útiles

### Links Importantes
- [n8n Docs - Sub-workflows](https://docs.n8n.io/flow-logic/subworkflows/)
- [OpenRouter Docs](https://openrouter.ai/docs)
- [OpenAI Whisper API](https://platform.openai.com/docs/guides/speech-to-text)
- [Evolution API Docs](https://doc.evolution-api.com/)

### Templates
- Workflow de testing
- Workflow de monitoring
- Postman collection para testing

### Contactos
- Support n8n: community.n8n.io
- Support OpenRouter: support@openrouter.ai

---

## 🎉 Conclusión

Al completar este plan de 5 semanas, tendrás:

✅ **Sistema completo funcional**
- 25 workflows modulares
- Arquitectura profesional y escalable
- Flujo end-to-end desde WhatsApp hasta respuesta

✅ **Alta calidad**
- Testing exhaustivo
- Documentación completa
- Error handling robusto

✅ **Preparado para producción**
- Deploy exitoso
- Monitoreo configurado
- Equipo capacitado

✅ **Escalable**
- Agregar features es fácil
- Modificar lógica es localizado
- Mantener es simple

---

**Última actualización**: 2025-11-26
**Versión**: 1.0
**Status del proyecto**: 🔲 No iniciado / 🟡 En progreso / ✅ Completado

