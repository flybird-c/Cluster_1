local function onsailor(self)
    if self:IsOccupied() then
        self.inst:RemoveTag("sailable")
    else
        self.inst:AddTag("sailable")
    end
end

local function onhassailor(self, hassailor)
    if self.inst.replica and self.inst.replica.sailable then
        self.inst.replica.sailable._hassailor:set(hassailor)
    end
end

local Sailable =  Class(function(self, inst)
    self.inst = inst
    self.unoccupiedanim = "run_loop"
    self.hassailor = false
    self.isembarking = false
    self.sanitydrain = 0
    self.maprevealbonus = 0
    self.movementbonus = 0
    self.hitmoisturerate = 1.0
    self.hit_immunity = 0.66 --time in seconds the boat is immune to hit state reactions after being hit.
    self.next_hit_time = 0
    -- self.offset = nil
    -- self.alwaysoccupied = nil
end, nil, {
    sailor = onsailor,
    isembarking = onsailor,
    hassailor = onhassailor,
})

function Sailable:OnRemoveFromEntity()
    self.inst:RemoveTag("sailable")
end

function Sailable:GetSailor()
    return self.sailor
end

function Sailable:IsOccupied()
    return self.sailor ~= nil or self.isembarking or self.alwaysoccupied
end

function Sailable:CanDoHit()
    return self.next_hit_time <= GetTime()
end

function Sailable:GetHit()
    self.next_hit_time = GetTime() + self.hit_immunity
end

function Sailable:SetHitImmunity(time)
    self.hit_immunity = time
end

function Sailable:GetIsSailEquipped()
    if self.alwayssail then return true end

    if self.inst.components.container then
        local equipped = self.inst.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_SAIL)
        if equipped and equipped:HasTag("sail") then
            return true
        end
    end
    return false
end

function Sailable:OnEmbarked(sailor)
    self.sailor = sailor
    self.isembarking = false

    if self.inst.components.boathealth then
        self.inst.components.boathealth:StartConsuming()
    elseif self.inst.components.fueled then
        self.inst.components.fueled:StartConsuming()
    end
	if self.inst.MiniMapEntity then
		self.inst.MiniMapEntity:SetEnabled(false)
	end

    self.inst:PushEvent("embarked", {sailor = sailor})

    if self.inst.components.workable then
        self.inst.components.workable.workable = false
    end

    self.inst.replica.sailable:PlayIdleAnims(true)
end

function Sailable:OnDisembarked(sailor)
    if self.sailor == sailor then
        self.sailor = nil
    end

    if self.inst.components.boathealth then
        self.inst.components.boathealth:StopConsuming()
        self.inst.components.boathealth:SetIsMoving(false)
    elseif self.inst.components.fueled then
        self.inst.components.fueled:StopConsuming()
    end
	if self.inst.MiniMapEntity then
		self.inst.MiniMapEntity:SetEnabled(true)
	end

    self.inst:PushEvent("disembarked", {sailor = sailor})

    if self.inst.components.workable then
        self.inst.components.workable.workable = true
    end

    self.inst.AnimState:PlayAnimation(self.unoccupiedanim, true)
end

function Sailable:GetMovementBonus()
    return self.movementbonus
end

-- function Sailable:GetSanityDrain() always 0 in sw
--     return self.sanitydrain
-- end

function Sailable:GetHitMoistureRate()
    return self.hitmoisturerate
end

function Sailable:GetMapRevealBonus()
    return self.maprevealbonus
end

function Sailable:HasSailor()
    return self.hassailor
end

return Sailable