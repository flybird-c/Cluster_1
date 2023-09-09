local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local function FixupWorkerCarry(inst, swap)
    if inst.prefab == "shadowworker" then
		if inst.sg.mem.swaptool == swap then
			return false
		end
		inst.sg.mem.swaptool = swap
		if swap == nil then
            inst.AnimState:ClearOverrideSymbol("swap_object")
            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")
        else
            inst.AnimState:Show("ARM_carry")
            inst.AnimState:Hide("ARM_normal")
            inst.AnimState:OverrideSymbol("swap_object", swap, swap)
        end
		return true
    else
        if swap == nil then -- DEPRECATED workers.
            inst.AnimState:Hide("swap_arm_carry")
        --'else' case cannot exist old workers had one item only assumed.
        end
    end
end

local actionhandler_hack =  ActionHandler(
    ACTIONS.HACK,
	function(inst)
		if FixupWorkerCarry(inst, "swap_machete") then
			return "item_out_chop"
		elseif not inst.sg:HasStateTag("prechop") then
			return inst.sg:HasStateTag("chopping")
				and "chop"
				or "chop_start"
		end
	end
)

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddStategraphActionHandler("shadowmaxwell", actionhandler_hack)