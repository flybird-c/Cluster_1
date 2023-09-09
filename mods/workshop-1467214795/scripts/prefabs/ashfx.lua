local TEXTURE = "images/fx/ash.tex"

local SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME = "ashcolourenvelope"
local SCALE_ENVELOPE_NAME = "ashscaleenvelope"

local assets =
{
    Asset("IMAGE", TEXTURE),
    Asset("SHADER", SHADER),
}

local function IntColour(r, g, b, a)
    return {r / 255.0, g / 255.0, b / 255.0, a / 255.0}
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(COLOUR_ENVELOPE_NAME, {
        {0, IntColour(50, 50, 50, 120)},
        {1, IntColour(50, 50, 50, 180)},})

    local max_scale = 1
    EnvelopeManager:AddVector2Envelope(SCALE_ENVELOPE_NAME, {
        {0, {max_scale, max_scale}},
        {1, {max_scale, max_scale}},})
    InitEnvelope = nil
    IntColour = nil
end

local MAX_LIFETIME = 7
local MIN_LIFETIME = 4

local function emit_fn(effect, emitter_shape)
    local vx, vy, vz = 0, 0, 0
    local lifetime = MIN_LIFETIME + ( MAX_LIFETIME - MIN_LIFETIME ) * UnitRand()
    local px, py, pz = emitter_shape()

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
    effect:SetMaxNumParticles(0, 4800)
    effect:SetMaxLifetime(0, MAX_LIFETIME)
    effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
    effect:SetScaleEnvelope(0, SCALE_ENVELOPE_NAME)
    effect:SetBlendMode(0, BLENDMODE.Premultiplied)
    effect:SetSortOrder(0, 3)
    effect:SetAcceleration(0, -1, -9.80/2, 1)
    effect:SetDragCoefficient(0, 0.8)
    effect:EnableDepthTest(0, true)

    -----------------------------------------------------

    local tick_time = TheSim:GetTickTime()

    local desired_particles_per_second = 0
    inst.particles_per_tick = desired_particles_per_second * tick_time

    local num_particles_to_emit = inst.particles_per_tick

    local bx, by, bz = 0, 20, 0
    local emitter_shape = CreateBoxEmitter(bx, by, bz, bx + 20, by, bz + 20)

    EmitterManager:AddEmitter(inst, nil, function()
        while num_particles_to_emit > 1 do
            emit_fn(effect, emitter_shape)
            num_particles_to_emit = num_particles_to_emit - 1
        end
        num_particles_to_emit = num_particles_to_emit + inst.particles_per_tick
    end)
end

local function fn(Sim)
    local inst = CreateEntity()

    inst.entity:AddTransform()

    inst:AddTag("FX")

    InitParticles(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

return Prefab("ashfx", fn, assets)
 
