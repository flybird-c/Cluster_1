-- A modified version of unevenground thats more general
-- Used as a more optimized version of the slow tasks in ds

local SlowingObject = Class(function(self, inst)
    self.inst = inst
    self.enabled = true
    self.key = "TAR"
    self.detectradius = 15
    self.detectperiod = .6
    self.detecttask = nil
    if not inst:IsAsleep() then
        self:Start()
    end
end)

local function OnNotifyNearbyEntities(inst, self)
    local x, y, z = inst.Transform:GetWorldPosition()
    local slowers = self:GetSlowers(x, y, z)
    if self.UpdateSlowdown ~= nil then
        self:UpdateSlowdown(slowers)
    end

    local rangesq = self.range * self.range
    for _, slowinst in ipairs(slowers)do
        if self.CanSlow == nil or self:CanSlow(slowinst, x, y, z, rangesq) then
                
            if slowinst.components.slowingobjectmanager == nil then
                slowinst:AddComponent("slowingobjectmanager")
            end
            slowinst.components.slowingobjectmanager:TrackTarget(inst, self.key, rangesq, self.detectperiod, self.OnUse)
        end
	end
end

local function OnStartTask(inst, self)
    self.detecttask = self.inst:DoPeriodicTask(self.detectperiod, OnNotifyNearbyEntities, self.delay or (self.detectperiod * (.3 + .7 * math.random())), self)
    OnNotifyNearbyEntities(self.inst, self)
end

local MUST_TAGS = {"locomotor"}
local CANT_TAGS = {"playerghost", "ghost", "shadow", "brightmare", "flying"}
function SlowingObject:GetSlowers(x, y, z)
    return TheSim:FindEntities(x, y , z, self.detectradius, MUST_TAGS, CANT_TAGS)
end

function SlowingObject:Start()
    if self.detecttask == nil then
        self.detecttask = self.inst:DoTaskInTime(0, OnStartTask, self)
    end
end

function SlowingObject:Stop()
    if self.detecttask ~= nil then
        self.detecttask:Cancel()
        self.detecttask = nil
    end
end

function SlowingObject:Enable()
    if not self.enabled then
        self.enabled = true
        if not self.inst:IsAsleep() then
            self:Start()
        end
    end
end

function SlowingObject:Disable()
    if self.enabled then
        self.enabled = false
        self:Stop()
    end
end

function SlowingObject:OnEntityWake()
    if self.enabled then
        self:Start()
    end
end

SlowingObject.OnEntitySleep = SlowingObject.Stop
SlowingObject.OnRemoveFromEntity = SlowingObject.Stop

return SlowingObject
