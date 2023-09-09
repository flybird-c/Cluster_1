local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local function Mighty_Multi(inst, data)
    if data.state == "mighty" then
        inst.components.workmultiplier:AddMultiplier(ACTIONS.HACK,   TUNING.MIGHTY_WORK_EFFECTIVENESS, inst)
        inst.components.efficientuser:AddMultiplier(ACTIONS.HACK,    TUNING.MIGHTY_WORK_EFFECTIVENESS, inst)
    else
        inst.components.workmultiplier:RemoveMultiplier(ACTIONS.HACK,   inst)
        inst.components.efficientuser:RemoveMultiplier(ACTIONS.HACK,  inst)
    end
end

local function OnDoingHack(inst, data)
    if data ~= nil and data.hack_target ~= nil then
		local hackable = data.hack_target.components.hackable
		if hackable ~= nil then
			if inst.components.mightiness:IsMighty() then
				if hackable.hacksleft > 0 and math.random() >= TUNING.MIGHTY_WORK_CHANCE then
					hackable.hacksleft = 0
				end
			end
			local gains = TUNING.WOLFGANG_MIGHTINESS_WORK_GAIN["HACK"]
			if gains ~= nil then
				inst.components.mightiness:DoDelta(gains)	
			end
		end
    end
end

IAENV.AddPrefabPostInit("wolfgang", function(inst)
    inst:ListenForEvent("mightiness_statechange",  Mighty_Multi)
    inst:ListenForEvent("working", OnDoingHack)
end)
