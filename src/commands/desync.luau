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

local Desync = _RyEnv.RyvoraGet("Desync.luau")

_RyEnv.registerCommand("desync", { }, {}, function()
	Desync.start()
end)

_RyEnv.registerCommand("undesync", { "nodesync" }, {}, function()
	Desync.stop()
end)

_RyEnv.registerCommand("bringdesync", { }, {}, function()
	local clonePrim = Desync.clone:FindFirstChild("HumanoidRootPart") or Desync.clone.PrimaryPart
	Desync.setOrigPosition(clonePrim.CFrame)
end)

_RyEnv.registerCommand("todesync", { }, {}, function()
	local clonePrim = Desync.clone:FindFirstChild("HumanoidRootPart") or Desync.clone.PrimaryPart
	local origPrim = Desync.origChar:FindFirstChild("HumanoidRootPart") or Desync.origChar.PrimaryPart
	clonePrim.CFrame = origPrim.CFrame
end)

