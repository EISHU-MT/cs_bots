bots.mm = {}
bots.mm.selected = {}
bots.mm.nodes = {}

local function get_mapmaker_form(error)
	return "formspec_version[6]" ..
	"size[10.5,5]" ..
	"box[0,0.9;10.6,4.2;#005CFF]" ..
	"box[0,0;6.2,0.9;#00D5FF]" ..
	"label[0.1,0.4;Bots positions]" ..
	"dropdown[0.1,1.7;10.3,1.1;selected;Select one,walker_area,camp_sit,to_other,sector_a,corner,corner2,sector_b,camp;1;false]" ..
	"label[4,1.3;Type of node]" ..
	"button_exit[0.1,3.9;10.3,1;;Cancel]" ..
	"button_exit[0.1,3;10.3,0.8;accept;Accept]" ..
	"box[6.2,0;4.4,0.9;#FF0000]" ..
	"label[7.5,0.4;"..error or "<no error>".."]"
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "cbots:node" then
		return
	end
	if fields.selected then
		bots.mm.selected[Name(player)] = fields.selected
		core.chat_send_player(Name(player), core.colorize("#00F9FF", "Selected: ")..core.colorize("#0075FF", fields.selected))
	end
	if fields.accept then
		local name = Name(player)
		local pos = bots.mm.nodes[name]
		core.set_node(pos, "bots:marker_"..bots.mm.selected[name])
	end
end)

-- Defs
local nodes = {
	description = "",
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = true,
	diggable = true,
	buildable_to = true,
	drop = "",
	groups = {choppy=2, dig_immediate=3, not_in_creative_inventory=1}
}

local things = {"walker_area", "camp_sit", "camp", "sector_a", "sector_b", "to_other", "corner", "corner2"}

for _, name in pairs(things) do
	local node = table.copy(nodes)
	node.description = name.."\nHading this can place the marker everywhere"
	node.tiles = {name..".png"}
	node.drawtype = "allfaces_optional"
	core.register_node(":bots:marker_"..name, node)
end






















