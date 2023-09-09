local TEXTURE = "levels/textures/ds_fog1.tex"

local SHADER = "shaders/vfx_particle.ksh"

local OCEAN_COLOUR_ENVELOPE_NAME = "oceanfogcolourenvelope"
local VOLCANO_COLOUR_ENVELOPE_NAME = "volcanofogcolourenvelope"
local SCALE_ENVELOPE_NAME = "oceanfogscaleenvelope"

local assets = {
    Asset("IMAGE", TEXTURE),
    Asset("SHADER", SHADER),
}

local function IntColour(r, g, b, a)
    return {r / 255.0, g / 255.0, b / 255.0, a / 255.0}
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(OCEAN_COLOUR_ENVELOPE_NAME, {
        {0, IntColour(255, 255, 255, 0)},
        {0.1, IntColour(255, 255, 255, 61)},
        {0.75, IntColour(255, 255, 255, 61)},
        {1, IntColour(255, 255, 255, 0)}})

    EnvelopeManager:AddColourEnvelope(VOLCANO_COLOUR_ENVELOPE_NAME, {
        {0, IntColour(255, 255, 255, 0)},
        {0.1, IntColour(255, 255, 255, 30)},
        {0.75, IntColour(255, 255, 255, 30)},
        {1, IntColour(255, 255, 255, 0)}})

    local min_scale = 6
    local max_scale = 10
	EnvelopeManager:AddVector2Envelope(SCALE_ENVELOPE_NAME, {
			{0,	{min_scale, min_scale}},
			{1,	{max_scale, max_scale}}})
    InitEnvelope = nil
    IntColour = nil
end

local MAX_LIFETIME = 15
local MAX_NUM_PARTICLES = 16 * MAX_LIFETIME
local GROUND_HEIGHT = 0.4
local EMITTER_RADIUS = 50

local function emit_fn(effect, radius)
	local vx, vy, vz = 0.01 * UnitRand(), 0, 0.01 * UnitRand()
	local lifetime = MAX_LIFETIME * (0.9 + UnitRand() * 0.1)
	local px, py, pz = radius * UnitRand(), GROUND_HEIGHT, radius * UnitRand()

    effect:AddParticle(
        0,
        lifetime,           -- lifetime
        px, py, pz,         -- position
        vx, vy, vz          -- velocity
    )
end

local function InitParticles(inst)
    --Dedicated server does not need to spawn local particle fx
    if TheNet:IsDedicated() then
        return
    elseif InitEnvelope ~= nil then
        InitEnvelope()
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)
    effect:SetRenderResources(0, softresolvefilepath(TEXTURE), SHADER)
    effect:SetMaxNumParticles(0, MAX_NUM_PARTICLES)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetSpawnVectors(0, -1, 0, 1, 1, 0, 1)
    effect:SetSortOrder(0, 3)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetRadius(0, EMITTER_RADIUS)

	inst.num_particles_to_emit = 0
end

local function commonfn(Sim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddNetwork()

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

    InitParticles(inst)

    return inst
end

local function oceanfn()
	local inst = commonfn()

    inst.entity:SetPristine()

    if TheNet:IsDedicated() then
    	return inst
    end

	inst.VFXEffect:SetColourEnvelope(0, OCEAN_COLOUR_ENVELOPE_NAME)
	inst.particles_per_tick = 8 * TheSim:GetTickTime()

	inst.daysegs = 16

	inst:ListenForEvent("clocksegschanged", function(world, data)
		inst.daysegs = data.day
	end, TheWorld)
	
	EmitterManager:AddEmitter(inst, nil, function()
		if TheWorld.state.isday then
			local t = inst.daysegs * TheWorld.state.timeinphase
			if t >= 0 and t <= 2 then
		        while inst.num_particles_to_emit > 1 do
		            emit_fn(inst.VFXEffect, EMITTER_RADIUS)
		            inst.num_particles_to_emit = inst.num_particles_to_emit - 1
		        end
		        inst.num_particles_to_emit = inst.num_particles_to_emit + inst.particles_per_tick
		    end
	    end
	end)

	return inst
end

local function gravefn(Sim)
	local inst = commonfn()

	inst._radius = net_float(inst.GUID, "radius", "onvfxradiusdirty")

    inst.entity:SetPristine()

    if TheWorld.ismastersim then
		inst:AddComponent("scenariorunner")
		inst.components.scenariorunner:SetScript("fog_shipgrave")

		inst.SetRadius = function(inst, radius)
			inst._radius:set(radius)
		end

		inst.OnSave = function(inst, data)
			data.radius = inst._radius:value()
		end

		inst.OnLoad = function(inst, data)
			if data and data.radius then
				inst:SetRadius(data.radius)
			end
		end
    end

    if TheNet:IsDedicated() then
    	return inst
    end

    inst:ListenForEvent("onvfxradiusdirty", function(inst)
    	inst.radius = inst._radius:value()
    	inst.VFXEffect:SetRadius(0, inst.radius)
    end)

	inst.VFXEffect:SetColourEnvelope(0, OCEAN_COLOUR_ENVELOPE_NAME)
	inst.particles_per_tick = 1 * TheSim:GetTickTime()

	inst.radius = 2

	inst.VFXEffect:SetRadius(0, inst.radius)
	
	EmitterManager:AddEmitter(inst, nil, function()
        while inst.num_particles_to_emit > 1 do
            emit_fn(inst.VFXEffect, inst.radius)
            inst.num_particles_to_emit = inst.num_particles_to_emit - 1
        end
        inst.num_particles_to_emit = inst.num_particles_to_emit + inst.particles_per_tick
	end)

	return inst
end

local function volcanofn()
	local inst = commonfn()

    inst.entity:SetPristine()
	
    if TheNet:IsDedicated() then
    	return inst
    end

	inst.VFXEffect:SetColourEnvelope(0, VOLCANO_COLOUR_ENVELOPE_NAME)
	inst.particles_per_tick = 1 * TheSim:GetTickTime()
	
	EmitterManager:AddEmitter(inst, nil, function()
        while inst.num_particles_to_emit > 1 do
            emit_fn(inst.VFXEffect, EMITTER_RADIUS)
            inst.num_particles_to_emit = inst.num_particles_to_emit - 1
        end
        inst.num_particles_to_emit = inst.num_particles_to_emit + inst.particles_per_tick
	end)

	return inst
end

return Prefab("oceanfog", oceanfn, assets),
		Prefab("shipgravefog", gravefn, assets),
		Prefab("volcanofog", volcanofn, assets)