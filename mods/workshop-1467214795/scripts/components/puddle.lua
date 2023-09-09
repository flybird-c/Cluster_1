local PUDDLE_MAX_SIZE = TUNING.MAX_PUDDLE_LEVEL

local function IsValidFloodPos(x, y)
	return math.abs(x) + math.abs(y) <= PUDDLE_MAX_SIZE
end

local puddle_spots = {}
for x = -PUDDLE_MAX_SIZE, PUDDLE_MAX_SIZE do
	for y = -PUDDLE_MAX_SIZE, PUDDLE_MAX_SIZE do
		if IsValidFloodPos(x, y) then
			puddle_spots[#puddle_spots + 1] = x
			puddle_spots[#puddle_spots + 1] = y
		end
	end
end
local puddle_count = #puddle_spots

local Puddle = Class(function(self, inst)
	self.inst = inst

	--self.flood_x = nil
	--self.flood_y = nil

	--self.asleep = nil

    self.puddle_depth = 0

    self.max_size = PUDDLE_MAX_SIZE

    --self.dead = nil

    local size = PUDDLE_MAX_SIZE * 2 + 1
    self.depth_grid = DataGrid(size, size)
    self.dist_grid = DataGrid(size, size)

    self.depth_grid:SetDataAtPoint(0, 0, 0)
    self.dist_grid:SetDataAtPoint(0, 0, 0)
end)

function Puddle:GetDepthAtPoint(x, y)
	return self.depth_grid:GetDataAtPoint(x, y) or 0
end

function Puddle:SetDepthAtPoint(x, y, depth)
	self.depth_grid:SetDataAtPoint(x, y, depth)
end

function Puddle:GetDistanceAtPoint(x, y)
	return self.dist_grid:GetDataAtPoint(x, y) or PUDDLE_MAX_SIZE
end

function Puddle:SetDistanceAtPoint(x, y, distance)
	self.dist_grid:SetDataAtPoint(x, y, distance)
end

function Puddle:OnRemoveFromEntity()
	for i = 1, puddle_count, 2 do
		local x, y = puddle_spots[i], puddle_spots[i+1]

		self:DoDepthDelta(x, y, -self:GetDepthAtPoint(x, y))
	end
end
Puddle.OnRemoveEntity = Puddle.OnRemoveFromEntity

function Puddle:OnEntitySleep()
	self.asleep = true
end

function Puddle:OnEntityWake()
	self.asleep = false
	if self.queued_inactive_update then
		self:QueueUpdate()
	end
end

function Puddle:SetPuddleCoordinates(x, y)
	self.flood_x, self.flood_y = x, y
end

function Puddle:GetPuddleCoordinates()
	return self.flood_x, self.flood_y
end

function Puddle:SetPuddleDepth(puddle_depth)
	puddle_depth = math.min(puddle_depth, PUDDLE_MAX_SIZE)

	if puddle_depth == self.puddle_depth then return end

	self.puddle_depth = puddle_depth
	self:QueueUpdate()
end

function Puddle:QueueUpdate()
	if self.queued_active_update then return end

	if self.asleep then
		if not self.queued_inactive_update then
			self.queued_inactive_update = true
			TheWorld.components.monsoonflooding:AddInactivePuddleUpdate(self)
		end
	else
		TheWorld.components.monsoonflooding:AddActivePuddleUpdate(self)
		self.queued_active_update = true
	end
end

function Puddle:OnTerraform(...)
	--TODO
	self:QueueUpdate()
end

function Puddle:OnFloodBlockingUpdated(x, y, blocked)
	local o_x, o_y = x - self.flood_x,  y - self.flood_y
	if not IsValidFloodPos(o_x, o_y) then return end

	if blocked then
		self:DoDepthDelta(o_x, o_y, -self:GetDepthAtPoint(o_x, o_y))
		if o_x == 0 and o_y == 0 then
			self.dead = true
		end
		return
	end

	self:QueueUpdate()
end

function Puddle:DoDepthDelta(x, y, diff)
	if diff == 0 then return end
	self.unchanged = false

	local old_depth = self:GetDepthAtPoint(x, y)
	local new_depth = Clamp(old_depth + diff, 0, PUDDLE_MAX_SIZE)
	self:SetDepthAtPoint(x, y, new_depth)

	if old_depth == 0 and new_depth > 0 then
		TheWorld.components.flooding:SpawnFloodAtPoint(self.flood_x + x, self.flood_y + y)
	elseif old_depth > 0 and new_depth == 0 then
		self:SetDepthAtPoint(x, y, nil)
		self:SetDistanceAtPoint(x, y, nil)
		TheWorld.components.flooding:DespawnFloodAtPoint(self.flood_x + x, self.flood_y + y)
	end
end

function Puddle:EqualizeDepth(x1, y1, x2, y2)
	if TheWorld.components.flooding:IsFloodBlocked(self.flood_x + x2, self.flood_y + y2, true) then return end

	local index1 = self.dist_grid:GetIndex(x1, y1)
	local index2 = self.dist_grid:GetIndex(x2, y2)

	local dist1 = self.dist_grid:GetDataAtIndex(index1) or PUDDLE_MAX_SIZE
	local dist2 = self.dist_grid:GetDataAtIndex(index2) or PUDDLE_MAX_SIZE

    if dist1 + 1 < dist2 then
        dist2 = math.min(dist1 + 1, PUDDLE_MAX_SIZE)
        self.dist_grid:SetDataAtIndex(index2, dist2)
    elseif dist2 + 1 < dist1 then
        dist1 = math.min(dist2 + 1, PUDDLE_MAX_SIZE)
        self.dist_grid:SetDataAtIndex(index1, dist1)
    end

	local depth1 = self.depth_grid:GetDataAtIndex(index1) or 0
	local depth2 = self.depth_grid:GetDataAtIndex(index2) or 0

    local equalize = true
    if dist1 > self.puddle_depth then
        self:DoDepthDelta(x1, y1, -depth1)
        equalize = false
    end

    if dist2 > self.puddle_depth then
        self:DoDepthDelta(x2, y2, -depth2)
        equalize = false
    end

    if equalize then
        local diff = math.abs(depth1 - depth2)
        local change = bit.rshift(diff, 1)
        if change ~= 0 then
            if depth1 > depth2 then
                self:DoDepthDelta(x1, y1, -change)
                self:DoDepthDelta(x2, y2, change)
            else
                self:DoDepthDelta(x1, y1, change)
                self:DoDepthDelta(x2, y2, -change)
            end
        end
    end
end

function Puddle:DoDepthUpdate(x, y)
	if TheWorld.components.flooding:IsFloodBlocked(self.flood_x + x, self.flood_y + y, true) then return end

	if IsValidFloodPos(x-1, y) then
		self:EqualizeDepth(x, y, x-1, y)
	end
	if IsValidFloodPos(x+1, y) then
		self:EqualizeDepth(x, y, x+1, y)
	end
	if IsValidFloodPos(x, y-1) then
		self:EqualizeDepth(x, y, x, y-1)
	end
	if IsValidFloodPos(x, y+1) then
		self:EqualizeDepth(x, y, x, y+1)
	end
end

function Puddle:DoUpdate(is_inactive_update)
	if is_inactive_update then
		self.queued_inactive_update = nil
	else
		self.queued_active_update = nil
	end

	self.unchanged = true

	for i = 1, puddle_count, 2 do
		local x, y = puddle_spots[i], puddle_spots[i+1]

		local depth = self:GetDepthAtPoint(x, y)

		if x == 0 and y == 0 and not self.dead then
			local diff = self.puddle_depth - depth

			self:DoDepthDelta(x, y, diff)

			depth = self:GetDepthAtPoint(x, y)
		end

		if depth > 0 then
			self:DoDepthUpdate(x, y)
		end
	end

	if not self.unchanged then
		self:QueueUpdate()
	end

	self.unchanged = nil
end

function Puddle:OnSave()
	local data = {}

	data.flood_x = self.flood_x
	data.flood_y = self.flood_y

	data.puddle_depth = self.puddle_depth

	data.depth_grid = self.depth_grid:Save()
	data.dist_grid = self.dist_grid:Save()

	data.updating = self.queued_inactive_update or self.queued_active_update

	return data
end

function Puddle:OnLoad(data)
	if data == nil then return end

	self.flood_x = data.flood_x
	self.flood_y = data.flood_y

	self.puddle_depth = data.puddle_depth

	self.depth_grid:Load(data.depth_grid)
	self.dist_grid:Load(data.dist_grid)

	if data.updating then
		self:QueueUpdate()
	end
end

return Puddle