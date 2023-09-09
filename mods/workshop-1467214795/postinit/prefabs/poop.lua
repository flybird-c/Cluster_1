local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_poop", "swap_poop")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function SetStunState(target)
	if target and target:IsValid() and target.sg then
		target.sg:GoToState("stunned")
	end
end

local function onthrown(inst, thrower, pt)
    inst.AnimState:SetBank("monkey_projectile")
    inst.AnimState:SetBuild("monkey_projectile")
    inst.AnimState:PlayAnimation("idle", true)

    -- Make sure it never floats, it will get deleted on landing anyway
    if inst.components.inventoryitem then
        inst.components.inventoryitem:ForceLanded(false, false)
    end

    inst.Physics:SetFriction(.2)

    inst.GroundTask = inst:DoPeriodicTask(FRAMES, function()
        local pos = inst:GetPosition()
        if pos.y <= 0.5 then
            local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 1.5, nil, {"FX", "NOCLICK", "DECOR", "INLIMBO"})

            for k,v in pairs(ents) do
                if v:IsValid() and (not v:HasTag("player") or TheNet:GetPVPEnabled()) then
                    if v.components.combat then
                        v.components.combat:GetAttacked(thrower, TUNING.POOP_THROWN_DAMAGE / (inst:HasTag("slingshotammo") and 2 or 1))
                    end
                    if v and v:HasTag("bird") and v.sg and v.sg:HasState("stunned") then --ds to dst changes
                        v:DoTaskInTime(.4, SetStunState)
                    end

                    if v:HasTag("player") and not v:HasTag("monkey") and v.components.sanity ~= nil and not v.components.sanity.only_magic_dapperness then --for pvp
                        v.components.sanity:DoDelta(-TUNING.POOP_THROWN_SANITY)
                    end
                end
            end

            local x, y, z = inst.Transform:GetWorldPosition()
            local splat = SpawnPrefab(IsOnOcean(x, y, z) and "splash_water_sink" or "poop_splat")
            splat.Transform:SetPosition(x, y, z)

            inst:Remove()
        end
    end)
end

local function targetfn()
    return inst.components.throwable:GetThrowPoint()
end

local function poopfn(inst)
    if TheWorld.ismastersim then
        inst:AddComponent("equippable")
        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)
        inst.components.equippable.equipstack = true
        inst.components.equippable.restrictedtag = "poopthrower"

        inst:AddComponent("throwable")
        inst.components.throwable.onthrown = onthrown

        inst:AddComponent("reticule")
        inst.components.reticule.targetfn = targetfn
        inst.components.reticule.ease = true
    end
end

IAENV.AddPrefabPostInit("poop", poopfn)
IAENV.AddPrefabPostInit("slingshotammo_poop", poopfn)
