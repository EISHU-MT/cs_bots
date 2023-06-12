minetest.register_on_shutdown(function()
	for name, botd in pairs(bots.bots_data) do
		if type(botd.usrdata) == "userdata" then
			botd.usrdata:remove()
		end
	end
end)