local assets = {
    Asset("ANIM", "anim/fish_farm_sign.zip"),   
}

local function DetermineSign(inst)
    if inst.parent then
        if inst.parent.components.breeder.seeded then
            if inst.parent.components.breeder.harvested then
                return FISH_FARM.SIGN[inst.parent.components.breeder.product]
            else
                return "buoy_sign_1"
            end
        else
            return nil
        end
    end
end

local function ResetArt(inst)    
    inst.AnimState:Hide("buoy_sign_1")    
    inst.AnimState:Hide("buoy_sign_2")
    inst.AnimState:Hide("buoy_sign_3")
    inst.AnimState:Hide("buoy_sign_4")
    inst.AnimState:Hide("buoy_sign_5") 

    local sign = DetermineSign(inst)
    if sign then
        inst.AnimState:Show(sign)   
    end
end

local function fn(Sim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    
    inst.AnimState:SetBank("fish_farm_sign")
    inst.AnimState:SetBuild("fish_farm_sign")
    inst.AnimState:PlayAnimation("idle", true)  
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.ResetArt = ResetArt

    inst.persists = false

    return inst

end    

return Prefab("fish_farm_sign", fn, assets)