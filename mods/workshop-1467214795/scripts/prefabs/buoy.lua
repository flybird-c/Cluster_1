require "prefabutil"

local assets = {
    Asset("ANIM", "anim/buoy.zip"),
}

local prefabs = {
    "collapse_small",
}

local function onhammered(inst, worker)
    if inst:HasTag("fire") and inst.components.burnable then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.sg:GoToState("hit")
end

local function onbuilt(inst)
    inst.sg:GoToState("place")
end

local function fn(Sim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeWaterObstaclePhysics(inst, .2, nil, 0.65)  
    
    inst.MiniMapEntity:SetIcon("buoy.tex")
    
    inst.AnimState:SetBank("buoy")
    inst.AnimState:SetBuild("buoy")
    inst.AnimState:PlayAnimation("idle", true)

    inst.Light:Enable(true)
    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(223/255,246/255,255/255)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetRadius(2)

    inst:AddTag("structure")
    
    inst.entity:SetPristine()
  
    if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)  

    inst:AddComponent("lootdropper") 
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    MakeSnowCovered(inst, .01)  

    inst:ListenForEvent("onbuilt", onbuilt)

    inst:SetStateGraph("SGbuoy")

    return inst
end

return Prefab("buoy", fn, assets, prefabs),
    MakePlacer("buoy_placer", "buoy", "buoy", "idle") 
