local assets = {
	Asset("ANIM", "anim/volcano_shrub.zip"),
}

local prefabs = {
	"ash"
}

local function chopfn(inst)
	RemovePhysicsColliders(inst)
	inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
	inst.AnimState:PlayAnimation("break")

	local function animfinish(inst) inst.components.growable:SetStage(1) inst:RemoveEventCallback("animover", animfinish) end
	inst:ListenForEvent("animover", animfinish)

	inst.components.lootdropper:SpawnLootPrefab("ash")
	inst.components.lootdropper:DropLoot()
end

local function SetEmpty(inst)
    local st = TheWorld.state
	local days = st["autumnlength"] + st["winterlength"] + st["springlength"] + st["summerlength"]
	inst.components.growable:StartGrowing(days * TUNING.TOTAL_DAY_TIME)
	inst.Physics:SetCollides(false)
	inst:AddTag("NOCLICK")
	inst.MiniMapEntity:SetEnabled(false)
	inst:Hide()
end

local function SetFull(inst)
	inst.components.workable:SetWorkLeft(1)
	inst.components.growable:StopGrowing()
	inst.AnimState:PlayAnimation("idle", true)
	inst.Physics:SetCollides(true)
	inst:RemoveTag("NOCLICK")
	inst.MiniMapEntity:SetEnabled(true)
	inst:Show()
end

local grow_stages = {
	{name="empty", fn=SetEmpty},
	{name="full", fn=SetFull},
}

local function fn(Sim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	MakeObstaclePhysics(inst, .25)

	inst.AnimState:SetBank("volcano_shrub")
	inst.AnimState:SetBuild("volcano_shrub")
	inst.AnimState:PlayAnimation("idle", true)

	inst.MiniMapEntity:SetIcon("volcano_shrub.tex")
	inst:AddTag("burnt")
	inst:AddTag("tree")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.CHOP)
	inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(chopfn)

	inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
	inst.components.hauntable.onhaunt = chopfn
	
	inst:AddComponent("lootdropper")

	inst:AddComponent("growable")
	inst.components.growable.stages = grow_stages
	inst.components.growable:SetStage(2)
	inst.components.growable.loopstages = false
	inst.components.growable.growonly = false
	inst.components.growable.springgrowth = false
	inst.components.growable.growoffscreen = true

	return inst
end

return Prefab("volcano_shrub", fn, assets, prefabs)
