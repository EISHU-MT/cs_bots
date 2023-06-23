return function(self)
	mobkit.vitals(self)
	self.object:set_armor_groups({fleshy = 100, immortal = 0})
	local nearest_id = mobkit.get_nearby_player(self)
	local nearest_player = Player(nearest_id)
	local pos = self.object:get_pos()
	local priority = mobkit.get_queue_priority(self)
	if nearest_player and vector.distance(nearest_player:get_pos(), pos) <= 5 then
		if bots.find_path_to(self.object:get_pos(), pos) then
			if self:get_team() ~= csgo.check_team(Name(nearest_player)) then
				mobkit.hq_attack(self, mobkit.get_queue_priority(self), nearest_id)
				mobkit.lq_turn2pos(self, nearest_player:get_pos())
				return
			end
		end
	end
	
	if nearest_player and self.hp <= 10 and self:get_team() ~= csgo.check_team(Name(nearest_player)) then
		mobkit.hq_runfrom(self, mobkit.get_queue_priority(self), nearest_player)
	elseif nearest_player and self.hp > 10 and self:get_team() ~= csgo.check_team(Name(nearest_player)) then
		mobkit.hq_hunt(self, mobkit.get_queue_priority(self), nearest_player)
	end
	
	bots.do_act_bot(self, mobkit.get_queue_priority(self) < 10 and mobkit.get_queue_priority(self) or 0.05)
	
	pfw.on_step(self)
	
	if AEIOU then
		local player = Player("singleplayer")
		local pos = player:get_pos()
		pfw.insert_path(self, bots.find_path_to(self.object:get_pos(), pos))
		AEIOU = nil
		return
	end
	-- Central
	
	local stand_node = mobkit.nodeatpos(mobkit.get_node_pos(mobkit.get_stand_pos(self)))
	
	--local stand_rname, standid = arapi.detect_in(self)
	--local edges, edgesid = arapi.get_nearby_type(self, "door")
	
	--if stand_rname == nil and edges == nil then
	--	bots.log("error", "Can't find any area for bots!\nMaybe the map is incompatible with bots.")
	--elseif stand_rname and edges then
	--[[	if standid ~= edgesid then
			if bots.pathes[self:get_bot_name()] then
				if not (vector.distance(bots.pathes[self:get_bot_name()], self.object:get_pos()) <= 2) then
					mobkit.goto_next_waypoint(self, bots.pathes[self:get_bot_name()])
				else
					bots.pathes[self:get_bot_name()] = nil
				end
				--mobkit.drive_to_pos(self, bots.pathes[self:get_bot_name()], 2, 10, vector.distance(bots.pathes[self:get_bot_name()], self.object:get_pos()))
			else
				local path = bots.random_path(edges.low_pos, edges.upper_pos)
				bots.pathes[self:get_bot_name()] = path
			end
		end
	end--]]
	--[[
	if priority < 10 and mobkit.timer(self, 1) then
		if bots.get_closest_node(self, "door") then
			mobkit.hq_goto(self, priority, bots.get_closest_node(self, "door"))
			return
		end
	end--]]
	local teammate = bots.get_closest_teammate(self, true)
	if priority < 10 then
		mobkit.hq_follow(self, priority, teammate)
	end
	
	
	if mobkit.is_queue_empty_high(self) then
		mobkit.hq_roam(self, 2)
	end
	
	--if math.random(1, 200) <= 100 then -- chance
	
	--	return
	--end
	
	
	if c4.planted == true then
		mobkit.drive_to_pos(self, c4.pos, 1.3, 10, 300)
	end
	

	
	
	
	
end