local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local function berry_postinitfn(inst)
	if TheWorld.ismastersim then
		MakePickableBlowInWindGust(inst, TUNING.BERRYBUSH_WINDBLOWN_SPEED, TUNING.BERRYBUSH_WINDBLOWN_FALL_CHANCE)
		inst.components.blowinwindgust:SetGustStartFn(nil) --no animation
	end
end

local function get_wind_anims(inst, type)
	local stage = inst.components.growable.stage or 1
	local state = inst.components.pickable ~= nil and not inst.components.pickable:CanBePicked() and inst.components.pickable:IsBarren() and "dead" or "idle" 
	if type == 1 then
		local anim = math.random(1,2)
		return "blown_loop_"..state..tostring(anim)
	elseif type == 2 then
		return "blown_pst_"..state
	elseif type == 3 then
		return "blown_pre_"..state
	end
	return state == "dead" and "dead" or "idle_big"
end

local function can_play_wind_anim(inst)
	--bananabushes actually have "dead" wind anims -Half
	return inst.components.pickable ~= nil and (inst.components.pickable:CanBePicked() or inst.components.pickable:IsBarren())
end

local function banana_postinitfn(inst)
	if TheWorld.ismastersim then
		MakePickableBlowInWindGust(inst, TUNING.BANANABUSH_WINDBLOWN_SPEED, TUNING.BANANABUSH_WINDBLOWN_FALL_CHANCE)
		inst.WindGetAnims = get_wind_anims
		inst.WindCanAnim = can_play_wind_anim
	end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("berrybush", berry_postinitfn)
IAENV.AddPrefabPostInit("berrybush2", berry_postinitfn)
IAENV.AddPrefabPostInit("bananabush", banana_postinitfn)
