require "prefabutil"

local assets = {
	Asset("ANIM", "anim/icemachine.zip"),
}

local prefabs = {
	"collapse_small",
	"ice",
}

local MACHINESTATES = {
	ON = "_on",
	OFF = "_off",
}

local USE_ANIMATION_LENGTH = 85 --actually 90 but 85 fits the old animover time better

local function spawnice(inst)
	inst.task_spawn = nil

    local ice = SpawnPrefab("ice")
    local pt = inst:GetPosition() + Vector3(0, 2, 0)
    ice.Transform:SetPosition(pt:Get())

    local angle = math.random() * 2 * PI
    local sp = 3 + math.random()
    ice.Physics:SetVel(sp * math.cos(angle), math.random() * 2 + 8, sp * math.sin(angle))
	ice.components.inventoryitem:SetLanded(false, true)

    --Machine should only ever be on after spawning an ice
	inst.components.fueled:StartConsuming()
	inst.AnimState:PlayAnimation("idle"..inst.machinestate, true)
end

local function onhammered(inst, worked)
	inst.components.lootdropper:DropLoot()
	local fx = SpawnPrefab("collapse_small")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	fx:SetMaterial("metal")
	inst:Remove()
end

local function fueltaskfn(inst)
	inst.AnimState:PlayAnimation("use")
	inst.SoundEmitter:PlaySound("ia/common/icemachine_start")
	inst.components.fueled:StopConsuming() --temp pause fuel so we don't run out in the animation.
	inst.task_spawn = inst:DoTaskInTime(USE_ANIMATION_LENGTH * FRAMES, spawnice)
	-- inst:ListenForEvent("animover", spawnice)
end

local function OnAddFuel(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/machine_fuel")
	inst.components.fueled:StartConsuming()
end

local function OnUpdateFueled(inst, dt)
	--TODO: summer season rate adjustment?
	inst.components.fueled.rate = 1
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit"..inst.machinestate)
	inst.AnimState:PushAnimation("idle"..inst.machinestate, true)
	if inst.task_spawn ~= nil then
	 	inst.task_spawn:Cancel()
		inst.task_spawn = nil
	end
	if inst.machinestate == MACHINESTATES.ON then
		inst.components.fueled:StartConsuming() --resume fuel consumption incase you were interrupted from fueltaskfn
	end
end

local function OnFuelSectionChange(newsection, oldsection, inst, doer)
	if newsection == 0 and oldsection > 0 then
		inst.machinestate = MACHINESTATES.OFF
		inst.AnimState:PlayAnimation("turn"..inst.machinestate)
		inst.AnimState:PushAnimation("idle"..inst.machinestate, true)
		inst.SoundEmitter:KillSound("loop")
		if inst.fueltask ~= nil then
			inst.fueltask:Cancel()
			inst.fueltask = nil
		end
	elseif newsection > 0 and oldsection == 0 then
		inst.machinestate = MACHINESTATES.ON
		inst.AnimState:PlayAnimation("turn"..inst.machinestate)
		inst.AnimState:PushAnimation("idle"..inst.machinestate, true)
		if not inst.SoundEmitter:PlayingSound("loop") then
			inst.SoundEmitter:PlaySound("ia/common/icemachine_lp", "loop")
		end
		if inst.fueltask == nil then
			inst.fueltask = inst:DoPeriodicTask(TUNING.ICEMAKER_SPAWN_TIME, fueltaskfn)
		end
	end
end


local SECTION_STATUS = {
    [0] = "OUT",
    [1] = "VERYLOW",
    [2] = "LOW",
    [3] = "NORMAL",
    [4] = "HIGH",
}

local function getstatus(inst)
    return SECTION_STATUS[inst.components.fueled:GetCurrentSection()]
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle"..inst.machinestate)
	inst.SoundEmitter:PlaySound("ia/common/icemaker_place")
end

local function onStartFlooded(inst)
	if inst.components.fueled then 
		inst.components.fueled.accepting = false
	end 
end 

local function onStopFlooded(inst)
	if inst.components.fueled then 
		inst.components.fueled.accepting = true
	end 
end 

local function OnSave(inst, data)
	if inst.task_spawn ~= nil then
		data.task_spawn = true
    end
end

local function OnLoad(inst, data)
	if data ~= nil then
		inst:DoTaskInTime(0, function()
			if data.task_spawn then
				fueltaskfn(inst)
			end
		end)
	end
end

local function fn(Sim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	inst.MiniMapEntity:SetIcon("icemachine.tex")

	inst.AnimState:SetBank("icemachine")
	inst.AnimState:SetBuild("icemachine")
	inst.AnimState:PushAnimation("idle"..MACHINESTATES.ON)

	MakeObstaclePhysics(inst, .4)

    inst:AddTag("structure")

	inst:AddComponent("floodable")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("lootdropper")

	inst:AddComponent("fueled")
	inst.components.fueled:SetTakeFuelFn(OnAddFuel)
	inst.components.fueled.accepting = true
	inst.components.fueled:SetSections(4)
	inst.components.fueled:SetSectionCallback(OnFuelSectionChange)
	inst.components.fueled:SetUpdateFn(OnUpdateFueled)
	inst.components.fueled.maxfuel = TUNING.ICEMAKER_FUEL_MAX
	inst.components.fueled:InitializeFuelLevel(TUNING.ICEMAKER_FUEL_MAX/2)
	inst.components.fueled:StartConsuming()

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
	
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	inst.components.floodable:SetFX("shock_machines_fx",5)
	inst.components.floodable.onStartFlooded = onStartFlooded
	inst.components.floodable.onStopFlooded = onStopFlooded

	inst.machinestate = MACHINESTATES.ON
	inst:ListenForEvent("onbuilt", onbuilt)

	inst.OnSave = OnSave
    inst.OnLoad = OnLoad

	return inst
end

return Prefab("icemaker", fn, assets, prefabs),
		MakePlacer("icemaker_placer", "icemachine", "icemachine", "idle_off")
