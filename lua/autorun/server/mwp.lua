//The Official MessWithPlayers script by Lavacoal123
//With help from meharryp
//Deviations of this script must be put on the GitHub site.
//Copyright Creative Commons Attribution Non-Commericial liscence.

local function FindPlayer( ply )
	for k,v in pairs( player.GetAll() ) do
		if string.find( v:Name():lower(), ply:lower() ) then
			return v
		end
	end
end

concommand.Add( "burnplayer", function( ply, cmd, args )
	if ply:IsAdmin() then
		local target = FindPlayer( args[1] )
		if IsValid( target ) then
			target:Ignite( 30 )
		else
			ply:ChatPrint( "Couldn't find a player by that name." )
		end
	else
		ply:ChatPrint( "You must be an admin to do that!" )
	end
end )

concommand.Add( "launchplayer", function( ply, cmd, args )
	if ply:IsAdmin() then
		local target = FindPlayer( args[1] )
		if IsValid( target ) then
			target:SetVelocity( target:GetVelocity() + Vector( 0, 0, 300 ) )
		else
			ply:ChatPrint( "Couldn't find a player by that name." )
		end
	else
		ply:ChatPrint( "You must be an admin to do that!" )
	end
end )

concommand.Add( "explodeplayer", function( ply, cmd, args )
	if ply:IsAdmin() then
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
	else
		ply:ChatPrint( "You must be an admin to do that!" )
	end
end )

concommand.Add( "switch_places", function( ply, cmd, args )
	if ply:IsAdmin() then
		local p1 = FindPlayer( args[1] )
		local p2 = FindPlayer( args[2] )

		if IsValid( p1 ) and IsValid( p2 ) then
			local pos1 = p1:GetPos()
			local pos2 = p2:GetPos()
			p1:SetPos( pos2 )
			p2:SetPos( pos1 )
		else
			ply:ChatPrint( "Couldn't find player(s) by that name." )
		end
	else
		ply:ChatPrint( "You must be an admin to do that!" )
	end
end )

// This is litterly the launchplayer command but on the Y-axis
concommand.Add( "spinplayer", function( ply, cmd, args )
	if ply:IsAdmin() then
		local target = FindPlayer( args[1] )
		if IsValid( target ) then
			target:SetVelocity( target:GetVelocity() + Vector( 0, 300, 2 ) )
		else
			ply:ChatPrint( "Couldn't find a player by that name." )
		end
	else
		ply:ChatPrint( "You must be an admin to do that!" )
	end
end )

concommand.Add( "freezeplayer", function( ply, cmd, args )
	if ply:IsAdmin() then
		local target = FindPlayer( args[1] )
		if IsValid( target ) then
			target:Freeze( not target:IsFrozen() )
		else
			ply:ChatPrint( "Couldn't find a player by that name." )
		end
	else
		ply:ChatPrint( "You must be an admin to do that!" )
	end
end )
