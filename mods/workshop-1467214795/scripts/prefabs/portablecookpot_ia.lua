require "prefabutil"

local cooking = require("cooking")

local assets =
{
	Asset("ANIM", "anim/cook_pot_warly.zip"),
	Asset("ANIM", "anim/cook_pot_food.zip"),
    Asset("ANIM", "anim/ui_cookpot_1x4.zip"),
}

local prefabs = 
{
	-- "collapse_small",
}
for k, v in pairs(cooking.recipes.cookpot) do
	table.insert(prefabs, v.name)
end

-- local function onhammered(inst, worker)
    -- if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        -- inst.components.burnable:Extinguish()
    -- end
    -- if not inst:HasTag("burnt") and inst.components.stewer.product ~= nil and inst.components.stewer:IsDone() then
        -- inst.components.lootdropper:AddChanceLoot(inst.components.stewer.product, 1)
    -- end
    -- if inst.components.container ~= nil then
        -- inst.components.container:DropEverything()
    -- end
	-- inst.components.lootdropper:AddChanceLoot("portablecookpot_item", 1)
    -- inst.components.lootdropper:DropLoot()
    -- SpawnAt("collapse_small", inst):SetMaterial("metal")
    -- inst:Remove()
-- end

-- local function onhit(inst, worker)
    -- if not inst:HasTag("burnt") then
        -- if inst.components.stewer:IsCooking() then
            -- inst.AnimState:PlayAnimation("hit_empty")
            -- inst.AnimState:PushAnimation("cooking_loop", true)
        -- elseif inst.components.stewer:IsDone() then
            -- inst.AnimState:PlayAnimation("hit_empty")
            -- inst.AnimState:PushAnimation("idle_full", false)
        -- else
            -- inst.AnimState:PlayAnimation("hit_empty")
            -- inst.AnimState:PushAnimation("idle_empty", false)
        -- end
    -- end
-- end

local function refreshpickupable(inst)
	if (not inst.components.container or inst.components.container:IsEmpty())
	and (not inst.components.stewer or not (inst.components.stewer:IsCooking()
	or inst.components.stewer.product))
	and not inst:HasTag("burnt") then
		if not inst.components.pickupable.canbepickedup then
			inst.components.pickupable.canbepickedup = true
		end
	elseif inst.components.pickupable.canbepickedup then
		inst.components.pickupable.canbepickedup = false
	end
end

--anim and sound callbacks

local function ShowProduct(inst)
    if not inst:HasTag("burnt") then
        local product = inst.components.stewer.product
        if IsModCookingProduct(inst.prefab, product) then
            inst.AnimState:OverrideSymbol("swap_cooked", product, product)
        else
            inst.AnimState:OverrideSymbol("swap_cooked", "cook_pot_food", product)
        end
    end
end

local function startcookfn(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("cooking_loop", true)
        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
        inst.Light:Enable(true)
    end
end

local function onopen(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("cooking_pre_loop", true)
        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_open")
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot", "snd")
    end
end

local function onclose(inst)
    if not inst:HasTag("burnt") then 
        if not inst.components.stewer:IsCooking() then
            inst.AnimState:PlayAnimation("idle_empty")
            inst.SoundEmitter:KillSound("snd")
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close")
    end
end

local function spoilfn(inst)
    if not inst:HasTag("burnt") then
        inst.components.stewer.product = inst.components.stewer.spoiledproduct
        ShowProduct(inst)
    end
end


local function donecookfn(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("cooking_pst")
        inst.AnimState:PushAnimation("idle_full", false)
        ShowProduct(inst)
        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_finish")
        inst.Light:Enable(false)
    end
end

local function continuedonefn(inst)
    if not inst:HasTag("burnt") then 
        inst.AnimState:PlayAnimation("idle_full")
        ShowProduct(inst)
    end
end

local function continuecookfn(inst)
    if not inst:HasTag("burnt") then 
        inst.AnimState:PlayAnimation("cooking_loop", true)
        inst.Light:Enable(true)
        inst.SoundEmitter:KillSound("snd")
        inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "snd")
    end
end

local function harvestfn(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("idle_empty")
		-- refreshpickupable(inst) --still has product at that point
		inst.components.pickupable.canbepickedup = true
    end
end

local function getstatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst.components.stewer:IsDone() and "DONE")
        or (not inst.components.stewer:IsCooking() and "EMPTY")
        or (inst.components.stewer:GetTimeToCook() > 15 and "COOKING_LONG")
        or "COOKING_SHORT"
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle_empty", false)
    -- inst.SoundEmitter:PlaySound("dontstarve/common/cook_pot_craft")
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
        inst.Light:Enable(false)
    end
	refreshpickupable(inst)
end

local function onFloodedStart(inst)
	if inst.components.container then 
		inst.components.container.canbeopened = false 
	end
	if inst.components.stewer then 
		if inst.components.stewer.cooking then 
			inst.components.stewer.product = "wetgoop"
		end
	end
end

local function onFloodedEnd(inst)
	if inst.components.container then 
		inst.components.container.canbeopened = true 
	end
end

local function pickupfn(inst, guy)
	if guy.components and guy.components.inventory then
		guy.components.inventory:GiveItem(SpawnPrefab("portablecookpot_item"))
		if inst.components.container then
			inst.components.container:Close() --This isn't really necessary, but it fixes Craft Pot and such. -M
		end
		inst:Remove()
		return true
	end
end

local function ondeploy(inst, pt, deployer)
	local pot = SpawnPrefab("portablecookpot") 
	if pot then 
		pot.Physics:SetCollides(false)
		pot.Physics:Teleport(pt.x, 0, pt.z) 
		pot.Physics:SetCollides(true)
		pot.SoundEmitter:PlaySound("dontstarve/common/place_structure_stone")
		pot.AnimState:PlayAnimation("place")
		pot.AnimState:PushAnimation("idle_empty", false)
		inst:Remove()
	end        
end

-- local function item_droppedfn(inst)
	-- --If this is a valid place to be deployed, auto deploy yourself.
	-- if inst.components.deployable and inst.components.deployable:CanDeploy(inst:GetPosition()) then
		-- inst.components.deployable:Deploy(inst:GetPosition(), inst)
	-- end
-- end

local function itemfn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("cook_pot_warly")
	inst.AnimState:SetBuild("cook_pot_warly")
	inst.AnimState:PlayAnimation("idle_drop")

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle_drop")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end


	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	-- inst.components.inventoryitem:SetOnDroppedFn(item_droppedfn)

	inst:AddComponent("deployable")
	inst.components.deployable.ondeploy = ondeploy
	-- inst.components.deployable:SetDeployMode(DEPLOYMODE.DEFAULT)

	-- inst:AddComponent("characterspecific")
    -- inst.components.characterspecific:SetOwner("warly")
	
	return inst
end

local function fn(Sim)
	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .5)

    inst.MiniMapEntity:SetIcon( "portablecookpot.tex" )

	inst.Light:Enable(false)
	inst.Light:SetRadius(.6)
	inst.Light:SetFalloff(1)
	inst.Light:SetIntensity(.5)
	inst.Light:SetColour(235/255,62/255,12/255)

	inst:AddTag("structure")
	MakeObstaclePhysics(inst, .5)

	inst.AnimState:SetBank("cook_pot_warly")
	inst.AnimState:SetBuild("cook_pot_warly")
	inst.AnimState:PlayAnimation("idle_empty")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("stewer")
	inst.components.stewer.onstartcooking = startcookfn
	inst.components.stewer.oncontinuecooking = continuecookfn
	inst.components.stewer.oncontinuedone = continuedonefn
	inst.components.stewer.ondonecooking = donecookfn
	inst.components.stewer.onharvest = harvestfn
	inst.components.stewer.onspoil = spoilfn

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("portablecookpot")
	inst.components.container.onopenfn = onopen
	inst.components.container.onclosefn = onclose

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus

	--TODO floodable
	-- inst:AddComponent("floodable")
	-- inst.components.floodable.onStartFlooded = onFloodedStart
	-- inst.components.floodable.onStopFlooded = onFloodedEnd
	-- inst.components.floodable.floodEffect = "shock_machines_fx"
	-- inst.components.floodable.floodSound = "ia/creatures/jellyfish/electric_land"

	inst:AddComponent("pickupable")
	inst.components.pickupable:SetOnPickupFn(pickupfn)
	-- inst.components.pickupable.canpickupfn = canpickup

	-- inst:AddComponent("characterspecific")
    -- inst.components.characterspecific:SetOwner("warly")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

	MakeSnowCovered(inst)
	inst:ListenForEvent( "onbuilt", onbuilt)
	inst:ListenForEvent( "itemget", refreshpickupable)
	inst:ListenForEvent( "itemlose", refreshpickupable)

    -- MakeMediumBurnable(inst, nil, nil, true)
    -- MakeSmallPropagator(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

	return inst
end

return Prefab( "portablecookpot", fn, assets, prefabs),
	MakePlacer( "portablecookpot_item_placer", "cook_pot_warly", "cook_pot_warly", "idle_empty" ),
	Prefab( "portablecookpot_item", itemfn, assets, prefabs)
