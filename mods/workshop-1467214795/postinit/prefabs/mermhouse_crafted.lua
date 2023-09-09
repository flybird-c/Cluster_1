local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local function mermhouse_postinit(inst)

    inst:AddTag("mermhouse")

    if TheWorld.ismastersim and IsInIAClimate(inst) then
        if inst.components.lootdropper and inst.components.lootdropper.loot then
            for k,v in pairs(inst.components.lootdropper.loot) do
                if v == "pondfish" then
                    inst.components.lootdropper.loot[k] = "pondfish_tropical"
                end
            end  
        end      
    end
end

IAENV.AddPrefabPostInit("mermwatchtower", mermhouse_postinit)
IAENV.AddPrefabPostInit("mermhouse_crafted", mermhouse_postinit)
