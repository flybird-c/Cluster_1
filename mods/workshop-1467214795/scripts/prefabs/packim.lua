local assets =
{
    Asset("ANIM", "anim/ui_chester_shadow_3x4.zip"),
    Asset("ANIM", "anim/ui_chest_3x3.zip"),

    Asset("ANIM", "anim/packim.zip"),
    Asset("ANIM", "anim/packim_build.zip"),
    Asset("ANIM", "anim/packim_fat_build.zip"),
    Asset("ANIM", "anim/packim_fire_build.zip"),

    Asset("MINIMAP_IMAGE", "packim"),
    Asset("MINIMAP_IMAGE", "packim_fat"),
    Asset("MINIMAP_IMAGE", "packim_fire"),
}

local prefabs =
{
    "packim_fishbone",
    "die_fx",
    "chesterlight",
    --"sparklefx",
    "firestaff",
    "feathers_packim",
    "feathers_packim_fat",
    "feathers_packim_fire",
}

local brain = require "brains/packimbrain"

local normalsounds =
{
    close = "ia/creatures/packim/close",
    death = "ia/creatures/packim/death",
    hurt = "ia/creatures/packim/hurt",
    land = "ia/creatures/packim/land",
    open = "ia/creatures/packim/open",
    swallow = "ia/creatures/packim/swallow",
    transform = "ia/creatures/packim/transform",
    trasnform_stretch = "ia/creatures/packim/transform_stretch",
    transform_pop = "ia/creatures/packim/transformation_pop",
    fly = "ia/creatures/packim/fly",
    fly_sleep = "ia/creatures/packim/fly_sleep",
    sleep = "ia/creatures/packim/sleep",
    bounce = "ia/creatures/packim/fly_bounce",

    -- only fat packim
    fat_death_spin = "ia/creatures/packim/fat/death_spin",
    fat_land_empty = "ia/creatures/packim/fat/land_empty",
    fat_land_full = "ia/creatures/packim/fat/land_full",
}

local fatsounds =
{
    close = "ia/creatures/packim/fat/close",
    death = "ia/creatures/packim/fat/death",
    hurt = "ia/creatures/packim/fat/hurt",
    land = "ia/creatures/packim/land",
    open = "ia/creatures/packim/fat/open",
    swallow = "ia/creatures/packim/fat/swallow",
    transform = "ia/creatures/packim/transform",
    trasnform_stretch = "ia/creatures/packim/trasnform_stretch",
    transform_pop = "ia/creatures/packim/trasformation_pop",
    fly = "ia/creatures/packim/fly",
    fly_sleep = "ia/creatures/packim/fly_sleep",
    sleep = "ia/creatures/packim/sleep",
    bounce = "ia/creatures/packim/fly_bounce",

    -- only fat packim
    fat_death_spin = "ia/creatures/packim/fat/death_spin",
    fat_land_empty = "ia/creatures/packim/fat/land_empty",
    fat_land_full = "ia/creatures/packim/fat/land_full",
}

local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function ShouldSleep(inst)
    return DefaultSleepTest(inst) and not inst.sg:HasStateTag("open") and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE) and not TheWorld.state.isfullmoon
end

local function OnOpen(inst)
    if not inst.components.health:IsDead() then
        inst.sg:GoToState("open")
    end
end

local function OnClose(inst)
    if not inst.components.health:IsDead() then
        inst.sg:GoToState("close")
    end
end

-- eye bone was killed/destroyed
local function OnStopFollowing(inst)
    inst:RemoveTag("companion")
end

local function OnStartFollowing(inst)
    inst:AddTag("companion")
end

local function RetargetFilterFn(inst)
    local bone = inst.components.follower:GetLeader()
    local leader = bone ~= nil and bone.components.inventoryitem ~= nil and bone.components.inventoryitem:GetGrandOwner() or nil
    if leader ~= nil and leader.components.combat then
        return function(guy)
            return
                    (not guy.LightWatcher or guy.LightWatcher:IsInLight())
                    and  guy.components.health
                    and  not guy.components.health:IsDead()
                    and  guy.components.combat
                    and  inst.components.combat:CanTarget(guy)
                    and  leader.components.combat.target == guy
        end
    end
end

local RETARGET_CANT_TAGS = {"FX", "NOCLICK", "INLIMBO", "abigail"}

local function RetargetFn(inst)
    if not inst.last_fire_time or (inst.fire_interval and (GetTime() - inst.last_fire_time) > inst.fire_interval) then
        local fn = RetargetFilterFn(inst)
        if fn ~= nil then
            return FindEntity(inst, TUNING.PIG_TARGET_DIST, fn, nil, RETARGET_CANT_TAGS)
        end
    end
end

local function KeepTargetFn(inst, target)
    if not inst.last_fire_time or (inst.fire_interval and (GetTime() - inst.last_fire_time) > inst.fire_interval) then
        --give up on dead guys, or guys in the dark, or werepigs
        return inst.components.combat:CanTarget(target)
            and (not target.LightWatcher or target.LightWatcher:IsInLight())
            and not (target.sg and target.sg:HasStateTag("transform"))
    end
    return false
end

local function tryeatcontents(inst)
    local dideat = false
    local container = inst.components.container

    -- check that all players have closed packim
    if container:IsOpen() then return false end 

    if inst.PackimState == "FIRE" then
        for i = 1, container:GetNumSlots() do
            local item = container:GetItemInSlot(i)
            if item and not item:HasTag("irreplaceable") then
                local replacement = nil
                if item.components.cookable then
                    replacement = item.components.cookable:Cook(inst, inst)
                elseif item.components.burnable then
                    replacement = SpawnPrefab("ash")
                end
                if replacement then
                    local stacksize = 1
                    if item.components.stackable then
                        stacksize = item.components.stackable:StackSize()
                    end
                    if replacement.components.stackable then
                        replacement.components.stackable:SetStackSize(stacksize)
                    end
                    container:RemoveItemBySlot(i)
                    item:Remove()
                    container:GiveItem(replacement, i)
                end
            end
        end
        return false
    end

    local loot = {}
    for i = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
		if item then
            if item:HasTag("packimfood") then
                dideat = true
                item = container:RemoveItemBySlot(i)
                if item.components.edible then
                    local cals = item.components.edible:GetHunger()
                    if item.components.stackable then
                        cals = cals * item.components.stackable:StackSize()
                    end
                    inst.components.hunger:DoDelta(cals)

                end
                item:Remove()
            elseif item:HasTag("spoiledbypackim") then
                dideat = true
                item = container:RemoveItemBySlot(i)
                if item.components.perishable and item.components.perishable.onperishreplacement then
                    local stack = 1
                    if item.components.stackable then
                        stack = item.components.stackable:StackSize()
                    end
                    for i = 1, stack do
                        table.insert(loot, item.components.perishable.onperishreplacement)
                    end
                end
                if item.components.edible then
                    local cals = item.components.edible:GetHunger()
                    if item.components.stackable then
                        cals = cals * item.components.stackable:StackSize()
                    end
                    inst.components.hunger:DoDelta(cals)
                end
                item:Remove()
            end
        end
    end
    if #loot > 0 then
        inst.components.lootdropper:SetLoot(loot)

        inst:DoTaskInTime(60 * FRAMES, function(inst)
            inst.components.lootdropper:DropLoot()
            inst.components.lootdropper:SetLoot({})
        end)
    end

    return dideat
end

local function MorphFatPackim(inst, noconsume)
    local container = inst.components.container
    inst.forceclosed = true
    container:Close()
    inst.forceclosed = false

    local old_SetNumSlots = container.SetNumSlots
    function container:SetNumSlots(numslots)
        self.numslots = numslots
    end

    inst.components.container:WidgetSetup("fat_packim")

    container.SetNumSlots = old_SetNumSlots

    inst.PackimState = "FAT"
    inst._isfatpackim:set(true)

    inst.AnimState:SetBuild("packim_fat_build")
    inst.MiniMapEntity:SetIcon("packim_fat.tex")
    inst.components.maprevealable:SetIcon("packim_fat.tex")

    inst:RemoveTag("fireimmune")

    inst.sounds = fatsounds

    local fx = SpawnPrefab("feathers_packim_fat")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function WeaponDropped(inst)
    inst:Remove()
end

local function MorphFirePackim(inst, noconsume)
    local container = inst.components.container
    inst.forceclosed = true
    container:Close()
    inst.forceclosed = false

    if not noconsume then
        local container = inst.components.container
        for i = 1, container:GetNumSlots() do
            container:RemoveItem(container:GetItemInSlot(i)):Remove()
        end
    end

    local old_SetNumSlots = container.SetNumSlots
    function container:SetNumSlots(numslots)
        self.numslots = numslots
    end

    inst.components.container:WidgetSetup("packim")

    container.SetNumSlots = old_SetNumSlots

    inst.PackimState = "FIRE"
    inst._isfatpackim:set(false)

    inst.AnimState:SetBuild("packim_fire_build")
    inst.MiniMapEntity:SetIcon("packim_fire.tex")
    inst.components.maprevealable:SetIcon("packim_fire.tex")

    local weapon = SpawnPrefab("firestaff")
    inst.components.inventory:Equip(weapon)
    weapon:RemoveComponent("finiteuses")
    weapon.persists = false
    weapon.components.inventoryitem:SetOnDroppedFn(WeaponDropped)

    inst:AddTag("fireimmune")

    inst.sounds = normalsounds

    local fx = SpawnPrefab("feathers_packim_fire")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local MorphPackim

local function MorphNormalPackim(inst, noconsume)
    local container = inst.components.container
    inst.forceclosed = true
    inst.components.container:Close()
    inst.forceclosed = false

    --Handle things being in the extra slots!
    local oldnumslots = container:GetNumSlots()
    local newnumslots = 9

    local overflowitems = {}

    if oldnumslots > newnumslots then
        local diff = oldnumslots - newnumslots
        for i = newnumslots + 1, oldnumslots, 1 do
            overflowitems[#overflowitems + 1] = container:RemoveItemBySlot(i)
        end
    end

    local old_SetNumSlots = container.SetNumSlots
    function container:SetNumSlots(numslots)
        self.numslots = numslots
    end

    inst.components.container:WidgetSetup("packim")

    container.SetNumSlots = old_SetNumSlots

    for i = 1,  #overflowitems, 1  do
        local item = overflowitems[i]
        overflowitems[i] = nil
        container:GiveItem(item, nil, nil, true)
    end

    inst.PackimState = "NORMAL"
    inst._isfatpackim:set(false)
    inst.components.hunger.current = 0

    inst.AnimState:SetBuild("packim_build")
    inst.MiniMapEntity:SetIcon("packim.tex")
    inst.components.maprevealable:SetIcon("packim.tex")

    inst:RemoveTag("fireimmune")

    inst.sounds = normalsounds

    local fx = SpawnPrefab("feathers_packim")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function CanMorph(inst, dideat)
    local canFat = false
    local canFire = true

    if inst.PackimState ~= "NORMAL" then
        return false, false
    end

    if dideat and inst.PackimState == "NORMAL" then
        if inst.components.hunger.current > TUNING.PACKIM_TRANSFORM_HUNGER then
            canFat = true
        end
    end

    local container = inst.components.container

    for i = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
        if item == nil then
            return canFat, false
        end

        canFire = canFire and item.prefab == "obsidian"

        if not canFire then
            return canFat, false
        end
    end

    return canFat, canFire
end

local function CheckForMorph(inst)
    local dideat = tryeatcontents(inst)

    if inst.forceclosed then return end

    inst.canFat, inst.canFire = CanMorph(inst, dideat)

    if inst.canFat or inst.canFire then
        inst.sg:GoToState("transform", true)
    elseif dideat then
        inst.sg:GoToState("swallow")
    end
end

local function DoMorph(inst, fn, noconsume)
    fn(inst, noconsume)
end

MorphPackim = function(inst, noconsume)
    if inst.canFat then
        MorphFatPackim(inst, noconsume)
    elseif inst.canFire then
        MorphFirePackim(inst, noconsume)
    else
        MorphNormalPackim(inst, noconsume)
    end
    inst.canFat = false
    inst.canFire = false
end

local function OnStarve(inst)
    if inst.PackimState == "FAT" then
        inst.sg:GoToState("transform")
    end
end

local function OnPoisoned(inst)
    inst:AddTag("spoiler")
end

local function OnPoisonDone(inst)
    inst:RemoveTag("spoiler")
end

local function OnSave(inst, data)
    data.PackimState = inst.PackimState
end

local function OnPreLoad(inst, data)
    if data == nil then
        return
    elseif data.PackimState == "FAT" then
        MorphFatPackim(inst, true)
    elseif data.PackimState == "FIRE" then
        MorphFirePackim(inst, true)
    end
end

local function OnIsFatPackimDirty(inst)
    if inst._isfatpackim:value() ~= inst._clientfatmorphed then
        inst._clientfatmorphed = inst._isfatpackim:value()

        inst.replica.container:WidgetSetup(inst._clientfatmorphed and "fat_packim" or nil)
    end
end

local function OnHaunt(inst)
    if math.random() <= TUNING.HAUNT_CHANCE_ALWAYS then
        inst.components.hauntable.panic = true
        inst.components.hauntable.panictimer = TUNING.HAUNT_PANIC_TIME_SMALL
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
        return true
    end
    return false
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
    inst.entity:AddLightWatcher()

    MakeAmphibiousCharacterPhysics(inst, 75, .5)

    inst:AddTag("companion")
    inst:AddTag("character")
    inst:AddTag("scarytoprey")
    inst:AddTag("packim")
    inst:AddTag("cattoy")
    inst:AddTag("notraptrigger")
    inst:AddTag("noauradamage")
    inst:AddTag("flying")

    inst.MiniMapEntity:SetIcon("packim.tex")
    inst.MiniMapEntity:SetCanUseCache(false)

    inst.AnimState:SetBank("packim")
    inst.AnimState:SetBuild("packim_build")

    inst.DynamicShadow:SetSize(1.5, .6)

    inst.Transform:SetSixFaced()

    inst._isfatpackim = net_bool(inst.GUID, "_isfatpackim", "onisfatpackimdirty")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst._clientfatmorphed = false
        inst:ListenForEvent("onisfatpackimdirty", OnIsFatPackimDirty)
        return inst
    end

    ------------------------------------------
    inst:AddComponent("maprevealable")
    inst.components.maprevealable:SetIconPrefab("globalmapiconunderfog")

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "chester_body"
    inst.components.combat.notags = {"player"}
    inst.components.combat:SetDefaultDamage(TUNING.PACKIM_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.PACKIM_ATTACK_PERIOD)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetTarget(nil)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.CHESTER_HEALTH)
    inst.components.health:StartRegen(TUNING.CHESTER_HEALTH_REGEN_AMOUNT, TUNING.CHESTER_HEALTH_REGEN_PERIOD)

    MakePoisonableCharacter(inst)
    inst.components.poisonable:SetOnPoisonedFn(OnPoisoned)
    inst.components.poisonable:SetOnPoisonDoneFn(OnPoisonDone)

    inst:AddComponent("inspectable")
    inst.components.inspectable:RecordViews()

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.PACKIM_WALKSPEED
    inst.components.locomotor:EnableGroundSpeedMultiplier(false)
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = true, allowocean = true }


    inst:AddComponent("follower")
    inst:ListenForEvent("stopfollowing", OnStopFollowing)
    inst:ListenForEvent("startfollowing", OnStartFollowing)

    inst:AddComponent("knownlocations")

    MakeSmallBurnableCharacter(inst, "PACKIM_BODY", Vector3(100, 50, 0.5))

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 0

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("packim")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose

    --we do this for stuff that does if inst.components.inventory or inst.components.container
    inst.components.inventory.GetItemSlot = function(self, ...) inst.components.container:GetItemSlot(...) end
    inst.components.inventory.GiveItem = function(self, ...) inst.components.container:GiveItem(...) end
    inst.components.inventory.DropItem = function(self, ...) inst.components.container:DropItem(...) end
    inst.components.inventory.RemoveItem = function(self, ...) inst.components.container:RemoveItem(...) end

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    MakeHauntableDropFirstItem(inst)
    AddHauntableCustomReaction(inst, OnHaunt, false, false, true)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper.forcewortoxsouls = true

    inst:AddComponent("hunger")
    inst.components.hunger:SetMax(TUNING.PACKIM_MAX_HUNGER)
    inst.components.hunger:SetKillRate(0)
    inst.components.hunger.current = 0
    inst.components.hunger:SetRate(TUNING.PACKIM_HUNGER_DRAIN)
    inst:ListenForEvent("startstarving", OnStarve)

    inst.sounds = normalsounds

    inst:SetStateGraph("SGpackim")
    inst.sg:GoToState("idle")

    inst:SetBrain(brain)

    inst.PackimState = "NORMAL"
    inst.MorphPackim = MorphPackim
    inst.CheckForMorph = CheckForMorph
    inst:ListenForEvent("onclose", CheckForMorph)

    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad

    return inst
end

return Prefab("packim", fn, assets, prefabs)
