local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("lureplant", function(inst)
	if not TheWorld.ismastersim then
		return
	end

	local minionspawner = inst.components.minionspawner
	if minionspawner and minionspawner.validtiletypes then
		minionspawner.validtiletypes[WORLD_TILES.BEACH] = true
		minionspawner.validtiletypes[WORLD_TILES.JUNGLE] = true
		minionspawner.validtiletypes[WORLD_TILES.TIDALMARSH] = true
		minionspawner.validtiletypes[WORLD_TILES.MEADOW] = true
	end
end)
