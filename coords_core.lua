bots.radius_to_area = function(center, r)
	return {
		x = center.x - r,
		y = center.y - r,
		z = center.z - r
	}, {
		x = center.x + r,
		y = center.y + r,
		z = center.z + r
	}
end

bots.is_vector = function(vector)
	return vector.x and vector.y and vector.z and type(vector.x) == "number" and type(vector.y) == "number" and type(vector.z) == "number"
end

bots.get_closest_teammate = function(self, bool)
	local objs = core.get_objects_inside_radius(self.object:get_pos(), 10)
	local players = {}
	local teammates = {}
	if bool then
		for i, obj in pairs(objs) do
			if obj:is_player() and csgo.check_team(Name(obj)) == self:get_team() then
				table.insert(players, obj)
			end
		end
		for _, player in pairs(players) do
			local opos = self.object:get_pos()
			local ppos = player:get_pos()
			if vector.distance(opos, ppos) <= 5 then
				return player
			end
		end
	else
		for i, obj in pairs(objs) do
			if obj:get_luaentity().bot_name or obj:is_player() and (csgo.check_team(obj:get_luaentity().bot_name or obj:get_player_name()) == self:get_team()) then
				table.insert(teammates, obj)
			end
		end
		for _, mate in pairs(teammates) do
			local opos = self.object:get_pos()
			local ppos = mate:get_pos()
			if vector.distance(opos, ppos) <= 5 then
				return mate
			end
		end
	end
end

bots.get_nearest_enemy = function(self)
	local objs = core.get_objects_inside_radius(self.object:get_pos(), 200)
	local team = self:get_team()
	local pos = self.object:get_pos()
	local objs2 = {}
	local nearest_enemy
	local enemys = {}
	for i, obj in pairs(objs) do
		if obj:get_properties().infotext:find("BOT") then
			table.insert(objs2, obj)
		elseif obj:is_player() then
			table.insert(objs2, obj)
		end
	end
	for i, obj in pairs(objs2) do
		if obj:get_properties().infotext:find("BOT") then
			local luaentity = obj:get_luaentity()
			if luaentity and luaentity:get_team() and (luaentity:get_team() == "terrorist" or luaentity:get_team() == "counter") then
				if luaentity:get_team() ~= team then
					if vector.distance(obj:get_pos(), pos) <= 80 then
						table.insert(enemys, obj)
					end
				end
			end
		elseif obj:is_player() then
			local eteam = csgo.check_team(Name(obj))
			if eteam ~= "" and eteam ~= "spectator" then
				if eteam ~= team then
					if vector.distance(obj:get_pos(), pos) <= 80 then
						table.insert(enemys, obj)
					end
				end
			end
		end
	end
	for i, obj in pairs(enemys) do
		if vector.distance(obj:get_pos(), pos) <= 70 then
			return obj
		end
	end
end

bots.get_closest_node = function(self, typeof)
	if typeof == "door" then
		local node = core.find_node_near(self.object:get_pos(), 10, "bots:invisible_door", false)
		--print(dump(node)..self.bot_name)
		if node then
			
			return node
		end
	end
end

bots.convert_pos_to_path = function(self, to_pos)
	local path = bots.find_path_to(self.object:get_pos(), to_pos)
	if path then
		return path
	else
		return {}
	end
end
local r = math.random
bots.random_path = function(minedge, maxedge_raw)
	local maxedge = {x = maxedge_raw.x, y = minedge.y, z = maxedge_raw.z} -- Convert
	local X = r(minedge.x, maxedge.x)
	local Y = minedge.y -- Dont randomize the `Y` Axis
	local Z = r(minedge.z, maxedge.z)
	return vector.new(X, Y, Z)
end






