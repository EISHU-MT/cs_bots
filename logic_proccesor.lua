
return function(self)
	mobkit.vitals(self)
	local nearest_id = mobkit.get_nearby_player(self)
	local nearest_player = Player(nearest_id)
	local pos = self.object:get_pos()
	if nearest_player and vector.distance(nearest_player:get_pos(), pos) <= 5 then
		if bots.find_path_to(self.object:get_pos(), pos) then
			if self:get_team() ~= csgo.check_team(Name(nearest_player)) then
				mobkit.hq_attack(self, mobkit.get_queue_priority(self), nearest_id)
				mobkit.lq_turn2pos(self, nearest_player:get_pos())
				return
			end
		end
	end
	--if math.random(1, 200) <= 100 then -- chance
		if nearest_player and self.hp <= 10 and self:get_team() ~= csgo.check_team(Name(nearest_player)) then
			mobkit.hq_runfrom(self, mobkit.get_queue_priority(self), nearest_player)
		elseif nearest_player and self.hp > 10 and self:get_team() ~= csgo.check_team(Name(nearest_player)) then
			mobkit.hq_hunt(self, mobkit.get_queue_priority(self), nearest_player)
		end
	--	return
	--end
	bots.do_act_bot(self, mobkit.get_queue_priority(self) < 10 and mobkit.get_queue_priority(self) or 0.05)
	
	if c4.planted == true then
		mobkit.drive_to_pos(self, c4.pos, 1.3, 10, 300)
	end
	
	if math.random(1, 200) <= 100 then -- chance
		local teammate = bots.get_closest_teammate(self, true)
		mobkit.hq_follow(self, mobkit.get_queue_priority(self), teammate)
	end
	
	self.object:set_armor_groups({fleshy = 100, immortal = 0})
end