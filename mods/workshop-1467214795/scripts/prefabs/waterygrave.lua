local assets =
{
	Asset("ANIM", "anim/graves_water.zip"),
    Asset("ANIM", "anim/graves_water_crate.zip"),
}

local prefabs =
{
    "seaweed",
    "coral",
    "pirateghost"
}

for k= 1,NUM_TRINKETS do
    table.insert(prefabs, "trinket_"..tostring(k) )
end
for k= 13,23 do
    table.insert(prefabs, "trinket_ia_"..tostring(k) )
end

local anims =
{
    {idle = "idle1", pst = "fishing_pst1"},
    {idle = "idle2", pst = "fishing_pst2"},
    {idle = "idle3", pst = "fishing_pst3"},
    {idle = "idle4", pst = "fishing_pst4"},
    {idle = "idle5", pst = "fishing_pst5"},
}

local function ReturnChildren(inst)
    local toremove = {}
    for k, v in pairs(inst.components.childspawner.childrenoutside) do
        table.insert(toremove, v)
    end
    for i, v in ipairs(toremove) do
        if v:IsAsleep() then
            v:PushEvent("detachchild")
            v:Remove()
        else
            v.components.health:Kill()
        end
    end
end

local function spawnghost(inst, chance)
    if inst.ghost == nil and math.random() <= (chance or 1) then
        inst.ghost = SpawnPrefab("ghost")
        if inst.ghost ~= nil then
            local x, y, z = inst.Transform:GetWorldPosition()
            inst.ghost.Transform:SetPosition(x - .3, y, z - .3)
            inst:ListenForEvent("onremove", function() inst.ghost = nil end, inst.ghost)
            return true
        end
    end
    return false
end

local function onretrieveevent(inst)
    inst.AnimState:PlayAnimation(anims[inst.anim].pst, false)
    inst:ListenForEvent("animover", function() 
        -- Fixes invisible graves when canceling the state at the last moment... -Half
        inst.retrieved = true
        inst:Hide()
    end)
end

local function onretrieve(inst, worker)
	if worker then
		if worker.components.sanity then
			worker.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
		end
        inst.SoundEmitter:PlaySound("ia/common/loot_reveal")
    end
    inst:Remove()
end

local function onfinishcallback(inst, worker)
    local pt = worker and worker:GetPosition() or nil

    if pt ~= nil then
        if worker.components.sanity ~= nil then
            worker.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
        end
        if not spawnghost(inst, .1) then
            inst.components.lootdropper:SpawnLootPrefab("seaweed", pt)
            if math.random() < 0.75 then
                inst.components.lootdropper:SpawnLootPrefab("coral", pt)
            end
            local item = math.random() < .5 and PickRandomTrinket() or nil
            if item ~= nil then
                inst.components.lootdropper:SpawnLootPrefab(item, pt)
            end

			if math.random() < TUNING.COOKINGRECIPECARD_GRAVESTONE_CHANCE then
                inst.components.lootdropper:SpawnLootPrefab("cookingrecipecard", pt)
			end

            if math.random() < TUNING.SCRAPBOOK_PAGE_GRAVESTONE_CHANCE then
                inst.components.lootdropper:SpawnLootPrefab("scrapbook_page")
            end

			if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
				local ornament = math.random(NUM_HALLOWEEN_ORNAMENTS * 4)
				if ornament <= NUM_HALLOWEEN_ORNAMENTS then
	                inst.components.lootdropper:SpawnLootPrefab("halloween_ornament_"..tostring(ornament), pt)
				end
				-- if TheWorld.components.specialeventsetup ~= nil then
				-- 	if math.random() < TheWorld.components.specialeventsetup.halloween_bat_grave_spawn_chance then
				-- 		local num_bats = 3
				-- 		for i = 1, num_bats do
				-- 			inst:DoTaskInTime(0.2 * i + math.random() * 0.3, function()
				-- 				local bat = SpawnPrefab("bat")
				-- 				local pos = FindNearbyLand(inst:GetPosition(), 3)
				-- 				bat.Transform:SetPosition(pos:Get())
				-- 				bat:PushEvent("fly_back")
				-- 			end)
				-- 		end

				-- 		TheWorld.components.specialeventsetup.halloween_bat_grave_spawn_chance = 0
				-- 	else
				-- 		TheWorld.components.specialeventsetup.halloween_bat_grave_spawn_chance = TheWorld.components.specialeventsetup.halloween_bat_grave_spawn_chance + 0.1 + (math.random() * 0.1)
				-- 	end
				-- end
			end

            onretrieve(inst, worker)
		else
			if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
                inst.components.lootdropper:SpawnLootPrefab("halloween_ornament_1", pt) -- ghost
			end
        end
    end
end

local function onfullmoon(inst, isfullmoon)
    if isfullmoon then
        inst.components.childspawner:StartSpawning()
        inst.components.childspawner:StopRegen()
    else
        inst.components.childspawner:StopSpawning()
        inst.components.childspawner:StartRegen()
        ReturnChildren(inst)
    end
end

local function oninit(inst)
    inst:WatchWorldState("isfullmoon", onfullmoon)
    onfullmoon(inst, TheWorld.state.isfullmoon)
end

local function gravefn()
    local inst = CreateEntity()

	inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeWeakWaterObstaclePhysics(inst, nil, 0.2, nil, 0.15)

    inst:AddTag("fishable") --Does NOT have the fishable component, but can be fished anyways.

    inst.anim = math.random(1, #anims)

    inst.AnimState:SetBank("graves_water")
    inst.AnimState:SetBuild("graves_water")
    inst.AnimState:PlayAnimation(anims[inst.anim].idle, true)
    --inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)

    inst:AddTag("waterygrave")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.FISH)
    inst.components.workable:SetWorkLeft(1)

    inst:ListenForEvent("retrieve", onretrieveevent)

    inst.components.workable:SetOnFinishCallback(onfinishcallback)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    -- inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "pirateghost"
    inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner:SetSpawnPeriod(10, 3)
    inst.components.childspawner.allowwater = true

    inst:DoTaskInTime(0, oninit)

    return inst
end

return Prefab( "waterygrave", gravefn, assets, prefabs )
