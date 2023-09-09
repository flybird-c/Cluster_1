local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local PARTICLE_STATES = {}

local TILE_WEST  = 0x01
local TILE_NORTH = 0x02
local TILE_EAST  = 0x04
local TILE_SOUTH = 0x08

local TILE_NORTHWEST = 0x10
local TILE_NORTHEAST = 0x20
local TILE_SOUTHEAST = 0x40
local TILE_SOUTHWEST = 0x80

local ANIM_SCALE = 1/150
local function PixelsToCoords(pixel_count)
    return ANIM_SCALE*pixel_count
end
local NORMAL_SCALE_ENVELOPE = "particle_tile_state_normal_scaleenvelope"
local SMALL_SCALE_ENVELOPE = "particle_tile_state_small_scaleenvelope"

ParticleTileScale =
{
	NORMAL = 4,
	SMALL = 2,
}

local MAX_LIFETIME = 10000
local SPAWN_LIFETIME_FAST_FORWARD = -10000+10
local SIM_TICK_TIME = TheSim:GetTickTime()
--our lifetime system ensures that if the time alive of a particle stays between -10000 and -9900 it will evaluate correctly, stay between -9990 and -9910 just to be safe
local LIFETIME_RANGE = math.ceil(80/SIM_TICK_TIME)*SIM_TICK_TIME

local TEXTURE_INDEX_WIDTH = 8
local TEXTURE_INDEX_HEIGHT = 6

local tx, ty = 0, TEXTURE_INDEX_HEIGHT - 1

local function GetLifetimeForTextureIndex()
	local index = (ty * TEXTURE_INDEX_WIDTH + tx) + 1
	return MAX_LIFETIME / index
end

function UpdateNextIndex()
	tx = tx + 1
	if tx == TEXTURE_INDEX_WIDTH then
		tx = 0
		ty = ty - 1
	end
end

local TileMaskToTextureIndex = {}
local function GenerateLifetimeForTiles(required, ...)
	local optionals = {...}
	local optional_count = #optionals

	local lifetime = GetLifetimeForTextureIndex()

	TileMaskToTextureIndex[required] = lifetime

	if optional_count == 1 then
		local o1 = optionals[1]
		TileMaskToTextureIndex[required+o1] = lifetime
	elseif optional_count == 2 then
		local o1 = optionals[1]
		local o2 = optionals[2]
		TileMaskToTextureIndex[required+o1] = lifetime
		TileMaskToTextureIndex[required+o2] = lifetime
		TileMaskToTextureIndex[required+o1+o2] = lifetime
	elseif optional_count == 3 then
		local o1 = optionals[1]
		local o2 = optionals[2]
		local o3 = optionals[3]
		TileMaskToTextureIndex[required+o1] = lifetime
		TileMaskToTextureIndex[required+o2] = lifetime
		TileMaskToTextureIndex[required+o3] = lifetime
		TileMaskToTextureIndex[required+o1+o2] = lifetime
		TileMaskToTextureIndex[required+o1+o3] = lifetime
		TileMaskToTextureIndex[required+o2+o3] = lifetime
		TileMaskToTextureIndex[required+o1+o2+o3] = lifetime
	elseif optional_count == 4 then
		local o1 = optionals[1]
		local o2 = optionals[2]
		local o3 = optionals[3]
		local o4 = optionals[4]
		TileMaskToTextureIndex[required+o1] = lifetime
		TileMaskToTextureIndex[required+o2] = lifetime
		TileMaskToTextureIndex[required+o3] = lifetime
		TileMaskToTextureIndex[required+o4] = lifetime
		TileMaskToTextureIndex[required+o1+o2] = lifetime
		TileMaskToTextureIndex[required+o1+o3] = lifetime
		TileMaskToTextureIndex[required+o1+o4] = lifetime
		TileMaskToTextureIndex[required+o2+o3] = lifetime
		TileMaskToTextureIndex[required+o2+o4] = lifetime
		TileMaskToTextureIndex[required+o3+o4] = lifetime
		TileMaskToTextureIndex[required+o1+o2+o3] = lifetime
		TileMaskToTextureIndex[required+o1+o2+o4] = lifetime
		TileMaskToTextureIndex[required+o1+o3+o4] = lifetime
		TileMaskToTextureIndex[required+o2+o3+o4] = lifetime
		TileMaskToTextureIndex[required+o1+o2+o3+o4] = lifetime
	end

	UpdateNextIndex()
end


--print("row 1")
local PRIMARY_LIFETIME = GetLifetimeForTextureIndex()
UpdateNextIndex()

GenerateLifetimeForTiles(TILE_WEST, TILE_NORTHWEST, TILE_SOUTHWEST)

GenerateLifetimeForTiles(TILE_NORTH, TILE_NORTHWEST, TILE_NORTHEAST)

GenerateLifetimeForTiles(TILE_NORTH+TILE_WEST, TILE_NORTHWEST, TILE_NORTHEAST, TILE_SOUTHWEST)

GenerateLifetimeForTiles(TILE_EAST, TILE_NORTHEAST, TILE_SOUTHEAST)

GenerateLifetimeForTiles(TILE_WEST+TILE_EAST, TILE_NORTHWEST, TILE_NORTHEAST, TILE_SOUTHEAST, TILE_SOUTHWEST)

GenerateLifetimeForTiles(TILE_NORTH+TILE_EAST, TILE_NORTHWEST, TILE_NORTHEAST, TILE_SOUTHEAST)

GenerateLifetimeForTiles(TILE_WEST+TILE_NORTH+TILE_EAST, TILE_NORTHWEST, TILE_NORTHEAST, TILE_SOUTHEAST, TILE_SOUTHWEST)

--print("row 2")

GenerateLifetimeForTiles(TILE_SOUTH, TILE_SOUTHEAST, TILE_SOUTHWEST)

GenerateLifetimeForTiles(TILE_SOUTH+TILE_WEST, TILE_NORTHWEST, TILE_SOUTHEAST, TILE_SOUTHWEST)

GenerateLifetimeForTiles(TILE_SOUTH+TILE_NORTH, TILE_NORTHWEST, TILE_NORTHEAST, TILE_SOUTHEAST, TILE_SOUTHWEST)

GenerateLifetimeForTiles(TILE_WEST+TILE_NORTH+TILE_SOUTH, TILE_NORTHWEST, TILE_NORTHEAST, TILE_SOUTHEAST, TILE_SOUTHWEST)

GenerateLifetimeForTiles(TILE_SOUTH+TILE_EAST, TILE_SOUTHEAST, TILE_NORTHEAST, TILE_SOUTHWEST)

GenerateLifetimeForTiles(TILE_WEST+TILE_EAST+TILE_SOUTH, TILE_NORTHWEST, TILE_NORTHEAST, TILE_SOUTHEAST, TILE_SOUTHWEST)

GenerateLifetimeForTiles(TILE_NORTH+TILE_EAST+TILE_SOUTH, TILE_NORTHWEST, TILE_NORTHEAST, TILE_SOUTHEAST, TILE_SOUTHWEST)

GenerateLifetimeForTiles(TILE_WEST+TILE_NORTH+TILE_SOUTH+TILE_EAST, TILE_NORTHWEST, TILE_NORTHEAST, TILE_SOUTHEAST, TILE_SOUTHWEST)

--print("row 3")

--this case is skipped
UpdateNextIndex()

GenerateLifetimeForTiles(TILE_NORTHWEST)

GenerateLifetimeForTiles(TILE_NORTHEAST)

GenerateLifetimeForTiles(TILE_NORTHWEST + TILE_NORTHEAST)

GenerateLifetimeForTiles(TILE_SOUTHEAST)

GenerateLifetimeForTiles(TILE_NORTHWEST + TILE_SOUTHEAST)

GenerateLifetimeForTiles(TILE_NORTHEAST + TILE_SOUTHEAST)

GenerateLifetimeForTiles(TILE_NORTHWEST + TILE_NORTHEAST + TILE_SOUTHEAST)

--print("row 4")

GenerateLifetimeForTiles(TILE_SOUTHWEST)

GenerateLifetimeForTiles(TILE_NORTHWEST + TILE_SOUTHWEST)

GenerateLifetimeForTiles(TILE_SOUTHWEST + TILE_NORTHEAST)

GenerateLifetimeForTiles(TILE_SOUTHWEST + TILE_NORTHWEST + TILE_NORTHEAST)

GenerateLifetimeForTiles(TILE_SOUTHWEST + TILE_SOUTHEAST)

GenerateLifetimeForTiles(TILE_SOUTHWEST + TILE_SOUTHEAST + TILE_NORTHWEST)

GenerateLifetimeForTiles(TILE_SOUTHWEST + TILE_SOUTHEAST + TILE_NORTHEAST)

GenerateLifetimeForTiles(TILE_SOUTHWEST + TILE_SOUTHEAST + TILE_NORTHEAST + TILE_NORTHWEST)

--print("row 5")

GenerateLifetimeForTiles(TILE_NORTH + TILE_SOUTHEAST, TILE_NORTHWEST, TILE_NORTHEAST)

GenerateLifetimeForTiles(TILE_EAST + TILE_SOUTHWEST, TILE_NORTHEAST, TILE_SOUTHEAST)

GenerateLifetimeForTiles(TILE_SOUTH + TILE_NORTHWEST, TILE_SOUTHWEST, TILE_SOUTHEAST)

GenerateLifetimeForTiles(TILE_WEST + TILE_NORTHEAST, TILE_SOUTHWEST, TILE_NORTHWEST)

GenerateLifetimeForTiles(TILE_NORTH + TILE_SOUTHEAST + TILE_SOUTHWEST, TILE_NORTHWEST, TILE_NORTHEAST)

GenerateLifetimeForTiles(TILE_EAST + TILE_SOUTHWEST + TILE_NORTHWEST, TILE_NORTHEAST, TILE_SOUTHEAST)

GenerateLifetimeForTiles(TILE_SOUTH + TILE_NORTHWEST + TILE_NORTHEAST, TILE_SOUTHWEST, TILE_SOUTHEAST)

GenerateLifetimeForTiles(TILE_WEST + TILE_NORTHEAST + TILE_SOUTHEAST, TILE_SOUTHWEST, TILE_NORTHWEST)

--print("row 6")

GenerateLifetimeForTiles(TILE_NORTH + TILE_SOUTHWEST, TILE_NORTHWEST, TILE_NORTHEAST)

GenerateLifetimeForTiles(TILE_EAST + TILE_NORTHWEST, TILE_NORTHEAST, TILE_SOUTHEAST)

GenerateLifetimeForTiles(TILE_SOUTH + TILE_NORTHEAST, TILE_SOUTHWEST, TILE_SOUTHEAST)

GenerateLifetimeForTiles(TILE_WEST + TILE_SOUTHEAST, TILE_SOUTHWEST, TILE_NORTHWEST)

GenerateLifetimeForTiles(TILE_NORTH + TILE_WEST + TILE_SOUTHEAST, TILE_NORTHWEST, TILE_NORTHEAST, TILE_SOUTHWEST)

GenerateLifetimeForTiles(TILE_NORTH + TILE_EAST + TILE_SOUTHWEST, TILE_NORTHWEST, TILE_NORTHEAST, TILE_SOUTHEAST)

GenerateLifetimeForTiles(TILE_SOUTH + TILE_WEST + TILE_NORTHEAST, TILE_NORTHWEST, TILE_SOUTHEAST, TILE_SOUTHWEST)

GenerateLifetimeForTiles(TILE_SOUTH + TILE_EAST + TILE_NORTHWEST, TILE_SOUTHEAST, TILE_NORTHEAST, TILE_SOUTHWEST)

local function CreateParticleTileStateManager(x, y, z, texture, shader, max_particles, scale_envelope)
	local inst = CreateEntity()

	inst.entity:SetCanSleep(false)

	inst.entity:AddTransform()
	inst.Transform:SetPosition(x, y, z)

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    inst:AddTag("CLASSIFIED")

    local effect = inst.entity:AddVFXEffect()

    effect:InitEmitters(1)
    effect:SetRenderResources(0, resolvefilepath(texture), resolvefilepath(shader))
    effect:SetMaxNumParticles(0, max_particles)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetSpawnVectors(0, 0, 0, 1, 1, 0, -0)
    effect:SetScaleEnvelope(0, scale_envelope)

    effect:SetLayer(0, LAYER_GROUND)
    effect:SetSortOrder(0, 2)
    effect:SetSortOffset(0, 0)

    effect:SetBlendMode(0, BLENDMODE.Premultiplied)
    effect:SetKillOnEntityDeath(0, true)
    effect:SetWorldSpaceEmitter(0, true)

    local ticktime = 0

    function inst:UpdateParticles(dt)
		ticktime = ticktime + dt
		if ticktime >= LIFETIME_RANGE then
            effect:FastForward(0, -LIFETIME_RANGE)
            ticktime = ticktime - LIFETIME_RANGE
		end
    end

    function inst:ResetParticles()
		ticktime = 0
		effect:ClearAllParticles(0)
    end

    inst.entity:SetPristine()

    inst.persists = false

	inst:SetPrefabName("particle_tile_state")

	inst.entity:CallPrefabConstructionComplete()

	return inst
end

local function RebuildRegion(particle_state, rx, ry, is_despawn)
	local index = particle_state.rendergrid:GetIndex(rx, ry)
	local lifetimegrid = particle_state.lifetimegrid

	local start_x = rx * particle_state.region_size
	local start_y = ry * particle_state.region_size

	local end_x = math.min((rx + 1) * particle_state.region_size, lifetimegrid:Width())
	local end_y = math.min((ry + 1) * particle_state.region_size, lifetimegrid:Height())

	local render = particle_state.rendergrid:GetDataAtIndex(index)
	if not render and is_despawn then return end

	if not render then
		local x = particle_state.start_x + ((start_x + (particle_state.region_size*0.5 + 0.5)) * particle_state.tilescale) + 0.10
		local z = particle_state.start_z + ((start_y + (particle_state.region_size*0.5 + 0.5)) * particle_state.tilescale) + 0.10
		render = CreateParticleTileStateManager(x, 0, z, particle_state.texture, particle_state.shader, particle_state.region_size*particle_state.region_size, particle_state.scale_envelope)
		particle_state.rendergrid:SetDataAtIndex(index, render)
	else
		render:ResetParticles()
	end

	for x = start_x, end_x-1 do
		for y = start_y, end_y-1 do
			local lifetime = lifetimegrid:GetDataAtPoint(x, y)

			if lifetime then
				local particle_x = particle_state.start_x + (x * particle_state.tilescale)
				local particle_z = particle_state.start_z + (y * particle_state.tilescale)
				render.VFXEffect:AddParticle(0, lifetime, particle_x, 0, particle_z, 0, 0, 0)
			end
		end
	end

	if render.VFXEffect:GetNumLiveParticles(0) == 0 then
		render:Remove()
		particle_state.rendergrid:SetDataAtIndex(index, nil)
	else
		render.VFXEffect:FastForward(0, SPAWN_LIFETIME_FAST_FORWARD)
	end
end

local function GetRegionsForXY(particle_state, x, y, is_despawn)
	local region_size = particle_state.region_size

	local region_x_pos = x % region_size
	local region_y_pos = y % region_size

	local left = x > 0 and region_x_pos == 0
	local right  = x < particle_state.lifetimegrid:Width() - 1 and region_x_pos == region_size - 1
	local down = y > 0 and region_y_pos == 0
	local up = y < particle_state.lifetimegrid:Height() - 1 and region_y_pos == region_size - 1

	local region_x = math.floor(x / region_size)
	local region_y = math.floor(y / region_size)

	local regions = {}
	table.insert(regions, {x = region_x,  y = region_y, is_despawn = is_despawn})

	if down then  table.insert(regions, {x = region_x,  y = region_y - 1, is_despawn = is_despawn}) end
	if right then table.insert(regions, {x = region_x + 1,  y = region_y, is_despawn = is_despawn}) end
	if up then 	  table.insert(regions, {x = region_x,  y = region_y + 1, is_despawn = is_despawn}) end
	if left then  table.insert(regions, {x = region_x - 1,  y = region_y, is_despawn = is_despawn}) end

	if down and right then table.insert(regions, {x = region_x + 1,  y = region_y - 1, is_despawn = is_despawn}) end
	if up and right then   table.insert(regions, {x = region_x + 1,  y = region_y + 1, is_despawn = is_despawn}) end
	if up and left then	   table.insert(regions, {x = region_x - 1,  y = region_y + 1, is_despawn = is_despawn}) end
	if down and left then  table.insert(regions, {x = region_x - 1,  y = region_y - 1, is_despawn = is_despawn}) end

	return regions
end

local function GetLifetimeForTilePosition(grid, x, y)
	local mask = 0

	if grid:GetDataAtPoint(x - 1, y) == PRIMARY_LIFETIME then mask = mask + TILE_SOUTH end
	if grid:GetDataAtPoint(x, y - 1) == PRIMARY_LIFETIME then mask = mask + TILE_WEST end
	if grid:GetDataAtPoint(x + 1, y) == PRIMARY_LIFETIME then mask = mask + TILE_NORTH end
	if grid:GetDataAtPoint(x, y + 1) == PRIMARY_LIFETIME then mask = mask + TILE_EAST end

	if grid:GetDataAtPoint(x - 1, y - 1) == PRIMARY_LIFETIME then mask = mask + TILE_SOUTHWEST end
	if grid:GetDataAtPoint(x + 1, y - 1) == PRIMARY_LIFETIME then mask = mask + TILE_NORTHWEST end
	if grid:GetDataAtPoint(x + 1, y + 1) == PRIMARY_LIFETIME then mask = mask + TILE_NORTHEAST end
	if grid:GetDataAtPoint(x - 1, y + 1) == PRIMARY_LIFETIME then mask = mask + TILE_SOUTHEAST end

	return TileMaskToTextureIndex[mask]
end

local function Calculate3x3Lifetime(grid, c_x, c_y)
	for x = c_x - 1, c_x + 1 do
		for y = c_y - 1, c_y + 1 do
			local index = grid:GetIndex(x, y)
			local lifetime = grid:GetDataAtIndex(index)
			if lifetime ~= PRIMARY_LIFETIME then
				grid:SetDataAtIndex(index, GetLifetimeForTilePosition(grid, x, y))
			end
		end
	end
end

local function ConstructParticleState(particle_state)
	local lifetime_w, lifetime_h = TheWorld.Map:GetSize()
	local start_x, y, start_z = TheWorld.Map:GetTileCenterPoint(0, 0)
	local region_size = 32
	local render_w, render_h = math.ceil(lifetime_w / region_size), math.ceil(lifetime_h / region_size)
	local scale_envelope = NORMAL_SCALE_ENVELOPE

	if particle_state.tilescale == ParticleTileScale.SMALL then
		lifetime_w, lifetime_h = lifetime_w * 2, lifetime_h * 2
		start_x, start_z = start_x - 1, start_z - 1
		region_size = region_size * 0.5
		render_w, render_h = math.ceil(lifetime_w / region_size), math.ceil(lifetime_h / region_size)
		scale_envelope = SMALL_SCALE_ENVELOPE
	end

	particle_state.lifetimegrid = DataGrid(lifetime_w, lifetime_h)
	particle_state.rendergrid = DataGrid(render_w, render_h)
	particle_state.region_size = region_size
	particle_state.scale_envelope = scale_envelope

	particle_state.start_x = start_x
	particle_state.start_z = start_z
end

local function AddOrUpdateRegion(regions_to_rebuild, new_region)
	for i, region in pairs(regions_to_rebuild) do
		if region.x == new_region.x and region.y == new_region.y then
			region.is_despawn = region.is_despawn and new_region.is_despawn
			return
		end
	end
	table.insert(regions_to_rebuild, new_region)
end

local function QueueRegionRebuilds(particle_state, x, y, is_despawn)
	local regions = GetRegionsForXY(particle_state, x, y, is_despawn)
	for i, region in ipairs(regions) do
		AddOrUpdateRegion(particle_state.regions_to_rebuild, region)
	end
end

if not TheNet:IsDedicated() then
	local SimInit = false
	IAENV.AddSimPostInit(function()
		--these don't produce the exact size, but its close enough that we can round it to perfect numbers in the shader
		EnvelopeManager:AddVector2Envelope(NORMAL_SCALE_ENVELOPE, {
			{2, {4/PixelsToCoords(1024), 4/PixelsToCoords(1536)}}
		})

		EnvelopeManager:AddVector2Envelope(SMALL_SCALE_ENVELOPE, {
			{2, {2/PixelsToCoords(1024), 2/PixelsToCoords(1536)}}
		})

		for key, particle_state in pairs(PARTICLE_STATES) do
			ConstructParticleState(particle_state)
		end
		SimInit = true

		local _Update = Update
		function Update(dt, ...)
			_Update(dt, ...)
			for key, particle_state in pairs(PARTICLE_STATES) do
				for i, region in pairs(particle_state.regions_to_rebuild) do
					RebuildRegion(particle_state, region.x, region.y, region.is_despawn)
					particle_state.regions_to_rebuild[i] = nil
				end

				for index, render in pairs(particle_state.rendergrid.grid) do
					render:UpdateParticles(dt)
				end
			end
		end
		UpdateRegistry(_Update, Update)
	end)

	function RegisterParticleTileState(key, texture, shader, tilescale)
		assert(tilescale == ParticleTileScale.NORMAL or tilescale == ParticleTileScale.SMALL)

		PARTICLE_STATES[key] =
		{
			texture = texture,
			shader = shader,
			tilescale = tilescale,
			regions_to_rebuild = {},
		}

		if SimInit then
			ConstructParticleState(PARTICLE_STATES[key])
		end
	end

	function SetParticleTileState(key, x, y, state)
		state = state and true or false
		local particle_state = PARTICLE_STATES[key]

		local lifetimegrid = particle_state.lifetimegrid
		local index = lifetimegrid:GetIndex(x, y)
		local prev_state = lifetimegrid:GetDataAtIndex(index) == PRIMARY_LIFETIME

		if prev_state ~= state then
			lifetimegrid:SetDataAtIndex(index, state and PRIMARY_LIFETIME or nil)
			Calculate3x3Lifetime(lifetimegrid, x, y)

			QueueRegionRebuilds(particle_state, x, y, not state)
		end
	end

	function GetParticleTileState(key, x, y)
		local particle_state = PARTICLE_STATES[key]
		return particle_state.lifetimegrid:GetDataAtPoint(x, y) == PRIMARY_LIFETIME
	end

	--lays out a grid of all the different visual states
	function Debug_ViewFloodLifetimeGrid(key, x, y)
		local particle_state = PARTICLE_STATES[key]
		local grid = particle_state.lifetimegrid
		for i = -3, 4 do
			for j = -2, 3 do
				local lifetime = MAX_LIFETIME / (((j+2) * TEXTURE_INDEX_WIDTH + (i+3)) + 1)
				local index = grid:GetIndex(x+i, y+j)
				grid:SetDataAtIndex(index, lifetime)

				QueueRegionRebuilds(particle_state, x+i, y+j, false)
			end
		end
	end
else
	function RegisterParticleTileState() end
	function SetParticleTileState() end
	function GetParticleTileState() return false end
end