
local VolcanoWave = Class(function(self, inst)
	assert(inst.WaveComponent ~= nil, "WaveComponent is missing from the world")
	self.inst = inst
	self.map = self.inst.Map
	self.waves = inst.WaveComponent

	self.map:AlwaysDrawWaves(true)
	self.map:SetUndergroundFadeHeight(0)

	local map_x_size, map_y_size = self.map:GetSize()
    self.waves:SetWaveParams(13.5, 2.5, -1)
    self.waves:Init(map_x_size, map_y_size)
    self.waves:SetWaveSize(80, 3.5)
    self.waves:SetWaveMotion(3, 0.5, 0.25)

	self.inst:StartUpdatingComponent(self)
end)

function VolcanoWave:OnUpdate()
	if self.waves and ThePlayer then
		local _map = TheWorld.Map
		local x, y, z = ThePlayer.Transform:GetWorldPosition()

        local disttolava = _map:GetClosestTileDist(x, y, z, WORLD_TILES.VOLCANO_LAVA, 20)
        local disttocloud = _map:GetClosestTileDist(x, y, z, WORLD_TILES.IMPASSABLE, 20)

        if disttocloud < disttolava then
			self.waves:SetWaveTexture( resolvefilepath("images/volcano_waves/volcano_cloud.tex") )
		else
			self.waves:SetWaveTexture( resolvefilepath("images/volcano_waves/lava_active.tex") )
		end
	end
end

return VolcanoWave
