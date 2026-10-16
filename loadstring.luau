local genv = (type(getgenv) == "function") and getgenv() or _G
genv.Ryvora__RyvoAdminConfig = {
	bundled = false
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/Ryvora/RyvoAdmin/refs/heads/main/main.luau"))()