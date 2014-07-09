ALLOWED_VEHICLE = "Airboat"

NEXT_MAP = "d1_canals_12"

TRIGGER_CHECKPOINT = {
	{Vector(5643, 4736, -939), Vector(5669, 5083, -779), false, function() ALLOWED_VEHICLE = "Airboat Gun" end},
	{Vector(289, -7412, -896), Vector(315, -7064, -736)}
}

hook.Add("PlayerSpawn", "hl2cPlayerSpawn", function(pl)
	pl:Give("weapon_crowbar")
	pl:Give("weapon_pistol")
	pl:Give("weapon_smg1")
	pl:Give("weapon_medkit")
end)