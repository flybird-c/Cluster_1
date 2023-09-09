local assets=
{
    Asset("ANIM", "anim/coconade.zip"),
    Asset("ANIM", "anim/swap_coconade.zip"),
}

local prefabs =
{
    "impact",
    "explode_small",
    "bombsplash",
}

local function addfirefx(inst, owner)
    if not inst.fire then
        inst.SoundEmitter:KillSound("hiss")
        inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
        inst.fire = SpawnPrefab("torchfire")
        local follower = inst.fire.entity:AddFollower()
        if owner then
            follower:FollowSymbol(owner.GUID, "swap_object", 40, -140, 1 )
        else
            follower:FollowSymbol(inst.GUID, "swap_flame", 0, 0, 0.1 )
        end
    end
end

local function removefirefx(inst)
    if inst.fire then
        inst.fire:Remove()
        inst.fire = nil
    end
end

local function LightTaskFn(inst)
	local pos = inst:GetPosition()

	if pos.y <= 0.3 then
		inst.components.explosive:OnBurnt()
	end

	if inst.fire then
		local rad = math.clamp(Lerp(2, 0, pos.y/6), 0, 2)
		local intensity = math.clamp(Lerp(0.8, 0.5, pos.y/7), 0.5, 0.8)
		local fire = inst.fire._light
		fire.Light:SetRadius(rad)
		fire.Light:SetIntensity(intensity)
	end
end

local function onthrown(inst, thrower, pt)
    inst.components.burnable:Ignite()
    inst.Physics:SetFriction(.2)
    inst.Transform:SetFourFaced()
    inst:FacePoint(pt:Get())
    inst.AnimState:PlayAnimation("throw", true)

    inst.SoundEmitter:PlaySound("ia/common/cannon_fire")

    local smoke = SpawnPrefab("collapse_small")

    local x, y, z = inst.Transform:GetWorldPosition()
    y = y + 1

    if thrower and thrower.visual then
        smoke.Transform:SetPosition(thrower.visual.AnimState:GetSymbolPosition("swap_lantern", 0, 0, 0))
    else
        smoke.Transform:SetPosition(x, y, z)
    end

    inst.LightTask = inst:DoPeriodicTask(FRAMES, LightTaskFn)
end

local function onexplode(inst)
    local pos = inst:GetPosition()

    inst.SoundEmitter:PlaySound("ia/common/cannon_hit")
    if IsOnOcean(inst) then
        SpawnWaves(inst, 6, 360, 5)
        local splash = SpawnPrefab("bombsplash")
        splash.Transform:SetPosition(pos.x, pos.y, pos.z)

        inst.SoundEmitter:PlaySound("ia/common/cannon_impact")
        inst.SoundEmitter:PlaySound("ia/common/volcano/rock_splash")

    else
        local explode = SpawnPrefab("explode_small")
        explode.Transform:SetPosition(pos.x, pos.y, pos.z)
    end
end

local function onremove(inst)
    inst.SoundEmitter:KillSound("hiss")
    removefirefx(inst)
    if inst.LightTask then
        inst.LightTask:Cancel()
    end
end

local function onignite(inst)
    addfirefx(inst)
end

local function fn(CANNON_DAMAGE)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("coconade")
    inst.AnimState:SetBuild("coconade")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("thrown")
    inst:AddTag("projectile")
    inst:AddTag("NOCLICK")
    inst:AddTag("explosive")

	--This used to be floatable for some obscure reason. It isn't even an inventory item! -M

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    MakeInventoryPhysics(inst)
    inst.Physics:ClearCollidesWith(COLLISION.LIMITS)

    inst:AddComponent("throwable")
    inst.components.throwable.onthrown = onthrown
    inst.components.throwable.maxdistance = 20

    inst:AddComponent("explosive")
    inst.components.explosive:SetOnExplodeFn(onexplode)
    inst.components.explosive.explosivedamage = CANNON_DAMAGE
    inst.components.explosive.explosiverange = TUNING.BOATCANNON_RADIUS
    inst.components.explosive.buildingdamage = TUNING.BOATCANNON_BUILDINGDAMAGE

    inst:AddComponent("burnable")
    inst.components.burnable.onignite = onignite
    inst.components.burnable.nofx = true

    inst.persists = false
    inst.OnRemoveEntity = onremove

    return inst
end

return Prefab("cannonshot", function() return fn(TUNING.BOATCANNON_DAMAGE) end, assets, prefabs),
    Prefab("woodlegs_cannonshot", function() return fn(TUNING.WOODLEGS_BOATCANNON_DAMAGE) end, assets, prefabs)
