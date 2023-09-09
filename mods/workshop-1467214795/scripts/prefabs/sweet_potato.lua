local assets = {
    Asset("ANIM", "anim/sweet_potato.zip"),
}

local prefabs = {
    "sweet_potato",
}

local function onpicked(inst)
    TheWorld:PushEvent("beginregrowth", inst)
end
local function OnBurnt(inst)
	TheWorld:PushEvent("beginregrowth", inst)
    DefaultBurntFn(inst)
end

local function fn()
    -- Sweet Potato you eat is defined in ia_veggies.lua
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("sweet_potato")
    inst.AnimState:SetBuild("sweet_potato")
    inst.AnimState:PlayAnimation("planted")
    inst.AnimState:SetRayTestOnBB(true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
    inst.components.pickable:SetUp("sweet_potato", 10)
    inst.components.pickable.onpickedfn = onpicked
	inst.components.pickable.remove_when_picked = true

    inst.components.pickable.quickpick = true

    MakeSmallBurnable(inst)
    inst.components.burnable:SetOnBurntFn(OnBurnt)
    MakeSmallPropagator(inst)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    return inst
end

return Prefab("sweet_potato_planted", fn, assets)
