ALLOWED_VEHICLE = "Jeep"

INFO_PLAYER_SPAWN = {Vector(2087, -5411, 1375), 0}

NEXT_MAP = "d2_coast_12"

hook.Add("PlayerSpawn", "hl2cPlayerSpawn", function(pl)
	pl:Give("weapon_crowbar")
	pl:Give("weapon_pistol")
	pl:Give("weapon_smg1")
	pl:Give("weapon_medkit")
	pl:Give("weapon_frag")
	pl:Give("weapon_357")
	pl:Give("weapon_physcannon")
	pl:Give("weapon_shotgun")
	pl:Give("weapon_ar2")
	pl:Give("weapon_rpg")
	pl:Give("weapon_crossbow")
end)

hook.Add("InitPostEntity", "hl2cInitPostEntity", function()
	local spawner = ents.FindByName("citizen_spawner_3")
	spawner[1]:Remove()

	local exit = ents.FindByName("logic_start_leader_exit")
	exit[1]:Fire("addoutput", "OnTrigger lighthouse_secret_door,Open,5.00,1")
end)