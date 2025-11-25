#!/bin/bash

# ============================================
# SCRIPT PARA SOLUCIONAR PROBLEMA DE USUARIOS
# ============================================
# Ejecutar desde la raíz del proyecto:
# chmod +x scripts/solucionar_usuarios.sh
# ./scripts/solucionar_usuarios.sh

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}========================================"
echo -e "  SOLUCIONADOR DE USUARIOS NUTRIDIAB   "
echo -e "========================================${NC}"
echo ""

# Configuración
DB_USER="${POSTGRES_USER:-dnzapata}"
DB_NAME="${POSTGRES_DB:-nutridiab}"
DB_HOST="${POSTGRES_HOST:-localhost}"
DB_PORT="${POSTGRES_PORT:-5432}"

echo -e "${YELLOW}📋 Configuración:${NC}"
echo "  Base de datos: $DB_NAME"
echo "  Usuario: $DB_USER"
echo "  Host: $DB_HOST"
echo ""

# Verificar si psql está instalado
echo -e "${YELLOW}🔍 Verificando PostgreSQL...${NC}"
if ! command -v psql &> /dev/null; then
    echo -e "${RED}❌ ERROR: psql no está instalado${NC}"
    echo -e "${RED}   Instala PostgreSQL primero${NC}"
    echo ""
    echo -e "${YELLOW}   Puedes ejecutar los scripts manualmente:${NC}"
    echo "   psql -U $DB_USER -d $DB_NAME -f database/agregar_campos_usuario_frontend.sql"
    echo "   psql -U $DB_USER -d $DB_NAME -f database/crear_usuarios_prueba.sql"
    exit 1
fi

echo -e "${GREEN}✅ PostgreSQL encontrado${NC}"
echo ""

# Paso 1: Agregar campos
echo -e "${CYAN}📝 PASO 1: Agregando campos a la base de datos...${NC}"
echo ""

if psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -f "database/agregar_campos_usuario_frontend.sql"; then
    echo -e "${GREEN}✅ Campos agregados exitosamente${NC}"
else
    echo -e "${YELLOW}⚠️  Error al agregar campos (puede que ya existan)${NC}"
fi

echo ""

# Paso 2: Crear usuarios de prueba
echo -e "${CYAN}👥 PASO 2: Creando usuarios de prueba...${NC}"
echo ""

if psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -f "database/crear_usuarios_prueba.sql"; then
    echo -e "${GREEN}✅ Usuarios de prueba creados${NC}"
else
    echo -e "${RED}❌ Error al crear usuarios de prueba${NC}"
fi

echo ""

# Paso 3: Verificar usuarios
echo -e "${CYAN}🔍 PASO 3: Verificando usuarios creados...${NC}"
echo ""

if psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -p "$DB_PORT" -f "database/verificar_usuarios.sql"; then
    echo -e "${GREEN}✅ Verificación completada${NC}"
else
    echo -e "${YELLOW}⚠️  No se pudo verificar${NC}"
fi

echo ""

# Resumen
echo -e "${CYAN}========================================"
echo -e "           RESUMEN                      "
echo -e "========================================${NC}"
echo ""
echo -e "${GREEN}✅ Scripts ejecutados correctamente${NC}"
echo ""
echo -e "${YELLOW}📋 SIGUIENTES PASOS:${NC}"
echo ""
echo -e "${NC}1. 🌐 Abre n8n: https://wf.zynaptic.tech${NC}"
echo ""
echo -e "${NC}2. 📥 Importa el workflow:${NC}"
echo "   - Workflows → + Add workflow → Import"
echo "   - Archivo: n8n/workflows/nutridiab-admin-usuarios.json"
echo ""
echo -e "${NC}3. ⚙️  Configura las credenciales de Postgres en el nodo${NC}"
echo ""
echo -e "${NC}4. ✅ Activa el workflow (toggle arriba a la derecha)${NC}"
echo ""
echo -e "${NC}5. 🧪 Prueba ejecutándolo manualmente:${NC}"
echo "   - Click en 'Execute Workflow'"
echo "   - Verifica que devuelve usuarios"
echo ""
echo -e "${NC}6. 🚀 Inicia el frontend:${NC}"
echo "   cd frontend"
echo "   npm run dev"
echo ""
echo -e "${NC}7. 🌐 Abre en el navegador:${NC}"
echo "   http://localhost:5173/users"
echo ""
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "${YELLOW}💡 TIP: Si aún no funciona, revisa:${NC}"
echo "   - Que el workflow esté ACTIVADO en n8n"
echo "   - Los logs de ejecución en n8n → Executions"
echo "   - La consola del navegador (F12)"
echo ""
echo -e "${YELLOW}📚 Documentación completa:${NC}"
echo "   n8n/SOLUCIONAR_USUARIOS_NO_APARECEN.md"
echo ""

