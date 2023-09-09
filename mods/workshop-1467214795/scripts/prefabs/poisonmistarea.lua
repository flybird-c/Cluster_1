local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("areaaware")

    inst:DoTaskInTime(0, function(inst)
        inst.components.areaaware:UpdatePosition()
        local node = inst.components.areaaware.current_area
        if node.area == nil then
            node.area = 1
        end 

        local mist = SpawnPrefab("poisonmist")
        local x, y, z = inst.Transform:GetWorldPosition()
        mist.Transform:SetPosition(x, 0, z)
        mist.components.emitter.area_emitter = CreateAreaEmitter(node.poly, node.cent)
        mist.components.emitter.density_factor = math.ceil(node.area / 4) / 31
        mist.components.emitter:Emit()
    end)

    return inst
end

return Prefab("poisonmistarea", fn) 
