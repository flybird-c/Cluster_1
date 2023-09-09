local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local function merm_postinit(inst)

    inst:AddTag("mermfighter")

    if TheWorld.ismastersim and IsInIAClimate(inst) then
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
end

IAENV.AddPrefabPostInit("merm", merm_postinit)
IAENV.AddPrefabPostInit("mermguard", merm_postinit)
