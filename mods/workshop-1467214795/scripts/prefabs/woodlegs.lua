local MakePlayerCharacter = require("prefabs/player_common")

local assets = {
    Asset("ANIM", "anim/woodlegs.zip"),
	Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local prefabs = {}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
	start_inv[string.lower(k)] = v.WOODLEGS
end

prefabs = FlattenTree({prefabs, start_inv}, true)

local footsteps = {
    -- runsounds
    "run_sand",
    "run_dirt",
    "run_marsh",
    "run_tallgrass",
    "run_woods",
    "run_carpet",
    "run_rock",
    "run_slate",
    "run_moss",
    "run_marble",
    -- mudsounds
    "run_mud",
    -- snowsounds
    "run_snow",
    "run_ice",
    -- creepsounds
    "run_web",
    -- extrasounds
    ["ia_run_sand"] = "run_sand",
    ["run_pebblebeach"] = "run_sand",
    ["run_meteor"] = "run_slate",
    ["run_dock"] = "run_wood",
}

local footstep_map = {}
for soundindex, sound in pairs(footsteps) do
    soundindex = "dontstarve/movement/" .. (type(soundindex) == "string" and soundindex or sound)
    sound = "ia/movement/woodlegs/" .. sound
    footstep_map[soundindex] = sound
end

local function FootStepfn(inst, soundname)
    if footstep_map[soundname] then
        return footstep_map[soundname]
    end

    -- custom sound used, take a guess based on tiledata
    local tile = inst.components.locomotor ~= nil and inst.components.locomotor:TempGroundTile() or inst:GetCurrentTileType()

    if GROUND_FLOORING[tile] then
        return "ia/movement/woodlegs/run_wood"
    end
    if GROUND_HARD[tile] then
        return "ia/movement/woodlegs/run_rock"
    end

    return "ia/movement/woodlegs/run_dirt"
end

local function sanityfn(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local tile = TheWorld.Map:GetTileAtPoint(x, y, z)

    local delta = 0
    if not IsOceanTile(tile) then
        delta = TUNING.WOODLEGS_WATER_SANITY
    end

    return delta
end

local function CanShaveTest(inst)
    return false, "REFUSE"
end

local function FindTreasure(inst)
    if not TheWorld.components.buriedtreasuremanager then
		return
	end

    local x, y, z = inst.Transform:GetWorldPosition()
    local treasures = TheSim:FindEntities(x, y, z, 10000, {"buriedtreasure"})
    local treasure_num = math.ceil(#treasures * 0.25)
    local new_treasure_num = math.random(4, 5) - treasure_num

    if treasure_num > 0 then
        for i = 1, treasure_num do
			treasures[i]:SetRandomNewTreasure()
			treasures[i]:RevealFog(inst)
		end
    end

    if new_treasure_num > 0 then
        for i = 1, new_treasure_num do
            local treasure = TheWorld.components.buriedtreasuremanager:SpawnNewTreasure()
            treasure:RevealFog(inst)
        end
    end
end

local function OnNewSpawn(inst)
    inst:DoTaskInTime(0.5, FindTreasure)
end

local function common_postinit(inst)
	inst.MiniMapEntity:SetIcon("woodlegs.tex")
    inst:AddTag("woodlegs")
    inst:AddTag("piratecaptain")
	inst:AddTag("bearded")

    inst.footstep_overridefn = FootStepfn
end

local function master_postinit(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default

    inst.components.health:SetMaxHealth(TUNING.WOODLEGS_HEALTH)
    inst.components.hunger:SetMax(TUNING.WOODLEGS_HUNGER)
    inst.components.sanity:SetMax(TUNING.WOODLEGS_SANITY)
    inst.components.sanity.custom_rate_fn = sanityfn

    inst.components.foodaffinity:AddPrefabAffinity("bananajuice", TUNING.AFFINITY_15_CALORIES_MED)

    inst:AddComponent("beard")
    inst.components.beard.canshavetest = CanShaveTest
    inst.components.beard:EnableGrowth(false)

    inst.soundsname = "woodlegs"
    inst.talker_path_override = "ia/characters/"

    inst.OnNewSpawn = OnNewSpawn
end

return MakePlayerCharacter("woodlegs", prefabs, assets, common_postinit, master_postinit, start_inv)
