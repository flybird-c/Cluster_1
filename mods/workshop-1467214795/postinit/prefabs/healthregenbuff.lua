local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local onextendedfn_old
local function onextendedfn(inst, ...)
	onextendedfn_old(inst, ...)
	inst.components.timer:SetTimeLeft("regenover", inst.components.timer:GetTimeLeft("regenover") + TUNING.JELLYBEAN_DURATION * TUNING.WARLY_IA_GOURMET_BONUS)
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("healthregenbuff", function(inst)
	if TheWorld.ismastersim then
		if GetTime() > 0 and inst.components.timer:GetTimeLeft("regenover") == TUNING.JELLYBEAN_DURATION then
			--just spawned, not loaded
			inst.components.timer:SetTimeLeft("regenover", TUNING.JELLYBEAN_DURATION * (1 + TUNING.WARLY_IA_GOURMET_BONUS))
		end
		
		onextendedfn_old = inst.components.debuff.onextendedfn
		inst.components.debuff.onextendedfn = onextendedfn
		
	end
end)
