local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local INITIAL_LAUNCH_HEIGHT = 0.1
local SPEED = 8
local function launch_away(inst, position)
    local ix, iy, iz = inst.Transform:GetWorldPosition()
    inst.Physics:Teleport(ix, iy + INITIAL_LAUNCH_HEIGHT, iz)

    local px, py, pz = position:Get()
    local angle = (180 - inst:GetAngleToPoint(px, py, pz)) * DEGREES
    local sina, cosa = math.sin(angle), math.cos(angle)
    inst.Physics:SetVel(SPEED * cosa, 4 + SPEED, SPEED * sina)
end

local do_water_explosion_effect = nil
local function ia_do_water_explosion_effect(inst, affected_entity, owner, position, ...)
    if affected_entity._on_trident_explosion_fn then
        return affected_entity._on_trident_explosion_fn(affected_entity, inst, owner, position, launch_away, ...)
    end
    return do_water_explosion_effect(inst, affected_entity, owner, position, ...)
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("trident", function(inst)
    if inst.DoWaterExplosionEffect then
        if not do_water_explosion_effect then
            do_water_explosion_effect = inst.DoWaterExplosionEffect
        end
        inst.DoWaterExplosionEffect = ia_do_water_explosion_effect
    end
end)