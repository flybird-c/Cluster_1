local assets_obsidian = {
    Asset("ANIM", "anim/rock_obsidian.zip"),
}

local assets_charcoal = {
    Asset("ANIM", "anim/rock_charcoal.zip"),
}

local prefabs_obsidian = {
    "obsidian"
}

local prefabs_charcoal = {
    "charcoal",
    "flint"
}

SetSharedLootTable("rock_obsidian", {
    {"obsidian", 1.0},
    {"obsidian", 1.0},
    {"obsidian", 0.5},
    {"obsidian", 0.25},
    {"obsidian", 0.25},
})

SetSharedLootTable("rock_charcoal", {
    {"charcoal", 1.0},
    {"charcoal", 1.0},
    {"charcoal", 0.5},
    {"charcoal", 0.25},
    {"charcoal", 0.25},
    {"flint", 0.5},
})

local function onwork(inst, worker, workleft)
    if workleft < TUNING.ROCKS_MINE*(1/3) then
        inst.AnimState:PlayAnimation("low")
    elseif workleft < TUNING.ROCKS_MINE*(2/3) then
        inst.AnimState:PlayAnimation("med")
    else
        inst.AnimState:PlayAnimation("full")
    end
end

local function ShouldRecoil(inst, worker, tool)
	if not (worker ~= nil and (worker:HasTag("toughworker") or worker:HasTag("explosive") or
        worker:HasTag("epic") or worker:HasTag("shadowrift_portal") or worker.prefab == "rift_terraformer" or worker.prefab == "tornado")) and
		not (tool ~= nil and tool.components.tool ~= nil and tool.components.tool:CanDoToughWork()) then
		return true
	end
	return false
end

local function onfinish_obsidian(inst, worker)
    local pt = Point(inst.Transform:GetWorldPosition())
    if worker:HasTag("explosive") then
        inst.SoundEmitter:PlaySound("ia/common/obsidian_explode")
        inst.components.lootdropper:ExplodeLoot(pt, 6 + (math.random() * 8))
    else
        inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
        inst.components.lootdropper:DropLoot(pt)
    end
    inst.components.growable:SetStage(1)
end

local function onfinish_charcoal(inst, worker)
    local pt = Point(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
    inst.components.lootdropper:DropLoot(pt)
    inst.components.growable:SetStage(1)
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
    inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
    inst.components.growable:StopGrowing()
    inst.Physics:SetCollides(true)
    inst:RemoveTag("NOCLICK")
    inst.MiniMapEntity:SetEnabled(true)
    inst:Show()
end

local function ongrowthfn(inst, last, current)
    inst.AnimState:PlayAnimation(inst.components.growable.stages[current].anim)
end

local grow_stages = {
    {name="empty", fn=SetEmpty},
    {name="full", fn=SetFull, anim="full"},
}

local function commonfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    return inst 
end

local function masterfn(inst)
    inst:AddComponent("lootdropper")
    inst:AddComponent("inspectable")

    MakeHauntableWork(inst)
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
    inst.components.workable:SetOnWorkCallback(onwork)

    inst:AddComponent("growable")
    inst.components.growable.stages = grow_stages
    inst.components.growable:SetStage(2)
    inst.components.growable:SetOnGrowthFn(ongrowthfn)
    inst.components.growable.loopstages = false
    inst.components.growable.growonly = false
    inst.components.growable.springgrowth = false
    inst.components.growable.growoffscreen = true

    return inst
end

local function obsidianfn()
    local inst = commonfn()

    inst.AnimState:SetBank("rock_obsidian")
    inst.AnimState:SetBuild("rock_obsidian")
    inst.AnimState:PlayAnimation("full")

    inst.MiniMapEntity:SetIcon("rock_obsidian.tex")

    inst:AddTag("obsidian")
    inst:AddTag("event_trigger")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst = masterfn(inst)

    inst.components.workable:SetShouldRecoilFn(ShouldRecoil)
    inst.components.workable:SetOnFinishCallback(onfinish_obsidian)
    inst.components.lootdropper:SetChanceLootTable("rock_obsidian")
    return inst
end

local function charcoalfn()
    local inst = commonfn()

    inst.AnimState:SetBank("rock_charcoal")
    inst.AnimState:SetBuild("rock_charcoal")
    inst.AnimState:PlayAnimation("full")

    inst:AddTag("charcoal")

    inst.MiniMapEntity:SetIcon("rock_charcoal.tex")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst = masterfn(inst)

    inst.components.workable:SetOnFinishCallback(onfinish_charcoal)
    inst.components.lootdropper:SetChanceLootTable("rock_charcoal")
    return inst
end

return Prefab("rock_obsidian", obsidianfn, assets_obsidian, prefabs_obsidian),
    Prefab("rock_charcoal", charcoalfn, assets_charcoal, prefabs_charcoal)
