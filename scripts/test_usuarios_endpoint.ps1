# Script para probar el endpoint de usuarios
Write-Host "Probando endpoint de usuarios..." -ForegroundColor Cyan
Write-Host ""

$n8nUrl = "https://wf.zynaptic.tech"
$endpoint = "/webhook/nutridiab/admin/usuarios"
$fullUrl = "$n8nUrl$endpoint"

Write-Host "URL: $fullUrl" -ForegroundColor Yellow
Write-Host ""

try {
    Write-Host "Haciendo peticion GET..." -ForegroundColor Gray
    $response = Invoke-WebRequest -Uri $fullUrl -Method GET -UseBasicParsing
    
    Write-Host "Status Code: $($response.StatusCode)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response Headers:" -ForegroundColor Cyan
    $response.Headers | Format-Table
    Write-Host ""
    Write-Host "Response Body:" -ForegroundColor Cyan
    $jsonContent = $response.Content | ConvertFrom-Json
    $jsonContent | ConvertTo-Json -Depth 5
    Write-Host ""
    
    if ($jsonContent) {
        if ($jsonContent -is [array]) {
            Write-Host "Respuesta es un array con $($jsonContent.Count) elementos" -ForegroundColor Green
        } elseif ($jsonContent.usuarios) {
            Write-Host "Respuesta contiene campo usuarios con $($jsonContent.usuarios.Count) elementos" -ForegroundColor Green
        } elseif ($jsonContent.data) {
            Write-Host "Respuesta contiene campo data con $($jsonContent.data.Count) elementos" -ForegroundColor Green
        } else {
            Write-Host "Estructura de respuesta no esperada" -ForegroundColor Yellow
            Write-Host "Claves disponibles: $($jsonContent.PSObject.Properties.Name -join ', ')" -ForegroundColor Yellow
        }
    }
} catch {
    Write-Host "Error al hacer la peticion:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    
    if ($_.Exception.Response) {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "Status Code: $statusCode" -ForegroundColor Red
        
        if ($statusCode -eq 404) {
            Write-Host ""
            Write-Host "Posibles causas:" -ForegroundColor Yellow
            Write-Host "  1. El workflow no esta importado en n8n" -ForegroundColor Yellow
            Write-Host "  2. El workflow no esta activo" -ForegroundColor Yellow
            Write-Host "  3. La ruta del webhook es incorrecta" -ForegroundColor Yellow
        } elseif ($statusCode -eq 500) {
            Write-Host ""
            Write-Host "Posibles causas:" -ForegroundColor Yellow
            Write-Host "  1. Error en la base de datos (credenciales, conexion)" -ForegroundColor Yellow
            Write-Host "  2. Error en el codigo del workflow" -ForegroundColor Yellow
            Write-Host "  3. Tabla o campos no existen en la base de datos" -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "Pasos siguientes:" -ForegroundColor Cyan
Write-Host "  1. Verifica que el workflow este importado en n8n" -ForegroundColor White
Write-Host "  2. Verifica que el workflow este ACTIVO (toggle verde)" -ForegroundColor White
Write-Host "  3. Verifica las credenciales de PostgreSQL en el workflow" -ForegroundColor White
Write-Host "  4. Revisa los logs de n8n si hay errores" -ForegroundColor White

