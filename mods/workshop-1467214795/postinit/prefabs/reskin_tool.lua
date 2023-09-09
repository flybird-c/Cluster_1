local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local reskin_varient_fx_info =
{
	krampus = { scale = 1.4 },
	butterfly = { scale = 0.9 },
    cutgrass = { scale = 0.9 },
	butterflywings = { scale = 0.9 },
    log = { scale = 0.9 },
	cave_banana = { scale = 0.9 },
	cave_banana_cooked = { scale = 0.9 },
}

local old_can_cast_fn
local function new_can_cast_fn(doer, target, pos, ...)
    return (old_can_cast_fn ~= nil and old_can_cast_fn(doer, target, pos, ...)) or (target ~= nil and target.components ~= nil and target.components.visualvariant ~= nil and next(target.components.visualvariant.possible_variants) ~= nil)
end

local old_spellCB
local function new_spellCB(tool, target, pos, caster, ...)
    local visualvariant = target ~= nil and target.components.visualvariant or nil
    local next_variant = nil
    if visualvariant ~= nil and target.skinname == nil then
        next_variant = next(visualvariant.possible_variants, visualvariant.variant) or next(visualvariant.possible_variants)
    end
    if next_variant then
        tool:DoTaskInTime(0, function()
            if target:IsValid() and tool:IsValid() then
                visualvariant:Set(next_variant)
            end
        end)
    end
    if next_variant == nil or next_variant == "default" then
         -- Runs for some stuff without a skin, hopefully fine...
        return old_spellCB(tool, target, pos, caster, ...)
    else
        local fx = SpawnPrefab("explode_reskin")

        local fx_info = reskin_varient_fx_info[target.prefab] or {}

        local scale_override = fx_info.scale or 1
        fx.Transform:SetScale(scale_override, scale_override, scale_override)

        local fx_pos_x, fx_pos_y, fx_pos_z = target.Transform:GetWorldPosition()
        fx_pos_y = fx_pos_y + (fx_info.offset or 0)
        fx.Transform:SetPosition(fx_pos_x, fx_pos_y, fx_pos_z)
    end
end

IAENV.AddPrefabPostInit("reskin_tool", function(inst)
    if TheWorld.ismastersim and inst.components.spellcaster ~= nil then
        if not old_spellCB then
            old_spellCB = inst.components.spellcaster.spell
        end
        inst.components.spellcaster:SetSpellFn(new_spellCB)
        if not old_can_cast_fn then
            old_can_cast_fn = inst.components.spellcaster.can_cast_fn
        end
        inst.components.spellcaster:SetCanCastFn(new_can_cast_fn)
    end
end)
