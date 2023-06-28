bots_nametags = {
	tags = {},
}
function bots_nametags.add_to(self)
	local entity = core.add_entity(self.object:get_pos(), "cs_bots:name")
	local texture = "tag_bg.png"
	local x = math.floor(134 - ((("BOT_"..self:get_bot_name(true)):len() * 11) / 2))
	local i = 0
	("BOT_"..self:get_bot_name(true)):gsub(".", function(char)
		local n = "_"
		if char:byte() > 96 and char:byte() < 123 or char:byte() > 47 and char:byte() < 58 or char == "-" then
			n = char
		elseif char:byte() > 64 and char:byte() < 91 then
			n = "U" .. char
		end
		texture = texture.."^[combine:84x14:"..(x+i)..",0=W_".. n ..".png"
		i = i + 11
	end)
	texture = texture.."^[colorize:"..csgo.get_team_colour(self:get_team())..":255"
	entity:set_properties({ textures={texture} })
	entity:set_attach(self.object, "", {x=0, y=18, z=0}, {x=0, y=0, z=0})
	local luaent = entity:get_luaentity()
	luaent.attachedto = self:get_bot_name()
	bots_nametags.tags[self:get_bot_name()] = entity
end

function bots_nametags.rmv_to(name)
	if bots_nametags.tags[name] then
		bots_nametags.tags[name]:remove()
	end
end

minetest.register_entity(":cs_bots:name", {
	initial_properties = {
		visual = "sprite",
		visual_size = {x=2.16, y=0.18, z=2.16},
		textures = {"invisible.png"},
		pointable = false,
		on_punch = function() return true end,
		physical = false,
		is_visible = true,
		backface_culling = false,
		makes_footstep_sound = false,
		static_save = false,
	},
})