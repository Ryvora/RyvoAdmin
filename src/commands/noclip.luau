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

-- Noclip: toggled by its own floating button (or the noclip/clip commands).
-- While active a Heartbeat keeps every BasePart non-collidable, remembering the
-- original CanCollide values so they can be restored on disable.

require("gui/floatingButton")

local info = {}
local beat = nil
local active = false
local button

local function setClip()
	local chr = _RyEnv.Player.getCharacter()
	if not chr then
		return
	end

	for _, part in pairs(chr:GetDescendants()) do
		if part:IsA("BasePart") then
			if info[part] == nil then
				info[part] = part.CanCollide
			end
			part.CanCollide = false
		end
	end
end

local function restoreClip()
	for part, original in pairs(info) do
		if part.Parent then
			part.CanCollide = original
		end
	end
	info = {}
end

local function enable()
	if active then
		return
	end

	active = true
	setClip()
	if beat then
		beat:Disconnect()
	end
	beat = _RyEnv.Svc.Run.Heartbeat:Connect(setClip)
end

local function disable()
	if beat then
		beat:Disconnect()
		beat = nil
	end
	restoreClip()
	active = false
end

button = _RyEnv.floatingButton.new("NoClip", false)
button.onClick = function()
	-- Toggling the button only toggles noclip; it never hides the button itself.
	if active then
		disable()
	else
		enable()
	end
	button:SetHighlighted(active)
end

_RyEnv.registerCommand("noclip", { "nc", "phase" }, {}, function()
	enable()
	if button then
		button:SetActive(true)
	end
end)

_RyEnv.registerCommand("clip", { "unnc", "unnoclip", "unphase" }, {}, function()
	disable()
	if button then
		button:SetActive(false)
	end
end)
