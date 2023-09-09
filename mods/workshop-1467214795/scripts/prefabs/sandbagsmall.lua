require "prefabutil"

local assets =
{
  Asset("ANIM", "anim/sandbag_small.zip"),
  Asset("ANIM", "anim/sandbag.zip"),
}

local prefabs =
{
	-- "gridplacer",
	"collapse_small",
}


local function OnIsPathFindingDirty(inst)
    if inst._ispathfinding:value() then
        if inst._pfpos == nil then
            inst._pfpos = inst:GetPosition()
			TheWorld.Pathfinder:AddWall(inst._pfpos.x + 0.5, inst._pfpos.y, inst._pfpos.z + 0.5)
			TheWorld.Pathfinder:AddWall(inst._pfpos.x + 0.5, inst._pfpos.y, inst._pfpos.z - 0.5)
			TheWorld.Pathfinder:AddWall(inst._pfpos.x - 0.5, inst._pfpos.y, inst._pfpos.z + 0.5)
			TheWorld.Pathfinder:AddWall(inst._pfpos.x - 0.5, inst._pfpos.y, inst._pfpos.z - 0.5)
        end
    elseif inst._pfpos ~= nil then
		TheWorld.Pathfinder:RemoveWall(inst._pfpos.x + 0.5, inst._pfpos.y, inst._pfpos.z + 0.5)
		TheWorld.Pathfinder:RemoveWall(inst._pfpos.x + 0.5, inst._pfpos.y, inst._pfpos.z - 0.5)
		TheWorld.Pathfinder:RemoveWall(inst._pfpos.x - 0.5, inst._pfpos.y, inst._pfpos.z + 0.5)
		TheWorld.Pathfinder:RemoveWall(inst._pfpos.x - 0.5, inst._pfpos.y, inst._pfpos.z - 0.5)
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

local function makefloodobstacle(inst)
	TheWorld:PushEvent("floodblockercreated",{blocker = inst})
end

local function InitializeFloodObstacle(inst)
	if not inst.components.health:IsDead() then
        makefloodobstacle(inst)
    end
end

local function clearobstacle(inst)
    inst.Physics:SetActive(false)
    inst._ispathfinding:set(false)
    TheWorld:PushEvent("floodblockerremoved",{blocker = inst})
end

local anims =
{
	{ threshold = 0, anim = "rubble" },
	{ threshold = 0.4, anim = "heavy_damage" },
	{ threshold = 0.5, anim = "half" },
	{ threshold = 0.99, anim = "light_damage" },
	{ threshold = 1, anim = "full" },
}

local function resolveanimtoplay(inst, percent)
    for i, v in ipairs(anims) do
        if percent <= v.threshold then
            return v.anim
        end
    end
end

local function onhealthchange(inst, old_percent, new_percent)
    local anim_to_play = resolveanimtoplay(inst, new_percent)
	inst.AnimState:PlayAnimation(anim_to_play)
	if new_percent > 0 and old_percent <= 0 then makeobstacle(inst) makefloodobstacle(inst) end
	if old_percent > 0 and new_percent <= 0 then clearobstacle(inst) end
    -- if new_percent > 0 then
        -- if old_percent <= 0 then
            -- makeobstacle(inst)
            -- makefloodobstacle(inst)
        -- end
        -- inst.AnimState:PlayAnimation(anim_to_play.."_hit")
        -- inst.AnimState:PushAnimation(anim_to_play, false)
    -- else
        -- if old_percent > 0 then
            -- clearobstacle(inst)
        -- end
        -- inst.AnimState:PlayAnimation(anim_to_play)
    -- end
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
	if TheWorld.ismastersim and not inst.components.health:IsDead() then
		TheWorld:PushEvent("floodblockerremoved",{blocker = inst})
	end
end

local function ToFloodGrid(num)
	-- The flood grid is is the center of a 2x2 tile pattern. So 1,3,5,7..
	num = math.floor(num)

    if num % 2 == 0 then
        num = num + 1
    end

    return num
end

local function quantizepos(pt)
    local x, y, z = pt:Get()

    local _flood = TheWorld.components.flooding
    if _flood ~= nil then
        return Vector3(_flood:GetFloodCenterPoint(x,y,z))
    else
        -- Placement outside of Shipwrecked.
        return Vector3(ToFloodGrid(x), 0, ToFloodGrid(z))
    end
end

local function quantizeplacer(inst)
	inst.Transform:SetPosition(quantizepos(inst:GetPosition()):Get())
end

local function placerpostinitfn(inst)
    inst.components.placer.onupdatetransform = quantizeplacer
    inst.components.placer.snap_to_flood = true --GEOPLACEMENT SUPPORT
end

local function ondeploy(inst, pt, deployer)
	local wall = SpawnPrefab("sandbagsmall")

	if wall then
		pt = quantizepos(pt)

		wall.Physics:SetCollides(false)
		wall.Physics:Teleport(pt.x, pt.y, pt.z)
		wall.Physics:SetCollides(true)
		inst.components.stackable:Get():Remove()

		wall.SoundEmitter:PlaySound("ia/common/sandbag")
	end
end

local function IsNearOther(other, pt, min_spacing_sq)
    --FindEntities range check is <=, but we want <
    return other:GetDistanceSqToPoint(pt.x, 0, pt.z) < (other.deploy_extra_spacing ~= nil and math.max(other.deploy_extra_spacing * other.deploy_extra_spacing, min_spacing_sq) or min_spacing_sq)
end

local function IsNearOtherWallOrPlayer(other, pt, min_spacing_sq)
    if other:HasTag("wall") or other:HasTag("player") then
        local x, y, z = other.Transform:GetWorldPosition()
        return math.floor(x) == math.floor(pt.x) and math.floor(z) == math.floor(pt.z)
    end
    return IsNearOther(other, pt, min_spacing_sq)
end

local function spacing_test_sq(inst)
    return inst:HasTag("sandbag") and .01 or 1
end

local function test_wall(inst, pt, mouseover, deployer)
    local _world = TheWorld
    local _map = _world.Map
    local _flood = _world.components.flooding
    pt = quantizepos(pt)

    local x, y, z = pt:Get()

    local tile, visual_tile = _map:GetTileAtPoint(x, y, z), _map:GetVisualTileAtPoint(x, y, z, 0.5)
    local ispassable, isoverhang
    if _flood ~= nil then
        ispassable, isoverhang = _flood:IsFloodableTile(tile, true), IsOverhangBetweenTiles(tile, visual_tile)
    else
        ispassable, isoverhang = IsLandTile(tile), IsOverhangBetweenTiles(tile, visual_tile)
    end

    return ispassable and _map:IsDeployPointClear(pt, inst, 1, spacing_test_sq, IsNearOtherWallOrPlayer, isoverhang)
end


local function onhammered(inst, worker)
	local max_loots = 2
	local num_loots = math.max(1, math.floor(max_loots*inst.components.health:GetPercent()))
	for k = 1, num_loots do
		inst.components.lootdropper:SpawnLootPrefab("sand")
	end

	local fx = SpawnPrefab("collapse_small")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

	inst:Remove()
end

local function onhit(inst)
	inst.SoundEmitter:PlaySound("ia/common/sandbag")

	local healthpercent = inst.components.health:GetPercent()
	local anim_to_play = resolveanimtoplay(inst, healthpercent)
	inst.AnimState:PushAnimation(anim_to_play)
end

local function onrepaired(inst)
	inst.SoundEmitter:PlaySound("ia/common/sandbag")
	makeobstacle(inst)
    makefloodobstacle(inst)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.Transform:SetEightFaced()

	MakeObstaclePhysics(inst, 1)
	inst.Physics:SetDontRemoveOnSleep(true)

    inst:SetDeployExtraSpacing(2) --only works against builder, not against deployables

	inst:AddTag("floodblocker")
	inst:AddTag("sandbag")
	inst:AddTag("wall")
	inst:AddTag("noauradamage")
	inst:AddTag("nointerpolate")
    inst:AddTag("ignorewalkableplatforms")

	inst.AnimState:SetBank("sandbag_small")
	inst.AnimState:SetBuild("sandbag_small")
	inst.AnimState:PlayAnimation("full", false)

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

    inst:DoTaskInTime(0, InitializeFloodObstacle)

	inst:AddComponent("inspectable")
	inst:AddComponent("lootdropper")

	inst:AddComponent("repairable")
	inst.components.repairable.repairmaterial = MATERIALS.SANDBAGSMALL
	inst.components.repairable.onrepaired = onrepaired

	inst:AddComponent("combat")
	inst.components.combat:SetKeepTargetFunction(keeptargetfn)
	inst.components.combat.onhitfn = onhit

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.SANDBAG_HEALTH)
	inst.components.health.currenthealth = TUNING.SANDBAG_HEALTH
	inst.components.health.ondelta = onhealthchange
	inst.components.health.nofadeout = true
	inst.components.health.canheal = false
	--apparently not burnable -M
	inst.components.health.fire_damage_scale = 0

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(3)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	MakeHauntableWork(inst)

	inst.OnLoad = onload

	return inst
end

local function itemfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst:AddTag("wallbuilder")

	inst.AnimState:SetBank("sandbag")
	inst.AnimState:SetBuild("sandbag")
	inst.AnimState:PlayAnimation("idle")

	-- MakeInventoryFloatable(inst)
	-- inst.components.floater:UpdateAnimations("idle_water", "idle")
    inst._custom_candeploy_fn = test_wall

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
	return inst
	end

	inst:AddComponent("repairer")
	inst.components.repairer.repairmaterial = MATERIALS.SANDBAGSMALL
	inst.components.repairer.healthrepairvalue = TUNING.SANDBAG_HEALTH / 2

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetSinks(true)

	inst:AddComponent("deployable")
	inst.components.deployable.ondeploy = ondeploy
	inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM)
	inst.components.deployable.deploydistance = 2

	MakeHauntableLaunch(inst)

	return inst
end

return Prefab( "sandbagsmall", fn, assets, prefabs ),
Prefab( "sandbagsmall_item", itemfn, assets, prefabs ),
MakePlacer("sandbagsmall_item_placer",  "sandbag_small", "sandbag_small", "full", false, false, false, 1.0, nil, "eight", placerpostinitfn)
