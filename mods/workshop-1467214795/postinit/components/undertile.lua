local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local function GetBaseTile(x, y)
    local map = TheWorld.Map

	local tile = map:GetTile(x, y)
	local climate = GetClimate(Vector3(x, 0, y))
	local basetile = WORLD_TILES.DIRT
	if IsClimate(climate, "volcano") then
		basetile = WORLD_TILES.VOLCANO_ROCK
	elseif IsClimate(climate, "island") then
		basetile = WORLD_TILES.BEACH
	--elseif tile == WORLD_TILES.PIGRUINS then
	--	basetile = WORLD_TILES.DEEPRAINFOREST
	end

	return basetile ~= tile and basetile or nil
end

IAENV.AddComponentPostInit("undertile", function(cmp)
	local _GetTileUnderneath = cmp.GetTileUnderneath
	function cmp:GetTileUnderneath(x, y, ...)
	    return _GetTileUnderneath(self, x, y, ...) or GetBaseTile(x, y)
	end
end)

-- This new cmp is NEAT!
