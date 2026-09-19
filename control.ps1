<#
.SYNOPSIS
  EyeWatch — instalador del lado CONTROLADOR (tu PC, el que se conecta a los demás).
.DESCRIPTION
  Instala el cliente RustDesk oficial (si falta), cloudflared con sus dos tareas
  de arranque (espejo local de mirror/relay) y deja configurado el servidor
  EyeWatch con su clave pública. Idempotente. Requiere PowerShell como Administrador.
#>
#requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'

$MirrorHost = 'mirror.s-mazo.tech'
$RelayHost  = 'relay.s-mazo.tech'
$ServerKey  = 'Yk2IRetI8CYYvdYQUEYzxUcOk+nj9Yz5ej6yYjOmDWU='

function Write-Ok($m)   { Write-Host "  [OK] $m" -ForegroundColor Green }
function Write-Info($m) { Write-Host "  [..] $m" -ForegroundColor Cyan }
function Write-Err($m)  { Write-Host "  [ERROR] $m" -ForegroundColor Red }

Write-Host "`n=== EyeWatch — Configuración del PC controlador ===`n" -ForegroundColor White

# ---------- 1. Cliente RustDesk ----------
$exe = Get-ChildItem "${env:ProgramFiles(x86)}","$env:ProgramFiles" -Recurse -Filter 'rustdesk.exe' -ErrorAction SilentlyContinue |
       Select-Object -First 1 -ExpandProperty FullName
if (-not $exe) {
  Write-Info "RustDesk no está instalado; descargando el cliente oficial..."
  $rel = Invoke-RestMethod 'https://api.github.com/repos/rustdesk/rustdesk/releases/latest'
  $asset = $rel.assets | Where-Object { $_.name -match 'x86_64\.exe$' } | Select-Object -First 1
  $tmp = Join-Path $env:TEMP $asset.name
  Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tmp -UseBasicParsing
  Start-Process -FilePath $tmp -ArgumentList '--silent-install' -Wait
  Remove-Item $tmp -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 3
  $exe = Get-ChildItem "${env:ProgramFiles(x86)}","$env:ProgramFiles" -Recurse -Filter 'rustdesk.exe' -ErrorAction SilentlyContinue |
         Select-Object -First 1 -ExpandProperty FullName
}
if ($exe) { Write-Ok "Cliente RustDesk presente" } else { Write-Err "No se pudo instalar RustDesk"; exit 1 }

# ---------- 2. Configuración del servidor EyeWatch ----------
$cfgDir = "$env:APPDATA\RustDesk\config"
New-Item -ItemType Directory -Path $cfgDir -Force | Out-Null
$cfg = Join-Path $cfgDir 'RustDesk2.toml'
$claves = @('custom-rendezvous-server','relay-server','key','disable-udp')
if (Test-Path $cfg) {
  $lineas = Get-Content $cfg | Where-Object { $l = $_; -not ($claves | Where-Object { $l -match "^\s*'?$($_)'?\s*=" }) }
  $lineas | Set-Content $cfg
  if (-not (Select-String -Path $cfg -Pattern '^\[options\]' -Quiet)) { "`n[options]" | Add-Content $cfg }
} else {
  "[options]" | Set-Content $cfg
}
@(
  "custom-rendezvous-server = '127.0.0.1'",
  "relay-server = '127.0.0.1'",
  "key = '$ServerKey'",
  "disable-udp = 'Y'"
) | Add-Content $cfg
Write-Ok "Servidor EyeWatch configurado (127.0.0.1 vía túnel, solo TCP)"

# ---------- 3. cloudflared + tareas persistentes ----------
$cfExe = "${env:ProgramFiles(x86)}\cloudflared\cloudflared.exe"
if (-not (Test-Path $cfExe)) {
  Write-Info "Instalando cloudflared..."
  $msi = Join-Path $env:TEMP 'cloudflared.msi'
  Invoke-WebRequest -Uri 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.msi' -OutFile $msi -UseBasicParsing
  Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn /norestart" -Wait
  Remove-Item $msi -Force -ErrorAction SilentlyContinue
}
foreach ($map in @(@($MirrorHost,21116), @($RelayHost,21117))) {
  $tn = "EyeWatch-Tunnel-$($map[1])"
  $act = New-ScheduledTaskAction -Execute $cfExe -Argument "access tcp --hostname $($map[0]) --url 127.0.0.1:$($map[1])"
  $trg = New-ScheduledTaskTrigger -AtStartup
  $set = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1) -ExecutionTimeLimit ([TimeSpan]::Zero)
  Register-ScheduledTask -TaskName $tn -Action $act -Trigger $trg -Settings $set -User 'SYSTEM' -RunLevel Highest -Force | Out-Null
  Start-ScheduledTask -TaskName $tn
  Write-Ok "Tarea '$tn' activa ($($map[0]) -> 127.0.0.1:$($map[1]))"
}

# ---------- 4. Validación ----------
Start-Sleep -Seconds 8
$ok16 = (Test-NetConnection -ComputerName 127.0.0.1 -Port 21116 -WarningAction SilentlyContinue).TcpTestSucceeded
$ok17 = (Test-NetConnection -ComputerName 127.0.0.1 -Port 21117 -WarningAction SilentlyContinue).TcpTestSucceeded
if ($ok16 -and $ok17) { Write-Ok "Túnel Cloudflare operativo" }
else { Write-Err "Espejo local incompleto (21116=$ok16 21117=$ok17). Revisa las tareas EyeWatch-Tunnel-*" }

Write-Host "`n=== LISTO ===" -ForegroundColor White
Write-Host "  Abre RustDesk, escribe el ID del PC gestionado y su contraseña." -ForegroundColor Yellow
Write-Host "  (Las credenciales de cada PC están en su C:\ProgramData\EyeWatch\credentials.txt)`n"
