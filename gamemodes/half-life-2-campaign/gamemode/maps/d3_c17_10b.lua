INFO_PLAYER_SPAWN = {Vector(2684, -1865, 260), 90}

NEXT_MAP = "d3_c17_11"

TRIGGER_CHECKPOINT = {
	{Vector(2562, -995, 257), Vector(2805, -954, 378)},
	{Vector(3529, 869, 512), Vector(3576, 1038, 619)},
	{Vector(2569, 1022, 256), Vector(2609, 1062, 377)}
}

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
	pl:Give("weapon_bugbait")
end)