local max_lengh = tonumber(minetest.settings:get("cs_core.max_path_finder_lengh", "100") or 100)
function bots.find_path_to(start_pos, end_pos)
	local path = minetest.find_path(start_pos, end_pos, max_lengh or 100, 1, 1, "A*")
	return path
end
