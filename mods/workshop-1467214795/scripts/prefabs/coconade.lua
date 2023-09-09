local assets =
{
    Asset("ANIM", "anim/coconade.zip"),
    Asset("ANIM", "anim/swap_coconade.zip"),

    Asset("ANIM", "anim/coconade_obsidian.zip"),
    Asset("ANIM", "anim/swap_coconade_obsidian.zip"),

    Asset("ANIM", "anim/explode_ring_fx.zip"),
}

local prefabs =
{
    "explode_large",
    "explodering_fx",
    "reticule",
}

local function addfirefx(inst, owner)
    if not inst.fire then
        inst.SoundEmitter:KillSound("hiss")
        inst.SoundEmitter:PlaySound("ia/common/coconade_fuse", "hiss")
        inst.fire = SpawnPrefab("torchfire")
        inst.fire.entity:AddFollower()
    end
    if owner then
        inst.fire.Follower:FollowSymbol(owner.GUID, "swap_object", 40, -140, 1)
    else
        inst.fire.Follower:FollowSymbol(inst.GUID, "swap_flame", 0, 0, 0.1)
    end
end

local function removefirefx(inst)
    if inst.fire then
        inst.SoundEmitter:KillSound("hiss")
        inst.fire:Remove()
        inst.fire = nil
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", inst.swapsymbol, inst.swapbuild)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    if inst.components.burnable:IsBurning() then
        addfirefx(inst, owner)
    end
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_object")
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    removefirefx(inst)
end

local function ondropped(inst)
    if inst.components.burnable:IsBurning() then
        addfirefx(inst)
    end
end

local function onputininventory(inst)
    inst.Physics:SetFriction(.1) --no idea why we are setting friction here, but it does in SW -M
    removefirefx(inst)
    if inst.components.burnable:IsBurning() then
        inst.SoundEmitter:PlaySound("ia/common/coconade_fuse", "hiss")
    end
end

local function onuse(inst)
    -- if inst.fusetask then
        -- removefirefx(inst)
        -- inst.fusetask:Cancel()
        -- inst.fusetask = nil
    -- else
        local owner = inst.components.inventoryitem.owner
        -- if inst.components.burnable:IsBurning() then
            addfirefx(inst, owner)
        -- end
        inst.fusetarget = GetTime() + TUNING.COCONADE_FUSE
        inst.fusetask = inst:DoTaskInTime(TUNING.COCONADE_FUSE, onfuse)
        inst.fusestart:push()
    -- end
    -- inst.components.useableitem.inuse = false
end

--[[
local function updatelight(inst)
    if inst.fire then
        local pos = inst:GetPosition()
        local rad = math.clamp(Lerp(2, 0, pos.y/6), 0, 2)
        local intensity = math.clamp(Lerp(0.8, 0.5, pos.y/7), 0.5, 0.8)
        local fire = inst.fire._light
        fire.Light:SetRadius(rad)
        fire.Light:SetIntensity(intensity)
    end
end

local function onhitground(inst, thrower, target)
    inst.AnimState:PlayAnimation("idle")
    inst.components.floater:UpdateAnimations("idle_water", "idle") --is this needed?
    inst:RemoveTag("NOCLICK")
    inst.components.inventoryitem:OnDropped()
end

local function onthrown(inst)
    inst.Physics:SetFriction(.2)
    inst.Transform:SetFourFaced()
    -- inst:FacePoint(pt:Get())
    inst.AnimState:PlayAnimation("throw", true)
    inst.SoundEmitter:PlaySound("ia/common/coconade_throw")

    inst:AddTag("NOCLICK")
    if inst.fusetask then
        addfirefx(inst)
    end
end]]

local function onthrown(inst, thrower, pt)
    inst.Physics:SetFriction(.2)
    inst.Transform:SetFourFaced()
    inst:FacePoint(pt:Get())
    inst.components.floater:UpdateAnimations("idle_water", "idle")
    --inst:AddTag("NOCLICK")
    inst.AnimState:PlayAnimation("throw", true)
    inst.SoundEmitter:PlaySound("ia/common/coconade_throw")


    inst.LightTask = inst:DoPeriodicTask(FRAMES, function()
        local pos = inst:GetPosition()

        if pos.y <= 0.3 then
            if IsOnOcean(inst) then
				inst.components.floater:PlayWaterAnim()
			else
				inst.components.floater:PlayLandAnim()
			end

            inst:DoTaskInTime(2, function()
                if inst and inst.LightTask then
                    inst.LightTask:Cancel()
                end
            end)
        end

        if inst.fire then
            local rad = math.clamp(Lerp(2, 0, pos.y / 6), 0, 2)
            local intensity = math.clamp(Lerp(0.8, 0.5, pos.y / 7), 0.5, 0.8)
            inst.fire._light.Light:SetRadius(rad)
            inst.fire._light.Light:SetIntensity(intensity)
        end
    end)
end

local function onexplode(inst, scale)
    scale = scale or 1

    local explode = SpawnPrefab("explode_large")
    local ring = SpawnPrefab("explodering_fx")
    local x, y, z = inst.Transform:GetWorldPosition()

    ring.Transform:SetPosition(x, y, z)
    ring.Transform:SetScale(scale, scale, scale)

    explode.Transform:SetPosition(x, y, z)
    explode.Transform:SetScale(scale, scale, scale)
end

local function onexplode_obsid(inst)
    inst.SoundEmitter:PlaySound("ia/common/coconade_obsidian_explode")
    onexplode(inst, 1.3)
end

local function onignite(inst)
    inst.components.fuse:StartFuse()
    if inst.components.equippable:IsEquipped() then
        local owner = inst.components.inventoryitem.owner
        addfirefx(inst, owner)
    elseif not inst.components.inventoryitem:IsHeld() then
        addfirefx(inst)
    end
end

local function OnExtinguished(inst)
	inst.SoundEmitter:KillSound("hiss")
	removefirefx(inst)
	inst.components.fuse:StopFuse()

	if inst.LightTask then
		inst.LightTask:Cancel()
	end
end

local function ondepleted(inst)
    inst.components.explosive:OnBurnt()
end

local function getstatus(inst)
    if inst.components.burnable:IsBurning() then
        return "BURNING"
    end
end

local function onremove(inst)
    inst.SoundEmitter:KillSound("hiss")
    removefirefx(inst)
    if inst.LightTask then
        inst.LightTask:Cancel()
    end
end

local function ReticuleTargetFn()
    local player = ThePlayer
    local map = TheWorld.Map
    local pos = Vector3()
    -- Attack range is 8, leave room for error
    -- Min range was chosen to not hit yourself (2 is the hit range)
    for r = 6.5, 3.5, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if map:IsPassableAtPoint(pos.x, pos.y, pos.z, true) and not map:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function commonfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    inst.Physics:ClearCollidesWith(COLLISION.LIMITS)

    inst:AddTag("thrown")
    inst:AddTag("projectile")
    inst:AddTag("fuse") --UI optimisation
    inst:AddTag("allowinventoryburning")
    inst:AddTag("allow_action_on_impassable")
    inst:AddTag("coconade")
    inst:AddTag("explosive")

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTargetFn
    inst.components.reticule.ease = true

    inst.OnRemoveEntity = onremove

    MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations("idle_water", "idle")

    return inst
end

local function masterfn(inst)
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    MakeHauntableLaunch(inst)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPutInInventoryFn(onputininventory)

    inst:AddComponent("fuse")
    inst.components.fuse:SetFuseTime(TUNING.COCONADE_FUSE)
    inst.components.fuse.onfusedone = ondepleted

    inst:AddComponent("burnable")
    inst.components.burnable.nofx = true
    inst.components.burnable:SetOnIgniteFn(onignite)
    inst.components.burnable:SetOnExtinguishFn(OnExtinguished)
    inst.components.burnable:SetAllowInventoryBurning(true)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    -- consider using complexprojectile instead and dumping "throwable"
    -- action "TOSS" should be already suitable
    inst:AddComponent("throwable")
    inst.components.throwable.onthrown = onthrown

    --[[
    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(12)
    inst.components.complexprojectile:SetGravity(-15)
    inst.components.complexprojectile.usehigharc = false
    inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
    inst.components.complexprojectile:SetOnLaunch(onthrown)
    inst.components.complexprojectile:SetOnHit(onhitground)
    inst.components.complexprojectile:SetOnUpdate(updatelight)]]

    inst:AddComponent("explosive")

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.WRATH_LARGE

    return inst
end

local _OnBurnt
local function OnBurnt(self, ...)
    local owner = self.inst and self.inst.components.inventoryitem and self.inst.components.inventoryitem:GetGrandOwner() or nil
    if owner and owner:HasTag("pocketdimension_container") then
        self.inst:Remove()
        return
    end
    return _OnBurnt(self, ...)
end

local function firefn()
    local inst = commonfn()

    inst.AnimState:SetBank("coconade")
    inst.AnimState:SetBuild("coconade")
    inst.AnimState:PlayAnimation("idle")

    inst.swapsymbol = "swap_coconade"
    inst.swapbuild = "swap_coconade"

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	masterfn(inst)

	inst.components.explosive:SetOnExplodeFn(onexplode)
	inst.components.explosive.explosivedamage = TUNING.COCONADE_DAMAGE
	inst.components.explosive.explosiverange = TUNING.COCONADE_EXPLOSIONRANGE
	inst.components.explosive.buildingdamage = TUNING.COCONADE_BUILDINGDAMAGE

    if not _OnBurnt then
        _OnBurnt = inst.components.explosive.OnBurnt
    end
    inst.components.explosive.OnBurnt = OnBurnt

    return inst
end

local _OnBurnt_obsid
local function OnBurnt_obsid(self, ...)
    local owner = self.inst and self.inst.components.inventoryitem and self.inst.components.inventoryitem:GetGrandOwner() or nil
    if owner and owner:HasTag("pocketdimension_container") then
        self.inst:Remove()
        return
    end
    return _OnBurnt_obsid(self, ...)
end

local function obsidianfn()
    local inst = commonfn()

    inst.AnimState:SetBank("coconade_obsidian")
    inst.AnimState:SetBuild("coconade_obsidian")
    inst.AnimState:PlayAnimation("idle")

    inst.swapsymbol = "swap_coconade_obsidian"
    inst.swapbuild = "swap_coconade_obsidian"

    -- shadowlevel (from shadowlevel component) added to pristine state for optimization
    inst:AddTag("shadowlevel")
    inst:AddTag("obsidiancoconade")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    masterfn(inst)

    inst:AddComponent("shadowlevel")
    inst.components.shadowlevel:SetDefaultLevel(TUNING.OBSIDIANCOCONADE_SHADOW_LEVEL)

	inst.components.explosive:SetOnExplodeFn(onexplode_obsid)
	inst.components.explosive.explosivedamage = TUNING.COCONADE_OBSIDIAN_DAMAGE
	inst.components.explosive.explosiverange = TUNING.COCONADE_OBSIDIAN_EXPLOSIONRANGE
	inst.components.explosive.buildingdamage = TUNING.COCONADE_OBSIDIAN_BUILDINGDAMAGE

    if not _OnBurnt_obsid then
        _OnBurnt_obsid = inst.components.explosive.OnBurnt
    end
    inst.components.explosive.OnBurnt = OnBurnt_obsid

    return inst
end

return Prefab("coconade", firefn, assets, prefabs),
    Prefab("obsidiancoconade", obsidianfn, assets, prefabs)
