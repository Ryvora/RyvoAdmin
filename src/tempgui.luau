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

local tempGui = Instance.new("ScreenGui")
tempGui.Parent = gethui and gethui() or game:GetService("CoreGui")
tempGui.IgnoreGuiInset = true

local root = Instance.new("TextLabel", tempGui)
root.AnchorPoint = Vector2.new(0.5, 0)
root.Position = UDim2.new(0.5, 0, 0, 12)
root.Size = UDim2.new(0.5, 0, 0, 40)
root.BorderSizePixel = 0
root.BackgroundTransparency = 0.2
root.BackgroundColor3 = Color3.new(0, 0, 0.1)
root.Font = Enum.Font.BuilderSansBold
root.TextScaled = true
root.TextColor3 = Color3.new(1, 1, 1)
root.TextXAlignment = Enum.TextXAlignment.Left

Instance.new("UICorner", root).CornerRadius = UDim.new(0, 10)
local _pad = Instance.new("UIPadding", root)
_pad.PaddingBottom = UDim.new(0, 3)
_pad.PaddingTop = UDim.new(0, 3)
_pad.PaddingLeft = UDim.new(0, 3)
_pad.PaddingRight = UDim.new(0, 3)


return {gui=tempGui, label=root}