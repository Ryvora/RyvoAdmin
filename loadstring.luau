local genv = (type(getgenv) == "function") and getgenv() or _G

-- RyvoAdmin bootstrap.
-- Change "source" to load the modules from somewhere else (for example your own
-- fork) - everything under it is loaded relative to this URL.
local config = genv.Ryvora__RyvoAdminConfig or {}
config.bundled = false
config.source = config.source or "https://raw.githubusercontent.com/Ryvora/RyvoAdmin/refs/heads/main/src/"
genv.Ryvora__RyvoAdminConfig = config

loadstring(game:HttpGet(config.source .. "main.luau"))()
