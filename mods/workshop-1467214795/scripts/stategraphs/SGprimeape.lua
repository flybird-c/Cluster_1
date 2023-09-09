require("stategraphs/commonstates")

local actionhandlers =
{
	ActionHandler(ACTIONS.GOHOME, "action"),
	ActionHandler(ACTIONS.PICKUP, "action"),
	ActionHandler(ACTIONS.STEAL, "action"),
	ActionHandler(ACTIONS.PICK, "action"),
	ActionHandler(ACTIONS.HARVEST, "action"),
	ActionHandler(ACTIONS.ATTACK, "throw"),
	ActionHandler(ACTIONS.EAT, "eat"),
	ActionHandler(ACTIONS.THROW, "kick"),
}

local events=
{
	CommonHandlers.OnLocomote(false, true),
	CommonHandlers.OnFreeze(),
	CommonHandlers.OnAttacked(),
	CommonHandlers.OnDeath(),
	CommonHandlers.OnSleep(),
	CommonHandlers.OnHop(),
    CommonHandlers.OnSink(),
	EventHandler("doattack", function(inst, data)
		if not (inst.components.health:IsDead() or inst.sg:HasStateTag("busy")) then
			--If you're not in melee range throw instead.
			--Maybe do some randomness to throw or not?
			--V2C: gdi. because sg events are queued, ALL data can possibly go invalid >_ <""
			inst.sg:GoToState(
				(not (data.target ~= nil and data.target:IsValid()) and "idle") or
				(inst:GetDistanceSqToInst(data.target) <= TUNING.MONKEY_MELEE_RANGE * TUNING.MONKEY_MELEE_RANGE + 1 and "attack") or
				"throw"
			)
		end
	end),
}

local function clap(inst) inst.SoundEmitter:PlaySound("ia/creatures/monkey_island/clap") end
local function step(inst) PlayFootstep(inst) end

local states =
{
    State{
        
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle_loop", true)
            else
                inst.AnimState:PlayAnimation("idle_loop", true)
            end
			inst.SoundEmitter:PlaySound(inst.soundtype.."/idle")
		end,

		events=
		{
            EventHandler("animover", function(inst) 

                if inst.components.combat.target and
                    inst.components.combat.target:HasTag("player") then

                    if math.random() < 0.05 then
                        inst.sg:GoToState("taunt")
                        return
                    end
				end

				inst.sg:GoToState("idle") 

			end),
		},
	},

    State{
        
        name = "action",
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("interact", true)
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
        end,
        onexit = function(inst)
            inst.SoundEmitter:KillSound("make")
        end,
        events=
        {
            EventHandler("animover", function (inst)
                inst:PerformBufferedAction()
                inst.sg:GoToState("idle")
            end),
        }
    }, 

    State{
        
        name = "eat",
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("eat", true)
        end,
        
        onexit = function(inst)
            inst:PerformBufferedAction()
        end,

        timeline = 
        {
            TimeEvent(8*FRAMES, function(inst) 
                local waittime = FRAMES*8
                for i = 0, 3 do
					inst:DoTaskInTime((i * waittime), function() inst.SoundEmitter:PlaySound(inst.soundtype.."/eat") end)
				end
			end)
		},

        events=
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("idle")
            end),
        }
    },

    State{
        name = "taunt",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
        end,

        timeline = 
        {
            TimeEvent(8*FRAMES, function(inst) 
                --12 fist hits
				inst.SoundEmitter:PlaySound(inst.soundtype.."/taunt")
				local waittime = FRAMES*2
				for i = 0, 11 do
					inst:DoTaskInTime((i * waittime), function() inst.SoundEmitter:PlaySound(inst.soundtype.."/chest_pound") end)
				end
			end)
		},

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "throw",
        tags = {"attack", "busy", "canrotate", "throwing"},
        
        onenter = function(inst)
            if not inst.HasAmmo(inst) then
                inst.sg:GoToState("idle")
            end

            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("throw")
        end,

        timeline = 
        {
            TimeEvent(14*FRAMES, function(inst) inst.components.combat:DoAttack()
            inst.SoundEmitter:PlaySound(inst.soundtype.."/throw") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

	State{
		name = "befriend",
		tags = {"busy"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("befriend")
			inst.components.locomotor:StopMoving()            
		end,

		timeline=
		{
			TimeEvent(14*FRAMES, clap),
			TimeEvent(20*FRAMES, clap),
			TimeEvent(26*FRAMES, clap),
			TimeEvent(31*FRAMES, clap),
			TimeEvent(36*FRAMES, clap),
			TimeEvent(43*FRAMES, clap),
			TimeEvent(51*FRAMES, clap),
			TimeEvent(57*FRAMES, clap),
			TimeEvent(63*FRAMES, clap),
			TimeEvent(68*FRAMES, clap),
			TimeEvent(73*FRAMES, clap),
			TimeEvent(80*FRAMES, clap),
		},

		events=
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
		},        
	},
}

CommonStates.AddSimpleState(states, "refuse", "refuse", { "busy" })
CommonStates.AddSimpleActionState(states, "kick", "walk_loop", 0 * FRAMES, { "busy", "canrotate" })
CommonStates.AddWalkStates(states,
{
	starttimeline =
	{

	},

	walktimeline = 
	{
		TimeEvent(4*FRAMES, step),
		TimeEvent(5*FRAMES, step),
		TimeEvent(10*FRAMES, function(inst) 
			PlayFootstep(inst)
			if math.random() < 0.1 then
				inst.SoundEmitter:PlaySound(inst.soundtype.."/idle")
			end
		end),
		TimeEvent(11*FRAMES, step),

	},

	endtimeline =
	{

	},
})
CommonStates.AddSleepStates(states,
    {
	starttimeline = 
	{

	},

	sleeptimeline = 
	{
		TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.soundtype.."/sleep") end),
	},

	endtimeline =
	{

	},
})

CommonStates.AddCombatStates(states,
{
	attacktimeline = 
	{
		TimeEvent(17*FRAMES, function(inst)
			inst.components.combat:DoAttack()
			inst.SoundEmitter:PlaySound(inst.soundtype.."/attack")
		end),
	},

	hittimeline =
	{
		TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.soundtype.."/hurt") end),
	},

	deathtimeline =
	{
		TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.soundtype.."/death") end),
	},
})

CommonStates.AddFrozenStates(states)

CommonStates.AddHopStates(states, false, {pre = "walk_pre", loop = "walk_loop", pst = "walk_pst"})
CommonStates.AddSinkAndWashAsoreStates(states)

return StateGraph("primeape", states, events, "idle", actionhandlers)
