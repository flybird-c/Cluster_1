local assets =
{
    Asset("ANIM", "anim/bubbles_sunk.zip"),
}

local function ontimerdone(inst, data)
    if data.name == "destroy" then
        inst:Remove()
    end
end

local function dobubblefx(inst)
    inst.AnimState:PlayAnimation("bubble_pre")
    inst.AnimState:PushAnimation("bubble_loop")
    inst.AnimState:PushAnimation("bubble_pst", false)
    inst:DoTaskInTime((math.random() * 15 + 15), dobubblefx)
end

local function init(inst, prefab)
    if not prefab then inst:Remove() end

    local pos = prefab:GetPosition()
    inst.Transform:SetPosition(pos:Get())
    if not prefab:HasTag("irreplaceable") then
        inst.components.timer:StartTimer("destroy", TUNING.SUNKENPREFAB_REMOVE_TIME)
    end
    inst.components.sunkenprefabinfo:SetPrefab(prefab)
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("bubbles_sunk")
    inst.AnimState:SetBuild("bubbles_sunk")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(-3)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst:AddTag("ignorewalkableplatforms")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("sunkenprefabinfo")

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)

    inst:DoTaskInTime((math.random() * 15 + 12), dobubblefx)

    inst.Initialize = init

    return inst
end

return Prefab("sunkenprefab", fn, assets)
