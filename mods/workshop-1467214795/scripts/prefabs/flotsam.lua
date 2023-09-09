local assets =
{
    Asset("ANIM", "anim/flotsam_debris_armoured_build.zip"),
    Asset("ANIM", "anim/flotsam_debris_bamboo_build.zip"),
    Asset("ANIM", "anim/flotsam_debris_cargo_build.zip"),
    Asset("ANIM", "anim/flotsam_debris_lograft_build.zip"),
    Asset("ANIM", "anim/flotsam_debris_rowboat_build.zip"),
    Asset("ANIM", "anim/flotsam_debris_surfboard_build.zip"),
    Asset("ANIM", "anim/flotsam_debris_sw.zip"),
    Asset("ANIM", "anim/flotsam_knightboat_build.zip"),

}

local anim_appends =
{
    "",
    "2",
    "3",
    "4",
    "5",
}

local function sink(inst)
    inst.SoundEmitter:PlaySound("ia/common/boat/debris_submerge")
    inst.AnimState:PushAnimation("sink"..inst.anim_append, false)
    inst:ListenForEvent("animover", inst.Remove)
end

local function fn(build)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)

    --just like Boat fragments, flotsam are always wet!
    inst:AddTag("wet")

    inst.SoundEmitter:PlaySound("ia/common/boat/debris_breakoff")

    inst.AnimState:SetBank("flotsam_debris_sw")
    inst.AnimState:SetBuild("flotsam_debris_"..build.."_build")
    inst.anim_append = anim_appends[math.random(#anim_appends)]
    inst.AnimState:PlayAnimation("idle"..inst.anim_append, true)

    inst:DoTaskInTime(3 + math.random() * 4, sink)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.persists = false

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.WOOD
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 0

    return inst
end

return Prefab("flotsam_armoured", function() return fn("armoured") end, assets, prefabs),
Prefab("flotsam_bamboo", function() return fn("bamboo") end, assets, prefabs),
Prefab("flotsam_cargo", function() return fn("cargo") end, assets, prefabs),
Prefab("flotsam_lograft", function() return fn("lograft") end, assets, prefabs),
Prefab("flotsam_rowboat", function() return fn("rowboat") end, assets, prefabs),
Prefab("flotsam_surfboard", function() return fn("surfboard") end, assets, prefabs)
