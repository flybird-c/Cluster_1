SailingCommonStates = {}

SailingCommonHandlers = {}
SailingCommonHandlerPatches = {}

-- WIP sailing patches, maybe one day we can use these for SGwilson
local function OnExitSail(inst)
    local boat = inst.replica.sailor:GetBoat()
    if boat and boat.components.rowboatwakespawner then
        boat.components.rowboatwakespawner:StopSpawning()
    end

    if inst.sg.nextstate ~= "sail_ia" then
        inst.SoundEmitter:KillSound("sail_loop")
        if inst.sg.nextstate ~= "row_ia" and inst.sg.nextstate ~= "hop_pre" then
            inst.components.locomotor:Stop(nil, true)
        end
        if inst.sg.nextstate ~= "row_stop_ia" and inst.sg.nextstate ~= "sail_stop_ia" then
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayIdleAnims()
            end
        end
    end
end

local function OnExitRow(inst)
    local boat = inst.replica.sailor:GetBoat()
    if boat and boat.components.rowboatwakespawner then
        boat.components.rowboatwakespawner:StopSpawning()
    end

    if inst.sg.nextstate ~= "row_ia" and inst.sg.nextstate ~= "sail_ia" then
        if inst.sg.nextstate ~= "hop_pre" then
            inst.components.locomotor:Stop(nil, true)
        end
        if inst.sg.nextstate ~= "row_stop_ia" and inst.sg.nextstate ~= "sail_stop_ia" then --Make sure equipped items are pulled back out (only really for items with flames right now)
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

-- Note: This patch is made for CommonHandlers.OnLocomote and wont work for ents like players
SailingCommonHandlerPatches.AddBoatLocomotion = function(sg, can_sail, can_row)
    local _locomote_eventhandler = sg.events.locomote.fn
    sg.events.locomote.fn = function(inst, data)
        local is_moving = inst.sg:HasStateTag("moving")
        local is_boating = inst.sg:HasStateTag("boating")
        local is_sailing = inst.sg:HasStateTag("sailing")
        local is_idling = inst.sg:HasStateTag("idle")

        local should_move = inst.components.locomotor:WantsToMoveForward()
        local should_sail = inst.replica.sailor and inst.replica.sailor:GetBoat() and inst.replica.sailor:GetBoat().replica.sailable:GetIsSailEquipped() or false
        if inst.components.sailor and inst.components.sailor.boat and not inst.components.sailor.boat.components.sailable then
            should_move = false
        end
 
        if should_move then
            if inst.components.sailor and inst.components.sailor.boat then
                inst.components.sailor.boat:PushEvent("boatstartmoving")
            end
        else
            if inst.components.sailor and inst.components.sailor.boat then
                inst.components.sailor.boat:PushEvent("boatstopmoving")
            end
        end

        if inst.components.sailor and inst.components.sailor:IsSailing() then
            if is_moving and not should_move then
                if can_sail and (should_sail or not can_row) then
                    inst.sg:GoToState("sail_stop_ia")
                elseif can_row then
                    inst.sg:GoToState("row_stop_ia")
                end
            elseif is_idling and should_move or (is_moving and should_move and (not is_boating or is_sailing ~= should_sail)) then
                -- The code on the line above was modified to support walking
                if can_sail and (should_sail or not can_row) then
                    inst.sg:GoToState("sail_start_ia")
                elseif can_row then
                    inst.sg:GoToState("row_start_ia")
                end
            end
            return
        end

        return _locomote_eventhandler ~= nil and _locomote_eventhandler(inst, data)
    end
end

SailingCommonHandlers.BoostByWaveHandler = function()
    return EventHandler("boostbywave", function(inst, data)
        if inst.sg:HasStateTag("moving") and inst.sg:HasStateTag("boating") then

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
    end)
end

SailingCommonStates.AddSailingStates = function(sg, config, anims, timelines, timeout)
    config = config or {}
    anims = anims or {}
	anims = anims or {}
	timelines = timelines or {}
    timeout = timeout or {} -- TODO: support both animover and timeouts

	local onenters = (config ~= nil and config.onenters ~= nil) and config.onenters or nil
	local onexits = (config ~= nil and config.onexits ~= nil) and config.onexits or nil
    local ontimeouts = (config ~= nil and config.ontimeouts ~= nil) and config.ontimeouts or nil

    table.insert(sg, State{
        name = "sail_start_ia",
        tags = {"moving", "canrotate", "boating", "sailing", "autopredict"},

        onenter = function(inst)
            local boat = inst.replica.sailor:GetBoat()

            if config.cant_run then
                inst.components.locomotor:WalkForward()
            else
                inst.sg:AddStateTag("running")
                inst.components.locomotor:RunForward()
            end

            local anim = type(anims.pre) ~= "function" and anims.pre or anims.pre(inst)
            if not inst.AnimState:IsCurrentAnimation(anim) then
                inst.AnimState:PlayAnimation(anim, true)
            else
                inst.AnimState:PushAnimation(anim, true)
            end

            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayPreSailAnims()
            end

            local equipped = inst.replica.inventory ~= nil and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equipped then
                equipped:PushEvent("startsailing", {owner = inst})
            end

            if onenters ~= nil and onenters.pre ~= nil then
				onenters.pre(inst)
			end

            inst.sg:SetTimeout(type(timeout.pre) ~= "function" and timeout.pre or timeout.pre(inst))
        end,

        onupdate = function(inst)
            if config.cant_run then
                inst.components.locomotor:WalkForward()
            else
                inst.sg:AddStateTag("running")
                inst.components.locomotor:RunForward()
            end
        end,

        onexit = function(inst)
            OnExitSail(inst)
            if onexits ~= nil and onexits.pre ~= nil then
				onexits.pre(inst)
			end
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("sail_ia")
            if ontimeouts ~= nil and ontimeouts.pre ~= nil then
				ontimeouts.pre(inst)
			end
        end,
    })

    table.insert(sg, State{
        name = "sail_ia",
        tags = {"canrotate", "moving", "boating", "sailing", "autopredict"},

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

            local anim = type(anims.loop) ~= "function" and anims.loop or anims.loop(inst)
            if not inst.AnimState:IsCurrentAnimation(anim) then
                inst.AnimState:PlayAnimation(anim, true)
            else
                inst.AnimState:PushAnimation(anim, true)
            end
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlaySailAnims()
            end

            if boat and boat.components.rowboatwakespawner then
                boat.components.rowboatwakespawner:StartSpawning()
            end

            if onenters ~= nil and onenters.loop ~= nil then
				onenters.loop(inst)
			end

            inst.sg:SetTimeout(type(timeout.loop) ~= "function" and timeout.loop or timeout.loop(inst))
        end,

        onexit = function(inst)
            OnExitSail(inst)
            if onexits ~= nil and onexits.loop ~= nil then
				onexits.loop(inst)
			end
        end,

        events = {
            --EventHandler("animover", function(inst) inst.sg:GoToState("sail_ia") end ),
            EventHandler("trawlitem", function(inst)
                local boat = inst.replica.sailor:GetBoat()
                if boat and boat.replica.sailable then
                    boat.replica.sailable:PlayTrawlOverAnims()
                end
            end),
        },

        ontimeout = function(inst) 
            inst.sg:GoToState("sail_ia")
            if ontimeouts ~= nil and ontimeouts.loop ~= nil then
				ontimeouts.loop(inst)
			end
        end,
    })

    table.insert(sg, State{
        name = "sail_stop_ia",
        tags = {"canrotate", "idle", "autopredict"},

        onenter = function(inst)
            local boat = inst.replica.sailor:GetBoat()

            inst.components.locomotor:Stop()

            local anim = type(anims.pst) ~= "function" and anims.pst or anims.pst(inst)
            if not inst.AnimState:IsCurrentAnimation(anim) then
                inst.AnimState:PlayAnimation(anim, true)
            else
                inst.AnimState:PushAnimation(anim, true)
            end
            if boat and boat.replica.sailable then
                boat.replica.sailable:PlayPostSailAnims()
            end

            if onenters ~= nil and onenters.pst ~= nil then
				onenters.pst(inst)
			end

            inst.sg:SetTimeout(type(timeout.pst) ~= "function" and timeout.pst or timeout.pst(inst))
        end,

        onexit = function(inst)
			if onexits ~= nil and onexits.pst ~= nil then
				onexits.pst(inst)
			end
        end,

        ontimeout = function(inst)
            local equipped = inst.replica.inventory ~= nil and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equipped then
                equipped:PushEvent("stopsailing", {owner = inst})
            end
            inst.sg:GoToState("idle")

            if ontimeouts ~= nil and ontimeouts.pst ~= nil then
				ontimeouts.pst(inst)
			end
        end,
    })
end


-- SailingCommonStates.AddRowingStates = function(sg)
--     table.insert(sg, State{
--         name = "row_start_ia",
--         tags = { "moving", "boating", "canrotate", "autopredict" },

--         onenter = function(inst, foleyfn)
--             local boat = inst.replica.sailor:GetBoat()

            -- if config.cant_run then
            --     inst.components.locomotor:WalkForward()
            -- else
            --     inst.sg:AddStateTag("running")
            --     inst.components.locomotor:RunForward()
            -- end

--             if not inst:HasTag("mime") then
--                 inst.AnimState:OverrideSymbol("paddle", "swap_paddle", "paddle")
--             end
--             inst.AnimState:OverrideSymbol("wake_paddle", "swap_paddle", "wake_paddle")

--             --RoT has row_pre, which is identical but uses the equipped item as paddle
            
--             local oar = inst.replica.inventory ~= nil and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

--             inst.AnimState:PlayAnimation(oar and oar:HasTag("oar") and "row_pre" or "row_ia_pre")
--             if boat and boat.replica.sailable then
--                 boat.replica.sailable:PlayPreRowAnims()
--             end

--             if foleyfn ~= nil then
--                 foleyfn(inst)
--             end

--             local equipped = inst.replica.inventory ~= nil and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
--             if equipped then
--                 equipped:PushEvent("startrowing", {owner = inst})
--             end
--             inst:PushEvent("startrowing")
--         end,

--         onupdate = function(inst)
            -- if config.cant_run then
            --     inst.components.locomotor:WalkForward()
            -- else
            --     inst.sg:AddStateTag("running")
            --     inst.components.locomotor:RunForward()
            -- end
--         end,

--         onexit = OnExitRow,

--         events = {
--             EventHandler("animover", function(inst)
--                 if inst.AnimState:AnimDone() then
--                     inst.sg:GoToState("row_ia")
--                 end
--             end),
--         },
--     })

--     table.insert(sg, State{
--         name = "row_ia",
--         tags = { "moving", "boating", "canrotate", "autopredict" },

--         onenter = function(inst, foleyfn)
--             local boat = inst.replica.sailor:GetBoat()

--             if boat and boat.replica.sailable and boat.replica.sailable.creaksound then
--                 inst.SoundEmitter:PlaySound(boat.replica.sailable.creaksound, nil, nil, true)
--             end
--             inst.SoundEmitter:PlaySound("ia/common/boat/paddle", nil, nil, true)
--             if foleyfn ~= nil then
--                 foleyfn(inst)
--             end

--             local oar = inst.replica.inventory ~= nil and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

--             local anim = oar and oar:HasTag("oar") and "row_medium" or "row_loop"
--             if not inst.AnimState:IsCurrentAnimation(anim) then
--                 --RoT has row_medium, which is identical but uses the equipped item as paddle
--                 inst.AnimState:PlayAnimation(anim, true)
--             end
--             if boat and boat.replica.sailable then
--                 boat.replica.sailable:PlayRowAnims()
--             end

--             if boat and boat.components.rowboatwakespawner then
--                 boat.components.rowboatwakespawner:StartSpawning()
--             end

--             if inst.components.mapwrapper
--             and inst.components.mapwrapper._state > 1
--             and inst.components.mapwrapper._state < 5 then
--                 inst.sg:AddStateTag("nomorph")
--                 -- TODO pause predict?
--             end

--             inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength())
--         end,

--         onexit = OnExitRow,

--         timeline = {
--             TimeEvent(8*FRAMES, function(inst)
--                 local boat = inst.replica.sailor:GetBoat()
--                 if boat and boat.replica.container then
--                     local trawlnet = boat.replica.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_SAIL)
--                     if trawlnet and trawlnet.rowsound then
--                         inst.SoundEmitter:PlaySound(trawlnet.rowsound, nil, nil, true)
--                     end
--                 end
--             end),
--         },

--         events = {
--             EventHandler("trawlitem", function(inst)
--                 local boat = inst.replica.sailor:GetBoat()
--                 if boat and boat.replica.sailable then
--                     boat.replica.sailable:PlayTrawlOverAnims()
--                 end
--             end),
--         },

--         ontimeout = function(inst) inst.sg:GoToState("row_ia") end,
--     })

--     table.insert(sg, State{
--         name = "row_stop_ia",
--         tags = { "canrotate", "idle", "autopredict"},

--         onenter = function(inst)
--             inst.components.locomotor:Stop()
--             local boat = inst.replica.sailor:GetBoat()
--             local oar = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            
--             inst.AnimState:PlayAnimation(oar and oar:HasTag("oar") and "row_idle_pst" or "row_pst")
--             if boat and boat.replica.sailable then
--                 boat.replica.sailable:PlayPostRowAnims()
--             end

--             --If the player had something in their hand before starting to row, put it back.
--             if inst.replica.inventory ~= nil and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
--                 inst.AnimState:PushAnimation("item_out", false)
--             end
--         end,

--         events = {
--             EventHandler("animqueueover", function(inst)
--                 if inst.AnimState:AnimDone() then
--                     local equipped = inst.replica.inventory ~= nil and inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
--                     if equipped then
--                         equipped:PushEvent("stoprowing", {owner = inst})
--                     end
--                     inst:PushEvent("stoprowing")
--                     inst.sg:GoToState("idle")
--                 end
--             end),
--         },
--     })
-- end
