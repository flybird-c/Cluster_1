local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local IsOnFlood = IsOnFlood
local IsOceanTile = IsOceanTile
local IsSurroundedByWaterTile = IsSurroundedByWaterTile
local IsLandTile = IsLandTile

local function GetIAWaveBearing(map, ex, ey, ez)

	local offs_1 =
	{
		{-1,-1}, {0,-1}, {1,-1},
		{-1, 0},		 {1, 0},
		{-1, 1}, {0, 1}, {1, 1,},
	}

	local width, height = map:GetSize()
	local halfw, halfh = 0.5 * width, 0.5 * height
	local x, y = map:GetTileXYAtPoint(ex, ey, ez)
	local xtotal, ztotal, n = 0, 0, 0

	local is_nearby_land_tile = false
    local offs_2 = {}

	for i = 1, #offs_1, 1 do
		local curoff = offs_1[i]
		local offx, offy = curoff[1], curoff[2]

		local ground = map:GetTile(x + offx, y + offy)
		if IsLandTile(ground) then
			is_nearby_land_tile = true
            table.insert(offs_2, curoff)
		end
	end

    -- Shore check failed now check if shimmer can be added
    if not is_nearby_land_tile then return map:IsSurroundedByWater(ex, ey, ez, 4) end

    -- Go through valid offsets and check for flood
    for i = 1, #offs_2, 1 do
		local curoff = offs_2[i]
		local offx, offy = curoff[1], curoff[2]

        if not IsOnFlood(ex + offx * TILE_SCALE, ey, ez + offy * TILE_SCALE) then
            xtotal = xtotal + ((x + offx - halfw) * TILE_SCALE)
            ztotal = ztotal + ((y + offy - halfh) * TILE_SCALE)
            n = n + 1
        end
	end

    -- Get farther set of bearings
	local offs_3 =
	{
		{-2,-2}, {-1,-2}, {0,-2}, {1,-2}, {2,-2},
		{-2,-1}, 						  {2,-1},
		{-2, 0}, 						  {2, 0},
		{-2, 1}, 						  {2, 1},
		{-2, 2}, {-1, 2}, {0, 2}, {1, 2}, {2, 2}
	}
	for i = 1, #offs_3, 1 do
		local curoff = offs_3[i]
		local offx, offy = curoff[1], curoff[2]

		local ground = map:GetTile(x + offx, y + offy)
		if IsLandTile(ground) and not IsOnFlood(ex + offx * TILE_SCALE, ey, ez + offy * TILE_SCALE) then
			xtotal = xtotal + ((x + offx - halfw) * TILE_SCALE)
			ztotal = ztotal + ((y + offy - halfh) * TILE_SCALE)
			n = n + 1
		end
	end

    if n == 0 then return true end -- No bearings found use shimmer
	return -math.atan2(ztotal/n - ez, xtotal/n - ex)/DEGREES - 90
end

local function SpawnIAWaveShore(self, x, y, z, bearing)
    local wave = SpawnPrefab( "ia_wave_shore" )
    wave.Transform:SetPosition( x, y, z )
    wave.Transform:SetRotation(bearing)
    wave:SetAnim()
end

local function SpawnIAWaveFlood(self, x, y, z)
    local wave = SpawnPrefab( "ia_wave_shimmer_flood" )
    wave.Transform:SetPosition( x, y, z )

    local bearing = GetIAWaveBearing(TheWorld.Map, x, y, z)
	if bearing == false or bearing == true then return end

    SpawnIAWaveShore(self, x, y, z, bearing)
end

local function CheckFlood(inst, map, x, y, z, g)
	return IsOnFlood(x, y, z) and IsSurroundedByWaterTile(x, y, z, 2, true, true)
end

local function TrySpawnIAWavesOrShore(self, map, x, y, z)
    local bearing = GetIAWaveBearing(map, x, y, z)
    if bearing == false then return end

    if bearing == true then
        SpawnPrefab("ia_wave_shimmer").Transform:SetPosition(x, y, z)
    else
        SpawnIAWaveShore(self, x, y, z, bearing)
    end
end

local function TrySpawnIAWaveShimmerMedium(self, map, x, y, z)
	if map:IsSurroundedByWater(x, y, z, 4) then
		local wave = SpawnPrefab( "ia_wave_shimmer_med" )
		wave.Transform:SetPosition( x, y, z )
	end
end

local function TrySpawnIAWaveShimmerDeep(self, map, x, y, z)
	if map:IsSurroundedByWater(x, y, z, 5) then
		local wave = SpawnPrefab( "ia_wave_shimmer_deep" )
		wave.Transform:SetPosition( x, y, z )
	end
end

local ia_shimmer = {
	[WORLD_TILES.OCEAN_SHALLOW] = {per_sec = 75, spawn_rate = 0, tryspawn = TrySpawnIAWavesOrShore},
	[WORLD_TILES.OCEAN_CORAL] = {per_sec = 80, spawn_rate = 0, tryspawn = TrySpawnIAWavesOrShore},
	[WORLD_TILES.OCEAN_MEDIUM] = {per_sec = 75, spawn_rate = 0, tryspawn = TrySpawnIAWaveShimmerMedium},
	[WORLD_TILES.OCEAN_DEEP] = {per_sec = 70, spawn_rate = 0, tryspawn = TrySpawnIAWaveShimmerDeep},
	[WORLD_TILES.OCEAN_SHIPGRAVEYARD] = {per_sec = 80, spawn_rate = 0, tryspawn = TrySpawnIAWaveShimmerDeep},
	[WORLD_TILES.MANGROVE] = {per_sec = 80, spawn_rate = 0, tryspawn = TrySpawnIAWavesOrShore},
	FLOOD = {per_sec = 80, spawn_rate = 0, checkfn = CheckFlood, spawnfn = SpawnIAWaveFlood},
}

local function SetWaveSettings(self, shimmer)
    self.shimmer_per_sec_mod = shimmer
end

IAENV.AddComponentPostInit("wavemanager", function(cmp)
    for i,v in pairs(ia_shimmer) do
        cmp.shimmer[i] = v
    end

    cmp.SetWaveSettings = SetWaveSettings
end)