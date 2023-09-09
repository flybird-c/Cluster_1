require("stategraphs/commonstates")

local actionhandlers = 
{
}

local events=
{
}

local states=
{
    State{
        name = "open",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("open")
        end,

        timeline=
        {
            TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/common/volcano/altar/slide_open") end),
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/common/volcano/altar/open") end)
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("opened") end)
        },
    },

    State{
        name = "opened",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_open", true)
        end,
    },

    State{
        name = "close",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("close")
        end,

        timeline=
        {
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/common/volcano/altar/slide_close") end),
            TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/common/volcano/altar/close") end)
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("closed") end)
        },
    },

    State{
        name = "closed",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_close", true)
        end,
    },

    State{
        name = "appeased",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("appeased_pre")
            inst.AnimState:PushAnimation("appeased")
            inst.AnimState:PushAnimation("appeased_pst", false)
            inst.SoundEmitter:PlaySound("ia/common/volcano/altar/splash")
            inst.SoundEmitter:PlaySound("ia/common/volcano/altar/appeased")
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                if inst:FullAppeased() then
                    inst.sg:GoToState("close")
                else
                    inst.sg:GoToState("opened")
                end
            end)
        },
    },

    State{
        name = "unappeased",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("unappeased", false)
            inst.SoundEmitter:PlaySound("ia/common/volcano/altar/splash")
            inst.SoundEmitter:PlaySound("ia/common/volcano/altar/unappeased")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("opened")
            end)
        },
    },
}

return StateGraph("volcanoaltar", states, events, "closed", actionhandlers)
