local CHECK_OFFSETS = {
    Vector3(1, 0, 0),
    Vector3(1, 0, 1),
    Vector3(0, 0, 1),
    Vector3(-1, 0, 1),
    Vector3(-1, 0, 0),
    Vector3(-1, 0, -1),
    Vector3(0, 0, -1),
    Vector3(1, 0, -1),
}

local Drifter = Class(function(self, inst)
    self.inst = inst
    self.drifttarget = nil
    --self.lastdrifttime = nil

    self.lastcheckidx = 0
end)

function Drifter:SetDriftTarget(pos)
    self.drifttarget = pos
    self.inst:StartUpdatingComponent(self)
end

function Drifter:Stop()
    self.drifttarget = nil
    self.inst:StopUpdatingComponent(self)
end

function Drifter:OnUpdate(dt)
    if self.drifttarget then
        --self.lastdrifttime = GetTime()
        local pos = Vector3(self.inst.Transform:GetWorldPosition())
        local offset = self.drifttarget - pos
        offset:Normalize()
        offset = offset * TUNING.FLOTSAM_DRIFT_SPEED

        self.lastcheckidx = (self.lastcheckidx + 1) % #CHECK_OFFSETS
        local x, y, z = (pos + CHECK_OFFSETS[self.lastcheckidx + 1] * (self.radius or 1)):Get()
        local tile = TheWorld.Map:GetTileAtPoint(x, y, z)
        if not IsOceanTile(tile) then
            self:Stop()
            return
        end
        --we can actually bump into stuff in dst, so use velocity instead, no going through boats and such
        self.inst.Physics:SetVel(offset.x, 0, offset.z)

        --self.inst.Transform:SetPosition((pos + (offset * dt * TUNING.FLOTSAM_DRIFT_SPEED)):Get())
    end
end

function Drifter:OnSave()
    local data = {}
    data.drifttarget = self.drifttarget
    return data
end

function Drifter:OnLoad(data)
    if data ~= nil and data.drifttarget ~= nil then
        self:SetDriftTarget( Vector3(data.drifttarget.x, data.drifttarget.y, data.drifttarget.z) )
    end
end

return Drifter
