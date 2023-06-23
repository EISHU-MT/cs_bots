arapi = {
	areas = {}
}
-- Globals without `arapi`
arapi_is_loaded = true

-- Functions
function arapi.reload_all_areas(map)
	if map.bots_areas then
		arapi.areas[map.name] = {doors = {}, sector = {}, walker_area = {}, prohibited_area = {}, pool = {}, lava = {}, spawn = {}}
		for id_name, contents in pairs(map.bots_areas) do
			local category, id = unpack(id_name:split("-"))
			arapi.areas[map.name][category][id] = contents
		end
	end
end

function arapi.detect_in(self)
	local pos = self.object:get_pos()
	if arapi.areas[maps.current_map.name] then
		for category, contents in pairs(arapi.areas[maps.current_map.name]) do
			for id, edges in pairs(contents) do
				local area = VoxelArea:new({MinEdge = edges.low_pos, MaxEdge = edges.upper_pos})
				if area:containsp(pos) then
					return category, id, area, pos
				end
			end
		end
	else
		return nil, nil, nil, nil
	end
end

local d = vector.distance

function arapi.get_nearby_type(self, typeof)
	local pos = mobkit.get_stand_pos(self)
	-- Verify
	if arapi.areas[maps.current_map.name] then
		if arapi.areas[maps.current_map.name][typeof] then
			for id, edges in pairs(arapi.areas[maps.current_map.name][typeof]) do
				if d(pos, edges.low_pos) >= 13 and d(pos, edges.low_pos) <= 4 then
					return edges, id
				end
			end
		else
			return nil
		end
	else
		return nil
	end
end