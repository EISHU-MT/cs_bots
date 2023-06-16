bmv = {queues={}, d = {}, timer = 0} -- Declare this
--[[
	Movements for bots (CS:MT)
	Guys that have helped for this code:
		~Panquesito7 (Gives ideas for bots movements [functions])
--]]
-- name: String, name of bot. vname: String, name of variable. data: All, data to be saved
local function save(name, vname, data)
	bots.data_of_bots[name][vname] = data
end

-- Same as save, returning the data and not saving ^^
local function get(name, vname)
	return bots.data_of_bots[name][vname]
end

-- pos: Table, vector to look. self: Table, self of bot
local function point_to(pos, self, save_position)
	if not self.object then
		return false
	end
	local central_pos = self.object:get_pos()
	if not central_pos then return false end
	local dir = vector.direction(central_pos, pos)
	local yaw = core.dir_to_yaw(dir)
	self.object:set_yaw(yaw)
	if save_position then
		save(self:get_bot_name(), "to_pos", pos)
	end
	return true
end

-- self: Table, self of bot. s: Number, speed multiplyer
local function advance_from_yaw(self, s)
	if not self then return false end
	if not self.object then return false end
	if get(self:get_bot_name(), "is_moving") then return true end
	
	local dir = core.yaw_to_dir(self.object:get_yaw())
	local multiplied_dir = vector.multiply(dir, s)
	self.object:set_velocity(multiplied_dir)
	
	-- Register to the bots.data_of_bots
	save(self:get_bot_name(), "is_moving", true)
end

-- pos: Table, vector for pos
local function find_any_gates(pos, n)
	if not bots.is_vector(pos) then return false end
	
	local down_corner, up_corner = bots.radius_to_area(pos, 15)
	
	local nodes = {}
	
	for i, pos in pairs(core.find_nodes_in_area(down_corner, up_corner), {"bots:invisible_door", "bots:marker_camp"}) do
		local next_node = vector.add(pos, {x = 0, y = 1, z = 0})
		if not n then
			if core.get_node(next_node).name == "air" then
				return pos, core.get_node(pos)
			end
		end
		if get(n, "used_node") ~= core.get_node(pos).name then
			if core.get_node(next_node).name == "air" then
				return pos, core.get_node(pos)
			end
		end
	end
end

-- self: Table, bot data
local function do_something(self)
	local to_pos, node = find_any_gates(self.object:get_pos(), self:get_bot_name())
	print(dump(to_pos), dump(node))
	if to_pos and get(self:get_bot_name(), "is_moving") ~= true then
		point_to(to_pos, self, true)
		advance_from_yaw(self, 1.3)
		save(self:get_bot_name(), "used_node", node)
	end
end

local function cancel_velocity(self)
	return self.object:set_velocity(vector.new(0,0,0))
end

local function random_walk(self)
	local max = 360
	local r = math.random(1, max)
	print(r)
	self.object:set_yaw(r)
	local formed = FormRandomString(5)
	bmv.d[formed] = self
	advance_from_yaw(self, 1.3)
	save(self:get_bot_name(), "is_walking_random", true)
end

local function is_near(pos1, pos2)
	local saved_cfg = 0.5 -- can be changeable
	if vector.distance(pos1, pos2) <= saved_cfg then
		return true
	else
		return false
	end
end

local function run_hooks(dt)
	for name, contents in pairs(bots.data_of_bots) do
		if contents.is_moving then
			if contents.is_walking_random then
				if os.time() % 1 == 0 then
					cancel_velocity(bots.bots_data[name].usrdata:get_luaentity())
					save(name, "is_walking_random", false)
				end
			else
				if contents.is_moving and contents.to_pos then
					if is_near(bots.bots_data[name].usrdata:get_pos(), contents.to_pos) then
						cancel_velocity(bots.bots_data[name].usrdata:get_luaentity())
						save(bots.bots_data[name].usrdata:get_luaentity():get_bot_name(), "is_moving", false)
						save(bots.bots_data[name].usrdata:get_luaentity():get_bot_name(), "to_pos", {})
					else
						local dir = vector.direction(bots.bots_data[name].usrdata:get_pos(), contents.to_pos)
						local yaw = core.dir_to_yaw(dir)
						bots.bots_data[name].usrdata:set_yaw(yaw) -- Update bot horizontal view
					end
				end
			end
		end
		--print(dump(contents))
	end
--[[	for name, c in pairs(bots.bots_data) do
		if c.usrdata and type(c.usrdata) == "userdata" then
			if c.usrdata:get_velocity() == vector.new(0,0,0) then
				save(name, "is_moving", false)
			elseif c.usrdata:get_velocity().x ~= 0 or c.usrdata:get_velocity().y ~= 0 or c.usrdata:get_velocity().z ~= 0 then
				save(name, "is_moving", true)
			end
		end
	end--]]
	bmv.timer = bmv.timer + dt
	for _, queued in pairs(bmv.queues) do
		if bmv.timer >= 0.2 then
			queued(_)
			bmv[_] = nil
			bmv.timer = 0
		end
	end
end

local function advance_bot(self)
	local nu = math.random(1, 3)
	--if os.time() % 1 ~= 0 then
	--	return
--	end
	--Get a current node
	if cs_match.commenced_match == false then
		return
	end
	if bmv.get(self:get_bot_name(), "is_moving") ~= true then
		--error()
		print("EXEC")
		if nu == 1 then
			do_something(self)
			print("aaaaaaaaaaaaaaaa")
		elseif nu == 2 then
			random_walk(self)
			print("RANDOM WALK")
		elseif nu == 3 then
			advance_from_yaw(self, 2)
		end
	end
end

-- Declare all!

bmv = {
	save = save,
	get = get,
	point_to = point_to,
	advance_from_yaw = advance_from_yaw,
	find_any_gates = find_any_gates,
	do_something = do_something,
	cancel_velocity = cancel_velocity,
	random_walk = random_walk,
	is_near = is_near,
	run_hooks = run_hooks,
	advance_bot = advance_bot,
	
	queues = {},
	d = {},
	
	timer = 0
}

core.register_globalstep(run_hooks)




