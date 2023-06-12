function bots.get_good_arm_by_money(arms, money2)
	local money = tonumber(money2)
	local i = 0
	for _, arm in pairs(arms) do
		i = i + 1
		if ItemStack(arm) then
			--print(money, type(money))
			if cs_shop.arms_values[arm] and money >= cs_shop.arms_values[arm] then
				return arm
			else
				return arm
			end
		end
	end
end

function bots.buy_if_dont_had(arm, data, type)
	if arm and data and type then
		if data["actual_"..type] ~= arm then --hack
			local ref = bots.request_inv(data)
			return ref:buy(arm, type)
		end
	end
end