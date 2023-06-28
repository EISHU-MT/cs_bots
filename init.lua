--[[
	BOTS for CS:MT Game
	License: same as CS:MT Game
	version: v0-WorkInProgress
--]]
local modpath = core.get_modpath(core.get_current_modname())
dofile(modpath.."/core.lua")
dofile(modpath.."/on_kill.lua")
dofile(modpath.."/act.lua")
dofile(modpath.."/helpers.lua")
dofile(modpath.."/path_finder.lua")
dofile(modpath.."/inv.lua")

bots.modules = modpath.."/modules"

dofile(bots.modules.."/init.lua")

dofile(modpath.."/map_maker.lua")

dofile(modpath.."/nodes.lua")
dofile(modpath.."/coords_core.lua")
dofile(modpath.."/movements.lua")

dofile(modpath.."/nametag.lua")

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

