# CS:MT Bots Engine (API)
This provides a API that allows to register **bots**

**Note:** Work In Progress & Beta. This mod may crash from something by trying the bots [=> examples](/examples).

## API
This example may help:
```lua
bots.register_bot("modname:name_of_bot", {
	bot_name = "Crusher", -- Name of bot, dont include "BOT_"!
	rifles = {"rangedweapons:ak47"}, -- Favorite rifles for the bot
	pistols = {"rangedweapons:luger"}, -- Favorite pistols/smgs for the bot
	hp = 20, -- HP, Max HP
	group = "terrorist", -- Team. counter or terrorist
	model = "character.b3d", -- Mesh for bot
	textures = {"red.1.png"}, -- Textures for mesh
	recharge = true, -- Recharge rifle & pistol & smg. (Optional=true)
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3}, -- Collision Box, selectionbox is Collision Box.
	sh = 0.6, -- Step height
}, { -- Animations
	stand = {x = 0, y = 79}, -- Stand
	lay = {x = 162, y = 166}, -- Lay (Used when bot died)
	walk = {x = 168, y = 187}, -- Walk
	mine = {x = 189, y = 198}, -- Mining, when bot shoots
	wmine = {x = 200, y = 219}, -- Walk mining, when bot walks and shoots
	sit = {x = 81, y = 160}, -- Sit
})
```
## Warnings
Do not use this bot engine for play, this is a unfinished mod for cs:mt!

### To Do (Optional)
- Apply gravity to bot
- Make bot do some action `bots.do_act_bot()`
- fix on_kill.lua
