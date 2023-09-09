require "prefabutil"

local function OnIsPathFindingDirty(inst)
    if inst._ispathfinding:value() then
        if inst._pfpos == nil then
            inst._pfpos = inst:GetPosition()
            TheWorld.Pathfinder:AddWall(inst._pfpos:Get())
        end
    elseif inst._pfpos ~= nil then
        TheWorld.Pathfinder:RemoveWall(inst._pfpos:Get())
        inst._pfpos = nil
    end
end

local function InitializePathFinding(inst)
    inst:ListenForEvent("onispathfindingdirty", OnIsPathFindingDirty)
    OnIsPathFindingDirty(inst)
end

local function makeobstacle(inst)
    inst.Physics:SetActive(true)
    inst._ispathfinding:set(true)
end

local function clearobstacle(inst)
    inst.Physics:SetActive(false)
    inst._ispathfinding:set(false)
end

local anims =
{
    { threshold = 0, anim = "broken" },
    { threshold = 0.4, anim = "onequarter" },
    { threshold = 0.5, anim = "half" },
    { threshold = 0.99, anim = "threequarter" },
    { threshold = 1, anim = { "fullA", "fullB", "fullC" } },
}

local function resolveanimtoplay(inst, percent)
	local animname
    for i, v in ipairs(anims) do
        if percent <= v.threshold then
            if type(v.anim) == "table" then
                -- get a stable animation, by basing it on world position
                local x, y, z = inst.Transform:GetWorldPosition()
                local x = math.floor(x)
                local z = math.floor(z)
                local q1 = #v.anim + 1
                local q2 = #v.anim + 4
                local t = ( ((x%q1)*(x+3)%q2) + ((z%q1)*(z+3)%q2) )% #v.anim + 1
                animname = v.anim[t]
				break
            else
                animname = v.anim
				break
            end
        end
    end
	
    if animname and inst:HasTag("water_wall") then
        animname = "water_" .. animname
    end
	
	return animname
end

local function onhealthchange(inst, old_percent, new_percent)
    local anim_to_play = resolveanimtoplay(inst, new_percent)
    if new_percent > 0 then
        if old_percent <= 0 then
            makeobstacle(inst)
        end
        inst.AnimState:PlayAnimation(anim_to_play.."_hit")
        inst.AnimState:PushAnimation(anim_to_play, false)
    else
        if old_percent > 0 then
            clearobstacle(inst)
        end
        inst.AnimState:PlayAnimation(anim_to_play)
    end
end

local function keeptargetfn()
    return false
end

local function onload(inst)
    if inst.components.health:IsDead() then
        clearobstacle(inst)
    end
end

local function onremove(inst)
    inst._ispathfinding:set_local(false)
    OnIsPathFindingDirty(inst)
end

local function checkmaterialfn(inst, item)
    return not item:HasTag("wallbuilder") or item.prefab == inst.prefab .."_item"
end

function MakeWallType(data)
    local assets =
    {
        Asset("ANIM", "anim/wall.zip"),
        Asset("ANIM", "anim/wall_water.zip"),
        Asset("ANIM", "anim/wall_"..data.name..".zip"),
    }

    local prefabs =
    {
        "collapse_small",
        -- "brokenwall_"..data.name, --screw that, only used by ruins anyways
    }

    local function ondeploywall(inst, pt, deployer)
        --inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spider_egg_sack")
        local wall = SpawnPrefab("wall_"..data.name) 
        if wall ~= nil then 
            local x = math.floor(pt.x) + .5
            local z = math.floor(pt.z) + .5
            wall.Physics:SetCollides(false)
            wall.Physics:Teleport(x, 0, z)
            wall.Physics:SetCollides(true)
            inst.components.stackable:Get():Remove()
            
            if data.buildsound ~= nil then
                wall.SoundEmitter:PlaySound(data.buildsound)
            end
        end
    end

    local function onhammered(inst, worker)
        if data.maxloots ~= nil and data.loot ~= nil then
            local num_loots = math.max(1, math.floor(data.maxloots * inst.components.health:GetPercent()))
            for i = 1, num_loots do
                inst.components.lootdropper:SpawnLootPrefab(data.loot)
            end
        end

        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        if data.material ~= nil then
            fx:SetMaterial(data.material)
        end

        inst:Remove()
    end
	
	-- local function ongusthammerfn(inst)
	    -- --onhammered(inst, nil)
	    -- inst.components.health:DoDelta(-data.windblown_damage, false, "wind")
	-- end

    local function CanDeployOnWallWater(inst, pt)
        return TheWorld.Map:CanDeployWaterWallAtPoint(pt, inst)
    end

    local function itemfn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst:AddTag("wallbuilder")

        inst.AnimState:SetBank("wall")
        inst.AnimState:SetBuild("wall_"..data.name)
        inst.AnimState:PlayAnimation("idle")

		MakeInventoryFloatable(inst)
		inst.components.floater:UpdateAnimations("idle_water", "idle")

        if data.waterwall then
            inst._custom_candeploy_fn = CanDeployOnWallWater
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")

        inst:AddComponent("repairer")

        inst.components.repairer.repairmaterial = data.material
        inst.components.repairer.healthrepairvalue = data.maxhealth / 6

        inst:AddComponent("deployable")
        inst.components.deployable.ondeploy = ondeploywall
        inst.components.deployable:SetDeployMode(DEPLOYMODE.WALL)
		if data.waterwall then
            inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM)
		end
		
        MakeHauntableLaunch(inst)

        return inst
    end

    local function onhit(inst)
		if data.destroysound ~= nil then
			inst.SoundEmitter:PlaySound(data.destroysound)
		elseif data.material ~= nil then
            inst.SoundEmitter:PlaySound("dontstarve/common/destroy_"..data.material)
        end

        local healthpercent = inst.components.health:GetPercent()
        if healthpercent > 0 then
            local anim_to_play = resolveanimtoplay(inst, healthpercent)
            inst.AnimState:PlayAnimation(anim_to_play.."_hit")
            inst.AnimState:PushAnimation(anim_to_play, inst:HasTag("water_wall"))
        end
    end

    local function onrepaired(inst)
        if data.buildsound ~= nil then
            inst.SoundEmitter:PlaySound(data.buildsound)
        end
        makeobstacle(inst)
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.Transform:SetEightFaced()

        if data.waterwall then
            MakeWaterObstaclePhysics(inst, .5)
            inst:AddTag("water_wall")
        else
            MakeObstaclePhysics(inst, .5)
		end
        inst.Physics:SetDontRemoveOnSleep(true)

        --inst.Transform:SetScale(1.3,1.3,1.3)

        inst:AddTag("wall")
        inst:AddTag("noauradamage")
        inst:AddTag("nointerpolate")

        inst.AnimState:SetBank(data.waterwall and "wall_water" or "wall")
        inst.AnimState:SetBuild("wall_"..data.name)
        inst.AnimState:PlayAnimation(data.waterwall and "water_half" or "half")

        for i, v in ipairs(data.tags) do
            inst:AddTag(v)
        end

        MakeSnowCoveredPristine(inst)

        inst._pfpos = nil
        inst._ispathfinding = net_bool(inst.GUID, "_ispathfinding", "onispathfindingdirty")
        makeobstacle(inst)
        --Delay this because makeobstacle sets pathfinding on by default
        --but we don't to handle it until after our position is set
        inst:DoTaskInTime(0, InitializePathFinding)

        inst.OnRemoveEntity = onremove

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end
		
        inst:AddComponent("inspectable")
        inst:AddComponent("lootdropper")

        inst:AddComponent("repairable")
        inst.components.repairable.repairmaterial = data.material
        inst.components.repairable.onrepaired = onrepaired
        inst.components.repairable.checkmaterialfn = checkmaterialfn

        inst:AddComponent("combat")
        inst.components.combat:SetKeepTargetFunction(keeptargetfn)
        inst.components.combat.onhitfn = onhit

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(data.maxhealth)
        inst.components.health:SetCurrentHealth(data.maxhealth * .5)
        inst.components.health.ondelta = onhealthchange
        inst.components.health.nofadeout = true
        inst.components.health.canheal = false

        -- if data.flammable then
            -- MakeMediumBurnable(inst)
            -- MakeLargePropagator(inst)
            -- inst.components.burnable.flammability = .5
        -- else
            inst.components.health.fire_damage_scale = 0
        -- end

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(3)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit) 

		-- if data.windblown_speed and data.windblown_fall_chance and data.windblown_damage then
		    -- inst:AddComponent("blowinwindgust")
		    -- inst.components.blowinwindgust:SetWindSpeedThreshold(data.windblown_speed)
		    -- inst.components.blowinwindgust:SetDestroyChance(data.windblown_fall_chance)
		    -- inst.components.blowinwindgust:SetDestroyFn(ongusthammerfn)
		    -- inst.components.blowinwindgust:Start()
		-- end
		
        MakeHauntableWork(inst)

        inst.OnLoad = onload

        MakeSnowCovered(inst)

        return inst
    end

    return Prefab("wall_"..data.name, fn, assets, prefabs),
        Prefab("wall_"..data.name.."_item", itemfn, assets, { "wall_"..data.name, "wall_"..data.name.."_item_placer" }),
        MakePlacer("wall_"..data.name.."_item_placer", "wall", "wall_"..data.name, "half", false, false, true, nil, nil, "eight")
end

local wallprefabs = {}

local walldata =
{
	{name = "limestone", material = MATERIALS.LIMESTONE, tags={"stone"}, loot = "coral", maxloots = 2, maxhealth=TUNING.LIMESTONEWALL_HEALTH, buildsound="dontstarve/common/place_structure_stone", destroysound="dontstarve/common/destroy_stone"},
	{name = "enforcedlimestone", material = MATERIALS.LIMESTONE, tags={"stone"}, loot = "coral", maxloots = 1, maxhealth=TUNING.ENFORCEDLIMESTONEWALL_HEALTH, buildsound="ia/creatures/seacreature_movement/water_emerge_lrg", destroysound="dontstarve/common/destroy_stone", waterwall = true},
}

for i, v in ipairs(walldata) do
    local wall, item, placer = MakeWallType(v)
    table.insert(wallprefabs, wall)
    table.insert(wallprefabs, item)
    table.insert(wallprefabs, placer)
end

return unpack(wallprefabs)
