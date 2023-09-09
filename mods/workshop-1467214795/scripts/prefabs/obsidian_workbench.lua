local assets = {
    Asset("ANIM", "anim/workbench_obsidian.zip"),
}

local MAXHITS = 10  -- make this an even number

local function turnlightoff(inst, light)
    if light then
        light:Enable(false)
    end
end

--light, rad, intensity, falloff, colour, time, callback
local function OnTurnOn(inst)
    inst.components.prototyper.on = true  -- prototyper doesn't set this until after this function is called!!
    inst.AnimState:PlayAnimation("proximity_pre")
    inst.AnimState:PushAnimation("proximity_loop", true)
    inst.SoundEmitter:PlaySound("ia/common/obsidian_workbench_LP", "loop")
end

local function OnTurnOff(inst)
    inst.components.prototyper.on = false  -- prototyper doesn't set this until after this function is called
    inst.AnimState:PlayAnimation("proximity_pst")
    inst.AnimState:PushAnimation("idle", true)
    inst.SoundEmitter:KillSound("loop")
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetPriority( 5 )
    inst.MiniMapEntity:SetIcon("obisidan_workbench.tex")
    inst.Transform:SetScale(1, 1, 1)

    MakeObstaclePhysics(inst, 2, 1.2)

    inst.AnimState:SetBank("workbench_obsidian")
    inst.AnimState:SetBuild("workbench_obsidian")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("prototyper")
    inst:AddTag("altar")
    inst:AddTag("structure")
    inst:AddTag("stone")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("prototyper")
    inst.components.prototyper.onturnon = OnTurnOn
    inst.components.prototyper.onturnoff = OnTurnOff
    inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.OBSIDIAN_BENCH

    inst.components.prototyper.onactivate = function()
        inst.AnimState:PlayAnimation("use")
        inst.AnimState:PushAnimation("proximity_loop", true)
    end

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    return inst
end

return Prefab("obsidian_workbench", fn, assets)
