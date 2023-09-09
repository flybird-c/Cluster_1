local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local ex_fns = require("prefabs/player_common_extensions")

-- Note: This does not apply to any upvalues within player_common_extensions
local _ConfigurePlayerLocomotor = ex_fns.ConfigurePlayerLocomotor
function ex_fns.ConfigurePlayerLocomotor(inst, ...)
    _ConfigurePlayerLocomotor(inst, ...)
    if inst:IsSailing() and not inst.components.locomotor:IsAmphibious() then
        inst.components.locomotor.pathcaps = inst.components.locomotor.pathcaps or {}
        inst.components.locomotor.pathcaps.ignoreLand = true
        inst.components.locomotor.pathcaps.allowocean = true
    end
end

-- Rip I cant fix this without using the upvalue hacker...
-- local _ConfigureGhostLocomotor = ex_fns.ConfigureGhostLocomotor
-- function ex_fns.ConfigureGhostLocomotor(inst, ...)
--     _ConfigureGhostLocomotor(inst, ...)
--     inst.components.locomotor.pathcaps = inst.components.locomotor.pathcaps or {}
--     inst.components.locomotor.pathcaps.allowocean = true
-- end