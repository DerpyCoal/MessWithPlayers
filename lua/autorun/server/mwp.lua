--[[
The Official MessWithPlayers script by Lavacoal123
With help from meharryp and John Internet.
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
local function FindPlayer( ply )
	for k,v in pairs( player.GetAll() ) do
		if string.find( v:Name():lower(), ply:lower() ) then
			return v
		end
	end
end

-- This function takes the name and data for a command, and creates it.
-- AddCommand(string, table), returns Nil
local function AddCommand( name, data )
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
	
	if data.rank and not data.accessFunc then
		if data.rank == "user" then
			data.rankFunc = function(ply) return true end
		elseif data.rank == "admin" then
			data.rankFunc = function(ply) return ply:IsAdmin() or ply:IsSuperAdmin() end
		elseif data.rank == "superadmin" then
			data.rankFunc = function(ply) return ply:IsSuperAdmin() end
		else
			data.rankFunc = function(ply) return ply:IsUserGroup(data.rank) end
		end
		
		data.internalAccess = data.rankFunc
	elseif not data.rank and data.accessFunc then
		data.internalAccess = data.accessFunc
	elseif data.rank and data.accessFunc then
		data.internalAccess = function(ply) if not data.accessFunc(ply) == nil then return data.accessFunc(ply) else return data.rankFunc(ply) end end
	else
		data.internalAccess = function(ply) return ply:IsAdmin() end
	end
	
	if not data.failMsg then data.failMsg = "You do not have the correct rank for this command." end
	
	concommand.Add(name, function(ply, cmd, args)
		if ply:IsValid() then
			if (data.minArgs and not args[data.minArgs]) then
				ply:ChatPrint(string.format("This command requires %d arguments.", data.minArgs))
			else
				if data.internalAccess(ply) then
					data.callback(ply, cmd, args)
				else
					ply:ChatPrint(data.failMsg)
				end
			end
		end
	end)
end

local commands = {}

commands.burnplayer = {}
commands.burnplayer.minArgs = 1
commands.burnplayer.callback = function(ply, cmd, args)
	local target = FindPlayer(args[1])
	if IsValid(target) then
		target:Ignite(30)
	else
		ply:ChatPrint("Couldn't find a player with that name.")
	end
end

commands.launchplayer = {}
commands.launchplayer.callback = function(ply, cmd, args)
	local target = FindPlayer( args[1] )
	if IsValid( target ) then
		target:SetVelocity( target:GetVelocity() + Vector( 0, 0, 300 ) )
	else
		ply:ChatPrint( "Couldn't find a player by that name." )
	end
end

commands.explodeplayer = {}
commands.explodeplayer.callback = function(ply, cmd, args)
	local target = FindPlayer( args[1] )
	if IsValid( target ) then
		local explosiontoplayer = ents.Create("env_explosion")
		if not ( IsValid( explosiontoplayer ) ) then return end
		explosiontoplayer:SetPos( target:GetPos() )
		explosiontoplayer:SetKeyValue( "Magnitude", "300" )
		explosiontoplayer:Spawn()
		explosiontoplayer:Fire( "explode" )
	else
		ply:ChatPrint( "Couldn't find a player by that name." )
	end
end
	
commands.switch_places = {}
commands.switch_places.callback = function(ply, cmd, args)
	local ply1 = FindPlayer(args[1])
	
	if args[2] then
		ply2 = FindPlayer(args[2])
	else
		ply2 = ply
	end
	
	if IsValid(ply1) and IsValid(ply2) then
		if ply1 == ply2 then
			ply:ChatPrint("You cannot select the same player to swap with.")
			return
		end

		local pos1, pos2 = ply1:GetPos(), ply2:GetPos()
		ply1:SetPos(pos2)
		ply2:SetPos(pos1)
	else
		ply:ChatPrint("Couldn't find a player with that name.")
	end
end

commands.spinplayer = {}
commands.spinplayer.callback = function(ply, cmd, args)
	local target = FindPlayer(args[1])
	if IsValid( target ) then
		target:SetVelocity( target:GetVelocity() + Vector( 0, 300, 2 ) )
	else
		ply:ChatPrint( "Couldn't find a player with that name." )
	end
end

commands.freezeplayer = {}
commands.freezeplayer.callback = function(ply, cmd, args)
	local target = FindPlayer( args[1] )
	if IsValid( target ) then
		target:Freeze( not target:IsFrozen() )
	else
		ply:ChatPrint( "Couldn't find a player by that name." )
	end
end

for k, v in pairs(commands) do
	AddCommand(k, v)
end