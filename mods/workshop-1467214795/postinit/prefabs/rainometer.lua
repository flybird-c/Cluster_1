local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local _DoCheckRain
local function DoCheckRain(inst, ...)
	local _pop = rawget(TheWorld.state, "pop")
	if inst:HasTag("flooded") then
		TheWorld.state.pop = 1
	elseif IsInIAClimate(inst) then
		TheWorld.state.pop = TheWorld.state.islandpop
	end
	if _DoCheckRain ~= nil then
		_DoCheckRain(inst, ...)
	end
	TheWorld.state.pop = _pop
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("rainometer", function(inst)
	inst:AddComponent("floodable")
	if TheWorld.ismastersim then
		inst.components.floodable:SetFX("shock_machines_fx",5)
		if not _DoCheckRain then
			for i, v in ipairs(inst.event_listening["animover"][inst]) do
				if UpvalueHacker.GetUpvalue(v, "DoCheckRain") then
					_DoCheckRain = UpvalueHacker.GetUpvalue(v, "DoCheckRain")
					UpvalueHacker.SetUpvalue(v, DoCheckRain, "DoCheckRain")
					break
				end
			end
		end
		--reset
		if inst.task ~= nil then
			inst.task:Cancel()
			inst.task = nil
		end
		inst:PushEvent("animover")
	end
end)
