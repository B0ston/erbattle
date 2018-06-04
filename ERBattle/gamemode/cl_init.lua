include("shared.lua")

leaderboard = {}
-- Initialize font for UI
surface.CreateFont( "VOL_FONT", {
	font = "Arial",
	extended = false,
	size = 15,
	weight = 2000,
})

surface.CreateFont( "LB_FONT", {
	font = "Consolas",
	extended = false,
	size = 15,
	weight = 2000,
})

surface.CreateFont( "dmgfont", {
	font = "Consolas",
	extended = false,
	size = 30,
	weight = 2000,
})

-- Initialize global variables used later on (in multiple blocks)
ply = LocalPlayer()
vol = 0;
volPercentage = 0;
currentTarget = nil;

--think hook
function updateStuff()
	local ply = LocalPlayer()
	local players = player.GetAll()
	
	for k, v in pairs(players) do
		leaderboard[k] = v:VoiceVolume()
	end

	if !ply:IsSpeaking() then
		volPercentage = 0
		vol = 0
	else
		-- if client IS speaking:
		vol = ply:VoiceVolume()
		volPercentage = math.floor((vol / 0.32) * 100)
	end

	-- Stores current target entity
	currentTarget = ply:GetEyeTraceNoCursor().Entity

	-- Client networking sending target ent and damage value to server.
	net.Start("sendVolValue")
	net.WriteEntity(currentTarget)
	if (volPercentage > 10) then
		net.WriteFloat(vol)
	end
	net.SendToServer()
	
end
hook.Add("Think", "continousVolChanger", updateStuff)

--HUD STARTS:
hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if (hide[name]) then return false end
end)

hook.Add("HUDPaint", "VolumeUI", function()
	local opacityR = 50 --red opacity
	local opacityY = 50 --yellow opacity
	local opacityG = 50 --green opacity
	local damage = vol * 75
	local players = player.GetAll()

	--draw three intensity bars (red yellow green)
	draw.RoundedBox(0,ScrW() / 2 + 50,ScrH() - 50,100,15,Color(255, 0, 0, opacityR))
	draw.RoundedBox(0,ScrW() / 2 - 50,ScrH() - 50,100,15,Color(255, 255, 0, opacityY))
	draw.RoundedBox(0,ScrW() / 2 - 150,ScrH() - 50,100,15,Color(0, 255, 0, opacityG))
	
	local volPercentageColor; --controls color of percentage

	--Draw text as read if value is above %100.
	if (volPercentage > 100) then
		volPercentageColor = Color(255, 0, 0, 255) --red solid
	else
		volPercentageColor = Color(0, 0, 0, 255) --black solid
	end

	-- Draw percentage above marker
	draw.SimpleText( "%"..volPercentage, "VOL_FONT", math.Clamp((ScrW() / 2 - 150) + (300 * (volPercentage / 100)) - 7, ScrW() / 2 - 150, ScrW() / 2 + 150), ScrH() - 70,volPercentageColor)
	draw.SimpleText("Damage: "..math.floor(damage),"dmgfont",50,ScrH() - 40,Color(0, 0, 0, 255))
	-- Draw outlining rectangle to give sharp look to volume scale
	surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
	surface.DrawOutlinedRect( ScrW() / 2 - 150, ScrH() - 50, 300, 15)

	--Draw marker on scale
	surface.DrawRect( math.Clamp((ScrW() / 2 - 150) + (300 * (volPercentage / 100)), ScrW() / 2 - 150, ScrW() / 2 + 150), ScrH() - 50, 1, 15 )

	--Draw leaderboard
	surface.DrawOutlinedRect(20,20,300,200)
	draw.RoundedBox(0,20,20,300,200,Color(255, 120, 120, 200))
	draw.SimpleText("Leaderboard:","LB_FONT",20,2,Color(255, 255, 255, 255))
	local greatest = 0
	for k, v in pairs(leaderboard) do
		if v > greatest then
			draw.SimpleText("~"..players[k]:Nick().." : "..((v / 0.32)),"LB_FONT",40,15 + k * 15,Color(255, 223, 0, 255))
		else
			draw.SimpleText(players[k]:Nick().." : "..((v / 0.32)),"LB_FONT",40,15 + k * 15,Color(255, 255, 255, 255))
		end
	end
end)
