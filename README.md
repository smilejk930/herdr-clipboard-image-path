# Clipboard Image Path for Herdr on WSL

This local Herdr plugin turns a Windows clipboard screenshot into a PNG and
types its WSL-visible path into the currently focused Herdr pane. It does not
submit Enter, so the path can be edited before sending it to Codex or another
program.

Images are saved under the Windows temporary directory:

```text
%TEMP%\herdr-clipboard-images\herdr-clipboard-*.png
```

From WSL, Herdr receives the equivalent `/mnt/c/Users/...` path.

## Requirements

- Herdr `0.9.1` or newer running inside WSL.
- `powershell.exe` available from WSL (standard on WSL).
- `wslpath` available from WSL.
- A Windows clipboard image, such as one made with `Win+Shift+S`.

## Install and bind Ctrl+V

### From a GitHub repository

After this plugin is published, install it from a Herdr-managed WSL pane:

```bash
herdr plugin install <github-owner>/<repository>
```

### From this local checkout

For local development, run this from a Herdr-managed WSL pane while in this
plugin directory:

```bash
herdr plugin link "$PWD"
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

## Test without a keybinding

With an image on the Windows clipboard:

```bash
herdr plugin action invoke local.clipboard-image-path.paste-path
```

If it fails, inspect the action log:

```bash
herdr plugin log list --plugin local.clipboard-image-path --limit 20
```

## Remove

```bash
herdr plugin unlink local.clipboard-image-path
```

Remove the matching `[[keys.command]]` block from `config.toml`, then reload
the config.
