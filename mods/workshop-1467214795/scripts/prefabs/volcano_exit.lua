local assets = {
    Asset("ANIM", "anim/volcano_entrance.zip"),
}

local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 1)

    inst.MiniMapEntity:SetIcon("volcano_entrance.tex")

    inst.AnimState:SetBank("volcano_entrance")
    inst.AnimState:SetBuild("volcano_entrance")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(-1)

    inst.Light:Enable(true)
    inst.Light:SetIntensity(0.75)
    inst.Light:SetColour(197/255, 197/255, 50/255)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetRadius(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddTag("moistureimmunity")
    
    inst:AddComponent("worldmigrator")
	inst.components.worldmigrator.id = 999
	inst.components.worldmigrator.receivedPortal = 999

    local old_SetDestinationWorld = inst.components.worldmigrator.SetDestinationWorld
    inst.components.worldmigrator.SetDestinationWorld = function(self, world, permanent)
        world = IA_CONFIG.shipwreckedid or world  --Guaranteed in multilayer world to teleport players to IA world  -Jerry
        old_SetDestinationWorld(self, world, permanent)
    end

    return inst
end

return Prefab("volcano_exit", fn, assets) 
