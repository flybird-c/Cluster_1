local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local tasksets = require("map/tasksets")
local MULTIPLY = require("map/forest_map").MULTIPLY

IAENV.AddLevelPreInit("SURVIVAL_SHIPWRECKED_CLASSIC", function(level)
    TUNING.BERMUDA_AMOUNT = TUNING.BERMUDA_AMOUNT * MULTIPLY[level.overrides.bermudatriangle or "default"]

    local task_set = "shipwrecked"
    local overrides = level.overrides

    if overrides.task_set ~= task_set then  -- When changing the world option, the taskset will be changed
        local shipwrecked_set_data = tasksets.GetGenTasks(task_set)

        local modfns = ModManager:GetPostInitFns("TaskSetPreInit", task_set)
        for _, modfn in ipairs(modfns) do
            print("Applying mod to task set '"..task_set.."'")
            modfn(shipwrecked_set_data)
        end
        modfns = ModManager:GetPostInitFns("TaskSetPreInitAny")
        for _, modfn in ipairs(modfns) do
            print("Applying mod to current task set")
            modfn(shipwrecked_set_data)
        end

        for k, v in pairs(shipwrecked_set_data) do
            level[k] = v
        end
    end

    --[[ DST already handles disabling bosses just fine, Island will be kept but Bee Queen will be disabled
    if overrides.beequeen ~= "never" then
        print("Added Bee Queen Island")
        table.insert(level.tasks, "MeadowBeeQueenIsland")
        table.insert(level.required_prefabs, "beequeenhive")
    end
    ]]

    if overrides.volcanoisland ~= "none" then
        print("Added Volcano Island")
        table.insert(level.tasks, "VolcanoIsland")
        level.overrides.task_add_tags = level.overrides.task_add_tags or {}
        level.overrides.task_add_tags["VolcanoIsland"] = {"volcanoclimate"}

        table.insert(level.required_prefabs, "volcano_altar")
        table.insert(level.required_prefabs, "obsidian_workbench")
        table.insert(level.required_prefabs, "daywalkerspawningground")
    end
end)
