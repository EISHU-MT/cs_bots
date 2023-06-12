local raw_metatable = {}
local function write_to_bot(data, name)
	bots.bots_data[name or "__example"] = data
end

function bots.reload_bank() -- callback
end

function raw_metatable:buy(arm, type)
	local money = bots.bots_data[self.name].money --self.money -- Bug
	local actual_thing
	local to_mod
	if type == "pistol" then
		actual_thing = self.actual_pistol or ""
		to_mod = "actual_pistol"
	elseif type == "rifle" then
		actual_thing = self.actual_rifle or ""
		to_mod = "actual_rifle"
	else
		return false, "type_not_found"
	end
	if actual_thing ~= arm and to_mod then
		local value = cs_shop.arms_values[arm] or 0
		if value ~= 0 and money >= value then
			self[to_mod] = arm
			bank.rm_player_value(self.name, value)
			write_to_bot(self, self.name)
			return true
		end
		return false, "no_money"
	else
		return false
	end
end

function raw_metatable:clear()
	self.actual_rifle = ""
	self.actual_pistol = ""
	write_to_bot(self, self.name)
end

function raw_metatable:destroy() -- Destroy the ref
	self = nil
	setmetatable(self, {__index = {}})
end

function bots.request_inv(botd)
	local bot_meta = {__index = raw_metatable, __newindex = function() end}
	local bot = botd
	return setmetatable(bot, bot_meta)
end