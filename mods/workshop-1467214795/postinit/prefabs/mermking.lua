local IAENV = env
GLOBAL.setfenv(1, GLOBAL)
--------------------------------------------

local function SetTrading_Items(inst)
    if inst.trading_items then
        for i,v in pairs(inst.trading_items) do
            for k,prefab in pairs(v.prefabs) do
                if prefab == "kelp" then
                    inst.trading_items[i].prefabs[k] = "seaweed"
                elseif prefab == "tentaclespots" then
                    if not table.contains(inst.trading_items[i].prefabs, "blowdart_flup") then
                        table.insert(inst.trading_items[i].prefabs, "blowdart_flup") --pretty rare
                        inst.trading_items[i].max_count = 3 --buff it to account for adding the flupshot and rarity of tentacle spots in sw
                    end
                end
            end
        end
    end
end

local Old_TradeItem
local function New_TradeItem(inst)
    local _trading_items = inst.trading_items
    if Old_TradeItem then
        Old_TradeItem(inst)
    end
    if _trading_items ~= inst.trading_items then --if the tables have been changed during this time they must of been reset, reapply our changes
        SetTrading_Items(inst)
    end
end
local function fn(inst)
    if TheWorld.ismastersim and IsInIAClimate(inst) then
        if inst.components.lootdropper and inst.components.lootdropper.loot ~= nil then
            local remove = {}
            for index,loot in pairs(inst.components.lootdropper.loot) do
                if loot == "pondfish" then
                    inst.components.lootdropper.loot[index] = "pondfish_tropical"
                elseif loot == "kelp" then
                    inst.components.lootdropper.loot[index] = "seaweed"
                elseif loot == "froglegs" then --sw merms dont ever drop froglegs
                    table.insert(remove, index)
                end
            end
            for num,remove_index in pairs(remove) do
                table.remove(inst.components.lootdropper.loot, remove_index)
            end
        end
        local _trading_filler = UpvalueHacker.GetUpvalue(inst.TradeItem, "trading_filler")
        if _trading_filler then
            for i,v in pairs(_trading_filler) do
                if v == "kelp" then
                    _trading_filler[i] = "seaweed"
                end
            end
        end
        SetTrading_Items(inst)
        if not Old_TradeItem then
            Old_TradeItem = inst.TradeItem
        end
        inst.TradeItem = New_TradeItem
    end
end

IAENV.AddPrefabPostInit("mermking", fn)
