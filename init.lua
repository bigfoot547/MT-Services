local nt_loop_running = minetest.settings:get_bool("nametag_loop")
local noob_loop_running = minetest.settings:get_bool("noob_loop")
local pos1, pos2 = {x = 4945, y = 4, z = -5005}, {x = 4935, y = -7, z = -4994}

function dbg(str)
	if minetest.get_player_by_name("Debug") ~= nil then
		minetest.chat_send_player("Debug", minetest.colorize("#FF0000", "DEBUG") .. ": " .. str)
	end
end

function nametag_mainloop()
	dbg("Starting nametag loop")
	local p

	for _,p in pairs(minetest.get_connected_players()) do
		local pname = p:get_player_name()
		local nametag = pname
		if minetest.get_player_privs(pname).server then
			nametag = "["..minetest.colorize("#FF0000", "ADMIN").."] " .. nametag
		end
		if pname == "bigfoot" then
			nametag = "["..minetest.colorize("#FF3030", "FIGBOOT").."] " .. nametag
		end
		if minetest.get_player_privs(pname).noob ~= nil then
			nametag = "["..minetest.colorize("#7F7F7F", "MINER").."] "..nametag
		end
		if pname == "Debug" then
			nametag = "["..minetest.colorize("#000000", "DEBUG").."] "..nametag
		end
		if minetest.get_player_privs(pname).interact ~= true then
			nametag = "["..minetest.colorize("#B0BFFF", "NEWBIE").."] "..nametag
		end
		p:set_nametag_attributes({text = nametag})
	end
	if not nt_loop_running then
		dbg("Nametag loop aborted.")
		minetest.chat_send_all("Nametag loop aborted.")
		return
	end
	dbg("Restarting loop again")
	minetest.after(5, mainloop)
end

function notify_noobs()
	local p

	for _,p in pairs(minetest.get_connected_players()) do
		local pname = p:get_player_name()
		local is_noob = minetest.get_player_privs(pname).noob ~= nil
		if is_noob then
			minetest.chat_send_player(pname, minetest.colorize("#007F00", "Refilling Mines!"))
		end
	end
end

function reset_mines()
	local stone = "default:stone"
	local coal_ore = "default:stone_with_coal"
	local iron_ore = "default:stone_with_iron"
	local gold_ore = "default:stone_with_gold"
	local mese_ore = "default:stone_with_mese"
	local diamond_ore = "default:stone_with_diamond"
	worldedit.set(pos1, pos2, {stone, stone, stone, stone, stone, stone, stone, stone,
		stone, stone, stone, stone, stone, stone, stone, stone, stone, stone, stone,
		stone, stone, stone, stone, stone, stone, stone, stone, stone, stone, stone,
		stone, stone, stone, stone, stone, stone, stone, stone, stone, stone, stone,
		stone, stone, stone, stone, stone, stone, stone, stone, stone, stone, stone,
		stone, stone, stone, stone, stone, stone, stone, stone, stone, stone, stone,
		stone, stone, stone, stone, stone, stone, stone, stone, stone, stone, stone,
		stone, coal_ore, coal_ore, coal_ore, coal_ore, coal_ore, coal_ore, iron_ore,
		iron_ore, iron_ore, gold_ore, gold_ore, mese_ore, diamond_ore})
end

function teleport_noobs()
	local p

	for _,p in pairs(minetest.get_connected_players()) do
		local pname = p:get_player_name()
		local is_noob = minetest.get_player_privs(pname).noob ~= nil
		local ppos = p:getpos()
		
		if is_noob and ppos.x <= pos1.x and ppos.x >= pos2.x and ppos.z >= pos1.z and ppos.z <= pos2.z then
			p:setpos({x = 4950, y = 5, z = -4999})
		end
	end
end

function noob_loop()
	local p
	local noob_found = false
	
	if not noob_loop_running then
		dbg("Noob timer disabled, aborting")
		minetest.chat_send_all("Noob timer aborted")
		return
	end
	
	for _,p in pairs(minetest.get_connected_players()) do
		if minetest.get_player_privs(p:get_player_name()).noob ~= nil then
			noob_found = true
			break
		end
	end
	
	if noob_found then
		notify_noobs()
		teleport_noobs()
		reset_mines()
	end
	dbg("60 seconds elapsed, restarting noob timer.")
	minetest.after(60, noob_loop)
end

minetest.register_chatcommand("start", {
	params = "<service>",
	description = "Starts a service",
	privs = {server = true},
	func = function(name, param)
		if param == "noob" then
			if noob_loop_running then
				return false, "Service [" .. param .. "] is already running."
			end
			
			noob_loop_running = true
			noob_loop()
			return true, "Service [" .. param .. "] started."
		elseif param == "nametag" then
			if nt_loop_running then
				return false, "Service [" .. param .. "] is already running."
			end
		
			nt_loop_running = true
			nametag_mainloop()
			return true, "Service [" .. param .. "] started."
		else
			return false, "Service not found."
		end
	end
})

minetest.register_chatcommand("stop", {
	params = "<service>",
	description = "Disables a service",
	privs = {server = true},
	func = function(name, param)
		if param == "noob" then
			if not noob_loop_running then
				return false, "Service [" .. param .. "] isn't running."
			end
		
			noob_loop_running = false
			return true, "Service [" .. param .. "] stopped."
		elseif param == "nametag" then
			if not nt_loop_running then
				return false, "Service [" .. param .. "] isn't running."
			end
		
			nt_loop_running = false
			return true, "Service [" .. param .. "] stopped."
		else
			return false, "Service not found."
		end
	end
})

-- Now we start the enabled services

if noob_loop_running then
	print("[Services] Noob loop service started as [noob]")
	noob_loop()
else
	print("[Services] Noob loop disabled, not starting")
end

if nt_loop_running then
	print("[Services] Nametag loop service started as [nametag]")
	nametag_mainloop()
else
	print("[Services] Nametag loop disabled, not starting")
end
