--[[
local function PlayerHasLavae(item)
    return item.components.petleash and item.components.petleash.numpets > 0
end
--]]
local function onboat(self, boat)
    if self.inst.replica.sailor then
        self.inst.replica.sailor._boat:set(boat)
    end
end

local function onsailing(self, sailing)
    if sailing then
        self.inst:AddTag("sailing")
    else
        self.inst:RemoveTag("sailing")
    end
end

local Sailor = Class(function(self, inst)
    self.inst = inst
    self.boat = nil
    self.sailing = false
    self.durabilitymultiplier = 1.0
    self.warningthresholds = --Moved these back to sailor from wisecracker -Z
    {
      { percent = 0.5, string = "ANNOUNCE_BOAT_DAMAGED" },
      { percent = 0.3, string = "ANNOUNCE_BOAT_SINKING" },
      { percent = 0.1, string = "ANNOUNCE_BOAT_SINKING_IMMINENT" },
    }
end,
nil,
{
    boat = onboat,
    sailing = onsailing,
})

--[[
function Sailor:HandleFollowers(water)
    local ChangeScene
    if water then
        local entpt

        function ChangeScene(ent)
            if not ent:HasTag("INLIMBO") --is it already removed?
            and not (ent.components.inventoryitem and ent.components.inventoryitem.owner ~= nil)
            and not ent:CanOnWater() then

                SpawnAt("spawn_fx_small", ent)
                ent:RemoveFromScene()
            elseif ent:HasTag("INLIMBO") --is it already removed?
            and not (ent.components.inventoryitem and ent.components.inventoryitem.owner ~= nil)
            and ent:CanOnWater() then

                if not entpt then -- Only do this once, if needed
                    entpt = Vector3(GetNextTickPosition(self.inst, false, TickSpeedToSpeed(3)))
                    SpawnAt("spawn_fx_small", entpt)
                end
                ent.Transform:SetPosition(entpt:Get())
                ent:ReturnToScene()

                if ent.components.spawnfader ~= nil then
                    ent.components.spawnfader:FadeIn()
                end
            end
        end
    else
        local entpt

        function ChangeScene(ent)
            if not ent:HasTag("INLIMBO") --is it already removed?
            and not (ent.components.inventoryitem and ent.components.inventoryitem.owner ~= nil)
            and not ent:CanOnLand() then

                SpawnAt("spawn_fx_small", ent)
                ent:RemoveFromScene()
            elseif ent:HasTag("INLIMBO") --is it already removed?
            and not (ent.components.inventoryitem and ent.components.inventoryitem.owner ~= nil)
            and ent:CanOnLand() then

                if not entpt then -- Only do this once, if needed
                    entpt = Vector3(GetNextTickPosition(self.inst, false, TickSpeedToSpeed(3)))
                    SpawnAt("spawn_fx_small", entpt)
                end
                ent.Transform:SetPosition(entpt:Get())
                ent:ReturnToScene()

                if ent.components.spawnfader ~= nil then
                    ent.components.spawnfader:FadeIn()
                end
            end
        end
    end
    if self.inst.components.inventory ~= nil then
        for k, item in pairs(self.inst.components.inventory.itemslots) do
            if item.components.leader ~= nil then
                for follower, v in pairs(item.components.leader.followers) do
                    ChangeScene(follower)
                end
            end
        end
        --special special case, look inside equipped containers
        for k, equipped in pairs(self.inst.components.inventory.equipslots) do
            if equipped.components.container ~= nil then
                for j, item in pairs(equipped.components.container.slots) do
                    if item.components.leader ~= nil then
                        for follower, v in pairs(item.components.leader.followers) do
                            ChangeScene(follower)
                        end
                    end
                end
            end
        end
    end

    -- This can be an arbitrary number of items
    for i, item in pairs(self.inst.components.inventory:FindItems(PlayerHasLavae)) do
        for j, pet in pairs(item.components.petleash:GetPets()) do
            ChangeScene(pet)
        end
    end

    if self.inst.components.petleash then
        for i, pet in pairs(self.inst.components.petleash:GetPets()) do
            ChangeScene(pet)
        end
    end

    if self.inst.components.leader ~= nil and self.inst.components.leader:CountFollowers() > 0 then
        for follower, v in pairs(self.inst.components.leader.followers) do
            ChangeScene(follower)
        end
    end
end
--]]

function Sailor:GetBoat()
    return self.boat
end

function Sailor:AlignBoat(direction)
    if self.boat then
        self.boat.Transform:SetRotation(direction or self.inst.Transform:GetRotation())
    end
end

-- This needs to save, because we're removing the boat from the scene
-- to prevent the player from dying upon logging back in.
function Sailor:OnSave()
    local data = {}
    if self.boat ~= nil and self.boat.persists then
        data.boat = self.boat:GetSaveRecord()
        data.boat.prefab = self.boat.actualprefab or self.boat.prefab
    end
    return data
end

function Sailor:OnLoad(data)
    if data and data.boat ~= nil then
        local boat = SpawnSaveRecord(data.boat)
        if boat then
            self:Embark(boat, true)
            if boat.components.container then
                boat:DoTaskInTime(0.3, function()
                    if boat.components.container:IsOpen() then
                        boat.components.container:Close(true)
                    end
                end)
                boat:DoTaskInTime(1.5, function()
                    boat.components.container:Open(self.inst)
                end)
            end
        end
    end
end

function Sailor:OnUpdate(dt)
    if self.boat ~= nil and self.boat:IsValid() then
        if self.boat.components.boathealth then
            self.boat.components.boathealth.depletionmultiplier = 1.0/self.durabilitymultiplier
        end
    end
end

function Sailor:Disembark(pos, boat_to_boat, nostate)
    self.sailing = false
    self.inst:StopUpdatingComponent(self)

    if self.boat.onboatdelta then
        self.inst:RemoveEventCallback("boathealthchange", self.boat.onboatdelta, self.boat)
        self.boat.onboatdelta = nil
    end

    if self.boat.components.container then
        self.boat.components.container:Close(true)
    end

    if self.inst.components.farseer then
        self.inst.components.farseer:RemoveBonus("boat")
    end

    -- if self.inst:HasTag("piratecaptain") and self.boat.components.sailable then -- always 0 in sw
    --     self.boat.components.sailable.sanitydrain = self.cachedsanitydrain
    --     self.cachedsanitydrain = nil
    -- end

    self.inst:RemoveChild(self.boat)
    if self.boat.components.highlightchild then
        self.boat.components.highlightchild:SetOwner(nil)
    end
    -- if self.inst.components.bloomer then
    --     self.inst.components.bloomer:DetachChild(self.boat)
    -- end
    if self.inst.components.colouradder then
        self.inst.components.colouradder:DetachChild(self.boat)
    end
    if self.inst.components.eroder then
        self.inst.components.eroder:DetachChild(self.boat)
    end
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local offset = self.boat.components.sailable.offset
    if offset ~= nil then
        x = x + offset.x
        y = y + offset.y
        z = z + offset.z
    end
    if self.boat.Physics then
        self.boat.Physics:Teleport(x, y, z)
    else
        self.boat.Transform:SetPosition(x, y, z)
    end
    self:AlignBoat()

    self.inst.components.locomotor.hasmomentum = false

    self.inst.components.locomotor:RemoveExternalSpeedAdder(self.boat, "SAILOR")

    -- Klei lies they are infact used and they keep making players try to walk to shore...
    if not self.inst.components.locomotor:IsAmphibious() then
        self.inst.components.locomotor.pathcaps = self.inst.components.locomotor.pathcaps or {}
        self.inst.components.locomotor.pathcaps.ignoreLand = false
        self.inst.components.locomotor.pathcaps.allowocean = false
    end

    self.inst:RemoveTag("sailing")
    self.inst:PushEvent("disembarkboat", {target = self.boat, pos = pos, boat_to_boat = boat_to_boat})

    if self.OnDisembarked then
        self.OnDisembarked(self.inst)
    end

    if self.boat.components.sailable then
        self.boat.components.sailable:OnDisembarked(self.inst)
    end

    self.boat = nil

    --self:HandleFollowers(false)

    if not nostate then
        if pos then
            self.inst.sg:GoToState("jumpoffboatstart", pos)
        elseif boat_to_boat then
            self.inst.sg:GoToState("jumponboatstart")
        end
    end
end

function Sailor:Embark(boat, nostate)
    if not boat or boat.components.sailable == nil then
        return
    end

    self.sailing = true
    self.boat = boat

    -- if self.inst:HasTag("piratecaptain") then -- always 0 in sw
    --     self.cachedsanitydrain = boat.components.sailable.sanitydrain
    --     boat.components.sailable.sanitydrain = 0
    -- end

    self.inst:StartUpdatingComponent(self)

    if self.boat.components.sailable.flotsambuild then
        self.inst.AnimState:OverrideSymbol("flotsam", self.boat.components.sailable.flotsambuild, "flotsam")
    end

    self.inst:AddTag("sailing")
    if not nostate then
        self.inst.sg:GoToState("jumpboatland")
    end

    self.inst:AddChild(self.boat)
    if self.boat.components.highlightchild then
        self.boat.components.highlightchild:SetOwner(self.inst)
    end
    -- if self.inst.components.bloomer then
    --     self.inst.components.bloomer:AttachChild(self.boat)
    -- end
    if self.inst.components.colouradder then
        self.inst.components.colouradder:AttachChild(self.boat)
    end
    if self.inst.components.eroder then
        self.inst.components.eroder:AttachChild(self.boat)
    end
    local x, y, z = 0, -0.1, 0
    local offset = self.boat.components.sailable.offset
    if offset ~= nil then
        x = x + offset.x
        y = y + offset.y
        z = z + offset.z
    end
    if self.boat.Physics then
        self.boat.Physics:Teleport(x, y, z)
    else
        self.boat.Transform:SetPosition(x, y, z)
    end
    self.boat.Transform:SetRotation(0)

    self.inst.components.locomotor:SetExternalSpeedAdder(boat, "SAILOR", boat.components.sailable.movementbonus)

    self.inst.components.locomotor.hasmomentum = true

    -- Klei lies they are infact used and they keep making players try to walk to shore...
    if not self.inst.components.locomotor:IsAmphibious() then
        self.inst.components.locomotor.pathcaps = self.inst.components.locomotor.pathcaps or {}
        self.inst.components.locomotor.pathcaps.ignoreLand = true
        self.inst.components.locomotor.pathcaps.allowocean = true
    end

    --Listen for boat taking damage, talk if it is!
    boat.onboatdelta = function(boat, data)
        if data then
            local old = data.oldpercent
            local new = data.percent
            local message = nil
            for _, threshold in ipairs(self.warningthresholds) do
                if old > threshold.percent and new <= threshold.percent then
                    message = threshold.string
                end
            end

            if message then
                self.inst:PushEvent("boat_damaged", {message = message})
            end
        end
    end
    self.inst:ListenForEvent("boathealthchange", boat.onboatdelta, boat)

    if boat.components.boathealth then
        local percent = boat.components.boathealth:GetPercent()
        boat.onboatdelta(boat, {oldpercent = 1, percent = percent})
    end


    if self.inst.components.farseer and boat.components.sailable and boat.components.sailable:GetMapRevealBonus() then
        self.inst.components.farseer:AddBonus("boat", boat.components.sailable:GetMapRevealBonus())
    end


    if boat.components.container then
        if boat.components.container:IsOpen() then
            boat.components.container:Close(true)
        end
        boat:DoTaskInTime(0.25, function() boat.components.container:Open(self.inst) end)
    end

    --self:HandleFollowers(true)

    self.inst:PushEvent("embarkboat", {target = self.boat})
    
    if self.OnEmbarked then
        self.OnEmbarked(self.inst)
    end

    if self.boat.components.sailable then
        self.boat.components.sailable:OnEmbarked(self.inst)
    end
end

function Sailor:IsSailing()
    return self.sailing and self.boat ~= nil
end

return Sailor
