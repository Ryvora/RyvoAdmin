<div align="center">

# RyvoAdmin

**A Roblox game administration and pentesting kit.**

[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)
[![Language](https://img.shields.io/badge/language-Luau-00a2ff.svg)](https://luau.org)
[![Platform](https://img.shields.io/badge/platform-Roblox-000000.svg)](https://www.roblox.com)

[**Documentation**](https://github.com/Ryvora/RyvoAdmin/wiki) &nbsp;•&nbsp;
[**Report a Bug**](https://github.com/Ryvora/RyvoAdmin/issues)

</div>

---

RyvoAdmin is a lightweight, modular administration and pentesting suite for Roblox. It runs from a single `loadstring` and gives you an in-game console with live autocomplete, toast notifications, and togglable tools such as flight and noclip.

## Features

- In-game command console with live autocomplete
- Modular command system - add your own commands with ease
- Draggable floating buttons for active commands (Fly, NoClip) that remember their position
- Config and floating-button values persist between sessions as JSON
- Toast notifications and a built-in help window
- Runs bundled (single file) or unbundled (loaded from source)

## Installation

Paste the loader below into your executor and click **Execute**:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/Ryvora/RyvoAdmin/refs/heads/main/loadstring.luau"))()
```

Then click the floating button to open the console. Type `help` to list every command.

## Configuration

RyvoAdmin fetches every module from one base URL, stored as `source` in the default config (currently `https://raw.githubusercontent.com/Ryvora/RyvoAdmin/refs/heads/main/src/`). Change it to point at your own fork or mirror. See [the wiki](https://github.com/Ryvora/RyvoAdmin/wiki) for details.

## Executor Requirements

For full compatibility your executor should provide:

1. `loadstring`
2. `game:HttpGet`
3. `getgenv()`
4. `_G`
5. `identifyexecutor()`
6. `gethui()`
7. `setclipboard` (used by `copypos` / `copycframe`)

## Documentation

Every command is documented on the **[RyvoAdmin Wiki](https://github.com/Ryvora/RyvoAdmin/wiki)**.

## License

Released under the [Apache License 2.0](LICENSE).

**Made with ♥️ by ChipLag @ Ryvora**
