--[[
	This file contents was extracted from RangedWeapons (cs_rws)
--]]
bots.launch_projectile = function(projectiles, dmg, entname, shoot_sound, combined_velocity, data, to_pos)
	local pos = data.object:get_pos()
	local entity = data.object:get_luaentity()
	local dir = bots.calc_dir(data.object:get_rotation())
	local yaw = data.object:get_yaw()
	local direction = vector.direction(pos, to_pos)
	local tmpsvertical = data.object:get_rotation().x / (math.pi/2)
	local svertical = math.asin(direction.y) - (math.pi/2)
	if pos and dir and yaw then
		minetest.sound_play(shoot_sound, {pos = pos, gain = 0.5, max_hear_distance = 60})
		pos.y = pos.y + 1.45
		projectiles = projectiles or 1
		for i=1,projectiles do
			local spawnpos_x = pos.x
			local spawnpos_y = pos.y
			local spawnpos_z = pos.z
			local obj = minetest.add_entity({x=spawnpos_x,y=spawnpos_y,z=spawnpos_z}, entname)
			local ent = obj:get_luaentity()
			local size = 0.1
			obj:set_properties({
				textures = {"bullet2.png"},
				visual = "sprite",
				visual_size = {x=0.4, y=0.4},
				collisionbox = {-size, -size, -size, size, size, size},
				glow = proj_glow,
			})
			
			ent.owner = data.object
			ent.damage = dmg or {fleshy = bots.default_bullet_damage}
			
			obj:set_pos(pos)
			obj:set_velocity({x=dir.x * combined_velocity, y=direction.y * combined_velocity, z=dir.z * combined_velocity})
			--obj:set_rotation({x=0,y=yaw / (math.pi/2),z=-direction.y})
		end
	end
end