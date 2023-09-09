local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

IAENV.AddStategraphPostInit("wilson", function(sg)

----------------------------------------------------------------------------------------------
-- FIX Collision Problems from ToggleOn/OffPhysics functions.
local _run_start_timeevent_2 = sg.states["run_start"].timeline[2].fn
local DoFoleySounds = UpvalueHacker.GetUpvalue(_run_start_timeevent_2, "DoFoleySounds")

local _DoRunSounds
local DoRunSounds = function(inst, ...)
    if _DoRunSounds then
        _DoRunSounds(inst, ...)
    end
    local pos = inst:GetPosition()
    if TheWorld.components.flooding and TheWorld.components.flooding:OnFlood(pos.x, 0, pos.z) then
        local rot = inst.Transform:GetRotation()
        local splash = SpawnPrefab("splash_footstep")
        local CameraRight = TheCamera:GetRightVec()
        local CameraDown = TheCamera:GetDownVec()
        local displacement = CameraRight:Cross(CameraDown) * .15
        local pos = pos - displacement
        splash.Transform:SetPosition(pos.x,pos.y, pos.z)
        splash.Transform:SetRotation(rot)
    end
end
local _run_timeevent_2 = sg.states["run"].timeline[2].fn
_DoRunSounds = UpvalueHacker.GetUpvalue(_run_timeevent_2, "DoRunSounds")
UpvalueHacker.SetUpvalue(_run_timeevent_2, function(inst, ...) DoRunSounds(inst, ...) end, "DoRunSounds")

local _electrocute_onenter = sg.states["electrocute"].onenter
local ClearStatusAilments = UpvalueHacker.GetUpvalue(_electrocute_onenter, "ClearStatusAilments")
local ForceStopHeavyLifting = UpvalueHacker.GetUpvalue(_electrocute_onenter, "ForceStopHeavyLifting")

local _run_monkey_start_onenter = sg.states["run_monkey_start"].onenter
local ConfigureRunState = UpvalueHacker.GetUpvalue(_run_monkey_start_onenter, "ConfigureRunState")

local _jumpin_onexit = sg.states["jumpin"].onexit
local ToggleOnPhysics = UpvalueHacker.GetUpvalue(_jumpin_onexit, "ToggleOnPhysics")

local _jumpin_onenter = sg.states["jumpin"].onenter
local ToggleOffPhysics = UpvalueHacker.GetUpvalue(_jumpin_onenter, "ToggleOffPhysics")

local _abandon_ship_onexit = sg.states["abandon_ship"].onexit
local DoneTeleporting = UpvalueHacker.GetUpvalue(_abandon_ship_onexit, "DoneTeleporting")

local _abandon_ship_events_animover = sg.states["abandon_ship"].events.animover.fn
local StartTeleporting = UpvalueHacker.GetUpvalue(_abandon_ship_events_animover, "StartTeleporting")

----------------------------------------------------------------------------------------------

local function OnExitRow(inst)
    local boat = inst.replica.sailor:GetBoat()
    if boat and boat.components.rowboatwakespawner then
        boat.components.rowboatwakespawner:StopSpawning()
    end
    if inst.sg.nextstate ~= "row_ia" and inst.sg.nextstate ~= "sail_ia" then
        inst.components.locomotor:Stop(nil, true)
        if inst.sg.nextstate ~= "row_stop_ia" and inst.sg.nextstate ~= "sail_stop_ia" then -- Make sure equipped items are pulled back out (only really for items with flames right now)
            local equipped = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equipped then
                equipped:PushEvent("stoprowing", {owner = inst})
            end
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayIdleAnims()
            end
        end
    end
end

local function OnExitSail(inst)
    local boat = inst.replica.sailor:GetBoat()
    if boat and boat.components.rowboatwakespawner then
        boat.components.rowboatwakespawner:StopSpawning()
    end

    if inst.sg.nextstate ~= "sail_ia" then
        inst.SoundEmitter:KillSound("sail_loop")
        if inst.sg.nextstate ~= "row_ia" then
            inst.components.locomotor:Stop(nil, true)
        end
        if inst.sg.nextstate ~= "row_stop_ia" and inst.sg.nextstate ~= "sail_stop_ia" then
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayIdleAnims()
            end
        end
    end
end

local function LandFlyingPlayer(player)
    player.sg:RemoveStateTag("flying")
    if player.Physics ~= nil then
        if player.sg.statemem.collisionmask ~= nil then
            player.Physics:SetCollisionMask(player.sg.statemem.collisionmask)
        end
    end
end

local function RaiseFlyingPlayer(player)
    player.sg:AddStateTag("flying")
    if player.Physics ~= nil then
        player.sg.statemem.collisionmask = player.Physics:GetCollisionMask()
        player.Physics:ClearCollidesWith(COLLISION.LIMITS)
        player.Physics:CollidesWith(COLLISION.FLYERS)
    end
end

local function InstallBermudaFX(inst, bermuda)

    if inst.sg.statemem.bermudafx then print("WARNING: InstallBermudaFX twice???") return end
    if inst.ApplyScale == nil or inst.components.colouradder == nil or inst.components.eroder == nil then print("WARNING: Invalid player for BermudaFX???", inst) return end

    inst.AnimState:Pause()

    inst.sg.statemem.bermudafx = true

    --[[
    local textures = {
        resolvefilepath("images/bermudaTriangle01.tex"),
        resolvefilepath("images/bermudaTriangle02.tex"),
        resolvefilepath("images/bermudaTriangle03.tex"),
        resolvefilepath("images/bermudaTriangle04.tex"),
        resolvefilepath("images/bermudaTriangle05.tex"),
    }
    --]]

    local colours = {
        {30/255, 57/255, 81/255, 1.0},
        {30/255, 57/255, 81/232, 1.0},
        {30/255, 57/255, 81/232, 1.0},
        {30/255, 57/255, 81/232, 1.0},

        {255/255, 255/255, 255/255, 1.0},
        {255/255, 255/255, 255/255, 1.0},

        {0, 0, 0, 1.0},
    }

    local colourfn = nil
    local posfn = nil
    local scalefn = nil
    local texturefn = nil

    colourfn = function()
        local colour = colours[math.random(#colours)]
        inst.components.colouradder:PushColour("bermuda_travel", colour[1], colour[2], colour[3], colour[4])

        inst.sg.statemem.colourtask = nil
        inst.sg.statemem.colourtask = inst:DoTaskInTime(math.random(10, 15) * FRAMES, colourfn)
    end

    posfn = function()
        local offset = Vector3(math.random(-1, 1) * .1, math.random(-1, 1) * .1, math.random(-1, 1) * .1)
        inst.Transform:SetPosition((inst:GetPosition() + offset):Get())

        inst.sg.statemem.postask = nil
        inst.sg.statemem.postask = inst:DoTaskInTime(math.random(6, 9) * FRAMES, posfn)
    end

    scalefn = function()
        inst.Transform:SetScale(math.random(95, 105) * 0.01, math.random(99, 101) * 0.01, 1)

        inst.sg.statemem.scaletask = nil
        inst.sg.statemem.scaletask = inst:DoTaskInTime(math.random(5, 8) * FRAMES, scalefn)
    end

    texturefn = function()
        -- Swap between holo and erode for extra glitch
        local intensity, lerp = math.random(1, 4) * 0.1, math.random(-2, 2)
        inst.components.eroder:PushErode("bermuda_travel", intensity, lerp < 0 and -100 or 0, lerp, 5)
        -- AnimState does not have SetErosionTexture in DST, and TheSim is a touchy subject
        -- inst.AnimState:SetErosionParams(math.random(4, 6) * 0.1, 0, 1)
        -- TheSim:SetErosionTexture(textures[math.random(#textures)])

        inst.sg.statemem.texturetask = nil
        inst.sg.statemem.texturetask = inst:DoTaskInTime(math.random(4, 7) * FRAMES, texturefn)
    end

    colourfn()
    posfn()
    scalefn()
    texturefn()
end

local function RemoveBermudaFX(inst)

    if inst.sg.statemem.bermudafx then
        inst.sg.statemem.colourtask:Cancel()
        inst.sg.statemem.colourtask = nil
        inst.sg.statemem.postask:Cancel()
        inst.sg.statemem.postask = nil
        inst.sg.statemem.scaletask:Cancel()
        inst.sg.statemem.scaletask = nil
        inst.sg.statemem.texturetask:Cancel()
        inst.sg.statemem.texturetask = nil

        if inst.components.colouradder then inst.components.colouradder:PopColour("bermuda_travel") end
        if inst.ApplyScale then inst:ApplyScale("bermuda_travel", 1) end -- Reset player scale
        if inst.components.eroder then inst.components.eroder:PopErode("bermuda_travel") end
        -- inst.AnimState:SetErosionParams(0, 0, 0)
        -- TheSim:SetErosionTexture("images/erosion.tex")

        inst.AnimState:Resume()

        inst.sg.statemem.bermudafx = nil
    end
end

-- STATEGRAPH PATCHES, not poluting this files namespace though.
do
    local _run_start_onenter = sg.states["run_start"].onenter
    sg.states["run_start"].onenter = function(inst, ...)
        ConfigureRunState(inst)
        if inst.sg.statemem.normal and inst:HasTag("monkeyking") and inst.components.locomotor:GetTimeMoving() >= TUNING.WILBUR_TIME_TO_RUN then
            inst.sg:GoToState("run_monkeyking") -- resuming after brief stop from changing directions, or resuming prediction after running into obstacle
            return
        end
        _run_start_onenter(inst, ...)
    end

    local _run_onupdate = sg.states["run"].onupdate
    sg.states["run"].onupdate = function(inst, ...)
        ConfigureRunState(inst)
        if inst.sg.statemem.normal and inst:HasTag("monkeyking") and inst.components.locomotor:GetTimeMoving() >= TUNING.WILBUR_TIME_TO_RUN then
            inst.sg:GoToState("run_monkeyking_start")
            return
        end
        _run_onupdate(inst, ...)
    end

    local _run_onenter = sg.states["run"].onenter
    sg.states["run"].onenter = function(inst, ...)
        ConfigureRunState(inst)
        if inst.sg.statemem.normal and inst:HasTag("monkeyking") and inst.components.locomotor:GetTimeMoving() >= TUNING.WILBUR_TIME_TO_RUN then
            inst.sg:GoToState("run_monkeyking_start")
            return
        end
        _run_onenter(inst, ...)
    end

    local _fishing_strain_onenter = sg.states["fishing_strain"].onenter
    sg.states["fishing_strain"].onenter = function(inst, ...)
        _fishing_strain_onenter(inst, ...)

        if inst.components.sailor and inst.components.sailor:IsSailing() then
            if math.random() < TUNING.FISHING_CROCODOG_SPAWN_CHANCE then
                TheWorld.components.hounded:SummonSpawn(Point(inst.Transform:GetWorldPosition()))
            end
        end
    end

    local _transform_werebeaver_exit = sg.states["transform_werebeaver"].onexit
    sg.states["transform_werebeaver"].onexit = function(inst, ...)
        if not inst.sg:HasStateTag("transform") and inst.components.sailor and inst.components.sailor:IsSailing() then

            -- this will cause the boat to "drown" the player and handle the rest of the code.
            inst.components.sailor.boat.components.boathealth:MakeEmpty()
        end
        return _transform_werebeaver_exit(inst, ...)
    end
    local _transform_weremoose_exit = sg.states["transform_weremoose"].onexit
    sg.states["transform_weremoose"].onexit = function(inst, ...)
        if not inst.sg:HasStateTag("transform") and inst.components.sailor and inst.components.sailor:IsSailing() then

            -- this will cause the boat to "drown" the player and handle the rest of the code.
            inst.components.sailor.boat.components.boathealth:MakeEmpty()
        end
        return _transform_weremoose_exit(inst, ...)
    end
    local _transform_weregoose_exit = sg.states["transform_weregoose"].onexit
    sg.states["transform_weregoose"].onexit = function(inst, ...)
        -- if inst.sg:HasStateTag("drowning") then return end -- simple hack to prevent looping
        if not inst.sg:HasStateTag("transform") and inst.components.sailor and inst.components.sailor:IsSailing() then
            -- inst.sg:AddStateTag("drowning") -- goose does not drown
            inst.components.sailor:Disembark(nil, nil, true)
        end
        return _transform_weregoose_exit(inst, ...)
    end


    -- local _idle_onenter = sg.states["mounted_idle"].onenter
    -- sg.states["mounted_idle"].onenter = function(inst, pushanim, ...)
    --    if inst.components.poisonable and inst.components.poisonable:IsPoisoned() and not (inst:GetStormLevel() >= TUNING.SANDSTORM_FULL_LEVEL and not inst.components.playervision:HasGoggleVision()) then
        -- not sure what pushanim does atm
            -- if pushanim then
            --    inst.AnimState:PlayAnimation("idle_poison_pre")
            -- else
            --    inst.AnimState:PlayAnimation("idle_poison_pre")
            -- end
            --
            -- inst.AnimState:PlayAnimation("idle_poison_pre")
            -- inst.AnimState:PushAnimation("idle_poison_loop")
            -- inst.AnimState:PushAnimation("idle_poison_pst", false)
            -- inst.sg:SetTimeout(2 + math.random() * 8)
        -- else
        --    _idle_onenter(inst, pushanim, ...)
       -- end
    -- end

    local _idle_onenter = sg.states["idle"].onenter
    sg.states["idle"].onenter = function(inst, pushanim, ...)
        if inst.components.drydrownable ~= nil and inst.components.drydrownable:ShouldDrown() then
            inst:PushEvent("onhitcoastline")
        end
        return _idle_onenter(inst, pushanim, ...)
    end

    local _funnyidle_onenter = sg.states["funnyidle"].onenter
    sg.states["funnyidle"].onenter = function(inst, ...)
        if inst.components.poisonable and inst.components.poisonable:IsPoisoned() then
            inst.AnimState:PlayAnimation("idle_poison_pre")
            inst.AnimState:PushAnimation("idle_poison_loop")
            inst.AnimState:PushAnimation("idle_poison_pst", false)
        else
            _funnyidle_onenter(inst, ...)
        end
    end

    local _play_flute_onenter = sg.states["play_flute"].onenter
    sg.states["play_flute"].onenter = function(inst, ...)
        _play_flute_onenter(inst, ...)
        local act = inst:GetBufferedAction()
        if act and act.invobject and act.invobject.flutebuild then
            inst.AnimState:OverrideSymbol("pan_flute01", act.invobject.flutebuild or "pan_flute", act.invobject.flutesymbol or "pan_flute01")
        end
    end
    local _play_horn_onenter = sg.states["play_horn"].onenter
    sg.states["play_horn"].onenter = function(inst, ...)
        _play_horn_onenter(inst, ...)
        local act = inst:GetBufferedAction()
        if act and act.invobject and act.invobject.hornbuild then
            inst.AnimState:OverrideSymbol("horn01", act.invobject.hornbuild or "horn", act.invobject.hornsymbol or "horn01")
        end
    end
    local _play_strum_onenter = sg.states["play_strum"].onenter
    sg.states["play_strum"].onenter = function(inst, ...)
        _play_strum_onenter(inst, ...)
        local act = inst:GetBufferedAction()
        if act and act.invobject and act.invobject.guitarbuild then
            inst.AnimState:OverrideSymbol("swap_trident", act.invobject.guitarbuild or "swap_trident", act.invobject.guitarsymbol or "swap_trident")
        end
    end
    local _use_pocket_scale_onenter = sg.states["use_pocket_scale"].onenter
    sg.states["use_pocket_scale"].onenter = function(inst, ...)
        _use_pocket_scale_onenter(inst, ...)
        if inst.sg.statemem.target_build then
            if inst.sg.statemem.target_build == "jellyfish" then
                inst.AnimState:PlayAnimation("action_uniqueitem_pre")
                inst.AnimState:PushAnimation("pocket_scale_weigh_jellyfish", false)
            elseif
                inst.sg.statemem.target_build == "rainbowjellyfish" then
                inst.AnimState:PlayAnimation("action_uniqueitem_pre")
                inst.AnimState:PushAnimation("pocket_scale_weigh_rainbowjellyfish", false)
            end
        end
    end
    local _use_fan_onenter = sg.states["use_fan"].onenter
    sg.states["use_fan"].onenter = function(inst, ...)
        _use_fan_onenter(inst, ...)
        local invobject = inst.bufferedaction.invobject
        if invobject and invobject.components.fan and invobject.components.fan.overridebuild then
            inst.AnimState:OverrideSymbol(
                "fan01",
                invobject.components.fan.overridebuild or "fan",
                invobject.components.fan.overridesymbol or "swap_fan"
            )
        end
    end

    sg.states.sink_fast.tags["should_not_drown_to_death"] = true
end

do
    -- HANDLER PATCHES

    local _locomote_eventhandler = sg.events.locomote.fn
    sg.events.locomote.fn = function(inst, data, ...)
        local is_attacking = inst.sg:HasStateTag("attack")

        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running")
        local should_move = inst.components.locomotor:WantsToMoveForward()
        if inst.components.sailor and inst.components.sailor.boat and not inst.components.sailor.boat.components.sailable then
            should_move = false
        end

        local should_run = inst.components.locomotor:WantsToRun()
        local hasSail = inst.replica.sailor and inst.replica.sailor:GetBoat() and inst.replica.sailor:GetBoat().replica.sailable:GetIsSailEquipped() or false
        if not should_move then
            if inst.components.sailor and inst.components.sailor.boat then
                inst.components.sailor.boat:PushEvent("boatstopmoving")
            end
        end
        if should_move then
            if inst.components.sailor and inst.components.sailor.boat then
                inst.components.sailor.boat:PushEvent("boatstartmoving")
            end
        end

        if inst.sg:HasStateTag("busy") or inst:HasTag("busy") or inst.sg:HasStateTag("overridelocomote") then
            return _locomote_eventhandler(inst, data, ...)
        end
        if inst.components.sailor and inst.components.sailor:IsSailing() then
            if not is_attacking then
                if is_moving and not should_move then
                    if hasSail then
                        inst.sg:GoToState("sail_stop_ia")
                    else
                        inst.sg:GoToState("row_stop_ia")
                    end
                elseif not is_moving and should_move or (is_moving and should_move and is_running ~= should_run) then
                    if hasSail then
                        inst.sg:GoToState("sail_start_ia")
                    else
                        inst.sg:GoToState("row_start_ia")
                    end
                end
            end
            return
        end

        return _locomote_eventhandler(inst, data, ...)
    end

    local _onsink_eventhandler = sg.events.onsink.fn
    sg.events.onsink.fn = function(inst, data, ...)
        if data and data.ia_boat and not inst.components.health:IsDead() and not inst.sg:HasStateTag("drowning") and
          (inst.components.drownable ~= nil and inst.components.drownable:ShouldDrown()) then
            inst.sg:GoToState("sink_boat", data.shore_pt)
        else
            if inst.components.sailor and inst.components.sailor.boat and inst.components.sailor.boat.components.container then
                inst.components.sailor.boat.components.container:Close(true)
            end
            _onsink_eventhandler(inst, data, ...)
        end
    end

    local _death_eventhandler = sg.events.death.fn
    sg.events.death.fn = function(inst, data)
        if data.cause == "drowning" then
            inst.sg:GoToState("death_drown")
        else
            if inst.components.sailor and inst.components.sailor.boat and inst.components.sailor.boat.components.container then
                inst.components.sailor.boat.components.container:Close(true)
            end
            _death_eventhandler(inst, data)
        end
    end

    local _attacked_eventhandler = sg.events.attacked.fn
    sg.events.attacked.fn = function(inst, data)
        if inst.components.sailor and inst.components.sailor:IsSailing() then
            local boat = inst.components.sailor:GetBoat()
            if not inst.components.health:IsDead() and not (boat and boat.components.boathealth and boat.components.boathealth:IsDead()) then

                if not boat.components.sailable or not boat.components.sailable:CanDoHit() then
                    return
                end

                if data.attacker and (data.attacker:HasTag("insect") or data.attacker:HasTag("twister"))then
                    local is_idle = inst.sg:HasStateTag("idle")
                    if not is_idle then
                        return
                    end
                end

                boat.components.sailable:GetHit()

                _attacked_eventhandler(inst, data)
            end
        else
            _attacked_eventhandler(inst, data)
        end
    end

    local _attack_actionhandler = sg.actionhandlers[ACTIONS.ATTACK].deststate
    sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action, ...)
        if not (inst.sg:HasStateTag("attack") and action.target == inst.sg.statemem.attacktarget or inst.components.health:IsDead()) then
            local weapon = inst.components.combat ~= nil and inst.components.combat:GetWeapon() or nil
            if weapon and weapon:HasTag("speargun") then
                return "speargun"
            end
        end
        return _attack_actionhandler(inst, action, ...)
    end

    local _eat_actionhandler = sg.actionhandlers[ACTIONS.EAT].deststate
    sg.actionhandlers[ACTIONS.EAT].deststate = function(inst, action, ...)
        local return_eat_state = _eat_actionhandler(inst, action, ...)
        local obj = action.target or action.invobject
        return (obj and return_eat_state == "eat" and obj:HasTag("edible_forcequickeat") and "quickeat") or return_eat_state
    end

    local _pickup_actionhandler = sg.actionhandlers[ACTIONS.PICKUP].deststate
    sg.actionhandlers[ACTIONS.PICKUP].deststate = function(inst, action, ...)
        return (action.target ~= nil and action.target.components.inventoryitem and action.target.components.inventoryitem.longpickup and "dolongaction") or _pickup_actionhandler(inst, action, ...)
    end

    -- Disembark properly and drop no skeleton
    local _death_animover = sg.states.death.events.animover.fn
    sg.states.death.events.animover.fn = function(inst, ...)
        if inst.AnimState:AnimDone() and not inst.sg:HasStateTag("dismounting")
        and IsOnOcean(inst) then
            if inst.components.sailor and inst.components.sailor:IsSailing() then
                inst.components.sailor:Disembark()
            end
            inst:PushEvent(inst.ghostenabled and "makeplayerghost" or "playerdied", {skeleton = false})
        else
            _death_animover(inst, ...)
        end
    end
end

do
    local _attack_onenter = sg.states.attack.onenter
    sg.states.attack.onenter = function(inst, data)

        local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if equip and equip:HasTag("cutlass") then
            SetSoundAlias("dontstarve/wilson/attack_weapon", "ia/common/swordfish_sword")
        elseif equip and equip:HasTag("pegleg") then
            SetSoundAlias("dontstarve/wilson/attack_weapon", "ia/common/pegleg_weapon")
        end

        _attack_onenter(inst, data)

        SetSoundAlias("dontstarve/wilson/attack_weapon", nil)

    end
end

do
    local _fish_actionhandler = sg.actionhandlers[ACTIONS.FISH].deststate
    sg.actionhandlers[ACTIONS.FISH].deststate = function(inst, action, ...)
        if action.target and action.target.components.workable
        and action.target.components.workable:GetWorkAction() == ACTIONS.FISH
        and action.target.components.workable:CanBeWorked() then
            return "fishing_retrieve"
        end
        if type(_fish_actionhandler) == "function" then
            return _fish_actionhandler(inst, action, ...)
        end
        return _fish_actionhandler
    end
end


local actionhandlers = {
    ActionHandler(ACTIONS.EMBARK, "embark"),
    ActionHandler(ACTIONS.DISEMBARK, "disembark"),
    ActionHandler(ACTIONS.THROW, "throw"),
    ActionHandler(ACTIONS.LAUNCH_THROWABLE, "cannon"),
    ActionHandler(ACTIONS.RETRIEVE, "dolongaction"),
    ActionHandler(ACTIONS.STICK, "doshortaction"),
    ActionHandler(ACTIONS.HACK, function(inst)
        if inst:HasTag("beaver") then
            return not inst.sg:HasStateTag("gnawing") and "gnaw" or nil
        end
        return not inst.sg:HasStateTag("prehack") and (inst.sg:HasStateTag("hacking") and "hack" or "hack_start") or nil
    end),
    ActionHandler(ACTIONS.TOGGLEON, "give"),
    ActionHandler(ACTIONS.TOGGLEOFF, "give"),
    ActionHandler(ACTIONS.REPAIRBOAT, "dolongaction"),
    ActionHandler(ACTIONS.CUREPOISON, function(inst, action)
        local target = action.target

        if not target or target == inst then
            return "curepoison"
        else
            return "give"
        end
    end),
    ActionHandler(ACTIONS.PACKUP, "doshortaction"),
    ActionHandler(ACTIONS.PEER, "peertelescope"),
    ActionHandler(ACTIONS.READMAP, "scrollmap"),
    ActionHandler(ACTIONS.NAME_BOAT, "doshortaction"),
    ActionHandler(ACTIONS.FISH_FLOTSAM, "fish_flotsam"),
}

local events = {

    -- ive changed the vacuum states and handlers to allow being sucked up over water, if this is a bad idea tell me and i can remove it -Half
    EventHandler("vacuum_in", function(inst)
        if inst.components.health and not inst.components.health:IsDead() and
        not IsOnOcean(inst) and
        not inst.sg:HasStateTag("vacuum_in") and
        not (inst.components.sailor and inst.components.sailor:IsSailing()) then
            inst.sg:GoToState("vacuumedin")
        end
    end),

    EventHandler("vacuum_out", function(inst, data)
        if inst.components.health and not inst.components.health:IsDead() and
        not inst.sg:HasStateTag("vacuum_out") and
        not (inst.components.sailor and inst.components.sailor:IsSailing()) then
            if IsOnOcean(inst) then
                -- copied from keeponland
                local pt = inst:GetPosition()
                local angle = inst.Transform:GetRotation()
                angle = angle * DEGREES
                local dist = -1
                local newpt = Vector3(pt.x + dist * math.cos(angle), pt.y, pt.z + dist * -math.sin(angle))
                if not IsLandTile(TheWorld.Map:GetVisualTileAtPoint(newpt.x, newpt.y, newpt.z)) then
                    -- Okay, try to find any point nearby
                    local result_offset = FindWalkableOffset(pt, 0, 5, 12)
                    newpt = result_offset and pt + result_offset or nil
                end

                if newpt then
                    inst.Transform:SetPosition(newpt.x, newpt.y, newpt.z)
                    if inst.components.locomotor then
                        inst.components.locomotor:Stop()
                    end
                end
            end
            inst.sg:GoToState("vacuumedout", data)
        else
            inst:RemoveTag("NOVACUUM")
        end
    end),


    EventHandler("vacuum_held", function(inst)
        if inst.components.health and not inst.components.health:IsDead() and
        not inst.sg:HasStateTag("vacuum_held") and
        not (inst.components.sailor and inst.components.sailor:IsSailing()) then
            if not IsOnOcean(inst) then
                inst.sg:GoToState("vacuumedheld")
            else
                -- copied from keeponland
                local pt = inst:GetPosition()
                local angle = inst.Transform:GetRotation()
                angle = angle * DEGREES
                local dist = -1
                local newpt = Vector3(pt.x + dist * math.cos(angle), pt.y, pt.z + dist * -math.sin(angle))
                if not IsLandTile(TheWorld.Map:GetVisualTileAtPoint(newpt.x, newpt.y, newpt.z, 1.5 / 4)) then
                    -- Okay, try to find any point nearby
                    local result_offset = FindWalkableOffset(pt, 0, 5, 12)
                    newpt = result_offset and pt + result_offset or nil
                end

                if newpt then
                    inst.Transform:SetPosition(newpt.x, newpt.y, newpt.z)
                    if inst.components.locomotor then
                        inst.components.locomotor:Stop()
                    end
                    inst.sg:GoToState("vacuumedheld")
                end
            end
        end
    end),

    EventHandler("sailequipped", function(inst)
        if inst.sg:HasStateTag("rowing") then
            inst.sg:GoToState("sail_ia")
            local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equipped then
                equipped:PushEvent("stoprowing", {owner = inst})
            end
        end
    end),

    EventHandler("sailunequipped", function(inst)
        if inst.sg:HasStateTag("sailing") then
            inst.sg:GoToState("row_ia")

            if not inst:HasTag("mime") then
                inst.AnimState:OverrideSymbol("paddle", "swap_paddle", "paddle")
            end
            -- TODO allow custom paddles?
            inst.AnimState:OverrideSymbol("wake_paddle", "swap_paddle", "wake_paddle")

            local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equipped then
                equipped:PushEvent("startrowing", {owner = inst})
            end
        end
    end),

    EventHandler("boatattacked", sg.events.attacked.fn),

    EventHandler("boostbywave", function(inst, data)
        if inst.sg:HasStateTag("running") then

            local boost = data.boost or TUNING.WAVEBOOST
            if inst.components.sailor then
                local boat = inst.components.sailor:GetBoat()
                if boat and boat.waveboost and not data.boost then
                    boost = boat.waveboost
                end
                -- sanity boost, walani's surfboard mainly
                if boat and boat.wavesanityboost and inst:HasTag("surfer") and inst.components.sanity then
                    inst.components.sanity:DoDelta(boat.wavesanityboost)
                end
            end

            if inst.components.locomotor then
                inst.components.locomotor.boost = boost
            end
        end
    end),

    EventHandler("shipwrecked_portal", function(inst, data)
        if inst.components.health and not
        inst.components.health:IsDead() then
            if inst.components.rider:IsRiding() then
                inst.sg:GoToState("player_SWportal_mounted")
            else
                inst.sg:GoToState("player_shipwrecked_portal_pre")
            end
        end
    end),

    EventHandler("onhitcoastline", function(inst, data)
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("drowning") and
                (inst.components.drydrownable ~= nil and inst.components.drydrownable:ShouldDrown()) then
            if inst.components.drydrownable:ShouldDestroyBoat() then
                inst.components.drydrownable:DestroyBoat()
            else
                inst.sg:GoToState("hitcoastline")
            end
        end
    end),
}

local states = {
    State{
        name = "row_start_ia",
        tags = { "moving", "running", "rowing", "boating", "canrotate", "autopredict" },

        onenter = function(inst)
            local boat = inst.replica.sailor:GetBoat()

            inst.components.locomotor:RunForward()

            if not inst:HasTag("mime") then
                inst.AnimState:OverrideSymbol("paddle", "swap_paddle", "paddle")
            end
            -- TODO allow custom paddles?
            inst.AnimState:OverrideSymbol("wake_paddle", "swap_paddle", "wake_paddle")

            -- RoT has row_pre, which is identical but uses the equipped item as paddle

            local oar = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            inst.AnimState:PlayAnimation(oar and oar:HasTag("oar") and "row_pre" or "row_ia_pre")
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayPreRowAnims()
            end

            DoFoleySounds(inst)

            local equipped = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equipped then
                equipped:PushEvent("startrowing", {owner = inst})
            end
            inst:PushEvent("startrowing")
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        onexit = OnExitRow,

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("row_ia")
                end
            end),
        },
    },

    State{
        name = "row_ia",
        tags = { "moving", "running", "rowing", "boating", "canrotate", "autopredict" },

        onenter = function(inst)
            local boat = inst.replica.sailor:GetBoat()

            if boat and boat.replica.sailable and boat.replica.sailable.creaksound then
                inst.SoundEmitter:PlaySound(boat.replica.sailable.creaksound, nil, nil, true)
            end
            inst.SoundEmitter:PlaySound("ia/common/boat/paddle", nil, nil, true)
            DoFoleySounds(inst)

            local oar = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            local anim = oar and oar:HasTag("oar") and "row_medium" or "row_loop"
            if not inst.AnimState:IsCurrentAnimation(anim) then
                -- RoT has row_medium, which is identical but uses the equipped item as paddle
                inst.AnimState:PlayAnimation(anim, true)
            end
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayRowAnims()
            end

            if boat and boat.components.rowboatwakespawner then
                boat.components.rowboatwakespawner:StartSpawning()
            end

            if inst.components.mapwrapper
            and inst.components.mapwrapper._state > 1
            and inst.components.mapwrapper._state < 5 then
                inst.sg:AddStateTag("nomorph")
                -- TODO pause predict?
            end

            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        onexit = OnExitRow,

        timeline = {
            TimeEvent(8*FRAMES, function(inst)
                local boat = inst.replica.sailor:GetBoat()
                if boat and boat.replica.container then
                    local trawlnet = boat.replica.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_SAIL)
                    if trawlnet and trawlnet.rowsound then
                        inst.SoundEmitter:PlaySound(trawlnet.rowsound, nil, nil, true)
                    end
                end
            end),
        },

        events = {
            EventHandler("trawlitem", function(inst)
                local boat = inst.replica.sailor:GetBoat()
                if boat and boat.replica.sailable then
                    boat.replica.sailable:PlayTrawlOverAnims()
                end
            end),
        },

        ontimeout = function(inst) inst.sg:GoToState("row_ia") end,
    },

    State{
        name = "row_stop_ia",
        tags = { "canrotate", "idle", "autopredict"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            local boat = inst.replica.sailor:GetBoat()
            local oar = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            inst.AnimState:PlayAnimation(oar and oar:HasTag("oar") and "row_idle_pst" or "row_pst")
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayPostRowAnims()
            end

            -- If the player had something in their hand before starting to row, put it back.
            if inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:PushAnimation("item_out", false)
            end
        end,

        events = {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    local equipped = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    if equipped then
                        equipped:PushEvent("stoprowing", {owner = inst})
                    end
                    inst:PushEvent("stoprowing")
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "sail_start_ia",
        tags = {"moving", "running", "canrotate", "boating", "sailing", "autopredict"},

        onenter = function(inst)
            local boat = inst.replica.sailor:GetBoat()

            inst.components.locomotor:RunForward()

            local anim = boat.replica.sailable.sailstartanim or "sail_pre"
            if anim ~= "sail_pre" or inst.has_sailface then
                inst.AnimState:PlayAnimation(anim)
            else
                inst.AnimState:PlayAnimation("sail_ia_pre")
            end
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayPreSailAnims()
            end

            local equipped = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equipped then
                equipped:PushEvent("startsailing", {owner = inst})
            end
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        onexit = OnExitSail,

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("sail_ia")
                end
            end),
        },
    },

    State{
        name = "sail_ia",
        tags = {"canrotate", "moving", "running", "boating", "sailing", "autopredict"},

        onenter = function(inst)
            local boat = inst.replica.sailor:GetBoat()

            local loopsound = nil
            local flapsound = nil

            if boat and boat.replica.container and boat.replica.container.hasboatequipslots then
                local sail = boat.replica.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_SAIL)
                if sail then
                    loopsound = sail.loopsound
                    flapsound = sail.flapsound
                end
            elseif boat and boat.replica.sailable and boat.replica.sailable.sailsound then
                loopsound = boat.replica.sailable.sailsound
            end

            if not inst.SoundEmitter:PlayingSound("sail_loop") and loopsound then
                inst.SoundEmitter:PlaySound(loopsound, "sail_loop", nil, true)
            end

            if flapsound then
                inst.SoundEmitter:PlaySound(flapsound, nil, nil, true)
            end

            if boat and boat.replica.sailable and boat.replica.sailable.creaksound then
                inst.SoundEmitter:PlaySound(boat.replica.sailable.creaksound, nil, nil, true)
            end

            local anim =boat and boat.replica.sailable and boat.replica.sailable.sailloopanim or "sail_loop"
            if not inst.AnimState:IsCurrentAnimation(anim) then
                if anim ~= "sail_loop" or inst.has_sailface then
                    inst.AnimState:PlayAnimation(anim , true)
                else
                    inst.AnimState:PlayAnimation("sail_ia_loop", true)
                end
            end
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlaySailAnims()
            end

            if boat and boat.components.rowboatwakespawner then
                boat.components.rowboatwakespawner:StartSpawning()
            end

            if inst.components.mapwrapper
            and inst.components.mapwrapper._state > 1
            and inst.components.mapwrapper._state < 5 then
                inst.sg:AddStateTag("nomorph")
                -- TODO pause predict?
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        onexit = OnExitSail,

        events = {
            -- EventHandler("animover", function(inst) inst.sg:GoToState("sail_ia") end ),
            EventHandler("trawlitem", function(inst)
                local boat = inst.replica.sailor:GetBoat()
                if boat and boat.replica.sailable then
                    boat.replica.sailable:PlayTrawlOverAnims()
                end
            end),
        },

        ontimeout = function(inst) inst.sg:GoToState("sail_ia") end,
    },

    State{
        name = "sail_stop_ia",
        tags = {"canrotate", "idle", "autopredict"},

        onenter = function(inst)
            local boat = inst.replica.sailor:GetBoat()

            inst.components.locomotor:Stop()
            local anim = boat.replica.sailable.sailstopanim or "sail_pst"
            if anim ~= "sail_pst" or inst.has_sailface then
                inst.AnimState:PlayAnimation(anim)
            else
                inst.AnimState:PlayAnimation("sail_ia_pst")
            end
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayPostSailAnims()
            end
        end,

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    local equipped = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    if equipped then
                        equipped:PushEvent("stopsailing", {owner = inst})
                    end
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "embark",
        tags = {"canrotate", "boating", "busy", "nomorph", "nopredict"},
        onenter = function(inst)
            local BA = inst:GetBufferedAction()
            if BA.target and BA.target.components.sailable and not BA.target.components.sailable:IsOccupied() then
                BA.target.components.sailable.isembarking = true
                if inst.components.sailor and inst.components.sailor:IsSailing() then
                    inst.components.sailor:Disembark(nil, true)
                else
                    inst.sg:GoToState("jumponboatstart")
                end
            else
                -- go to idle first so wilson can go to the talk state if desired -M
                -- and in my defence, Klei does that too, in opengift state
                inst.sg:GoToState("idle")
                inst:PushEvent("actionfailed", { action = inst.bufferedaction, reason = "INUSE" })
                inst:ClearBufferedAction()
            end
        end,

        onexit = function(inst)
        end,
    },

    State{
        name = "disembark",
        tags = {"canrotate", "boating", "busy", "nomorph", "nopredict"},
        onenter = function(inst)
            inst:PerformBufferedAction()
        end,

        onexit = function(inst)
        end,
    },

    State{
        name = "scrollmap",
        tags = {"doing"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("scroll", false)
            inst.AnimState:OverrideSymbol("scroll", "messagebottle", "scroll")
            inst.AnimState:PushAnimation("scroll_pst", false)

            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")
            if inst.components.inventory.activeitem and inst.components.inventory.activeitem.components.book then
                inst.components.inventory:ReturnActiveItem()
            end
            inst:PerformPreviewBufferedAction()
        end,

        onexit = function(inst)
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry")
                inst.AnimState:Hide("ARM_normal")
            end
        end,

        timeline=
        {
            TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/common/treasuremap_open", nil, nil, true) end),
            TimeEvent(58*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/common/treasuremap_close", nil, nil, true) end),
        },

        events=
        {
            EventHandler("animover", function(inst)
                inst:PerformBufferedAction()
            end),


            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:ClearBufferedAction()
                    inst.sg:GoToState("idle")
                end
            end),


        },
    },
    -- a copy of the quickeat state that has the sw sounds and leads to the celebrate state
    -- as much as id like to just edit the quickeat state this one has the sound play when you eat the item rather than before you eat the item
    State{
        name = "curepoison",
        tags = { "busy" },

        onenter = function(inst, foodinfo)
            inst.components.locomotor:Stop()

            local feed = foodinfo and foodinfo.feed
            if feed ~= nil then
                inst.components.locomotor:Clear()
                inst:ClearBufferedAction()
                inst.sg.statemem.feed = foodinfo.feed
                inst.sg.statemem.feeder = foodinfo.feeder
                inst.sg:AddStateTag("pausepredict")
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:RemotePausePrediction()
                end
            elseif inst:GetBufferedAction() then
                feed = inst:GetBufferedAction().invobject
            end

            if inst.components.inventory:IsHeavyLifting() and
                not inst.components.rider:IsRiding() then
                inst.AnimState:PlayAnimation("heavy_quick_eat")
            else
                inst.AnimState:PlayAnimation("quick_eat_pre")
                inst.AnimState:PushAnimation("quick_eat", false)
            end

            inst.components.hunger:Pause()
        end,

        timeline =
        {
            TimeEvent(12 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("ia/common/player_drink", "drinking")
                if inst.sg.statemem.feed ~= nil then
                    inst.components.eater:Eat(inst.sg.statemem.feed, inst.sg.statemem.feeder)
                else
                    inst:PerformBufferedAction()
                end
                inst.sg:RemoveStateTag("busy")
                inst.sg:RemoveStateTag("pausepredict")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("celebrate")
                end
            end),
        },

        onexit = function(inst)
            inst.SoundEmitter:KillSound("drinking")
            if not GetGameModeProperty("no_hunger") then
                inst.components.hunger:Resume()
            end
            if inst.sg.statemem.feed ~= nil and inst.sg.statemem.feed:IsValid() then
                inst.sg.statemem.feed:Remove()
            end
        end,
    },

    -- a striped down copy of the research state but with a sw poison sound and it can be interupted
    State{
        name = "celebrate",
        tags = { "idle" },

        onenter = function(inst)
            ForceStopHeavyLifting(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("research")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        timeline =
        {
            TimeEvent(8 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("ia/common/antivenom_whoosh")
            end),

            TimeEvent(14 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("yotb_2021/common/heel_click")
            end),

            TimeEvent(23 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("yotb_2021/common/heel_click")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "jumponboatstart",
        tags = { "doing", "nointerupt", "busy", "canrotate", "nomorph", "nopredict"},

        onenter = function(inst)
            if inst.Physics.ClearCollidesWith then
            inst.Physics:ClearCollidesWith(COLLISION.LIMITS) -- R08_ROT_TURNOFTIDES
            end
            inst.components.locomotor:StopMoving()
            -- inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.AnimState:PlayAnimation("jumpboat")
            inst.SoundEmitter:PlaySound("ia/common/boatjump_whoosh")

            local BA = inst:GetBufferedAction()
            inst.sg.statemem.startpos = inst:GetPosition()
            inst.sg.statemem.targetpos = BA.target and BA.target:GetPosition()

            inst:PushEvent("ms_closepopups")

            inst.sg:AddStateTag("temp_invincible")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        onexit = function(inst)
        -- This shouldn"t actually be reached
            if inst.Physics.ClearCollidesWith then
            inst.Physics:CollidesWith(COLLISION.LIMITS) -- R08_ROT_TURNOFTIDES
            end
            inst.components.locomotor:Stop()
            -- inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.sg:RemoveStateTag("temp_invincible")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,

        timeline = {
            -- Make the action cancel-able until this?
            TimeEvent(7 * FRAMES, function(inst)
                inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
                local dist = inst:GetPosition():Dist(inst.sg.statemem.targetpos)
                local speed = dist / (18/30)
                inst.Physics:SetMotorVelOverride(1 * speed, 0, 0)
            end),
        },

        events = {
            EventHandler("animover", function(inst)
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end

                inst.sg:RemoveStateTag("temp_invincible")
                inst.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
                inst.Physics:Stop()

                inst.components.locomotor:Stop()
                -- inst.components.locomotor:EnableGroundSpeedMultiplier(true)
                inst:PerformBufferedAction()
            end),
        },
    },

    State{
        name = "jumpboatland",
        tags = { "doing", "nointerupt", "busy", "canrotate", "invisible", "nomorph", "nopredict"},

        onenter = function(inst, pos)
            if inst.Physics.ClearCollidesWith then
            inst.Physics:CollidesWith(COLLISION.LIMITS) -- R08_ROT_TURNOFTIDES
            end
            inst.sg:AddStateTag("temp_invincible")
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("landboat")
            local boat = inst.components.sailor.boat
            if boat and boat.landsound then
                inst.SoundEmitter:PlaySound(boat.landsound)
            end
        end,

        onexit = function(inst)
            inst.sg:RemoveStateTag("temp_invincible")
            if inst.components.drydrownable ~= nil and inst.components.drydrownable:ShouldDrown() then
                inst:PushEvent("onhitcoastline")
            end
        end,

        events = {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "jumpoffboatstart",
        tags = { "doing", "nointerupt", "busy", "canrotate", "nomorph", "nopredict"},

        onenter = function(inst, pos)
            if inst.Physics.ClearCollidesWith then
            inst.Physics:ClearCollidesWith(COLLISION.LIMITS) -- R08_ROT_TURNOFTIDES
            end
            inst.components.locomotor:StopMoving()
            -- inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.AnimState:PlayAnimation("jumpboat")
            inst.SoundEmitter:PlaySound("ia/common/boatjump_whoosh")

            inst.sg.statemem.startpos = inst:GetPosition()
            inst.sg.statemem.targetpos = pos

            inst:PushEvent("ms_closepopups")

            inst.sg:AddStateTag("temp_invincible")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:RemotePausePrediction()
            end
        end,

        onexit = function(inst)
        -- This shouldn"t actually be reached
            if inst.Physics.ClearCollidesWith then
            inst.Physics:CollidesWith(COLLISION.LIMITS) -- R08_ROT_TURNOFTIDES
            end
            inst.components.locomotor:Stop()
            -- inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.sg:RemoveStateTag("temp_invincible")

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,

        timeline = {
            -- Make the action cancel-able until this?
            TimeEvent(7 * FRAMES, function(inst)
                inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
                local dist = inst:GetPosition():Dist(inst.sg.statemem.targetpos)
                local speed = dist / (18/30)
                inst.Physics:SetMotorVelOverride(1 * speed, 0, 0)
            end),
        },

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
                    inst.sg:RemoveStateTag("temp_invincible")
                    inst.sg:GoToState("jumpoffboatland")
                end
            end),
        },
    },

    State{
        name = "jumpoffboatland",
        tags = { "doing", "nointerupt", "busy", "canrotate", "nomorph", "nopredict"},

        onenter = function(inst, pos)
            if inst.Physics.ClearCollidesWith then
            inst.Physics:CollidesWith(COLLISION.LIMITS) -- R08_ROT_TURNOFTIDES
            end
            inst.sg:AddStateTag("temp_invincible")
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("land", false)
            inst.SoundEmitter:PlaySound("ia/common/boatjump_to_land")
            PlayFootstep(inst)
        end,

        onexit = function(inst)
            inst.sg:RemoveStateTag("temp_invincible")
        end,

        events = {
            EventHandler("animqueueover", function(inst)
                inst:PerformBufferedAction()
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "hack_start",
        tags = {"prehack", "working"},

        onenter = function(inst)
            inst.components.locomotor:Stop()

            local buffaction = inst:GetBufferedAction()
            local tool = buffaction ~= nil and buffaction.invobject or nil

            if tool ~= nil then
                local symbolswapdata = tool.components.symbolswapdata
                if symbolswapdata.is_skinned then
                    inst.AnimState:OverrideItemSkinSymbol("swap_machete", tool:GetSkinBuild(), symbolswapdata.build, tool.GUID, symbolswapdata.symbol)
                else
                    inst.AnimState:OverrideSymbol("swap_machete", symbolswapdata.build, symbolswapdata.symbol)
                end
                inst.AnimState:PlayAnimation("hack_pre")
            else
                inst.AnimState:PlayAnimation("chop_pre")
            end

        end,

        events = {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("hack")
                end
            end),
        },
    },

    State{
        name = "hack",
        tags = {"prehack", "hacking", "working"},

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            local tool = inst.sg.statemem.action ~= nil and inst.sg.statemem.action.invobject or nil

            -- Note this is used to make sure the tool symbol is still the machete even when inventory hacking
            if tool ~= nil then
                local symbolswapdata = tool.components.symbolswapdata
                if symbolswapdata.is_skinned then
                    inst.AnimState:OverrideItemSkinSymbol("swap_machete", tool:GetSkinBuild(), symbolswapdata.build, tool.GUID, symbolswapdata.symbol)
                else
                    inst.AnimState:OverrideSymbol("swap_machete", symbolswapdata.build, symbolswapdata.symbol)
                end
                inst.AnimState:PlayAnimation("hack_loop")
            else
                inst.AnimState:PlayAnimation("chop_loop")
            end
        end,

        timeline = {
            TimeEvent(2*FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),


            TimeEvent(9*FRAMES, function(inst)
                inst.sg:RemoveStateTag("prehack")
            end),

            TimeEvent(14*FRAMES, function(inst)
                if inst.components.playercontroller ~= nil and
                inst.components.playercontroller:IsAnyOfControlsPressed(
                CONTROL_PRIMARY, CONTROL_ACTION, CONTROL_CONTROLLER_ACTION) and
                inst.sg.statemem.action ~= nil and
                inst.sg.statemem.action:IsValid() and
                inst.sg.statemem.action.target ~= nil and
                inst.sg.statemem.action.target.components.hackable ~= nil and
                inst.sg.statemem.action.target.components.hackable:CanBeHacked() and
                inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action) and
                CanEntitySeeTarget(inst, inst.sg.statemem.action.target) then
                    inst:ClearBufferedAction()
                    inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),

            TimeEvent(16*FRAMES, function(inst)
                inst.sg:RemoveStateTag("hacking")
            end),
        },

        events = {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end),
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "sink_boat",
        tags = { "busy", "nopredict", "nomorph", "drowning", "nointerrupt" },

        onenter = function(inst, shore_pt)

            ForceStopHeavyLifting(inst)
            inst:ClearBufferedAction()

            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()

            inst.AnimState:Hide("swap_arm_carry")
            inst.AnimState:PlayAnimation("boat_death")

            if inst:HasTag("beaver") then
                inst.AnimState:SetBuild("werebeaver_boat_death")
                inst.AnimState:SetBankAndPlayAnimation("werebeaver_boat_death", "boat_death")
                inst.SoundEmitter:PlaySound("ia/characters/woodie/sinking_death_werebeaver")
            else
                inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/sinking")
            end

            if inst:HasTag("weremoose") then
                inst.AnimState:PlayAnimation("sink")
                inst.AnimState:Hide("plank")
                inst.AnimState:Hide("float_front")
                inst.AnimState:Hide("float_back")
            end

            if inst.components.rider:IsRiding() then
                inst.sg:AddStateTag("dismounting")
            end

            if shore_pt ~= nil then
                inst.components.drownable:OnFallInOcean(shore_pt:Get())
            else
                inst.components.drownable:OnFallInOcean()
            end

            inst.components.drownable:DropInventory()

            inst.sg:SetTimeout(8) -- just in case
        end,

        timeline = {
            TimeEvent(14 * FRAMES, function(inst)
                if inst:HasTag("weremoose") then
                    inst.AnimState:Show("float_front")
                    inst.AnimState:Show("float_back")
                end
            end),
            TimeEvent(50*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("ia/common/boat/sinking/shadow")
            end),
            TimeEvent(70*FRAMES, function(inst)
                inst.DynamicShadow:Enable(false)
                inst:ShowHUD(false)
            end),
        },

        ontimeout= function(inst)  -- failsafe
            if inst.components.drownable:GetRescueData() ~= nil then
                -- copy from animover
                if inst:HasTag("beaver") then
                    inst.AnimState:SetBank("werebeaver")
                    if inst.components.skinner then
                        inst.components.skinner:SetSkinMode("werebeaver_skin")
                    else
                        inst.AnimState:SetBuild("werebeaver")
                    end
                end
            end
            StartTeleporting(inst)

            if inst.sg:HasStateTag("dismounting") then
                inst.sg:RemoveStateTag("dismounting")

                local mount = inst.components.rider:GetMount()
                inst.components.rider:ActualDismount()
                if mount ~= nil then
                    if mount.components.drownable ~= nil then
                        mount:Hide()
                        mount:PushEvent("onsink", {noanim = true, shore_pt = Vector3(inst.components.drownable.dest_x, inst.components.drownable.dest_y, inst.components.drownable.dest_z)})
                    elseif mount.components.health ~= nil then
                        mount:Hide()
                        mount.components.health:Kill()
                    end
                end
            end

            inst.components.drownable:WashAshore()
        end,

        events = {
            EventHandler("animover", function(inst)
                if inst.components.drownable:GetRescueData() ~= nil then
                    -- copy from animover
                    if inst:HasTag("beaver") then
                        inst.AnimState:SetBank("werebeaver")
                        if inst.components.skinner then
                            inst.components.skinner:SetSkinMode("werebeaver_skin")
                        else
                            inst.AnimState:SetBuild("werebeaver")
                        end
                    end
                end
                StartTeleporting(inst)

                if inst.sg:HasStateTag("dismounting") then
                    inst.sg:RemoveStateTag("dismounting")

                    local mount = inst.components.rider:GetMount()
                    inst.components.rider:ActualDismount()
                    if mount ~= nil then
                        if mount.components.drownable ~= nil then
                            mount:Hide()
                            mount:PushEvent("onsink", {noanim = true, shore_pt = Vector3(inst.components.drownable.dest_x, inst.components.drownable.dest_y, inst.components.drownable.dest_z)})
                        elseif mount.components.health ~= nil then
                            mount:Hide()
                            mount.components.health:Kill()
                        end
                    end
                end

                inst.components.drownable:WashAshore()
            end),

            EventHandler("on_washed_ashore", function(inst)
                -- Congrats you LIVE!
                local drownable = inst.components.drownable
                inst.sg:GoToState("washed_ashore")
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end

            if inst.sg.statemem.isteleporting then
                DoneTeleporting(inst)
            end

            inst.DynamicShadow:Enable(true)
            inst:ShowHUD(true)
        end,
    },

    -- Blood for the blood god
    State{
        name = "death_drown",
        tags = { "busy", "dead", "canrotate", "nopredict", "nomorph", "drowning", "nointerrupt" },

        onenter = function(inst, data)
            assert(inst.deathcause ~= nil, "Entered death state without cause.")

            ClearStatusAilments(inst)
            ForceStopHeavyLifting(inst)

            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()
            inst:ClearBufferedAction()

            inst.components.burnable:Extinguish()

            if HUMAN_MEAT_ENABLED then
                inst.components.inventory:GiveItem(SpawnPrefab("humanmeat")) -- Drop some player meat!
            end

            inst.components.inventory:DropEverything(true)

            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:RemotePausePrediction()
                inst.components.playercontroller:Enable(false)
            end

            if inst.ghostenabled then
                inst.components.cursable:Died()
                if inst:HasTag("wonkey") then
                    inst:ChangeFromMonkey()
                else
                    inst:PushEvent("makeplayerghost", { skeleton = TheWorld.Map:IsPassableAtPoint(inst.Transform:GetWorldPosition()) }) -- if we are not on valid ground then don't drop a skeleton
                end
            else
                inst.AnimState:SetPercent(inst.deathanimoverride or "death", 1)
                inst:PushEvent("playerdied", { skeleton = false })
            end
        end,
    },

    State{
        name = "jumpinbermuda",
        tags = {"doing", "busy", "canrotate", "nopredict", "nomorph"},

        onenter = function(inst, data)
            ToggleOffPhysics(inst) -- QOL: Immunity to waves and prevents the player acting as an invisible obstacle when hidden...
            inst.components.locomotor:Stop()

            inst.sg.statemem.target = data.teleporter

            if data.teleporter ~= nil and data.teleporter.components.teleporter ~= nil then
                data.teleporter.components.teleporter:RegisterTeleportee(inst)
            end

            inst.sg.statemem.teleportarrivestate = "jumpoutbermuda" -- for teleporter cmp

            InstallBermudaFX(inst)
        end,

        onexit = function(inst)
            RemoveBermudaFX(inst)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end

            if inst.sg.statemem.isteleporting then
                inst.sg:RemoveStateTag("temp_invincible")
                if TUNING.DO_SEA_DAMAGE_TO_BOAT and inst.components.sailor.boat and
                inst.components.sailor.boat.components.boathealth then
                    inst.components.sailor.boat.components.boathealth:SetInvincible(false)
                end
                if inst.components.playercontroller ~= nil then
                    inst.components.playercontroller:Enable(true)
                end
                inst:Show()
                inst.DynamicShadow:Enable(true)
            elseif inst.sg.statemem.target ~= nil
                and inst.sg.statemem.target:IsValid()
                and inst.sg.statemem.target.components.teleporter ~= nil then
                inst.sg.statemem.target.components.teleporter:UnregisterTeleportee(inst)
            end
        end,

        timeline = {
            -- this is just hacked in here to make the sound play BEFORE the player hits the wormhole
            TimeEvent(30*FRAMES, function(inst)
                inst:Hide()
                RemoveBermudaFX(inst)
                inst.sg:AddStateTag("temp_invincible")
                SpawnPrefab("pixel_out").Transform:SetPosition(inst:GetPosition():Get())
            end),

            TimeEvent(40*FRAMES, function(inst)
                if inst.sg.statemem.target ~= nil
                    and inst.sg.statemem.target:IsValid()
                    and inst.sg.statemem.target.components.teleporter ~= nil then
                    -- Unregister first before actually teleporting
                    inst.sg.statemem.target.components.teleporter:UnregisterTeleportee(inst)
                    if inst.sg.statemem.target.components.teleporter:Activate(inst) then
                        inst.sg.statemem.target:PushEvent("starttravelsound", inst)
                        inst.sg.statemem.isteleporting = true
                        inst.sg:AddStateTag("temp_invincible")

                        if TUNING.DO_SEA_DAMAGE_TO_BOAT and inst.components.sailor.boat and
                        inst.components.sailor.boat.components.boathealth then
                            inst.components.sailor.boat.components.boathealth:SetInvincible(true)
                        end

                        if inst.components.playercontroller ~= nil then
                            inst.components.playercontroller:Enable(false)
                        end
                        inst:Hide()
                        inst.DynamicShadow:Enable(false)
                        return
                    end
                    inst.sg:GoToState("jumpoutbermuda")
                end
            end),
        },
    },

    State{
        name = "jumpoutbermuda",
        tags = {"doing", "busy", "canrotate", "nopredict", "nomorph"},

        onenter = function(inst, data)
            ToggleOffPhysics(inst) -- QOL: Immunity to waves and prevents the player acting as an invisible obstacle when hidden...
            inst.components.locomotor:Stop()

            SpawnPrefab("pixel_in").Transform:SetPosition(inst:GetPosition():Get())
        end,

        onexit = function(inst)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end
            RemoveBermudaFX(inst)
            inst:Show()
        end,

        timeline =
        {

            TimeEvent(10*FRAMES, function(inst)
                inst:Show()
                InstallBermudaFX(inst)
                -- inst.components.health:SetInvincible(false)
            end),

            TimeEvent(35*FRAMES, function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "vacuumedin",
        tags = {"busy", "vacuum_in", "canrotate", "pausepredict"},

        onenter = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:RemotePausePrediction()
            end
            inst.AnimState:PlayAnimation("flying_pre")
            inst.AnimState:PlayAnimation("flying_loop", true)

            RaiseFlyingPlayer(inst)
        end,

        onexit = function(inst)
            if inst.components.Health and not inst.components.health:IsDead() and IsOnOcean(inst) then
                inst.components.health:Drown(true)
            end
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
            LandFlyingPlayer(inst)
        end,
    },

    State{
        name = "vacuumedheld",
        tags = {"busy", "vacuum_held", "pausepredict"},

        onenter = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:RemotePausePrediction()
            end
            inst.DynamicShadow:Enable(false)
            inst:Hide()

            RaiseFlyingPlayer(inst)
        end,

        onexit = function(inst)
            inst:Show()
            inst.DynamicShadow:Enable(true)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end

            LandFlyingPlayer(inst)
        end,
    },

    State{
        name = "vacuumedout",
        tags = {"busy", "vacuum_out", "canrotate", "pausepredict"},

        onenter = function(inst, data)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:RemotePausePrediction()
            end
            inst.AnimState:PlayAnimation("flying_loop", true)

            inst.sg.mem.angle = math.random(360)
            inst.sg.mem.speed = data.speed

            local rx, rz = math.rotate(math.rcos(inst.sg.mem.angle) * inst.sg.mem.speed, math.rsin(inst.sg.mem.angle) * inst.sg.mem.speed, math.rad(inst.Transform:GetRotation()))

            inst.Physics:SetMotorVelOverride(rx, 0, rz)

            inst.sg:SetTimeout(FRAMES*10)
        end,


        onupdate = function(inst)
            local rx, rz = math.rotate(math.rcos(inst.sg.mem.angle) * inst.sg.mem.speed, math.rsin(inst.sg.mem.angle) * inst.sg.mem.speed, math.rad(inst.Transform:GetRotation()))

            inst.Physics:SetMotorVelOverride(rx, 0, rz)
        end,

        ontimeout = function(inst)
            inst.Physics:ClearMotorVelOverride()

            local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if item and not item:HasTag("irreplaceable") and not inst:HasTag("stronggrip") and not (inst:HasTag("clockmaker") and item:HasTag("pocketwatch")) then
                inst.components.inventory:DropItem(item)
            end

            for i = 1, 4 do
                item = nil
                local slot = math.random(1,inst.components.inventory:GetNumSlots())
                item = inst.components.inventory:GetItemInSlot(slot)
                if item and not item:HasTag("irreplaceable") and not (inst:HasTag("clockmaker") and item:HasTag("pocketwatch")) then
                    inst.components.inventory:DropItem(item, true, true)
                end
            end

            inst.Physics:SetMotorVel(0,0,0)
            inst.sg:GoToState("vacuumedland")
            inst:DoTaskInTime(5, function(inst) inst:RemoveTag("NOVACUUM") end)
        end,

        onexit = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
        end,
    },

    State{
        name = "vacuumedland",
        tags = {"busy", "pausepredict"},

        onenter = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(false)
                inst.components.playercontroller:RemotePausePrediction()
            end
            inst.AnimState:PlayAnimation("flying_land")
            inst.sg:AddStateTag("temp_invincible")
        end,

        onexit = function(inst)
            if inst.components.playercontroller ~= nil then
                inst.components.playercontroller:Enable(true)
            end
            inst.sg:RemoveStateTag("temp_invincible")
        end,

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "throw",
        tags = {"attack", "notalking", "abouttoattack"},

        onenter = function(inst)
            if inst:HasTag("_sailor") and inst:HasTag("sailing") then
                inst.sg:AddStateTag("boating")
            end
            inst.sg.statemem.target = inst.components.combat.target
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("throw")

            if inst.components.combat.target then
                if inst.components.combat.target and inst.components.combat.target:IsValid() then
                    inst:FacePoint(inst.components.combat.target.Transform:GetWorldPosition())
                end
            end

        end,

        timeline=
        {
            TimeEvent(7*FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.sg:RemoveStateTag("abouttoattack")
            end),
            TimeEvent(11*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },

        events=
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "speargun",
        tags = {"attack", "notalking", "abouttoattack"},

        onenter = function(inst)
            if inst:HasTag("_sailor") and inst:HasTag("sailing") then
                inst.sg:AddStateTag("boating")
            end
            inst.sg.statemem.target = inst.components.combat.target
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("speargun")

            if inst.components.combat.target then
                if inst.components.combat.target and inst.components.combat.target:IsValid() then
                    inst:FacePoint(inst.components.combat.target.Transform:GetWorldPosition())
                end
            end
        end,

        timeline=
        {

            TimeEvent(12*FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.sg:RemoveStateTag("abouttoattack")
                inst.SoundEmitter:PlaySound("ia/common/use_speargun", nil, nil, true)
            end),
            TimeEvent(20*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },

        events=
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "cannon",
        tags = {"busy", "doing"},

        onenter = function(inst)
            if inst:HasTag("_sailor") and inst:HasTag("sailing") then
                inst.sg:AddStateTag("boating")
            end
            inst.AnimState:PlayAnimation("give")
        end,

        timeline = {
            TimeEvent(13*FRAMES, function(inst)
                -- Light Cannon
                inst.sg:RemoveStateTag("abouttoattack")
                inst:PerformBufferedAction()
            end),
            TimeEvent(15*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "peertelescope",
        tags = {"doing", "busy", "canrotate", "nopredict"},

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            local act = inst:GetBufferedAction()

            if act then
            local pt = act.GetActionPoint and act:GetActionPoint() or act.pos
                if pt then
                    inst:ForceFacePoint(pt.x, pt.y, pt.z)
                end
            end
            inst.AnimState:PlayAnimation("telescope", false)
            inst.AnimState:PushAnimation("telescope_pst", false)

            inst.components.locomotor:Stop()
        end,

        timeline =
        {
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/common/use_spyglass", nil, nil, true) end),
        },

        events = {
            EventHandler("animover", function(inst)
                if not inst.AnimState:AnimDone() then -- skip the second callback
                    inst:PerformBufferedAction()
                    -- if ThePlayer and inst == ThePlayer and ThePlayer.HUD and ThePlayer.HUD.controls then
                        -- ThePlayer.HUD.controls:ShowMap()
                    -- end
                end
            end ),
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end ),
        },
    },

    State {
        name = "fish_flotsam",
        tags = {"busy", "fishing"},
        onenter = function(inst)
            inst.sg.statemem.tool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            local act = inst:GetBufferedAction()
            -- MASSIVE HACK! TODO: DONT DO THIS H E R E -Half
            if act ~= nil and act.target ~= nil and act.action ~= nil and act.action.maxdistance ~= nil and inst:GetDistanceSqToInst(act.target) > act.action.maxdistance^2 then
                if inst.sg.statemem.tool ~= nil and inst.sg.statemem.tool:IsValid() and inst.sg.statemem.tool.components.fishingrod ~= nil then
                    inst.sg.statemem.tool.components.fishingrod:StopFishing()
                end
                inst:PushEvent("actionfailed", { action = act, reason = "TOOFAR" })
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle")
                return
            end
            inst.components.locomotor:Stop()
            inst.AnimState:Hide("RIPPLES")
            inst.AnimState:PlayAnimation("fishing_pre") -- 24
            inst.AnimState:PushAnimation("fishing_cast")
            inst.AnimState:PushAnimation("fishing_idle") -- 38
            inst.AnimState:PushAnimation("fishing_idle")
            inst.AnimState:PushAnimation("bite_heavy_pre") -- 4
            inst.AnimState:PushAnimation("bite_heavy_loop") -- 13
            inst.AnimState:PushAnimation("bite_heavy_loop")
            inst.AnimState:PushAnimation("fish_catch", false) -- 13
        end,

        onexit = function(inst)
            if inst.sg.statemem.tool ~= nil and inst.sg.statemem.tool:IsValid() and inst.sg.statemem.tool.components.fishingrod ~= nil then
                inst.sg.statemem.tool.components.fishingrod:StopFishing()
            end
        end,

        timeline =
        {
            TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_cast", nil, nil, true) end),
            TimeEvent(15*FRAMES, function(inst) inst:PerformBufferedAction() end),
            TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_baitsplash", nil, nil, true) end),
            TimeEvent(100*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishinwater", "splash", nil, true)
                inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_strain", "strain", nil, true)
            end),
            TimeEvent(130*FRAMES, function(inst)
                inst.SoundEmitter:KillSound("splash")
                inst.SoundEmitter:KillSound("strain")
            end),
            TimeEvent(138*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishcaught", nil, nil, true) end),
            TimeEvent(143*FRAMES, function(inst) inst.sg:RemoveStateTag("fishing") end),
            TimeEvent(149*FRAMES, function(inst)
                if inst.sg.statemem.tool ~= nil and inst.sg.statemem.tool.components.fishingrod ~= nil then
                    inst.sg.statemem.tool.components.fishingrod:CollectFlotsam()
                end
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },

    },

    State{
        name = "run_monkeyking_start",
        tags = {"moving", "running", "canrotate", "monkey", "autopredict"},

        onenter = function(inst)
            ConfigureRunState(inst)
            if not inst.sg.statemem.normal then
                inst.sg:GoToState("run")
                return
            end

            inst.Transform:SetPredictedSixFaced()
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_monkeyking_pre")
            inst.SoundEmitter:PlaySound("ia/characters/wilbur/walktorun", nil, nil, true) -- Note: soundname removed due to issues
        end,

        onupdate = function(inst)
            if inst.components.locomotor:GetTimeMoving() < TUNING.WILBUR_TIME_TO_RUN then
                inst.sg:GoToState("run")
            end
        end,

        events =
        {
            EventHandler("gogglevision", function(inst, data)
                if not data.enabled and inst:GetStormLevel() >= TUNING.SANDSTORM_FULL_LEVEL then
                    inst.sg:GoToState("run")
                end
            end),
            EventHandler("sandstormlevel", function(inst, data)
                if data.level >= TUNING.SANDSTORM_FULL_LEVEL and not inst.components.playervision:HasGoggleVision() then
                    inst.sg:GoToState("run")
                end
            end),
            EventHandler("carefulwalking", function(inst, data)
                if data.careful then
                    inst.sg:GoToState("run")
                end
            end),
            EventHandler("animover", function(inst)
                inst.sg.statemem.monkeyrunning = true
                inst.sg:GoToState("run_monkeyking")
            end),
        },

        onexit = function(inst)
            if not inst.sg.statemem.monkeyrunning then

                inst.Transform:ClearPredictedFacingModel()
            end
        end,
    },

    State{
        name = "run_monkeyking",
        tags = {"moving", "running", "canrotate", "monkey", "autopredict"},

        onenter = function(inst)
            ConfigureRunState(inst)
            if not inst.sg.statemem.normal then
                inst.sg:GoToState("run")
                return
            end

            inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED + TUNING.WILBUR_SPEED_BONUS
            inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE * TUNING.WILBUR_RUN_HUNGER_RATE_MULT)
            inst.Transform:SetPredictedSixFaced()
            inst.components.locomotor:RunForward()

            if not inst.AnimState:IsCurrentAnimation("run_monkeyking_loop") then
                inst.AnimState:PlayAnimation("run_monkeyking_loop", true)
            end

            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("TAIL_carry")
                inst.AnimState:Hide("TAIL_normal")
            else
                inst.AnimState:Hide("TAIL_carry")
                inst.AnimState:Show("TAIL_normal")
            end

            -- V2C: adding half a frame time so it rounds up
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() + .5 * FRAMES)
        end,

        timeline =
        {
            TimeEvent(4*FRAMES, function(inst) PlayFootstep(inst, 0.5, true) end),
            TimeEvent(5*FRAMES, function(inst) PlayFootstep(inst, 0.5, true) DoFoleySounds(inst) end),
            TimeEvent(10*FRAMES, function(inst) PlayFootstep(inst, 0.5, true) end),
            TimeEvent(11*FRAMES, function(inst) PlayFootstep(inst, 0.5, true) end),
        },

        onupdate = function(inst)
            if inst.components.locomotor:GetTimeMoving() < TUNING.WILBUR_TIME_TO_RUN then
                inst.sg:GoToState("run")
                return
            end
            inst.components.locomotor:RunForward()
        end,

        events =
        {
            EventHandler("gogglevision", function(inst, data)
                if not data.enabled and inst:GetStormLevel() >= TUNING.SANDSTORM_FULL_LEVEL then
                    inst.sg:GoToState("run")
                end
            end),
            EventHandler("sandstormlevel", function(inst, data)
                if data.level >= TUNING.SANDSTORM_FULL_LEVEL and not inst.components.playervision:HasGoggleVision() then
                    inst.sg:GoToState("run")
                end
            end),
            EventHandler("carefulwalking", function(inst, data)
                if data.careful then
                    inst.sg:GoToState("run")
                end
            end),
            EventHandler("equip", function(inst, data)
                inst.AnimState:Show("TAIL_carry")
                inst.AnimState:Hide("TAIL_normal")
            end),
            EventHandler("unequip", function(inst, data)
                inst.AnimState:Hide("TAIL_carry")
                inst.AnimState:Show("TAIL_normal")
            end),
        },

        ontimeout = function(inst)
            inst.sg.statemem.monkeyrunning = true
            inst.sg:GoToState("run_monkeyking")
        end,

        onexit = function(inst)
            if not inst.sg.statemem.monkeyrunning then
                inst.AnimState:Hide("TAIL_carry")
                inst.AnimState:Show("TAIL_normal")

                inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED + TUNING.WILBUR_WALK_SPEED_PENALTY
                inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE)
                inst.Transform:ClearPredictedFacingModel()
            end
        end,
    },

    State{
        name = "fishing_retrieve",
        -- tags = {"prefish", "fishing", "boating"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fishing_pre") -- 14
            inst.AnimState:PushAnimation("fishing_cast") -- 8-11, new in DST, contains part of old fishing_pre
            inst.AnimState:PushAnimation("bite_heavy_pre") -- 5
            inst.AnimState:PushAnimation("bite_heavy_loop") -- 14
            inst.AnimState:PushAnimation("fish_catch", false)
            inst.AnimState:OverrideSymbol("fish01", "graves_water_crate", "fish01")

            inst.sg.statemem.tool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        end,

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("fish01")
            local rod = inst.sg.statemem.tool ~= nil and inst.sg.statemem.tool:IsValid() and inst.sg.statemem.tool.components.fishingrod or nil
            if rod ~= nil then
                if rod.target ~= nil and rod.target.retrieved then
                    rod:Retrieve()
                else
                    rod:StopFishing()
                end
            end
        end,

        timeline =
        {
            TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_cast", nil, nil, true) end),
            TimeEvent(15*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_baitsplash", nil, nil, true)
                inst:PerformBufferedAction()
            end),
            TimeEvent(49*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishcaught", nil, nil, true) end),
            TimeEvent(55*FRAMES, function(inst)
                local rod = inst.sg.statemem.tool ~= nil and inst.sg.statemem.tool.components.fishingrod
                if rod ~= nil then
                    rod.target:PushEvent("retrieve")
                end
            end),
            TimeEvent(64*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishland", nil, nil, true) end),
            TimeEvent(65*FRAMES, function(inst)
                local rod = inst.sg.statemem.tool ~= nil and inst.sg.statemem.tool.components.fishingrod
                if rod ~= nil then
                    rod:Retrieve()
                end
            end),
        },

        events=
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end ),
        },
    },

    State{
        name = "player_SWportal_mounted",
        tags = {"busy"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("dismount")
            inst.SoundEmitter:PlaySound("dontstarve/beefalo/saddle/dismount")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.components.rider:ActualDismount()
                inst.sg:GoToState("player_portal_shipwrecked_pre")
            end ),
        }
    },

    State{
        name = "player_shipwrecked_portal_pre",
        tags = {"doing", "busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_loop")
            inst.sg:AddStateTag("temp_invincible")

            inst.sg:SetTimeout(3.5)
        end,

        timeline =
        {

            TimeEvent(30*FRAMES, function(inst)
                inst.DynamicShadow:Enable(false)
            end),
            TimeEvent(30*FRAMES, function(inst)
                inst.AnimState:PlayAnimation("jump")
                local portal = SpawnPrefab("wormhole_shipwrecked_fx")
                portal.Transform:SetPosition((inst:GetPosition() - (TheCamera:GetDownVec() * 0.1)):Get())
            end),
        },

        onexit = function(inst)
            inst.sg:RemoveStateTag("temp_invincible")
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("player_shipwrecked_portal_loop")
        end,
    },

    State{
        name = "player_shipwrecked_portal_loop",
        tags = {"doing", "busy", "canrotate"},

        onenter = function(inst)

            inst.sg:AddStateTag("temp_invincible")
            inst.AnimState:AddOverrideBuild("player_portal_shipwrecked")
            inst.AnimState:PlayAnimation("shipwrecked_portal_pre")
            inst.AnimState:PushAnimation("shipwrecked_portal_loop", true)

            local target = GetClosestInstWithTag("shipwrecked_portal", inst, 5)
            inst.sg.statemem.target = target

            inst.sg.statemem.target:Hide()
            ChangeToInventoryPhysics(inst.sg.statemem.target)
            inst.Transform:SetPosition(inst.sg.statemem.target:GetPosition():Get())

            local facepoint = (inst.sg.statemem.target:GetPosition() + TheCamera:GetRightVec())
            inst:ForceFacePoint(facepoint:Get())

            inst.SoundEmitter:PlaySound("ia/common/portal/sit")
                -- if false then
            inst.SoundEmitter:PlaySound("ia/common/portal/ride_LP", "ride_lp")

            inst.SoundEmitter:PlaySound("ia/common/portal/music_LP", "music_lp")
                -- if true then
            inst.SoundEmitter:PlaySound("ia/common/crafted/skyworthy/LP", "ride_lp")
        end,

        onexit = function(inst)
            inst.sg:RemoveStateTag("temp_invincible")
            inst.sg.statemem.target:Show()
            ChangeToObstaclePhysics(inst.sg.statemem.target)
            inst.SoundEmitter:KillSound("music_lp")
            inst.SoundEmitter:KillSound("ride_lp")
        end,
    },

    State{
        name = "hitcoastline",
        tags = { "busy", "nopredict", "nomorph", "drowning", "nointerrupt" },

        onenter = function(inst, shore_pt)
            ForceStopHeavyLifting(inst)
            inst:ClearBufferedAction()

            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()

            inst.AnimState:PlayAnimation("dozy")
            inst.SoundEmitter:PlaySound((inst.talker_path_override or "dontstarve/characters/")..(inst.soundsname or inst.prefab).."/sinking")

            if shore_pt ~= nil then
                inst.components.drydrownable:OnHitCoastline(shore_pt:Get())
            else
                inst.components.drydrownable:OnHitCoastline()
            end
            inst.DynamicShadow:Enable(false)

            local sand = SpawnPrefab("townportalsandcoffin_fx")
            sand.Transform:SetPosition(inst.Transform:GetWorldPosition())

            inst:ShowHUD(false)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    local puddle = SpawnPrefab("washashore_puddle_fx")
                    puddle.Transform:SetPosition(inst.Transform:GetWorldPosition())
                    StartTeleporting(inst)
                    inst.components.drydrownable:WashAway()
                end
            end),

            EventHandler("on_washed_away", function(inst)
                inst.sg:GoToState("washed_away")
            end),
        },

        onexit = function(inst)
            if inst.sg.statemem.isphysicstoggle then
                ToggleOnPhysics(inst)
            end

            if inst.sg.statemem.isteleporting then
                DoneTeleporting(inst)
            end

            inst.DynamicShadow:Enable(true)
            inst:ShowHUD(true)
        end,
    },

    State{
        name = "washed_away",
        tags = { "busy", "canrotate", "nopredict", "nomorph", "drowning", "nointerrupt" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("wakeup")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },


    },
}

for k, v in pairs(actionhandlers) do
    assert(v:is_a(ActionHandler), "Non-action handler added in mod actionhandler table!")
    sg.actionhandlers[v.action] = v
end

for k, v in pairs(events) do
    assert(v:is_a(EventHandler), "Non-event added in mod events table!")
    sg.events[v.name] = v
end

for k, v in pairs(states) do
    assert(v:is_a(State), "Non-state added in mod state table!")
    sg.states[v.name] = v
end

end)