include("shared.lua")

-- Initialize font for UI
surface.CreateFont( "VOL_FONT", {
	font = "Arial",
	extended = false,
	size = 15,
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
	-- Does not allow false values to linger after client has stopped speaking.
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
	net.WriteFloat(vol)
	net.SendToServer()
	-- print(currentTarget:Health())
end
hook.Add("Think", "continousVolChanger", updateStuff)

--HUD STARTS:
hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true
}

hook.Add( "HUDShouldDraw", "HideHUD", function( name )
	if ( hide[ name ] ) then return false end
end)

hook.Add("HUDPaint", "VolumeUI", function()
	local opacityR = 50 --red opacity
	local opacityY = 50 --yellow opacity
	local opacityG = 50 --green opacity

	--draw three intensity bars (red yellow green)
	draw.RoundedBox(0,ScrW() / 2 + 50,ScrH() - 50,100,15,Color(255, 0, 0, opacityR))
	draw.RoundedBox(0,ScrW() / 2 - 50,ScrH() - 50,100,15,Color(255, 255, 0, opacityY))
	draw.RoundedBox(0,ScrW() / 2 - 150,ScrH() - 50,100,15,Color(0, 255, 0, opacityG))
	
	local volPercentageColor; --controls color of percentage

	--Draw text as read if value is above %100.
	if (volPercentage > 100) then
		volPercentageColor = Color(255, 0, 0, 255)
	else
		volPercentageColor = Color(0, 0, 0, 255)
	end

	-- Draw percentage above marker
	draw.SimpleText( "%"..volPercentage, "VOL_FONT", math.Clamp((ScrW() / 2 - 150) + (300 * (volPercentage / 100)) - 7, ScrW() / 2 - 150, ScrW() / 2 + 150), ScrH() - 70,volPercentageColor)

	-- Draw outlining rectangle to give sharp look to volume scale
	surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
	surface.DrawOutlinedRect( ScrW() / 2 - 150, ScrH() - 50, 300, 15)

	--Draw marker on scale
	surface.DrawRect( math.Clamp((ScrW() / 2 - 150) + (300 * (volPercentage / 100)), ScrW() / 2 - 150, ScrW() / 2 + 150), ScrH() - 50, 1, 15 )
end)

