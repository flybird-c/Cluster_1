local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local FishingRod = require("components/fishingrod")

--completely override to get rid of equippable condition
function FishingRod:OnUpdate()
	if self:IsFishing() then
		if not self.fisherman:IsValid()
		or (not self.fisherman.sg:HasStateTag("fishing") and not self.fisherman.sg:HasStateTag("catchfish") )
		or (self.inst.components.equippable and not self.inst.components.equippable.isequipped) then
            self:StopFishing()
		end
	end
end

local _Collect = FishingRod.Collect
function FishingRod:Collect(...)
    if self.caughtfish and self.fisherman and IsOnOcean(self.fisherman) then
		--print("bargle, I'm boating!")

        if self.caughtfish.Physics ~= nil then
            self.caughtfish.Physics:SetActive(true)
        end
        self.caughtfish.entity:Show()
        if self.caughtfish.DynamicShadow ~= nil then
            self.caughtfish.DynamicShadow:Enable(true)
        end
		-- print("CAUGHT FISH",self.caughtfish,self.caughtfish.components.inventoryitem)
		self.fisherman.components.inventory:GiveItem(self.caughtfish, nil, self.fisherman:GetPosition())

        if self.caughtfish.components.inventoryitem then
            self.caughtfish.components.inventoryitem:SetSinks(self.caughtfish.shouldsink or false)
        end
        self.caughtfish.shouldsink = nil

        self.caughtfish.persists = true
        self.inst:PushEvent("fishingcollect", {fish = self.caughtfish} )
        self.fisherman:PushEvent("fishingcollect", {fish = self.caughtfish} )
        self:StopFishing()
    else
        if self.caughtfish then
            if self.caughtfish.components.inventoryitem then
                self.caughtfish.components.inventoryitem:SetSinks(self.caughtfish.shouldsink or false)
            end
            self.caughtfish.shouldsink = nil
        end
		return _Collect(self, ...)
	end
end

local _StartFishing = FishingRod.StartFishing
function FishingRod:StartFishing(target, fisherman, ...)
	_StartFishing(self, target, fisherman, ...)
    if target ~= nil and (target.components.workable
      and target.components.workable:GetWorkAction() == ACTIONS.FISH
      and target.components.workable:CanBeWorked()
      or target.components.flotsamfisher) then
        self.target = target
        self.fisherman = fisherman
    end
end

function FishingRod:Retrieve()
    local numworks = 1
    if self.fisherman and self.fisherman.components.worker then
        numworks = self.fisherman.components.worker:GetEffectiveness(ACTIONS.FISH)
    end
    if self.target and self.target.components.workable then
        self.target.components.workable:WorkedBy(self.fisherman, numworks)
        self.inst:PushEvent("fishingcollect")
        self.target:PushEvent("fishingcollect")
        self:StopFishing()
    end
end

function FishingRod:CollectFlotsam()
    if self.target and self.target.components.flotsamfisher and self.fisherman then
        self.target.components.flotsamfisher:Fish(self.fisherman)
        self.inst:PushEvent("fishingcollect", {fish = nil} )
        self.fisherman:PushEvent("fishingcollect", {fish = nil} )
        self:StopFishing()
    end
end
