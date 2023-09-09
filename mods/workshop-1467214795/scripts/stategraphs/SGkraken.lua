require("stategraphs/commonstates")

local function onattack(inst, data)
    if inst.components.health:GetPercent() > 0 and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then
        local dist = inst:GetDistanceSqToInst(data.target)
        if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
            if dist > 144 then
                inst.sg:GoToState("throw", data.target)
            elseif inst.components.rechargeable:IsCharged() then
                inst.sg:GoToState("laser")
            end
        else
            if dist > 25 then
                inst.sg:GoToState("throw", data.target)
            end
        end
    end
end

local function SpawnLaserCircle(inst, radius, startangle)
    local numsteps = radius * 3
    local x, y, z = inst.Transform:GetWorldPosition()
    local angle = (inst.Transform:GetRotation() + 90 + startangle) * DEGREES
    local step = .75
    local offset = 2 - step  -- should still hit players right up against us
    local targets, skiptoss = {}, {}
    local i = -1
    local fx, dist, delay, x1, z1
    inst.SoundEmitter:PlaySound("dontstarve/creatures/deerclops/laser")

    while i < numsteps do
        i = i + 1
        angle = angle + (PI / (numsteps * 2))
        dist = radius
        delay = math.max(10, i + 9)
        x1 = x + radius * math.sin(angle)
        z1 = z + radius * math.cos(angle)

        fx = SpawnPrefab(i > 0 and "kraken_laser" or "kraken_laserempty")
        -- fx.caster = inst
        fx.components.combat:SetDefaultDamage(75)
        fx.Transform:SetPosition(x1, 0, z1)
        fx:Trigger(delay * FRAMES / (6 / radius + 0.5) / (radius * 0.1), targets, skiptoss)
        if i == 0 then
            ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, .6, fx, 30)
        end
    end

    if i < numsteps then
        dist = (i + .5) * step + offset
        x1 = x + dist * math.sin(angle)
        z1 = z + dist * math.cos(angle)
    end
    fx = SpawnPrefab("kraken_laser")
    fx.Transform:SetPosition(x1, 0, z1)
    fx:Trigger((delay + 1) * FRAMES / (6 / radius + 0.5) / (radius * 0.1), targets, skiptoss)

    fx = SpawnPrefab("kraken_laser")
    fx.Transform:SetPosition(x1, 0, z1)
    fx:Trigger((delay + 2) * FRAMES / (6 / radius + 0.5) / (radius * 0.1), targets, skiptoss)
end

local events =
{
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    EventHandler("doattack", onattack),
    EventHandler("move", function(inst, data)
        if not inst.sg:HasStateTag("move") then
            inst.sg:GoToState("move", data.pos)
        end
    end),
}

local actionhandlers = {}

local states =
{
    State{
        name = "throw",
        tags = {"attack", "busy"},

        onenter = function(inst)
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("spit")
        end,

        timeline =
        {
            TimeEvent(13 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("ia/creatures/quacken/spit_puke")
            end),
            TimeEvent(56 * FRAMES, function(inst)
                inst:PushEvent("onattackother", {target=inst.sg.statemem.target or inst.components.combat.target})
                inst.SoundEmitter:PlaySound("ia/creatures/quacken/spit")
            end),
            TimeEvent(57 * FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("taunt") end),
        },
    },

    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_loop", true)
        end,
    },

    State{
        name = "hit",
        tags = {"busy", "hit"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("ia/creatures/quacken/hit")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "move",
        tags = {"busy", "move"},

        onenter = function(inst, pos)
            inst.components.health:SetInvincible(true)
            inst.AnimState:PlayAnimation("taunt")
            inst.AnimState:PushAnimation("exit", false)
            inst.sg.statemem.pos = pos
            inst.components.minionspawner:DespawnAll()
            inst.components.minionspawner.minionpositions = nil
            inst.sg:SetTimeout(4)
        end,

        timeline =
        {
            TimeEvent(20 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("ia/creatures/quacken/taunt")
            end),

            TimeEvent(62 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("ia/creatures/quacken/exit")
            end),

            TimeEvent(82 * FRAMES, function(inst)
                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    inst.Light:SetIntensity(.5)
                    inst.Light:SetRadius(10)
                end
            end),

            TimeEvent(83 * FRAMES, function(inst)
                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    inst.Light:SetIntensity(.4)
                    inst.Light:SetRadius(8)
                end
                inst.SoundEmitter:PlaySound("ia/creatures/quacken/quacken_submerge")
                inst.SoundEmitter:KillSound("quacken_lp_1")
                inst.SoundEmitter:KillSound("quacken_lp_2")
            end),

            TimeEvent(84 * FRAMES, function(inst)
                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    inst.Light:SetIntensity(0.3)
                    inst.Light:SetRadius(6)
                end
            end),

            TimeEvent(85 * FRAMES, function(inst)
                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    inst.Light:SetIntensity(0.2)
                    inst.Light:SetRadius(4)
                end
            end),

            TimeEvent(86 * FRAMES, function(inst)
                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    inst.Light:SetIntensity(0.1)
                    inst.Light:SetRadius(2)
                end
            end),

            TimeEvent(86 * FRAMES, function(inst)
                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    inst.Light:SetIntensity(0)
                    inst.Light:SetRadius(0)
                end
            end),
        },

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            inst.Transform:SetPosition(inst.sg.statemem.pos:Get())
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("spawn")
        end,
    },

    State{
        name = "spawn",
        tags = {"busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("ia/creatures/quacken/enter")
            inst.SoundEmitter:PlaySound("ia/creatures/quacken/quacken_emerge")

            inst.SoundEmitter:PlaySound("ia/creatures/quacken/head_drone_rnd_LP", "quacken_lp_1")
            inst.SoundEmitter:PlaySound("ia/creatures/quacken/head_drone_LP", "quacken_lp_2")

            inst.AnimState:PlayAnimation("enter")
        end,

        timeline =
        {
            TimeEvent(5 * FRAMES, function(inst) inst.components.minionspawner:SpawnAll() end),
            TimeEvent(35 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/quacken/enter") end),
            TimeEvent(70 * FRAMES, function(inst)
                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    inst.Light:SetIntensity(0.1)
                    inst.Light:SetRadius(2)
                end
            end),
            TimeEvent(71 * FRAMES, function(inst)
                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    inst.Light:SetIntensity(0.2)
                    inst.Light:SetRadius(4)
                end
            end),
            TimeEvent(72 * FRAMES, function(inst)
                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    inst.Light:SetIntensity(0.3)
                    inst.Light:SetRadius(6)
                end
            end),
            TimeEvent(73 * FRAMES, function(inst)
                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    inst.Light:SetIntensity(0.4)
                    inst.Light:SetRadius(8)
                end
            end),
            TimeEvent(74 * FRAMES, function(inst)
                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    inst.Light:SetIntensity(0.5)
                    inst.Light:SetRadius(10)
                end
            end),
            TimeEvent(75 * FRAMES, function(inst)
                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    inst.Light:SetIntensity(0.6)
                    inst.Light:SetRadius(12)
                end
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")
            inst.components.minionspawner:DespawnAll()
            inst.components.minionspawner.minionpositions = nil
        end,

        timeline =
        {
            TimeEvent(2 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("ia/creatures/quacken/death")
            end),

            TimeEvent(35 * FRAMES, function(inst)
                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    inst.Light:SetIntensity(.5)
                    inst.Light:SetRadius(10)
                end
            end),

            TimeEvent(36 * FRAMES, function(inst)
                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    inst.Light:SetIntensity(.4)
                    inst.Light:SetRadius(8)
                end
            end),

            TimeEvent(37 * FRAMES, function(inst)
                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    inst.Light:SetIntensity(.3)
                    inst.Light:SetRadius(6)
                end
            end),

            TimeEvent(38 * FRAMES, function(inst)
                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    inst.Light:SetIntensity(.2)
                    inst.Light:SetRadius(4)
                end
                inst.SoundEmitter:PlaySound("ia/creatures/quacken/quacken_submerge")
                inst.SoundEmitter:KillSound("quacken_lp_1")
                inst.SoundEmitter:KillSound("quacken_lp_2")
            end),

            TimeEvent(39 * FRAMES, function(inst)
                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    inst.Light:SetIntensity(.1)
                    inst.Light:SetRadius(2)
                end
            end),

            TimeEvent(40 * FRAMES, function(inst)
                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    inst.Light:SetIntensity(0)
                    inst.Light:SetRadius(0)
                end
            end),

            TimeEvent(90 * FRAMES, function(inst)
                inst.components.lootdropper:DropLoot()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst:Remove() end),
        },
    },

    State{
        name = "taunt",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("taunt")
        end,

        timeline =
        {
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/quacken/taunt") end)
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "laser",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("taunt")
            inst.AnimState:PushAnimation("atk", false)
        end,

        timeline =
        {
            TimeEvent(20 * FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/quacken/taunt") end),
            TimeEvent(74 * FRAMES, function(inst)
                inst.sg.statemem.atked = true
                inst.SoundEmitter:PlaySound("ia/creatures/quacken/taunt")
                local target = inst.components.combat.target
                if target ~= nil and target:IsValid() and inst:GetPosition():Dist(target:GetPosition()) < 11 then
                    inst:ForceFacePoint(target.Transform:GetWorldPosition())
                    SpawnLaserCircle(inst, 2.5, -45)
                    SpawnLaserCircle(inst, 7, -45)
                    SpawnLaserCircle(inst, 12.5, -45)
                end
            end)
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.sg.statemem.atked then
                    inst.sg.statemem.atked = false
                    inst.components.rechargeable:Discharge(3)
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
}

return StateGraph("kraken", states, events, "idle", actionhandlers)
