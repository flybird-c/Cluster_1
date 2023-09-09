local FlotsamRebatcher = Class(function(self, inst)
    self.inst = inst

    self.rebatchtime = TUNING.FLOTSAM_REBATCH_TIME
    self.individualtime = 0
    self.batchremaining = 0

    self.spawnradius = TUNING.FLOTSAM_BATCH_SPAWN_RADIUS
    self.batchsize = TUNING.FLOTSAM_BATCH_SIZE

    inst:StartUpdatingComponent(self)
end)

function FlotsamRebatcher:RainModifier()
    -- flotsam batches are more likely when it's raining ("storms!")
    return 1 + TheWorld.state.precipitationrate * 15
end

function FlotsamRebatcher:GetPlayer()
    local players = {}
    for i,player in pairs(AllPlayers) do
        if IsInDSTClimate(player) and player:IsOnValidGround() then
            table.insert(players, player)
        end
    end
    return GetRandomItem(players)
end

function FlotsamRebatcher:GetSpawnPoint(pt)
    local function TestOffset(offset)
        local _map = TheWorld.Map
        local x, y, z = (pt + offset):Get()
        local tile = _map:GetTileAtPoint(x, y, z)
        return IsOceanTile(tile) and _map:IsSurroundedByWater(x, y, z, 6)
    end

    local theta = math.random() * 360
    local resultoffset = FindValidPositionByFan(theta, self.spawnradius, 20, TestOffset)

    if resultoffset ~= nil then
        return pt + resultoffset
    end
end

function FlotsamRebatcher:SpawnSomeFlotsam(player)
    local pt = player:GetPosition()
    local spawnpoint = self:GetSpawnPoint(pt)
    if spawnpoint ~= nil then
        local flotsam = SpawnPrefab("flotsam")
        flotsam.Physics:Teleport(spawnpoint:Get())
        flotsam.components.drifter:SetDriftTarget(pt)
        if flotsam.debris ~= nil then
            for i,debris in pairs(flotsam.debris) do
                if debris.components.spawnfader ~= nil then
                    debris.components.spawnfader:FadeIn()
                end
            end
        end
    end
    self.batchremaining = self.batchremaining - 1
end

function FlotsamRebatcher:OnUpdate(dt)
    self.rebatchtime = self.rebatchtime - dt * self:RainModifier()

    if self.rebatchtime <= 0 then
        self.rebatchtime = TUNING.FLOTSAM_REBATCH_TIME
        self.batchremaining = self.batchremaining + self.batchsize.min + math.random(self.batchsize.max-self.batchsize.min)
    end

    self.individualtime = self.individualtime - dt

    if self.individualtime <= 0 then
        self.individualtime = TUNING.FLOTSAM_INDIVIDUAL_TIME
        if self.batchremaining > 0 then
            local player = self:GetPlayer()
            -- print("trying to spawn flotsam for", player)
            if player then
                self:SpawnSomeFlotsam(player)
            end
        end
    end
end

FlotsamRebatcher.LongUpdate = FlotsamRebatcher.OnUpdate

function FlotsamRebatcher:OnSave()
    return {
        rebatchtime = self.rebatchtime,
        individualtime = self.individualtime,
        batchremaining = self.batchremaining,
    }
end

function FlotsamRebatcher:OnLoad(data)
    self.rebatchtime = data.rebatchtime
    self.individualtime = data.individualtime
    self.batchremaining = data.batchremaining
end

function FlotsamRebatcher:GetDebugString()
    return string.format("rebatchtime: %.2f indivtime: %.2f batchremaining: %d", self.rebatchtime, self.individualtime, self.batchremaining)
end

return FlotsamRebatcher
