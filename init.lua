--[[
	BOTS for CS:MT Game
	License: same as CS:MT Game
	version: v0-WorkInProgress
--]]
local modpath = core.get_modpath(core.get_current_modname())
dofile(modpath.."/core.lua")
dofile(modpath.."/on_kill.lua")
local meta = {}
function meta:get_current_version(state)
	if state == "number" then
		return self.versionN
	else
		return self.version
	end
end
function meta:get_total_loadedbots()
	return #bots.bots_data
end
bots = setmetatable(bots, meta)