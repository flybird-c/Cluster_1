local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("closed", false)
        if inst.components.container ~= nil then
            inst.components.container:DropEverything()
            inst.components.container:Close()
        end
    end
end


local function fn()
    local inst = Prefabs["pandoraschest"].fn()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.inspectable.nameoverride = "pandoraschest"

    inst:AddComponent("named")
    inst.components.named:SetName(STRINGS.NAMES.PANDORASCHEST)

    inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(2)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
    
	inst:AddComponent("lootdropper")

    return inst
end

return Prefab("pandoraschest_tropical", fn)
