require("map/rooms/volcano/volcano")
local deepcopy = _G.deepcopy

local volcano_task = {
    locks = LOCKS.NONE,
    keys_given = {KEYS.ISLAND1},
    crosslink_factor = 0,
    make_loop = true,
    gen_method = "volcano",
    room_choices = {
        {
            ["VolcanoLava"] = 6 + math.random(0, 1)
        },
        {
            ["VolcanoNoise"] = 10 + math.random(0, 1)
        },
        {
            ["VolcanoNoise"] = 12 + math.random(0, 1)  -- in sw it 13, but we have start task in dst, so Subtract 1 to make the volcano more like a garden
        },
        {
            ["VolcanoStart"] = 1,
            ["VolcanoAltar"] = 1,
            ["VolcanoObsidianBench"] = 1,
            ["VolcanoCage"] = 1,
            ["VolcanoNoise"] = 13 + math.random(0, 1)
        },
    },
    room_bg = WORLD_TILES.VOLCANO,
    colour = {r = 1, g = 1, b = 0, a = 1}
}
AddTask("Volcano", volcano_task)
local volcanoisland_task = deepcopy(volcano_task)
volcanoisland_task.room_choices[4]["VolcanoStart"] = 0
table.remove(volcanoisland_task.room_choices, 1) --disable for now due to buggy gen
AddTask("VolcanoIsland", volcanoisland_task)
