local genv = (type(getgenv) == "function") and getgenv() or _G
local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
end
_RyEnv = _RyEnv or genv.Ryvora__RyvoAdmin.Env

local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

local gui = require("gui/builder")
local config = require("config")
local format = require("gui/format")

-- Hide everything by default
gui.commandBox.Visible = false
gui.autocompleteContain.Visible = false

-- Only clear autocomplete when we actually need to
local function clearAutocomplete()
	for _, child in ipairs(gui.autocompleteContain:GetChildren()) do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
end

local function refreshAutocomplete()
	clearAutocomplete()

	local query = gui.commandBox.Text or ""
	-- Only take the first word as the command query, before a space
	local firstWord = string.match(query, "^%S*") or ""

	if firstWord == "" then
		gui.autocompleteContain.Visible = false
		return
	end

	local shown = 0
	for _, cmd in ipairs(_RyEnv.Commands) do
		if format.matchesQuery(cmd, firstWord) then
			gui.addAutocomplete(format.formatCommand(cmd))
			shown += 1
			if shown >= 8 then break end
		end
	end

	gui.autocompleteContain.Visible = shown > 0
end

local function openGUI()
	gui.commandBox.Visible = true
	gui.commandBox.Text = ""
	clearAutocomplete()
	gui.autocompleteContain.Visible = false
	gui.commandBox:CaptureFocus()
end

local function closeGUI()
	gui.commandBox.Visible = false
	gui.autocompleteContain.Visible = false
	gui.commandBox:ReleaseFocus()
	clearAutocomplete()
end

local function viewportSize()
	local camera = workspace.CurrentCamera
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

local function clampToScreen(x, y)
	local viewport = viewportSize()
	local insetTop, insetBottom = screenInsets()
	local size = gui.floatHandle.AbsoluteSize

	if size.X <= 0 or size.Y <= 0 then
		-- Layout has not resolved yet, the handle is 5% of the viewport height
		size = Vector2.new(viewport.Y * 0.05, viewport.Y * 0.05)
	end

	local margin = 8
	local minX = margin
	local maxX = math.max(minX, viewport.X - size.X - margin)
	local minY = margin
	local maxY = math.max(minY, viewport.Y - insetTop.Y - insetBottom.Y - size.Y - margin)

	return math.clamp(x, minX, maxX), math.clamp(y, minY, maxY)
end

local function saveFloatPosition()
	local position = gui.floatHandle.Position

	config.write("floatingButton", {
		position = { position.X.Offset, position.Y.Offset },
	})
end

local function loadFloatPosition()
	local saved = config.read("floatingButton")
	if type(saved) ~= "table" or type(saved.position) ~= "table" then
		return
	end

	local x = tonumber(saved.position[1])
	local y = tonumber(saved.position[2])
	if not x or not y then
		return
	end

	x, y = clampToScreen(x, y)
	gui.floatHandle.Position = UDim2.new(0, x, 0, y)
end

loadFloatPosition()

-- Float handle: drag to move, position is persisted on release
local DRAG_THRESHOLD = 6

local dragging = false
local dragMoved = false
local dragStart = Vector2.zero
local dragStartPos = UDim2.new()

local function startsDrag(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

gui.floatHandle.InputBegan:Connect(function(input)
	if not startsDrag(input) then
		return
	end

	dragging = true
	dragMoved = false
	dragStart = UserInputService:GetMouseLocation()
	dragStartPos = gui.floatHandle.Position
end)

UserInputService.InputChanged:Connect(function()
	if not dragging then
		return
	end

	local delta = UserInputService:GetMouseLocation() - dragStart

	if math.abs(delta.X) > DRAG_THRESHOLD or math.abs(delta.Y) > DRAG_THRESHOLD then
		dragMoved = true
	end

	local x, y = clampToScreen(dragStartPos.X.Offset + delta.X, dragStartPos.Y.Offset + delta.Y)
	gui.floatHandle.Position = UDim2.new(0, x, 0, y)
end)

UserInputService.InputEnded:Connect(function(input)
	if not startsDrag(input) or not dragging then
		return
	end

	dragging = false

	if dragMoved then
		saveFloatPosition()
	end
end)

-- Float handle behavior: toggle the command box (unless it was a drag)
gui.floatHandle.MouseButton1Click:Connect(function()
	if dragMoved then
		return
	end

	if gui.commandBox.Visible then
		closeGUI()
	else
		openGUI()
	end
end)

-- Focus lost -> close
gui.commandBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local text = gui.commandBox.Text or ""
		if text ~= "" then
			-- Parse: first token = command, rest = args
			local parts = {}
			for token in string.gmatch(text, "%S+") do
				table.insert(parts, token)
			end

			if #parts > 0 then
				local cmdName = table.remove(parts, 1)
				pcall(function()
					_RyEnv.executeCommand(cmdName, table.unpack(parts))
				end)
			end
		end
	end
	closeGUI()
end)

-- Live autocomplete as they type
gui.commandBox:GetPropertyChangedSignal("Text"):Connect(function()
	if not gui.commandBox.Visible then return end
	refreshAutocomplete()
end)

return gui