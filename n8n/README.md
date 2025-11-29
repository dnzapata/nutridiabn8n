# n8n Backend - NutriDiab

Esta carpeta contiene la configuración y workflows de n8n que actúan como backend de la aplicación NutriDiab.

## 🚨 IMPORTANTE: Análisis de Modularización Disponible

**Se ha realizado un análisis exhaustivo de los workflows actuales y se propone una arquitectura modular siguiendo las mejores prácticas de n8n.**

### 📚 Documentación Completa de Modularización

Lee **[README_MODULARIZACION.md](./README_MODULARIZACION.md)** para acceder a:

1. **RESUMEN_EJECUTIVO_MODULARIZACION.md** - Para managers y stakeholders
2. **ANALISIS_MODULARIZACION_NUTRIDIAB.md** - Análisis técnico detallado
3. **ARQUITECTURA_MODULAR_PROPUESTA.md** - Diagramas y contratos de datos
4. **GUIA_IMPLEMENTACION_SUBWORKFLOWS.md** - Código y ejemplos prácticos
5. **PLAN_ACCION_5_SEMANAS.md** - Plan día a día de implementación

### ⚡ Quick Start de Modularización

```bash
# 1. Lee el resumen ejecutivo
cat n8n/RESUMEN_EJECUTIVO_MODULARIZACION.md

# 2. Si apruebas, sigue el plan de 5 semanas
cat n8n/PLAN_ACCION_5_SEMANAS.md

# 3. Implementa usando la guía
cat n8n/GUIA_IMPLEMENTACION_SUBWORKFLOWS.md
```

### 🎯 Estado del Proyecto

- ✅ **13 workflows existentes** (auth, admin) - Bien modularizados
- ❌ **Workflow principal vacío** - Necesita implementación
- ❌ **Lógica de IA faltante** - Necesita implementación
- 🎯 **12 nuevos sub-workflows propuestos** - Plan completo disponible

---

## 📁 Estructura

```
n8n/
├── data/                                      # Datos persistentes de n8n
├── workflows/                                 # Workflows existentes (13)
├── README.md                                  # Este archivo
├── README_MODULARIZACION.md                   # 📚 ÍNDICE de documentación
├── RESUMEN_EJECUTIVO_MODULARIZACION.md        # Para managers
├── ANALISIS_MODULARIZACION_NUTRIDIAB.md       # Análisis técnico
├── ARQUITECTURA_MODULAR_PROPUESTA.md          # Diagramas y diseño
├── GUIA_IMPLEMENTACION_SUBWORKFLOWS.md        # Código práctico
└── PLAN_ACCION_5_SEMANAS.md                   # Plan de implementación
```

## 🔧 Workflows Existentes (13)

### Autenticación (7 workflows) ✅
| Workflow | Endpoint | Descripción | Nodos |
|----------|----------|-------------|-------|
| `nutridiab-auth-login.json` | `POST /nutridiab/auth/login` | Login de usuarios | 6 |
| `nutridiab-auth-login-v2.json` | `POST /nutridiab/auth/login-v2` | Login v2 | 5 |
| `nutridiab-auth-logout.json` | `POST /nutridiab/auth/logout` | Cerrar sesión | 3 |
| `nutridiab-auth-validate.json` | `POST /nutridiab/auth/validate` | Validar sesión | 5 |
| `nutridiab-auth-check-admin.json` | `POST /nutridiab/auth/check-admin` | Verificar rol admin | 3 |
| `validate-token-workflow.json` | `POST /nutridiab/validate-and-save` | Validar token y actualizar datos | 9 |
| `generate-token-workflow.json` | `POST /nutridiab/generate-token` | Generar tokens | 4 |

### Administración (4 workflows) ✅
| Workflow | Endpoint | Descripción | Nodos |
|----------|----------|-------------|-------|
| `nutridiab-admin-usuarios.json` | `GET /nutridiab/admin/usuarios` | Listar usuarios con stats | 4 |
| `nutridiab-admin-consultas.json` | `GET /nutridiab/admin/consultas` | Listar consultas recientes | 4 |
| `nutridiab-admin-stats.json` | `GET /nutridiab/admin/stats` | Estadísticas generales | 3 |
| `nutridiab-admin-actualizar-usuario.json` | `PUT /nutridiab/admin/usuarios/:id` | Actualizar usuario | 5 |

### Utilidades (2 workflows) ✅
| Workflow | Endpoint | Descripción | Nodos |
|----------|----------|-------------|-------|
| `health-check.json` | `GET /webhook/health` | Health check del sistema | 3 |
| `nutridiab.json` | - | **Workflow principal (VACÍO)** | 0 ❌ |

### 🆕 Workflows a Crear (12 propuestos)

Ver [PLAN_ACCION_5_SEMANAS.md](./PLAN_ACCION_5_SEMANAS.md) para detalles completos.

#### Fase 1: Servicios Comunes (5 sub-workflows)
- `[PROD] [Service] - WhatsApp Send`
- `[PROD] [Service] - Save Consultation`
- `[PROD] [Service] - Audit Log`
- `[PROD] [Service] - Calculate Cost`
- `[PROD] [Service] - Error Handler`

#### Fase 2: Procesamiento IA (3 sub-workflows)
- `[PROD] [IA] - Process Text`
- `[PROD] [IA] - Process Image`
- `[PROD] [IA] - Process Audio`

#### Fase 3: Onboarding (3 sub-workflows)
- `[PROD] [Service] - Validate User`
- `[PROD] [Onboarding] - New User`
- `[PROD] [Onboarding] - Terms Accept`

#### Fase 4: Orquestador (1 workflow principal)
- `[PROD] - NutriDiab Main Webhook`

## 📝 Cómo Importar Workflows

1. Inicia n8n: `docker-compose up -d`
2. Accede a https://wf.zynaptic.tech
3. Ve a **Workflows** → **Import from File**
4. Selecciona los archivos JSON de la carpeta `workflows/`

## 🎯 Crear un Nuevo Workflow

1. En n8n, crea un nuevo workflow
2. Agrega un nodo **Webhook**
3. Configura el método HTTP (GET, POST, etc.)
4. Define la ruta del webhook
5. Agrega la lógica de negocio con otros nodos
6. Responde con un nodo **Respond to Webhook**
7. Activa el workflow

## 💡 Ejemplos de Nodos Útiles

- **HTTP Request**: Llamar APIs externas
- **Code**: JavaScript/Python personalizado
- **Function**: Transformar datos
- **IF**: Lógica condicional
- **Switch**: Múltiples condiciones
- **Set**: Establecer variables
- **Database nodes**: MySQL, PostgreSQL, MongoDB
- **Error Trigger**: Manejo de errores

## 🔐 Seguridad

Para producción, considera:

1. Activar autenticación básica en n8n
2. Usar HTTPS
3. Implementar rate limiting
4. Validar entrada de usuarios
5. Usar variables de entorno para secretos

## 📊 Monitoreo

Accede a las ejecuciones en:
- https://wf.zynaptic.tech/executions

Aquí puedes ver:
- Historial de ejecuciones
- Errores y logs
- Tiempo de ejecución
- Datos de entrada/salida

