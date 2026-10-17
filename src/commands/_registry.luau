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

local commands = {
	"fly",
	"noclip",
	"help",
	"copypos",
	"walkspeed",
	"desync",
	"dex",
	"rspy",
}

-- If there's any command that has a subcommand, e.g. fly & unfly (allows counting accurately!)
local extras = {
	"unfly",
	"clip",
	"copycframe",
	"unwalkspeed",
	"undesync", 
	"bringdesync",
	"todesync",
	"vex",
	"cspy",
	"tspy",
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

