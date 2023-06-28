bots.wait_for_later = {}
bots.queue_shot = {}
function bots.do_act_bot(properties, dtime)
	local entity = properties.object:get_luaentity()
	local object = properties.object
	local name = entity:get_bot_name()
	if cs_match.commenced_match == false and bots.wait_for_later[name] ~= true then
		local preffered_rifle = entity:get_bot_data().rifles
		local preffered_pistol = entity:get_bot_data().pistols
		bots.buy_if_dont_had(bots.get_good_arm_by_money(preffered_rifle, bots.bots_data[name].money), bots.bots_data[name], "rifle")
		bots.buy_if_dont_had(bots.get_good_arm_by_money(preffered_pistol, bots.bots_data[name].money), bots.bots_data[name], "pistol")
		bots.wait_for_later[name] = true
		return
	end
	if cs_match.commenced_math ~= false then
		--print(bots.max_view_range)
		bots.wait_for_later[name] = nil
		local objs = core.get_objects_inside_radius(object:get_pos(), bots.max_view_range)
		for _, obj in pairs(objs) do
			if obj:is_player() or obj:get_properties().infotext:find("BOT") then
				local pos = object:get_pos()
				local to_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
				local to_pos2 = {x = obj:get_pos().x, y = obj:get_pos().y + 1, z = obj:get_pos().z}
				--print(dump(core.line_of_sight(to_pos, to_pos2)))
				local checked_thing
				if not obj:is_player() and obj:get_luaentity().bot_data then -- test if he a bot
					checked_thing = csgo.check_team(obj:get_luaentity():get_bot_name()) ~= ""
				end
				if core.line_of_sight(to_pos, to_pos2) and (csgo.check_team(obj:get_player_name()) ~= "" or checked_thing) then
					local obj_team = csgo.check_team(obj:get_player_name()) ~= "" and csgo.check_team(obj:get_player_name()) or csgo.check_team(obj:get_luaentity():get_bot_name()) ~= "" and csgo.check_team(obj:get_luaentity():get_bot_name())
					
					--print(obj_team, name, entity:get_team())
					
					if obj:get_properties().infotext ~= object:get_properties().infotext then -- Avoid if the object is the used object
						
						if obj_team ~= "spectator" then
							if obj_team ~= entity:get_team() then
								
								
								
								local yaw, pitch = bots.return_dir(obj:get_pos(), object:get_pos())
								
								object:set_yaw(yaw)
								
								if not bots.queue_shot[name] then
									bots.bots_data[name].usrdata:set_animation(bots.bots_animations[name].mine, bots.bots_animations[name].anispeed, 0)
									local itemstack = ItemStack((bots.bots_data[name].actual_rifle ~= "" and bots.bots_data[name].actual_rifle) or (bots.bots_data[name].actual_pistol ~= "" and bots.bots_data[name].actual_pistol))
									if itemstack and itemstack ~= "" then
										bots.bots_data[name].actual_item = itemstack:get_name()
										local damage = itemstack:get_definition().RW_gun_capabilities.gun_damage -- can be changed.
										local sound = itemstack:get_definition().RW_gun_capabilities.gun_sound
										local velocity = itemstack:get_definition().RW_gun_capabilities.gun_velocity or bots.default_gun_velocity
										bots.launch_projectile(1, damage or bots.default_bullet_damage, "bots:bullet", sound, velocity, properties, obj:get_pos())
										bots.queue_shot[name] = 0.1
										bots.witem[name]:set_properties({
											textures = {itemstack:get_name()},
											visual_size = bots.location[4],
										})
										
									else
										print()
									end
								end
							end
						end
					end
				end
			end
			
		end
		if c4.planted then
			if properties:get_team() ~= "terrorist" and properties:get_team() ~= "" and properties:get_team() == "counter" then
				if c4.pos and vector.distance(c4.pos, object:get_pos()) <= 3 then
					--error()
					--print(dtime)
					bots.timers[entity:get_bot_name()] = bots.timers[entity:get_bot_name()] + dtime
					object:set_velocity(vector.new(0,0,0))
					if bots.timers[entity:get_bot_name()] >= 7 then
						local user = "BOT "..entity:get_bot_name(true)
						annouce.winner("counter", "Congrats to "..user.." for defusing the c4!")
						core.after(0.6, cs_match.finish_match, "counter")
						c4.remove_bomb()
						c4.remove_bomb2()
						bots.timers[entity:get_bot_name()] = 0
					end
				end
			end
		end
		-- Move forms
		--[[
			Every corner in the map is a sign that the bot needed to move to the other AXIS. (bots:marker_corner)
			Bots might use bots.return_dir(p1, p2) to make bot look at the corner.
		--]]
	--[[
		Using Mobkit API for movements.
		By Termos
	--]]
	--mobkit.stepfunc(properties, dtime) -- Link to this, for movements
	end
end
bots.timer = 0
local step = function(dtime)
	bots.timer = bots.timer + dtime
	if bots.timer >= 0.1 then
		for name, val in pairs(bots.queue_shot) do
			--print(val)
			
			if type(val) == "number" and not (val <= 0) then
				bots.queue_shot[name] = bots.queue_shot[name] - dtime
			else
				bots.queue_shot[name] = nil
				bots.bots_data[name].usrdata:set_animation(bots.bots_animations[name].stand, bots.bots_animations[name].anispeed, 0)
			end
		end
		bots.timer = 0
	end
end

core.register_globalstep(step)


