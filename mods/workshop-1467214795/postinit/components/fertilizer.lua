local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Fertilizer = require("components/fertilizer")

function Fertilizer:MakeNormal()
    self.inst:RemoveTag("fertilizer_volcanic")
    self.inst:RemoveTag("fertilizer_oceanic")
end

function Fertilizer:MakeVolcanic()
    self.inst:AddTag("fertilizer_volcanic")
    self.inst:RemoveTag("fertilizer_oceanic")
end

function Fertilizer:MakeOceanic()
    self.inst:RemoveTag("fertilizer_volcanic")
    self.inst:AddTag("fertilizer_oceanic")
end