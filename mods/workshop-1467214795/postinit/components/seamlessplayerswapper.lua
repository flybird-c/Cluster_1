local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local SeamlessPlayerSwapper = require("components/seamlessplayerswapper")

local _OnSeamlessCharacterSwap = SeamlessPlayerSwapper.OnSeamlessCharacterSwap
function SeamlessPlayerSwapper:OnSeamlessCharacterSwap(old_player, ...)
    local new_player = self.inst
    local old_boat = old_player.components.sailor and old_player.components.sailor:GetBoat() or nil
    if old_boat and new_player.components.sailor then
        old_player.components.sailor:Disembark(nil, true, true)
        new_player.components.sailor:Embark(old_boat, true)
    end
    return _OnSeamlessCharacterSwap(self, old_player, ...)
end
