local genv = (type(getgenv) == "function") and getgenv() or _G
local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/Ryvora/RyvoAdmin/refs/heads/main/"..mdl..".luau"))()
end
_RyEnv = _RyEnv or genv.Ryvora__RyvoAdmin.Env

local gui = require("gui/builder")

local TweenService = game:GetService("TweenService")

local CONTAINER_WIDTH_SCALE = 0.24
local CONTAINER_MIN_WIDTH = 260
local CONTAINER_MAX_WIDTH = 420
local CONTAINER_MARGIN = 12
local MAX_VISIBLE = 8
local FADE_IN_TIME = 0.2
local FADE_OUT_TIME = 0.6
local DEFAULT_TIMEOUT = 4

-- Top right corner of the screen, newest notification stacked on top
local container = Instance.new("Frame")
container.Name = "Notifications"
container.Parent = gui.root
container.AnchorPoint = Vector2.new(1, 0)
container.Position = UDim2.new(1, -CONTAINER_MARGIN, 0, CONTAINER_MARGIN)
-- Width follows the screen, the column itself fills the available height.
container.Size = UDim2.new(CONTAINER_WIDTH_SCALE, 0, 1, -CONTAINER_MARGIN * 2)
container.BackgroundTransparency = 1
container.BorderSizePixel = 0
container.ZIndex = 10

local widthConstraint = Instance.new("UISizeConstraint", container)
widthConstraint.MinSize = Vector2.new(CONTAINER_MIN_WIDTH, 0)
widthConstraint.MaxSize = Vector2.new(CONTAINER_MAX_WIDTH, 100000)

local layout = Instance.new("UIListLayout")
layout.Name = "Layout"
layout.Parent = container
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Padding = UDim.new(0, 8)

local active = {}
local nextOrder = 0

local function tween(instance, goal, duration)
	if instance.Parent == nil then
		return nil
	end

	local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local handle = TweenService:Create(instance, info, goal)
	handle:Play()
	return handle
end

-- transparent = true fades out, false fades in
local function fade(item, transparent, duration)
	if item.Parent == nil then
		return
	end

	local background = transparent and 1 or 0.2
	local foreground = transparent and 1 or 0

	tween(item, { BackgroundTransparency = background }, duration)

	for _, child in ipairs(item:GetDescendants()) do
		if child:IsA("TextLabel") then
			tween(child, {
				TextTransparency = foreground,
				TextStrokeTransparency = foreground,
			}, duration)
		elseif child:IsA("UIStroke") then
			tween(child, { Transparency = foreground }, duration)
		end
	end
end

local function dismiss(item, duration)
	fade(item, true, duration)

	task.delay(duration, function()
		local index = table.find(active, item)
		if index then
			table.remove(active, index)
		end
		if item.Parent then
			item:Destroy()
		end
	end)
end

local function createNotification(message, timeout)
	local text = tostring(message == nil and "" or message)

	local life = tonumber(timeout)
	if life == nil then
		life = DEFAULT_TIMEOUT
	elseif life < 0 then
		life = 0
	end

	nextOrder -= 1

	local item = Instance.new("Frame")
	item.Name = "Notification"
	item.Parent = container
	item.Size = UDim2.new(1, 0, 0, 0)
	item.AutomaticSize = Enum.AutomaticSize.Y
	item.BackgroundColor3 = Color3.new(0, 0, 0.1)
	item.BackgroundTransparency = 1
	item.BorderSizePixel = 0
	item.ZIndex = 10
	item.LayoutOrder = nextOrder

	gui.style(item, true)

	local stroke = item:FindFirstChildOfClass("UIStroke")
	if stroke then
		stroke.Transparency = 1
	end

	local label = Instance.new("TextLabel")
	label.Name = "Message"
	label.Parent = item
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, 0, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.Font = Enum.Font.BuilderSansBold
	label.TextSize = 18
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextWrapped = true
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.TextTransparency = 1
	label.Text = text
	label.ZIndex = 10

	table.insert(active, 1, item)
	while #active > MAX_VISIBLE do
		local oldest = table.remove(active)
		if oldest then
			oldest:Destroy()
		end
	end

	fade(item, false, FADE_IN_TIME)

	if life <= 0 then
		dismiss(item, FADE_OUT_TIME)
	else
		task.delay(life, function()
			if item.Parent == nil then
				return
			end
			dismiss(item, FADE_OUT_TIME)
		end)
	end

	return item
end

_RyEnv.notify = createNotification

local genv = (type(getgenv) == "function") and getgenv() or nil
if genv and type(genv.Ryvora__RyvoAdmin) == "table" then
	genv.Ryvora__RyvoAdmin.Notify = _RyEnv.notify
end

return {
	container = container,
	create = createNotification,
}
