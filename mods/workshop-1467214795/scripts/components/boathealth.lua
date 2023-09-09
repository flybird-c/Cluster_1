local function onmaxhealth(self, maxhealth)
    self.inst.replica.boathealth._maxhealth:set(maxhealth)
end

local function oncurrenthealth(self, currenthealth)
    self.inst.replica.boathealth._currenthealth:set(currenthealth)
end

local function oninvincible(self, invincible)
    self.inst.replica.boathealth._invincible:set(invincible)
end

local BoatHealth = Class(function(self, inst)
    self.inst = inst
    self.consuming = false

    self.maxhealth = 100
    self.currenthealth = 0
    self.rate = 1

    self.period = 1
    self.bonusmult = 1
    self.depleted = nil
    self.depletionmultiplier = 1

    self.base_damage_scale = 1
    self.wave_damage_scale = 1
    self.attack_damage_scale = 1

    self.leakinghealth = 0

    self.damagesound = nil

    self.moving = false
    self.invincible = false

    self.inst:ListenForEvent("boatstartmoving", function() 
        self.moving = true
    end, self.inst)

    self.inst:ListenForEvent("boatstopmoving", function() 
        self.moving = false 
    end, self.inst)
end, nil, {
    maxhealth = onmaxhealth,
    currenthealth = oncurrenthealth,
    invincible = oninvincible,
})


function BoatHealth:MakeEmpty()
    if self.currenthealth > 0 then
        self:DoDelta(-self.currenthealth)
    end
end

function BoatHealth:OnSave()
    return {health = self.currenthealth, rate = self.rate}
end

function BoatHealth:OnLoad(data)
    self.rate = data.rate
    if data.health then
        self:SetHealth(data.health)
    end
end

function BoatHealth:SetDepletedFn(fn)
    self.depleted = fn
end

function BoatHealth:IsEmpty()
    return self.currenthealth <= 0
end

function BoatHealth:IsFull()
    return self.currenthealth >= self.maxhealth
end

function BoatHealth:SetUpdateFn(fn)
    self.updatefn = fn
end

function BoatHealth:GetDebugString()
    return string.format("%s %2.2f/%2.2f (-%2.2f)", self.consuming and "ON" or "OFF", self.currenthealth, self.maxhealth, self.rate)
end

function BoatHealth:GetPercent()
    if self.maxhealth > 0 then 
        return math.min(1, self.currenthealth / self.maxhealth)
    else
        return 0
    end
end

function BoatHealth:IsInvincible()
    return self.invincible
end

function BoatHealth:SetInvincible(val)
    self.invincible = val
    self.inst:PushEvent("boatinvincibletoggle", {invincible = val})
end

function BoatHealth:SetIsMoving(move)
    self.moving = move
end

function BoatHealth:SetPercent(amount)
    local target = (self.maxhealth * amount)
    self:DoDelta(target - self.currenthealth)
end

function BoatHealth:StartConsuming()
    self.consuming = true
    if self.task == nil then
        self.task = self.inst:DoPeriodicTask(self.period, function() self:DoUpdate(self.period) end)
    end
end

function BoatHealth:IsDead()
    return self.currenthealth <= 0
end

function BoatHealth:SetHealth(hp, perishtime)
    local oldpercent = self:GetPercent()
    if self.maxhealth < hp then
        self.maxhealth = hp
    end
    if perishtime then
        self.rate = hp / perishtime
    end
    self.currenthealth = hp
    self.inst:PushEvent("boathealthchange", {percent = self:GetPercent(), oldpercent = oldpercent, damage = false, currenthealth = hp, maxhealth = self.maxhealth})
end

function BoatHealth:DoDelta(amount, damageType, source, ignore_invincible)
    if self.invincible and not ignore_invincible then
        return
    end

    local sailor = self.inst.components.sailable and self.inst.components.sailable.sailor or nil

    if damageType == "combat" or damageType == "wave" then
        if self.damagesound and sailor then
            self.inst.SoundEmitter:PlaySound(self.damagesound)
        end
    end

    if self.moving and damageType == nil and amount < 0 then
        amount = amount * self.depletionmultiplier
    end

    local oldpercent = self:GetPercent()

    self.currenthealth = math.max(0, math.min(self.maxhealth, self.currenthealth + amount) )

    if self.currenthealth <= 0 and self.depleted then
        --This isn't great but deferring the function call is needed to fix a potential crash when dying from hitting a wave
        --When getting depleted by hitting a wave this function will be called from the waves onCollision callback 
        --The depleted function for boats causes the player to switch collision shapes which will cause a crash when done in the midst of the physics engine processing collisions 
        self.inst:DoTaskInTime(0, self.depleted) 
    end

    local percent = self:GetPercent()

    local isDamage = damageType == "wave" or damageType == "combat" or damageType == "fire"

    if self.hitfx and oldpercent-percent > TUNING.BOAT_HITFX_THRESHOLD
    and isDamage and damageType ~= "fire" then
        SpawnAt(self.hitfx, self.inst)
    end

    self.inst:PushEvent("boathealthchange", {percent = percent, oldpercent = oldpercent, damage = isDamage, currenthealth = self.currenthealth, maxhealth = self.maxhealth})
end

function BoatHealth:DoUpdate(dt)
    if self.consuming and self.moving then
        self:DoDelta(-dt*self.rate)
    end

    if self:IsEmpty() then
        self:StopConsuming()
    end

    if self.updatefn then
        self.updatefn(self.inst)
    end
end

function BoatHealth:StopConsuming()
    self.consuming = false
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

function BoatHealth:LongUpdate(dt)
    self:DoUpdate(dt)
end

function BoatHealth:IsLeaking()
    return self.currenthealth <= self.leakinghealth
end

return BoatHealth
