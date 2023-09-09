local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

--TODO: figure out why this doesnt work -Half
--[[
local Old_OnIsDay
local function New_OnIsDay(inst, isday, ...)
    if Old_OnIsDay then
        Old_OnIsDay(inst, isday, ...)
    end
    if not isday and not inst:HasTag("burnt") and inst.components.childspawner ~= nil and inst.components.childspawner.childreninside > 0 then
        inst.components.childspawner:ReleaseAllChildren()
    end
end

local Old_StartSpawning
local function New_StartSpawning(inst, ...)
    if Old_StartSpawning then
        return Old_StartSpawning(inst, ...)
    end
    if not inst:HasTag("burnt") and not inst.components.childspawner ~= nil and not inst.components.childspawner.spawning then
        inst.components.childspawner:StartSpawning()
    end
end
--]]

local function mermhouse_postinit(inst)

    inst:AddTag("mermhouse")

    if TheWorld.ismastersim and IsInIAClimate(inst) then
        --for i, v in ipairs(inst.worldstatewatching["isday"]) do
        --    if UpvalueHacker.GetUpvalue(v, "StartSpawning") then
        --        if not Old_OnIsDay then
        --            Old_OnIsDay = inst.worldstatewatching["isday"][i]
        --        end
        --        inst.worldstatewatching["isday"][i] = New_OnIsDay
        --        local _StartSpawning =  UpvalueHacker.GetUpvalue(inst.worldstatewatching["isday"][i], "StartSpawning")
        --        if not Old_StartSpawning then
        --            Old_StartSpawning = _StartSpawning
        --        end
        --        _StartSpawning = New_StartSpawning
        --        break
        --    end
        --end
        if inst.components.lootdropper and inst.components.lootdropper.loot then
            for k,v in pairs(inst.components.lootdropper.loot) do
                if v == "pondfish" then
                    inst.components.lootdropper.loot[k] = "pondfish_tropical"
                end
            end  
        end
    end
end

IAENV.AddPrefabPostInit("mermhouse", mermhouse_postinit)
