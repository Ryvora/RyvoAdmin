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
