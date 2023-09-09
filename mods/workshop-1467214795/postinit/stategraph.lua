GLOBAL.setfenv(1, GLOBAL)

local SGInstance = StateGraphInstance
local _GoToState = SGInstance.GoToState
SGInstance.GoToState = function(self, statename, params, ...)
    self.nextstate = statename
    _GoToState(self, statename, params, ...)
    self.nextstate = nil
end
