local TileTracker = Class(function(self, inst)
	self.inst = inst
	self.tile = nil
	self.tileinfo = nil
    self.ontilechangefn = nil

	if not self.inst:IsAsleep() then
		self.inst:StartUpdatingComponent(self)
	end

end)

function TileTracker:OnEntitySleep()
	self.inst:StopUpdatingComponent(self)
end

function TileTracker:OnEntityWake()
	self.inst:StartUpdatingComponent(self)
end

function TileTracker:OnUpdate()
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local tile = TheWorld.Map:GetVisualTileAtPoint(x, y, z)
    
    if tile ~= nil and tile ~= self.tile then
		self.tile = tile
        self.tileinfo = GetTileInfo(tile)
		if self.ontilechangefn then
			self.ontilechangefn(self.inst, tile, self.tileinfo)
		end
    end
end

function TileTracker:ShouldTransition(x, z)
	return self.tile ~= TheWorld.Map:GetVisualTileAtPoint(x, y, z)
end

function TileTracker:SetOnTileChangeFn(fn)
    self.ontilechangefn = fn
end
-- Note: water tracking functionality stripped from tiletracker as dst's amphibius creature component does the same thing but with better integration (note dst's amphibius creature component is a stripped down copy of ds's tiletracker)
function TileTracker:SetOnWaterChangeFn(fn)
    assert(false, "Use AmphibiousCreature for water tracking")
-- self.onwaterchangefn = fn
end

function TileTracker:GetDebugString()
	return "tile: " .. tostring(self.tile)
end

return TileTracker
