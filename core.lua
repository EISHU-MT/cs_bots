local floor = math.floor
bots = {
	groups = {terrorist = {count = 0, bots = {}}, counter = {count = 0, bots = {}}},
	metatable_registering = {},
	bots_animations = {
		__example = {
			lay = {x = 162, y = 166},
			speed = 15,
		},
	},
	callbacks = {},
	storage = core.get_mod_storage(core.get_current_modname()), -- Make compatible with olders versions
	version = "V0-WorkInProgress",
	versionN = 0.1,
	bots_data = {
		__example = {
			actual_rifle = "rangedweapons:ak47",
			name = "BOT_Crusher",
			money = "456",
			team = "counter",
			actual_pistol = "rangedweapons:luger",
			recharge = true,
			actual_weapon_image = "", -- TODO: Must use ItemStack(weapon):get_definition().inventory_image
			usrdata = {}, -- Object
		},
	},
	register_toteam_bot = function(bot, by_started_engine)
			local bot22 = bot:get_luaentity()
		if bot and type(bot) == "userdata" and csgo.max_bots ~= csgo.team[bot22:get_team()].bots_count and not maps.current_map.enable_bots then
			local bot2 = bot:get_luaentity()
			local team = bot2:get_team()
			csgo.op[bot2:get_bot_name()] = true
			csgo.pt[bot2:get_bot_name()] = true
			csgo.online[bot2:get_bot_name()] = true
			csgo.spect[bot2:get_bot_name()] = false
			csgo.pot2[bot2:get_bot_name()] = team
			csgo.pot[bot2:get_bot_name()] = team
			csgo.team[team].bots[bot2:get_bot_name()] = true
			csgo.team[team].bots_count = csgo.team[team].bots_count + 1
			
			bot:set_armor_groups({immortal = 0, fleshy = 100})
			
			bots.groups[team].bots[bot2:get_bot_name()] = true
			bots.groups[team].count = #bots.groups[team].bots
			
			if by_started_engine ~= true then
				if team == "counter" then
					local pos = counters_spawn()
					bot:set_pos(pos)
				elseif team == "terrorist" then
					local pos = terrorists_spawn()
					bot:set_pos(pos)
				end
			end
		end
	end,
	log = function(act, msg)
		if minetest.settings:get_bool("cs_core.enable_env_debug", false) then
			core.log(act, msg)
		end
	end,
	dead_bots = {},
	register_deadbot = function(bot, team)
		local bot2 = bot:get_luaentity()
		table.insert(bots.dead_bots, {entity = core.add_entity(bot:get_pos(), bots.bots_data[bot2:get_bot_name()].rname), team = team or bot2:get_team()})
		local def = bot:get_properties()
		def.is_visible = true
		def.makes_foostep_sound = false
		def.pointable = false
		def.show_on_minimap = false
		bot:set_properties(def)
		bot:set_armor_groups({immortal = 1})
		bot:set_animation(bots.bots_animations[bot2:get_bot_name()].lay, bots.bots_animations[bot2:get_bot_name()].anispeed, 0)
		
		local team = bot2:get_team()
		csgo.op[bot2:get_bot_name()] = false
		csgo.pt[bot2:get_bot_name()] = false
		csgo.online[bot2:get_bot_name()] = false
		csgo.spect[bot2:get_bot_name()] = false
		csgo.pot2[bot2:get_bot_name()] = "spectator"
		csgo.pot[bot2:get_bot_name()] = "spectator"
		csgo.team[team].bots[bot2:get_bot_name()] = false
		csgo.team[team].bots_count = csgo.team[team].bots_count - 1
		
		bots.groups[team].bots[bot2:get_bot_name()] = false
		bots.groups[team].count = #bots.groups[team].bots
	end,
	respawn_bots = function()
		for _, bot in pairs(bots.dead_bots) do
			if type(bot) == "table" and type(bot.entity) == "userdata" and csgo.is_team(bot.team) then
				if csgo.max_bots ~= csgo.team[bot.team].bots_count then
					bots.register_toteam_bot(bot.entity)
					local def = bot.entity:get_properties()
					def.is_visible = true
					def.makes_foostep_sound = true
					def.pointable = true
					def.show_on_minimap = true
					bot.entity:set_properties(def)
					bot.entity:set_animation(bots.bots_animations[bot.entity:get_luaentity():get_bot_name()].stand, bots.bots_animations[bot.entity:get_luaentity():get_bot_name()].anispeed, 0)
				end
			end
			bots.dead_bots[_] = nil
		end
	end,
	reset_bots = function()
		bots.respawn_bots()
		for name, tabled in pairs(bots.bots_data) do
			if name and tabled and not name:find("__") then
				if tabled.usrdata:get_pos() and vector.distance(maps.current_map.teams[tabled.team], tabled.usrdata:get_pos()) > 2 then
					tabled.usrdata:set_pos(maps.current_map.teams[tabled.team])
					tabled.usrdata:set_hp(tabled.entity:get_bot_maxhp())
				end
			end
		end
	end,
	start_engine = function()
		if bots.enable ~= true then
			bots.log("error", "Bots engine is disabled")
			return
		end
		for name, contents in pairs(bots.bots_data) do
			if name:find("__") then -- Test purposes
				return
			end
			local team = contents.team
			local registered_name = contents.rname
			local bot = core.add_entity(maps.current_map.teams[team], contents.rname)
			bots.bots_data[name].usrdata = bot
			bots.bots_data[name].entity = bot:get_luaentity()
			bot:set_physics_override({gravity=1, speed=1})
			bot:set_animation(bots.bots_animations[name].stand, bots.bots_animations[name].anispeed, 0)
			bots.register_toteam_bot(bot, true)
		end
	end,
	to_2d = function(pos)
		return {x = pos.x, y = pos.z}
	end,
	mve = {},
	--do_act_bot = function() end,
	do_gravity = function(entity, dtime, gravity, ended)
		--[[local inf = entity:get_properties()
		if not inf then
			return
		end
		local y_level = inf.collisionbox[2]
		local pos = entity:get_pos()
		
		local center = {x = pos.x, y = pos.y + y_level + 0.25, z = pos.z}
		local stand = {x = pos.x, y = pos.y + y_level - 0.25, z = pos.z}
		
		local center_node = core.get_node(center)
		local stand_node = core.get_node(stand)
		
		--print(dump(center_node))
		--print(dump(stand_node))
		
		if center_node.name ~= "air" then
			
			local xyz = {x = pos.x, y = pos.y + 1, z = pos.z}
			local n = core.get_node(xyz)
			
			local y = pos.y
			
			for i = 1, 400 do
				if core.get_node({x = pos.x, y = pos.y + 1, z = pos.z}).name == "air" then
					entity:set_pos({x = pos.x, y = pos.y + i, z = pos.z})
					return
				end
			end
		end
		print(dump(stand))
		print(dump(stand_node))

		if stand_node.name == "air" then
			for i = 1, 400 do
				if core.get_node({x = pos.x, y = pos.y - (y_level + 0.25), z = pos.z}).name == "air" then
					entity:set_pos({x = pos.x, y = pos.y - 1, z = pos.z})
					print({x = pos.x, y = pos.y - i, z = pos.z})
					return
				end
			end
		end--]]
	end,
	is_in_it = function(target, pos1, pos2) -- target = Target pos, pos1 = corner 1, pos2 = corner 2
		return target.x >= pos1.x and target.x <= pos2.x and target.y >= pos1.y and target.y <= pos2.y and target.z >= pos1.z and target.z <= pos2.z
	end,
	return_dir = function(pos1, pos2)
		local from = bots.to_2d(pos2)
		local to = bots.to_2d(pos1)
		local offset_to = {
			x = to.x - from.x,
			y = to.y - from.y
		}
		local direction = vector.direction(pos2, pos1)
		local pitch = math.asin(direction.y) - (math.pi/2)
		local dir = math.atan2(offset_to.y, offset_to.x) - (math.pi/2)
		return dir, pitch
	end,
	physics = {
		__example = {
			-- Gravity (Fall peer node)
			gravity = 1,
			-- Jump (velocity.y + jump value peer second, jump nodes peer second.)
			jump = 1
		},
	},
	end_velocity_y = tonumber(minetest.settings:get("cs_core.end_velocity_y", "0") or 0),
	default_gun_velocity = tonumber(minetest.settings:get("cs_core.default_gun_velocity", "30") or 30),
	default_gravity = tonumber(minetest.settings:get("cs_core.bots_gravity", "9.81") or 9.81),
	default_bullet_damage = tonumber(minetest.settings:get("cs_core.default_bullet_damage", "10") or 10),
	max_view_range = tonumber(minetest.settings:get("cs_core.view_range", "50") or 50),
	enable = minetest.settings:get("cs_core.enable_bots", false) and minetest.settings:get_bool("cs_map.mapmaking", false) ~= true,
	queue_to_say = {},
	calc_dir = function(rotation)
		-- Calculate the look direction based on the rotation
		local yaw = rotation.y
		local pitch = rotation.x
		-- Calculate the components of the look direction vector
		local directionX = -math.sin(yaw) * math.cos(pitch)
		local directionY = math.sin(pitch)
		local directionZ = math.cos(yaw) * math.cos(pitch)
		-- Return the look direction as a vector
		return {x = directionX, y = directionY, z = directionZ}
	end
}

local metatable_registering = {}

function metatable_registering:get_bot_name(bool)
	if bool then
		return self.bot_name
	end
	return "BOT_"..self.bot_name
end
function metatable_registering:is_bot()
	return true
end
function metatable_registering:get_player_name()
	return self.bot_name
end
function metatable_registering:get_team()
	local inf = self
	return inf.team
end
function metatable_registering:apply_physics(physics)
	if physics.gravity then
		bots.physics[self.object:get_luaentity():get_bot_name()].gravity = physics.gravity
	end
	if physics.speed then
		bots.log("warning", "'speed' field is being ignored because the field cant be applied! BOTS => physics => apply physics.speed")
	end
	if physics.jump then
		bots.physics[self.object:get_luaentity():get_bot_name()].jump = physics.jump
	end
end
function metatable_registering:get_bot_data()
	return self.bot_data
end
function metatable_registering:get_bot_maxhp()
	return self.object:get_properties().hp_max
end

local metatable = {__index = metatable_registering}

function bots.register_bot(name, def, animation)
	local team
	if def.group or def.team then
		team = def.group or def.team
	else
		return false
	end
	local metatable2 = metatable_registering
	metatable2.team = team
	metatable2.bot_name = def.bot_name
	metatable2.bot_data = {
		rifles = def.rifles,
		pistols = def.pistols,
		money = def.money or 200,
		name = def.bot_name,
		recharge = def.recharge or true,
	}
	
	
	local meta = {__index = metatable2}
	local mdef = {
		initial_properties = {
			bot_name = def.bot_name, -- Karl, Crusher, etc
			rifles = def.rifles,
			name = def.bot_name,
			hp_max = def.hp,
			team = team,
			--eye_height = 1.625,
			physical = true,
			collide_with_objects = true,
			collisionbox = def.collisionbox,
			selectionbox = def.collisionbox,
			pointable = true,
			visual = "mesh",
			visual_size = {x = 1, y = 1, z = 1},
			mesh = def.model,
			textures = def.textures,
			colors = {},
			use_texture_alpha = false,
			spritediv = {x = 1, y = 1},
			is_visible = true,
			makes_footstep_sound = true,
			automatic_rotate = 0,
			stepheight = def.sh,
			automatic_face_movement_dir = 0.0,
			automatic_face_movement_max_rotation_per_sec = -1,
			backface_culling = true,
			nametag = "",
			infotext = "BOT "..def.bot_name,
			static_save = true,
			damage_texture_modifier = "^[brighten",
			shaded = true,
			show_on_minimap = true,
			dtimer1 = 0,
			dtimer2 = 0,
			
		},
		
		on_step = function(self, dtime)
			bots.do_act_bot(self, dtime)
		end,
		on_rightclick = function(self, clicker)
			local player = Player(clicker)
			local name = Name(clicker)
			local entity = self.object:get_luaentity()
			local team = self.team
			--print(dump(self))
			if csgo.check_team(name) ~= "terrorist" and csgo.check_team(name) ~= "counter" then
				return -- Engine must dont make obj rotate, like an spectator rightclicking a bot
			end
			if csgo.check_team(name) == csgo.check_team(entity:get_bot_name()) then
				local msg = radio.select_random_msg("what_happening")
				radio.send_msg(self.team, msg, "BOT "..entity:get_bot_name(true).." ")
			else
				local from = bots.to_2d(self.object:get_pos())
				local to = bots.to_2d(player:get_pos())
				local offset_to = {
					x = to.x - from.x,
					y = to.y - from.y
				}
				
				local dir = math.atan2(offset_to.y, offset_to.x) - (math.pi/2)
				self.object:set_yaw(dir)
			end
		end,
		on_death = function(self, puncher)
			--if self.object:get_hp() - damage <= tonumber("0") then -- I feel dumb by setting the tonumber() and not directly 0, because it does errors, like this: attempt to compare number with boolean.
				local player = Player(puncher)
				local name = Name(puncher)
				local player_team = csgo.check_team(name)
				local team = self.team
				if player_team ~= "spectator" then
					
					
					
					local lay = bots.on_kill(self.object, player, damage, self, "bot")
					
				end
				
				--core.log("error", "---")
				
				--return false
				
				
				
			--end
			--return false
		end,
		
		on_punch = function(self, puncher, _, _, _, damage)
			local from = bots.to_2d(self.object:get_pos())
			local to = bots.to_2d(puncher:get_pos())
			local offset_to = {
				x = to.x - from.x,
				y = to.y - from.y
			}
			
			local dir = math.atan2(offset_to.y, offset_to.x) - (math.pi/2)
			self.object:set_yaw(dir)
			
			local pteam = csgo.check_team(puncher:get_player_name())
			local name = puncher:get_player_name()
			
			if pteam ~= self.object:get_luaentity():get_team() then
				local msg = radio.select_random_msg("hurted")
				if (bots.queue_to_say[self.object:get_luaentity():get_bot_name()] or 0) <= 0 then
					radio.send_msg(self.object:get_luaentity():get_team(), msg, "<BOT "..self.object:get_luaentity():get_bot_name(true).."> ")
					bots.queue_to_say[self.object:get_luaentity():get_bot_name()] = 0.5
				end
				
			end
			
		end,
		
		on_activate = function(self)
			--setmetatable(self, metatable)
			self.object:set_velocity({x = 0, y = 0, z = 0})
			self.object:set_acceleration({x = 0, y = -bots.physics[self.object:get_luaentity():get_bot_name()].gravity, z = 0})
		end,
	}
	core.register_entity(name, setmetatable(mdef, metatable))
	bots.bots_data["BOT_"..def.bot_name] = {
		name = "BOT_"..def.bot_name,
		money = 200,
		actual_rifle = "",
		team = team,
		actual_pistol = "",
		recharge = true,
		usrdata = {},
		rname = name,
		eye_height = def.eye_height or 1.625
	}
	bots.bots_animations["BOT_"..def.bot_name] = {
		lay = animation.lay or animation.death,
		sit = animation.sit or animation.camp,
		stand = animation.stand or animation.noact,
		mine = animation.mine or animation.attack,
		walk_mine = animation.wmine or animation.walk_attack,
		anispeed = animation.speed or 30,
	}
	bots.physics["BOT_"..def.bot_name] = {
		gravity = def.gravity or bots.default_gravity,
		jump = 1
	}
	kills.add_to("BOT_"..def.bot_name, team)
end

--Register some parts for env

local function gsf(dtime)
	for name, value in pairs(bots.queue_to_say) do
		if type(value) == "number" then
			bots.queue_to_say[name] = bots.queue_to_say[name] - dtime
		end
	end
end

core.register_globalstep(gsf)
























