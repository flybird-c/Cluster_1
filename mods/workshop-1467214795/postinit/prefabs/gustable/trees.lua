local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local stagename = {
    "short",
    "normal",
    "tall",
    "old",
}

local function get_wind_anims(inst, type)
    local stage = inst.components.growable.stage or 1
    if type == 1 then
        local anim = math.random(1,2)
        return "blown_loop_".. stagename[stage] .. tostring(anim)
    elseif type == 2 then
        return "blown_pst_" .. stagename[stage]
    elseif type == 3 then
        return "blown_pre_" .. stagename[stage]
    end
    return "idle_" .. stagename[stage]
end

local function postinitfn(inst)
    if TheWorld.ismastersim then
        MakeTreeBlowInWindGust(inst, TUNING.EVERGREEN_WINDBLOWN_SPEED, TUNING.EVERGREEN_WINDBLOWN_FALL_CHANCE)
        inst.WindGetAnims = get_wind_anims
    end
end

IAENV.AddPrefabPostInit("evergreen", postinitfn)
IAENV.AddPrefabPostInit("evergreen_sparse", postinitfn)
IAENV.AddPrefabPostInit("twiggytree", postinitfn)
IAENV.AddPrefabPostInit("deciduoustree", postinitfn)
