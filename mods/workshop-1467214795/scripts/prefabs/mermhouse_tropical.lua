local assets = {
    Asset("ANIM", "anim/merm_sw_house.zip"),
    Asset("MINIMAP_IMAGE", "mermhouse_tropical"),
}

local prefabs = {
    "mermhouse"
}

local function fn()
    local inst = Prefabs["mermhouse"].fn()

    inst.AnimState:SetBank("merm_sw_house")
    inst.AnimState:SetBuild("merm_sw_house")
    inst.MiniMapEntity:SetIcon("mermhouse_tropical.tex")
    
    inst.realprefab = "mermhouse_tropical"

    inst:SetPrefabName("mermhouse")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("named")
    inst.components.named:SetName(STRINGS.NAMES.MERMHOUSE_TROPICAL)

    return inst
end

return Prefab("mermhouse_tropical", fn, assets, prefabs)
