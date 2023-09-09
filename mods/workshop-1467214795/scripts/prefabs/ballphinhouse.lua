require("worldsettingsutil")

local assets =
{
    Asset("ANIM", "anim/ballphin_house.zip"),
    Asset("SOUND", "sound/pig.fsb"),
}

local prefabs =
{
    "ballphin",
}

-- local function onfar(inst)
-- end

local function LightsOn(inst)
    if not inst:HasTag("burnt") and not inst.lightson then
        inst.Light:Enable(true)

        inst.AnimState:PlayAnimation("lit", true)
        inst.SoundEmitter:PlaySound("ia/common/ballphin_house/lit")
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

local function getstatus(inst)
    if inst.components.childspawner and inst.components.childspawner.childreninside > 0 then
        return "FULL"
    end
end

local function onoccupied(inst, child)
    if not inst:HasTag("burnt") then
        inst.SoundEmitter:PlaySound("ia/creatures/balphin/in_house_LP", "pigsound")
        inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")

        if inst.doortask then
            inst.doortask:Cancel()
            inst.doortask = nil
        end

        inst.doortask = inst:DoTaskInTime(1, LightsOn)
    end
end

local function onvacate(inst)
    if not inst:HasTag("burnt") then
        if inst.doortask then
            inst.doortask:Cancel()
            inst.doortask = nil
        end
        inst.SoundEmitter:KillSound("pigsound")
    end
end

local function onspawned(inst, child)
    if not inst:HasTag("burnt") then
        inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
        if child then
            child.mood_override = inst.components.mood and inst.components.mood:OnSave()  -- since ballphin mood gets reset when entering a ballphin house, override the mood with the houses
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

    inst.components.lootdropper:DropLoot()

    if inst.components.childspawner then
        inst.components.childspawner:ReleaseAllChildren()
        inst:RemoveComponent("childspawner")
    end

    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("stone")
    inst:Remove()
end

local function onignite(inst)
    if inst.components.childspawner then
        inst.components.childspawner:ReleaseAllChildren()
    end
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
    if inst.newhometask then
      inst.newhometask:Cancel()
      inst.newhometask = nil
    end
    if inst.releasetask then
      inst.releasetask:Cancel()
      inst.releasetask = nil
    end
end

-- local function ongusthammerfn(inst)
--     onhammered(inst, nil)
-- end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        if inst.lightson then
            inst.AnimState:PushAnimation("lit")
        else
            inst.AnimState:PushAnimation("idle")
        end
    end
end

local function OnStartNight(inst)
    if inst.newhometask then
        inst.newhometask:Cancel()
        inst.newhometask = nil
    end
end

local function OnStartDay(inst)
    -- print(inst, "OnDay")
    if not inst:HasTag("burnt") then
        -- print("##----> DAY TEST",inst.components.childspawner.childreninside)
        if inst.components.childspawner then
            inst.components.childspawner:StartSpawning()
            if inst.components.childspawner.childreninside > 0 then
                -- print("##----> DAY, RELEASE BALLPHINS!`")
                LightsOff(inst)
                if inst.doortask then
                    inst.doortask:Cancel()
                    inst.doortask = nil
                end
                local segs = TheWorld.net.components.clock:OnSave().segs
                local midday = (segs.day*TUNING.SEG_TIME) / 2
                inst.releasetask = inst:DoTaskInTime(midday, function(inst)  -- if by half the day not all the ballphins have left there house simply release them all
                    if inst.components.childspawner.childreninside > 0 and TheWorld.state.isday then
                        inst.components.childspawner:ReleaseAllChildren()  -- in sw only a single ballphin will exit its house everyday even though there can be an infinite amount -Half
                    end
                end)
            end
        end
    end
end

local function OnStartDusk(inst)
    -- print(inst, "OnDay")
    if inst.releasetask then
        inst.releasetask:Cancel()
        inst.releasetask = nil
    end
    if not inst:HasTag("burnt") and inst.components.childspawner then
        inst.components.childspawner:StopSpawning()
        if not inst.lightson and inst.components.childspawner and inst.components.childspawner.childreninside > 0 then --fixes a ds bug where the lights dont go on for balphins still inside
            inst.doortask = inst:DoTaskInTime(1, LightsOn)
        end
        -- instead of all ballphins merging into one pod and sharing the same house like in sw, if a ballphin has no house try give it a random one nearby throughout dusk
        -- ballphins themselfs also pick a random house at dthe start of dusk if they have none
        inst.newhometask = inst:DoPeriodicTask(5, function(inst)
            if TheWorld.state.isdusk and inst.components.childspawner then
                local homeless = FindEntity(inst, 15, function(ballphin) return not (ballphin.components.homeseeker and ballphin.components.homeseeker:HasHome()) end, {"ballphin"})
                local x, y, z = inst.Transform:GetWorldPosition()
                local homeless = TheSim:FindEntities(x, y, z, 15, {"ballphin"})
                for i, v in pairs(homeless) do
                    if not (v.components.homeseeker and v.components.homeseeker:HasHome()) then
                        v:DoTaskInTime(math.random(2, 7), function(ballphin)
                            if inst.components.childspawner and not (ballphin.components.homeseeker and ballphin.components.homeseeker:HasHome()) then -- make sure the ballphin hasnt gotten a new home by now
                                inst.components.childspawner:TakeOwnership(ballphin)
                            end
                        end)
                    end
                end
            elseif inst.newhometask then
                inst.newhometask:Cancel()
                inst.newhometask = nil
            end
        end)
    end
end

local function spawncheckday(inst)
    inst.inittask = nil
    inst:WatchWorldState("startcaveday", OnStartDay)  -- not sure why but all the dst stuff checks startcaveday instead of startday -Half
    inst:WatchWorldState("startdusk", OnStartDusk)
    inst:WatchWorldState("startnight", OnStartNight)
    if inst.components.childspawner and inst.components.childspawner.childreninside > 0 then
        if TheWorld.state.isday then
            OnStartDay(inst)
        else
            OnStartDusk(inst)
        end
    end
end

local function oninit(inst)
    inst.inittask = inst:DoTaskInTime(math.random(), spawncheckday)
end

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("ia/common/ballphin_house_craft")
    inst.SoundEmitter:PlaySound("ia/creatures/seacreature_movement/splash_medium")
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle")
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function OnPreLoad(inst, data)
    WorldSettings_ChildSpawner_PreLoad(inst, data, TUNING.BALLPHINHOUSE_RELEASE_TIME, TUNING.BALLPHINHOUSE_REGEN_TIME)
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("ballphinhouse.tex")

    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetRadius(2)
    inst.Light:Enable(false)
    inst.Light:SetColour(0/255, 180/255, 255/255)

    MakeWaterObstaclePhysics(inst, 1.5, 2, 0.75)

    inst.AnimState:SetBank("ballphin_house")
    inst.AnimState:SetBuild("ballphin_house")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("structure")
    inst:AddTag("ballphin_palace")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("lootdropper") -- they drop the loot from the crafting recipe

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    -- inst:AddComponent( "spawner" )
    -- WorldSettings_Spawner_SpawnDelay(inst, TUNING.BALLPHINHOUSE_SPAWN_TIME, TUNING.BALLPHINHOUSE_ENABLED)
    -- inst.components.spawner:Configure( "ballphin", TUNING.BALLPHINHOUSE_SPAWN_TIME)
    -- inst.components.spawner.onoccupied = onoccupied
    -- inst.components.spawner.onvacate = onvacate
    -- inst.components.spawner:CancelSpawning()  --sw was updated at some point to allow multipule ballphins in a single ballphinhouse

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "ballphin"
    inst.components.childspawner:SetRegenPeriod(TUNING.BALLPHINHOUSE_REGEN_TIME)
    inst.components.childspawner:SetSpawnPeriod(TUNING.BALLPHINHOUSE_RELEASE_TIME)
    inst.components.childspawner:SetMaxChildren(TUNING.BALLPHIN_PALACE_MAX_CHILDREN)
    inst.components.childspawner:SetOccupiedFn(onoccupied)
    inst.components.childspawner:SetVacateFn(onvacate)
    inst.components.childspawner:SetSpawnedFn(onspawned)
    inst.components.childspawner.allowmorethanmaxchildren = true
    inst.components.childspawner.wateronly = true
    WorldSettings_ChildSpawner_SpawnPeriod(inst, TUNING.BALLPHINHOUSE_RELEASE_TIME, TUNING.BALLPHINHOUSE_ENABLED)
    WorldSettings_ChildSpawner_RegenPeriod(inst, TUNING.BALLPHINHOUSE_REGEN_TIME, TUNING.BALLPHINHOUSE_ENABLED)
    if not TUNING.BALLPHINHOUSE_ENABLED then
        inst.components.childspawner.childreninside = 0
    end

    inst:AddComponent("mood")
    inst.components.mood:SetMoodTimeInDays(TUNING.BALLPHIN_MATING_SEASON_LENGTH, TUNING.BALLPHIN_MATING_SEASON_WAIT, TUNING.BALLPHIN_MATING_ALWAYS, TUNING.BALLPHIN_MATING_SEASON_LENGTH, TUNING.BALLPHIN_MATING_SEASON_WAIT, TUNING.BALLPHIN_MATING_ENABLED)
    inst.components.mood:SetMoodSeason(SEASONS.MILD)
    inst.components.mood:CheckForMoodChange()

    -- inst.components.childspawner.spawnonwater = true
    -- inst.components.childspawner.wateronly = true --need rot support first -Half

    -- inst:AddComponent( "playerprox" ) --this is never even used.. -Half
    -- inst.components.playerprox:SetDist(10,13)
    -- inst.components.playerprox:SetOnPlayerNear(onnear)
    -- inst.components.playerprox:SetOnPlayerFar(onfar)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst.OnSave = onsave
    inst.OnLoad = onload
    inst.OnPreLoad = OnPreLoad

    inst:ListenForEvent("burntup", onburntup)
    inst:ListenForEvent("onignite", onignite)
    inst:ListenForEvent("onbuilt", onbuilt)

    inst.inittask = inst:DoTaskInTime(0, oninit)

    MakeHauntableWork(inst)
    MakeSnowCovered(inst, .01)

    return inst
end

return Prefab( "ballphinhouse", fn, assets, prefabs ),
    MakePlacer("ballphinhouse_placer", "ballphin_house", "ballphin_house", "idle", false, false, false)
