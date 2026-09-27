<#
.SYNOPSIS
  EyeWatch  instalador desatendido (irm eye.s-mazo.tech | iex)
.DESCRIPTION
  Idempotente. Instala EyeWatch (cliente RustDesk rebranded) como servicio Windows,
  instala cloudflared con dos tareas al arranque (espejo local de mirror/relay),
  fija contrasena permanente ALEATORIA por PC y muestra ID + contrasena una vez.
  Sin secretos embebidos. Requiere PowerShell como Administrador.
#>
#requires -RunAsAdministrator
$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'   # acelera Invoke-WebRequest

# ---------- Parametros del despliegue (publicos, sin secretos) ----------
$ExeUrl      = 'https://github.com/S-mazo/eye/releases/latest/download/EyeWatch-setup.exe'
$CfMsiUrl    = 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.msi'
$MirrorHost  = 'mirror.s-mazo.tech'
$RelayHost   = 'relay.s-mazo.tech'
$ServerKey   = 'Yk2IRetI8CYYvdYQUEYzxUcOk+nj9Yz5ej6yYjOmDWU='
$CredDir     = "$env:ProgramData\EyeWatch"
$CredFile    = "$CredDir\credentials.txt"

function Write-Ok($m)   { Write-Host "  [OK] $m" -ForegroundColor Green }
function Write-Info($m) { Write-Host "  [..] $m" -ForegroundColor Cyan }
function Write-Err($m)  { Write-Host "  [ERROR] $m" -ForegroundColor Red }

Write-Host "`n=== EyeWatch  Instalacion ===`n" -ForegroundColor White

# ---------- 1. Descargar e instalar EyeWatch ----------
$tmp = Join-Path $env:TEMP 'EyeWatch-setup.exe'
Write-Info "Descargando EyeWatch..."
Invoke-WebRequest -Uri $ExeUrl -OutFile $tmp -UseBasicParsing
Write-Info "Instalando (silencioso)..."
$p = Start-Process -FilePath $tmp -ArgumentList '--silent-install' -Wait -PassThru
if ($p.ExitCode -ne 0) { Write-Err "El instalador devolvio codigo $($p.ExitCode)"; exit 1 }
Remove-Item $tmp -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3
Write-Ok "EyeWatch instalado"

# ---------- 2. Localizar binario y servicio ----------
$exe = Get-ChildItem "${env:ProgramFiles(x86)}","$env:ProgramFiles" -Recurse -Filter 'EyeWatch.exe' -ErrorAction SilentlyContinue |
       Select-Object -First 1 -ExpandProperty FullName
if (-not $exe) { Write-Err "No se encontro EyeWatch.exe tras instalar"; exit 1 }
$svc = Get-Service | Where-Object { $_.Name -match 'rustdesk|eyewatch' } | Select-Object -First 1
if ($svc) {
  Set-Service $svc.Name -StartupType Automatic
  Write-Ok "Servicio '$($svc.Name)' en arranque Automatico (SCM; sobrevive a 'Inicio' del Administrador de tareas)"
}

# ---------- 3. Contrasena permanente aleatoria (unica por PC) ----------
New-Item -ItemType Directory -Path $CredDir -Force | Out-Null
if (Test-Path $CredFile) {
  $Password = (Get-Content $CredFile | Where-Object { $_ -match '^Password=' }) -replace '^Password=',''
  Write-Info "Instalacion previa detectada: reutilizando la contrasena existente (idempotente)"
} else {
  $chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKMNPQRSTUVWXYZ23456789'
  $Password = -join (1..20 | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
}
& $exe --password $Password | Out-Null
Write-Ok "Contrasena permanente fijada"

# ---------- 4. Configuracion del cliente (todas las funciones habilitadas) ----------
$opciones = [ordered]@{
  'custom-rendezvous-server' = '127.0.0.1'      # espejado por cloudflared access tcp
  'relay-server'          = '127.0.0.1'
  'key'                   = $ServerKey
  'disable-udp'           = 'Y'                # Cloudflare Tunnel es TCP-only
  'approve-mode'          = 'password'         # solo contrasena: sin popup al conectar
  'verification-method'   = 'use-permanent-password'
  'hide-tray'             = 'Y'                # sin icono en bandeja
  'hide-help-cards'       = 'Y'
  'remove-preset-password-warning' = 'Y'
  'allow-auto-update'     = 'N'                # nunca sustituir EyeWatch por RustDesk oficial
  'allow-remote-config-modification' = 'N'
  'enable-file-transfer'  = 'Y'
  'enable-camera'         = 'Y'
  'enable-terminal'       = 'Y'
  'enable-tunnel'         = 'Y'
  'enable-audio'          = 'Y'
  'enable-clipboard'      = 'Y'
  'enable-remote-restart' = 'Y'
}
foreach ($k in $opciones.Keys) { & $exe --option "$k=$($opciones[$k])" | Out-Null }
Write-Ok "Configuracion aplicada (archivos, camara, terminal, tunel TCP: habilitados)"

# ---------- 5. cloudflared + tareas persistentes ----------
$cfExe = "${env:ProgramFiles(x86)}\cloudflared\cloudflared.exe"
if (-not (Test-Path $cfExe)) {
  Write-Info "Instalando cloudflared..."
  $msi = Join-Path $env:TEMP 'cloudflared.msi'
  Invoke-WebRequest -Uri $CfMsiUrl -OutFile $msi -UseBasicParsing
  $p = Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn /norestart" -Wait -PassThru
  Remove-Item $msi -Force -ErrorAction SilentlyContinue
  if (-not (Test-Path $cfExe)) { Write-Err "cloudflared no quedo instalado"; exit 1 }
}
Write-Ok "cloudflared presente"

foreach ($map in @(@($MirrorHost,21116), @($RelayHost,21117))) {
  $tn = "EyeWatch-Tunnel-$($map[1])"
  $arg = "access tcp --hostname $($map[0]) --url 127.0.0.1:$($map[1])"
  $act = New-ScheduledTaskAction -Execute $cfExe -Argument $arg
  $trg = New-ScheduledTaskTrigger -AtStartup
  $set = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
         -RestartCount 999 -RestartInterval (New-TimeSpan -Minutes 1) -ExecutionTimeLimit ([TimeSpan]::Zero)
  Register-ScheduledTask -TaskName $tn -Action $act -Trigger $trg -Settings $set `
    -User 'SYSTEM' -RunLevel Highest -Force | Out-Null
  Start-ScheduledTask -TaskName $tn
  Write-Ok "Tarea '$tn' registrada y arrancada ($($map[0]) -> 127.0.0.1:$($map[1]))"
}

# ---------- 6. Validacion final ----------
Start-Sleep -Seconds 8
$ok21116 = (Test-NetConnection -ComputerName 127.0.0.1 -Port 21116 -WarningAction SilentlyContinue).TcpTestSucceeded
$ok21117 = (Test-NetConnection -ComputerName 127.0.0.1 -Port 21117 -WarningAction SilentlyContinue).TcpTestSucceeded
if ($svc) {
  $arrancado = $false
  foreach ($intento in 1..3) {
    try {
      Restart-Service $svc.Name -Force -ErrorAction Stop
      $arrancado = $true; break
    } catch {
      Write-Info "Reinicio del servicio (intento $intento/3): $($_.Exception.Message)"
      Start-Process sc.exe -ArgumentList "start $($svc.Name)" -Wait -NoNewWindow -ErrorAction SilentlyContinue
      Start-Sleep -Seconds 5
      if ((Get-Service $svc.Name).Status -eq 'Running') { $arrancado = $true; break }
    }
  }
  if ($arrancado) { Write-Ok "Servicio '$($svc.Name)' en ejecucion" }
  else { Write-Err "El servicio '$($svc.Name)' no arranca. Ejecuta: sc.exe qc $($svc.Name) ; Get-EventLog -LogName System -Newest 8 -Source 'Service Control Manager'" }
}
$Id = (& $exe --get-id 2>$null) -replace '\s',''
if (-not $Id) { Write-Err "No se pudo obtener el ID (el servicio no responde aun; re-ejecuta este script en unos minutos)"; exit 1 }

# Guardar credenciales (solo Administradores)
"ID=$Id`nPassword=$Password" | Out-File $CredFile -Encoding ascii -Force
$acl = Get-Acl $CredFile
$acl.SetAccessRuleProtection($true, $false)
$acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) | Out-Null }
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule('Administradores','FullControl','Allow')))
$acl.AddAccessRule((New-Object System.Security.AccessControl.FileSystemAccessRule('SYSTEM','FullControl','Allow')))
Set-Acl $CredFile $acl

Write-Host "`n=== RESULTADO ===" -ForegroundColor White
if ($ok21116 -and $ok21117) { Write-Ok "Tunel Cloudflare operativo (21116 y 21117 locales responden)" }
else { Write-Err "Espejo local incompleto (21116=$ok21116 21117=$ok21117). Revisa las tareas EyeWatch-Tunnel-*" }
Write-Host "`n  " -ForegroundColor Yellow
Write-Host  "    ANOTA ESTOS DATOS  no se repiten:      " -ForegroundColor Yellow
Write-Host  "    ID:         $Id" -ForegroundColor Yellow
Write-Host  "    Contrasena: $Password" -ForegroundColor Yellow
Write-Host  "  " -ForegroundColor Yellow
Write-Host  "  (Tambien en $CredFile  solo Administradores)`n"
Write-Ok "EyeWatch queda activo como servicio; tras reiniciar el PC se conecta solo, antes del login."
