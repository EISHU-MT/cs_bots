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
		table.insert(bots.dead_bots, {entity = bot, team = team or bot2:get_team()})
		local def = bot:get_properties()
		def.is_visible = false
		def.makes_foostep_sound = false
		def.pointable = false
		def.show_on_minimap = false
		bot:set_properties(def)
	end,
	respawn_bots = function()
		if not maps.current_map.enable_bots then
			bots.log("warning", "Map "..maps.current_map.name.." inst available for bots!")
		--	return
		end
		for _, bot in pairs(bots.dead_bots) do
			if type(bot) == "table" and type(bot.entity) == "userdata" and csgo.is_team(bot.team) then
				if csgo.max_bots ~= csgo.teams[bot.team].bots_count then
					bots.register_toteam_bot(bot.entity)
				end
			end
		end
	end,
	reset_bots = function()
		if not maps.current_map.enable_bots then
			bots.log("warning", "Map "..maps.current_map.name.." inst available for bots!")
		--	return
		end
		bots.respawn_bots()
		for name, tabled in pairs(bots.bots_data) do
			if name and tabled then
				if vector.distance(maps.current_map.teams[tabled.team], tabled.usrdata:get_pos()) > 2 then
					tabled.usrdata:set_pos(maps.current_map.teams[tabled.team])
					tabled.usrdata:set_hp(tabled.entity:get_bot_maxhp())
				end
			end
		end
	end,
	start_engine = function()
		if not maps.current_map.enable_bots then
			bots.log("warning", "Map "..maps.current_map.name.." inst available for bots!")
		--	return
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
	do_act_bot = function() end,
	do_gravity = function(entity, dtime, gravity, ended)
		local inf = entity:get_properties()
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
		end
	end,
	physics = {
		__example = {
			-- Gravity (Fall peer node)
			gravity = 1,
			-- Jump (velocity.y + jump value peer second, jump nodes peer second.)
			jump = 1
		},
	},
	end_velocity_y = tonumber(minetest.settings:get("cs_core.end_velocity_y", "0") or 0)
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
	return self.object:get_properties().bot_data
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
			rifles = def.rifles, -- {"192" = "rangedweapons:ak47"}
			name = def.bot_name,
			hp_max = def.hp,
			team = team,
			--eye_height = 1.625,
			physical = false,
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
			damage_texture_modifier = "",
			shaded = true,
			show_on_minimap = true,
			dtimer1 = 0,
			dtimer2 = 0,
			
		},
		
		on_step = function(self, dtime)
			bots.do_act_bot(self.bot_name, self.team, self, dtime)
		end,
		on_rightclick = function(self, clicker)
			local player = Player(clicker)
			local name = Name(clicker)
			local entity = self.object:get_luaentity()
			local team = self.team
			print(dump(self))
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
					
					bots.on_kill(self.object, player, damage, self, "bot")
					
				end
				
				core.log("error", "---")
				
				--return false
				
				
				
			--end
			--return false
		end,
		--[[
		on_activate = function(self)
			setmetatable(self, metatable)
		end,--]]
	}
	core.register_entity(name, setmetatable(mdef, metatable))
	bots.bots_data["BOT_"..def.bot_name] = {
		name = "BOT_"..def.bot_name,
		money = "200",
		actual_rifle = "",
		team = team,
		actual_pistol = "",
		recharge = true,
		usrdata = {},
		rname = name,
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
		gravity = 1,
		jump = 1
	}
	kills.add_to("BOT_"..def.bot_name, team)
end

--Register some parts for env

local function gsf(dtime)
	for name, contents in pairs(bots.physics) do
		if type(bots.bots_data[name].usrdata) == "userdata" then
			bots.do_gravity(bots.bots_data[name].usrdata, dtime, contents.gravity, ended)
		end
	end
end

core.register_globalstep(gsf)
























