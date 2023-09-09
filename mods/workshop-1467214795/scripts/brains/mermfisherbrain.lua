require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/chattynode"

local SEE_HOME_DIST = 18
local MAX_WANDER_DIST = 15
local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8

local MermFisherBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GoHomeAction(inst)
	if not inst.components.combat.target
		and inst.components.homeseeker 
		and inst.components.homeseeker.home 
		and inst.components.homeseeker.home:IsValid()
		and not (inst.components.homeseeker.home.components.burnable ~= nil
			and inst.components.homeseeker.home.components.burnable:IsBurning())
		and not inst.components.homeseeker.home:HasTag("burnt") then
		return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
	end
end

local function ShouldGoHome(inst)
	--one merm should stay outside
	local home = inst.components.homeseeker ~= nil and inst.components.homeseeker.home or nil
	return TheWorld.state.isday
		and home ~= nil
		and (home.components.childspawner == nil
			or home.components.childspawner:CountChildrenOutside() > 1)
end

local function Fish(inst)
    local pond = FindEntity(inst, 20, nil, {"fishable"})

    if pond and not inst.sg:HasStateTag("fishing") and inst.CanFish then
        return BufferedAction(inst, pond, ACTIONS.FISH)
    end
end

local function IsHomeOnFire(inst)
    return inst.components.homeseeker
        and inst.components.homeseeker.home
        and inst.components.homeseeker.home.components.burnable
        and inst.components.homeseeker.home.components.burnable:IsBurning()
        and inst.components.homeseeker.home:IsNear(inst, SEE_HOME_DIST)
end

function MermFisherBrain:OnStart()

    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.components.hauntable ~= nil and self.inst.components.hauntable.panic end, "PanicHaunted", 
            ChattyNode(self.inst, "MERM_TALK_PANIC",
                Panic(self.inst))),

        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", 
            ChattyNode(self.inst, "MERM_TALK_PANIC",
                Panic(self.inst))),

        WhileNode(function() return self.inst.components.combat.target ~= nil and not self.inst.sg:HasStateTag("fishing") end, "Is Threatened",
			ChattyNode(self.inst, "MERM_TALK_RUNAWAY",
				RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST))),
        
        WhileNode( function() return IsHomeOnFire(self.inst) end, "HomeOnFire", 
            ChattyNode(self.inst, "MERM_TALK_PANIC",
                Panic(self.inst))),

        ChattyNode(self.inst, "MERM_TALK_GO_HOME",
            WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome", DoAction(self.inst, GoHomeAction, "Go Home", true))),

        ChattyNode(self.inst, "MERM_TALK_FISH",
            DoAction(self.inst, Fish, "Fish Action")),

        WhileNode(function() return not self.inst.sg:HasStateTag("fishing") end, "Is Idle",
			Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST)),
    }, 0.25)
    
    self.bt = BT(self.inst, root)
end

return MermFisherBrain
