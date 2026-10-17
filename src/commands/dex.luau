local vexurl = "https://gitlab.com/ltseverydayyou/uuuuuuu/-/raw/main/DexPlusBackup.luau"
local dexurl = "https://gitlab.com/ltseverydayyou/uuuuuuu/-/raw/main/DexPlusBackup.luau"


local genv = (type(getgenv) == "function") and getgenv() or _G
local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
	-- Cache modules so they only execute once (avoids duplicate UI, etc.).
	genv.Ryvora__RyvoAdmin = genv.Ryvora__RyvoAdmin or {}
	local cache = genv.Ryvora__RyvoAdmin.RequireCache
	if not cache then
		cache = {}
		genv.Ryvora__RyvoAdmin.RequireCache = cache
	end
	local entry = cache[mdl]
	if entry and entry.done then
		return entry.value
	end
	local src = (genv.Ryvora__RyvoAdminConfig and genv.Ryvora__RyvoAdminConfig.source) or "https://raw.githubusercontent.com/Ryvora/RyvoAdmin/refs/heads/main/src/"
	local result = loadstring(game:HttpGet(src .. mdl .. ".luau"))()
	cache[mdl] = { value = result, done = true }
	return result
end
_RyEnv = _RyEnv or genv.Ryvora__RyvoAdmin.Env

_RyEnv.registerCommand("vex", { "explorer" }, {}, function()
	_RyEnv.notify("Loading Vex Explorer...", 2)
	loadstring(game:HttpGet(vexurl))()
end)


_RyEnv.registerCommand("dex++", { "dexpp", "dex" }, {}, function()
	_RyEnv.notify("Loading Dex++ (Vex is recommended)...", 2)
	loadstring(game:HttpGet(dexurl))()
end)
