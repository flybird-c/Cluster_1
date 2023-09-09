local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local function fn(inst)
	inst:AddComponent("floodable")

	if TheWorld.ismastersim then
		inst.components.floodable:SetFX("shock_machines_fx",5)
		--rest handled in postinit/components/builder.lua
	end
end

-- Prototypers
IAENV.AddPrefabPostInit("researchlab", fn)
IAENV.AddPrefabPostInit("researchlab2", fn)
IAENV.AddPrefabPostInit("researchlab3", fn)
IAENV.AddPrefabPostInit("researchlab4", fn)
IAENV.AddPrefabPostInit("piratihatitator", fn)
IAENV.AddPrefabPostInit("turfcraftingstation", fn)

-- Crafting Stations
IAENV.AddPrefabPostInit("madscience_lab", fn)
IAENV.AddPrefabPostInit("wintersfeastoven", fn)
