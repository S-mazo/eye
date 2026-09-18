<#
.SYNOPSIS
  EyeWatch — despliegue en masa (varios PCs desde un PC de administración).
.DESCRIPTION
  Ejecuta el bootstrapper oficial (irm eye.s-mazo.tech | iex) en una lista de PCs
  vía PowerShell Remoting. Recoge el ID+contraseña generados en cada PC leyendo
  C:\ProgramData\EyeWatch\credentials.txt (remotamente, como admin).
.EXAMPLE
  .\deploy-masivo.ps1 -Equipos PC01,PC02,PC03
  Get-Content pcs.txt | .\deploy-masivo.ps1
#>
param(
  [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
  [string[]]$Equipos,
  [pscredential]$Credencial
)
begin { $resultados = @() }
process {
  foreach ($pc in $Equipos) {
    Write-Host "`n=== $pc ===" -ForegroundColor White
    try {
      $param = @{ ComputerName = $pc; ErrorAction = 'Stop' }
      if ($Credencial) { $param.Credential = $Credencial }
      $r = Invoke-Command @param -ScriptBlock {
        Invoke-Expression (Invoke-RestMethod 'https://eye.s-mazo.tech')
        if (Test-Path 'C:\ProgramData\EyeWatch\credentials.txt') {
          Get-Content 'C:\ProgramData\EyeWatch\credentials.txt'
        }
      }
      $id  = ($r | Where-Object { $_ -match '^ID=' })  -replace '^ID=',''
      $pwd = ($r | Where-Object { $_ -match '^Password=' }) -replace '^Password=',''
      $resultados += [pscustomobject]@{ PC=$pc; ID=$id; Password=$pwd; Estado='OK' }
      Write-Host "  OK  ID=$id" -ForegroundColor Green
    } catch {
      $resultados += [pscustomobject]@{ PC=$pc; ID=''; Password=''; Estado=$_.Exception.Message }
      Write-Host "  FALLO: $($_.Exception.Message)" -ForegroundColor Red
    }
  }
}
end {
  $ts = Get-Date -Format 'yyyyMMdd-HHmm'
  $out = "eyewatch-despliegue-$ts.csv"
  $resultados | Export-Csv $out -NoTypeInformation -Encoding UTF8
  Write-Host "`nResumen guardado en $out (protégelo: contiene contraseñas)" -ForegroundColor Yellow
  $resultados | Format-Table PC, ID, Estado
}
<#
NOTAS
- Requiere WinRM habilitado en los PCs destino (Enable-PSRemoting) y credenciales admin.
- Alternativa GPO: script de arranque de equipo con:
    powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (irm 'https://eye.s-mazo.tech')"
  (las credenciales quedan en C:\ProgramData\EyeWatch\credentials.txt de cada PC).
#>
