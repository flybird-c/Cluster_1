local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local StartFX_old
local function StartFX(proxy, ...)
	if not ThePlayer or IsInIAClimate(ThePlayer) == IsInIAClimate(proxy) then
		StartFX_old(proxy, ...)
	end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("lightning", function(inst)

for per, _ in pairs(inst.pendingtasks) do
	if per.fn ~= inst.Remove and per.period == 0 then --assume there's only the two vanilla tasks
		StartFX_old = per.fn
		per.fn = StartFX
		break
	end
end


end)