local genv = (type(getgenv) == "function") and getgenv() or _G
local function require(mdl) -- We can safely override this since we will never use it in RyvoAdmin!
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
if not genv.Ryvora__RyvoAdminConfig then
	genv.Ryvora__RyvoAdminConfig = {
		bundled = true
	} 
end

local config = genv.Ryvora__RyvoAdminConfig
config.source = config.source or "https://raw.githubusercontent.com/Ryvora/RyvoAdmin/refs/heads/main/src/"

_RyEnv = {}
_RyEnv.Commands = {}
-- Initialize some Variables
_RyEnv.Svc = {
	Workspace = game:GetService("Workspace"),
	Players = game:GetService("Players"),
	Run = game:GetService("RunService")
}

_RyEnv.Identity = (type(identifyexecutor) == "function") and identifyexecutor() or "your Executor"

_RyEnv.RyvoraRoot = "https://raw.githubusercontent.com/Ryvora/FOSS/refs/heads/main/"
function _RyEnv.RyvoraGet(scrpt)
	return loadstring(game:HttpGet(_RyEnv.RyvoraRoot .. scrpt))()
end

_RyEnv.Player = _RyEnv.RyvoraGet("LocalPlayer.luau")

if genv and genv.Ryvora__RyvoAdmin then
	local marker = genv.Ryvora__RyvoAdmin
	if type(marker.Notify) == "function" then
		marker.Notify("You attempted to load RyvoAdmin more than once!\nThis is not an error!", 5)
	end
	error("Blocked Multi-execution")
end

genv.Ryvora__RyvoAdmin = {}

if not config.bundled then
	genv.Ryvora__RyvoAdmin.Env = _RyEnv
end


local Util = require("util")

local tempGui, _ = require("tempgui")

require("commands/_registry")

-- Remove Temporary GUI
tempGui.gui:Destroy()

require("gui/impl")
require("gui/notifications")

-- ------------------------------------------------------------------ args --
-- Convert a raw string argument into the type declared by its argsInfo entry.
--   number -> tonumber(value)
--   bool   -> true/false (case-insensitive)
--   player -> "me" | exact Name/DisplayName | Name prefix match

local function findPlayer(value)
	if value == "me" then
		return _RyEnv.Svc.Players.LocalPlayer
	end

	local players = _RyEnv.Svc.Players:GetPlayers()

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

function _RyEnv.executeCommand(commandOrPart, ...)
	local args = {...}
	local command
	for _, v in pairs(_RyEnv.Commands) do
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

		for _, v in pairs(_RyEnv.Commands) do
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
			_RyEnv.notify("Invalid Command!", 5)
		else
			_RyEnv.notify("Invalid Command!\nDid you mean: " .. command.Command .. "?", 15)
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
