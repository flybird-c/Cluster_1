local assets=
{
	Asset("ANIM", "anim/ink_projectile.zip"),
	Asset("ANIM", "anim/ink_puddle.zip"),
}

local function onthrown(inst, thrower, pt, time_to_target)
    inst.Physics:SetFriction(.2)

    -- local shadow = SpawnPrefab("warningshadow")
    -- shadow.Transform:SetPosition(pt:Get())
    -- shadow:shrink(time_to_target, 1.75, 0.5)

	inst.TrackHeight = inst:DoPeriodicTask(FRAMES, function()
		local pos = inst:GetPosition()

		if pos.y <= 1 then
			local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 1.5, nil, inst.noTags)

		    for k,v in pairs(ents) do
	            if v.components.combat and v ~= inst and v.prefab ~= "kraken_tentacle" then
	                v.components.combat:GetAttacked(thrower, TUNING.QUACKEN_INK_DAMAGE)
					if v.components.inkable then
						v.components.inkable:Ink()
					end
				end
		    end

			if IsOnOcean(inst) then
				local splash = SpawnPrefab("kraken_ink_splat")
				splash.Transform:SetPosition(pos.x, pos.y, pos.z)

				inst.SoundEmitter:PlaySound("ia/common/cannon_impact")
				inst.SoundEmitter:PlaySound("ia/creatures/seacreature_movement/splash_large")

				local ink = SpawnPrefab("kraken_inkpatch")
				ink.Transform:SetPosition(pos.x, pos.y, pos.z)
			end

			inst:Remove()
		end
	end)
end

local function onremove(inst)
	if inst.TrackHeight then
		inst.TrackHeight:Cancel()
		inst.TrackHeight = nil
	end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("ink")
	inst.AnimState:SetBuild("ink_projectile")
	inst.AnimState:PlayAnimation("fly_loop", true)

	MakeInventoryPhysics(inst)
	inst.Physics:ClearCollidesWith(COLLISION.LIMITS)

	inst:AddTag("thrown")
	inst:AddTag("projectile")

	inst.noTags = {"FX", "DECOR", "INLIMBO", "shadow"}

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("throwable")
	inst.components.throwable.onthrown = onthrown
	inst.components.throwable.random_angle = 0
	inst.components.throwable.max_y = 100
	inst.components.throwable.yOffset = 7

	inst.OnRemoveEntity = onremove

	inst.persists = false

	return inst
end

local INK_TIME = TUNING.QUACKEN_INK_LINGERTIME

local function UpdateSlowdown(self, slowdowns)
    local inst = self.inst

    inst.ink_timer = inst.ink_timer - self.detectperiod
    inst.ink_scale = Lerp(0, 1, inst.ink_timer/INK_TIME)
    inst.Transform:SetScale(inst.ink_scale, inst.ink_scale, inst.ink_scale)

	if inst.ink_scale <= 0.33 then
		--inst.slowing_player = false
		inst:Remove()
		return
	end

    self.range = inst.ink_scale * 3.66
end

local function CanSlow(self, slowinst, x, y, z, rangesq)
    return slowinst.components.locomotor ~= nil 
        and slowinst.components.locomotor.enablegroundspeedmultiplier 
        and slowinst:GetCurrentPlatform() == nil 
end

local function inkpatch_fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

    inst.AnimState:SetBuild("ink_puddle")
    inst.AnimState:SetBank("ink_puddle")
    inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetSortOrder(ANIM_SORT_ORDER_BELOW_GROUND.UNDERWATER)
	inst.AnimState:SetSortOrder(3)

	inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.ink_timer = INK_TIME
	inst.ink_scale = 1
	inst.Transform:SetScale(inst.ink_scale, inst.ink_scale, inst.ink_scale)

	inst:AddComponent("slowingobject")
    inst.components.slowingobject.key = "QUACKEN_INK"
    inst.components.slowingobject.detectradius = (inst.ink_scale * 3.66) + 15
    inst.components.slowingobject.detectperiod = 3 * FRAMES
    inst.components.slowingobject.delay = 3 * FRAMES
    inst.components.slowingobject.UpdateSlowdown = UpdateSlowdown
    inst.components.slowingobject.CanSlow = CanSlow

	return inst
end

return Prefab("kraken_projectile", fn, assets),
		Prefab("kraken_inkpatch", inkpatch_fn)
