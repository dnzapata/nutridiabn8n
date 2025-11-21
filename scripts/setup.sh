#!/bin/bash

# Script de configuración inicial para Nutridiab
# Este script facilita la configuración del proyecto
# Aplicación de control nutricional para diabéticos

echo "🚀 Configurando Nutridiab..."
echo ""

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Verificar Docker
echo "📋 Verificando requisitos previos..."
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker no está instalado${NC}"
    echo "   Descarga Docker Desktop: https://www.docker.com/products/docker-desktop"
    exit 1
fi
echo -e "${GREEN}✓ Docker instalado${NC}"

# Verificar Node
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js no está instalado${NC}"
    echo "   Descarga Node.js: https://nodejs.org/"
    exit 1
fi
echo -e "${GREEN}✓ Node.js instalado ($(node --version))${NC}"
echo ""

# Copiar .env si no existe
if [ ! -f .env ]; then
    echo "📝 Creando archivo .env..."
    cp .env.example .env
    echo -e "${GREEN}✓ Archivo .env creado${NC}"
else
    echo -e "${BLUE}ℹ  Archivo .env ya existe${NC}"
fi
echo ""

# Iniciar n8n
echo "🐳 Iniciando n8n con Docker..."
docker-compose up -d

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ n8n iniciado correctamente${NC}"
    echo -e "${BLUE}   Accede a n8n en: https://wf.zynaptic.tech${NC}"
else
    echo -e "${RED}❌ Error al iniciar n8n${NC}"
    exit 1
fi
echo ""

# Instalar dependencias del frontend
echo "📦 Instalando dependencias del frontend..."
cd frontend
npm install

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Dependencias instaladas${NC}"
else
    echo -e "${RED}❌ Error al instalar dependencias${NC}"
    exit 1
fi
cd ..
echo ""

# Resumen
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}🎉 ¡Configuración completada!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 Próximos pasos:"
echo ""
echo "1. Configura n8n (primera vez):"
echo -e "   ${BLUE}https://wf.zynaptic.tech${NC}"
echo ""
echo "2. Importa los workflows:"
echo "   - Abre n8n"
echo "   - Workflows > Import from File"
echo "   - Selecciona archivos de n8n/workflows/"
echo ""
echo "3. Inicia el frontend:"
echo -e "   ${BLUE}cd frontend && npm run dev${NC}"
echo ""
echo "4. Abre la aplicación:"
echo -e "   ${BLUE}http://localhost:5173${NC}"
echo ""
echo "📚 Documentación adicional:"
echo "   - README.md - Información general"
echo "   - QUICK_START.md - Guía rápida"
echo "   - WORKFLOWS.md - Crear workflows"
echo ""

