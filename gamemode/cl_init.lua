// Include the required lua files
include("sh_init.lua")
include("cl_scoreboard.lua")


// Client only constants
DROWNING_SOUNDS = {
	"player/pl_drown1.wav",
	"player/pl_drown2.wav",
	"player/pl_drown3.wav"
}


// Called by ShowScoreboard
function GM:CreateScoreboard()
	if scoreboard then
		scoreboard:Remove()
		scoreboard = nil
	end

	scoreboard = vgui.Create("scoreboard")
end


// This creates the drowning effect
function DrowningEffect(um)
	surface.PlaySound(DROWNING_SOUNDS[math.random(1, #DROWNING_SOUNDS)])
	deAlpha = 100
	deAlphaUpdate = 0
end
usermessage.Hook("DrowningEffect", DrowningEffect)


// Do not want!
function GM:HUDDrawScoreBoard()
end


// Called every frame to draw the hud
function GM:HUDPaint()
	if self.ShowScoreboard && LocalPlayer() && LocalPlayer():Team() != TEAM_DEAD then
		return
	end
	
	self:HUDDrawTargetID()
	self:HUDDrawPickupHistory()
	surface.SetDrawColor(0, 0, 0, 0)
	
	w = ScrW()
	h = ScrH()
	centerX = w / 2
	centerY = h / 2
	
	// Draw nav marker/point
	if showNav && checkpointPosition && LocalPlayer():Team() == TEAM_ALIVE then
		local checkpointDistance = math.Round(LocalPlayer():GetPos():Distance(checkpointPosition) / 39)
		local checkpointPositionScreen = checkpointPosition:ToScreen()
		
		surface.SetDrawColor(255, 255, 255, 255)
		
		if checkpointPositionScreen.x > 32 && checkpointPositionScreen.x < w - 43 && checkpointPositionScreen.y > 32 && checkpointPositionScreen.y < h - 38 then
			surface.SetTexture(surface.GetTextureID("hl2c_nav_marker"))
			surface.DrawTexturedRect(checkpointPositionScreen.x - 14, checkpointPositionScreen.y - 14, 28, 28)
			draw.DrawText(tostring(checkpointDistance).." m", "arial16", checkpointPositionScreen.x, checkpointPositionScreen.y + 15, Color(255, 220, 0, 255), 1)
		else
			local r = math.Round(centerX / 2)
			local checkpointPositionRad = math.atan2(checkpointPositionScreen.y - centerY, checkpointPositionScreen.x - centerX)
			local checkpointPositionDeg = 0 - math.Round(math.deg(checkpointPositionRad))
			surface.SetTexture(surface.GetTextureID("hl2c_nav_pointer"))
			surface.DrawTexturedRectRotated(math.cos(checkpointPositionRad) * r + centerX, math.sin(checkpointPositionRad) * r + centerY, 32, 32, checkpointPositionDeg + 90)
		end
	end
	
	if LocalPlayer():Team() == TEAM_DEAD then	-- If dead, then draw spectator letterbox
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, w, h * 0.10)
		surface.DrawRect(0, h - h * 0.10, w, h * 0.10)
	else
		// Drowning Effect
		if deAlpha && deAlpha > 0 then
			if CurTime() >= deAlphaUpdate + 0.01 then
				deAlpha = deAlpha - 1
				deAlphaUpdate = CurTime()
			end
			
			surface.SetDrawColor(0, 0, 255, deAlpha)
			surface.DrawRect(0, 0, w, h)
		end
		
		// Aux bar
		if energy < 100 then
			draw.RoundedBox(8, (ScrH() - h * 0.132) / 27.75, ScrH() - h * 0.132, h * 0.026 * 8.2, h * 0.026, Color(0, 0, 0, 75))
			surface.SetDrawColor(236, 210, 37, 150)
			surface.DrawRect((ScrH() - h * 0.126) / 22.3, ScrH() - h * 0.126, (energy / 100) * (h * 0.015 * 12.75), h * 0.015)
		end
		
		// Crosshair
		if !LocalPlayer():InVehicle() && LocalPlayer():GetActiveWeapon() && LocalPlayer():GetActiveWeapon():IsValid() then	
			surface.SetDrawColor(255, 255, 255, 255)
			surface.DrawRect(centerX - 1, centerY - 1, 1, 1)
			surface.DrawRect(centerX - 11, centerY - 1, 1, 1)
			surface.DrawRect(centerX + 9, centerY - 1, 1, 1)
			surface.DrawRect(centerX - 1, centerY + 7, 1, 1)
			surface.DrawRect(centerX - 1, centerY - 9, 1, 1)
			
			if !LocalPlayer():KeyDown(IN_ZOOM) then
				draw.SimpleText("(", "crosshair44", centerX - 15, centerY, Color(255, 220, 0, 150), 2, 1)
				draw.SimpleText(")", "crosshair44", centerX + 15, centerY, Color(255, 220, 0, 150), 0, 1)
			end
		end
	end
	
	// Are we going to the next map?
	if nextMapCountdownStart then
		local nextMapCountdownLeft = math.Round(nextMapCountdownStart + NEXT_MAP_TIME - CurTime())
		if nextMapCountdownLeft > 0 then
			draw.DrawText("Next Map in "..tostring(nextMapCountdownLeft), "impact32", centerX, h - h * 0.075, Color(255, 255, 255, 200), 1)
		else
			draw.DrawText("Switching Maps!", "impact32", centerX, h - h * 0.075, Color(255, 255, 255, 200), 1)
		end
	end
	
	// Are we restarting the map?
	if restartMapCountdownStart then
		local restartMapCountdownLeft = math.Round(restartMapCountdownStart + RESTART_MAP_TIME - CurTime())
		if restartMapCountdownLeft > 0 then
			draw.DrawText("Restarting Map in "..tostring(restartMapCountdownLeft), "impact32", centerX, h - h * 0.075, Color(255, 255, 255, 200), 1)
		else
			draw.DrawText("Restarting Map!", "impact32", centerX, h - h * 0.075, Color(255, 255, 255, 200), 1)
		end
	end
	
	// On top of it all
	self:DrawDeathNotice(0.85, 0.04)
end


// Called every frame
function GM:HUDShouldDraw(name)
	if LocalPlayer() && LocalPlayer():IsValid() then
		if !LocalPlayer():Alive() || (self.ShowScoreboard && LocalPlayer() && LocalPlayer():Team() != TEAM_DEAD) then
			return false
		end
		
		local wep = LocalPlayer():GetActiveWeapon()
		
 		if wep && wep:IsValid() && wep.HUDShouldDraw != nil then
			return wep.HUDShouldDraw(wep, name)
		end
 	end
	
 	return true
end
 

// Called when we initialize
function GM:Initialize()
	// Initial variables for client
	energy = 100
	self.ShowScoreboard = false
	showNav = true
	scoreboard = nil
	
	// Create a Client ConVar to control halos
	CreateClientConVar( "hl2c_player_halo", "0", true, false )
	CreateClientConVar( "hl2c_vital_npc_halo", "0", true, false )
	CreateClientConVar( "hl2c_citizen_npc_halo", "0", true, false )
	
	// Fonts we will need later
	surface.CreateFont("arial16", {
		font = "Arial",
		size = 16,
		weight = 400
	})
	
	surface.CreateFont("arial16Bold", {
		font = "Arial",
		size = 16,
		weight = 700
	})
	
	surface.CreateFont("coolvetica72", {
		font = "coolvetica",
		size = 72,
		weight = 500
	})
	
	surface.CreateFont("crosshair44", {
		font = "HL2Cross",
		size = 44,
		weight = 430
	})
	
	surface.CreateFont("impact32", {
		font = "Impact",
		size = 32,
		weight = 400
	})
	
	language.Add("worldspawn", "World")
	language.Add("func_door_rotating", "Door")
	language.Add("func_door", "Door")
	language.Add("phys_magnet", "Magnet")
	language.Add("trigger_hurt", "Trigger Hurt")
	language.Add("entityflame", "Fire")
	language.Add("env_explosion", "Explosion")
	language.Add("env_fire", "Fire")
	language.Add("func_tracktrain", "Train")
	language.Add("npc_launcher", "Headcrab Pod")
	language.Add("func_tank", "Mounted Turret")
	language.Add("npc_helicopter", "Helicopter")
	language.Add("npc_bullseye", "Turret")
	language.Add("prop_vehicle_apc", "APC")
	language.Add("item_healthvial", "Health Vial")
	language.Add("combine_mine", "Mine")
	language.Add("npc_grenade_frag", "Grenade")
end

function GM:PreDrawHalos()
	local entpl = ents.FindByClass("player")
	if GetConVarNumber("hl2c_player_halo") >= 1 then
		halo.Add(entpl, Color(255, 127, 0), 5, 5, 2, true, true)
	end
	
	local entvnpc1 = ents.FindByClass("npc_alyx")
	local entvnpc2 = ents.FindByClass("npc_barney")
	if GetConVarNumber("hl2c_vital_npc_halo") >= 1 then
		halo.Add(entvnpc1, Color(127, 106, 0), 5, 5, 2, true, false)
		halo.Add(entvnpc2, Color(0, 106, 127), 5, 5, 2, true, false)
	end
	
	local entcnpc1 = ents.FindByClass("npc_citizen")
	if GetConVarNumber("hl2c_citizen_npc_halo") >= 1 then
		halo.Add(entcnpc1, Color(0, 255, 0), 5, 5, 2, true, false)
	end
end

function GM:PostDrawViewModel( vm, pl, weapon )

	if ( weapon.UseHands || !weapon:IsScripted() ) then

		local hands = LocalPlayer():GetHands()
		if ( IsValid( hands ) ) then hands:DrawModel() end

	end

end


// Called when going to the next map
function NextMap(um)
	if #SUCCESS_SOUNDS > 1 then
		surface.PlaySound(SUCCESS_SOUNDS[math.random(1, #SUCCESS_SOUNDS)])
	elseif #SUCCESS_SOUNDS > 0 then
		surface.PlaySound(SUCCESS_SOUNDS[1])
	end
	
	nextMapCountdownStart = um:ReadLong()
	
	if LocalPlayer():Team() != TEAM_ALIVE then
		RunConsoleCommand("+score")
	end
end
usermessage.Hook("NextMap", NextMap)


// Called when player spawns for the first time
function PlayerInitialSpawn(um)
	if !file.Exists("shown_hl2c_help.txt", "DATA") then
		ShowHelp()
		file.Write("shown_hl2c_help.txt", "You've viewed the help menu in Half-Life 2 Campaign.")
	end
	checkpointPosition = um:ReadVector()
end
usermessage.Hook("PlayerInitialSpawn", PlayerInitialSpawn)


// Called when restarting maps
function RestartMap(um)
	if #FAILURE_SOUNDS > 1 then
		surface.PlaySound(FAILURE_SOUNDS[math.random(1, #FAILURE_SOUNDS)])
	elseif #FAILURE_SOUNDS > 0 then
		surface.PlaySound(FAILURE_SOUNDS[1])
	end
	
	restartMapCountdownStart = um:ReadLong()
	
	RunConsoleCommand("+score")
end
usermessage.Hook("RestartMap", RestartMap)


// Called by show help
function ShowHelp()
	local helpText = [[-= KEYBOARD SHORTCUTS =-
	[F1] (Show Help) - Opens this menu.
	[F2] (Show Team) - Toggles the navigation marker on your HUD.
	[F3] (Spare 1) - Spawns a vehicle if allowed.
	[F4] (Spare 2) - Removes a vehicle if you have one.
	
	-= OTHER NOTES =-
	Once you're dead you cannot respawn until the next map.
	Ported by daunknownman2010
	
	-= CREDITS =-
	AMT - Original creator]]
	
	local helpMenu = vgui.Create("DFrame")
	local helpPanel = vgui.Create("DPanel", helpMenu)
	local helpLabel = vgui.Create("DLabel", helpPanel)
	
	helpLabel:SetText(helpText)
	helpLabel:SetTextColor(color_black)
	helpLabel:SizeToContents()
	helpLabel:SetPos(5, 5)
	
	local w, h = helpLabel:GetSize()
	helpMenu:SetSize(w + 20, h + 43)
	
	helpPanel:StretchToParent(5, 28, 5, 5)
	
	helpMenu:SetTitle("Half-Life 2 Campaign Help")
	helpMenu:Center()
	helpMenu:MakePopup()
end
usermessage.Hook("ShowHelp", ShowHelp)


// Called by client pressing -score
function GM:ScoreboardHide()
	self.ShowScoreboard = false
	
	if scoreboard then
		scoreboard:SetVisible(false)
	end
end


// Called by client pressing +score
function GM:ScoreboardShow()
	self.ShowScoreboard = true
	
	if !scoreboard then
		self:CreateScoreboard()
	end
	
	scoreboard:SetVisible(true)
	scoreboard:UpdateScoreboard(true)
end

// Called by ShowTeam
function ShowTeam()
	if showNav then
		showNav = false
	else
		showNav = true
	end
end
usermessage.Hook("ShowTeam", ShowTeam)

// Called by server
function SetCheckpointPosition(um)
	checkpointPosition = um:ReadVector()
end
usermessage.Hook("SetCheckpointPosition", SetCheckpointPosition)


// Called by server Think()
function UpdateEnergy(um)
	energy = um:ReadShort()
end
usermessage.Hook("UpdateEnergy", UpdateEnergy)