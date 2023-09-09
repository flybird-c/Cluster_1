local function SetPuddleLocation(inst, f_x, f_y)
	inst.Transform:SetPosition(TheWorld.components.flooding:GetFloodCenterPoint(f_x, f_y))
	inst.components.puddle:SetPuddleCoordinates(f_x, f_y)
end

local function fn()
    assert(TheWorld.ismastersim)

    local inst = CreateEntity()
    --[[Non-networked entity]]

    inst.persists = false

    inst.entity:AddTransform()

    inst:AddTag("CLASSIFIED")

    inst:AddComponent("puddle")

    inst.SetPuddleLocation = SetPuddleLocation

    inst.entity:SetPristine()

    return inst
end

return Prefab("monsoon_puddle", fn)