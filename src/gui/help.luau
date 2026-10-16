local genv = (type(getgenv) == "function") and getgenv() or _G
local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
end
_RyEnv = _RyEnv or genv.Ryvora__RyvoAdmin.Env

-- Floating command list window. Built once at require time, hidden until opened.

local gui = require("gui/builder")
local format = require("gui/format")

local WINDOW_WIDTH_SCALE = 0.42
local WINDOW_WIDTH = 560 -- design width, scale fraction is derived from this
local WINDOW_HEIGHT = 420 -- base height; UIAspectRatioConstraint scales it with the width
local WINDOW_ASPECT = WINDOW_WIDTH / WINDOW_HEIGHT
local WINDOW_MIN_WIDTH = 440
local WINDOW_MAX_WIDTH = 760
local TITLE_HEIGHT = 36
local SEARCH_HEIGHT = 32
local SIDE_MARGIN = 12

local help = {}

local window = Instance.new("Frame")
window.Name = "HelpWindow"
window.Parent = gui.root
window.AnchorPoint = Vector2.new(0.5, 0.5)
window.Position = UDim2.new(0.5, 0, 0.5, 0)
-- Width follows the screen; the aspect constraint derives the height from it.
-- A non-zero base height is required or the constraint collapses the window.
window.Size = UDim2.new(WINDOW_WIDTH_SCALE, 0, 0, WINDOW_HEIGHT)
window.BackgroundColor3 = Color3.new(0, 0, 0.1)
window.BackgroundTransparency = 0.1
window.BorderSizePixel = 0
window.Visible = false
window.ZIndex = 20
gui.style(window, false)

local windowAspect = Instance.new("UIAspectRatioConstraint", window)
windowAspect.AspectRatio = WINDOW_ASPECT
windowAspect.DominantAxis = Enum.DominantAxis.Width

local windowWidth = Instance.new("UISizeConstraint", window)
windowWidth.MinSize = Vector2.new(WINDOW_MIN_WIDTH, 0)
windowWidth.MaxSize = Vector2.new(WINDOW_MAX_WIDTH, 100000)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Parent = window
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, SIDE_MARGIN, 0, 6)
title.Size = UDim2.new(1, -(SIDE_MARGIN * 2 + 36), 0, 24)
title.Font = Enum.Font.BuilderSansBold
title.TextSize = 20
title.TextColor3 = Color3.new(1, 1, 1)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "RyvoAdmin Commands"
title.ZIndex = 21

local close = Instance.new("TextButton")
close.Name = "Close"
close.Parent = window
close.AnchorPoint = Vector2.new(1, 0)
close.Position = UDim2.new(1, -SIDE_MARGIN, 0, 4)
close.Size = UDim2.new(0, 28, 0, 28)
close.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
close.BackgroundTransparency = 0.2
close.BorderSizePixel = 0
close.Text = ""
close.ZIndex = 21
gui.style(close, 5)

local closeIcon = Instance.new("ImageLabel")
closeIcon.Name = "Icon"
closeIcon.Parent = close
closeIcon.BackgroundTransparency = 1
closeIcon.Size = UDim2.new(1, 0, 1, 0)
closeIcon.Image = "rbxassetid://102326100327209"
closeIcon.ZIndex = 21

local search = Instance.new("TextBox")
search.Name = "Search"
search.Parent = window
search.Position = UDim2.new(0, SIDE_MARGIN, 0, TITLE_HEIGHT + 12)
search.Size = UDim2.new(1, -(SIDE_MARGIN * 2), 0, SEARCH_HEIGHT)
search.BackgroundColor3 = Color3.new(0, 0, 0.1)
search.BackgroundTransparency = 0.3
search.BorderSizePixel = 0
search.Font = Enum.Font.BuilderSansBold
search.TextSize = 16
search.TextColor3 = Color3.new(1, 1, 1)
search.PlaceholderText = "Search commands..."
search.PlaceholderColor3 = Color3.new(0.7, 0.7, 0.7)
search.Text = ""
search.TextXAlignment = Enum.TextXAlignment.Left
search.ClearTextOnFocus = false
search.ZIndex = 20
gui.style(search, true)

local list = Instance.new("ScrollingFrame")
list.Name = "List"
list.Parent = window
list.Position = UDim2.new(0, SIDE_MARGIN, 0, TITLE_HEIGHT + 12 + SEARCH_HEIGHT + 10)
list.Size = UDim2.new(1, -(SIDE_MARGIN * 2), 1, -(TITLE_HEIGHT + SEARCH_HEIGHT + 34))
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.ScrollBarThickness = 6
list.ZIndex = 20

local layout = Instance.new("UIListLayout")
layout.Name = "Layout"
layout.Parent = list
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 12)

local listpad = Instance.new("UIPadding")
listpad.Parent = list
listpad.PaddingTop = UDim.new(0, 6)
listpad.PaddingBottom = UDim.new(0, 6)
listpad.PaddingLeft = UDim.new(0, 6)
listpad.PaddingRight = UDim.new(0, 6)

local function clearRows()
	for _, child in ipairs(list:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
end

local function refresh()
	clearRows()

	local query = search.Text or ""
	local shown = 0

	for i, cmd in ipairs(_RyEnv.Commands) do
		if format.matchesQuery(cmd, query) then
			local row = Instance.new("TextLabel")
			row.Name = "Row"
			row.Parent = list
			row.LayoutOrder = i
			row.Size = UDim2.new(1, -8, 0, 0)
			row.AutomaticSize = Enum.AutomaticSize.Y
			row.BackgroundColor3 = Color3.new(0, 0, 0.1)
			row.BackgroundTransparency = 0.4
			row.BorderSizePixel = 0
			row.Font = Enum.Font.BuilderSansBold
			row.TextSize = 16
			row.TextColor3 = Color3.new(1, 1, 1)
			row.TextWrapped = true
			row.TextXAlignment = Enum.TextXAlignment.Left
			row.TextYAlignment = Enum.TextYAlignment.Top
			row.Text = format.formatCommand(cmd)
			row.ZIndex = 20
			gui.style(row, true)

			shown += 1
		end
	end

	if shown == 0 then
		local empty = Instance.new("TextLabel")
		empty.Name = "NoMatch"
		empty.Parent = list
		empty.Size = UDim2.new(1, 0, 0, 24)
		empty.BackgroundTransparency = 1
		empty.Font = Enum.Font.BuilderSansBold
		empty.TextSize = 16
		empty.TextColor3 = Color3.new(0.8, 0.8, 0.8)
		empty.Text = "No commands match your search."
		empty.ZIndex = 20
	end
end

function help.open(query)
	if query ~= nil then
		search.Text = tostring(query)
	end
	refresh()
	window.Visible = true
end

function help.close()
	window.Visible = false
	search:ReleaseFocus()
end

function help.isOpen()
	return window.Visible == true
end

close.MouseButton1Click:Connect(function()
	help.close()
end)

search:GetPropertyChangedSignal("Text"):Connect(function()
	if window.Visible then
		refresh()
	end
end)

help.window = window
help.list = list
help.search = search
help.refresh = refresh

return help
