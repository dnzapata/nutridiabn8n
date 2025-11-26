# Script simple para verificar que el campo aceptadoel este en el endpoint
# Ejecutar: powershell -ExecutionPolicy Bypass -File scripts\verificar_aceptoterminos_simple.ps1

$endpoint = "https://wf.zynaptic.tech/webhook/nutridiab/admin/usuarios"

Write-Host "[*] Consultando endpoint..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri $endpoint -Method Get
    
    if ($response -and $response.Count -gt 0) {
        $usuario = $response[0]
        
        Write-Host "`n[OK] Usuario de ejemplo:" -ForegroundColor Green
        Write-Host "  Nombre: $($usuario.nombre) $($usuario.apellido)"
        Write-Host ""
        
        # Verificar campo acepto_terminos
        if ($null -ne $usuario.acepto_terminos) {
            Write-Host "  [OK] acepto_terminos: $($usuario.acepto_terminos)" -ForegroundColor Green
        } else {
            Write-Host "  [ERROR] acepto_terminos: NO EXISTE" -ForegroundColor Red
        }
        
        # Verificar campo aceptadoel
        if ($null -ne $usuario.aceptadoel) {
            Write-Host "  [OK] aceptadoel: $($usuario.aceptadoel)" -ForegroundColor Green
        } else {
            Write-Host "  [FALTA] aceptadoel: NO EXISTE (necesita actualizar workflow)" -ForegroundColor Yellow
        }
        
        Write-Host ""
        
        if ($null -ne $usuario.acepto_terminos -and $null -ne $usuario.aceptadoel) {
            Write-Host "[EXITO] Todo correcto! Ambos campos estan presentes." -ForegroundColor Green
        } elseif ($null -ne $usuario.acepto_terminos) {
            Write-Host "[ADVERTENCIA] El campo acepto_terminos existe pero falta aceptadoel" -ForegroundColor Yellow
            Write-Host "  Accion requerida: Actualizar el workflow en n8n" -ForegroundColor Yellow
        } else {
            Write-Host "[ERROR] Faltan campos importantes" -ForegroundColor Red
        }
        
    } else {
        Write-Host "[ERROR] No se encontraron usuarios" -ForegroundColor Red
    }
    
} catch {
    Write-Host "[ERROR] No se pudo consultar el endpoint:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

Write-Host ""

