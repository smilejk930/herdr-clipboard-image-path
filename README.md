# Clipboard Image Path for Herdr on WSL

This Herdr plugin turns a Windows clipboard screenshot into a PNG and
types its WSL-visible path into the currently focused Herdr pane. It does not
submit Enter, so the path can be edited before sending it to Codex or another
program.

Clipboard images are saved under the Windows temporary directory:

```text
%TEMP%\herdr-clipboard-images\herdr-clipboard-*.png
```

From WSL, Herdr receives the equivalent `/mnt/c/Users/...` path.

If the capture tool saves screenshots directly to `Pictures\\Screenshots`
instead of placing an image on the clipboard, the plugin uses the newest image
there, provided it was created within the previous five minutes. This supports
Windows' automatically saved screenshots such as
`/mnt/c/Users/<Windows-user>/Pictures/Screenshots/<screenshot>.png`.

## Requirements

- Herdr `0.9.1` or newer running inside WSL.
- `powershell.exe` available from WSL (standard on WSL).
- `wslpath` available from WSL.
- A Windows clipboard image, such as one made with `Win+Shift+S`.

## Install and bind Ctrl+V

Install it from a Herdr-managed WSL pane:

```bash
herdr plugin install smilejk930/herdr-clipboard-image-path
```

Add this to `~/.config/herdr/config.toml`. It deliberately reserves `Ctrl+V`
for image paths, replacing Herdr's normal handling of that key.

```toml
[[keys.command]]
key = "ctrl+v"
type = "plugin_action"
command = "local.clipboard-image-path.paste-path"
description = "paste Windows clipboard image path"
```

Reload the config:

```bash
herdr server reload-config
```

Now capture with `Win+Shift+S`, focus a Herdr pane, and press `Ctrl+V`.

## Remove

```bash
herdr plugin unlink local.clipboard-image-path
```

Remove the matching `[[keys.command]]` block from `config.toml`, then reload
the config.
