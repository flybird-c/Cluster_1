local function MakeHat(name)
    local fname = "hat_" .. name
    local symname = name .. "hat"
    local prefabname = symname

    local function generic_perish(inst)
        inst:Remove()
    end

    -- do not pass this function to equippable:SetOnEquip as it has different a parameter listing
    local function _onequip(inst, owner, symbol_override)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("equipskinneditem", inst:GetSkinName())
            owner.AnimState:OverrideItemSkinSymbol("swap_hat", skin_build, symbol_override or "swap_hat", inst.GUID, fname)
        else
            owner.AnimState:OverrideSymbol("swap_hat", fname, symbol_override or "swap_hat")
        end
        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAIR_HAT")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAT")
            owner.AnimState:Show("HEAD_HAT_NOHELM")
			owner.AnimState:Hide("HEAD_HAT_HELM")
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
        end

        if owner.components.sailor then
            if inst.onmountboat then
                if owner.components.sailor:IsSailing() then
                    inst.onmountboat(owner, {
                        target = owner.components.sailor:GetBoat()
                    })
                end
                inst:ListenForEvent("embarkboat", inst.onmountboat, owner)
            end
            if inst.ondismountboat then
                inst:ListenForEvent("disembarkboat", inst.ondismountboat, owner)
            end
        end
    end

    local function _onunequip(inst, owner)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("unequipskinneditem", inst:GetSkinName())
        end

        owner.AnimState:ClearOverrideSymbol("swap_hat")
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAT")
            owner.AnimState:Hide("HEAD_HAT_NOHELM")
			owner.AnimState:Hide("HEAD_HAT_HELM")
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()
        end

        if owner.components.sailor then
            if inst.onmountboat then
                inst:RemoveEventCallback("embarkboat", inst.onmountboat, owner)
            end
            if inst.ondismountboat then
                if owner.components.sailor:IsSailing() then
                    inst.ondismountboat(owner, {
                        target = owner.components.sailor:GetBoat()
                    })
                end
                inst:RemoveEventCallback("disembarkboat", inst.ondismountboat, owner)
            end
        end
    end

    local function simple_onequip(inst, owner, from_ground)
        _onequip(inst, owner)
    end

    local function simple_onunequip(inst, owner, from_ground)
        _onunequip(inst, owner)
    end

    local function simple_onequiptomodel(inst, owner, from_ground)
        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()
        end
    end

    local function opentop_onequip(inst, owner)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("equipskinneditem", inst:GetSkinName())
            owner.AnimState:OverrideItemSkinSymbol("swap_hat", skin_build, "swap_hat", inst.GUID, fname)
        else
            owner.AnimState:OverrideSymbol("swap_hat", fname, "swap_hat")
        end

        owner.AnimState:Show("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")

        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
        end

        if owner.components.sailor then
            if inst.onmountboat then
                if owner.components.sailor:IsSailing() then
                    inst.onmountboat(owner, {
                        target = owner.components.sailor:GetBoat()
                    })
                end
                inst:ListenForEvent("embarkboat", inst.onmountboat, owner)
            end
            if inst.ondismountboat then
                inst:ListenForEvent("disembarkboat", inst.ondismountboat, owner)
            end
        end
    end

    local function simple_common(custom_init)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        -- exception for double_umbrella
        inst.AnimState:SetBank(symname == "double_umbrellahat" and "hat_double_umbrella" or symname)
        inst.AnimState:SetBuild(fname)
        inst.AnimState:PlayAnimation("anim")

        inst:AddTag("hat")

        if custom_init ~= nil then
            custom_init(inst)
        end

        MakeInventoryFloatable(inst)
        inst.components.floater:UpdateAnimations("idle_water", "anim")

        return inst
    end

    local function simple_master(inst)
        inst:AddComponent("inventoryitem")
        inst:AddComponent("inspectable")

        inst:AddComponent("tradable")

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
        inst.components.equippable:SetOnEquip(simple_onequip)
        inst.components.equippable:SetOnUnequip(simple_onunequip)
        inst.components.equippable:SetOnEquipToModel(simple_onequiptomodel)

        MakeHauntableLaunch(inst)
    end

    --------

    local function woodlegs_spawntreasure(new_sec, old_sec, inst, doer)
        if new_sec >= old_sec then
            return
        end

        inst.components.luckytreasurefinder:FindTreasure()
        inst.components.luckytreasurefinder:RevealTreasures()
    end

    local function woodlegs_onequip(inst, data)
        inst.components.luckytreasurefinder:Start(data.owner)
    end

    local function woodlegs_unequip(inst)
        inst.components.luckytreasurefinder:Stop()
    end

    local function woodlegs()
        local inst = simple_common()

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        simple_master(inst)

        inst:AddComponent("luckytreasurefinder")

        inst:ListenForEvent("equipped", woodlegs_onequip)

        inst:ListenForEvent("unequipped", woodlegs_unequip)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.WOODLEGSHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(generic_perish)
        inst.components.fueled:SetSections(TUNING.WOODLEGSHAT_TREASURES)
        -- DST doesnt have onload for the sectioncallback so just delay this by a tick
        inst:DoTaskInTime(0, function(_inst)
            if _inst and _inst.components and _inst.components.fueled then
                _inst.components.fueled:SetSectionCallback(woodlegs_spawntreasure)
            end
        end)

        return inst
    end

    --------

    local function ox()
        local inst = simple_common()

        -- waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        simple_master(inst)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALLMED)

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_OXHAT, TUNING.ARMOR_OXHAT_ABSORPTION)

        inst.components.equippable.poisonblocker = true

        return inst
    end

    --------

    local function shark_teeth()
        local inst = simple_common()

        inst.AnimState:SetBank("hat_shark_teeth")
        -- inst.AnimState:SetBuild("hat_shark_teeth")
        -- inst.AnimState:PlayAnimation("anim")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        simple_master(inst)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.SHARK_HAT_PERISHTIME)
        inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
        inst.components.fueled:SetDepletedFn(generic_perish)

        inst.components.equippable:SetOnEquip(opentop_onequip)
        -- inst.components.equippable:SetOnUnequip(shark_teeth_onunequip)

        inst.onmountboat = function(player, data)
            inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE
        end
        inst.ondismountboat = function(player, data)
            inst.components.equippable.dapperness = 0
        end

        -- inst:DoTaskInTime(0.1,function()
        -- local owner = inst.components.inventoryitem.owner
        -- if owner and owner.components.sailor and owner.components.sailor:IsSailing() then
        -- inst.onmountboat(inst)
        -- end
        -- end)

        return inst
    end

    --------

    local function captain()
        local inst = simple_common()

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        simple_master(inst)

        -- inst.components.equippable:SetOnEquip(captain_onequip)
        -- inst.components.equippable:SetOnUnequip(captain_onunequip)
        -- inst.durabilitymultiplier = 2

        inst.onmountboat = function(player, data)
            -- if data and data.target and data.target.components.boathealth then
            -- data.target.components.boathealth.depletionmultiplier =
            -- data.target.components.boathealth.depletionmultiplier * TUNING.CAPTAINHAT_DEPLETION_MULT
            -- end
            if player and player.components.sailor then
                player.components.sailor.durabilitymultiplier =
                    player.components.sailor.durabilitymultiplier / TUNING.CAPTAINHAT_DEPLETION_MULT
            end
        end
        inst.ondismountboat = function(player, data)
            -- if data and data.target and data.target.components.boathealth then
            -- data.target.components.boathealth.depletionmultiplier =
            -- data.target.components.boathealth.depletionmultiplier / TUNING.CAPTAINHAT_DEPLETION_MULT
            -- end
            if player and player.components.sailor then
                player.components.sailor.durabilitymultiplier =
                    player.components.sailor.durabilitymultiplier * TUNING.CAPTAINHAT_DEPLETION_MULT
            end
        end

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.CAPTAINHAT_PERISHTIME)
        inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
        inst.components.fueled:SetDepletedFn(generic_perish)

        return inst
    end

    --------

    local function double_umbrella_onequip(inst, owner)
        opentop_onequip(inst, owner)

        owner.DynamicShadow:SetSize(2.2, 1.4)
    end

    local function double_umbrella_onunequip(inst, owner)
        _onunequip(inst, owner)

        owner.DynamicShadow:SetSize(1.3, 0.6)
    end

    local function double_umbrella_perish(inst)
        if inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
            local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
            if owner ~= nil then
                owner.DynamicShadow:SetSize(1.3, 0.6)
                local data = {
                    prefab = inst.prefab,
                    equipslot = inst.components.equippable.equipslot
                }
                inst:Remove() -- generic_perish(inst)
                owner:PushEvent("umbrellaranout", data)
                return
            end
        end
        inst:Remove() -- generic_perish(inst)
    end

    local function double_umbrella()
        local inst = simple_common()

        inst:AddTag("umbrella")

        -- waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        simple_master(inst)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.DOUBLE_UMBRELLA_PERISHTIME)
        inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
        inst.components.fueled:SetDepletedFn(double_umbrella_perish)

        inst.components.equippable:SetOnEquip(double_umbrella_onequip)
        inst.components.equippable:SetOnUnequip(double_umbrella_onunequip)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_ABSOLUTE)

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE)
        inst.components.insulator:SetSummer()

        inst.components.equippable.insulated = true

        return inst
    end

    --------

    local function aerodynamic()
        local inst = simple_common()

        inst.AnimState:SetBank("hat_aerodynamic")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        simple_master(inst)

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
        inst.components.equippable.walkspeedmult = TUNING.AERODYNAMICHAT_SPEED_MULT

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.AERODYNAMICHAT_PERISHTIME)
        inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
        inst.components.fueled:SetDepletedFn(generic_perish)

        inst:AddComponent("windproofer")
        inst.components.windproofer:SetEffectiveness(TUNING.WINDPROOFNESS_MED)

        return inst
    end

    --------

    local function gas()
        local inst = simple_common()

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        simple_master(inst)

        inst.components.equippable.poisongasblocker = true

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.GASHAT_PERISHTIME)
        inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
        inst.components.fueled:SetDepletedFn(generic_perish)

        return inst
    end

    --------

    local function snakeskin()
        local inst = simple_common()

        -- waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        simple_master(inst)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.SNAKESKINHAT_PERISHTIME)
        inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
        inst.components.fueled:SetDepletedFn(generic_perish)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_LARGE)

        inst.components.equippable.insulated = true

        return inst
    end

    --------

    local function pirate()
        local inst = simple_common()

        -- waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        simple_master(inst)

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = "USAGE"
        inst.components.fueled:InitializeFuelLevel(TUNING.PIRATEHAT_PERISHTIME)
        inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
        inst.components.fueled:SetDepletedFn(generic_perish)

        inst.onmountboat = function(player, data)
            if not player.mapexplorerbonus then
                -- Increases map exploration radius
                local radius = TUNING.MAPREVEAL_PIRATEHAT_BONUS
                local intervals = 25
                local theta = 0
                player.mapexplorerbonus = player:DoPeriodicTask(0.2, function()
                    local pt = Vector3(player.Transform:GetWorldPosition())
                    local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
                    theta = theta + (2 * PI / intervals)
                    if player.player_classified ~= nil then
                        player.player_classified.MapExplorer:RevealArea((pt + offset):Get())
                        player.player_classified.MapExplorer:RevealArea((pt - offset):Get())
                    end
                end)
            end
        end
        inst.ondismountboat = function(player, data)
            if player.mapexplorerbonus then
                player.mapexplorerbonus:Cancel()
                player.mapexplorerbonus = nil
            end
        end

        return inst
    end

    -------

    local function brainjelly_onequip(inst, owner)
        _onequip(inst, owner)
        if owner.components.builder then
            owner.components.builder.jellybrainhat = true
            owner:PushEvent("unlockrecipe")
            inst.brainjelly_onbuild = function()
                inst.components.finiteuses:Use(1)
            end
            owner:ListenForEvent("builditem", inst.brainjelly_onbuild)
            owner:ListenForEvent("bufferbuild", inst.brainjelly_onbuild)
        end
    end

    local function brainjelly_onunequip(inst, owner)
        _onunequip(inst, owner)
        if owner.components.builder then
            owner.components.builder.jellybrainhat = false
            owner:PushEvent("unlockrecipe")
            owner:RemoveEventCallback("builditem", inst.brainjelly_onbuild)
            owner:RemoveEventCallback("bufferbuild", inst.brainjelly_onbuild)
            inst.brainjelly_onbuild = nil
            -- cancel any existing BUILD actions, since they might be unavaliable after jellybrainhat was set to false.
            if owner.bufferedaction and owner.bufferedaction.action == ACTIONS.BUILD then
                owner:ClearBufferedAction()
            end
        end
    end

    local function brainjelly_onequiptomodel(inst, owner, from_ground)
        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()
        end
    end

    local function brainjelly()
        local inst = simple_common()

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        simple_master(inst)

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(4)
        inst.components.finiteuses:SetPercent(1)
        inst.components.finiteuses:SetOnFinished(inst.Remove)

        inst.components.equippable:SetOnEquip(brainjelly_onequip)
        inst.components.equippable:SetOnUnequip(brainjelly_onunequip)
        inst.components.equippable:SetOnEquipToModel(brainjelly_onequiptomodel)

        return inst
    end

    --------

    local function default()
        local inst = simple_common()

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        simple_master(inst)

        return inst
    end

    local fn = nil
    local assets = {Asset("ANIM", "anim/" .. fname .. ".zip")}
    local prefabs = nil

    if name == "captain" then
        fn = captain
    elseif name == "snakeskin" then
        fn = snakeskin
    elseif name == "pirate" then
        fn = pirate
    elseif name == "gas" then
        fn = gas
    elseif name == "aerodynamic" then
        fn = aerodynamic
    elseif name == "double_umbrella" then
        fn = double_umbrella
    elseif name == "shark_teeth" then
        fn = shark_teeth
    elseif name == "brainjelly" then
        fn = brainjelly
    elseif name == "woodlegs" then
        fn = woodlegs
    elseif name == "ox" then
        fn = ox
    end

    return Prefab(prefabname, fn or default, assets, prefabs)
end

return MakeHat("captain"),
    MakeHat("snakeskin"),
    MakeHat("pirate"),
    MakeHat("gas"),
    MakeHat("aerodynamic"),
    MakeHat("double_umbrella"),
    MakeHat("shark_teeth"),
    MakeHat("brainjelly"),
    MakeHat("woodlegs"),
    MakeHat("ox")
