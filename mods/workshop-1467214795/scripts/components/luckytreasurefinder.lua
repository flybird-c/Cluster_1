local LuckyTreasureFinder = Class(function(self, inst)
    self.inst = inst

    self.num_found = 0

    self.owner = nil
end)

function LuckyTreasureFinder:Start(owner)
    self.owner = owner
end

function LuckyTreasureFinder:Stop()
    self.owner = nil
end

function LuckyTreasureFinder:GetChanceLuck()
    if self.owner == nil then
        return -1
    elseif self.owner:HasTag("piratecaptain") then
        return 1
    end
    return 0.66
end

function LuckyTreasureFinder:RevealTreasures()
    -- if TheCamera.interior then  -- For Hamlet houses
    --     if equipper and equipper.components.talker then
    --         equipper.components.talker:Say(GetString(equipper.prefab, "ANNOUNCE_WOODLEGSHAT_INDOORS"))
    --     end
    --     return
    -- end
    for i = 1, self.num_found do
        local pos = self.inst:GetPosition()
        local offset = FindWalkableOffset(pos, math.random() * 2 * math.pi, math.random(25, 30), 18)

        if offset then
            local spawn_pos = pos + offset
            local treasure = SpawnPrefab("buriedtreasure")

            treasure.Transform:SetPosition(spawn_pos:Get())
            treasure:SetRandomTreasure()

            if self.owner then
                self.owner:PushEvent("treasureuncover")
            end
            self.num_found = self.num_found - 1
        end
    end
end

function LuckyTreasureFinder:FindTreasure()
    if math.random() <= self:GetChanceLuck() then
        self.num_found = self.num_found + 1
    end
end

function LuckyTreasureFinder:OnRemoveFromEntity()
    self:RevealTreasures()
    self:Stop()
end

function LuckyTreasureFinder:OnSave()
    local data = {}
    data.num_found = self.num_found
    return data
end   

function LuckyTreasureFinder:OnLoad(data) 
    if data == nil then return end
	self.num_found = data.num_found or 0
end

return LuckyTreasureFinder
