local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local function Pillar_PlayAnimation(inst, anim, loop)
	inst.AnimState:PlayAnimation(anim, loop)
	inst.base.AnimState:PlayAnimation(anim, loop)
end

local function Pillar_PushAnimation(inst, anim, loop)
	inst.AnimState:PushAnimation(anim, loop)
	inst.base.AnimState:PushAnimation(anim, loop)
end

local function AlwaysRecoil(inst, worker, tool, numworks)
	return true, numworks
end

local function UpdateBuild(inst, workleft)
	if math.floor(workleft) <= 1 then
		if inst.level ~= "lowest" then
			local dlevel = (inst.level == "full" and 3) or (inst.level == "med" and 2) or (inst.level == "low" and 1) or 0
			inst.level = "lowest"
			inst.AnimState:OverrideSymbol("pillar_full", "daywalker_pillar", "pillar_lowest")
			inst.base.AnimState:OverrideSymbol("pillar_full", "daywalker_pillar", "pillar_lowest_base")
			if inst.Light ~= nil then
				SetLightColour(inst, 1.3)
			end
			inst.components.workable:SetShouldRecoilFn(AlwaysRecoil)
			return true, dlevel
		end
	elseif workleft <= 4 then
		if inst.level ~= "low" then
			local dlevel = (inst.level == "full" and 2) or (inst.level == "med" and 1) or 0
			inst.level = "low"
			inst.AnimState:OverrideSymbol("pillar_full", "daywalker_pillar", "pillar_low")
			inst.base.AnimState:OverrideSymbol("pillar_full", "daywalker_pillar", "pillar_low_base")
			if inst.Light ~= nil then
				SetLightColour(inst, 1.2)
			end
			inst.components.workable:SetShouldRecoilFn(nil)
			return true, dlevel
		end
	elseif workleft <= 7 then
		if inst.level ~= "med" then
			local dlevel = inst.level == "full" and 1 or 0
			inst.level = "med"
			inst.AnimState:OverrideSymbol("pillar_full", "daywalker_pillar", "pillar_med")
			inst.base.AnimState:OverrideSymbol("pillar_full", "daywalker_pillar", "pillar_med_base")
			if inst.Light ~= nil then
				SetLightColour(inst, 1.1)
			end
			inst.components.workable:SetShouldRecoilFn(nil)
			return true, dlevel
		end
	end
	return false, 0
end

local function SpawnDebris(inst, anim, layer)
	local fx = CreateEntity()

	fx:AddTag("FX")
	fx:AddTag("NOCLICK")
	--[[Non-networked entity]]
	fx.entity:SetCanSleep(false)
	fx.persists = false

	fx.entity:AddTransform()
	fx.entity:AddAnimState()
	fx.entity:AddSoundEmitter()

	fx.AnimState:SetBank("daywalker_pillar")
	fx.AnimState:SetBuild("daywalker_pillar")
	fx.AnimState:PlayAnimation(anim)
	fx.AnimState:SetFinalOffset(layer)

	fx:ListenForEvent("animover", fx.Remove)

	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())

	return fx
end

local function OnDebrisDirty(inst)
	if inst.debris:value() == 0 then
		local rnd = math.random(2)
		SpawnDebris(inst, "debris_small_"..(rnd == 1 and "a" or "b"), -1)
		inst:DoTaskInTime((2 + math.random(3)) * FRAMES, SpawnDebris, "debris_small_"..(rnd == 2 and "a" or "b"), -1)
	else
		local anim =
			(inst.debris:value() == 1 and "debris_low") or
			(inst.debris:value() == 2 and "debris_med") or
			nil

		if anim ~= nil then
			SpawnDebris(inst, anim, 1).SoundEmitter:PlaySound("daywalker/pillar/hit")
		end
	end
end

local function OnEndVibrate(inst)
	inst.vibrate_task = nil
	local daywalker = inst.prisoner:value()
	if daywalker ~= nil and daywalker.CountPillars ~= nil then
		local resonating, idle = daywalker:CountPillars()
		if resonating ~= 0 and idle == 0 then
			--All resonating!
			return
		end
	end
	Pillar_PlayAnimation(inst, "idle")
	inst.SoundEmitter:KillSound("vibrate_loop")
	inst.SoundEmitter:KillSound("chain_vibrate_loop")
end

local _OnWorked

local function OnWorked(inst, worker, workleft, numworks, ...)
	if worker:HasTag("obsidiancoconade") then
		Pillar_PlayAnimation(inst, "hit")
		Pillar_PushAnimation(inst, "idle")
		if workleft < 1 then
			workleft = 1
			inst.components.workable:SetWorkLeft(1)
		end
		local changed, dlevel = UpdateBuild(inst, workleft)
		if changed then
			for i = 1, dlevel do
				inst.components.lootdropper:SpawnLootPrefab("marble")
			end
			inst.debris:set(inst.level == "med" and 2 or 1)
		else
			inst.debris:set(0)
		end
		--Dedicated server does not need to spawn the local fx
		if not (TheNet:IsDedicated() or inst:IsAsleep()) then
			OnDebrisDirty(inst)
		end
		inst.SoundEmitter:KillSound("vibrate_loop")
		inst.SoundEmitter:KillSound("chain_vibrate_loop")
		if workleft <= 1 then
			inst.SoundEmitter:PlaySound("daywalker/pillar/pickaxe_hit_unbreakable")
			local prisoner = inst.prisoner:value()
			if prisoner ~= nil then
				Pillar_PlayAnimation(inst, "pillar_shake", true)
				local num = 1
				if prisoner.CountPillars ~= nil then
					num = prisoner:CountPillars()
				end
				inst.SoundEmitter:PlaySound("daywalker/pillar/chain_rattle_"..tostring(math.min(3, num)), "vibrate_loop")
				inst.SoundEmitter:PlaySound("daywalker/pillar/chain_shake_lp", "chain_vibrate_loop")
				if inst.vibrate_task ~= nil then
					inst.vibrate_task:Cancel()
				end
				inst.vibrate_task = inst:DoTaskInTime(6, OnEndVibrate)
				inst.restartvibrate:push()
	
				prisoner:PushEvent("pillarvibrating")
			end
		end
	else
        _OnWorked(inst, worker, workleft, numworks, ...)
    end
end

IAENV.AddPrefabPostInit("daywalker_pillar", function(inst)


	if inst.components.workable then
		if inst.components.workable.onwork then
			if _OnWorked == nil then
				_OnWorked = inst.components.workable.onwork
			end
		end
		inst.components.workable.onwork = OnWorked
	end


end)