# eye.s-mazo.tech — Instalador público de EyeWatch

Este repo sirve el bootstrapper de instalación vía GitHub Pages y aloja los
Releases con el instalador `EyeWatch-setup.exe` (generado desde el repo
privado `eyewatch-build`).

## Uso (en el PC a gestionar)

PowerShell **como Administrador**:

```powershell
irm eye.s-mazo.tech | iex
```

Al terminar muestra **una sola vez** el ID y la contraseña aleatoria del PC
(también en `C:\ProgramData\EyeWatch\credentials.txt`, solo Administradores).

## Cómo funciona el `irm` en la raíz del dominio

`index.html` **es** el script de PowerShell. `irm` descarga el cuerpo de la
respuesta sin importar el Content-Type (`text/html`), y `iex` lo ejecuta.
Por eso no hace falta Jekyll ni redirecciones. `install.ps1` existe además
como copia canónica por si se prefiere `irm eye.s-mazo.tech/install.ps1 | iex`.

> Alternativa documentada: servir el raw desde
> `raw.githubusercontent.com/S-mazo/eye/main/install.ps1`. Se descartó porque
> exige otra URL y no funciona con el dominio propio.

## Actualizar el instalador

1. En el repo privado `eyewatch-build`, lanzar el workflow de build.
2. El workflow publica un nuevo Release aquí con el asset `EyeWatch-setup.exe`.
3. `install.ps1` usa `/releases/latest/download/`, así que **no hay que tocar
   el script**: el siguiente `irm | iex` instala la versión nueva.

## Seguridad

- Este repo es público a propósito y **no contiene secretos**: ni contraseñas
  (se generan aleatorias por PC en cada instalación) ni la clave privada del
  servidor (nunca sale de la VPS).
- La clave pública del servidor embebida en el script no es un secreto: sirve
  para que el cliente verifique al servidor, no al revés.

## Lado controlador (tu PC)

```powershell
irm eye.s-mazo.tech/control.ps1 | iex
```

Instala el cliente RustDesk oficial (si falta), cloudflared con sus dos tareas y
deja configurado el servidor EyeWatch. Después: abre RustDesk, escribe el ID del
PC gestionado y su contraseña.
