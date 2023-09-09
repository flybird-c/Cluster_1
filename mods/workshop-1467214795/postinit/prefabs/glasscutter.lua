local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("glasscutter", function(inst)

    inst:AddComponent("symbolswapdata")
	inst.components.symbolswapdata:SetData("swap_glasscutter", "swap_glasscutter")
    
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.HACK, 3)
    inst.components.finiteuses:SetConsumption(ACTIONS.HACK, 0.5)

end)

