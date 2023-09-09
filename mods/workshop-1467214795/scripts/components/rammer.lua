local Rammer = Class(function(self, inst)
    self.inst = inst
    self.sailor = nil

    self.minSpeed = 2.0
    self.cooldowntime = 0.5
    self.oncooldown = false
    self.checkRadius = 3
    self.hitRadius = 1

    self.wasactive = false

    self.onactivatefn = nil
    self.ondeactivatefn = nil
    self.onupdatefn = nil
    self.onramtargetfn = nil

    self.notags = {"FX", "NOCLICK", "DECOR", "INLIMBO","unramable"}
end)

function Rammer:SetMinSpeed(speed)
    self.minSpeed = speed
end

function Rammer:SetOnActivate(fn)
    self.onactivatefn = fn
end

function Rammer:SetOnDeactivate(fn)
    self.ondeactivatefn = fn
end

function Rammer:SetOnUpdate(fn)
    self.onupdatefn = fn
end

function Rammer:SetOnRamTarget(fn)
    self.onramtargetfn = fn
end

function Rammer:FindSailor()
    return self.sailor
end

function Rammer:StartCooldown()
    self.oncooldown = true
    self.inst:DoTaskInTime(self.cooldowntime, function() self.oncooldown = false end)
end

function Rammer:Start(sailor)
    if sailor == nil then return print("rammer failed to start due to lack of sailor") end
    self.sailor = sailor
    self.inst:StartUpdatingComponent(self)
end

function Rammer:Stop()
    self.sailor = nil
    self.inst:StopUpdatingComponent(self)
    if self.wasactive then
        if self.ondeactivatefn ~= nil then
            self.ondeactivatefn(self.inst)
        end
        self.wasactive = false
    end
end

function Rammer:IsInHitCone(ent, sailor)

    if sailor.Physics == nil or ent.Physics == nil then
        return false
    end

    local sailor_vel = Vector3(sailor.Physics:GetVelocity())
    local origin = Vector3(self.inst.Transform:GetWorldPosition())
    local point = Vector3(ent.Transform:GetWorldPosition())

    local offset = (point - origin):GetNormalized()

    local maxDistance = self.hitRadius + sailor.Physics:GetRadius() + ent.Physics:GetRadius()

    local len_sq = offset:LengthSq()
    if len_sq > (maxDistance * maxDistance) then
        return false
    else
        return sailor_vel:GetNormalized():Dot(offset) > 0.75
    end
end

function Rammer:CheckRamHit()

    if self.inst == nil or self.inst:IsValid() == false then
        print("Component instance is invalid!")
        return
    end

    local sailor = self:FindSailor()

    if self.onramtargetfn == nil then
        print("onramtargetfn is not set, stopping rammer")
        self:Stop()
        return
    end

    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, sailor.Physics:GetRadius() + self.hitRadius * 2, nil, self.notags)

    for i, ent in pairs(ents) do
        if ent ~= sailor 
            and (ent.components.health == nil or ent.components.health.currenthealth > 0)
            and (not ent:HasTag("shadow") or sailor.components.sanity == nil or not sailor.components.sanity:IsCrazy()) then
            if self:IsInHitCone(ent, sailor) then           
                self.onramtargetfn(self.inst, ent)
            end
        end
    end
end


function Rammer:OnUpdate(dt)
    -- toggle on/off callbacks
    if self:IsActive() then
        if not self.wasactive then
            if self.onactivatefn ~= nil then
                self.onactivatefn(self.inst)
            end
            self.wasactive = true
        end

        self:CheckRamHit()

        if self.onupdatefn ~= nil then
            self.onupdatefn(self.inst, dt)
        end
    else
        if self.wasactive then
            if self.ondeactivatefn ~= nil then
                self.ondeactivatefn(self.inst)
            end
            self.wasactive = false
        end
    end
end

function Rammer:IsActive()
    local sailor = self:FindSailor()

    local v = Vector3(sailor.Physics:GetVelocity())
    local minSpeedSq = self.minSpeed * self.minSpeed

    return (v:LengthSq() >= minSpeedSq) and not self.oncooldown
end

function Rammer:DebugRender()
    if TheSim:GetDebugRenderEnabled() then
        if self.inst.draw then
            self.inst.draw:Flush()
            self.inst.draw:SetRenderLoop(true)
            self.inst.draw:SetZ(0.15)

            local dim = 2.0 * self.range
            local x, y, z = self.inst.Transform:GetWorldPosition()

            self.inst.draw:Box(x - self.range, z - self.range, dim, dim, 0, 1, 0, 1)
        else
            --TheSim:SetDebugRenderEnabled(true)
            self.inst.draw = self.inst.entity:AddDebugRender()
        end
    end
end

return Rammer
