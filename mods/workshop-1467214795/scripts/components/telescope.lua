local function oncanuse(self)
    if self.canuse then
        self.inst:AddTag("telescope")
    else
        self.inst:RemoveTag("telescope")
    end
end

local Telescope = Class(function(self, inst)
    self.inst = inst
    self.range = TUNING.TELESCOPE_RANGE
    self.onusefn = nil
    self.canuse = true
end,
nil,
{
    canuse = oncanuse,
})

function Telescope:OnRemoveFromEntity()
    self.inst:RemoveTag("telescope")
end

function Telescope:SetOnUseFn(fn)
    self.onusefn = fn
end

function Telescope:SetRange(range)
    self.range = range
end

function Telescope:Peer(doer, pos)
	if doer and doer.player_classified then
		local x, y, z = doer.Transform:GetWorldPosition()
		local angle = - doer:GetAngleToPoint(pos.x, pos.y, pos.z) - (TUNING.TELESCOPE_ARC/2)
		local arc = TUNING.TELESCOPE_ARC
		local range = self.range
		local arclength = 0.5 * range * arc * DEGREES

		if not TheWorld.state.isday then
			range = range / 2
		end

		local i = 1
		while i < range do
			for j = 0, arclength, 4 do
				local a = angle + (j / (0.5 * range * DEGREES))
				--print(string.format("%4.2f = (%4.2f / %4.2f)\n", a, j, arclength))
				local c = math.cos(a * DEGREES)
				local s = math.sin(a * DEGREES)
				local x0, z0 = x + i * c, z + i * s
				doer.player_classified.MapExplorer:RevealArea(x0, 0, z0)
				-- local cx, cy, cz = TheWorld.Map:GetTileCenterPoint(x0, 0, z0)
				-- if cx and cy and cz then
					-- doer.player_classified.MapExplorer:RevealArea(cx, cy, cz)
					-- minimap:ShowArea(cx, cy, cz, 30)
					-- map:VisitTile(map:GetTileCoordsAtPoint(cx, cy, cz))
				-- end
			end
			i = i + 8
		end

		--Toggle map
		if doer.player_classified.peertelescope then
			doer.player_classified.peertelescope:push()
		end
		-- doer:PushEvent("peertelescope")

		if self.onusefn ~= nil then
			self.onusefn(self.inst, doer, pos)
		end

		return true
	end
end

return Telescope
