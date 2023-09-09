local assets=
{
    Asset("ANIM", "anim/octopus.zip"),
    -- Asset("MINIMAP_IMAGE", "octopus"),
}


local prefabs =
{
    "dubloon",
    "octopuschest",
    "seaweed",
    "seashell",
    "coral",
    "shark_fin",
    "blubber",
    "sail_palmleaf",
    "sail_cloth",
    "sail_snakeskin",
    "sail_feather",
    "boatrepairkit",
    "trawlnet",
    "seatrap",
    "telescope",
    "supertelescope",
    "boat_lantern",
    "piratehat",
    "captainhat",
    "boatcannon",
}

for i = 1, NUM_HALLOWEENCANDY do
    table.insert(prefabs, "halloweencandy_"..i)
end

-- only accept 1 trinket per day and pull up a chest that has multiple  dubloons + items (that we set per trinket)
-- only accept 1 seafood meal per day and pull up a chest with 1 dubloon + rando cheap items that come from a loot list
-- only accept 1 seafood crockpot meal per day and pull up a chest that has 1 dubloon + items (that we set per dish)

local function StartTrading(inst)
    if not inst.components.trader.enabled then
        inst.components.trader:Enable()

        if inst.sleepfn then
            inst.AnimState:PlayAnimation("sleep_pst")
            inst:RemoveEventCallback("animover", inst.sleepfn)
            inst.sleepfn = nil
        end

        inst.AnimState:PushAnimation("idle", true)
    end
	
	inst.sleeping = false
end

local function FinishedTrading(inst)
    inst.components.trader:Disable()
    inst.AnimState:PlayAnimation("sleep_pre")

    if inst.sleepfn then
        inst:RemoveEventCallback("animover", inst.sleepfn)
        inst.sleepfn = nil
    end

    inst.sleepfn = function(inst)
        inst.AnimState:PlayAnimation("sleep_loop")
        inst.SoundEmitter:PlaySound("ia/creatures/octopus_king/sleep")
    end

    inst:ListenForEvent("animover", inst.sleepfn)
	
	inst.sleeping = true
end

-- chest style
local function OnGetItemFromPlayer(inst, giver, item)

    local istrinket = item:HasTag("trinket") or item:HasTag("beachtoy") or string.sub(item.prefab, 1, 7) == "trinket" -- cache this, the item is destroyed by the time the reward is created.
    local itemprefab = string.sub(item.prefab, -8) == "_gourmet" and string.sub(item.prefab, 1, -9) or item.prefab
    local itemprefab_loot = OCTOPUSKING_LOOT.chestloot[itemprefab]
    if type (itemprefab_loot) == "table" then
        itemprefab_loot = itemprefab_loot[math.random(1, #itemprefab_loot)]
    end

    local tradefor = item.components.tradable.tradefor
    inst.components.trader:Disable()

    inst.AnimState:PlayAnimation("happy")
    inst.AnimState:PushAnimation("grabchest")
    inst.AnimState:PushAnimation("idle", true)
    inst:DoTaskInTime(13*FRAMES, function(inst)	inst.SoundEmitter:PlaySound("ia/creatures/octopus_king/happy") end)
    inst:DoTaskInTime(53*FRAMES, function(inst)	inst.SoundEmitter:PlaySound("ia/creatures/octopus_king/tenticle_out_water") end)
    inst:DoTaskInTime(71*FRAMES, function(inst)	inst.SoundEmitter:PlaySound("ia/creatures/octopus_king/tenticle_in_water") end)
    inst:DoTaskInTime(78*FRAMES, function(inst)	inst.SoundEmitter:PlaySound("ia/creatures/seacreature_movement/splash_small") end)
    inst:DoTaskInTime(109*FRAMES, function(inst)

        inst.SoundEmitter:PlaySound("ia/creatures/octopus_king/tenticle_out_water")

        -- put things in a chest and throw that
        local angle
        local spawnangle
        local x, y, z = inst.Transform:GetWorldPosition()

        if giver ~= nil and giver:IsValid() then
            angle = (210 - math.random()*60 - giver:GetAngleToPoint(x, 0, z))*DEGREES
            spawnangle = (130 - giver:GetAngleToPoint(x, 0, z))*DEGREES
        else
            local down = TheCamera:GetDownVec()
            angle = math.atan2(down.z, down.x) + (math.random()*60-30)*DEGREES
            spawnangle = math.atan2(down.z, down.x) + -50*DEGREES
            giver = nil
        end

        local candy_chest
        local chest = SpawnPrefab("octopuschest")
        local chests = {chest}
        if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
            candy_chest = SpawnPrefab("octopuschest")
            table.insert(chests,candy_chest)
        end
        for chest_num,chest_inst in ipairs(chests) do
            local sp = math.random()*3+2
            local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(2*math.cos(spawnangle), 2, 2*math.sin(spawnangle))
            chest_inst.Transform:SetPosition(pt:Get())
            chest_inst.Physics:SetVel(sp*math.cos(angle*chest_num), math.random()*2+9, sp*math.sin(angle*chest_num))
            if chest_inst.components.inventoryitem then
                chest_inst.components.inventoryitem:SetLanded(false, true)
            end
            chest_inst.AnimState:PlayAnimation("air_loop", true)

            chest_inst:ListenForEvent("on_landed", function()
                chest_inst.AnimState:PlayAnimation("land")
                chest_inst.AnimState:PushAnimation("closed", true)
            end)
        end

        if candy_chest ~= nil then
            local candytypes = { math.random(NUM_HALLOWEENCANDY), math.random(NUM_HALLOWEENCANDY), math.random(NUM_HALLOWEENCANDY), math.random(NUM_HALLOWEENCANDY) }
            local numcandies = ((item.components.tradable.dubloonvalue or 1) + math.random(3) + 2)
            if giver ~= nil and giver.components.skinner ~= nil then
                for _, item in pairs(giver.components.skinner:GetClothing()) do
                    if DoesItemHaveTag(item, "COSTUME") or DoesItemHaveTag(item, "HALLOWED") then
                        numcandies = numcandies + math.random(6) + 3
                        break
                    end
                end
            end
            for i = 1, numcandies do
                local loot = SpawnPrefab("halloweencandy_"..GetRandomItem(candytypes))
                candy_chest.components.container:GiveItem(loot, nil, nil, true, false)
            end
        end

        if not istrinket then
            local single = SpawnPrefab("dubloon")
            chest.components.container:GiveItem(single, nil, nil, true, false)

            if itemprefab_loot then
                local goodreward = SpawnPrefab(itemprefab_loot)
                chest.components.container:GiveItem(goodreward, nil, nil, true, false)
            else
                local dubloonvalue = math.min(item.components.tradable.dubloonvalue or 0, 2)
                for i = 1, dubloonvalue do
                    local loot = SpawnPrefab(OCTOPUSKING_LOOT.randomchestloot[math.random(1, #OCTOPUSKING_LOOT.randomchestloot)])
                    chest.components.container:GiveItem(loot, nil, nil, true, false)
                end
            end
        else
            -- trinkets give out dubloons only
            for i = 1, (item.components.tradable.dubloonvalue or item.components.tradable.goldvalue * 3) do
                local loot = SpawnPrefab("dubloon")
                chest.components.container:GiveItem(loot, nil, nil, true, false)
            end
        end
        if tradefor ~= nil then
            for _, v in pairs(tradefor) do
                local item = SpawnPrefab(v)
                if item ~= nil then
                    chest.components.container:GiveItem(item, nil, nil, true, false)
                end
            end
        end
    end)

    inst.happy = true
    if inst.endhappytask then
        inst.endhappytask:Cancel()
    end
    inst.endhappytask = inst:DoTaskInTime(5, function(inst)
        inst.happy = false
        inst.endhappytask = nil
		
		if not IA_CONFIG.octopuskingtweak then
			FinishedTrading(inst)
		else
			inst.tradelist[giver.userid] = true
			inst.components.trader:Enable()
		end
    end)
end

local function OnRefuseItem(inst, giver, item)
    inst.SoundEmitter:PlaySound("ia/creatures/octopus_king/reject")
    inst.AnimState:PlayAnimation("unimpressed")
    inst.AnimState:PushAnimation("idle", true)
    inst.happy = false
end

local function OnSavefn(inst, data)
    if not inst.components.trader.enabled then
        data.sleeping = true
    end
end

local function OnLoadfn(inst,data)
    if data ~= nil and data.sleeping then
        FinishedTrading(inst)
    end
end

local function OnSaveMultiplayerfn(inst, data)
	if inst.tradelist ~= nil then
		data.tradelist = inst.tradelist
	end
end

local function OnLoadMultiplayerfn(inst, data)
	if data ~= nil and data.tradelist ~= nil then
		inst.tradelist = data.tradelist
	end
end

local function UpdateMultiplayer(inst)
	local pos = inst:GetPosition()
	local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 40, "player")
	local shouldsleep = true
	for i,v in ipairs(ents) do
		if v.userid ~= nil and inst.tradelist[v.userid] == nil then
			shouldsleep = false
		end
	end
	if not inst.sleeping and shouldsleep then
		FinishedTrading(inst)
	elseif not shouldsleep and inst.sleeping and not TheWorld.state.isnight then
		StartTrading(inst)
	end
end

local function AcceptTest(inst, item, giver)
    local itemprefab = string.sub(item.prefab, -8) == "_gourmet" and string.sub(item.prefab, 1, -9) or item.prefab
    return ((item.components.tradable.dubloonvalue and item.components.tradable.dubloonvalue > 0) 
    or OCTOPUSKING_LOOT.chestloot[itemprefab] ~= nil or string.sub(itemprefab, 1, 7) == "trinket") 
    and (not IA_CONFIG.octopuskingtweak or (inst.tradelist ~= nil and giver.userid ~= nil 
    and inst.tradelist[giver.userid] == nil))
end

local function StartDay(inst)
    if IA_CONFIG.octopuskingtweak then
        inst.tradelist = {}
    else
        StartTrading(inst)
    end
end

local function OnHaunt(inst, haunter)
    if inst.components.trader and inst.components.trader.enabled then
        OnRefuseItem(inst)
        return true
    end
    return false
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()

    inst.MiniMapEntity:SetIcon("octopus.tex")
    inst.MiniMapEntity:SetPriority(1)

    inst.DynamicShadow:SetSize(10, 5)

    MakeWaterObstaclePhysics(inst, 2.5, .9, 1)

    inst:AddTag("king")
    inst.AnimState:SetBank("octopus")
    inst.AnimState:SetBuild("octopus")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("trader")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("trader")

    inst.components.trader:SetAcceptTest(AcceptTest)

    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem

	inst.OnLoad = OnLoadfn
	inst.OnSave = OnSavefn

	inst:WatchWorldState("startnight", FinishedTrading)

    inst:WatchWorldState("startday", StartDay)

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
    inst.components.hauntable:SetOnHauntFn(OnHaunt)
	
	if IA_CONFIG.octopuskingtweak then
		inst.tradelist = {}
	
		inst.OnLoad = OnLoadMultiplayerfn
		inst.OnSave = OnSaveMultiplayerfn
		
		inst._multiplayertask = inst:DoPeriodicTask(1, UpdateMultiplayer)
	end

    return inst
end

return Prefab( "octopusking", fn, assets, prefabs)
