# ============================================
# SCRIPT PARA SOLUCIONAR PROBLEMA DE USUARIOS
# ============================================
# Ejecutar desde la raíz del proyecto:
# .\scripts\solucionar_usuarios.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  SOLUCIONADOR DE USUARIOS NUTRIDIAB   " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Configuración
$DB_USER = "dnzapata"
$DB_NAME = "nutridiab"
$DB_HOST = "localhost"
$DB_PORT = "5432"

Write-Host "📋 Configuración:" -ForegroundColor Yellow
Write-Host "  Base de datos: $DB_NAME"
Write-Host "  Usuario: $DB_USER"
Write-Host "  Host: $DB_HOST"
Write-Host ""

# Verificar si psql está instalado
Write-Host "🔍 Verificando PostgreSQL..." -ForegroundColor Yellow
$psqlExists = Get-Command psql -ErrorAction SilentlyContinue
if (-not $psqlExists) {
    Write-Host "❌ ERROR: psql no está instalado o no está en el PATH" -ForegroundColor Red
    Write-Host "   Instala PostgreSQL o configura el PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Puedes ejecutar los scripts manualmente:" -ForegroundColor Yellow
    Write-Host "   1. database/agregar_campos_usuario_frontend.sql" -ForegroundColor White
    Write-Host "   2. database/crear_usuarios_prueba.sql" -ForegroundColor White
    exit 1
}

Write-Host "✅ PostgreSQL encontrado" -ForegroundColor Green
Write-Host ""

# Paso 1: Agregar campos
Write-Host "📝 PASO 1: Agregando campos a la base de datos..." -ForegroundColor Cyan
Write-Host ""
$env:PGPASSWORD = Read-Host "Ingresa la contraseña de la base de datos" -AsSecureString | ConvertFrom-SecureString -AsPlainText

try {
    psql -U $DB_USER -d $DB_NAME -h $DB_HOST -p $DB_PORT -f "database/agregar_campos_usuario_frontend.sql"
    Write-Host "✅ Campos agregados exitosamente" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Error al agregar campos (puede que ya existan)" -ForegroundColor Yellow
}

Write-Host ""

# Paso 2: Crear usuarios de prueba
Write-Host "👥 PASO 2: Creando usuarios de prueba..." -ForegroundColor Cyan
Write-Host ""

try {
    psql -U $DB_USER -d $DB_NAME -h $DB_HOST -p $DB_PORT -f "database/crear_usuarios_prueba.sql"
    Write-Host "✅ Usuarios de prueba creados" -ForegroundColor Green
} catch {
    Write-Host "❌ Error al crear usuarios de prueba" -ForegroundColor Red
}

Write-Host ""

# Paso 3: Verificar usuarios
Write-Host "🔍 PASO 3: Verificando usuarios creados..." -ForegroundColor Cyan
Write-Host ""

try {
    psql -U $DB_USER -d $DB_NAME -h $DB_HOST -p $DB_PORT -f "database/verificar_usuarios.sql"
    Write-Host "✅ Verificación completada" -ForegroundColor Green
} catch {
    Write-Host "⚠️  No se pudo verificar" -ForegroundColor Yellow
}

Write-Host ""

# Resumen
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "           RESUMEN                      " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Scripts ejecutados correctamente" -ForegroundColor Green
Write-Host ""
Write-Host "📋 SIGUIENTES PASOS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. 🌐 Abre n8n: https://wf.zynaptic.tech" -ForegroundColor White
Write-Host ""
Write-Host "2. 📥 Importa el workflow:" -ForegroundColor White
Write-Host "   - Workflows → + Add workflow → Import" -ForegroundColor Gray
Write-Host "   - Archivo: n8n/workflows/nutridiab-admin-usuarios.json" -ForegroundColor Gray
Write-Host ""
Write-Host "3. ⚙️  Configura las credenciales de Postgres en el nodo" -ForegroundColor White
Write-Host ""
Write-Host "4. ✅ Activa el workflow (toggle arriba a la derecha)" -ForegroundColor White
Write-Host ""
Write-Host "5. 🧪 Prueba ejecutándolo manualmente:" -ForegroundColor White
Write-Host "   - Click en 'Execute Workflow'" -ForegroundColor Gray
Write-Host "   - Verifica que devuelve usuarios" -ForegroundColor Gray
Write-Host ""
Write-Host "6. 🚀 Inicia el frontend:" -ForegroundColor White
Write-Host "   cd frontend" -ForegroundColor Gray
Write-Host "   npm run dev" -ForegroundColor Gray
Write-Host ""
Write-Host "7. 🌐 Abre en el navegador:" -ForegroundColor White
Write-Host "   http://localhost:5173/users" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 TIP: Si aún no funciona, revisa:" -ForegroundColor Yellow
Write-Host "   - Que el workflow esté ACTIVADO en n8n" -ForegroundColor Gray
Write-Host "   - Los logs de ejecución en n8n → Executions" -ForegroundColor Gray
Write-Host "   - La consola del navegador (F12)" -ForegroundColor Gray
Write-Host ""
Write-Host "📚 Documentación completa:" -ForegroundColor Yellow
Write-Host "   n8n/SOLUCIONAR_USUARIOS_NO_APARECEN.md" -ForegroundColor Gray
Write-Host ""

# Limpiar variable de entorno
$env:PGPASSWORD = $null

