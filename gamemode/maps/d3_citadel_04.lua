NEXT_MAP = "d3_citadel_05"

SUPER_GRAVITY_GUN = true

TRIGGER_CHECKPOINT = {
	{Vector(67, 687, 2536), Vector(453, 1065, 2578)},
	{Vector(194, 543, 6402), Vector(316, 664, 6523)},
	{Vector(191, 502, 6401), Vector(313, 542, 6522)}
}

hook.Add("InitPostEntity", "hl2cInitPostEntity", function()
	local func_brushes = ents.FindByName("citadel_brush_elevcage1_2")
	func_brushes[1]:Remove()
end)