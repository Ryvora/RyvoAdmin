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

-- Floating buttons: draggable, Ryvora-styled squares that toggle a command on
-- click. Created with `_RyEnv.floatingButton.new(label, hasValue)`.
--
--   local button = _RyEnv.floatingButton.new("fly", true)
--   button:SetActive(true)                 -- show + highlight (blue)
--   button:SetHighlighted(false)           -- recolor only (black), keeps visibility
--   button.value                            -- current numeric value (or nil)
--   button.onValueChange = function(v) end  -- fired when the "+" value changes
--   button.onClick = function() end         -- fired when the body is clicked
--   button:Destroy()                        -- removes the button completely
--
-- When `hasValue` is true a small "+" peeks out of the top-left corner. Pressing
-- it opens a textbox at the top of the screen where a NUMBER can be entered; the
-- value is stored, persisted and passed to onValueChange.

local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local gui = require("gui/builder")
local config = require("config")

local floatingButton = {}
floatingButton.buttons = {}

local BUTTON_SCALE = 0.1 -- of the viewport height, keeps it square
local PLUS_SCALE = 0.5 -- half of the button (peeks out of the corner)
local DRAG_THRESHOLD = 6
local MARGIN = 8
local CONFIG_KEY = "floatingButton_"

local ACTIVE_COLOR = Color3.new(0.1, 0.4, 0.9)
local INACTIVE_COLOR = Color3.new(0, 0, 0)

-- ----------------------------------------------------------------- helpers --

local function viewportSize()
	local camera = _RyEnv.Svc.Workspace.CurrentCamera
	return (camera and camera.ViewportSize) or Vector2.new(1280, 720)
end

local function screenInsets()
	local ok, top, bottom = pcall(function()
		return GuiService:GetGuiInset()
	end)

	if ok and typeof(top) == "Vector2" then
		return top, (typeof(bottom) == "Vector2") and bottom or Vector2.zero
	end

	return Vector2.zero, Vector2.zero
end

local function clampToScreen(handle, x, y)
	local viewport = viewportSize()
	local insetTop, insetBottom = screenInsets()
	local size = handle.AbsoluteSize

	if size.X <= 0 or size.Y <= 0 then
		size = Vector2.new(viewport.Y * BUTTON_SCALE, viewport.Y * BUTTON_SCALE)
	end

	local minX = MARGIN
	local maxX = math.max(minX, viewport.X - size.X - MARGIN)
	local minY = MARGIN
	local maxY = math.max(minY, viewport.Y - insetTop.Y - insetBottom.Y - size.Y - MARGIN)

	return math.clamp(x, minX, maxX), math.clamp(y, minY, maxY)
end

-- Ryvora style, but everything half transparent (stroke included).
local function styleGhost(instance)
	gui.style(instance, false)

	local stroke = instance:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Transparency = 0.5
	end
	instance.BackgroundTransparency = 0.5
	instance.TextTransparency = 0.5
end

-- ----------------------------------------------------------- value editor ---

local valueBar = Instance.new("Frame")
valueBar.Name = "FloatingButtonValue"
valueBar.Parent = gui.root
valueBar.AnchorPoint = Vector2.new(0.5, 0)
valueBar.Position = UDim2.new(0.5, 0, 0, 12)
valueBar.Size = UDim2.new(0, 240, 0, 38)
valueBar.BackgroundColor3 = Color3.new(0, 0, 0.1)
valueBar.BackgroundTransparency = 0.1
valueBar.BorderSizePixel = 0
valueBar.Visible = false
valueBar.ZIndex = 30
gui.style(valueBar)

local valueInput = Instance.new("TextBox")
valueInput.Name = "Input"
valueInput.Parent = valueBar
valueInput.Size = UDim2.new(1, 0, 1, 0)
valueInput.BackgroundTransparency = 1
valueInput.Font = Enum.Font.BuilderSansBold
valueInput.TextScaled = true
valueInput.TextColor3 = Color3.new(1, 1, 1)
valueInput.Text = ""
valueInput.PlaceholderText = "Enter a number..."
valueInput.PlaceholderColor3 = Color3.new(0.7, 0.7, 0.7)
valueInput.ClearTextOnFocus = false
valueInput.ZIndex = 30

local editing = nil

local function openValueEditor(button)
	editing = button
	valueInput.Text = (button.value ~= nil) and tostring(button.value) or ""
	valueBar.Visible = true
	valueInput:CaptureFocus()
end

local function closeValueEditor()
	valueBar.Visible = false
	editing = nil
	valueInput:ReleaseFocus()
end

valueInput.FocusLost:Connect(function(enterPressed)
	if enterPressed and editing then
		local number = tonumber(valueInput.Text)
		if number then
			editing:SetValue(number)
		end
	end
	closeValueEditor()
end)

floatingButton.valueBar = valueBar
floatingButton.valueInput = valueInput

-- ---------------------------------------------------------------- buttons ---

function floatingButton.new(label, hasValue)
	label = tostring(label)

	local self = {}
	self.label = label
	self.value = nil
	self.active = false
	self.handle = nil

	local connections = {}

	local function connect(signal, fn)
		connections[#connections + 1] = signal:Connect(fn)
	end

	local key = CONFIG_KEY .. label
	local saved = config.read(key)
	if type(saved) ~= "table" then
		saved = nil
	end

	local handle = Instance.new("TextButton")
	self.handle = handle
	handle.Name = "FloatingButton_" .. label
	handle.Parent = gui.root
	handle.AnchorPoint = Vector2.new(0, 0)
	handle.Size = UDim2.new(BUTTON_SCALE, 0, BUTTON_SCALE, 0)
	handle.SizeConstraint = Enum.SizeConstraint.RelativeYY
	handle.BackgroundColor3 = Color3.new(0, 0, 0.1)
	handle.BackgroundTransparency = 0.2
	handle.Text = label
	handle.TextColor3 = Color3.new(1, 1, 1)
	handle.TextScaled = true
	handle.Font = Enum.Font.BuilderSansBold
	handle.ZIndex = 5
	handle.Visible = false -- shown only while its command is active
	gui.style(handle, 4)

	local index = #floatingButton.buttons
	handle.Position = UDim2.new(0, 100, 0, 50 + index * 90)

	if saved and type(saved.position) == "table" then
		local x = tonumber(saved.position[1])
		local y = tonumber(saved.position[2])
		if x and y then
			x, y = clampToScreen(handle, x, y)
			handle.Position = UDim2.new(0, x, 0, y)
		end
	end

	if saved and type(saved.value) == "number" then
		self.value = saved.value
	end

	local function save()
		config.write(key, {
			position = { handle.Position.X.Offset, handle.Position.Y.Offset },
			value = self.value,
		})
	end

	function self:SetValue(number)
		self.value = number
		save()
		if type(self.onValueChange) == "function" then
			self.onValueChange(number)
		end
	end

	function self:SetActive(isActive)
		self.active = isActive and true or false
		handle.Visible = self.active
		self:SetHighlighted(self.active)
	end

	function self:SetHighlighted(isActive)
		handle.BackgroundColor3 = isActive and ACTIVE_COLOR or INACTIVE_COLOR
	end

	function self:Destroy()
		for _, connection in ipairs(connections) do
			connection:Disconnect()
		end

		for i, button in ipairs(floatingButton.buttons) do
			if button == self then
				table.remove(floatingButton.buttons, i)
				break
			end
		end

		if editing == self then
			closeValueEditor()
		end

		handle:Destroy()
		self.handle = nil
	end

	-- Drag support (position persisted on release)
	local dragging = false
	local dragMoved = false
	local dragStart = Vector2.zero
	local dragStartPos = UDim2.new()

	local function startsDrag(input)
		return input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
	end

	connect(handle.InputBegan, function(input)
		if not startsDrag(input) then
			return
		end
		dragging = true
		dragMoved = false
		dragStart = UserInputService:GetMouseLocation()
		dragStartPos = handle.Position
	end)

	connect(UserInputService.InputChanged, function()
		if not dragging then
			return
		end
		local delta = UserInputService:GetMouseLocation() - dragStart
		if math.abs(delta.X) > DRAG_THRESHOLD or math.abs(delta.Y) > DRAG_THRESHOLD then
			dragMoved = true
		end
		local x, y = clampToScreen(handle, dragStartPos.X.Offset + delta.X, dragStartPos.Y.Offset + delta.Y)
		handle.Position = UDim2.new(0, x, 0, y)
	end)

	connect(UserInputService.InputEnded, function(input)
		if not startsDrag(input) or not dragging then
			return
		end
		dragging = false
		if dragMoved then
			save()
		end
	end)

	-- Body click toggles the command (ignored when the press was a drag)
	connect(handle.MouseButton1Click, function()
		if dragMoved then
			return
		end
		if type(self.onClick) == "function" then
			self.onClick()
		end
	end)

	-- Optional "+" that opens the numeric value editor
	if hasValue then
		local plus = Instance.new("TextButton")
		plus.Name = "Plus"
		plus.Parent = handle
		plus.AnchorPoint = Vector2.new(0.5, 0.5)
		plus.Position = UDim2.new(0, 0, 0, 0)
		plus.Size = UDim2.new(PLUS_SCALE, 0, PLUS_SCALE, 0)
		plus.BackgroundColor3 = Color3.new(0, 0, 0.1)
		plus.Text = "+"
		plus.TextColor3 = Color3.new(1, 1, 1)
		plus.TextScaled = true
		plus.Font = Enum.Font.BuilderSansBold
		plus.ZIndex = handle.ZIndex + 1
		styleGhost(plus)

		connect(plus.MouseButton1Click, function()
			if dragMoved then
				return
			end
			openValueEditor(self)
		end)
	end

	floatingButton.buttons[#floatingButton.buttons + 1] = self
	return self
end

_RyEnv.floatingButton = floatingButton

return floatingButton
