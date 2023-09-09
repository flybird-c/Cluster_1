local PREDATOR_SPAWN_DIST = 30

local function onvolume(self, volume)
    if volume > 0 then
        self.inst:AddTag("breederharvest")
    else
        self.inst:RemoveTag("breederharvest")
    end
end

local function onseeded(self, seeded)
    if not seeded then
        self.inst:AddTag("canbeseeded")
    else
        self.inst:RemoveTag("canbeseeded")
    end
end

local Breeder = Class(function(self, inst)
    self.inst = inst

    --V2C: Recommended to explicitly add tag to prefab pristine state
    self.inst:AddTag("breeder")

    self.crops = {}
    self.volume = 0
    self.max_volume = 4
    self.seeded = false
    self.harvestable = false
    self.level = 1
    self.croppoints = {}
    self.growrate = 1

    self.haspredators = true

    self.luretime = TUNING.SEG_TIME * 5
    self.cycle_min = TUNING.SEG_TIME * 6
    self.cycle_max = TUNING.SEG_TIME * 10
end,
nil,
{
    seeded = onseeded,
    volume = onvolume,
})

function Breeder:IsEmpty()
    return self.volume == 0
end

function Breeder:OnSave()
    local data = {
        harvestable = self.harvestable,
        volume = self.volume,
        seeded = self.seeded,
        product = self.product,
        harvested = self.harvested,
    }

    if self.BreedTask then     
        data.breedtasktime = GetTaskRemaining(self.BreedTask)     
    end

    return data
end    

function Breeder:OnLoad(data, newents)
    self.volume = data.volume
    self.seeded = data.seeded
    self.harvestable = data.harvestable
    self.product = data.product
    self.harvested= data.harvested

    if data.breedtasktime then
        self.BreedTask = self.inst:DoTaskInTime(data.breedtasktime, function() self:CheckVolume() end)
    end

    self.inst:DoTaskInTime(0, function(inst) inst:PushEvent("vischange") end)
end

function Breeder:CheckSeeded()
    if self.volume < 1 and not self.harvestable then        
        self:StopBreeding()
    end 
    self.inst:PushEvent("vischange")
end

function Breeder:UpdateVolume(delta)
    self.volume = math.clamp(self.volume + delta, 0, self.max_volume)
    self:CheckSeeded()
end

function Breeder:GetPredatorPrefab(inst, pt)
    local x, y, z = inst.Transform:GetWorldPosition()
    local tile, tileinfo = inst:GetCurrentTileType(x, y, z)

    local ROT_WATERS = IsInDSTClimate(inst)
    local prefab = (ROT_WATERS and "hound") or "crocodog"

    --TODO more tile properties?
    if GetTileDepth(tile) >= OCEAN_DEPTH.DEEP then
        if math.random() < 0.7 then
            prefab = (ROT_WATERS and "shark") or "sharx"
        end
    end

    return prefab
end

function Breeder:GetPredatorSpawnPoint(pt)
    local theta = math.random() * 2 * PI
    local radius = PREDATOR_SPAWN_DIST
    local wateroffset =	FindSwimmableOffset(pt, theta, radius, 36, false)

    if wateroffset then
        local pos = pt + wateroffset
        return pos
    end
end

local BREEDER_PREDATOR_TAGS = {"breederpredator"}

function Breeder:SummonPredator(harvester)
    local pt = self.inst:GetPosition()
    
    local inst = self.inst

    local predators = TheSim:FindEntities(pt.x, pt.y, pt.z, 15, BREEDER_PREDATOR_TAGS)

    if #predators > 2 then
        return nil
    end

    local spawn_pt = self:GetPredatorSpawnPoint(pt)

    if spawn_pt then
        local predator = SpawnPrefab(self:GetPredatorPrefab(inst, pt))

        if predator then
            predator.Physics:Teleport(spawn_pt:Get())
            predator:FacePoint(pt)
            predator.components.combat:SuggestTarget(harvester)
            predator:AddTag("attackingbreeder")
        end
    end
end

function Breeder:CheckVolume()
    if self.seeded then
        self:UpdateVolume(1)
        self.inst:PushEvent("vischange")

        local time = math.random(self.cycle_min, self.cycle_max)

        self.BreedTask = self.inst:DoTaskInTime(time, function() self:CheckVolume() end)
    end
end

function Breeder:Seed(item)
    if not item.components.seedable then
        return false
    end
    
    self:Reset()
    
    local prefab = nil
    if item.components.seedable.product and type(item.components.seedable.product) == "function" then
		prefab = item.components.seedable.product(item)
    else
		prefab = item.components.seedable.product or item.prefab
	end

    self.product = prefab

    self.seeded = true

    local time = math.random(self.cycle_min, self.cycle_max)

    self.BreedTask = self.inst:DoTaskInTime(time, function() self:CheckVolume() end)


    if self.onseedfn then
		self.onseedfn(self.inst, item)
    end

    self.inst:PushEvent("vischange")

	item:Remove()    
	
    return true
end

function Breeder:CanBeHarvested(doer)
    return self.volume > 0 and doer.components.inventory ~= nil
end

function Breeder:CollectSceneActions(doer, actions)
    if self:CanBeHarvested(doer) then
        table.insert(actions, ACTIONS.HARVEST)
    end
end

function Breeder:Harvest(harvester)
    if self.onharvestfn then
        self.onharvestfn(self.inst, harvester)
    end

    self.harvestable = false
    self.harvested = true
    if harvester and harvester.components.inventory then
        local product = SpawnPrefab(self.product)
        harvester.components.inventory:GiveItem(product)

        if math.random() <= TUNING.BREEDER_PREDATOR_SPAWN_CHANGE then
            self:SummonPredator(harvester)
        end
    else
        if not harvester:HasTag("breederpredator") then
            harvester.components.lootdropper:SpawnLootPrefab(self.product)
        end
    end

    self:UpdateVolume(-1)

    return true
end

function Breeder:GetDebugString()
    return "seeded: ".. tostring(self.seeded) .." harvestable: ".. tostring(self.harvestable) .." volume: ".. tostring(self.volume)
end

function Breeder:Reset()
    self.harvested = false
    self.seeded = false
    self.harvestable = false
    self.volume = 0   
    self.product = nil 
    self.inst:PushEvent("vischange")
end

function Breeder:StopBreeding()
    self:Reset()
    if self.BreedTask then
        self.BreedTask:Cancel()
        self.BreedTask = nil
    end
end

return Breeder
