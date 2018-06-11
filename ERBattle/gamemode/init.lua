AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

-- Sets playermodel for all clients
function GM:PlayerSetModel( ply3 )
	ply3:SetModel( "models/player/kleiner.mdl" )
end

-- Creates NextBot spawning function for debugging
function GM:PlayerSay(sender, text, team)
	if (text == "!nextbot_spawn") then
		player.CreateNextBot( "yanni" )
	end
end

-- Updates health of targeted player
function updateBoard()
	-- Gets table of current players
	local players = player.GetAll()

	local playerValues = {}
end

hook.Add("Think", "update_board", updateBoard)

--Starts recieving networked data from client
util.AddNetworkString("sendVolValue")

net.Receive("sendVolValue",function(len, pl)
	-- Stores client's target as local variable
	local trgt = net.ReadEntity()
	-- Stores client's damage dealt (based off voice volume) as a local variable
	local dmg = net.ReadFloat()
	-- Sets new health based off 'dmg' variable
	trgt:SetHealth(trgt:Health() - dmg)
	-- Kills target, doesn't allow target to have a negative health.
	if trgt:IsPlayer() and trgt:Health() <= 0 and trgt:Alive() then
		trgt:Kill()
	end
end)
