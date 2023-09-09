local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local ScreenFlash_old
local function ScreenFlash(self, ...)
	--for some reason, this thing runs on dedicated too -M
	if not ThePlayer or IsInIAClimate(ThePlayer) == (self._islandthunder:value() or false) then
		ScreenFlash_old(self, ...)
	end
end

local OnRandDirty_old
local function OnRandDirty(self, ...)
	if ThePlayer and IsInIAClimate(ThePlayer) == (self._islandthunder:value() or false) then
		OnRandDirty_old(self, ...)
	end
end


----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("thunder_close", function(inst)


inst._islandthunder = net_bool(inst.GUID, "thunder_close._islandthunder")

for per, _ in pairs(inst.pendingtasks) do
	if per.fn ~= inst.Remove and per.period == 0 then --assume there's only the three vanilla tasks
		ScreenFlash_old = per.fn
		per.fn = ScreenFlash
		break
	end
end
		
if inst.event_listeners and inst.event_listeners.randdirty and inst.event_listeners.randdirty[inst] then
	OnRandDirty_old = inst.event_listeners.randdirty[inst][1]
	inst.event_listeners.randdirty[inst][1] = OnRandDirty
end


end)