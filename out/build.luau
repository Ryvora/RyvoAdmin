local __RYVORA_BUNDLER_ENV = {
    fakeScripts = {
        ["commands/_registry"] = function(__RYVORA_BUNDLER_ENV)
        local genv = (type(getgenv) == "function") and getgenv() or _G
        local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
        	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
        end
        __RYVORA_BUNDLER_ENV._G =  __RYVORA_BUNDLER_ENV._G or genv.Ryvora__RyvoAdmin.Env
        
        local commands = {
        	"fly",
        	"noclip",
        	"help",
        	"copypos",
        	"walkspeed",
        	"desync"
        }
        
        -- If there's any command that has a subcommand, e.g. fly & unfly (allows counting accurately!)
        local extras = {
        	"unfly",
        	"clip",
        	"copycframe",
        	"unwalkspeed",
        	"undesync", 
        	"bringdesync",
        	"todesync"
        }
        
        -- CODE FROM HERE; DONT EDIT IT! --
        function __RYVORA_BUNDLER_ENV._G.registerCommand(command, aliases, argsInfo, callback)
        	table.insert(__RYVORA_BUNDLER_ENV._G.Commands, {
        		Command=command,
        		Aliases=aliases,
        		ArgsInfo=argsInfo,
        		Callback=callback
        	})
        end
        
        
        
        local tempGui = __RYVORA_BUNDLER_ENV.require("tempgui")
        local failedToLoad = 0
        for i, cmd in pairs(commands) do
        	-- TODO: Print Errors
        	tempGui.label.Text = "Registering Commands... (" .. i .. "/" .. #commands+#extras .. ")"
        	
        	local success, result = pcall(function()
        		__RYVORA_BUNDLER_ENV.require("commands/" .. cmd)
        	end)
        	if not success then
        		failedToLoad = failedToLoad + 1
        		warn("RyvoAdmin Error, Failed to register command: " .. tostring(cmd) .. ", because of: " .. tostring(result))
        	end
        end
        
        
        end,
        ["commands/copypos"] = function(__RYVORA_BUNDLER_ENV)
        local genv = (type(getgenv) == "function") and getgenv() or _G
        local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
        	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
        end
        __RYVORA_BUNDLER_ENV._G =  __RYVORA_BUNDLER_ENV._G or genv.Ryvora__RyvoAdmin.Env
        
        __RYVORA_BUNDLER_ENV._G.registerCommand("copypos", { "cpos" }, {}, function()
        	local root = __RYVORA_BUNDLER_ENV._G.Player.getCharacterRoot()
        	if not setclipboard then
        		__RYVORA_BUNDLER_ENV._G.notify("setclipboard is not supported by " .. __RYVORA_BUNDLER_ENV._G.Identity, 3)
        		return
        	end
        	setclipboard("Vector3.new(" .. tostring(root.CFrame.Position) .. ")")
        	__RYVORA_BUNDLER_ENV._G.notify("Successfully copied to clipboard!", 1)
        end)
        
        __RYVORA_BUNDLER_ENV._G.registerCommand("copycframe", { "ccf" }, {}, function()
        	local root = __RYVORA_BUNDLER_ENV._G.Player.getCharacterRoot()
        	if not setclipboard then
        		__RYVORA_BUNDLER_ENV._G.notify("setclipboard is not supported by " .. __RYVORA_BUNDLER_ENV._G.Identity, 3)
        		return
        	end
        	setclipboard("CFrame.new(" .. tostring(root.CFrame) .. ")")
        	__RYVORA_BUNDLER_ENV._G.notify("Successfully copied to clipboard!", 1)
        end)
        
        end,
        ["commands/desync"] = function(__RYVORA_BUNDLER_ENV)
        local genv = (type(getgenv) == "function") and getgenv() or _G
        local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
        	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
        end
        __RYVORA_BUNDLER_ENV._G =  __RYVORA_BUNDLER_ENV._G or genv.Ryvora__RyvoAdmin.Env
        
        local Desync = __RYVORA_BUNDLER_ENV._G.RyvoraGet("Desync.luau")
        
        __RYVORA_BUNDLER_ENV._G.registerCommand("desync", { }, {}, function()
        	Desync.start()
        end)
        
        __RYVORA_BUNDLER_ENV._G.registerCommand("undesync", { "nodesync" }, {}, function()
        	Desync.stop()
        end)
        
        __RYVORA_BUNDLER_ENV._G.registerCommand("bringdesync", { }, {}, function()
        	local clonePrim = Desync.clone:FindFirstChild("HumanoidRootPart") or Desync.clone.PrimaryPart
        	Desync.setOrigPosition(clonePrim.CFrame)
        end)
        
        __RYVORA_BUNDLER_ENV._G.registerCommand("todesync", { }, {}, function()
        	local clonePrim = Desync.clone:FindFirstChild("HumanoidRootPart") or Desync.clone.PrimaryPart
        	local origPrim = Desync.origChar:FindFirstChild("HumanoidRootPart") or Desync.origChar.PrimaryPart
        	clonePrim.CFrame = origPrim.CFrame
        end)
        
        
        end,
        ["commands/fly"] = function(__RYVORA_BUNDLER_ENV)
        local genv = (type(getgenv) == "function") and getgenv() or _G
        local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
        	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
        end
        __RYVORA_BUNDLER_ENV._G =  __RYVORA_BUNDLER_ENV._G or genv.Ryvora__RyvoAdmin.Env
        
        -- Flight: toggled by the "fly" floating button (or the fly/unfly commands).
        --
        -- Horizontal direction comes from Humanoid.MoveDirection so it works on both
        -- keyboard and touch (mobile thumbstick). Vertical direction comes from the
        -- camera's up/down pitch, so looking up flies you up and looking down flies you
        -- down. Speed is the floating button's value.
        
        __RYVORA_BUNDLER_ENV.require("gui/floatingButton")
        
        local Run = __RYVORA_BUNDLER_ENV._G.Svc.Run
        local Workspace = __RYVORA_BUNDLER_ENV._G.Svc.Workspace
        
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
        
        	local humanoid = __RYVORA_BUNDLER_ENV._G.Player.getHumanoid()
        	local root = __RYVORA_BUNDLER_ENV._G.Player.getCharacterRoot()
        
        	if not humanoid or not root then
        		if __RYVORA_BUNDLER_ENV._G.notify then
        			__RYVORA_BUNDLER_ENV._G.notify("Fly: you need a character to fly!", 4)
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
        
        button = __RYVORA_BUNDLER_ENV._G.floatingButton.new("Fly", true)
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
        
        __RYVORA_BUNDLER_ENV._G.registerCommand("fly", { "fl" }, {}, function()
        	if enable() and button then
        		button:SetActive(true)
        	end
        end)
        
        __RYVORA_BUNDLER_ENV._G.registerCommand("unfly", { "stopfly" }, {}, function()
        	disable()
        	if button then
        		button:SetActive(false)
        	end
        end)
        
        end,
        ["commands/help"] = function(__RYVORA_BUNDLER_ENV)
        local genv = (type(getgenv) == "function") and getgenv() or _G
        local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
        	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
        end
        __RYVORA_BUNDLER_ENV._G =  __RYVORA_BUNDLER_ENV._G or genv.Ryvora__RyvoAdmin.Env
        
        local helpGui = __RYVORA_BUNDLER_ENV.require("gui/help")
        
        __RYVORA_BUNDLER_ENV._G.registerCommand("help", { "commands", "cmds" }, {
        	{ name = "query", type = "string", required = false },
        }, function(query)
        	if query ~= nil and query ~= "" then
        		helpGui.open(query)
        	else
        		helpGui.open()
        	end
        end)
        
        end,
        ["commands/noclip"] = function(__RYVORA_BUNDLER_ENV)
        local genv = (type(getgenv) == "function") and getgenv() or _G
        local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
        	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
        end
        __RYVORA_BUNDLER_ENV._G =  __RYVORA_BUNDLER_ENV._G or genv.Ryvora__RyvoAdmin.Env
        
        -- Noclip: toggled by its own floating button (or the noclip/clip commands).
        -- While active a Heartbeat keeps every BasePart non-collidable, remembering the
        -- original CanCollide values so they can be restored on disable.
        
        __RYVORA_BUNDLER_ENV.require("gui/floatingButton")
        
        local info = {}
        local beat = nil
        local active = false
        local button
        
        local function setClip()
        	local chr = __RYVORA_BUNDLER_ENV._G.Player.getCharacter()
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
        	beat = __RYVORA_BUNDLER_ENV._G.Svc.Run.Heartbeat:Connect(setClip)
        end
        
        local function disable()
        	if beat then
        		beat:Disconnect()
        		beat = nil
        	end
        	restoreClip()
        	active = false
        end
        
        button = __RYVORA_BUNDLER_ENV._G.floatingButton.new("NoClip", false)
        button.onClick = function()
        	-- Toggling the button only toggles noclip; it never hides the button itself.
        	if active then
        		disable()
        	else
        		enable()
        	end
        	button:SetHighlighted(active)
        end
        
        __RYVORA_BUNDLER_ENV._G.registerCommand("noclip", { "nc", "phase" }, {}, function()
        	enable()
        	if button then
        		button:SetActive(true)
        	end
        end)
        
        __RYVORA_BUNDLER_ENV._G.registerCommand("clip", { "unnc", "unnoclip", "unphase" }, {}, function()
        	disable()
        	if button then
        		button:SetActive(false)
        	end
        end)
        
        end,
        ["commands/walkspeed"] = function(__RYVORA_BUNDLER_ENV)
        local genv = (type(getgenv) == "function") and getgenv() or _G
        local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
        	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
        end
        __RYVORA_BUNDLER_ENV._G =  __RYVORA_BUNDLER_ENV._G or genv.Ryvora__RyvoAdmin.Env
        
        local beat = nil
        local speed = 16
        
        local function applySpeed()
        	local hum = __RYVORA_BUNDLER_ENV._G.Player.getHumanoid()
        	if hum then
        		hum.WalkSpeed = speed
        	end
        end
        
        __RYVORA_BUNDLER_ENV._G.registerCommand("walkspeed", { "ws", "speed" }, {
        	{ name = "value", required = true, type = "number" },
        }, function(value)
        	speed = value
        	applySpeed()
        
        	if not beat then
        		beat = __RYVORA_BUNDLER_ENV._G.Svc.Run.Heartbeat:Connect(applySpeed)
        	end
        end)
        
        __RYVORA_BUNDLER_ENV._G.registerCommand("unwalkspeed", { "unws", "unspeed" }, {}, function()
        	speed = 16
        	if beat then
        		beat:Disconnect()
        		beat = nil
        	end
        	applySpeed()
        end)
        
        end,
        ["config"] = function(__RYVORA_BUNDLER_ENV)
        local genv = (type(getgenv) == "function") and getgenv() or _G
        local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
        	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
        end
        __RYVORA_BUNDLER_ENV._G =  __RYVORA_BUNDLER_ENV._G or genv.Ryvora__RyvoAdmin.Env
        
        -- Key/value config store backed by json files next to the script.
        -- Every write() is flushed to disk immediately, so nothing is ever kept
        -- in memory only. If you mutate a table returned by read(), call save(key)
        -- to persist it.
        
        local HttpService = game:GetService("HttpService")
        
        local FILE_PREFIX = "RyvoAdmin_"
        local FILE_SUFFIX = ".json"
        
        local config = {}
        local cache = {}
        
        local function fileName(key)
        	local safe = string.gsub(tostring(key), "[^%w_%-]", "_")
        	return FILE_PREFIX .. safe .. FILE_SUFFIX
        end
        
        local function directGlobal(name)
        	-- Reading an undefined global yields nil (non-strict Luau), so this is safe.
        	if name == "writefile" then
        		return writefile
        	elseif name == "readfile" then
        		return readfile
        	elseif name == "appendfile" then
        		return appendfile
        	elseif name == "isfile" then
        		return isfile
        	elseif name == "listfiles" then
        		return listfiles
        	elseif name == "makefolder" then
        		return makefolder
        	end
        	return nil
        end
        
        local function executorFunction(name)
        	-- 1) Directly named executor globals are the canonical ones.
        	local direct = directGlobal(name)
        	if type(direct) == "function" then
        		return direct
        	end
        
        	-- 2) The executor's global environment (getgenv()).
        	if type(getgenv) == "function" then
        		local ok, env = pcall(getgenv)
        		if ok and type(env) == "table" and type(env[name]) == "function" then
        			return env[name]
        		end
        	end
        
        	-- 3) The shared _G table.
        	if type(_G) == "table" and type(_G[name]) == "function" then
        		return _G[name]
        	end
        
        	return nil
        end
        
        function config.read(key)
        	key = tostring(key)
        
        	if cache[key] ~= nil then
        		return cache[key]
        	end
        
        	local name = fileName(key)
        	local value = {}
        	local readFile = executorFunction("readfile")
        
        	if readFile then
        		local ok, contents = pcall(readFile, name)
        		if ok and type(contents) == "string" and contents ~= "" then
        			local decodedOk, decoded = pcall(function()
        				return HttpService:JSONDecode(contents)
        			end)
        
        			if decodedOk and type(decoded) == "table" then
        				value = decoded
        			else
        				warn("[RyvoAdmin] config: could not decode " .. name .. ", falling back to defaults")
        			end
        		end
        	end
        
        	cache[key] = value
        	return value
        end
        
        function config.write(key, value)
        	key = tostring(key)
        	cache[key] = value
        
        	local name = fileName(key)
        	local writeFile = executorFunction("writefile")
        
        	if not writeFile then
        		warn("[RyvoAdmin] config: writefile is unavailable, " .. name .. " was not saved")
        		return false
        	end
        
        	local encodedOk, encoded = pcall(function()
        		return HttpService:JSONEncode(value)
        	end)
        
        	if not encodedOk then
        		warn("[RyvoAdmin] config: could not encode " .. name .. ": " .. tostring(encoded))
        		return false
        	end
        
        	local wroteOk, err = pcall(writeFile, name, encoded)
        	if not wroteOk then
        		warn("[RyvoAdmin] config: failed to write " .. name .. ": " .. tostring(err))
        		return false
        	end
        
        	return true
        end
        
        function config.save(key)
        	key = tostring(key)
        
        	if cache[key] == nil then
        		return false
        	end
        
        	return config.write(key, cache[key])
        end
        
        __RYVORA_BUNDLER_ENV._G.config = config
        
        return config
        
        end,
        ["gui/builder"] = function(__RYVORA_BUNDLER_ENV)
        local genv = (type(getgenv) == "function") and getgenv() or _G
        local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
        	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
        end
        __RYVORA_BUNDLER_ENV._G =  __RYVORA_BUNDLER_ENV._G or genv.Ryvora__RyvoAdmin.Env
        
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
        end,
        ["gui/floatingButton"] = function(__RYVORA_BUNDLER_ENV)
        local genv = (type(getgenv) == "function") and getgenv() or _G
        local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
        	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
        end
        __RYVORA_BUNDLER_ENV._G =  __RYVORA_BUNDLER_ENV._G or genv.Ryvora__RyvoAdmin.Env
        
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
        
        local gui = __RYVORA_BUNDLER_ENV.require("gui/builder")
        local config = __RYVORA_BUNDLER_ENV.require("config")
        
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
        	local camera = __RYVORA_BUNDLER_ENV._G.Svc.Workspace.CurrentCamera
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
        
        __RYVORA_BUNDLER_ENV._G.floatingButton = floatingButton
        
        return floatingButton
        
        end,
        ["gui/format"] = function(__RYVORA_BUNDLER_ENV)
        local genv = (type(getgenv) == "function") and getgenv() or _G
        local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
        	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
        end
        __RYVORA_BUNDLER_ENV._G =  __RYVORA_BUNDLER_ENV._G or genv.Ryvora__RyvoAdmin.Env
        
        -- Shared command display/matching helpers used by the autocomplete and the help window.
        
        local format = {}
        
        -- Format argsInfo into "<required> [optional]" tokens
        function format.formatArgs(argsInfo)
        	if not argsInfo or #argsInfo == 0 then
        		return ""
        	end
        
        	-- Stable sort: required first, preserving original order within groups
        	local ordered = {}
        	for i, v in ipairs(argsInfo) do
        		ordered[i] = { name = v.name or v, info = v, index = i }
        	end
        	table.sort(ordered, function(a, b)
        		local ar = a.info and a.info.required and true or false
        		local br = b.info and b.info.required and true or false
        		if ar ~= br then return ar end
        		return a.index < b.index
        	end)
        
        	local parts = {}
        	for _, entry in ipairs(ordered) do
        		local info = entry.info
        		local name = entry.name
        		local required = info and info.required or false
        		local argType = info and info.type
        
        		local token
        		if argType and argType ~= name then
        			token = name .. "(" .. argType .. ")"
        		else
        			token = name
        		end
        
        		if required then
        			table.insert(parts, "<" .. token .. ">")
        		else
        			table.insert(parts, "[" .. token .. "]")
        		end
        	end
        
        	return " " .. table.concat(parts, " ")
        end
        
        -- "a/b" style alias list, or "" when the command has no aliases
        function format.formatAliases(cmd)
        	if not cmd.Aliases or #cmd.Aliases == 0 then
        		return ""
        	end
        	return table.concat(cmd.Aliases, "/")
        end
        
        -- Build the display string for a command
        function format.formatCommand(cmd)
        	local aliases = format.formatAliases(cmd)
        	local alternatives = ""
        	if aliases ~= "" then
        		alternatives = " [" .. aliases .. "]"
        	end
        	return cmd.Command .. alternatives .. format.formatArgs(cmd.ArgsInfo)
        end
        
        -- Case-insensitive prefix/substring match against command name + aliases
        function format.matchesQuery(cmd, query)
        	query = string.lower(query)
        	if query == "" then return true end
        
        	if string.find(string.lower(cmd.Command), query, 1, true) then
        		return true
        	end
        	if cmd.Aliases then
        		for _, alias in ipairs(cmd.Aliases) do
        			if string.find(string.lower(alias), query, 1, true) then
        				return true
        			end
        		end
        	end
        	return false
        end
        
        return format
        
        end,
        ["gui/help"] = function(__RYVORA_BUNDLER_ENV)
        local genv = (type(getgenv) == "function") and getgenv() or _G
        local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
        	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
        end
        __RYVORA_BUNDLER_ENV._G =  __RYVORA_BUNDLER_ENV._G or genv.Ryvora__RyvoAdmin.Env
        
        -- Floating command list window. Built once at require time, hidden until opened.
        
        local gui = __RYVORA_BUNDLER_ENV.require("gui/builder")
        local format = __RYVORA_BUNDLER_ENV.require("gui/format")
        
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
        
        	for i, cmd in ipairs(__RYVORA_BUNDLER_ENV._G.Commands) do
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
        
        end,
        ["gui/impl"] = function(__RYVORA_BUNDLER_ENV)
        local genv = (type(getgenv) == "function") and getgenv() or _G
        local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
        	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
        end
        __RYVORA_BUNDLER_ENV._G =  __RYVORA_BUNDLER_ENV._G or genv.Ryvora__RyvoAdmin.Env
        
        local UserInputService = game:GetService("UserInputService")
        local GuiService = game:GetService("GuiService")
        
        local gui = __RYVORA_BUNDLER_ENV.require("gui/builder")
        local config = __RYVORA_BUNDLER_ENV.require("config")
        local format = __RYVORA_BUNDLER_ENV.require("gui/format")
        
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
        	for _, cmd in ipairs(__RYVORA_BUNDLER_ENV._G.Commands) do
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
        					__RYVORA_BUNDLER_ENV._G.executeCommand(cmdName, table.unpack(parts))
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
        end,
        ["gui/notifications"] = function(__RYVORA_BUNDLER_ENV)
        local genv = (type(getgenv) == "function") and getgenv() or _G
        local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
        	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
        end
        __RYVORA_BUNDLER_ENV._G =  __RYVORA_BUNDLER_ENV._G or genv.Ryvora__RyvoAdmin.Env
        
        local gui = __RYVORA_BUNDLER_ENV.require("gui/builder")
        
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
        
        __RYVORA_BUNDLER_ENV._G.notify = createNotification
        
        local genv = (type(getgenv) == "function") and getgenv() or nil
        if genv and type(genv.Ryvora__RyvoAdmin) == "table" then
        	genv.Ryvora__RyvoAdmin.Notify = __RYVORA_BUNDLER_ENV._G.notify
        end
        
        return {
        	container = container,
        	create = createNotification,
        }
        
        end,
        ["main"] = function(__RYVORA_BUNDLER_ENV)
        local genv = (type(getgenv) == "function") and getgenv() or _G
        local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
        	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
        end
        if not genv.Ryvora__RyvoAdminConfig then
        	genv.Ryvora__RyvoAdminConfig = {
        		bundled = true
        	} 
        end
        
        local config = genv.Ryvora__RyvoAdminConfig
        config.source = config.source or "https://raw.githubusercontent.com/Ryvora/RyvoAdmin/refs/heads/main/src/"
        
        
        __RYVORA_BUNDLER_ENV._G.Commands = {}
        -- Initialize some Variables
        __RYVORA_BUNDLER_ENV._G.Svc = {
        	Workspace = game:GetService("Workspace"),
        	Players = game:GetService("Players"),
        	Run = game:GetService("RunService")
        }
        
        __RYVORA_BUNDLER_ENV._G.Identity = (type(identifyexecutor) == "function") and identifyexecutor() or "your Executor"
        
        __RYVORA_BUNDLER_ENV._G.RyvoraRoot = "https://raw.githubusercontent.com/Ryvora/FOSS/refs/heads/main/"
        function __RYVORA_BUNDLER_ENV._G.RyvoraGet(scrpt)
        	return loadstring(game:HttpGet(__RYVORA_BUNDLER_ENV._G.RyvoraRoot .. scrpt))()
        end
        
        __RYVORA_BUNDLER_ENV._G.Player = __RYVORA_BUNDLER_ENV._G.RyvoraGet("LocalPlayer.luau")
        
        if genv and genv.Ryvora__RyvoAdmin then
        	local marker = genv.Ryvora__RyvoAdmin
        	if type(marker.Notify) == "function" then
        		marker.Notify("You attempted to load RyvoAdmin more than once!\nThis is not an error!", 5)
        	end
        	error("Blocked Multi-execution")
        end
        
        genv.Ryvora__RyvoAdmin = {}
        
        if not config.bundled then
        	genv.Ryvora__RyvoAdmin.Env = __RYVORA_BUNDLER_ENV._G
        end
        
        
        local Util = __RYVORA_BUNDLER_ENV.require("util")
        
        local tempGui, _ = __RYVORA_BUNDLER_ENV.require("tempgui")
        
        __RYVORA_BUNDLER_ENV.require("commands/_registry")
        
        -- Remove Temporary GUI
        tempGui.gui:Destroy()
        
        __RYVORA_BUNDLER_ENV.require("gui/impl")
        __RYVORA_BUNDLER_ENV.require("gui/notifications")
        
        -- ------------------------------------------------------------------ args --
        -- Convert a raw string argument into the type declared by its argsInfo entry.
        --   number -> tonumber(value)
        --   bool   -> true/false (case-insensitive)
        --   player -> "me" | exact Name/DisplayName | Name prefix match
        
        local function findPlayer(value)
        	if value == "me" then
        		return __RYVORA_BUNDLER_ENV._G.Svc.Players.LocalPlayer
        	end
        
        	local players = __RYVORA_BUNDLER_ENV._G.Svc.Players:GetPlayers()
        
        	for _, plr in pairs(players) do
        		if plr.Name == value or plr.DisplayName == value then
        			return plr
        		end
        	end
        
        	for _, plr in pairs(players) do
        		if plr.Name:sub(1, #value) == value then
        			return plr
        		end
        	end
        
        	return nil
        end
        
        local function convertArg(value, info)
        	local argType = info and info.type
        
        	if argType == "number" then
        		return tonumber(value) or value
        	elseif argType == "bool" or argType == "boolean" then
        		local lowered = string.lower(tostring(value))
        		if lowered == "true" then
        			return true
        		elseif lowered == "false" then
        			return false
        		end
        		return value
        	elseif argType == "player" then
        		return findPlayer(value)
        	end
        
        	return value
        end
        
        function __RYVORA_BUNDLER_ENV._G.executeCommand(commandOrPart, ...)
        	local args = {...}
        	local command
        	for _, v in pairs(__RYVORA_BUNDLER_ENV._G.Commands) do
        		if v.Command == commandOrPart then
        			command = v
        			break
        		end
        		for _, alias in pairs(v.Aliases or {}) do
        			if alias == commandOrPart then
        				command = v
        				break
        			end
        		end
        		if command ~= nil then
        			break
        		end
        	end
        
        	if command == nil then
        		-- Try to guess what they meant
        		local bestDistance = math.huge
        
        		for _, v in pairs(__RYVORA_BUNDLER_ENV._G.Commands) do
        			local candidates = { v.Command }
        
        			if v.Alt then
        				table.insert(candidates, v.Alt)
        			end
        
        			for _, name in ipairs(candidates) do
        				local distance = Util.Levenshtein(
        					string.lower(name),
        					string.lower(tostring(commandOrPart))
        				)
        
        				if distance < bestDistance then
        					bestDistance = distance
        					command = v
        				end
        			end
        		end
        
        		-- Don't guess if the closest command is too different.
        		if bestDistance > 1 then
        			command = nil
        		end
        
        		if command == nil then
        			__RYVORA_BUNDLER_ENV._G.notify("Invalid Command!", 5)
        		else
        			__RYVORA_BUNDLER_ENV._G.notify("Invalid Command!\nDid you mean: " .. command.Command .. "?", 15)
        		end
        		return
        	end
        
        	local count = #args
        	local converted = table.create(count)
        	for i = 1, count do
        		local info = command.ArgsInfo and command.ArgsInfo[i]
        		converted[i] = convertArg(args[i], info)
        	end
        
        	command.Callback(table.unpack(converted, 1, count))
        end
        
        end,
        ["tempgui"] = function(__RYVORA_BUNDLER_ENV)
        local genv = (type(getgenv) == "function") and getgenv() or _G
        local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
        	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
        end
        __RYVORA_BUNDLER_ENV._G =  __RYVORA_BUNDLER_ENV._G or genv.Ryvora__RyvoAdmin.Env
        
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
        end,
        ["util"] = function(__RYVORA_BUNDLER_ENV)
        local genv = (type(getgenv) == "function") and getgenv() or _G
        local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
        	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
        end
        __RYVORA_BUNDLER_ENV._G =  __RYVORA_BUNDLER_ENV._G or genv.Ryvora__RyvoAdmin.Env
        
        local Util = {}
        
        function Util.Levenshtein(a, b)
        	local matrix = {}
        
        	for i = 0, #a do
        		matrix[i] = {}
        		matrix[i][0] = i
        	end
        
        	for j = 0, #b do
        		matrix[0][j] = j
        	end
        
        	for i = 1, #a do
        		for j = 1, #b do
        			local cost = a:sub(i, i) == b:sub(j, j) and 0 or 1
        
        			matrix[i][j] = math.min(
        				matrix[i - 1][j] + 1,
        				matrix[i][j - 1] + 1,
        				matrix[i - 1][j - 1] + cost
        			)
        		end
        	end
        
        	return matrix[#a][#b]
        end
        
        return Util
        end
    },

    fakeSenv = {
        ["commands/_registry"] = nil,
        ["commands/copypos"] = nil,
        ["commands/desync"] = nil,
        ["commands/fly"] = nil,
        ["commands/help"] = nil,
        ["commands/noclip"] = nil,
        ["commands/walkspeed"] = nil,
        ["config"] = nil,
        ["gui/builder"] = nil,
        ["gui/floatingButton"] = nil,
        ["gui/format"] = nil,
        ["gui/help"] = nil,
        ["gui/impl"] = nil,
        ["gui/notifications"] = nil,
        ["main"] = nil,
        ["tempgui"] = nil,
        ["util"] = nil
    },

    _G = {}
}

__RYVORA_BUNDLER_ENV.require = function(module)
    if __RYVORA_BUNDLER_ENV.fakeSenv[module] then
        return __RYVORA_BUNDLER_ENV.fakeSenv[module]
    end

    if __RYVORA_BUNDLER_ENV.fakeScripts[module] then
        local senv = __RYVORA_BUNDLER_ENV.fakeScripts[module](__RYVORA_BUNDLER_ENV) -- Execute
        __RYVORA_BUNDLER_ENV.fakeSenv[module] = senv
        return senv
    end

    error("Invalid Module: " .. tostring(module))
    return nil
end

__RYVORA_BUNDLER_ENV.require("main")
