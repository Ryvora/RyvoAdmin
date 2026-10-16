local genv = (type(getgenv) == "function") and getgenv() or _G
local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
end
_RyEnv = _RyEnv or genv.Ryvora__RyvoAdmin.Env

local helpGui = require("gui/help")

_RyEnv.registerCommand("help", { "commands", "cmds" }, {
	{ name = "query", type = "string", required = false },
}, function(query)
	if query ~= nil and query ~= "" then
		helpGui.open(query)
	else
		helpGui.open()
	end
end)
