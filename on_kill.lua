bots.on_kill = function(bot, hitter, damage, self, state) -- bot == bot have been hurted, else player have been hurted by bot
	if type(bot) == "userdata" then
		if state == "bot" then
			if cs_match.commenced_match == true then --Be sure if the match is continued or a fail.
				local pname
				
				if hitter and not hitter:get_properties().infotext:find("BOT") then -- for now
					pname = hitter:get_player_name()
				elseif hitter and hitter:get_properties().infotext:find("BOT") then
					pname = hitter:get_luaentity():get_bot_name()
				end
				
				local victim = "BOT_"..self.bot_name
				
				if victim and pname and victim == pname then
					return
				end
				
				--if reason.type == "punch" and reason.object then
				if not victim or not pname then
					return
				end
				
				if csgo.pot[victim] == csgo.pot[pname] then -- They suicide and win, this is not ok >:(
					if csgo.team[csgo.pot[victim]].total_count - 1 <= 0 and csgo.team[csgo.enemy_team(csgo.pot[victim])].total_count == 1 then
						local t = csgo.enemy_team(csgo.pot[victim])
						
						local random = Randomise("Select random", {"The last alive player is: "..victim, "The team "..csgo.enemy_team(csgo.pot[victim]).." had only 1 player!"})
						
						bots.register_deadbot(bot, csgo.pot[victim])
						annouce.winner(t, random)
						cs_match.finish_match(csgo.pot[pname])
						cs_kill.run_callbacks(victim, nil, nil, csgo.pot[victim])
						
						
					elseif csgo.team[csgo.pot[victim]].total_count - 1 < 0 then
						local t = csgo.enemy_team(csgo.pot[victim])
						local random = Randomise("Select random", {"The last BOT that do suicide is: "..victim, "The team "..t.." did his job"})
						annouce.winner(t, random)
						cs_match.finish_match(csgo.pot[pname])
						cs_kill.run_callbacks(victim, nil, nil, csgo.pot[victim])
						bots.register_deadbot(bot, csgo.pot[victim])
						
					else
						--if died[victim] ~= true then 
							if cs_match.commenced_match ~= false then
								if hitter:get_player_name() and hitter:get_player_name() ~= "" then
									local a1 = hitter:get_inventory() and hitter:get_wielded_item() and hitter:get_wielded_item() ~= "" and hitter:get_wielded_item() or ItemStack(bots.actual_items[pname])
									local image = a1:get_definition().inventory_image or "cs_files_hand.png"
									
									local hitter_name = hitter:get_player_name() ~= "" and hitter:get_player_name() or hitter:get_luaentity() and hitter:get_luaentity().bot_name and "BOT "..hitter:get_luaentity().bot_name
									
									cs_kh.add(pname, "BOT "..self.bot_name, image, "", csgo.pot[victim])
									
									cs_kill.run_callbacks(victim, pname, nil, csgo.pot[victim])
									
									bots.register_deadbot(bot, csgo.pot[victim])
									
									csgo.blank(victim, csgo.pot[victim])
								else
									print(dump(bots.bots_data[pname]))
									local a1 = ItemStack(bots.actual_items[pname])
									local image = a1:get_definition().inventory_image or "cs_files_hand.png"
									
									local err = image == nil
									
									local exc = ""
									
									if err then
										exc = "(!)"
									end
									
									local hitter_name = hitter:get_player_name() ~= "" and hitter:get_player_name() or hitter:get_luaentity() and hitter:get_luaentity().bot_name and "BOT "..hitter:get_luaentity().bot_name
									
									cs_kh.add(pname, "BOT "..self.bot_name, image, exc, csgo.pot[victim])
									
									cs_kill.run_callbacks(victim, pname, nil, csgo.pot[victim])
									
									bots.register_deadbot(bot, csgo.pot[victim])
									
									csgo.blank(victim, csgo.pot[victim])
								end
							end
						--end
					end
					return
				else
					if csgo.team[csgo.pot[victim]].total_count - 1 <= 0 and csgo.team[csgo.pot[pname]].total_count == 1 then
						local random = Randomise("Select random", {"The last alive player/bot is: "..pname, "the team "..csgo.pot[pname].." had only 1 player!", "wajaaaa"})
						annouce.winner(csgo.pot[pname], random)
						cs_match.finish_match(csgo.pot[pname])
						cs_kill.run_callbacks(victim, pname, csgo.pot[pname], csgo.pot[victim])
						bots.register_deadbot(bot, csgo.pot[victim])
					elseif csgo.team[csgo.pot[victim]].total_count - 1 <= 0 and victim and csgo.pot[pname] then
						local random = Randomise("Select random", {"The last killed player/bot is: "..victim, "the team "..csgo.pot[pname].." did his job", "wajaaa"})
						annouce.winner(csgo.pot[pname], random)
						cs_match.finish_match(csgo.pot[pname])
						cs_kill.run_callbacks(victim, pname, csgo.pot[pname], csgo.pot[victim])
						bots.register_deadbot(bot, csgo.pot[victim])
					else
						--if died[victim] ~= true then 
							if cs_match.commenced_match ~= false then
								if hitter:get_player_name() and hitter:get_player_name() ~= "" then
									local a1 = hitter:get_inventory() and hitter:get_wielded_item() and hitter:get_wielded_item() ~= "" and hitter:get_wielded_item() or ItemStack(bots.actual_items[pname])
									local image = a1:get_definition().inventory_image or "cs_files_hand.png"
									
									local hitter_name = hitter:get_player_name() ~= "" and hitter:get_player_name() or hitter:get_luaentity() and hitter:get_luaentity().bot_name and "BOT "..hitter:get_luaentity().bot_name
									
									cs_kh.add(pname, "BOT "..self.bot_name, image, "", csgo.pot[victim])
									
									cs_kill.run_callbacks(victim, pname, csgo.pot[pname], csgo.pot[victim])
									
									bots.register_deadbot(bot, csgo.pot[victim])
									
									csgo.blank(victim, csgo.pot[victim])
								else
									local a1 = ItemStack(bots.actual_items[pname])
									local image = a1:get_definition().inventory_image or "cs_files_hand.png"
									
									local hitter_name = hitter:get_player_name() ~= "" and hitter:get_player_name() or hitter:get_luaentity() and hitter:get_luaentity().bot_name and "BOT "..hitter:get_luaentity().bot_name
									
									cs_kh.add(pname, "BOT "..self.bot_name, image, "", csgo.pot[victim])
									
									cs_kill.run_callbacks(victim, pname, csgo.pot[pname], csgo.pot[victim])
									
									bots.register_deadbot(bot, csgo.pot[victim])
									
									csgo.blank(victim, csgo.pot[victim])
								end
							end
						--end
					end
				end
				
			else
				return true
			end
		elseif state == "player" then
			if cs_match.commenced_match ~= true then
				return true
			end
			
			local player = bot
			
			if player:get_hp() > 0 and player:get_hp() - damage <= 0 and csgo.pot[victim] and csgo.pot[victim] ~= "spectator" then
				died_players[player:get_player_name()] = minetest.add_entity(player:get_pos(), "cs_player:dead_ent")
				local new_table = table.copy(bots.dead_ent)
				local tex
				if csgo.pot2[Name(player)] == "terrorist" then
					tex = "red.png"
				elseif csgo.pot2[Name(player)] == "counter" then
					tex = "blue.png"
				else
					tex = "character.png"
				end
				new_table.textures = {tex}
				new_table.visual_size = {x = 1, y = 1, z = 1}
				died_players[player:get_player_name()]:set_properties(new_table)
				died_players[player:get_player_name()]:set_animation({x = 162, y = 166}, 15, 0)
				--player_set_animation(player, "lay")
				
				local value5 = csgo.team[csgo.pot[victim]].count - 1
				function empty() end
				if victim and csgo.pot[victim] and csgo.pot[victim] ~= "spectator" then
					if value5 <= 0 then
						print()
					else
						ccore[victim] = csgo.pot2[victim]
					end
				end
			else
				return -- Avoid some bugs
			end
			
			local pname
			if hitter and not hitter:get_properties().infotext:find("BOT") then -- for now
				pname = hitter:get_player_name()
			elseif hitter and hitter:get_properties().infotext:find("BOT") then
				pname = hitter:get_luaentity():get_bot_name()
				--return true
			end
			
			local victim = bot:get_player_name()
			
			if victim and pname and victim == pname then
				return true
			end
			
			--if reason.type == "punch" and reason.object then
			if not victim or not pname then
				return
			end
			
			if csgo.pot[victim] == csgo.pot[pname] then -- They suicide and win, this is not ok >:(
				if csgo.team[csgo.pot[victim]].total_count - 1 <= 0 and csgo.team[csgo.enemy_team(csgo.pot[victim])].total_count == 1 then
					local t = csgo.enemy_team(csgo.pot[victim])
					
					local random = Randomise("Select random", {"The last alive player is: "..csgo.team[t].players[1], "The team "..csgo.enemy_team(csgo.pot[victim]).." had only 1 player!"})
					
					annouce.winner(t, random)
					cs_match.finish_match(csgo.pot[pname])
					cs_kill.run_callbacks(victim, nil, nil, csgo.pot[victim])
					--bots.respawn_bots()
					
				elseif csgo.team[csgo.pot[victim]].total_count - 1 <= 0 then
					local t = csgo.enemy_team(csgo.pot[victim])
					local random = Randomise("Select random", {"The last player that do suicide is: "..victim, "The team "..t.." did his job"})
					annouce.winner(t, random)
					cs_match.finish_match(csgo.pot[pname])
					cs_kill.run_callbacks(victim, nil, nil, csgo.pot[victim])
					--bots.respawn_bots()
				else
					if died[victim] ~= true then 
						if cs_match.commenced_match ~= false then
							local a1 = ItemStack(bots.actual_items[victim])
							local image = a1:get_definition().inventory_image or "cs_files_hand.png"
							cs_kh.add(pname, victim, image, "", csgo.pot[victim])
							
							cs_kill.run_callbacks(victim, nil, nil, csgo.pot[victim])
							
							ccore[victim] = csgo.pot2[victim]
							--bots.register_deadbot(bot, csgo.pot[victim])
							
							bank.player_add_value(pname, 60)
							
							csgo.blank(victim, csgo.pot[victim])
							
							csgo.spectator(victim)
							csgo.send_message(victim .. " will be a spectator. because he died. ", "spectator")
						end
					end
				end
				return
			else
				if csgo.team[csgo.pot[victim]].total_count - 1 == 0 and csgo.team[csgo.pot[pname]].total_count == 1 then
					local random = Randomise("Select random", {"The last alive player is: "..pname, "the team "..csgo.pot[pname].." had only 1 player!", "wajaaaa"})
					annouce.winner(csgo.pot[pname], random)
					cs_match.finish_match(csgo.pot[pname])
					cs_kill.run_callbacks(victim, pname, csgo.pot[pname], csgo.pot[victim])
					--bots.respawn_bots()
				elseif csgo.team[csgo.pot[victim]].total_count - 1 == 0 and victim and csgo.pot[pname] then
					local random = Randomise("Select random", {"The last killed player is: "..victim, "the team "..csgo.pot[pname].." did his job", "wajaaa"})
					annouce.winner(csgo.pot[pname], random)
					cs_match.finish_match(csgo.pot[pname])
					cs_kill.run_callbacks(victim, pname, csgo.pot[pname], csgo.pot[victim])
					--bots.respawn_bots()
				else
					if died[victim] ~= true then 
						if cs_match.commenced_match ~= false and bot:get_luaentity() and bots.bots_data[bot:get_luaentity():get_bot_name()] then
							local a1 = ItemStack(bots.actual_items[victim])
							local image = a1:get_definition().inventory_image or "cs_files_hand.png"
							cs_kh.add(pname, victim, image, "", csgo.pot[victim])
							
							cs_kill.run_callbacks(victim, pname, csgo.pot[pname], csgo.pot[victim])
							
							bank.player_add_value(pname, 60)
							
							ccore[victim] = csgo.pot2[victim]
							
							csgo.blank(victim, csgo.pot[victim])
							csgo.spectator(victim)
							csgo.send_message(victim .. " will be a spectator. because he died. ", "spectator")
						end
					end
				end
			end
		end
	end
end