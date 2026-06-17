# dotfiles-slaker

Catppuccin Mocha Mauve Hyprland rice by **Slaker19**.

Basado en el estilo de window management de **JaKooLit**, con theme purple/Catppuccin, waybar funcional, swaync, rofi, Quickshell overview y wallpaper picker hexagonal.

---

## Atajos de teclado

| Atajo | Función |
|-------|---------|
| `Win + Enter` | Terminal (Ghostty) |
| `Win + D` | Lanzador de apps (Rofi) |
| `Win + Shift + R` | Lanzador de comandos (Rofi run) |
| `Win + Q` | Cerrar ventana |
| `Win + F` | Fullscreen |
| `Win + Shift + F` | Fullscreen |
| `Win + Ctrl + F` | Maximizar |
| `Win + B` | Navegador (Brave|ZenBrowser|Firefox) |
| `Win + E` | Gestor de archivos (Nautilus) |
| `Win + Backspace` | Bloquear pantalla |
| `Win + Shift + L` | Bloquear pantalla |
| `Win + Shift + Escape` | Menú de salida (Wlogout) |

### Window management (estilo JaKooLit)

| Atajo | Función |
|-------|---------|
| `Win + Space` | Alternar float/tile (800×600 centrado) |
| `Win + Alt + Space` | Forzar float a todas las ventanas |
| `Win + flechas` | Mover foco |
| `Win + Ctrl + flechas` | Mover ventana |
| `Win + Shift + flechas` | Redimensionar ventana |
| `Win + Alt + flechas` | Intercambiar ventanas |
| `Win + G` | Toggle group |
| `Win + P` | Pseudo-tile |
| `Win + Tab` | Overview de workspaces (Quickshell) |
| `Win + Shift + Tab` | Workspace anterior |
| `Win + U` | Toggle workspace especial (scratchpad) |
| `Win + Shift + U` | Mover ventana a workspace especial |
| `Win + Ctrl + K` | Abrir qt6ct |

### Workspaces

| Atajo | Función |
|-------|---------|
| `Win + 1-0` | Ir al workspace N |
| `Win + Shift + 1-0` | Mover ventana al workspace N |
| `Win + Ctrl + 1-0` | Mover ventana al workspace N (silent) |
| `Win + .` / `Win + ,` | Siguiente / anterior workspace |
| `Win + scroll` | Cambiar workspace |

### Capturas de pantalla

| Atajo | Función |
|-------|---------|
| `Win + Print` | Captura de área seleccionada |
| `Win + Shift + Print` | Captura de monitor actual |
| `Win + Shift + S` | Captura de área seleccionada |

### Multimedia

| Atajo | Función |
|-------|---------|
| `Tecla Play/Pause` | Reproducir / pausar |
| `Tecla Next` | Siguiente tema |
| `Tecla Prev` | Tema anterior |
| `Tecla VolUp` | Subir volumen (+5%) |
| `Tecla VolDown` | Bajar volumen (-5%) |
| `Tecla VolMute` | Silenciar audio |
| `Tecla MicMute` | Silenciar micrófono |
| `Tecla BrightUp` | Subir brillo (+5%) |
| `Tecla BrightDown` | Bajar brillo (-5%, mínimo 5%) |

### Notificaciones y extras

| Atajo | Función |
|-------|---------|
| `Win + N` | Centro de notificaciones (swaync) |
| `Win + Shift + O` | Alternar blur/transparencia |
| `Win + W` | Selector de wallpaper (hexagonal UI) |
| `Win + Shift + V` | Portapapeles (cliphist + rofi) |
| `Win + Ctrl + M` | Configuración de monitores (nwg-displays) |

---

## Mouse y gestos

| Acción | Función |
|--------|---------|
| `Win + click izquierdo` | Mover ventana |
| `Win + click derecho` | Redimensionar ventana |
| `Win + Alt + click derecho` | Redimensionar ventana |
| `3 dedos horizontal` | Cambiar workspace |
| `3 dedos arriba` | Overview de workspaces |

---

## Componentes

| Componente | Descripción |
|-----------|-------------|
| **Hyprland** | Compositor Wayland |
| **Waybar** | Barra superior con sysstats, media controls, fecha |
| **Rofi** | Lanzador de apps y portapapeles (Catppuccin Mauve) |
| **Swaync** | Centro de notificaciones (Caelestia purple) |
| **Quickshell** | Overview de workspaces |
| **Ghostty** | Terminal con tema Catppuccin |
| **Fastfetch** | Info del sistema (gamer-style) |
| **Qt6ct + Kvantum** | Qt apps con Catppuccin Mocha Mauve |
| **Catppuccin GTK** | GTK apps con Catppuccin Mocha Mauve |
| **hypr-wallpicker** | Wallpaper picker con UI hexagonal |
| **Hypridle** | Gestión de idle (5min dim, 10min lock, 15min suspend) |
| **Cliphist** | Historial del portapapeles |
| **Wlogout** | Menú de salida (lock/logout/suspend/reboot/shutdown) |
| **Btop** | Monitor del sistema |

---

## Instalación

```bash
git clone https://github.com/Slaker19/dotfiles-slaker.git
cd dotfiles-slaker
./install.sh
```

### Modos de instalación

| Modo | Descripción |
|------|-------------|
| **Fresh** | Instalación limpia. Respaldar configs existentes, reemplazar todo, instalar todos los paquetes, habilitar servicios. |
| **Upgrade** | Actualización segura. Solo añade archivos nuevos, preserva tus cambios locales. Instala solo paquetes faltantes. |

Seleccionás el modo al ejecutar el script o pasando el flag:

```bash
./install.sh --fresh     # Instalación limpia
./install.sh --upgrade   # Actualización (preserva configs)
```

Después de fresh, reiniciar sesión en Hyprland.

---

## Colores

| Rol | Color |
|-----|-------|
| Fondo | `#0a0a14` |
| Texto | `#cdd6f4` |
| Primario (Mauve) | `#bb86fc` / `#cba6f7` |
| Secundario | `#7c3aed` |
| Superficie | `#11111b` |
| Base | `#1e1e2e` |

---

## Créditos

- [JaKooLit](https://github.com/JaKooLit) — Window management style
- [Catppuccin](https://github.com/catppuccin) — Tema Mocha Mauve
- [Unixcraft-Studios](https://github.com/Unixcraft-Studios/hypr-wallpicker) — hypr-wallpicker
