-- Fog is handled client-side

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local MAPWRAPPER_WARN_RANGE = TUNING.MAPWRAPPER_WARN_RANGE
local MAPWRAPPER_LOSECONTROL_RANGE = TUNING.MAPWRAPPER_LOSECONTROL_RANGE
local MAPWRAPPER_GAINCONTROL_RANGE = TUNING.MAPWRAPPER_GAINCONTROL_RANGE

local _map = TheWorld.Map

local STATES = {
    WAIT = 0,
    WARN = 1,
    MOVEOFF = 2,
    BLIND = 3,
    MOVEBACK = 4,
    RETURN = 5,
}

local DIRECTIONS = {
    left = 0,
    right = 1,
    down = 2,
    up = 3,
}

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

self.inst = inst
self._state = STATES.WAIT
local _warpdir = nil

--------------------------------------------------------------------------
--[[ Functions ]]
--------------------------------------------------------------------------

function self:GetDistanceFromEdge(x, y, z)
	-- Remember that (0/0) is in the middle
	local w, h = _map:GetSize()
	local halfw, halfh = 0.5 * w * TILE_SCALE, 0.5 * h * TILE_SCALE
	local distx = math.min(x + halfw, halfw - x)
	local distz = math.min(z + halfh, halfh - z)
	assert(distx >= 0)
	assert(distz >= 0)
	local dist = math.min(distx, distz)
	return dist
end

function self:OnUpdate()
	local w, h = _map:GetSize()
	local x, y, z = self.inst.Transform:GetLocalPosition()
	local tx, ty = _map:GetTileCoordsAtPoint(x, y, z)

	local is_inrange = function(range)
		return (tx < range) or (w - tx < range) or (ty < range) or (h - ty < range)
	end

	if self._state == STATES.WAIT then
		if is_inrange(MAPWRAPPER_WARN_RANGE) then
			self._state = STATES.WARN
		end

	elseif self._state == STATES.WARN or self._state == STATES.RETURN then
		if not is_inrange(MAPWRAPPER_WARN_RANGE) then
			self._state = STATES.WAIT
		elseif self.inst:IsOnOcean() and is_inrange(MAPWRAPPER_LOSECONTROL_RANGE) then
			self.inst.components.health:SetInvincible(true)
            if self.inst.components.wereness and self.inst:HasTag("wereplayer") then
                self.inst.components.wereness:StopDraining()
            end
			if TUNING.DO_SEA_DAMAGE_TO_BOAT and (self.inst.components.sailor and self.inst.components.sailor.boat and self.inst.components.sailor.boat.components.boathealth) then
				self.inst.components.sailor.boat.components.boathealth:SetInvincible(true)
			end

			local angle = 0 
			local xDist = math.min(tx, math.abs(tx - w))
			local zDist = math.min(ty, math.abs(ty - h))
			
			if xDist < zDist then --horizontal (x)
				if x < 0 then 
					angle = 180
					_warpdir = DIRECTIONS.left
				else 
					angle = 0 
					_warpdir = DIRECTIONS.right
				end 
			else --vertical (z)
				if z < 0 then 
					angle = 90 
					_warpdir = DIRECTIONS.down
				else 
					angle = -90
					_warpdir = DIRECTIONS.up
				end 
			end 
			
			self.inst.components.locomotor:Stop()
			self.inst.components.playercontroller:Enable(false)
			self.inst.Transform:SetRotation(angle)
			self.inst.Physics:SetMotorVelOverride(TUNING.WILSON_RUN_SPEED, 0, 0)
			self._state = STATES.MOVEOFF
		end

	elseif self._state == STATES.MOVEOFF then
		self.inst.Physics:SetMotorVelOverride(TUNING.WILSON_RUN_SPEED, 0, 0)
		if is_inrange(TUNING.MAPWRAPPER_TELEPORT_RANGE) then
			local width = (w - 2) * TILE_SCALE
			local height = (h - 2) * TILE_SCALE
			local right, top = width/2.0, height/2.0
			local left, bottom = -right, -top

			local dx, dy, dz = x, y, z  

			if _warpdir == DIRECTIONS.left then 
				dx = right 
				dz = math.min(dz, top - (MAPWRAPPER_GAINCONTROL_RANGE * 4 + 4))
				dz = math.max(dz, bottom + (MAPWRAPPER_GAINCONTROL_RANGE * 4 + 4))
			elseif _warpdir == DIRECTIONS.right then 
				dx = left 
				dz = math.min(dz, top - (MAPWRAPPER_GAINCONTROL_RANGE * 4 + 4))
				dz = math.max(dz, bottom + (MAPWRAPPER_GAINCONTROL_RANGE * 4+ 4))
			elseif _warpdir == DIRECTIONS.up then 
				dz = bottom
				dx = math.min(dx, right - (MAPWRAPPER_GAINCONTROL_RANGE *4 + 4))
				dx = math.max(dx, left + (MAPWRAPPER_GAINCONTROL_RANGE *4 + 4))
			elseif _warpdir == DIRECTIONS.down then 
				dz = top
				dx = math.min(dx, right - (MAPWRAPPER_GAINCONTROL_RANGE *4 + 4))
				dx = math.max(dx, left + (MAPWRAPPER_GAINCONTROL_RANGE *4 + 4))
			end 

            if self.inst.Physics then
				self.inst.Physics:Teleport(dx, dy, dz)
			elseif self.inst.Transform then
				self.inst.Transform:SetPosition(dx, dy, dz)
			else
				print("Mapwrapping FAILED: entity has neither Physics nor Transform")
			end

			self._state = STATES.BLIND
			self.inst:DoTaskInTime(3, function()
				self._state = STATES.MOVEBACK
				self.inst:Show()
			end)
		end
	
	elseif self._state == STATES.BLIND then
		self.inst.components.locomotor:Stop()
		self.inst:Hide()
		
	elseif self._state == STATES.MOVEBACK then
		self.inst.Physics:SetMotorVelOverride(TUNING.WILSON_RUN_SPEED, 0, 0)

		if not is_inrange(TUNING.MAPWRAPPER_GAINCONTROL_RANGE) then
			if self.inst.components.sanity and not self.inst.components.sanity.only_magic_dapperness then
				self.inst.components.sanity:DoDelta(-TUNING.SANITY_MED)
			end

			self.inst.Physics:Stop()
			self.inst.components.locomotor:Stop()
			self.inst.components.health:SetInvincible(false)
            if self.inst.components.wereness and self.inst:HasTag("wereplayer") then
                self.inst.components.wereness:StartDraining()
            end
			if TUNING.DO_SEA_DAMAGE_TO_BOAT and (self.inst.components.sailor and self.inst.components.sailor.boat and self.inst.components.sailor.boat.components.boathealth) then
				self.inst.components.sailor.boat.components.boathealth:SetInvincible(false)
			end
			self.inst.components.playercontroller:Enable(true)
			self._state = STATES.RETURN
		end
	end
end

self.inst:StartUpdatingComponent(self)
	
end, nil, {
	_state = function(self, state)
        self.inst.replica.mapwrapper._state:set(state)
	end
})
