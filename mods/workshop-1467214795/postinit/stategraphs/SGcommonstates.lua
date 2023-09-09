local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
require("stategraphs/commonstates")

local function sleeponanimover(inst)
    if inst.AnimState:AnimDone() then
        inst.sg:GoToState("sleeping")
    end
end
--------------------------------------------------------------------------
local function idleonanimover(inst)
    if inst.AnimState:AnimDone() then
        inst.sg:GoToState("idle")
    end
end
--------------------------------------------------------------------------
local function onwakeup(inst)
    if not inst.sg:HasStateTag("nowake") then
        inst.sg:GoToState("wake")
    end
end

--in ds you can override the anims for the commonstates but you cant in dst, this is just a copy of the dst function that allows you to override the anims (used for tigershark) -Half
--honestly i could of just set the states directly in the tigershark sg...
CommonStates.AddSleepStatesWithAnim = function(states, timelines, fns, anims)
    table.insert(states, State{
        name = "sleep",
        tags = { "busy", "sleeping" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation((anims and anims.sleep_pre) or "sleep_pre")
            if fns ~= nil and fns.onsleep ~= nil then
                fns.onsleep(inst)
            end
        end,

        timeline = timelines ~= nil and timelines.starttimeline or nil,

        events =
        {
            EventHandler("animover", sleeponanimover),
            EventHandler("onwakeup", onwakeup),
        },
    })

    table.insert(states, State{
        name = "sleeping",
        tags = { "busy", "sleeping" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation((anims and anims.sleep_loop) or "sleep_loop")
        end,

        timeline = timelines ~= nil and timelines.sleeptimeline or nil,

        events =
        {
            EventHandler("animover", sleeponanimover),
            EventHandler("onwakeup", onwakeup),
        },
    })

    table.insert(states, State{
        name = "wake",
        tags = { "busy", "waking" },

        onenter = function(inst)
            if inst.components.locomotor ~= nil then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation((anims and anims.sleep_pst) or "sleep_pst")
            if inst.components.sleeper ~= nil and inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
            end
            if fns ~= nil and fns.onwake ~= nil then
                fns.onwake(inst)
            end
        end,

        timeline = timelines ~= nil and timelines.waketimeline or nil,

        events =
        {
            EventHandler("animover", idleonanimover),
        },
    })
end

local _PlayMiningFX = PlayMiningFX
function PlayMiningFX(inst, target, nosound, ...)
    if target ~= nil and target:IsValid() then
        local coral = target:HasTag("coral")
        local charcoal = target:HasTag("charcoal")
        local obsidian = target:HasTag("obsidian")

        if coral or charcoal or obsidian then
            if target.Transform ~= nil then
                SpawnPrefab(
                    (charcoal and "mining_charcoal_fx") or
                    (obsidian and "mining_obsidian_fx") or
                    "mining_fx"
                ).Transform:SetPosition(target.Transform:GetWorldPosition())
            end
            if not nosound and inst.SoundEmitter ~= nil then
                inst.SoundEmitter:PlaySound(
                    (charcoal and "ia/common/charcoal_mine") or
                    (coral and "ia/common/coral_mine") or
                    (obsidian and "turnoftides/common/together/moon_glass/mine")
                )
            end
            return
        end
    end
    return _PlayMiningFX(inst, target, nosound, ...)
end

--------------------------------------------------------------------------

local function onhitcoastline(inst, data)
    if (inst.components.health == nil or not inst.components.health:IsDead()) and not inst.sg:HasStateTag("drowning") and (inst.components.drydrownable ~= nil and inst.components.drydrownable:ShouldDrown()) then
        inst.sg:GoToState("hitcoastline", data)
    end
end

CommonHandlers.OnHitCoastline = function()
    return EventHandler("onhitcoastline", onhitcoastline)
end

local function DoWashAway(inst, skip_sand)
	if not skip_sand then
        local x, y, z = inst.Transform:GetWorldPosition()
        SpawnPrefab("washashore_puddle_fx").Transform:SetPosition(x, y, z)
		SpawnPrefab("sand_puff").Transform:SetPosition(x, y, z)
	end

	inst.sg.statemem.isteleporting = true
	inst:Hide()
	if inst.components.health ~= nil then
		inst.components.health:SetInvincible(true)
	end
	inst.components.drydrownable:WashAway()
end

CommonStates.AddHitCoastlineAndWashAwayStates = function(states, anims, timelines, fns)
	anims = anims or {}
	timelines = timelines or {}
	fns = fns or {}

    local onenters = fns.onenters or {}

    table.insert(states, State{
        name = "hitcoastline",
        tags = { "busy", "nopredict", "nomorph", "drowning", "nointerrupt", "nowake" },

        onenter = function(inst, data)
            inst:ClearBufferedAction()

            inst.components.locomotor:Stop()
            inst.components.locomotor:Clear()

			inst.sg.statemem.collisionmask = inst.Physics:GetCollisionMask()
	        inst.Physics:SetCollisionMask(COLLISION.GROUND)

			if data ~= nil and data.shore_pt ~= nil then
				inst.components.drydrownable:OnHitCoastline(data.shore_pt:Get())
			else
				inst.components.drydrownable:OnHitCoastline()
			end

			if inst.DynamicShadow ~= nil then
			    inst.DynamicShadow:Enable(false)
			end

		    if inst.brain ~= nil then
				inst.brain:Stop()
			end

			local skip_anim = data ~= nil and data.noanim
			if anims.sink ~= nil and not skip_anim then
				inst.sg.statemem.has_anim = true
	            inst.AnimState:PlayAnimation(anims.hitcoastline)
			else
				DoWashAway(inst, skip_anim)
			end

            if onenters.hitcoastline ~= nil then
                onenters.hitcoastline(inst)
            end

        end,

		timeline = timelines.sink,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.sg.statemem.has_anim and inst.AnimState:AnimDone() then
					DoWashAway(inst)
				end
            end),

            EventHandler("on_washed_away", function(inst)
				inst.sg:GoToState("washed_away")
			end),
        },

        onexit = function(inst)
			if inst.sg.statemem.collisionmask ~= nil then
				inst.Physics:SetCollisionMask(inst.sg.statemem.collisionmask)
			end

            if inst.sg.statemem.isteleporting then
				if inst.components.health ~= nil then
					inst.components.health:SetInvincible(false)
				end
				inst:Show()
			end

			if inst.DynamicShadow ~= nil then
				inst.DynamicShadow:Enable(true)
			end

			if inst.components.herdmember ~= nil then
				inst.components.herdmember:Leave()
			end

			if inst.components.combat ~= nil then
				inst.components.combat:DropTarget()
			end

		    if inst.brain ~= nil then
				inst.brain:Start()
			end
        end,
    })

	table.insert(states, State{
		name = "washed_away",
        tags = { "doing", "busy", "nopredict", "silentmorph" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
			if type(anims.washaway) == "table" then
				for i, v in ipairs(anims.washaway) do
					if i == 1 then
			            inst.AnimState:PlayAnimation(v)
					else
			            inst.AnimState:PushAnimation(v, false)
					end
				end
			elseif anims.washashore ~= nil then
				inst.AnimState:PlayAnimation(anims.washaway)
			else
				inst.AnimState:PlayAnimation("sleep_loop")
	            inst.AnimState:PushAnimation("sleep_pst", false)
			end

		    if inst.brain ~= nil then
				inst.brain:Stop()
			end

			SpawnPrefab("sand_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())

            if onenters.washaway ~= nil then
                onenters.washaway(inst)
            end
        end,

		timeline = timelines.washaway,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },

        onexit = function(inst)
		    if inst.brain ~= nil then
				inst.brain:Start()
			end
        end,
	})
end