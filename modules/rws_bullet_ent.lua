local function on_step(self, dtime, mr)
	if mr.collides ~= true and self.timer >= 10 then
		self.object:remove()
		return
	end
	if mr.collides == true then
		local collisions = mr.collisions[1]
		if not collisions then
			return
		end
		if collisions.type == "object" then
			local obj = collisions.object
			if type(self.owner) ~= "userdata" then -- avoid crash from this
				return
			end
			collisions.object:punch(self.owner, nil, {damage_groups = self.damage}, nil)
			self.object:remove()
		elseif collisions.type == "node" then
			minetest.add_particle({
				pos = self.object:get_pos(),
				velocity = {x=0, y=0, z=0},
				acceleration = {x=0, y=0, z=0},
				expirationtime = 30,
				size = math.random(10,20)/10,
				collisiondetection = false,
				vertical = false,
				texture = "rangedweapons_bullethole.png",
				glow = 0,
			})
			self.object:remove()
			return
		end
		if self.timer >= 10 then
			self.object:remove()
		end
	end
	--print(dump(mr.collisions))
	
	if not mr.collisions[1] then
		return
	end
	
	--print(dump(mr.collisions[1]))
	--print(dump(mr.collisions[1].old_velocity))
	
	--[[local objVel = mr.collisions[1] ~= nil and mr.collisions[1].old_velocity
	local objRot = self.object:get_rotation()
	
	if objRot and objVel then
		if moveresult.collisions[1].axis == "x" then
			self.object:set_rotation({x=0,y=objRot.y,z=objRot.z+3})
			self.object:set_velocity({x=objVel.x*-1,y=objVel.y,z=objVel.z})
		end
		if moveresult.collisions[1].axis == "z" then
			self.object:set_rotation({x=0,y=objRot.y,z=objRot.z+3})
			self.object:set_velocity({x=objVel.x,y=objVel.y,z=objVel.z*-1})
		end
		if moveresult.collisions[1].axis == "y" then
			self.object:set_rotation({x=0,y=objRot.y+3,z=objRot.z+3})
			self.object:set_velocity({x=objVel.x,y=objVel.y*-1,z=objVel.z})
		end
	end--]]
	self.timer = self.timer + dtime
end

local def = {
	timer = 0,
	initial_properties = {
		physical = true,
		hp_max = 420,
		glow = core.LIGHT_MAX,
		visual = "sprite",
		visual_size = {x=0.4, y=0.4},
		textures = {"bullet2.png"},
		lastpos = {},
		collide_with_objects = true,
		collisionbox = {-0.0025, -0.0025, -0.0025, 0.0025, 0.0025, 0.0025},
	},
	owner = {},
	damage = bots.default_bullet_damage, -- Default
	on_step = on_step
}

core.register_entity(":bots:bullet", def)