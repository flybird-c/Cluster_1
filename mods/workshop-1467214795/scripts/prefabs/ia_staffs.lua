local assets =
{
    Asset("ANIM", "anim/ia_staffs.zip"),
    Asset("ANIM", "anim/swap_ia_staffs.zip"),
}

local prefabs =
{
    wind = {

    },
    volcano = {
        "fire_projectile",
        "dragoonegg_falling"
    },
}

---------COMMON FUNCTIONS---------

local function onfinished(inst)
    if inst.components.spellcaster then
        inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
    end
    inst:Remove()
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function commonfn(colour, tags, hasskin, equipfn, unequipfn, hasshadowlevel)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations(colour .. "staff_water", colour .. "staff")

    inst.AnimState:SetBank("ia_staffs")
    inst.AnimState:SetBuild("ia_staffs")
    inst.AnimState:PlayAnimation(colour.."staff")

    if tags ~= nil then
        for i, v in ipairs(tags) do
            inst:AddTag(v)
        end
    end

    if hasshadowlevel then
        --shadowlevel (from shadowlevel component) added to pristine state for optimization
        inst:AddTag("shadowlevel")
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -------
    inst:AddComponent("inspectable")

    MakeHauntableLaunch(inst)

    inst:AddComponent("inventoryitem")

    inst:AddComponent("tradable")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(function(inst, owner)
        owner.AnimState:OverrideSymbol("swap_object", "swap_ia_staffs", colour .. "staff")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
        if equipfn then
            equipfn(inst, owner)
        end
    end)
    inst.components.equippable:SetOnUnequip(function(inst, owner)
        onunequip(inst, owner)
        if unequipfn then
            unequipfn(inst, owner)
        end
    end)

    if hasshadowlevel then
        inst:AddComponent("shadowlevel")
        inst.components.shadowlevel:SetDefaultLevel(TUNING.STAFF_SHADOW_LEVEL)
    end

    return inst
end

---------VOLCANO STAFF---------

local function createeruption(staff, target, pos)
    local owner = staff.components.inventoryitem:GetGrandOwner() or nil
    if (owner ~= nil and IsInIAClimate(owner)) or (owner == nil and IsInIAClimate(staff)) then
        staff.components.finiteuses:Use(1)

        local delay = 0.0
        for i = 1, TUNING.VOLCANOSTAFF_FIRERAIN_COUNT, 1 do
            local x, y, z = TUNING.VOLCANOSTAFF_FIRERAIN_RADIUS * UnitRand() + pos.x, pos.y,
            TUNING.VOLCANOSTAFF_FIRERAIN_RADIUS * UnitRand() + pos.z
            staff:DoTaskInTime(delay, function(inst)
                local firerain = SpawnPrefab("firerain")
                --local firerain = SpawnPrefab("dragoonegg_falling")
                firerain.Transform:SetPosition(x, y, z)
                firerain:StartStep()
            end)
            delay = delay + TUNING.VOLCANOSTAFF_FIRERAIN_DELAY
        end

        if TheWorld.components.volcanomanager then
            TheWorld.components.volcanomanager:StartStaffEffect(TUNING.VOLCANOSTAFF_ASH_TIMER)
        end
    elseif owner ~= nil then
        --Say something about why the staff doesn't work here.
        owner.components.talker:Say(GetString(owner, "ANNOUNCE_MAGIC_FAIL"))
    end
end

local function OnHaunt(staff)
    if math.random() <= TUNING.HAUNT_CHANCE_RARE then
        local pos = staff:GetPosition()
        pos.x, pos.z = pos.x+math.random(-10, 10), pos.z+math.random(-10, 10)
        createeruption(staff, nil, pos)
        return true
    end
    return false
end

local function volcano()
    local inst = commonfn("meteor", {"nosteal", "nopunch", "allow_action_on_impassable"}, nil, nil, nil, true)

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = function()
        return Vector3(ThePlayer.entity:LocalToWorldSpace(5, 0, 0))
    end
    inst.components.reticule.ease = true

    if not TheWorld.ismastersim then
        return inst
    end

    inst.fxcolour = {223 / 255, 208 / 255, 69 / 255}
    inst.castsound = "dontstarve/common/staffteleport"

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(createeruption)
    inst.components.spellcaster.canuseonpoint = true
    inst.components.spellcaster.canuseonpoint_water = true

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(onfinished)
    inst.components.finiteuses:SetMaxUses(TUNING.VOLCANOSTAFF_USES)
    inst.components.finiteuses:SetUses(TUNING.VOLCANOSTAFF_USES)

    AddHauntableCustomReaction(inst, OnHaunt, true, false, true)
    inst.components.hauntable.hauntvalue = TUNING.HAUNT_LARGE

    return inst
end

---------WIND STAFF---------

local function wind_onunequip(inst, owner)
    if owner.ramp_fn then
        owner:RemoveEventCallback("wind_rampup", owner.ramp_fn, TheWorld)
        owner.ramp_fn = nil
    end
    inst.components.fueled:StopConsuming()
    inst.components.whirlwindadjuster:Stop()
end

local function wind_onequip(inst, owner)
    inst.components.fueled:StartConsuming()

    if TheWorld.state.hurricane and TheWorld.state.gustspeed > .1 and IsInIAClimate(owner) then
        inst.SoundEmitter:PlaySound("ia/common/sail_stick")
    end

    owner.ramp_fn = function()
        inst.SoundEmitter:PlaySound("ia/common/sail_stick")
    end

    owner:ListenForEvent("wind_rampup", owner.ramp_fn, TheWorld)
    inst.components.whirlwindadjuster:Start(owner)
end

local function wind()
    local inst = commonfn("wind", {"nopunch"}, nil, wind_onequip , wind_onunequip, true)

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(TUNING.SAILSTICK_PERISHTIME)
    inst.components.fueled:SetDepletedFn(onfinished)

    inst:AddComponent("whirlwindadjuster")

    return inst
end

return Prefab("volcanostaff", volcano, assets, prefabs.volcano),
        Prefab("windstaff", wind, assets, prefabs.wind)
