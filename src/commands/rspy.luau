local cobaltspyurl = "https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau"
local simplespyurl = "https://gitlab.com/ltseverydayyou/uuuuuuu/-/raw/main/SimpleSpyRework.luau"
local turtlespyurl = "https://gitlab.com/ltseverydayyou/uuuuuuu/-/raw/main/Turtle%20Spy.lua"

local genv = (type(getgenv) == "function") and getgenv() or _G
local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
end
_RyEnv = _RyEnv or genv.Ryvora__RyvoAdmin.Env

_RyEnv.registerCommand("cspy", { "cobalt" }, {}, function()
	_RyEnv.notify("Loading Cobalt RemoteSpy...", 2)
	loadstring(game:HttpGet(cobaltspyurl))
end)


_RyEnv.registerCommand("rspy", { "sspy", "simplespy" }, {}, function()
	_RyEnv.notify("Loading SimpleSpy (Cobalt is recommended)...", 2)
	loadstring(game:HttpGet(simplespyurl))
end)

_RyEnv.registerCommand("tspy", { "turtlespy" }, {}, function()
	_RyEnv.notify("Loading SimpleSpy (Cobalt is recommended)...", 2)
	loadstring(game:HttpGet(simplespyurl))
end)
