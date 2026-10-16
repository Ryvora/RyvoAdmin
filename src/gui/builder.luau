local genv = (type(getgenv) == "function") and getgenv() or _G
local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
end
_RyEnv = _RyEnv or genv.Ryvora__RyvoAdmin.Env

local gui = {}

function style(instance, padding)
	-- padding: nil = 10, true = 5, false = none, number = that many pixels
	local padVal = 10
	if padding == true then
		padVal = 5
	elseif padding == false then
		padVal = 0
	elseif type(padding) == "number" then
		padVal = padding
	end

	if padVal > 0 then
		local pad = Instance.new("UIPadding", instance)
		local p = UDim.new(0, padVal)
		pad.PaddingBottom = p
		pad.PaddingTop = p
		pad.PaddingLeft = p
		pad.PaddingRight = p
	end

	local stroke = Instance.new("UIStroke", instance)
	stroke.Thickness = 3
	stroke.Color = Color3.new(0.1, 0.4, 0.9)
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local corner = Instance.new("UICorner", instance)
	corner.CornerRadius = UDim.new(0, 10)
end

gui.style = style

gui.root = Instance.new("ScreenGui")
gui.root.Parent = gethui and gethui() or game:GetService("CoreGui")
gui.root.Name = "RyvoAdmin GUI"
-- A ScreenGui created from a script defaults to ZIndexBehavior.Global, where a
-- child renders under its parent unless its ZIndex is >= the parent's. We want
-- the usual "children always render above their parent" model.
gui.root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

gui.commandBox = Instance.new("TextBox", gui.root)
gui.commandBox.Position = UDim2.new(0.5, 0, 0, 0)
gui.commandBox.AnchorPoint = Vector2.new(0.5, 0)
-- Width is scale-based so it follows the screen, height stays a fixed pixel size.
gui.commandBox.Size = UDim2.new(0.28, 0, 0, 40)
gui.commandBox.BackgroundColor3 = Color3.new(0,0,0.1)
gui.commandBox.BackgroundTransparency = 0.2
gui.commandBox.TextColor3 = Color3.new(1,1,1)
gui.commandBox.TextScaled = true
gui.commandBox.TextXAlignment = Enum.TextXAlignment.Left
gui.commandBox.Text = ""
gui.commandBox.Font = Enum.Font.BuilderSansBold
gui.commandBox.PlaceholderText = "Enter Command..."
style(gui.commandBox)

local commandConstraint = Instance.new("UISizeConstraint", gui.commandBox)
commandConstraint.MinSize = Vector2.new(220, 36)
commandConstraint.MaxSize = Vector2.new(560, 48)


gui.autocompleteContain = Instance.new("Frame", gui.root)
gui.autocompleteContain.Position = UDim2.new(0.5, 0, 0, 50)
gui.autocompleteContain.AnchorPoint = Vector2.new(0.5, 0)
gui.autocompleteContain.Size = UDim2.new(0.28, 0, 0, 40*8) -- Arbitrary element limit
gui.autocompleteContain.BackgroundColor3 = Color3.new(1,0,0) -- Debugging: Red
gui.autocompleteContain.BackgroundTransparency = 1 -- Remove for Debugging

-- Match the command box width so the drop-down lines up with the input.
local autocompleteConstraint = Instance.new("UISizeConstraint", gui.autocompleteContain)
autocompleteConstraint.MinSize = Vector2.new(220, 0)
autocompleteConstraint.MaxSize = Vector2.new(560, 100000)

local autocompleteList = Instance.new("UIListLayout", gui.autocompleteContain)
autocompleteList.Padding = UDim.new(0, 10)

function gui.addAutocomplete(text)
	local ui = Instance.new("TextLabel", gui.autocompleteContain)
	ui.BackgroundTransparency = 0.5
	ui.Size = UDim2.new(1, 0, 0, 30)
	ui.BackgroundColor3 = Color3.new(0,0,0.1)
	ui.TextColor3 = Color3.new(1,1,1)
	ui.TextScaled = true
	ui.Text = text
	ui.Font = Enum.Font.BuilderSansBold
	ui.TextXAlignment = Enum.TextXAlignment.Left
	style(ui, true)
end

gui.floatHandle = Instance.new("TextButton", gui.root)
gui.floatHandle.Text = ""
gui.floatHandle.Position = UDim2.new(0, 100, 0, 50)
gui.floatHandle.Size = UDim2.new(0.05, 0, 0.05, 0)
gui.floatHandle.SizeConstraint = Enum.SizeConstraint.RelativeYY
gui.floatHandle.BackgroundColor3 = Color3.new(0, 0, 0.1)
gui.floatHandle.BackgroundTransparency = 0.5

local image = Instance.new("ImageLabel", gui.floatHandle)
image.Size = UDim2.new(1, 0, 1, 0)
image.BackgroundTransparency = 1
image.Image = "rbxassetid://135964688013914"

Instance.new("UICorner", gui.floatHandle).CornerRadius = UDim.new(1,0)
local pad = Instance.new("UIPadding", gui.floatHandle)
local padding = UDim.new(0, 7)
pad.PaddingBottom = padding
pad.PaddingTop = padding
pad.PaddingLeft = padding
pad.PaddingRight = padding


return gui