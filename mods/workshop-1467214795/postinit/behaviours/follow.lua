local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local unpack = unpack

--------------------------------------------------------------

require("behaviours/follow")

local function _momentum_distsq(inst, targ)
    local x, y, z = inst.Transform:GetWorldPosition()
    local x1, y1, z1 = targ.Transform:GetWorldPosition()
    local dx = x1 - x
    local dy = y1 - y
    local dz = z1 - z
    --Note: Currently, this is 3D including y-component
    return dx * dx + dy * dy + dz * dz, Vector3(x1, y1, z1)
end

local _Visit = Follow.Visit
function Follow:Visit(...)

    if self.status == READY or self.status == RUNNING then
        if self.inst.components.locomotor:HasMomentum() then
            if not self.hasmomentum then
                self.hasmomentum = true
                self:EvaluateDistances()
            end
        else
            if self.hasmomentum then
                self.hasmomentum = false
                self:EvaluateDistances()
            end
        end
    end

    local rets = {_Visit(self, ...)}

    if self.status == RUNNING then
        if self.action == "APPROACH" then
            if self.hasmomentum then
                local dist_sq = _momentum_distsq(self.inst, self.currenttarget)

                local different_platforms = self:AreDifferentPlatforms(self.inst, self.currenttarget)

                local currentSpeed = self.inst.Physics:GetMotorSpeed()
                local deceleration = self.inst.components.locomotor:GetDeceleration()
                local stopdistance = math.pow(currentSpeed, 2)/(deceleration * 2.0)

                dist_sq = dist_sq - stopdistance

                if not different_platforms and dist_sq < self.target_dist * self.target_dist then
                    self.action = "DECELERATING"
                    self.inst.components.locomotor:Stop()
                    return unpack(rets)
                end
            end
        elseif self.action == "BACKOFF" then
            if self.hasmomentum then
                local dist_sq = _momentum_distsq(self.inst, self.currenttarget)

                local currentSpeed = self.inst.Physics:GetMotorSpeed()
                local deceleration = self.inst.components.locomotor:GetDeceleration()
                local stopdistance = math.pow(currentSpeed, 2)/(deceleration * 2.0)

                dist_sq = dist_sq - stopdistance

                if dist_sq > self.target_dist * self.target_dist then
                    self.action = "DECELERATING"
                    self.inst.components.locomotor:Stop()
                    return unpack(rets)
                end
            end
        elseif self.action == "DECELERATING" then
            if self.hasmomentum then
                local dist_sq = _momentum_distsq(self.inst, self.currenttarget)
    
                local on_different_platforms = self:AreDifferentPlatforms(self.inst, self.currenttarget)

                if not on_different_platforms and dist_sq < self.min_dist * self.min_dist then
                    self.action = "BACKOFF"
                    return unpack(rets)
                elseif on_different_platforms or dist_sq > self.max_dist * self.max_dist then
                    self.action = "APPROACH"
                    return unpack(rets)
                elseif not self.inst.components.locomotor:WantsToMoveForward()
                    or not self.inst.components.locomotor:IsSlowing() then
                    self.status = SUCCESS
                    return unpack(rets)
                end
            else
                self.status = SUCCESS
                return unpack(rets)
            end
        end
    end
    return unpack(rets)
end

IAENV.AddGlobalClassPostConstruct("behaviours/follow", "Follow", function(self)
    -- Yah im lazy, I dont want to worry about manually patching the brain or assuming all critters have the same brain
    if self.inst ~= nil and self.inst.momentum_follow_bonus ~= nil then
        local _max_dist = self.max_dist_fn or self.max_dist
        self.max_dist_fn = function(inst, ...)
            local dist = type(_max_dist) ~= "function" and _max_dist or _max_dist(inst, ...)
            if inst.components.locomotor:HasMomentum() then
                return math.sqrt(dist * dist + inst.momentum_follow_bonus * inst.momentum_follow_bonus)
            end
            return dist
        end
        self.max_dist = nil
    
        local _target_dist = self.target_dist_fn or self.target_dist
        self.target_dist_fn = function(inst, ...)
            local dist = type(_target_dist) ~= "function" and _target_dist or _target_dist(inst, ...)
            if inst.components.locomotor:HasMomentum() then
                return math.sqrt(dist * dist + inst.momentum_follow_bonus * inst.momentum_follow_bonus)
            end
            return dist
        end
        self.target_dist = nil
    end
end)