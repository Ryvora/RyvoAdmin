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