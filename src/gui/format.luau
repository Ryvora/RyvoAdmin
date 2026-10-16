local genv = (type(getgenv) == "function") and getgenv() or _G
local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/Ryvora/RyvoAdmin/refs/heads/main/"..mdl..".luau"))()
end
_RyEnv = _RyEnv or genv.Ryvora__RyvoAdmin.Env

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
