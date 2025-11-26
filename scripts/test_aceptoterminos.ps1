# Script para verificar el campo AceptoTerminos en el endpoint
# Ejecutar: powershell -ExecutionPolicy Bypass -File scripts\test_aceptoterminos.ps1

Write-Host "[*] Verificando campo AceptoTerminos en el endpoint..." -ForegroundColor Cyan
Write-Host ""

$endpoint = "https://wf.zynaptic.tech/webhook/nutridiab/admin/usuarios"

try {
    Write-Host "[*] Consultando endpoint: $endpoint" -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri $endpoint -Method Get -UseBasicParsing
    
    Write-Host "[OK] Respuesta recibida" -ForegroundColor Green
    Write-Host ""
    
    # Verificar si la respuesta es un array
    if ($response -is [Array]) {
        Write-Host "[INFO] Total de usuarios: $($response.Count)" -ForegroundColor Cyan
        Write-Host ""
        
        if ($response.Count -gt 0) {
            Write-Host "[*] Primer usuario (muestra):" -ForegroundColor Yellow
            $primerUsuario = $response[0]
            
            # Mostrar campos relevantes
            Write-Host "  - ID: $($primerUsuario.id)"
            Write-Host "  - Nombre: $($primerUsuario.nombre) $($primerUsuario.apellido)"
            Write-Host "  - Email: $($primerUsuario.email)"
            Write-Host ""
            
            # Verificar todos los campos relacionados con términos
            Write-Host "[*] Campos de Aceptacion de Terminos:" -ForegroundColor Cyan
            
            # Listar TODAS las propiedades del objeto
            Write-Host ""
            Write-Host "[*] Todas las propiedades del usuario:" -ForegroundColor Yellow
            $primerUsuario.PSObject.Properties | ForEach-Object {
                $nombre = $_.Name
                $valor = $_.Value
                if ($nombre -match "termino|acepto|accept" -or $nombre -eq "AceptoTerminos") {
                    Write-Host "  [IMPORTANTE] $nombre = $valor" -ForegroundColor Green
                } else {
                    Write-Host "  - $nombre = $valor"
                }
            }
            
            Write-Host ""
            Write-Host "[*] Verificando especificamente el campo:" -ForegroundColor Yellow
            
            # Intentar acceder al campo de diferentes formas
            $variantes = @(
                "AceptoTerminos",
                "aceptoterminos", 
                "acepto_terminos",
                "aceptoTerminos",
                "Aceptoterminos"
            )
            
            foreach ($variante in $variantes) {
                $valor = $primerUsuario.$variante
                if ($null -ne $valor) {
                    Write-Host "  [OK] $variante = $valor" -ForegroundColor Green
                } else {
                    Write-Host "  [NO] $variante = (no existe)" -ForegroundColor Red
                }
            }
            
            Write-Host ""
            Write-Host "[*] Estructura completa del primer usuario:" -ForegroundColor Cyan
            $primerUsuario | ConvertTo-Json -Depth 3
            
        } else {
            Write-Host "[WARN] No hay usuarios en la respuesta" -ForegroundColor Yellow
        }
    } else {
        Write-Host "[WARN] La respuesta no es un array" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "[*] Respuesta completa:" -ForegroundColor Cyan
        $response | ConvertTo-Json -Depth 3
    }
    
} catch {
    Write-Host "[ERROR] Error al consultar el endpoint:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "[*] Detalles del error:" -ForegroundColor Yellow
    Write-Host $_ -ForegroundColor Gray
}

Write-Host ""
Write-Host "[OK] Verificacion completada" -ForegroundColor Green
