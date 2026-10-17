local vexurl = "https://gitlab.com/ltseverydayyou/uuuuuuu/-/raw/main/DexPlusBackup.luau"
local dexurl = "https://gitlab.com/ltseverydayyou/uuuuuuu/-/raw/main/DexPlusBackup.luau"


local genv = (type(getgenv) == "function") and getgenv() or _G
local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
end
_RyEnv = _RyEnv or genv.Ryvora__RyvoAdmin.Env

_RyEnv.registerCommand("vex", { "explorer" }, {}, function()
	_RyEnv.notify("Loading Vex Explorer...", 2)
	loadstring(game:HttpGet(vexurl))
end)


_RyEnv.registerCommand("dex++", { "dexpp", "dex" }, {}, function()
	_RyEnv.notify("Loading Dex++ (Vex is recommended)...", 2)
	loadstring(game:HttpGet(vexurl))
end)
