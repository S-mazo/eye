# Checklist post-instalación EyeWatch (por PC)

Ejecutar tras `irm eye.s-mazo.tech | iex` y, al final, tras un **reinicio**.

## Inmediato tras instalar

- [ ] El script terminó sin `[ERROR]` y mostró `Túnel Cloudflare operativo`.
- [ ] ID + contraseña anotados en mi gestor de contraseñas.
- [ ] Servicio EyeWatch: `Get-Service | ? Name -match 'rustdesk|eyewatch'` → `Running`, arranque `Automatic`.
- [ ] Tareas: `Get-ScheduledTask EyeWatch-Tunnel-*` → ambas `Ready/Running` como SYSTEM.
- [ ] **Sin icono en bandeja** (el proceso en 2º plano en el Administrador de tareas es lo esperado).
- [ ] **Sin ventana de aviso** al conectar (probar conexión entrante con el ID+contraseña).
- [ ] Marca **EyeWatch** visible (icono/nombre), nada de "RustDesk" en la app instalada.

## Funcionalidad (desde mi cliente controlador)

- [ ] Escritorio remoto fluido (todo va relayeado por Cloudflare: latencia algo mayor es normal).
- [ ] Transferencia de archivos (ambos sentidos).
- [ ] Visualización de cámara.
- [ ] Terminal/shell remota.
- [ ] Port forwarding (TCP tunneling).

## Tras reiniciar el PC gestionado

- [ ] **Sin iniciar sesión**, el PC aparece accesible y acepta conexión con su contraseña.
- [ ] Tras el login: sigue sin icono en bandeja ni popups.
- [ ] Si se quita de "Inicio" en el Administrador de tareas: irrelevante, EyeWatch es
      **servicio SCM**, no una entrada de Inicio. Verificar reconexión tras otro reinicio.

## Antivirus / SmartScreen

- [ ] Si Defender lo marca como PUA: añadir exclusión de carpeta de instalación de EyeWatch
      (`Add-MpPreference -ExclusionPath "<carpeta EyeWatch>"`) y documentarlo.
- [ ] El flujo `irm | iex` no añade Mark-of-the-Web: no debería salir el popup azul de
      SmartScreen. Si aparece al ejecutar algo manualmente: "Más información → Ejecutar de
      todas formas" (desaparece cuando el binario esté firmado con Authenticode).
