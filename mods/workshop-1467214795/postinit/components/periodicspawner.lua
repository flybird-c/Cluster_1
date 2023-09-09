local IAENV = env
GLOBAL.setfenv(1, GLOBAL)
----------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local PeriodicSpawner = require("components/periodicspawner")

function PeriodicSpawner:SetNotFloatsam(val)
    -- Should be used for prefabs that should'nt be deleated after a set time if not touched
    -- For example aquatic herds
    self.notfloatsam = val
end

local _TrySpawn = PeriodicSpawner.TrySpawn
function PeriodicSpawner:TrySpawn(...)
    local world = TheWorld
    local _flotsamgenerator = nil
    if self.notfloatsam then
        _flotsamgenerator = world.components.flotsamgenerator
        world.components.flotsamgenerator = nil
    end
    local rets = {_TrySpawn(self, ...)}
    if _flotsamgenerator then
        world.components.flotsamgenerator = _flotsamgenerator
    end
    return unpack(rets)
end
