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
	location = { -- Wield item for bots
		"Arm_Right",
		{x=0, y=5.5, z=3},
		{x=-90, y=225, z=90},
		{x=0.25, y=0.25},
	},
	bots_data = {
	},
	pathes = {},
	dead_ent = {
		hp_max = 100,
		--eye_height = 1.625,
		physical = true,
		collide_with_objects = true,
		collisionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5 },  -- default
		selectionbox = { -0.5, -0.5, -0.5, 0.5, 0.5, 0.5, rotate = false },
		pointable = false,
		visual = "mesh",
		visual_size = {x = 1, y = 1, z = 1},
		mesh = "empty.b3d",
		textures = {},
		colors = {},
		use_texture_alpha = false,
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = true,
		makes_footstep_sound = false,
		automatic_rotate = 0,
		stepheight = 0,
		automatic_face_movement_dir = 0.0,
		automatic_face_movement_max_rotation_per_sec = -1,
		backface_culling = true,
		glow = 1,
		nametag = "",
		infotext = "(DIED)",
		static_save = true,
		damage_texture_modifier = "",
		shaded = true,
		show_on_minimap = false,
	},
	transform = function(n) if not tostring(n):find("-") then return n end return tonumber(tostring(n):sub(2)) end,
	difference_between_pos = function(pos1, pos2)
		local t = bots.transform
		local x = pos1.x - pos2.x
		local y = pos1.y - pos2.y
		local z = pos1.z - pos2.z
		return {x = t(x), y = t(y), z = t(z)}
	end,
	equals = function(t1, t2)
		for name, value in pairs(t1) do
			if t2[name] and t2[name] ~= value then
				return false
			end
		end
		return true
	end,
	register_toteam_bot = function(bot, by_started_engine)
		local bot22 = bot:get_luaentity()
		--print("aeaeaeaeae"..dump(bot))
		if bot and type(bot) == "userdata" and csgo.max_bots ~= csgo.team[bot22:get_team()].bots_count and not maps.current_map.enable_bots then
			--print(bot22:get_team().." "..bot22:get_bot_name())
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
			
			--WieldItem (Extracted from wielditem (cs_hand))
			--print()
			--print(dump(core.add_entity(bot:get_pos(), "bots:witem")))
			local witem = core.add_entity(bot:get_pos(), "bots:witem")
			witem:set_attach(bot, bots.location[1], bots.location[2], bots.location[3])
			witem:set_properties({
				textures = {"wield3d:hand"},
				visual_size = bots.location[4],
			})
			
			bots.witem[bot2:get_bot_name()] = witem
			
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
		table.insert(bots.dead_bots, {team = team or bot2:get_team(), bot_raw_name = bot2.name})
		local def = bot:get_properties()
		def.is_visible = true
		def.makes_foostep_sound = false
		def.pointable = false
		def.show_on_minimap = false
		bot:set_properties(def)
		bot:set_armor_groups({immortal = 1})
		bot:set_animation(bots.bots_animations[bot2:get_bot_name()].lay, bots.bots_animations[bot2:get_bot_name()].anispeed, 0)
		
		died_players[bot2:get_bot_name()] = minetest.add_entity(bot:get_pos(), "cs_player:dead_ent")
		local new_table = table.copy(bots.dead_ent)
		local tex
		if team == "terrorist" then
			tex = "red."..math.random(1, 2)..".png"
		elseif team == "counter" then
			tex = "blue.png"
		else
			tex = "character.png"
		end
		new_table.textures = {tex}
		new_table.visual_size = {x = 1, y = 1, z = 1}
		died_players[bot2:get_bot_name()]:set_properties(new_table)
		died_players[bot2:get_bot_name()]:set_animation({x = 162, y = 166}, 15, 0)
		
		bots_nametags.rmv_to(bot2:get_bot_name())
		
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
			if type(bot) == "table" and bot.bot_raw_name and csgo.is_team(bot.team) then
				if csgo.max_bots ~= csgo.team[bot.team].bots_count then
					local bott = core.add_entity(maps.current_map.teams[bot.team], bot.bot_raw_name)
					local ent = bott:get_luaentity()
					bots.register_toteam_bot(bott)
					
					bots.bots_data[ent:get_bot_name()].usrdata = bott
					bots.bots_data[ent:get_bot_name()].entity = ent
					
					local def = bott:get_properties()
					def.is_visible = true
					def.makes_foostep_sound = true
					def.pointable = true
					def.show_on_minimap = true
					bott:set_properties(def)
					bott:set_animation(bots.bots_animations[bott:get_luaentity():get_bot_name()].stand, bots.bots_animations[bott:get_luaentity():get_bot_name()].anispeed, 0)
				end
			end
			bots.dead_bots[_] = nil
		end
	end,
	reset_bots = function()
		bots.respawn_bots()
		for name, tabled in pairs(bots.bots_data) do
			if name and tabled and not name:find("__") then
				if type(tabled.usrdata) == "userdata" then
					bots_nametags.rmv_to(tabled.usrdata:get_luaentity():get_bot_name())
					tabled.usrdata:remove()
				end
				
				-- Reset bot
				
				local bott = core.add_entity(maps.current_map.teams[tabled.team], tabled.rname)
				
				bott:set_pos(maps.current_map.teams[tabled.team])
				bott:set_hp(20)
				
				bots_nametags.add_to(bott:get_luaentity())
				
				local def = bott:get_properties()
				def.is_visible = true
				def.makes_foostep_sound = true
				def.pointable = true
				def.show_on_minimap = true
				bott:set_properties(def)
				bott:set_animation(bots.bots_animations[bott:get_luaentity():get_bot_name()].stand, bots.bots_animations[bott:get_luaentity():get_bot_name()].anispeed, 0)
				
				local ent = bott:get_luaentity()
				bots.bots_data[ent:get_bot_name()].usrdata = bott
				bots.bots_data[ent:get_bot_name()].entity = ent
				
			end
		end
	end,
	start_engine = function()
		if bots.enable ~= true then
			bots.log("error", "Bots engine is disabled")
			return
		end
		
		for name, contents in pairs(bots.bots_data) do
			if not name:find("__") then -- Test purposes
				--print(dump(contents))
				local team = contents.team
				local registered_name = contents.rname
				local bot = core.add_entity(maps.current_map.teams[team], contents.rname)
				bots.bots_data[name].usrdata = bot
				local ent = bot:get_luaentity()
				--print(bot:get_luaentity():get_bot_name(), bot:get_luaentity():get_team())
				bots.bots_data[name].entity = bot:get_luaentity()
				bot:set_animation(bots.bots_animations[name].stand, bots.bots_animations[name].anispeed, 0)
				bots.register_toteam_bot(bot, true)
			end
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
	end,
	witem = {},
	data_of_bots = {},
	timers = {},
	logic = dofile(core.get_modpath(core.get_current_modname()).."/logic_proccesor.lua")
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
	local team = def.team
	local metatable2 = metatable_registering
	metatable2.bot_data = {
		rifles = def.rifles,
		pistols = def.pistols,
		money = def.money or 200,
		name = def.bot_name,
		team = team,
		recharge = def.recharge or true,
	}
	
	
	local meta = {__index = metatable2}
	local mdef = {
		initial_properties = {
			--bot_name = def.bot_name, -- Karl, Crusher, etc
			--rifles = def.rifles,
			name = def.bot_name,
			hp_max = def.hp,
			--team = team,
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
			--spritediv = {x = 1, y = 1},
			is_visible = true,
			makes_footstep_sound = true,
			--automatic_rotate = 0,
			stepheight = def.sh,
			automatic_face_movement_dir = false,
			--automatic_face_movement_max_rotation_per_sec = -1,
			--backface_culling = false,
			nametag = "",
			infotext = "BOT "..def.bot_name,
			static_save = false,
			damage_texture_modifier = "^[brighten",
			shaded = true,
			show_on_minimap = true,
			dtimer1 = 0,
			dtimer2 = 0,
			
		},
		
		team = team,
		name = def.bot_name,
		rifles = def.rifles,
		bot_name = def.bot_name,
		
		on_step = mobkit.stepfunc, --function(self, dtime)
			--bots.do_act_bot(self, dtime)
		--end,
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
				bots.timers[self:get_bot_name()] = 0
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
			
			if not minetest.settings:get_bool("cs_core.enable_friend_shot", false) then
				mobkit.hurt(self, damage)
			end
			
		end,
		
		on_activate = mobkit.actfunc, --function(self)
		--	--setmetatable(self, metatable)
		--	self.object:set_velocity({x = 0, y = 0, z = 0})
		--	self.object:set_acceleration({x = 0, y = -bots.physics[self.object:get_luaentity():get_bot_name()].gravity, z = 0})
		--end,
		
		-- MobKit required fields
		
		logic = bots.logic,
		
		timeout = 0,
		buoyancy = -1,
		max_hp = def.hp,
		get_staticdata = mobkit.statfunc, -- MT Special
		max_speed = 2,
		view_range = bots.max_view_range,
		jump_height = 1,
		attack={range=1, damage_groups = {fleshy = 10} },
		animation = {
			walk = {range = animation.walk, speed = animation.speed, loop = true},
			attack = {range = animation.mine, speed = animation.speed, loop = true},
			stand = {range = animation.stand, speed = animation.speed, loop = true}
		},
		armor_groups = {fleshy = 100, immortal = 0}
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
	--print(dump(bots.bots_data))
	bots.bots_animations["BOT_"..def.bot_name] = {
		lay = animation.lay or animation.death,
		sit = animation.sit or animation.camp,
		stand = animation.stand or animation.noact,
		mine = animation.mine or animation.attack,
		walk = animation.walk,
		walk_mine = animation.wmine or animation.walk_attack,
		anispeed = animation.speed or 30,
	}
	--print(dump(bots.bots_data))
	bots.physics["BOT_"..def.bot_name] = {
		gravity = def.gravity or bots.default_gravity,
		jump = 1
	}
	bots.data_of_bots["BOT_"..def.bot_name] = {timer = 0}
	kills.add_to("BOT_"..def.bot_name, team)
	bots.timers["BOT_"..def.bot_name] = 0
end

local wield_entity = {
	initial_properties = {
		physical = false,
		collisionbox = {-0.125,-0.125,-0.125, 0.125,0.125,0.125},
		visual = "wielditem",
		textures = {"wield3d:hand"},
		wielder = nil,
		pointable = false,
		timer = 0,
		static_save = false,
	},
}

--Register some parts for env

local function gsf(dtime)
	for name, value in pairs(bots.queue_to_say) do
		if type(value) == "number" then
			bots.queue_to_say[name] = bots.queue_to_say[name] - dtime
		end
	end
end

core.register_globalstep(gsf)

core.register_entity(":bots:witem", wield_entity)























