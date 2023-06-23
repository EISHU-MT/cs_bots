
bots.map_maker = {}
bots.map_maker.type_of_ids = {}
bots.map_maker.areas = {}
bots.map_maker.areas_blocks = {}
bots.map_maker.to_compile = {}
local function put_block(pos, n)
	table.insert(bots.map_maker.areas_blocks[n], pos)
	return core.set_node(pos, {name = "mcore:display_node"})
end
local function remove_displays(name)
	for _, pos in pairs(bots.map_maker.areas_blocks[name]) do
		core.set_node(pos, {name = "air"})
		bots.map_maker.areas_blocks[name][_] = nil
	end
end
local function process(pos, name)
	if not bots.map_maker.areas[name] then
		bots.map_maker.areas[name] = {}
	end
	if type(bots.map_maker.areas[name].pos1) ~= "table" then
		bots.map_maker.areas[name].pos1 = pos
		put_block(pos, name)
		return false
	elseif type(bots.map_maker.areas[name].pos2) ~= "table" then
		bots.map_maker.areas[name].pos2 = pos
		put_block(pos, name)
		return true
	end
	return false
end
local function is_ready(name)
	return type(bots.map_maker.areas[name].pos1) == "table" and type(bots.map_maker.areas[name].pos2) == "table"
end
local function compile(id, name)
	bots.map_maker.to_compile[id] = {
		upper_pos = get_corners_for_pos(bots.map_maker.areas[name].pos1, bots.map_maker.areas[name].pos1)[1],
		low_pos = get_corners_for_pos(bots.map_maker.areas[name].pos1, bots.map_maker.areas[name].pos2)[2],
	}
end
local function save_data()
	local data = core.serialize(bots.map_maker)
	bots.storage:set_string("map_makerdata", data)
end
local function request_data(bool)
	local raw_data = bots.storage:get_string("map_makerdata")
	local data = core.deserialize(raw_data)
	if bool then
		return data.to_compile -- Return to_compile if the map is exporting
	end
	if data then
		return data
	else
		return {
			areas = {},
			areas_blocks = {},
			to_compile = {},
			type_of_ids = {}
		}
	end
end
function get_corners_for_pos(pos1, pos2) -- Should return: table_with_highest_Y, table_with_lowest_Y
	if pos1.y > pos2.y then
		return pos1, pos2
	elseif pos1.y < pos2.y then
		return pos2, pos1
	elseif pos1.y == pos2.y then
		return pos1, pos2
	end
end
-- Initialize Bots mapmaker data from storage
local data = request_data(nil)
if data then
	bots.map_maker = data -- Dont lost all data
end
-- Definitions
local wand_def = {
	description = "Bots areas wand",
	short_description = "bots areas manage",
	inventory_image = "cs_files_area_tool.png^stick_overlay.png",
	range = 15,
	liquids_pointable = true,
	on_place = function(itemstack, placer, pointed_thing)
		local name = Name(placer)
		local player = Player(placer)
		if not wand[name] then
			wand[name] = {}
		end
		process(pointed_thing.under, name)
		if is_ready(name) then
			core.chat_send_player(name, "All positions done!")
			core.chat_send_player(name, "Sending a menu to configure the pos.")
			core.show_formspec(name, "cbots:wand", return_formspec("Not available!", "BWand", "ID Cant be shown here", "Field not used!"))
		end
	end,
	on_use = function(itemstack, user, pointed_thing)
		local name = Name(user)
		core.show_formspec(Name(user), "cbots:manage", wand_formspec(core.pos_to_string(bots.map_maker.areas[name].pos1 or {x = 0, y = 0, z = 0}) or "<non set>", core.pos_to_string(bots.map_maker.areas[name].pos2 or {x = 0, y = 0, z = 0}) or "<non set>", "Bots "))
	end,
}

--error()

local on_join = function(player)
	if bots.enable ~= true then
		if type(bots.map_maker.areas[Name(player)]) ~= "table" then
			bots.map_maker.areas[Name(player)] = {}
		end
		if type(bots.map_maker.areas_blocks[Name(player)]) ~= "table" then
			bots.map_maker.areas_blocks[Name(player)] = {}
		end
		if type(bots.map_maker.type_of_ids[Name(player)]) ~= "table" then
			bots.map_maker.type_of_ids[Name(player)] = ""
		end
	end
end


function type_of_area_formspec()
	return "formspec_version[6]" ..
	"size[10.5,3]" ..
	"box[0,0;10.5,0.7;#FFFFFF]" ..
	"label[0.2,0.3;Map bots areas manager]" ..
	"button_exit[0.2,2;10.1,0.8;accepted;Accept]" ..
	"dropdown[0.2,0.9;10.1,0.8;area;Select_One,door,sector,walker_area,prohibited_area,pool,lava,spawn;1;false]"
end

-- Register

core.register_craftitem(":cs_bots:wand", wand_def)
core.register_on_joinplayer(on_join)
core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "cbots:wand" and formname ~= "cbots:manage" and formname ~= "cbots:type_selection" then
		return
	end
	
	if fields.area then
		core.chat_send_player(Name(player), core.colorize("#00EDFF", "[GUI] Selected: ")..fields.area)
		bots.map_maker.type_of_ids[Name(player)] = fields.area
	end
	
	if fields.accepted then
		core.chat_send_player(Name(player), core.colorize("#00EDFF", "[GUI QUIT] Selected: ")..fields.area ~= "Select_One" and fields.area or "walker_area")
		bots.map_maker.type_of_ids[Name(player)] = bots.map_maker.type_of_ids[Name(player)] ~= "Select_One" and bots.map_maker.type_of_ids[Name(player)] or "walker_area" -- Be sure if the type of area wanst the `Select_One`
		core.chat_send_player(Name(player), core.colorize("#00EDFF", "[GUI QUIT] Now, rightclick any node, rightclicking will dont change any area, just its will show again the menu."))
	end
	
	if fields.decline then
		core.chat_send_player(Name(player), core.colorize("#FF0000", "Declined."))
		remove_displays(Name(player))
		bots.map_maker.areas[Name(player)].pos1 = nil
		bots.map_maker.areas[Name(player)].pos2 = nil
		save_data()
	end
	if fields.accept then
		if not (bots.map_maker.type_of_ids[Name(player)]) or bots.map_maker.type_of_ids[Name(player)] == "Select_One" or bots.map_maker.type_of_ids[Name(player)] == "" then
			core.chat_send_player(Name(player), core.colorize("#00EDFF", "[GUI] First select any room/area type!"))
			core.after(1, function(player) core.show_formspec(Name(player), "cbots:type_selection", type_of_area_formspec()) end, player)
			return
		end
		bots.log("action", "[BOTS Map Maker] Saving some modules")
		remove_displays(Name(player))
		compile(bots.map_maker.type_of_ids[Name(player)].."-"..FormRandomString(5), Name(player))
		bots.map_maker.type_of_ids[Name(player)] = ""
		bots.map_maker.areas[Name(player)].pos1 = nil
		bots.map_maker.areas[Name(player)].pos2 = nil
		save_data()
	end
	
	if fields.reset then
		core.chat_send_player(Name(player), core.colorize("#FF0000", "Positions have been resetted"))
		remove_displays(Name(player))
		bots.map_maker.areas[Name(player)].pos1 = nil
		bots.map_maker.areas[Name(player)].pos2 = nil
		save_data()
	end
end)


























