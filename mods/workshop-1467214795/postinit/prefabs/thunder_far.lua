local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local PlayThunderSound_old
local function PlayThunderSound(self, ...)
	if ThePlayer and IsInIAClimate(ThePlayer) == (self._islandthunder:value() or false) then
		PlayThunderSound_old(self, ...)
	end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("thunder_far", function(inst)


inst._islandthunder = net_bool(inst.GUID, "thunder_close._islandthunder")
    for per, _ in pairs(inst.pendingtasks) do
        if per.fn ~= inst.Remove and per.period == 0 then --assume there's only the two vanilla tasks
            PlayThunderSound_old = per.fn
            per.fn = PlayThunderSound
            break
        end
    end
end)