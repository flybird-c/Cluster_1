local assets = {
    Asset("ANIM", "anim/spider_tropical_build.zip")
}

local prefabs = {
    "spider_warrior"
}

local function OnStartLeashing(inst, data)
    inst:SetHappyFace(true)
    inst.components.inventoryitem.canbepickedup = true

    leader.components.builder:UnlockRecipe("mutator_tropical_spider_warrior")

end

--making this a realprefab causes waaay too many problems
local function fn()
    local inst = Prefabs["spider_warrior"].fn()
    
    inst.AnimState:SetBuild("spider_tropical_build")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.inspectable.nameoverride = "spider_warrior"
    inst.components.combat.poisonous = true

    local loottables = {inst.components.lootdropper.randomloot, inst.components.lootdropper.randomhauntedloot}
    for tablenum, table in pairs(loottables) do
        for k,v in pairs(table) do
            if v.prefab == "spidergland" then
                if tablenum == 1 then
                    inst.components.lootdropper.randomloot[k].prefab = "venomgland"
                else
                    inst.components.lootdropper.randomhauntedloot[k].prefab = "venomgland"
                end
            end
        end
    end

    inst.recipe = "mutator_tropical_spider_warrior"

    return inst
end
return Prefab("tropical_spider_warrior", fn, assets, prefabs)
