local genv = (type(getgenv) == "function") and getgenv() or _G
local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
	return loadstring(game:HttpGet(genv.Ryvora__RyvoAdminConfig.source .. mdl .. ".luau"))()
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