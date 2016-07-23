--[[
The Official MessWithPlayers script by Lavacoal123
Initially unfucked by meharryp.
Modulised (?) by Dr Internet.
Deviations of this script must be posted on GitHub (http://www.github.com)
Copyright - Creative Commons Attribution Non-Commercial License
]]--

--[[ Structure: Command Data
required
callback: function(ply, cmd, args) - The function that is run if the user passes validity checks

optional
rank: string for the rank. (user (true), admin (IsAdmin), superadmin (IsSuperAdmin) or other (IsUserGroup) - If blank then assumes admin, unless accessFunc is filled.
accessFunc: function(ply) a function that is called to check if a user has access to a command. return true to allow access, false to deny, blank to try rank, if data.rank is not null.
failMsg: string to explain why a check failed. Defaults to "You do not have the correct rank for this command."
minArgs: integer with the minimum number of arguments required for the function to work. If ommited, it is assumed that no arguments are required.
]]--

-- This function takes a player's name as an input, returning the player data if found.
-- FindPlayer(string), returns Player
local function FindPlayer(ply)
	for k, v in pairs(player.GetAll()) do
		if string.find(v:Name():lower(), ply:lower()) then
			return v
		end
	end
end

-- This function takes the name and data for a command, and creates it.
-- AddCommand(string, table), returns Nil
local function AddCommand(name, data)
	-- Start by checking the validity of the data passed to the function.
	-- Assert in Lua, is the same as "if not argument[1] then error(argument[2]) end"
	-- So in this case, if not name then error("Name not passed...") end
	assert(name, "Name not passed to AddCommand")
	assert(data, "Data not passed to AddCommand")
	-- This checks that not only data is provided, but that data is a table.
	if not istable(data) then error("Data is not a table.") end
	
	-- Setting stuff for later for later.
	data.internalAccess = nil
	data.rankFunc = nil
	
	-- This bit of code creates the internal accessor function.
	-- It creates a function for checking the rank string, by using IsAdmin, IsSuperAdmin and IsUserGroup.
	if data.rank then
		if data.rank == "user" then
			data.rankFunc = function(ply) return true end
		elseif data.rank == "admin" then
			data.rankFunc = function(ply) return ply:IsAdmin() or ply:IsSuperAdmin() end
		elseif data.rank == "superadmin" then
			data.rankFunc = function(ply) return ply:IsSuperAdmin() end
		else
			data.rankFunc = function(ply) return ply:IsUserGroup(data.rank) end
		end
	end
	
	-- This bit then creates the function that we use.
	if data.rank and not data.accessFunc then
		-- If the rank is the only thing set, then of course, we use that.
		data.internalAccess = data.rankFunc
	elseif not data.rank and data.accessFunc then
		-- And the opposite is true here, if we only have the accessor func, we use that.
		data.internalAccess = data.accessFunc
	elseif data.rank and data.accessFunc then
		-- If we have both? Start by checking the accessorFunc, and if it returns nothing, check the rank function.
		data.internalAccess = function(ply)
			-- I can't just run a "if not data.accessFunc(ply)", as false and nil both return false on that, and false is valid, whilst nil isn't.
			-- Fun times.
			if data.accessFunc(ply) == nil then
				return data.rankFunc(ply)
			else
				return data.accessFunc(ply)
			end
		end
	else
		-- If if we have neither, just run an IsAdmin check. I could have it return false, but the spec calls for an IsAdmin call.
		data.internalAccess = function(ply) return ply:IsAdmin() end
	end
	
	-- Set the default fail message, if a custom one is not provided.
	if not data.failMsg then data.failMsg = "You do not have the correct rank for this command." end
	
	-- Finally, add the console command.
	concommand.Add(name, function(ply, cmd, args)
		-- Check if the calling player is valid.
		if ply:IsValid() then
			-- If there is a minimum amount of arguments required, and we don't have it, then fail.
			if (data.minArgs and not args[data.minArgs]) then
				-- Tell the user why their command failed.
				ply:ChatPrint(string.format("This command requires %d %s.", data.minArgs, data.minArgs == 1 and "argument" or "arguments"))
			else
				-- If not, then check if they have the proper access.
				if data.internalAccess(ply) then
					-- And if they do, run the function which does the stuff.
					data.callback(ply, cmd, args)
				else
					-- If they don't, again, tell them why.
					ply:ChatPrint(data.failMsg)
				end
			end
		end
	end)
end

-- Table for commands to be stored in. I could directly call AddCommand, but I think this looks nicer.
local commands = {}

-- Initialise the table for the command.
commands.burnplayer = {}
-- Minimum number of arguments, of course.
commands.burnplayer.minArgs = 1
-- This is where we define the function to be ran, if the pre-call checks all return correctly (correct number of arguments, player has access, etc)
commands.burnplayer.callback = function(ply, cmd, args)
	-- Get the player data, from the player name.
	local target = FindPlayer(args[1])
	-- If the player is valid.
	if IsValid(target) then
		-- BURN THEM.
		target:Ignite(30)
	else
		-- Or tell the player that they couldn't be found.
		ply:ChatPrint("Couldn't find a player with that name.")
	end
end

commands.launchplayer = {}
commands.launchplayer.minArgs = 1
commands.launchplayer.callback = function(ply, cmd, args)
	local target = FindPlayer(args[1])
	if IsValid(target) then
		-- Give the player 300 units/tick (or whatever it is) extra velocity upwards.
		target:SetVelocity(target:GetVelocity() + Vector( 0, 0, 300 ))
	else
		ply:ChatPrint("Couldn't find a player by that name.")
	end
end

commands.explodeplayer = {}
commands.explodeplayer.callback = function(ply, cmd, args)
	local target = FindPlayer(args[1])
	if IsValid(target) then
		-- Create an explosion entity.
		local explosiontoplayer = ents.Create("env_explosion")
		-- If it failed to create, then stop running.
		if not (IsValid(explosiontoplayer)) then return end
		-- Set the position of the explosion to be ontop of the player.
		explosiontoplayer:SetPos(target:GetPos())
		explosiontoplayer:SetKeyValue("Magnitude", "300")
		explosiontoplayer:Spawn()
		-- Boom.
		explosiontoplayer:Fire("explode")
	else
		ply:ChatPrint("Couldn't find a player by that name.")
	end
end
	
commands.switch_places = {}
commands.switch_places.callback = function(ply, cmd, args)
	-- This one is fun.
	-- Find the first player.
	local ply1 = FindPlayer(args[1])
	
	-- This demonstrates optional arguments.
	-- If there is a second argument, find them to swap with.
	if args[2] then
		ply2 = FindPlayer(args[2])
	else
		-- Or if there isn't a second argument, set it to be the calling player.
		ply2 = ply
	end
	
	if IsValid(ply1) and IsValid(ply2) then
		-- Check for player validity, of course.
		-- But if they are the same, don't allow it.
		if ply1 == ply2 then
			ply:ChatPrint("You cannot select the same player to swap with.")
			return
		end

		-- Finally, swap the positions of the players.
		local pos1, pos2 = ply1:GetPos(), ply2:GetPos()
		ply1:SetPos(pos2)
		ply2:SetPos(pos1)
	else
		ply:ChatPrint("Couldn't find a player with that name.")
	end
end

-- The fuck is the point of this one?
-- I don't even know.
commands.spinplayer = {}
commands.spinplayer.callback = function(ply, cmd, args)
	local target = FindPlayer(args[1])
	if IsValid(target) then
		target:SetVelocity(target:GetVelocity() + Vector( 0, 300, 2 ))
	else
		ply:ChatPrint("Couldn't find a player with that name.")
	end
end

commands.freezeplayer = {}
commands.freezeplayer.callback = function(ply, cmd, args)
	local target = FindPlayer(args[1])
	if IsValid(target) then
		-- Simple enough. ply:Freeze(false) unfreezes.
		-- This will toggle the frozen state on the player.
		target:Freeze(not target:IsFrozen())
	else
		ply:ChatPrint("Couldn't find a player by that name.")
	end
end

for k, v in pairs(commands) do
	-- Loop through set of command data, and add it.
	AddCommand(k, v)
end