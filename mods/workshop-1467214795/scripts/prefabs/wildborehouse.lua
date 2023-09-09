require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/pig_house_tropical.zip"),
    Asset("SOUND", "sound/pig.fsb"),
}

local prefabs =
{
    "wildbore",
    "splash_sink",
}

-- Client update

local function LightsOn(inst)
    if not inst:HasTag("burnt") and not inst.lightson then
        inst.Light:Enable(true)
        inst.AnimState:PlayAnimation("lit", true)
        inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lighton")
        inst.lightson = true
    end
end

local function LightsOff(inst)
    if not inst:HasTag("burnt") and inst.lightson then
        inst.Light:Enable(false)
        inst.AnimState:PlayAnimation("idle", true)
        inst.SoundEmitter:PlaySound("dontstarve/pig/pighut_lightoff")
        inst.lightson = false
    end
end

local function onfar(inst)
    if not inst:HasTag("burnt") and inst.components.spawner and inst.components.spawner:IsOccupied() then
        LightsOn(inst)
    end
end

local function getstatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst.components.spawner ~= nil and
            inst.components.spawner:IsOccupied() and
            (inst.lightson and "FULL" or "LIGHTSOUT"))
        or nil
end

local function onnear(inst)
    if not inst:HasTag("burnt") and inst.components.spawner and inst.components.spawner:IsOccupied() then
        LightsOff(inst)
    end
end

local function onwere(child)
    if child.parent ~= nil and not child.parent:HasTag("burnt") then
        child.parent.SoundEmitter:KillSound("pigsound")
        child.parent.SoundEmitter:PlaySound("dontstarve/pig/werepig_in_hut", "pigsound")
    end
end

local function onnormal(child)
    if child.parent ~= nil and not child.parent:HasTag("burnt") then
        child.parent.SoundEmitter:KillSound("pigsound")
        child.parent.SoundEmitter:PlaySound("ia/creatures/wild_boar/boar_in_hut", "pigsound")
    end
end

local function onoccupieddoortask(inst)
    inst.doortask = nil
    if not inst.components.playerprox:IsPlayerClose() then
        LightsOn(inst)
    end
end

local function onoccupied(inst, child)
    if not inst:HasTag("burnt") then
        inst.SoundEmitter:PlaySound("ia/creatures/wild_boar/boar_in_hut", "pigsound")
        inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")

        if inst.doortask ~= nil then
            inst.doortask:Cancel()
        end
        inst.doortask = inst:DoTaskInTime(1, onoccupieddoortask)
        if child ~= nil then
            inst:ListenForEvent("transformwere", onwere, child)
            inst:ListenForEvent("transformnormal", onnormal, child)
        end
    end
end

local function onvacate(inst, child)
    if not inst:HasTag("burnt") then
        if inst.doortask ~= nil then
            inst.doortask:Cancel()
            inst.doortask = nil
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
        inst.SoundEmitter:KillSound("pigsound")
        LightsOff(inst)

        if child ~= nil then
            inst:RemoveEventCallback("transformwere", onwere, child)
            inst:RemoveEventCallback("transformnormal", onnormal, child)
            if child.components.werebeast ~= nil then
                child.components.werebeast:ResetTriggers()
            end

            local child_platform = TheWorld.Map:GetPlatformAtPoint(child.Transform:GetWorldPosition())
            if (child_platform == nil and not child:IsOnValidGround()) then
                local fx = SpawnPrefab("splash_sink")
                fx.Transform:SetPosition(child.Transform:GetWorldPosition())

                child:Remove()
            else
                if child.components.health ~= nil then
                    child.components.health:SetPercent(1)
                end
                child:PushEvent("onvacatehome")
            end
        end
    end
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    if inst.doortask ~= nil then
        inst.doortask:Cancel()
        inst.doortask = nil
    end
    if inst.components.spawner ~= nil and inst.components.spawner:IsOccupied() then
        inst.components.spawner:ReleaseChild()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        if inst.lightson then
            inst.AnimState:PushAnimation("lit")
        else
            inst.AnimState:PushAnimation("idle")
        end
        if inst.components.spawner and inst.components.spawner.child then

            local child = inst.components.spawner.child
            if inst.components.spawner:IsOccupied() then
                inst.components.spawner:ReleaseChild()
                if child then
                    -- from what ive seen in ds and dst pigman and wildbores play this animation when leaving there house at night because there actually trying to go back into there house, for example if you light a pighouse on fire they try but cant go back inside. Manually setting this fixes wildbores sometimes attacking before they play the gohome animation making them much harder to deal with.
                    child.sg:GoToState("gohome")
                end
            end
            if child then
                child.components.combat:SuggestTarget(worker)
            end
        end
    end
end

local function onstartdaydoortask(inst)
    inst.doortask = nil
    if not inst:HasTag("burnt") then
        inst.components.spawner:ReleaseChild()
    end
end

local function onstartdaylighttask(inst)
    if inst:IsLightGreaterThan(0.8) then  -- they have their own light! make sure it's brighter than that out.
        LightsOff(inst)
        inst.doortask = inst:DoTaskInTime(1 + math.random() * 2, onstartdaydoortask)
    elseif TheWorld.state.iscaveday then
        inst.doortask = inst:DoTaskInTime(1 + math.random() * 2, onstartdaylighttask)
    else
        inst.doortask = nil
    end
end

local function OnStartDay(inst)
    -- print(inst, "OnStartDay")
    if not inst:HasTag("burnt") and inst.components.spawner:IsOccupied() then
        if inst.doortask ~= nil then
            inst.doortask:Cancel()
        end
        inst.doortask = inst:DoTaskInTime(1 + math.random() * 2, onstartdaylighttask)
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle")
end

local function onburntup(inst)
    if inst.doortask ~= nil then
        inst.doortask:Cancel()
        inst.doortask = nil
    end
    if inst.inittask ~= nil then
        inst.inittask:Cancel()
        inst.inittask = nil
    end
end

local function onignite(inst)
    if inst.components.spawner ~= nil and inst.components.spawner:IsOccupied() then
        inst.components.spawner:ReleaseChild()
    end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function spawncheckday(inst)
    inst.inittask = nil
    inst:WatchWorldState("startcaveday", OnStartDay) -- not sure why but all the dst stuff checks startcaveday instead of isday -Half
    if inst.components.spawner ~= nil and inst.components.spawner:IsOccupied() then
        if TheWorld.state.iscaveday or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
            inst.components.spawner:ReleaseChild()
        else
            inst.components.playerprox:ForceUpdate()
            onoccupieddoortask(inst)
        end
    end
end

local function oninit(inst)
    inst.inittask = inst:DoTaskInTime(math.random(), spawncheckday)
    if inst.components.spawner ~= nil and
        inst.components.spawner.child == nil and
        inst.components.spawner.childname ~= nil and
        not inst.components.spawner:IsSpawnPending() then
        local child = SpawnPrefab(inst.components.spawner.childname)
        if child ~= nil then
            inst.components.spawner:TakeOwnership(child)
            inst.components.spawner:GoHome(child)
        end
    end
end

local function OnPreLoad(inst, data)
    WorldSettings_Spawner_PreLoad(inst, data, TUNING.WILDBOREHOUSE_SPAWN_TIME)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst.MiniMapEntity:SetIcon("wildborehouse.tex")
    -- {anim="level1", sound="dontstarve/common/campfire", radius=2, intensity=.75, falloff=.33, colour = {197/255,197/255,170/255}},
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(1)
    inst.Light:Enable(false)
    inst.Light:SetColour(180/255, 195/255, 50/255)

    inst.AnimState:SetBank("pig_house_tropical")
    inst.AnimState:SetBuild("pig_house_tropical")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("structure")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("spawner")
    WorldSettings_Spawner_SpawnDelay(inst, TUNING.WILDBOREHOUSE_SPAWN_TIME, TUNING.WILDBOREHOUSE_ENABLED)
    inst.components.spawner:Configure("wildbore", TUNING.WILDBOREHOUSE_SPAWN_TIME)
    inst.components.spawner.onoccupied = onoccupied
    inst.components.spawner.onvacate = onvacate
    inst.components.spawner:SetWaterSpawning(false, true)
    inst.components.spawner:CancelSpawning()

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(10, 13)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    -- inst:AddComponent("blowinwindgust")
    -- inst.components.blowinwindgust:SetWindSpeedThreshold(TUNING.PIGHOUSE_WINDBLOWN_SPEED)
    -- inst.components.blowinwindgust:SetDestroyChance(TUNING.PIGHOUSE_WINDBLOWN_FALL_CHANCE)
    -- inst.components.blowinwindgust:SetDestroyFn(ongusthammerfn)
    -- inst.components.blowinwindgust:Start()

    inst.OnSave = onsave
    inst.OnLoad = onload
    inst.OnPreLoad = OnPreLoad

    inst:ListenForEvent("burntup", onburntup)
    inst:ListenForEvent("onignite", onignite)
    inst:ListenForEvent("onbuilt", onbuilt)
    inst.inittask = inst:DoTaskInTime(0, oninit)

    MakeSnowCovered(inst)
    MakeMediumBurnable(inst, nil, nil, true)
    MakeLargePropagator(inst)
    MakeHauntableWork(inst)

    return inst
end

return Prefab("wildborehouse", fn, assets, prefabs ),
    MakePlacer("wildborehouse_placer", "pig_house_tropical", "pig_house_tropical", "idle")
