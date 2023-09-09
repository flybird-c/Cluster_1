local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local WorldWind = require("components/worldwind")

local _OnSave = WorldWind.OnSave
function WorldWind:OnSave(...)
    local data, ref = _OnSave and _OnSave(self, ...) or {}, nil
    data.angle = self.angle
    data.timeToWindChange = self.timeToWindChange
    return data, ref
end

local _OnLoad = WorldWind.OnLoad
function WorldWind:OnLoad(data, ...)
    if _OnLoad then _OnLoad(self, data, ...) end
    if data then
        self.angle = data.angle or self.angle
        self.timeToWindChange = data.timeToWindChange or self.timeToWindChange
    end
end

local _OnUpdate = WorldWind.OnUpdate
function WorldWind:OnUpdate(...)
    local dochange =  self.timeToWindChange <= 0
    
    _OnUpdate(self, ...)
    
    if dochange then
        --SW uses 16 segments, every time, which might make this too predictable
        self.timeToWindChange = math.random(4, 16) * TUNING.SEG_TIME
    end
end