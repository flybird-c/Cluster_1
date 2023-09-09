local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

-- Store the globals for optimization
local IA_OCEAN_PREFABS = IA_OCEAN_PREFABS
local DST_OCEAN_PREFABS = DST_OCEAN_PREFABS

local _SpawnPrefab = SpawnPrefab
function SpawnPrefab(name, ...)
    if TheWorld and TheWorld.has_ia_ocean then
        name = IA_OCEAN_PREFABS[name] or name
    else
        name = DST_OCEAN_PREFABS[name] or name
    end
    return _SpawnPrefab(name, ...)
end
-- This is an important function and I dont want to mess with some of its important
-- upvalues so hide our changes
gemrun("hidefn", SpawnPrefab, _SpawnPrefab)