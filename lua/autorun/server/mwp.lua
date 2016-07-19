//The Official MessWithPlayers script by Lavacoal123
//Deviations of this script must be put on the GitHub site.
//Copyright Creative Commons Attribution Non-Commericial liscence.

local password = "password"

concommand.Add("SetMWP_Password", function setpass( args ) 
	if args[1] == password then
		password = args[2]
		print( "Succesfully changed password to" .. password )
	else
		print( "Invalid Password." )
	end
end )

concommand.Add("burnplayer", function setpass( args )
	if args[2] == password then
		if (args[1]:IsPlayer()) then
			args[1]:Ignite( 30 )
		else
			print("Argument 1 is not a valid player.")
		end
	else
		print( "Invalid Password." )
	end
end )

concommand.Add("launchplayer", function setpass( args ) 
	if args[2] == password then
		if (args[1]:IsPlayer()) then
			args[1]:SetVelocity( args[1]:GetVelocity() + Vector( 0, 0, 300 ) )
		else
			print("Argument 1 is not a valid player.")
		end
	else
		print( "Invalid Password." )
	end
end )

concommand.Add("explodeplayer", function setpass( args ) 
	if args[2] == password then
		if (args[1]:IsPlayer()) then
			local explosiontoplayer = ents.Create("env_explosion")
			if not ( IsValid( explosiontoplayer ) ) then return end
			explosiontoplayer:SetPos( args[1]:GetPos() )
			explosiontoplayer:SetKeyValue("Magnitude", "300")
			explosiontoplayer:Spawn()
			
		else
			print("Argument 1 is not a valid player.")
		end
	else
		print( "Invalid Password." )
	end
end )

concommand.Add("swap_places", function setpass( args ) 
	if args[3] == password then
                if (args[2]:IsPlayer()) then
                if (args[1]:IsPlayer()) then
		pposition1 = args[1]:GetPos()
		pposition2 = args[2]:GetPos()
		args[1]:SetPos(pposition2)
		args[2]:SetPos(pposition1)
                else print ("Player 1 invalid.") end
                else print ("Player 2 invalid.") end
	else
		print( "Invalid Password." )
	end
end )

concommand.Add("spinplayer", function setpass( args ) 
	if args[2] == password then
		if (args[1]:IsPlayer()) then
			args[1]:SetVelocity( args[1]:GetVelocity() + Vector( 0, 300, 2 ) )
		else
			print("Argument 1 is not a valid player.")
		end
	else
		print( "Invalid Password." )
	end
end )
