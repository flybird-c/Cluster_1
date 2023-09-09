local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Dryer = require("components/dryer")

local function OnIsRaining(israining)
    if israining then
        self:Pause()
    else
        self:Resume()
    end
end

local _StartDrying = Dryer.StartDrying
function Dryer:StartDrying(...)
	local ret = _StartDrying(self, ...)

    if not self.task and IsInIAClimate(self.inst) and not (TheWorld.state.islandisraining or self.protectedfromrain) then
        self:Resume()
    end

	return ret
end

local _LongUpdate = Dryer.LongUpdate
function Dryer:LongUpdate(...)
	local ret = _LongUpdate(self, ...)

    if self:IsDrying() and not self.task
	and IsInIAClimate(self.inst) and not (TheWorld.state.islandisraining or self.protectedfromrain) then
		self:Resume()
	end

	return ret
end

local _OnLoad = Dryer.OnLoad
function Dryer:OnLoad(...)
	local ret = _OnLoad(self, ...)

    if self:IsDrying() and not self.task
	and IsInIAClimate(self.inst) and not (TheWorld.state.islandisraining or self.protectedfromrain) then
		self:Resume()
	end

	return ret
end


local _fn_i, scope_fn

local _StartWatchingRain
for i, v in ipairs({"LongUpdate", "OnLoad"}) do
    _StartWatchingRain, _fn_i, scope_fn = UpvalueHacker.GetUpvalue(Dryer[v], "StartWatchingRain")
    if _StartWatchingRain then
        debug.setupvalue(scope_fn, _fn_i, function(self, ...)
            if IsInIAClimate(self.inst) then
                if not self.watchingrain then
                    self.watchingrain = true
                    self:WatchWorldState("islandisraining", OnIsRaining)
                end
            else
                return _StartWatchingRain(self, ...)
            end
        end)
        break
    end
end

local _StopWatchingRain
for i, v in ipairs({"OnRemoveFromEntity", "OnLoad", "StartDrying", "StopDrying", "DropItem", "Harvest"}) do
    _StopWatchingRain, _fn_i, scope_fn = UpvalueHacker.GetUpvalue(Dryer[v], "StopWatchingRain")
    if _StopWatchingRain then
        debug.setupvalue(scope_fn, _fn_i, function(self, ...)
            self:StopWatchingWorldState("islandisraining", OnIsRaining)
            return _StopWatchingRain(self, ...)
        end)
        break
    end
end
