local genv = (type(getgenv) == "function") and getgenv() or _G
local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
end
_RyEnv = _RyEnv or genv.Ryvora__RyvoAdmin.Env

-- Flight: toggled by the "fly" floating button (or the fly/unfly commands).
--
-- Horizontal direction comes from Humanoid.MoveDirection so it works on both
-- keyboard and touch (mobile thumbstick). Vertical direction comes from the
-- camera's up/down pitch, so looking up flies you up and looking down flies you
-- down. Speed is the floating button's value.

require("gui/floatingButton")

local Run = _RyEnv.Svc.Run
local Workspace = _RyEnv.Svc.Workspace

local button
local active = false
local speed = 50

local bodyVelocity
local bodyGyro
local beat

local function stop()
	if beat then
		beat:Disconnect()
		beat = nil
	end
	if bodyVelocity then
		bodyVelocity:Destroy()
		bodyVelocity = nil
	end
	if bodyGyro then
		bodyGyro:Destroy()
		bodyGyro = nil
	end
end

local function disable()
	stop()
	active = false
end

local function enable()
	if active then
		return true
	end

	local humanoid = _RyEnv.Player.getHumanoid()
	local root = _RyEnv.Player.getCharacterRoot()

	if not humanoid or not root then
		if _RyEnv.notify then
			_RyEnv.notify("Fly: you need a character to fly!", 4)
		end
		return false
	end

	active = true

	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Velocity = Vector3.zero
	bodyVelocity.Parent = root

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	bodyGyro.P = 3000
	bodyGyro.D = 500
	bodyGyro.Parent = root

	beat = Run.Heartbeat:Connect(function()
		if not root.Parent or not humanoid.Parent then
			disable()
			return
		end

		local camera = Workspace.CurrentCamera
		local move = humanoid.MoveDirection

		if camera then
			-- Face where we look.
			bodyGyro.CFrame = CFrame.new(root.Position, root.Position + camera.CFrame.LookVector)
		end

		if move.Magnitude > 0 then
			-- Move wherever we look, wherever we move; vertical follows camera pitch.
			local direction = Vector3.new(move.X, 0, move.Z)
			if camera then
				direction = direction + Vector3.new(0, camera.CFrame.LookVector.Y, 0)
			end
			if direction.Magnitude > 0 then
				direction = direction.Unit
			end
			bodyVelocity.Velocity = direction * speed
		else
			-- Not moving: stay put, never drift up or down.
			bodyVelocity.Velocity = Vector3.zero
		end
	end)

	return true
end

button = _RyEnv.floatingButton.new("Fly", true)
if type(button.value) == "number" then
	speed = button.value
end
button.onValueChange = function(newValue)
	speed = newValue
end
button.onClick = function()
	-- Toggling the button only toggles flight; it never hides the button itself.
	if active then
		disable()
	else
		enable()
	end
	button:SetHighlighted(active)
end

_RyEnv.registerCommand("fly", { "fl" }, {}, function()
	if enable() and button then
		button:SetActive(true)
	end
end)

_RyEnv.registerCommand("unfly", { "stopfly" }, {}, function()
	disable()
	if button then
		button:SetActive(false)
	end
end)
