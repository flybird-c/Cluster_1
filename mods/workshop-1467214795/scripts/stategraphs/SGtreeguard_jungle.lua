require("stategraphs/commonstates")

local actionhandlers = 
{
}

local function onattack(inst, data)
    if inst.components.health:GetPercent() > 0 and
    (inst.sg:HasStateTag("hit") or not
    inst.sg:HasStateTag("busy")) then
        local dist = inst:GetDistanceSqToInst(data.target)
        local scale = inst._scale or 1

        if dist > TUNING.JUNGLETREEGUARD_MELEE * TUNING.JUNGLETREEGUARD_MELEE * (scale * scale) then
            --Throw
            inst:SetRange()
            inst.sg:GoToState("throw_pre", data.target)
        else
            --Melee
            inst:SetMelee()
            inst.sg:GoToState("attack", data.target) 
        end
    end
end

local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(false,true),
    CommonHandlers.OnFreeze(),
    EventHandler("doattack", onattack),
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not
        inst.sg:HasStateTag("attack") and not
        inst.sg:HasStateTag("waking") and not
        inst.sg:HasStateTag("sleeping") and 
        (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("frozen")) then
            inst.sg:GoToState("hit") 
        end
    end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("gotosleep", function(inst) inst.sg:GoToState("sleeping") end),
    EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake") end),

    EventHandler("onignite", function(inst) inst.sg:GoToState("panic") end),
}

local states=
{
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/death")
            inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/death_drop")
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        
    },
    
    State{
        name = "tree",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("tree_idle", true)
        end,
    },   

    State{
        name = "panic",
        tags = {"busy"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("panic_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("panic_loop") end),
            EventHandler("onextinguish", function(inst) inst.sg:GoToState("panic_pst") end),
        }
    },

    State{
        name = "panic_loop",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("panic_loop")
            inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/panic")
        end,

        timeline = {
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/footstep") end),
            TimeEvent(18*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/footstep") end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("panic_loop") end),
            EventHandler("onextinguish", function(inst) inst.sg:GoToState("panic_pst") end),
        },
    },

    State{
        name = "panic_pst",
        tags = {"busy"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("panic_post")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        }
    },
    
	State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
            inst.sg.statemem.target = target
        end,
        
        timeline=
        {
			TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/attack") end),
            TimeEvent(32*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/attack_swipe") end),
			TimeEvent(39*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(40*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
            TimeEvent(41*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "throw_pre",
        tags = {"attack", "busy"},
        
        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pluck")
            inst.sg.statemem.target = target
            inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/pluck")

            local throw_swap = nil
            local throwable_prefab = inst.components.thrower ~= nil and inst.components.thrower.throwable_prefab or nil
            
            if throwable_prefab == "treeguard_snake_poison" then
                throw_swap = "snakepoison_cannon01"
            elseif throwable_prefab == "treeguard_snake" then
                throw_swap = "snake_cannon01"
            else
                throw_swap = "banana_cannon01"
            end

            inst.AnimState:OverrideSymbol("snake_cannon01", "jungleTreeGuard_build", throw_swap)
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("throw", inst.sg.statemem.target) end),
        },
    },

    State{
        name = "throw",
        tags = {"attack", "busy"},
        
        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("throw_pre")
            inst.AnimState:PushAnimation("throw", false)
            inst.sg.statemem.target = target
        end,
        
        timeline=
        {
            TimeEvent(00*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/attack") end),
            TimeEvent(37*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/attack_swipe") end),
            TimeEvent(40*FRAMES, function(inst) inst:PushEvent("onattackother", {target=inst.sg.statemem.target}) end),
            TimeEvent(41*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
            TimeEvent(47*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(50*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/coconut_throw") end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },  
    
    
	State{
        name = "hit",
        tags = {"hit", "busy"},
        
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/hit")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
        
        timeline=
        {
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/tree_movement") end),
        },
        
    },      
    
    State{
        name = "sleeping",
        tags = {"sleeping", "busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:HideSymbol("snow")
            inst.AnimState:PlayAnimation("transform_tree", false)
            inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/transform_out")
            inst.DynamicShadow:Enable(false)
        end,

        onexit = function(inst)
            inst.DynamicShadow:Enable(true)
        end,

        events=
        {
		    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() then inst.sg:GoToState("wake") end end),
        },
        
        timeline=
        {
            TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(31*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/tree_movement") end),
        },
        
    },
    
    State{
        name = "spawn",
        tags = {"waking", "busy"},
        
        onenter = function(inst, start_anim)
            inst.Physics:Stop()
            inst.AnimState:HideSymbol("snow")
            inst.AnimState:PlayAnimation("transform_ent")
            inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/transform_in")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

        timeline=
        {
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(41*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/footstep") end),
            TimeEvent(49*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/footstep") end),
            TimeEvent(53*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/transform_VO") end),
        },
        
    },
    
    State{
        name = "wake",
        tags = {"waking", "busy"},
        
        onenter = function(inst, start_anim)
            inst.Physics:Stop()
            inst.AnimState:HideSymbol("snow")
            inst.AnimState:PlayAnimation("transform_ent_mad")
            inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/transform_in")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

        timeline=
        {
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/coconut_throw") end),
            TimeEvent(33*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/attack") end),
            TimeEvent(41*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/footstep") end),
            TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/attack") end),
            TimeEvent(49*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/footstep") end),
            TimeEvent(53*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/transform_VO") end),
        },
        
    },

    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop")
            inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/idle")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
}

CommonStates.AddWalkStates(
    states,
    {
		starttimeline =
		{
            TimeEvent(0*FRAMES, function(inst) inst.Physics:Stop() end),
            TimeEvent(20*FRAMES, function(inst) inst.components.locomotor:WalkForward() end),
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(27*FRAMES, function(inst) inst.Physics:Stop() end),
		},
        walktimeline = 
        { 
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/walk_VO") end),
            TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/footstep") end),
            TimeEvent(56*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(57*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/footstep") end),
        },
        endtimeline=
        {
            TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/palm_tree_guard/footstep") end),
        },
    })

CommonStates.AddFrozenStates(states)

return StateGraph("treeguard_jungle", states, events, "idle", actionhandlers)
