local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local MermKingManager = require("components/mermkingmanager")

local MERMCANDIDATE_CANT_TAGS = UpvalueHacker.GetUpvalue(MermKingManager.FindMermCandidate, "MERMCANDIDATE_CANT_TAGS")

table.insert(MERMCANDIDATE_CANT_TAGS, "mermfisher") -- PAIIIIIIN