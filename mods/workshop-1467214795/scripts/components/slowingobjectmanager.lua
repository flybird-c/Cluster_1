local next = next
local MODIFIERS = TUNING.SLOWING_OBJECT_MODIFIERS

local function onslowing(self, slowing)
    if self.inst.player_classified ~= nil then
        self.inst.player_classified.slowing_object:set(slowing)
    end
end

local SlowingObjectManager = Class(function(self, inst)
    self.inst = inst
    self.careful = false
    self.ismastersim = TheWorld.ismastersim
    self.targets = {}
    self.enabled = {}
    self.slowing = false
end,
nil,
{
    slowing = onslowing,
})

function SlowingObjectManager:TrackTarget(target, key, rangesq, duration, onuse)
    local data = self.targets[target]
    if data == nil then
        data = {}
        data.onuse = onuse
        data.key = key
        self.targets[target] = data
        self.inst:StartUpdatingComponent(self)
    end
    data.rangesq = rangesq
    data.remaining = duration + .05
end

function SlowingObjectManager:IsSlowing()
    return self.slowing
end

function SlowingObjectManager:ToggleModifier(key, mult, enabled)
    if enabled then
        if not self.enabled[key] then
            if not self.slowing and next(self.enabled) == nil then
                self.slowing = true
            end
            self.enabled[key] = true
            if self.ismastersim and self.inst.components.locomotor ~= nil then
                self.inst.components.locomotor:SetExternalSpeedMultiplier(self.inst, key, mult)
            end
        end
    elseif self.enabled[key] then
        self.enabled[key] = nil
        if self.slowing and next(self.enabled) == nil then
            self.slowing = false
        end
        if self.ismastersim and self.inst.components.locomotor ~= nil then
            self.inst.components.locomotor:RemoveExternalSpeedMultiplier(self.inst, key)
        end
    end
end

function SlowingObjectManager:OnUpdate(dt)
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local toremove
    local toenable = {}
    for k, v in pairs(self.targets) do
        if v.remaining > dt and k:IsValid() then
            v.remaining = v.remaining - dt
            if not toenable[v.key] and k:GetDistanceSqToPoint(x, y, z) < v.rangesq then
                toenable[v.key] = true
                if v.onuse then
                    v.onuse(k, self.inst)
                end
            end
        elseif toremove ~= nil then
            table.insert(toremove, k)
        else
            toremove = { k }
        end
    end

    if toremove ~= nil then
        for i, v in ipairs(toremove) do
            self.targets[v] = nil
        end
        if next(self.targets) == nil then
            self.inst:StopUpdatingComponent(self)
        end
    end

    for k, v in pairs(MODIFIERS) do
        self:ToggleModifier(k, v, toenable[k])
    end
end

return SlowingObjectManager
