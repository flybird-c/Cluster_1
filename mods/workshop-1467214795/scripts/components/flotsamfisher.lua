local FlotsamFisher = Class(function(self, inst)
    self.inst = inst
    self.lootleft = 3
    self.flotsam_loot = {"boards", "rope", "log", "cutgrass"}
    self.decay_interval = TUNING.TOTAL_DAY_TIME

	self.inst:AddTag("flotsamfisher")
end)

function FlotsamFisher:OnRemoveFromEntity()
    self.inst:RemoveTag("flotsamfisher")
end

-- function FlotsamFisher:TestWeights(numtest)
-- 	numtest = numtest or 100

-- 	local loots = {}

-- 	for i = 0, numtest do
-- 		local loot = self:GetLootType()
-- 		if not loots[loot] then
-- 			loots[loot] = 1
-- 		else
-- 			loots[loot] = loots[loot] + 1
-- 		end
-- 	end

-- 	print("----------")
-- 	dumptable(loots)
-- 	print("----------")

-- end

function FlotsamFisher:GetLootType()
	local total_weight = 0

	for k,v in pairs(self.flotsam_loot) do
		total_weight = total_weight + v
	end

	local rand_weight = math.random() * total_weight

	-- print("Total Weight:", total_weight)
	-- print("Random Weight:", rand_weight)

	for k,v in pairs(self.flotsam_loot) do
		rand_weight = rand_weight - v
		if rand_weight <= 0 then
			return k
		end
	end 
end

function FlotsamFisher:Initialize(num)
	self.lootleft = num
    if self.onfishfn then
        self.onfishfn(self.inst, nil)
    end
end

function FlotsamFisher:DeltaLoot(delta)
	self.lootleft = self.lootleft + delta

	if self.lootleft <= 0 then
		self.inst:Remove()
	end
end

	--local function sink(fish, fisher)
	-- 	if not (fish.components.inventoryitem and fish.components.inventoryitem:IsHeld()) then
	-- 		if not fish:IsOnValidGround() then
	-- 			local fx = SpawnPrefab("splash_ocean")
	-- 			local pos = fish:GetPosition()
	-- 			fx.Transform:SetPosition(pos.x, pos.y, pos.z)
	-- 			if fish:HasTag("irreplaceable") then
	-- 				fish.Transform:SetPosition(fisher.Transform:GetWorldPosition())
	-- 			else
	-- 				fish:Remove()
	-- 			end
	-- 		end
	-- 	end
	--end

local function RemoveInventoryPhysics(obj)
    local origmask = obj.Physics:GetCollisionMask()
    obj.Physics:ClearCollisionMask()
    obj.Physics:CollidesWith(COLLISION.GROUND)
    obj.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
	return origmask
end

local function RestoreInventoryPhysics(obj, origmask)
	obj.Physics:ClearCollisionMask()
	obj.Physics:SetCollisionMask(origmask)
end

function FlotsamFisher:Fish(fisher)
	--Launch a "fish" towards the player.
	local fish = SpawnPrefab(self:GetLootType())

	local origmask = RemoveInventoryPhysics(fish)
	fish:DoTaskInTime(.6, function(fish) RestoreInventoryPhysics(fish, origmask) end)

	--direction from flotsam to player
	local pos = self.inst:GetPosition()
	local fisher_pos = fisher:GetPosition()

	local direction = fisher_pos - pos

	fish.Transform:SetPosition(pos:Get())

	local angle = math.atan2(direction.z, direction.x) + (math.random()*10-5)*DEGREES

	local sp
	if fisher:IsOnOcean(true) then
		--scaled based on distance due to platforms and boats on rot water -Half
		sp = math.sqrt(fisher:GetDistanceSqToInst(self.inst)) + math.random(1, 2)
	else
		sp = math.random(6, 7)
	end

	fish.Physics:SetVel(sp*math.cos(angle), 30, sp*math.sin(angle))

	self:DeltaLoot(-1)

	-- no longer needed -Half
	-- fish:DoTaskInTime(1.546, sink, fisher)

	if self.onfishfn then
		self.onfishfn(self.inst, fisher)
	end

end

function FlotsamFisher:OnSave()
    return {
        lootleft = self.lootleft
    }
end

function FlotsamFisher:OnLoad(data)
    self:Initialize(data.lootleft)
end

return FlotsamFisher