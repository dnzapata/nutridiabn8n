# ============================================
# TEST API DE USUARIOS
# ============================================
# Script para probar el endpoint de usuarios
# Ejecutar: .\scripts\test_usuarios_api.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   TEST API DE USUARIOS NUTRIDIAB       " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$API_URL = "https://wf.zynaptic.tech/webhook/nutridiab/admin/usuarios"

Write-Host "🌐 URL del endpoint:" -ForegroundColor Yellow
Write-Host "   $API_URL" -ForegroundColor White
Write-Host ""

Write-Host "📡 Haciendo petición GET..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri $API_URL -Method Get -ContentType "application/json"
    
    Write-Host "✅ Petición exitosa!" -ForegroundColor Green
    Write-Host ""
    
    # Analizar respuesta
    Write-Host "📊 Análisis de la respuesta:" -ForegroundColor Cyan
    Write-Host ""
    
    if ($response -is [Array]) {
        Write-Host "✅ La respuesta es un array" -ForegroundColor Green
        Write-Host "   Cantidad de usuarios: $($response.Count)" -ForegroundColor White
        Write-Host ""
        
        if ($response.Count -gt 0) {
            Write-Host "👤 Primer usuario:" -ForegroundColor Yellow
            $firstUser = $response[0]
            
            Write-Host "   ID: $($firstUser.id)" -ForegroundColor White
            Write-Host "   Nombre: $($firstUser.nombre)" -ForegroundColor White
            Write-Host "   Apellido: $($firstUser.apellido)" -ForegroundColor White
            Write-Host "   Email: $($firstUser.email)" -ForegroundColor White
            Write-Host "   Status: $($firstUser.status)" -ForegroundColor White
            Write-Host "   Role: $($firstUser.role)" -ForegroundColor White
            Write-Host ""
            
            Write-Host "📋 Estructura completa del primer usuario:" -ForegroundColor Cyan
            $firstUser | ConvertTo-Json -Depth 10 | Write-Host
        } else {
            Write-Host "⚠️  El array está vacío (no hay usuarios)" -ForegroundColor Yellow
        }
    } elseif ($response -is [PSCustomObject]) {
        Write-Host "📦 La respuesta es un objeto" -ForegroundColor Yellow
        Write-Host "   Propiedades: $($response.PSObject.Properties.Name -join ', ')" -ForegroundColor White
        Write-Host ""
        Write-Host "📋 Respuesta completa:" -ForegroundColor Cyan
        $response | ConvertTo-Json -Depth 10 | Write-Host
    } else {
        Write-Host "❓ Tipo de respuesta desconocido: $($response.GetType().Name)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "📋 Respuesta completa:" -ForegroundColor Cyan
        $response | ConvertTo-Json -Depth 10 | Write-Host
    }
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
} catch {
    Write-Host "❌ Error al hacer la petición" -ForegroundColor Red
    Write-Host ""
    Write-Host "Detalles del error:" -ForegroundColor Yellow
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    
    if ($_.Exception.Response) {
        Write-Host "Status Code: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Yellow
        Write-Host "Status Description: $($_.Exception.Response.StatusDescription)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "📋 Posibles causas:" -ForegroundColor Cyan
    Write-Host "  1. El workflow no está activado en n8n" -ForegroundColor White
    Write-Host "  2. La URL del endpoint es incorrecta" -ForegroundColor White
    Write-Host "  3. El workflow tiene errores de configuración" -ForegroundColor White
    Write-Host "  4. Problemas de conectividad con n8n" -ForegroundColor White
    Write-Host ""
    Write-Host "🔍 Verifica en n8n:" -ForegroundColor Yellow
    Write-Host "  1. Abre https://wf.zynaptic.tech" -ForegroundColor White
    Write-Host "  2. Ve a Workflows → Nutridiab - Admin Usuarios" -ForegroundColor White
    Write-Host "  3. Asegúrate de que esté ACTIVADO" -ForegroundColor White
    Write-Host "  4. Ejecuta manualmente el workflow" -ForegroundColor White
    Write-Host "  5. Revisa los logs de ejecución" -ForegroundColor White
    Write-Host ""
}


