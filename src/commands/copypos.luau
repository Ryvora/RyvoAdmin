local genv = (type(getgenv) == "function") and getgenv() or _G
local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/Ryvora/RyvoAdmin/refs/heads/main/"..mdl..".luau"))()
end
_RyEnv = _RyEnv or genv.Ryvora__RyvoAdmin.Env

_RyEnv.registerCommand("copypos", { "cpos" }, {}, function()
	local root = _RyEnv.Player.getCharacterRoot()
	if not setclipboard then
		_RyEnv.notify("setclipboard is not supported by " .. _RyEnv.Identity, 3)
		return
	end
	setclipboard("Vector3.new(" .. tostring(root.CFrame.Position) .. ")")
	_RyEnv.notify("Successfully copied to clipboard!", 1)
end)

_RyEnv.registerCommand("copycframe", { "ccf" }, {}, function()
	local root = _RyEnv.Player.getCharacterRoot()
	if not setclipboard then
		_RyEnv.notify("setclipboard is not supported by " .. _RyEnv.Identity, 3)
		return
	end
	setclipboard("CFrame.new(" .. tostring(root.CFrame) .. ")")
	_RyEnv.notify("Successfully copied to clipboard!", 1)
end)
