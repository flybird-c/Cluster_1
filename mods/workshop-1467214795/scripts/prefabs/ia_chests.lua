local assets =
{
    Asset("ANIM", "anim/luggage.zip"),
    Asset("ANIM", "anim/octopus_chest.zip"),
    Asset("ANIM", "anim/kraken_chest.zip"),
    Asset("ANIM", "anim/water_chest.zip"),
}

local prefabs =
{
    "collapse_small",
}

local function onopen(inst) 
	inst.AnimState:PlayAnimation("open")
	inst.AnimState:PushAnimation("opened", true)

	if inst.prefab == "luggagechest" then
		inst.SoundEmitter:PlaySound("ia/common/steamer_trunk/open")
	else
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
	end
end

local function onclose(inst)
	inst.AnimState:PlayAnimation("close")
	inst.AnimState:PushAnimation("closed", true)
		
	if inst.prefab == "luggagechest" then
		inst.SoundEmitter:PlaySound("ia/common/steamer_trunk/close")
	else
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
	end
end

local function oncloseocto(inst)
	inst.AnimState:PlayAnimation("close")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")

	if not inst.components.container:IsEmpty() then
		inst.AnimState:PushAnimation("closed", true)
		return
	else
		
		inst.AnimState:PushAnimation("sink", false)
		inst.components.container.canbeopened = false
			
		inst:DoTaskInTime(96*FRAMES, function (inst)
			inst.SoundEmitter:PlaySound("ia/creatures/seacreature_movement/splash_small")
		end)

		inst:ListenForEvent("animqueueover", function (inst)
			inst:Remove()
		end)
	end
end 

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood") --TODO water chests are rock afaik -M
    inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation("closed", true)
	if inst.components.container ~= nil then 
		inst.components.container:DropEverything() 
		inst.components.container:Close()
	end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/chest_craft")
end

local joecounter = 1
local function onload(inst, data)
    if data ~= nil then
		-- from the worldgen data
		if data.joeluggage then
			joecounter = joecounter%4
			inst:AddComponent("scenariorunner")
			inst.components.scenariorunner:SetScript("chest_luggage"..tostring(joecounter + 1))
			inst.components.scenariorunner:Run()
			joecounter = joecounter + 1
		end
    end
end

local function MakeChest(anim, override_widget, minimap, indestructible, waterobstacle)
    return function()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        if minimap ~= false then
            inst.MiniMapEntity:SetIcon(anim .. ".tex")
        end

        inst:AddTag("structure")
        inst:AddTag("chest")

        inst.AnimState:SetBank(anim)
        inst.AnimState:SetBuild(anim)
        inst.AnimState:PlayAnimation("closed", true)

        MakeSnowCoveredPristine(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        inst:AddComponent("container")
        inst.components.container:WidgetSetup(override_widget or "treasurechest")
        inst.components.container.onopenfn = onopen
        inst.components.container.onclosefn = onclose

        if indestructible then
            inst:AddComponent("inventoryitem")
            inst.components.inventoryitem.canbepickedup = false
            inst.components.inventoryitem.cangoincontainer = false
            inst.components.inventoryitem.nobounce = true
            inst.components.inventoryitem:SetSinks(false)

            inst.components.container.onclosefn = oncloseocto
        else
            inst:AddComponent("lootdropper")
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
            inst.components.workable:SetWorkLeft(2)
            inst.components.workable:SetOnFinishCallback(onhammered)
            inst.components.workable:SetOnWorkCallback(onhit)
        end

        if waterobstacle then
            MakeWeakWaterObstaclePhysics(inst, 0, 0.8, 2, 0.75)
        else
            MakeInventoryPhysics(inst)
        end

        inst.no_wet_prefix = true

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        inst:ListenForEvent("onbuilt", onbuilt)
        MakeSnowCovered(inst)

        inst.OnLoad = onload

        return inst
    end
end

return Prefab("luggagechest", MakeChest("luggage", "luggagechest", nil, nil, true), assets, prefabs),
    Prefab("octopuschest", MakeChest("octopus_chest", "octopuschest", false, true), assets, prefabs),
    Prefab("krakenchest", MakeChest("kraken_chest", "krakenchest", nil, nil, true), assets, prefabs),
    Prefab("waterchest", MakeChest("water_chest", "waterchest", true, nil, true), assets, prefabs),
    MakePlacer("waterchest_placer", "water_chest", "water_chest", "closed")
