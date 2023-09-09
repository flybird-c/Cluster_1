local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

IAENV.AddStategraphPostInit("wilson_client", function(sg)

local TIMEOUT = 2

local _run_start_timeevent_2 = sg.states["run_start"].timeline[2].fn
local DoFoleySounds = UpvalueHacker.GetUpvalue(_run_start_timeevent_2, "DoFoleySounds")

local _run_monkey_start_onenter = sg.states["run_monkey_start"].onenter
local ConfigureRunState = UpvalueHacker.GetUpvalue(_run_monkey_start_onenter, "ConfigureRunState")

-- NOTE: If you have a sound that plays both in SGwilson and SGwilson_client
-- make sure the 4th parameter is true in Playsound for both
-- to prevent the sound from playing twice (this disables the sound sync)
-- PlayFootstep also has a third param that does the same

--STATEGRAPH PATCHES, not poluting this files namespace though.
do
    local _locomote_eventhandler = sg.events.locomote.fn
    sg.events.locomote.fn = function(inst, data)
        if inst.sg:HasStateTag("busy") or inst:HasTag("busy") then
            return
        end
        local is_attacking = inst.sg:HasStateTag("attack")

        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running")
        local should_move = inst.components.locomotor:WantsToMoveForward()
        if inst.replica.sailor and inst.replica.sailor:GetBoat() and not inst.replica.sailor:GetBoat().replica.sailable then
            should_move = false
        end

        local should_run = inst.components.locomotor:WantsToRun()
        local hasSail = inst.replica.sailor and inst.replica.sailor:GetBoat() and inst.replica.sailor:GetBoat().replica.sailable:GetIsSailEquipped() or false


        if inst:HasTag("_sailor") and inst:HasTag("sailing") then
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
                        inst.sg:GoToState("rowl_start_ia")
                    end
                end
            end
            return
        end

        _locomote_eventhandler(inst, data)
    end
end

do
	local _attack_actionhandler = sg.actionhandlers[ACTIONS.ATTACK].deststate
	sg.actionhandlers[ACTIONS.ATTACK].deststate = function(inst, action, ...)
		if not (inst.sg:HasStateTag("attack") and action.target == inst.sg.statemem.attacktarget or inst.replica.health:IsDead()) then
			local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if equip and equip:HasTag("speargun") then
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
		return (action.target ~= nil and action.target.replica.inventoryitem and action.target.replica.inventoryitem:CanLongPickup() and "dolongaction") or _pickup_actionhandler(inst, action, ...)
	end
end

do
    local _run_start_onenter = sg.states["run_start"].onenter
    sg.states["run_start"].onenter = function(inst, ...)
        ConfigureRunState(inst)
        if inst.sg.statemem.normal and inst:HasTag("monkeyking") and inst.components.locomotor:GetTimeMoving() >= TUNING.WILBUR_TIME_TO_RUN then
            inst.sg:GoToState("run_monkeyking") --resuming after brief stop from changing directions, or resuming prediction after running into obstacle
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

	local _attack_onenter = sg.states.attack.onenter
	sg.states.attack.onenter = function(inst, data)

		local equip = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
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
		if action.target and action.target:HasTag("FISH_workable") then
			return "fishing_retrieve"
		end
		if type(_fish_actionhandler) == "function" then
			return _fish_actionhandler(inst, action, ...)
		end
		return _fish_actionhandler
	end
end


local actionhandlers = {
    ActionHandler(ACTIONS.THROW, "throw"),
    ActionHandler(ACTIONS.LAUNCH_THROWABLE, "cannon"),
    ActionHandler(ACTIONS.RETRIEVE, "dolongaction"),
    ActionHandler(ACTIONS.STICK, "doshortaction"),
    ActionHandler(ACTIONS.HACK, function(inst)
        if inst:HasTag("beaver") then
            return not inst.sg:HasStateTag("gnawing") and "gnaw" or nil
        end
        return not inst.sg:HasStateTag("prehack") and "hack_start" or nil
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
    EventHandler("sailequipped", function(inst)
        if inst.sg:HasStateTag("rowing") then
            inst.sg:GoToState("sail_ia")
        end
    end),

    EventHandler("sailunequipped", function(inst)
        if inst.sg:HasStateTag("sailing") then
            inst.sg:GoToState("row_ia")

            if not inst:HasTag("mime") then
                inst.AnimState:OverrideSymbol("paddle", "swap_paddle", "paddle")
            end
            --TODO allow custom paddles?
            inst.AnimState:OverrideSymbol("wake_paddle", "swap_paddle", "wake_paddle")
        end
    end),
}

local states = {
    State{
        name = "rowl_start_ia",
        tags = { "moving", "running", "rowing", "boating", "canrotate"},

        onenter = function(inst)
            local boat = inst.replica.sailor:GetBoat()

            inst.components.locomotor:RunForward()

            if not inst:HasTag("mime") then
                inst.AnimState:OverrideSymbol("paddle", "swap_paddle", "paddle")
            end
            --TODO allow custom paddles?
            inst.AnimState:OverrideSymbol("wake_paddle", "swap_paddle", "wake_paddle")

            local oar = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            inst.AnimState:PlayAnimation(oar and oar:HasTag("oar") and "row_pre" or "row_ia_pre")
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayPreRowAnims()
            end

            DoFoleySounds(inst)
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        events = {
            EventHandler("animover", function(inst) inst.sg:GoToState("row_ia") end),
        },
    },

    State{
        name = "row_ia",
        tags = { "moving", "running", "rowing", "boating", "canrotate"},

        onenter = function(inst)
            local boat = inst.replica.sailor:GetBoat()

            if boat and boat.replica.sailable and boat.replica.sailable.creaksound then
                inst.SoundEmitter:PlaySound(boat.replica.sailable.creaksound, nil, nil, true)
            end
            inst.SoundEmitter:PlaySound("ia/common/boat/paddle", nil, nil, true)
            DoFoleySounds(inst)

            local oar = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            local anim = oar and oar:HasTag("oar") and "row_medium" or "row_loop"
            if not inst.AnimState:IsCurrentAnimation(anim) then
				--RoT has row_medium, which is identical but uses the equipped item as paddle
                inst.AnimState:PlayAnimation(anim, true)
            end

            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayRowAnims()
            end
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayRowAnims()
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        onexit = function(inst)
            local boat = inst.replica.sailor:GetBoat()
            if inst.sg.nextstate ~= "row_ia" and inst.sg.nextstate ~= "sail_ia" then
                inst.components.locomotor:Stop(nil, true)
                if inst.sg.nextstate ~= "row_stop_ia" and inst.sg.nextstate ~= "sail_stop_ia" then
                    if boat and boat.replica.sailable then
                        boat.replica.sailable:PlayIdleAnims()
                    end
                end
            end
        end,

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
        tags = { "canrotate", "idle"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            local boat = inst.replica.sailor:GetBoat()

            local oar = inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            inst.AnimState:PlayAnimation(oar and oar:HasTag("oar") and "row_idle_pst" or "row_pst")
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayPostRowAnims()
            end
        end,

        events = {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "sail_start_ia",
        tags = {"moving", "running", "canrotate", "boating", "sailing"},

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
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        events = {
            EventHandler("animover", function(inst) inst.sg:GoToState("sail_ia") end),
        },
    },

    State{
        name = "sail_ia",
        tags = {"canrotate", "moving", "running", "boating", "sailing"},

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


            local anim = boat and boat.replica.sailable and boat.replica.sailable.sailloopanim or "sail_loop"
            if not inst.AnimState:IsCurrentAnimation(anim) then
                if anim ~= "sail_loop" or inst.has_sailface then
                    inst.AnimState:PlayAnimation(anim, true)
                else
                    inst.AnimState:PlayAnimation("sail_ia_loop", true)
                end
            end
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlaySailAnims()
            end
            inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
        end,

        onexit = function(inst)
            local boat = inst.replica.sailor:GetBoat()
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
        end,

        events = {
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
        tags = {"canrotate", "idle"},

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
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "hack_start",
        tags = {"prehack", "hacking", "working"},

        onenter = function(inst)
            inst.components.locomotor:Stop()

            if not inst:HasTag("working") then
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
                    inst.AnimState:PushAnimation("hack_lag", false)
                else
                    inst.AnimState:PlayAnimation("chop_pre")
                    inst.AnimState:PushAnimation("chop_lag", false)
                end
            end

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
            if inst:HasTag("working") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end
    },

    -- BERMUDA STATES

    State{
        name = "jumpinbermuda",
        tags = {"doing", "busy", "canrotate"},

        onenter = function(inst, data)
            inst.components.locomotor:Stop()

            inst.AnimState:Pause()

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
            if inst:HasTag("doing") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "speargun",
        tags = {"attack", "notalking", "abouttoattack"},

        onenter = function(inst)
            if inst:HasTag("_sailor") and inst:HasTag("sailing") then
                inst.sg:AddStateTag("boating")
            end
			local target = inst.replica.combat:GetTarget()
            inst.sg.statemem.target = target
            inst.replica.combat:StartAttack()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("speargun")

			if target and target:IsValid() then
				inst:FacePoint(target.Transform:GetWorldPosition())
            end
        end,

        timeline=
        {

            TimeEvent(12*FRAMES, function(inst)
                inst:PerformPreviewBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
                inst.SoundEmitter:PlaySound("ia/common/use_speargun", nil, nil, true)
            end),
            TimeEvent(20*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
                inst.replica.combat:CancelAttack()
            end
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

            inst:PerformPreviewBufferedAction()
        end,

        onupdate = function(inst)
            if inst:HasTag("doing") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
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

    State{
        name = "throw",
        tags = {"attack", "notalking", "abouttoattack"},

        onenter = function(inst)
            if inst:HasTag("_sailor") and inst:HasTag("sailing") then
                inst.sg:AddStateTag("boating")
            end
			local target = inst.replica.combat:GetTarget()
            inst.sg.statemem.target = target
            inst.replica.combat:StartAttack()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("throw")

			if target and target:IsValid() then
				inst:FacePoint(inst.replica.combat:GetTarget().Transform:GetWorldPosition())
            end

        end,

        timeline = {
            TimeEvent(7*FRAMES, function(inst)
                inst:PerformPreviewBufferedAction()
                inst.sg:RemoveStateTag("abouttoattack")
            end),
            TimeEvent(11*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            if inst.sg:HasStateTag("abouttoattack") and inst.replica.combat ~= nil then
                inst.replica.combat:CancelAttack()
            end
        end,
    },

    State{
        name = "curepoison",
        tags = { "busy" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("quick_eat_pre")
            inst.AnimState:PushAnimation("quick_eat_lag", false)

            inst:PerformPreviewBufferedAction()
            inst.sg:SetTimeout(TIMEOUT)
        end,

        onupdate = function(inst)
            if inst:HasTag("busy") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        ontimeout = function(inst)
            inst:ClearBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "cannon",
        tags = {"busy", "doing"},

        onenter = function(inst)
            if inst:HasTag("_sailor") and inst:HasTag("sailing") then
                inst.sg:AddStateTag("boating")
            end
            inst.AnimState:PlayAnimation("give")

            inst:PerformPreviewBufferedAction()
        end,

        onupdate = function(inst)
            if inst:HasTag("doing") then
                if inst.entity:FlattenMovementPrediction() then
                    inst.sg:GoToState("idle", "noanim")
                end
            elseif inst.bufferedaction == nil then
                inst.sg:GoToState("idle")
            end
        end,

        timeline = {
            TimeEvent(13*FRAMES, function(inst)
                --Light Cannon
                inst.sg:RemoveStateTag("abouttoattack")
                inst:PerformPreviewBufferedAction()
            end),
            TimeEvent(15*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },

        events = {
            EventHandler("animover", function(inst)
                inst:PerformBufferedAction()
                inst.sg:GoToState("idle")
            end),

            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst:ClearBufferedAction()
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "peertelescope",
        tags = {"doing", "busy", "canrotate", "nopredict"},

        onenter = function(inst)
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
                if not inst.AnimState:AnimDone() then
					inst:PerformPreviewBufferedAction()
					-- if ThePlayer and inst == ThePlayer and ThePlayer.HUD and ThePlayer.HUD.controls then
						-- ThePlayer.HUD.controls:ShowMap()
					-- end
				end
            end ),
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end ),
        },
    },

    State {
        name = "fish_flotsam",
        tags = {"busy", "fishing"},
        onenter = function(inst)
            local act = inst:GetBufferedAction()
            if act ~= nil and act.target ~= nil and act.action ~= nil and act.action.maxdistance ~= nil and inst:GetDistanceSqToInst(act.target) > act.action.maxdistance^2 then
                inst:PushEvent("actionfailed", { action = act, reason = "TOOFAR" })
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle")
                return
            end
            inst.components.locomotor:Stop()
            inst.AnimState:Hide("RIPPLES")
            inst.AnimState:PlayAnimation("fishing_pre") --24
            inst.AnimState:PushAnimation("fishing_cast")--new in DST, contains part of old fishing_pre
            inst.AnimState:PushAnimation("fishing_idle") --38
            inst.AnimState:PushAnimation("fishing_idle")
            inst.AnimState:PushAnimation("bite_heavy_pre") --4
            inst.AnimState:PushAnimation("bite_heavy_loop") --13
            inst.AnimState:PushAnimation("bite_heavy_loop")
            inst.AnimState:PushAnimation("fish_catch", false) --13
        end,

        timeline =
        {
            TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_cast", nil, nil, true) end),
            TimeEvent(15*FRAMES, function(inst) inst:PerformBufferedAction() end),
            TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_baitsplash", nil, nil, true) end),
            TimeEvent(100*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishinwater", "splash", nil, true)
                inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_strain", "splash", nil, true)
            end),
            TimeEvent(130*FRAMES, function(inst)
                inst.SoundEmitter:KillSound("splash")
                inst.SoundEmitter:KillSound("strain")
            end),
            TimeEvent(138*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishcaught", nil, nil, true) end),
            TimeEvent(143*FRAMES, function(inst) inst.sg:RemoveStateTag("fishing") end),
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
            inst.SoundEmitter:PlaySound("ia/characters/wilbur/walktorun", nil, nil, true)
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

            inst.components.locomotor.predictrunspeed = TUNING.WILSON_RUN_SPEED + TUNING.WILBUR_SPEED_BONUS
            inst.Transform:SetPredictedSixFaced()
            inst.components.locomotor:RunForward()

            if not inst.AnimState:IsCurrentAnimation("run_monkeyking_loop") then
                inst.AnimState:PlayAnimation("run_monkeyking_loop", true)
            end

            if inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("TAIL_carry")
                inst.AnimState:Hide("TAIL_normal")
            else
                inst.AnimState:Hide("TAIL_carry")
                inst.AnimState:Show("TAIL_normal")
            end

            --V2C: adding half a frame time so it rounds up
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

                inst.components.locomotor.predictrunspeed = nil
                inst.Transform:ClearPredictedFacingModel()
            end
        end,
    },

    State{
        name = "fishing_retrieve",
        --tags = {"prefish", "fishing", "boating"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fishing_pre") --14
            inst.AnimState:PushAnimation("fishing_cast") --8-12, new in DST, contains part of old fishing_pre
            inst.AnimState:PushAnimation("bite_heavy_pre") --5
            inst.AnimState:PushAnimation("bite_heavy_loop") --14
            inst.AnimState:PushAnimation("fish_catch", false)
            inst.AnimState:OverrideSymbol("fish01", "graves_water_crate", "fish01")
        end,

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("fish01")
        end,

        timeline =
        {
            TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_cast", nil, nil, true) end),
            TimeEvent(15*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_baitsplash", nil, nil, true)
                inst:PerformPreviewBufferedAction()
            end),
            TimeEvent(49*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishcaught", nil, nil, true) end),
            TimeEvent(64*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishland", nil, nil, true) end),
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
