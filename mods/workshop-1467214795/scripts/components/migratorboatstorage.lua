-- TODO: Some way to undock boats if the player travels back to this shard via a different worldmigrator
-- Maybe auto undock boats when the player enters this shard through a different migrator??

local function EvictBoat(boat, pos, radius)
    local offset = FindSwimmableOffset(pos, math.random() * PI * 2, radius, 8, false, true)
    if offset ~= nil then pos = pos + offset end
    boat.Transform:SetPosition(pos:Get())
end

local MigratorBoatStorage = Class(function(self, inst)
    self.inst = inst

    self.stored_boats = {}
end)

function MigratorBoatStorage:HasPlayerBoat(userid)
    return self.stored_boats[userid] ~= nil
end

function MigratorBoatStorage:DockPlayerBoat(player)
    local boat = player.components.sailor:GetBoat()
    if boat ~= nil then
        if self:HasPlayerBoat(player.userid) then
            EvictBoat(self:SpawnPlayerBoat(player.userid), self.inst:GetPosition(), self.inst:GetPhysicsRadius(0) + .5)
        end
        player.components.sailor:Disembark()
        self:SavePlayerBoat(player.userid, boat)

    end
end

function MigratorBoatStorage:UnDockPlayerBoat(player)
    if not self:HasPlayerBoat(player.userid) then return end

    local boat = self:SpawnPlayerBoat(player.userid)

    if boat == nil or not boat:IsValid() then return end

    if not player:CanOnWater(true) then -- TODO maybe a more specific "canembark" check? -Half
        player.components.sailor:Embark(boat)
    else
        EvictBoat(boat, self.inst:GetPosition(), self.inst:GetPhysicsRadius(0) + .5)
    end
    
    return boat
end

function MigratorBoatStorage:SavePlayerBoat(userid, boat)
    self.stored_boats[userid] = boat:GetSaveRecord()
    self.stored_boats[userid].prefab = boat.actualprefab or self.stored_boats[userid].prefab
    boat:Remove()
end

function MigratorBoatStorage:SpawnPlayerBoat(userid)
    local boat = SpawnSaveRecord(self.stored_boats[userid])
    self.stored_boats[userid] = nil
    return boat
end

function MigratorBoatStorage:OnSave()
    return {
        stored_boats = self.stored_boats,
    }
end

function MigratorBoatStorage:OnLoad(data)
    if data then
        self.stored_boats = data.stored_boats or {}
    end
end

return MigratorBoatStorage
