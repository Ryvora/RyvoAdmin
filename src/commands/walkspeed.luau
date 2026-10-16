local genv = (type(getgenv) == "function") and getgenv() or _G
local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
end
_RyEnv = _RyEnv or genv.Ryvora__RyvoAdmin.Env

local beat = nil
local speed = 16

local function applySpeed()
	local hum = _RyEnv.Player.getHumanoid()
	if hum then
		hum.WalkSpeed = speed
	end
end

_RyEnv.registerCommand("walkspeed", { "ws", "speed" }, {
	{ name = "value", required = true, type = "number" },
}, function(value)
	speed = value
	applySpeed()

	if not beat then
		beat = _RyEnv.Svc.Run.Heartbeat:Connect(applySpeed)
	end
end)

_RyEnv.registerCommand("unwalkspeed", { "unws", "unspeed" }, {}, function()
	speed = 16
	if beat then
		beat:Disconnect()
		beat = nil
	end
	applySpeed()
end)
