local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local WalkablePlatformPlayer = require("components/walkableplatformplayer")

local _StopBoatMusicTest = WalkablePlatformPlayer.StopBoatMusicTest
function WalkablePlatformPlayer:StopBoatMusicTest(...)
    self.inst:PushEvent("stopboatmusic", self.platform)
    return _StopBoatMusicTest(self, ...)
end
