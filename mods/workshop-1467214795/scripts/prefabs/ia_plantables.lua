require "prefabutil"

local function make_plantable(data)
    local assets = {
        Asset("ANIM", "anim/"..(data.build or data.name)..".zip"),
    }

    local function ondeploy(inst, pt, deployer)
        local tree = SpawnPrefab(data.name)
        if tree ~= nil then
            tree.Transform:SetPosition(pt:Get())
            inst.components.stackable:Get():Remove()
            if tree.components.pickable then 
                tree.components.pickable:OnTransplant()
            elseif tree.components.hackable then 
                tree.components.hackable:OnTransplant()
            end 
            if deployer ~= nil and deployer.SoundEmitter ~= nil then
                deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
            end
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)
        
        inst:AddTag("deployedplant")

        if data.volcanic then inst:AddTag("volcanicplant") end
        if data.noburn then inst:AddTag("fire_proof") end

        inst.AnimState:SetBank(data.bank or data.name)
        inst.AnimState:SetBuild(data.build or data.name)
        inst.AnimState:PlayAnimation("dropped")

        MakeInventoryFloatable(inst)
        inst.components.floater:UpdateAnimations("dropped_water", "dropped")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

        inst:AddComponent("inspectable")
        inst.components.inspectable.nameoverride = data.inspectoverride or "dug_"..data.name
        inst:AddComponent("inventoryitem")

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

        inst:AddComponent("appeasement")
        inst.components.appeasement.appeasementvalue = TUNING.WRATH_SMALL

        if data.noburn then
            MakeHauntableLaunch(inst)
        else
            MakeMediumBurnable(inst, TUNING.LARGE_BURNTIME)
            MakeSmallPropagator(inst)

            MakeHauntableLaunchAndIgnite(inst)
        end

        inst:AddComponent("deployable")
        inst.components.deployable.ondeploy = ondeploy
        inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
        if data.spacing then
            inst.components.deployable:SetDeploySpacing(data.spacing)
        end
        if data.deploydistance then
            inst.components.deployable.deploydistance = data.deploydistance
        end

        ---------------------
        return inst
    end

    return Prefab("dug_"..data.name, fn, assets)
end

-- Note: using separate function just to avoid naming inconsistencies caused by Klei's naming inconsistencies -M
local function make_waterplantable(data)
    local assets = {
        Asset("ANIM", "anim/"..(data.build or data.name)..".zip"),
        Asset("ANIM", "anim/"..data.pbuild..".zip"),
    }

    local function ondeploy(inst, pt, deployer)
        local tree = SpawnAt(data.tree, pt)
        if tree ~= nil then
            if inst.components.stackable then
                inst.components.stackable:Get():Remove()
            else
                inst:Remove()
            end
            if tree.components.pickable then 
                tree.components.pickable:OnTransplant()
            elseif tree.components.growable and data.stage then 
                tree.components.growable:SetStage(data.stage)
            end 
            if deployer ~= nil and deployer.SoundEmitter ~= nil and data.sound then
                deployer.SoundEmitter:PlaySound(data.sound)
            end
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        --inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        if data.isplant then
            inst:AddTag("deployedplant")
        end

        inst.AnimState:SetBank(data.build or data.name)
        inst.AnimState:SetBuild(data.build or data.name)
        inst.AnimState:PlayAnimation("idle")

        MakeInventoryFloatable(inst)
        inst.components.floater:UpdateAnimations("idle_water", "idle")

        if data.canonbuildable then
            inst._tile_candeploy_fn = IsBuildableOceanTile
        else
            inst._tile_candeploy_fn = IsShallowOceanTile
        end
        
        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        -- inst.components.inspectable.nameoverride = data.inspectoverride or "dug_"..data.name
        inst:AddComponent("inventoryitem")

        inst:AddComponent("stackable")

        if data.smallstack then
            inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
        else
            inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM --For some reason, they're small -M
        end

        if data.perishable then
            inst:AddComponent("perishable")
            inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)
            inst.components.perishable:StartPerishing()
            inst.components.perishable.onperishreplacement = "spoiled_food"
            inst:AddTag("show_spoilage")
        end

        -- No idea why they are tradable -M
        -- inst:AddComponent("tradable")

        MakeHauntableLaunch(inst)

        inst:AddComponent("deployable")
        inst.components.deployable.ondeploy = ondeploy
        inst.components.deployable:SetDeployMode(DEPLOYMODE.WATER)
        if data.spacing then
            inst.components.deployable:SetDeploySpacing(data.spacing)
        end
        
        if data.deploydistance then
            inst.components.deployable.deploydistance = data.deploydistance
        end


        ---------------------
        return inst
    end
	
    return Prefab(data.name, fn, assets)
end

local plantables = {
    {
        name = "bambootree",
        build = "bambootree_build",
    },
    {
        name = "bush_vine",
    },
    {
        name = "coffeebush",
        anim = "idle_dead",
        noburn = true,
        volcanic = true,
    },
    {
        name = "elephantcactus",
        bank = "cactus_volcano",
        build = "cactus_volcano",
        anim = "idle_dead",
        noburn = true,
        volcanic = true,
        deploydistance = 2.1,
    },
}

--separate function because there's just too many inconsistencies
local waterplantables =
{
  {
    name = "seaweed_stalk",
    build = "seaweed_seed",
    pbuild = "seaweed_seed",
	panim = "placer",
	tree = "seaweed_planted",
	isplant = true,
  },
  {
    name = "mussel_bed",
    build = "musselfarm_seed",
    pbuild = "musselfarm",
	panim = "idle_underwater",
	tree = "mussel_farm",
	smallstack = true,
	stage = 2,
	sound = "ia/common/musselbed_plant",
  },
  {
    name = "nubbin",
    build = "nubbin",
    pbuild = "coral_rock",
	panim = "low1",
	tree = "rock_coral",
	stage = 1,
	sound = "ia/creatures/seacreature_movement/splash_medium",
	perishable = true,
	canonbuildable = true,
	spacing = DEPLOYSPACING.LARGE,
    deploydistance = 4,
  },
}

local prefabs = {}
for i, v in ipairs(plantables) do
    table.insert(prefabs, make_plantable(v))
    table.insert(prefabs, MakePlacer("dug_"..v.name.."_placer", v.bank or v.name, v.build or v.name, v.anim or "idle"))
end
for i, v in ipairs(waterplantables) do
    table.insert(prefabs, make_waterplantable(v))
    table.insert(prefabs, MakePlacer(v.name.."_placer", v.pbuild or v.build, v.pbuild or v.build, v.panim))
end

return unpack(prefabs)
