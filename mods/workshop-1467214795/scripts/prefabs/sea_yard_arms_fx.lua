local assets = {
   Asset("ANIM", "anim/sea_yard_tools.zip")
}

local function delete(inst, user)
     inst:Remove() 
     if user then
        user.armsfx = nil
    end
end

local function stopfx(inst, user)
    inst.AnimState:PlayAnimation("out")
    inst:ListenForEvent("animover", function() 
        inst.SoundEmitter:KillSound("fix")   
        delete(inst, user) 
    end)   
end

local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetFinalOffset(10)

    inst.AnimState:SetBank("sea_yard_tools")
    inst.AnimState:SetBuild("sea_yard_tools")
    inst.AnimState:PlayAnimation("in")
    inst.AnimState:PushAnimation("loop", true)
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SoundEmitter:PlaySound("ia/creatures/seacreature_movement/splash_medium")
    inst.SoundEmitter:PlaySound("ia/common/shipyard/fix_LP", "fix")   

    inst.stopfx = stopfx

    return inst
end

return Prefab("sea_yard_arms_fx", fn, assets) 
