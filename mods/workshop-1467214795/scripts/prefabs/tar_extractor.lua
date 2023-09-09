require "prefabutil"

local assets=
{
	Asset("ANIM", "anim/tar_extractor.zip"),
	Asset("ANIM", "anim/tar_extractor_meter.zip"),
}

local prefabs=
{
	"tar",
    "collapse_small",
	"tar_extractor_underwater_fx",
}

local RESOURCE_TIME = TUNING.SEG_TIME*4
local POOP_ANIMATION_LENGTH = 70

local startTar

local FINDTAR_TAGS = {"tar"}
local function spawnTarProp(inst)
	inst.task_spawn = nil
    local pt = inst:GetPosition() + Vector3(0,4.5,0)
    local tar = TheSim:FindEntities(pt.x, 0, pt.z, 4, FINDTAR_TAGS)[1]
    if tar ~= nil and not tar.components.stackable:IsFull() then
        -- optimization
        tar.components.stackable:SetStackSize(tar.components.stackable:StackSize() + 1)
    else
        tar = SpawnPrefab("tar")

        tar.Transform:SetPosition(pt.x + 1, 0, pt.z + 1)
    
        tar.AnimState:PlayAnimation("drop")
        tar.AnimState:PushAnimation("idle_water",true)
    end

	if inst.components.machine:IsOn() and not inst.components.fueled:IsEmpty() then
		startTar(inst)
		inst.AnimState:PlayAnimation("active",true)
		inst.underwater.AnimState:PlayAnimation("active",true)
	else
		inst.AnimState:PlayAnimation("idle", true)
		inst.underwater.AnimState:PlayAnimation("idle", true)
	end
end

local function makeTar(inst)
	inst.SoundEmitter:PlaySound("ia/common/tar_extractor/poop")
	inst.AnimState:PlayAnimation("poop")
	inst.underwater.AnimState:PlayAnimation("poop")
	inst.task_spawn = inst:DoTaskInTime(POOP_ANIMATION_LENGTH * FRAMES, spawnTarProp)
	inst.task_tar = nil
	--inst:ListenForEvent("animover", spawnTarProp )
end

startTar = function(inst)
	inst.task_tar = inst:DoTaskInTime(RESOURCE_TIME, makeTar )
	inst.task_tar_time = GetTime()
end

local function placeAlign(inst)
	local range = 1
	local pt = inst:GetPosition()
	local tarpits = TheSim:FindEntities(pt.x, pt.y, pt.z, range, {"tarpit"})

	if #tarpits > 0 then
		for k, v in pairs(tarpits) do
			if not v:HasTag("NOCLICK") then
				inst.Transform:SetPosition(v.Transform:GetWorldPosition())
				return true
			end
		end
	end
	return false
end

local function placeTestFn(pt, rot)
	local range = .1
	local tarpits = TheSim:FindEntities(pt.x, pt.y, pt.z, range, {"tarpit"})

	if #tarpits > 0 then
		for k, v in pairs(tarpits) do
			if not v:HasTag("NOCLICK") then
				return true, false
			end
		end
	end
	return false, false
end

local function onBuilt(inst)
	inst.SoundEmitter:PlaySound("ia/common/tar_extractor/craft")
	inst.SoundEmitter:PlaySound("ia/creatures/seacreature_movement/splash_medium")
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle",true)
	inst.underwater.AnimState:PlayAnimation("place")
	inst.underwater.AnimState:PushAnimation("idle",true)

	local range = .1
	local pt = inst:GetPosition()
	local tarpits = TheSim:FindEntities(pt.x, pt.y, pt.z, range, {"tarpit"}, nil)
	for i,tarpit in ipairs(tarpits)do
		if tarpit:IsValid() and not tarpit:HasTag("NOCLICK") then
			inst.tarpit = tarpit
			tarpit:AddTag("NOCLICK")
			break
		end
	end

	if not inst.tarpit then
		--This should not happen, panic!
		inst.components.workable:Destroy(inst)
	end
end

local function onRemove(inst, worker)
	if inst.tarpit then
		inst.tarpit:RemoveTag("NOCLICK")
	end
end


local function onhit(inst, worker)
	if not inst:HasTag("burnt") and not inst.task_spawn then
		inst.AnimState:PlayAnimation("hit")
		inst.underwater.AnimState:PlayAnimation("hit")
		if inst.components.machine:IsOn() then
			inst.AnimState:PushAnimation("active",true)
			inst.underwater.AnimState:PushAnimation("active",true)
		else
			inst.AnimState:PushAnimation("idle", true)
			inst.underwater.AnimState:PushAnimation("idle", true)
		end
	end
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnAt("collapse_small", inst)
    fx:SetMaterial("metal")
	inst.SoundEmitter:KillSound("suck")
    inst:Remove()
end

local function TurnOff(inst)
	if inst.task_tar then
		inst.task_tar:Cancel()
		inst.task_tar = nil
		inst.task_tar_time = nil
	end
	inst.components.fueled:StopConsuming()
	inst.AnimState:PlayAnimation("idle", true)
	inst.underwater.AnimState:PlayAnimation("idle", true)
	inst.SoundEmitter:KillSound("suck")
end

local function TurnOn(inst)
	startTar(inst)
	inst.components.fueled:StartConsuming()
	inst.AnimState:PlayAnimation("active", true)
	inst.underwater.AnimState:PlayAnimation("active", true)
	inst.SoundEmitter:PlaySound("ia/common/tar_extractor/active_LP", "suck")
end

local function CanInteract(inst)
	return not inst.components.fueled:IsEmpty()
end

local function OnFuelSectionChange(new, old, inst)
    if inst._fuellevel ~= new then
        inst._fuellevel = new
		inst.AnimState:OverrideSymbol("swap_meter", "tar_extractor_meter", tostring(new))
    end
end

local function OnFuelEmpty(inst)
	inst.components.machine:TurnOff()
end

local function ontakefuelfn(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/machine_fuel")
	--Turn machine on?
	if CanInteract(inst) and not inst.components.machine.ison then
        inst.components.machine:TurnOn()
    end
end

local function getstatus(inst, viewer)
	if inst.components.machine.ison then
		if inst.components.fueled
		and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= .25 then
			return "LOWFUEL"
		else
			return "ON"
		end
	else
		return "OFF"
	end
end

local function OnSave(inst, data)
    if inst:HasTag("burnt")
	or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end

	if inst.task_spawn then
		data.task_spawn = true
    elseif inst.task_tar then
		data.task_tar_time = RESOURCE_TIME - (GetTime() - inst.task_tar_time)
    end

	if inst.tarpit then
		data.tarpit = inst.tarpit.GUID
		return {tarpit = inst.tarpit.GUID}
	end
end

local function OnLoad(inst, data)
	if data and data.burnt and inst.components.burnable and inst.components.burnable.onburnt then
        inst.components.burnable.onburnt(inst)
    end

    inst:DoTaskInTime(0, function()
	    if data.task_spawn then
			makeTar(inst)
		elseif data.task_tar_time then
	    	if inst.task_tar then
	    		inst.task_tar:Cancel()
	    		inst.task_tar = nil
	    	end
			inst.task_tar = inst:DoTaskInTime(data.task_tar_time, makeTar )
			inst.task_tar_time = GetTime()
	    end
	end)
end

local function OnLoadPostPass(inst, newents, data)
    if data and data.tarpit then
		local tarpit = newents[data.tarpit]
		if tarpit then
			inst.tarpit = tarpit.entity
			inst.tarpit:AddTag("NOCLICK")
			return
		end
    end
	--This should not happen, panic!
	inst.components.workable:Destroy(inst)
end

local function OnSpawn(inst)
    if inst and not inst.tarpit then
		local tar_pool = DebugSpawn("tar_pool")
		tar_pool.Transform:SetPosition(inst.Transform:GetWorldPosition())
		inst.tarpit = tar_pool
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeWaterObstaclePhysics(inst, .4, nil, 0.80)

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetPriority( 5 )
	minimap:SetIcon( "tar_extractor.tex" )

	inst.AnimState:SetBank("tar_extractor")
	inst.AnimState:SetBuild("tar_extractor")
	inst.AnimState:PlayAnimation("idle",true)

	inst.AnimState:OverrideSymbol("swap_meter", "tar_extractor_meter", 10)

    inst.AnimState:HideSymbol("underwater_shadow")

	inst:AddTag("structure")

	MakeSnowCoveredPristine(inst)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.underwater = SpawnPrefab("tar_extractor_underwater_fx")
	inst.underwater.entity:SetParent(inst.entity)
	inst.underwater.Transform:SetPosition(0,0,0)

	inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)  

	inst:AddComponent("lootdropper")

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)


	inst:AddComponent("machine")
	inst.components.machine.turnonfn = TurnOn
	inst.components.machine.turnofffn = TurnOff
	inst.components.machine.caninteractfn = CanInteract
	inst.components.machine.cooldowntime = 0.5

	inst:AddComponent("fueled")
	inst.components.fueled:SetDepletedFn(OnFuelEmpty)
    inst.components.fueled:SetTakeFuelFn(ontakefuelfn)
	inst.components.fueled.accepting = true
	inst.components.fueled:SetSections(10)
	inst.components.fueled:SetSectionCallback(OnFuelSectionChange)
	inst.components.fueled:InitializeFuelLevel(TUNING.TAR_EXTRACTOR_MAX_FUEL_TIME)
	inst.components.fueled.bonusmult = 5
	inst.components.fueled.secondaryfueltype = FUELTYPE.CHEMICAL

	--MakeLargeBurnable(inst, nil, nil, true)
	--MakeLargePropagator(inst)

	MakeSnowCovered(inst)

	inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass
	inst.OnRemoveEntity = onRemove
	inst:ListenForEvent( "onbuilt", onBuilt)
	inst:DoTaskInTime(0, OnSpawn)

	return inst
end

local function underwaterfxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

	inst.AnimState:SetBank("tar_extractor")
	inst.AnimState:SetBuild("tar_extractor")
	inst.AnimState:PlayAnimation("idle",true)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)

	inst.AnimState:HideSymbol("ball")
    inst.AnimState:HideSymbol("bamboo")
	inst.AnimState:HideSymbol("base")
    inst.AnimState:HideSymbol("body")
    inst.AnimState:HideSymbol("droplet")
    inst.AnimState:HideSymbol("pipe")
	inst.AnimState:HideSymbol("ripple2")
    inst.AnimState:HideSymbol("splash")
    inst.AnimState:HideSymbol("swap_meter")
    inst.AnimState:HideSymbol("top_bit")
    inst.AnimState:HideSymbol("wake")

	inst:AddTag("DECOR")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.persists = false

	return inst
end

local function placerfn(inst)
	inst.components.placer.onupdatetransform = placeAlign
	-- inst.components.placer.testfn = placeTestFn
end

return Prefab( "tar_extractor", fn, assets, prefabs ),
Prefab( "tar_extractor_underwater_fx", underwaterfxfn, assets, prefabs ),
MakePlacer( "tar_extractor_placer", "tar_extractor", "tar_extractor", "idle", nil, nil, nil, nil, nil, nil, placerfn)
