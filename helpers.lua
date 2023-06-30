function bots.get_good_arm_by_money(arms, money2, name)
	local money = tonumber(money2)
	local i = 0
	--[[for _, arm in pairs(arms) do
		i = i + 1
		if ItemStack(arm) then
			--print(money, type(money))
			if cs_shop.arms_values[arm] and money >= cs_shop.arms_values[arm] and (cs_shop.arms_values[actual] or 0) < cs_shop.arms_values[arm] then
				return arm
			else
				return arm
			end
		end
	end--]]
	local a = arms
	table.sort(a, function (n1, n2) return cs_shop.arms_values[n1] < cs_shop.arms_values[n2] end)
	for _, arm in pairs(a) do
		--print(arm, cs_shop.arms_values[arm], name)
		if cs_shop.arms_values[arm] <= money and ((a[_ + 1] and cs_shop.arms_values[a[_ + 1]]) and (cs_shop.arms_values[a[_ + 1]] > money)) then
			return arm
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