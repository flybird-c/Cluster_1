local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local MakePlayerCharacter = require("prefabs/player_common")

local _DropWetTool, _, RegisterMasterEventListeners = UpvalueHacker.GetUpvalue(MakePlayerCharacter, "RegisterMasterEventListeners", "DropWetTool")
local function DropWetTool(inst, data, ...)
    if IsInIAClimate(inst) then
        local _wetness = rawget(TheWorld.state, "wetness")
        TheWorld.state.wetness = TheWorld.state.islandwetness
        local rets = {_DropWetTool(inst, data, ...)}
        TheWorld.state.wetness = _wetness
        return unpack(rets)
    end
    return _DropWetTool(inst, data, ...)
end
UpvalueHacker.SetUpvalue(RegisterMasterEventListeners, DropWetTool, "DropWetTool")
