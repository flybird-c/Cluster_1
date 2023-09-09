local assets =
{
    Asset("ANIM", "anim/seagull_shadow.zip"),
}

local prefabs =
{
    "seagull",
    "circlingseagull",
}

local function RemoveSeagullShadow(inst, shadow)
    shadow:KillShadow()
    for i, v in ipairs(inst.seagullshadows) do
        if v == shadow then
            table.remove(inst.seagullshadows, i)
            return
        end
    end
end

local function SpawnSeagullShadow(inst)
    local shadow = SpawnPrefab("circlingseagull")
    shadow.components.circler:SetCircleTarget(inst)
    shadow.components.circler:Start()
    table.insert(inst.seagullshadows, shadow)
end

local function UpdateShadows(inst)
    local count = inst.components.childspawner.childreninside
    local old = #inst.seagullshadows
    if old < count then
        for i = old + 1, count do
            SpawnSeagullShadow(inst)
        end
    elseif old > count then
        for i = old, count + 1, -1 do
            RemoveSeagullShadow(inst, inst.seagullshadows[i])
        end
    end
	-- print(inst,"SHADOWS",#inst.seagullshadows)
end
-- c_sel().components.childspawner.onaddchild(c_sel())

local function OnSpawn(inst, child)
    for i, shadow in ipairs(inst.seagullshadows) do
        local dist = shadow.components.circler.distance
        local angle = shadow.components.circler.angleRad
        local pos = inst:GetPosition()
        local offset = FindWalkableOffset(pos, angle, dist, 8, false, nil, nil, true)
        if offset ~= nil then
            child.Transform:SetPosition(pos.x + offset.x, 30, pos.z + offset.z)
        else
            child.Transform:SetPosition(pos.x, 30, pos.y)
        end
        child.sg:GoToState("glide")
        RemoveSeagullShadow(inst, shadow)
        return
    end
end

--This function is a little hack against bad practises in SW -M
local function OnDeleteSeagull(seagull)
	if seagull and seagull.sg and seagull.sg.currentstate.name == "flyaway" then
		if seagull.seagullspawner then
			seagull.seagullspawner.components.childspawner:AddChildrenInside(1)
		end
	end
end

local function SpawnSeagull(inst)
    if not inst.components.childspawner:CanSpawn() then
        return
    end

	local seagull = inst.components.childspawner:SpawnChild()
	if seagull ~= nil then
		local x, y, z = inst.Transform:GetWorldPosition()
		seagull.Transform:SetPosition(x + math.random() * 20 - 10, 30, z + math.random() * 20 - 10)

		seagull.seagullspawner = inst
		inst:ListenForEvent("onremove", OnDeleteSeagull, seagull)

		-- inst.SoundEmitter:PlaySound("ia/creatures/seagull/distant")
	end
end

local function CancelAwakeTasks(inst)
    if inst.waketask ~= nil then
        inst.waketask:Cancel()
        inst.waketask = nil
    end
    if inst.spawntask ~= nil then
        inst.spawntask:Cancel()
        inst.spawntask = nil
    end
end

local function OnEntitySleep(inst)
    for i = #inst.seagullshadows, 1, -1 do
        inst.seagullshadows[i]:Remove()
        table.remove(inst.seagullshadows, i)
    end
    CancelAwakeTasks(inst)
end

local function OnWakeTask(inst)
    inst.waketask = nil
    if not inst:IsAsleep() then
        UpdateShadows(inst)
    end
end

local function OnEntityWake(inst)
    if inst.waketask == nil then
        inst.waketask = inst:DoTaskInTime(.5, OnWakeTask)
    end
    if inst.spawntask == nil then
        inst.spawntask = inst:DoPeriodicTask(TUNING.SEAGULLSPAWNER_SPAWN_PERIOD * .1, SpawnSeagull)
    end
end

local function SpawnerOnIsNight(inst, isnight)
    if isnight then
        inst.OnEntityWake = nil
        inst.components.childspawner:StopSpawning()
        if not inst.components.childspawner.regening and inst.components.childspawner.numchildrenoutside + inst.components.childspawner.childreninside < inst.components.childspawner.maxchildren then
            inst.components.childspawner:StartRegen()
        end
        -- ReturnChildren(inst)
        CancelAwakeTasks(inst)
    else
        inst.OnEntityWake = OnEntityWake
        inst.components.childspawner:StartSpawning()
        if not inst:IsAsleep() then
            OnEntityWake(inst)
        end
    end
end

local function SpawnerOnIsWinter(inst, iswinter)
    if iswinter then
        inst.OnEntityWake = nil
        inst:StopWatchingWorldState("isnight", SpawnerOnIsNight)
        inst.components.childspawner:StopSpawning()
        inst.components.childspawner:StopRegen()
        -- ReturnChildren(inst)
        CancelAwakeTasks(inst)
    else
        inst:WatchWorldState("isnight", SpawnerOnIsNight)
        SpawnerOnIsNight(inst, TheWorld.state.isnight)
    end
end

local function OnAddChild(inst)
	-- print("about to update shadows")
    UpdateShadows(inst)
    if inst.components.childspawner.numchildrenoutside + inst.components.childspawner.childreninside >= inst.components.childspawner.maxchildren then
        inst.components.childspawner:StopRegen()
    end
end

local function SpawnerOnInit(inst)
    inst.OnEntitySleep = OnEntitySleep
    inst:WatchWorldState("iswinter", SpawnerOnIsWinter)
    SpawnerOnIsWinter(inst, TheWorld.state.iswinter)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("seagull.tex")

    inst:AddTag("seagullspawner")
    inst:AddTag("CLASSIFIED")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "seagull"
    inst.components.childspawner:SetSpawnedFn(OnSpawn)
    inst.components.childspawner:SetOnAddChildFn(OnAddChild)
    inst.components.childspawner:SetMaxChildren(math.random(1, 2))
    inst.components.childspawner:SetSpawnPeriod(TUNING.SEAGULLSPAWNER_SPAWN_PERIOD)
    inst.components.childspawner:SetRegenPeriod(TUNING.SEAGULLSPAWNER_REGEN_PERIOD)
    inst.components.childspawner:StopRegen()
    inst.components.childspawner.allowwater = true
    inst.components.childspawner.allowboats = true

    inst.seagullshadows = {}
    inst.spawntask = nil
    inst.waketask = nil
    inst:DoTaskInTime(0, SpawnerOnInit)

    return inst
end

-----------------------------------------------------------------------------------

local MAX_FADE_FRAME = math.floor(3 / FRAMES + .5)

local function OnUpdateFade(inst, dframes)
    local done
    if inst._isfadein:value() then
        local frame = inst._fadeframe:value() + dframes
        done = frame >= MAX_FADE_FRAME
        inst._fadeframe:set_local(done and MAX_FADE_FRAME or frame)
    else
        local frame = inst._fadeframe:value() - dframes
        done = frame <= 0
        inst._fadeframe:set_local(done and 0 or frame)
    end

    local k = inst._fadeframe:value() / MAX_FADE_FRAME
    inst.AnimState:OverrideMultColour(1, 1, 1, k)

    if done then
        inst._fadetask:Cancel()
        inst._fadetask = nil
        if inst._killed then
            --don't need to check ismastersim, _killed will never be set on clients
            inst:Remove()
            return
        end
    end

    if TheWorld.ismastersim then
        if inst._fadeframe:value() > 0 then
            inst:Show()
        else
            inst:Hide()
        end
    end
end

local function OnFadeDirty(inst)
    if inst._fadetask == nil then
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateFade, nil, 1)
    end
    OnUpdateFade(inst, 0)
end

local function CircleOnIsNight(inst, isnight)
    inst._isfadein:set(not isnight)
    inst._fadeframe:set(inst._fadeframe:value())
    OnFadeDirty(inst)
end

local function CircleOnIsWinter(inst, iswinter)
    if iswinter then
        inst:StopWatchingWorldState("isnight", CircleOnIsNight)
        CircleOnIsNight(inst, true)
    else
        inst:WatchWorldState("isnight", CircleOnIsNight)
        CircleOnIsNight(inst, TheWorld.state.isnight)
    end
end

local function CircleOnInit(inst)
    -- inst:WatchWorldState("iswinter", CircleOnIsWinter)
    -- CircleOnIsWinter(inst, TheWorld.state.iswinter)
	CircleOnIsNight(inst, false)
end

local function DoFlap(inst)
    if math.random() > 0.66 then 
        inst.AnimState:PlayAnimation("shadow_flap_loop") 
        for i = 2, math.random(3, 6) do
            inst.AnimState:PushAnimation("shadow_flap_loop") 
        end
        inst.AnimState:PushAnimation("shadow") 
    end
end

local function KillShadow(inst)
    if inst._fadeframe:value() > 0 and not inst:IsAsleep() then
        inst:StopWatchingWorldState("iswinter", CircleOnIsWinter)
        inst:StopWatchingWorldState("isnight", CircleOnIsNight)
        inst._killed = true
        inst._isfadein:set(false)
        inst._fadeframe:set(inst._fadeframe:value())
        OnFadeDirty(inst)
    else
        inst:Remove()
    end
end

local function circlingseagullfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("seagull_shadow")
    inst.AnimState:SetBuild("seagull_shadow")
    inst.AnimState:PlayAnimation("shadow", true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:OverrideMultColour(1, 1, 1, 0)

    inst:AddTag("FX")

    inst._fadeframe = net_byte(inst.GUID, "circlingseagull._fadeframe", "fadedirty")
    inst._isfadein = net_bool(inst.GUID, "circlingseagull._isfadein", "fadedirty")
    inst._fadetask = nil

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("fadedirty", OnFadeDirty)

        return inst
    end

    inst:AddComponent("circler")

    inst:DoTaskInTime(0, CircleOnInit)
    inst:DoPeriodicTask(math.random(3, 5), DoFlap)

    inst.KillShadow = KillShadow

    inst.persists = false

    return inst
end

return Prefab("seagullspawner", fn, nil, prefabs),
    Prefab("circlingseagull", circlingseagullfn, assets)
