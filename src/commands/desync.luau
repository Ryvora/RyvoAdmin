local genv = (type(getgenv) == "function") and getgenv() or _G
local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/Ryvora/RyvoAdmin/refs/heads/main/"..mdl..".luau"))()
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

