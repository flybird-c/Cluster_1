require("stategraphs/commonstates")

local actionhandlers = 
{
  ActionHandler(ACTIONS.GOHOME, "gohome"),
  ActionHandler(ACTIONS.EAT, "eat"),
  ActionHandler(ACTIONS.CHOP, "chop"),
  ActionHandler(ACTIONS.HACK, "chop"),
  ActionHandler(ACTIONS.PICKUP, "pickup"),
  ActionHandler(ACTIONS.EQUIP, "pickup"),
  ActionHandler(ACTIONS.ADDFUEL, "pickup"),
  ActionHandler(ACTIONS.TAKEITEM, "pickup"),
  ActionHandler(ACTIONS.UNPIN, "pickup"),
  ActionHandler(ACTIONS.MARK, "dropitem"),

}


local events=
{

  EventHandler("locomote", function(inst)
      local is_attacking = inst.sg:HasStateTag("attack") or inst.sg:HasStateTag("chargingattack")
      local is_busy = inst.sg:HasStateTag("busy")
      local is_idling = inst.sg:HasStateTag("idle")
      local is_moving = inst.sg:HasStateTag("moving")
      local is_running = inst.sg:HasStateTag("running") or inst.sg:HasStateTag("chargingattack")
      local should_charge = inst:HasTag("ChaseAndRam")
      local is_charging = inst.sg:HasStateTag("charging")

      if is_attacking or is_busy then return end

      local should_move = inst.components.locomotor:WantsToMoveForward()
      local should_run = inst.components.locomotor:WantsToRun()

      if is_moving and not should_move then
        inst.SoundEmitter:KillSound("charge")
        if is_charging then
          inst.sg:GoToState("charge_pst")
        elseif is_running then
          inst.sg:GoToState("run_stop")
        else
          inst.sg:GoToState("walk_stop")
        end
      elseif (not is_moving and should_move)
		or (is_moving and should_move and is_running ~= should_run)
		--added ability to start charging mid-run to fix weird locomote event timing -M
		or (is_moving and should_move and not is_charging and should_charge) then
        if should_run then
          -- hack against accidentally remaining tag by the behaviour
          if should_charge and (inst.components.combat:InCooldown() or not inst.components.combat:HasTarget()) then
            inst:RemoveTag("ChaseAndRam")
            should_charge = false
          end
          if should_charge then
            inst.sg:GoToState("charge_antic_pre")
          else
            inst.sg:GoToState("run_start")
          end
        else
          inst.sg:GoToState("walk_start")
        end
      end 
    end),

	EventHandler("doattack", function(inst)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState(inst.sg:HasStateTag("charging") and "charge_attack" or "attack")
        end
	end),


  CommonHandlers.OnStep(),
  CommonHandlers.OnSleep(),
  CommonHandlers.OnFreeze(),
  EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("hit") end end),
  CommonHandlers.OnIpecacPoop(),
  CommonHandlers.OnDeath(),
  CommonHandlers.OnHop(),
	CommonHandlers.OnSink(),
    EventHandler("transformnormal", function(inst)
        if not inst.components.health:IsDead() then
            inst.sg:GoToState("transformNormal")
        end
    end),
    EventHandler("cheer", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("cheer")
        end
    end),
    EventHandler("win_yotb", function(inst, data)
        if not (inst.sg:HasStateTag("busy") or inst.components.health:IsDead()) then
            inst.sg:GoToState("win_yotb")
        end
    end),
  EventHandler("transformnormal", function(inst) if inst.components.health:GetPercent() > 0 then inst.sg:GoToState("transformNormal") end end),
  EventHandler("doaction", 
    function(inst, data) 
      if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
        if data.action == ACTIONS.CHOP or data.action == ACTIONS.HACK then
          inst.sg:GoToState("chop", data.target)
        end
      end
    end),
}

local states=
{
  State{
    name= "funnyidle",
    tags = {"idle"},

    onenter = function(inst)
      inst.Physics:Stop()
      inst.SoundEmitter:PlaySound("ia/creatures/wild_boar/oink")

      if inst.components.follower:GetLeader() ~= nil and inst.components.follower:GetLoyaltyPercent() < 0.05 then
        inst.AnimState:PlayAnimation("hungry")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/hungry")
      --elseif inst:HasTag("guard") then
      --  inst.AnimState:PlayAnimation("idle_angry") -Wilbore guard unimplemented -Half
      elseif TheWorld.state.isnight then --copy from SGpig in dst just cleaner code
        inst.AnimState:PlayAnimation("idle_scared")
      elseif inst.components.combat:HasTarget() then
        inst.AnimState:PlayAnimation("idle_angry")
      elseif inst.components.follower:GetLeader() ~= nil and inst.components.follower:GetLoyaltyPercent() > 0.3 then
        inst.AnimState:PlayAnimation("idle_happy")
      else
        inst.AnimState:PlayAnimation("idle_creepy")
      end
    end,

    events=
    {
      EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
    },        
  },

  State {
    name = "frozen",
    tags = {"busy"},

    onenter = function(inst)
      inst.AnimState:PlayAnimation("frozen")
      inst.Physics:Stop()
      --inst.components.highlight:SetAddColour(Vector3(82/255, 115/255, 124/255))
    end,
  },
  State{
      name = "dropitem", --used for yotpk event
      tags = { "busy" },

      onenter = function(inst)
          inst.Physics:Stop()
          inst.AnimState:PlayAnimation("pig_pickup")
      end,

      timeline =
      {
          TimeEvent(10 * FRAMES, function(inst)
              inst:PerformBufferedAction()
          end),
      },

      events =
      {
          EventHandler("animover", function(inst)
              inst.sg:GoToState("idle")
          end),
      },
  },
  State{
      name = "cheer",
      tags = { "busy" },

      onenter = function(inst)
          inst.Physics:Stop()
          inst.AnimState:PlayAnimation("buff")
      end,

       events =
      {
           EventHandler("animover", function(inst)
               inst.sg:GoToState("idle")
          end),
      },
  },
  State{
      name = "win_yotb",
      tags = { "busy" },

      onenter = function(inst)
          inst.Physics:Stop()
          inst.AnimState:PlayAnimation("win")
      end,

      events =
      {
          EventHandler("animover", function(inst)
              inst.sg:GoToState("idle")
          end),
      },
  },

  State{
    name = "death",
    tags = {"busy"},

    onenter = function(inst)
      inst.SoundEmitter:PlaySound("ia/creatures/wild_boar/grunt")
      inst.AnimState:PlayAnimation("death")
      inst.Physics:Stop()
      RemovePhysicsColliders(inst)            
      inst.components.lootdropper:DropLoot(inst:GetPosition())      
    end,

  },

  State{
    name = "abandon",
    tags = {"busy"},

    onenter = function(inst, leader)
      inst.Physics:Stop()
      inst.AnimState:PlayAnimation("abandon")
      if leader ~= nil and leader:IsValid() then
        inst:FacePoint(leader:GetPosition())
      end
    end,

    events =
    {
      EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
    },        
  },

  State{
    name = "transformNormal",
    tags = {"transform", "busy", "sleeping"},

    onenter = function(inst)
      inst.Physics:Stop()
      inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/transformToPig")
      inst.AnimState:SetBuild("werepig_build")
      inst.AnimState:PlayAnimation("transform_were_pig")
      inst:RemoveTag("hostile")

    end,

    onexit = function(inst)
      inst.AnimState:SetBuild(inst.build)
    end,

    events=
    {
      EventHandler("animover", function(inst)
          inst.components.sleeper:GoToSleep(15+math.random()*4)
          inst.sg:GoToState("sleeping")
        end ),
    },        
  },

  State{
    name = "attack",
    tags = {"attack", "busy"},

    onenter = function(inst)
      inst.SoundEmitter:PlaySound("ia/creatures/wild_boar/attack")
      inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
      inst.components.combat:StartAttack()
      inst.Physics:Stop()
      inst.AnimState:PlayAnimation("atk")
    end,

    timeline=
    {
      TimeEvent(13*FRAMES, function(inst)
		  inst.components.combat:DoAttack()
		  inst.sg:RemoveStateTag("attack")
		  inst.sg:RemoveStateTag("busy")
	  end),
    },

    events=
    {
      EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
    },
  },

  State{
    name = "chop",
    tags = {"chopping"},

    onenter = function(inst)
      inst.Physics:Stop()
      inst.AnimState:PlayAnimation("atk")
    end,

    timeline=
    {

      TimeEvent(13*FRAMES, function(inst) inst:PerformBufferedAction() end ),
    },

    events=
    {
      EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
    },
  },

  State{
    name = "eat",
    tags = {"busy"},

    onenter = function(inst)
      inst.Physics:Stop()            
      inst.AnimState:PlayAnimation("eat")
    end,

    timeline=
    {
      TimeEvent(10*FRAMES, function(inst) inst:PerformBufferedAction() end),
      --note: wildbores dont oink like puny pigs when eating there food -half
      -- dst added chewing sounds to pigmen "eat"
      TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/beefalo/chew") end),
      TimeEvent(21*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/beefalo/chew") end),
    },

    events=
    {
      EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
    },        
  },
  State{
    name = "hit",
    tags = {"busy"},

    onenter = function(inst)
      inst.SoundEmitter:PlaySound("ia/creatures/wild_boar/oink")
      inst.AnimState:PlayAnimation("hit")
      inst.Physics:Stop()
    end,

    events=
    {
      EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
    },        
  },


  State{
    name = "charge_antic_pre",
    tags = {"moving", "charging", "busy", "atk_pre", "canrotate"},

    onenter = function(inst)
      inst.Physics:Stop()
      inst.AnimState:PlayAnimation("paw_pre")
    end,

    events =
    {
      EventHandler("animover", function(inst) inst.sg:GoToState("charge_antic_loop") end),
    },
  },

  State{
    name = "charge_antic_loop",
    tags = {"moving", "charging", "busy", "atk_pre", "canrotate"},

    onenter = function(inst)
      inst.Physics:Stop()
      inst.AnimState:PlayAnimation("paw_loop", true)
      inst.sg:SetTimeout(1.5)
    end,

    ontimeout= function(inst)
      inst.sg:GoToState("charge_pre")
      inst:PushEvent("attackstart" )
    end,
  },

  State{
    name = "charge_pre",
    tags = {"busy", "charging", "atk_pre", "moving", "running"},

    onenter = function(inst)
        inst.components.locomotor.allow_platform_hopping = false
        inst.components.locomotor:RunForward()
        inst.components.locomotor:SetExternalSpeedAdder(inst, "chargeattack", 5)
        inst.AnimState:PlayAnimation("charge_pre")
    end,

    onexit = function(inst)
		inst.components.locomotor:RemoveExternalSpeedAdder(inst, "chargeattack")
        inst.components.locomotor.allow_platform_hopping = true
    end,

    events =
    {
        EventHandler("animover", function(inst) inst.sg:GoToState("charge_loop") end),
    },
  },

  State{
    name = "charge_loop",
    tags = {"charging", "moving", "running"},

    onenter = function(inst)
        inst.components.locomotor.allow_platform_hopping = false
        inst.components.locomotor:RunForward()
        inst.components.locomotor:SetExternalSpeedAdder(inst, "chargeattack", 5)
        inst.AnimState:PlayAnimation("charge_loop")
    end,

    onexit = function(inst)
		inst.components.locomotor:RemoveExternalSpeedAdder(inst, "chargeattack")
        inst.components.locomotor.allow_platform_hopping = true
    end,

    events =
    {
      EventHandler("animover", function(inst) inst.sg:GoToState("charge_loop") end),
    },
  },

  State{
    name = "charge_pst",
    tags = {"canrotate", "idle"},

    onenter = function(inst)
      inst.components.locomotor:Stop()
      inst.AnimState:PlayAnimation("charge_pst")
    end,

    events =
    {
      EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
    },
  },

  State{
    name = "charge_attack",
    tags = {"chargingattack", "busy"},

    onenter = function(inst)
      inst.components.combat:StartAttack()
      inst.components.locomotor:StopMoving()
      inst.AnimState:PlayAnimation("charge_atk")
      inst.SoundEmitter:PlaySound("ia/creatures/wild_boar/charge_attack")
    end,

    timeline =
    {
      TimeEvent(12*FRAMES, function(inst) 
          inst.components.combat:DoAttack()
          inst.components.combat:ResetCooldown() --TEST -M
		  -- inst.sg:RemoveStateTag("busy")
          inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
        end),
    },

    events =
    {
      EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
    },
  },


}

CommonStates.AddWalkStates(states,
  {
    walktimeline = {
      TimeEvent(0*FRAMES, PlayFootstep ),
      TimeEvent(12*FRAMES, PlayFootstep ),
    },
  })
CommonStates.AddRunStates(states,
  {
    runtimeline = {
      TimeEvent(0*FRAMES, PlayFootstep ),
      TimeEvent(10*FRAMES, PlayFootstep ),
    },
  })

CommonStates.AddSleepStates(states,
  {
    sleeptimeline = 
    {
      TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ia/creatures/wild_boar/sleep") end ),
    },
  })

CommonStates.AddIdle(states,"funnyidle")
CommonStates.AddSimpleState(states,"refuse", "pig_reject", {"busy"})
CommonStates.AddFrozenStates(states)
CommonStates.AddIpecacPoopState(states)
CommonStates.AddSimpleActionState(states,"pickup", "pig_pickup", 10*FRAMES, {"busy"})
CommonStates.AddSimpleActionState(states, "gohome", "pig_pickup", 4*FRAMES, {"busy"})
CommonStates.AddHopStates(states, true, { pre = "boat_jump_pre", loop = "boat_jump_loop", pst = "boat_jump_pst"}) --wildbores use the same bank as pigmen so this should work -Half
CommonStates.AddSinkAndWashAsoreStates(states)
return StateGraph("wildbore", states, events, "idle", actionhandlers)
