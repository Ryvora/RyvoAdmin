local genv = (type(getgenv) == "function") and getgenv() or _G
local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
end
_RyEnv = _RyEnv or genv.Ryvora__RyvoAdmin.Env

local commands = {
	"fly",
	"noclip",
	"help",
	"copypos",
	"walkspeed",
	"desync"
}

-- If there's any command that has a subcommand, e.g. fly & unfly (allows counting accurately!)
local extras = {
	"unfly",
	"clip",
	"copycframe",
	"unwalkspeed",
	"undesync", 
	"bringdesync",
	"todesync"
}

-- CODE FROM HERE; DONT EDIT IT! --
function _RyEnv.registerCommand(command, aliases, argsInfo, callback)
	table.insert(_RyEnv.Commands, {
		Command=command,
		Aliases=aliases,
		ArgsInfo=argsInfo,
		Callback=callback
	})
end



local tempGui = require("tempgui")
local failedToLoad = 0
for i, cmd in pairs(commands) do
	-- TODO: Print Errors
	tempGui.label.Text = "Registering Commands... (" .. i .. "/" .. #commands+#extras .. ")"
	
	local success, result = pcall(function()
		require("commands/" .. cmd)
	end)
	if not success then
		failedToLoad = failedToLoad + 1
		warn("RyvoAdmin Error, Failed to register command: " .. tostring(cmd) .. ", because of: " .. tostring(result))
	end
end

