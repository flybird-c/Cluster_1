local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("resurrectionstone", function(inst)

    if IsInIAClimate(inst) then 
        
        if not TheWorld.ismastersim then
            return 
        end

        if inst.components.lootdropper then -- Might need to use deepcopy when merged is back
            if inst.components.lootdropper and inst.components.lootdropper.loot then
                for k, loot_name in pairs(inst.components.lootdropper.loot) do
                    if loot_name == "marble" then
                        inst.components.lootdropper.loot[k] = "limestonenugget"
                    end
                end
            end
        end
    end
end)
