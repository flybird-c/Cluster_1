local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local MAKE_NEXT_EXCLUDE_TAGS = {"tallbird"}
local NESTABLE_TILES = table.invert({WORLD_TILES.MAGMAFIELD, WORLD_TILES.VOLCANO_ROCK})

local _CanMakeNewHome = nil
local function CanMakeNewHome(inst, ...)
    if _CanMakeNewHome(inst, ...) then
        return true
    end
    if inst.components.homeseeker == nil and not inst.components.combat:HasTarget() then
		local x, y, z = inst.Transform:GetWorldPosition()
		local tile = TheWorld.Map:GetTileAtPoint(x, y, z)
		return NESTABLE_TILES[tile] and TheSim:CountEntities(x, y, z, TUNING.TALLBIRD_MAKE_NEST_RADIUS, nil, MAKE_NEXT_EXCLUDE_TAGS) == 0
	end
end

local function fn(inst)
    if TheWorld.ismastersim then
        if not _CanMakeNewHome then
            _CanMakeNewHome = inst.CanMakeNewHome
        end
        inst.CanMakeNewHome = CanMakeNewHome
    end
end

IAENV.AddPrefabPostInit("tallbird", fn)
