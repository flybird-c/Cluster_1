local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Perishable = require("components/perishable")

local _Update, _fn_i, scope_fn
for i, v in ipairs({"LongUpdate", "StartPerishing"}) do
    _Update, _fn_i, scope_fn = UpvalueHacker.GetUpvalue(Perishable[v], "Update")
    if _Update then break end
end
local function Update(self, ...)
    local _temperature = rawget(TheWorld.state, "temperature")
    if self.inst and self.inst:IsValid() and IsInIAClimate(self.inst) then
        TheWorld.state.temperature = TheWorld.state.islandtemperature
    else
        TheWorld.state.temperature = TheWorld.state.temperature
    end
   _Update(self, ...)
   TheWorld.state.temperature = _temperature
end
debug.setupvalue(scope_fn, _fn_i, Update)