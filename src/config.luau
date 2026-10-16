local genv = (type(getgenv) == "function") and getgenv() or _G
local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/Ryvora/RyvoAdmin/refs/heads/main/"..mdl..".luau"))()
end
_RyEnv = _RyEnv or genv.Ryvora__RyvoAdmin.Env

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

_RyEnv.config = config

return config
