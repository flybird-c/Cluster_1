local assets = {
  Asset("ANIM", "anim/dubloon.zip"),
}

local function basic()
    local inst = CreateEntity()
    inst.entity:AddTransform()

    inst:AddTag("NOBLOCK")

    function inst:OnLoad(data)
        inst.data = data
    end

    function inst:OnSave(data)
        if inst.data then
            for k, v in pairs(inst.data) do
        	   data[k] = v
            end
        end
    end

    return inst
end


return
Prefab("butterfly_areaspawner", basic)
