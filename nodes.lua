core.register_node(":bots:invisible_door", {
	description = "Invisible door",
	drawtype = "allfaces_optional",
	tiles = "camp.png",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = true,
	diggable = true,
	buildable_to = true,
	drop = "",
	groups = {choppy=2, dig_immediate=3, not_in_creative_inventory=1}
})