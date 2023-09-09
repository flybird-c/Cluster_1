local prefabs = {
    "guano"
}

local function fn()
    local inst = Prefabs["guano"].fn()
    
    inst.realprefab = "guano_wilbur"

    inst:SetPrefabName("guano")

    if not TheWorld.ismastersim then
        return inst
    end

    if inst.components.hauntable ~= nil then
        inst:RemoveComponent("hauntable")
    end
    inst.AnimState:SetHaunted(true)

    inst:AddTag("haunted")

    return inst
end

return Prefab("guano_wilbur", fn, nil, prefabs)
