# Script de configuración inicial para Nutridiab (PowerShell)
# Para Windows - Aplicación de control nutricional para diabéticos

Write-Host "🚀 Configurando Nutridiab..." -ForegroundColor Cyan
Write-Host ""

# Verificar Docker
Write-Host "📋 Verificando requisitos previos..." -ForegroundColor Yellow

try {
    docker --version | Out-Null
    Write-Host "✓ Docker instalado" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker no está instalado" -ForegroundColor Red
    Write-Host "   Descarga Docker Desktop: https://www.docker.com/products/docker-desktop"
    exit 1
}

# Verificar Node
try {
    $nodeVersion = node --version
    Write-Host "✓ Node.js instalado ($nodeVersion)" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js no está instalado" -ForegroundColor Red
    Write-Host "   Descarga Node.js: https://nodejs.org/"
    exit 1
}
Write-Host ""

# Copiar .env si no existe
if (-not (Test-Path .env)) {
    Write-Host "📝 Creando archivo .env..." -ForegroundColor Yellow
    Copy-Item .env.example .env
    Write-Host "✓ Archivo .env creado" -ForegroundColor Green
} else {
    Write-Host "ℹ  Archivo .env ya existe" -ForegroundColor Blue
}
Write-Host ""

# Iniciar n8n
Write-Host "🐳 Iniciando n8n con Docker..." -ForegroundColor Yellow
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ n8n iniciado correctamente" -ForegroundColor Green
    Write-Host "   Accede a n8n en: https://wf.zynaptic.tech" -ForegroundColor Blue
} else {
    Write-Host "❌ Error al iniciar n8n" -ForegroundColor Red
    exit 1
}
Write-Host ""

# Instalar dependencias del frontend
Write-Host "📦 Instalando dependencias del frontend..." -ForegroundColor Yellow
Set-Location frontend
npm install

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Dependencias instaladas" -ForegroundColor Green
} else {
    Write-Host "❌ Error al instalar dependencias" -ForegroundColor Red
    exit 1
}
Set-Location ..
Write-Host ""

# Resumen
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "🎉 ¡Configuración completada!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""
Write-Host "📍 Próximos pasos:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Configura n8n (primera vez):"
Write-Host "   https://wf.zynaptic.tech" -ForegroundColor Blue
Write-Host ""
Write-Host "2. Importa los workflows:"
Write-Host "   - Abre n8n"
Write-Host "   - Workflows > Import from File"
Write-Host "   - Selecciona archivos de n8n/workflows/"
Write-Host ""
Write-Host "3. Inicia el frontend:"
Write-Host "   cd frontend" -ForegroundColor Blue
Write-Host "   npm run dev" -ForegroundColor Blue
Write-Host ""
Write-Host "4. Abre la aplicación:"
Write-Host "   http://localhost:5173" -ForegroundColor Blue
Write-Host ""
Write-Host "📚 Documentación adicional:"
Write-Host "   - README.md - Información general"
Write-Host "   - QUICK_START.md - Guía rápida"
Write-Host "   - WORKFLOWS.md - Crear workflows"
Write-Host ""

