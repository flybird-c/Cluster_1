local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local function fn(inst)
    if ThePlayer ~= nil then
        local climate = GetClimate(ThePlayer)

        if IsClimate(climate, "island") then
            local warning_level = inst.prefab:sub(-1)
            if warning_level then
                SpawnPrefab("crocodogwarning_lvl"..warning_level)
            end
        end
        if not IsDSTClimate(climate) then
            inst:Remove()
        end
    end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("houndwarning_lvl1", fn)
IAENV.AddPrefabPostInit("houndwarning_lvl2", fn)
IAENV.AddPrefabPostInit("houndwarning_lvl3", fn)
IAENV.AddPrefabPostInit("houndwarning_lvl4", fn)
    
