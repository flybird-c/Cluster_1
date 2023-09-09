local easing = require("easing")

local SPEED_VAR_PERIOD = 5
local SPEED_VAR_PERIOD_VARIANCE = 2

local next = next

local function startfromevent(inst)
	inst.components.blowinwindgustitem:Start()
end
local function stopfromevent(inst)
	inst.components.blowinwindgustitem:Stop()
end

local BlowInWind = Class(function(self, inst)

    self.inst = inst

	self.inst:AddTag("blowinwindgustitem")

	self.maxSpeedMult = 1.5
	self.minSpeedMult = .5
	self.averageSpeed = (TUNING.WILSON_RUN_SPEED + TUNING.WILSON_WALK_SPEED)/2
	self.speed = 0

	self.velocity = Vector3(0,0,0)

	self.speedVarTime = 0
	self.speedVarPeriod = GetRandomWithVariance(SPEED_VAR_PERIOD, SPEED_VAR_PERIOD_VARIANCE)

	self._override_angles = {}
	self.override_angle = nil

	--self.spawnPeriod = 1.0
	--self.timeSinceSpawn = self.spawnPeriod

	self.enabled = false
	
	self.inst:ListenForEvent("hitland", startfromevent)--R08_ROT_TURNOFTIDES
	self.inst:ListenForEvent("on_landed", startfromevent)--R08_ROT_TURNOFTIDES
	self.inst:ListenForEvent("ondropped", startfromevent)
	self.inst:ListenForEvent("onpickup", stopfromevent)
end)

function BlowInWind:OnRemoveEntity()
	self:Stop()
	if self.inst:HasTag("blowinwindgustitem") then
		self.inst:RemoveTag("blowinwindgustitem")
	end
	self.inst:RemoveEventCallback("hitland", startfromevent)
	self.inst:RemoveEventCallback("on_landed", startfromevent)--R08_ROT_TURNOFTIDES
	self.inst:RemoveEventCallback("ondropped", startfromevent)
	self.inst:RemoveEventCallback("onpickup", stopfromevent)
end

function BlowInWind:SetOverrideAngle(adjuster, angle)
    if self._override_angles[adjuster] ~= angle then
	    self._override_angles[adjuster] = angle

        self.override_angle = (next(self._override_angles) ~= nil) and self:CalculateOverrideAngle()
    end
end

--https://www.themathdoctors.org/averaging-angles/
function BlowInWind:CalculateOverrideAngle()
    local Num = 0
	local Den = 0
	for i,v in pairs(self._override_angles) do
		Num = Num + math.sin(math.rad(v))
		Den = Den + math.cos(math.rad(v))
	end
	return math.deg(math.atan2(Num,Den))
end

function BlowInWind:GetOverrideAngle()
	return self.override_angle
end

function BlowInWind:OnEntitySleep()
	self:Stop(true)
end

function BlowInWind:OnEntityWake()
	if self.enabled then --only start updating if it is supossed to be updating
		self:Start(true)
	end
end

function BlowInWind:Start(soft)
	if not soft then
		self.enabled = true
	end
	if (self.inst.components.inventoryitem and self.inst.components.inventoryitem:IsHeld())
	or self.inst:IsAsleep() --never start if asleep
	or not IsInIAClimate(self.inst) then
		return
	end
	self.onwater = self:IsOnWater()
	self.inst:StartUpdatingComponent(self)
end


function BlowInWind:Stop(soft)
	if not soft then
		self.enabled = false
	end
	self.velocity = Vector3(0,0,0)
	self.speed = 0.0
	if self.inst:IsValid() then
		self.inst.Physics:Stop()
	end
	self.inst:StopUpdatingComponent(self)
end

function BlowInWind:SetMaxSpeedMult(spd)
	if spd then self.maxSpeedMult = spd end
end

function BlowInWind:SetMinSpeedMult(spd)
	if spd then self.minSpeedMult = spd end
end

function BlowInWind:SetAverageSpeed(spd)
	if spd then self.averageSpeed = spd end
end

function BlowInWind:GetSpeed()
	return self.speed
end

function  BlowInWind:GetVelocity()
	return self.velocity
end

function BlowInWind:GetDebugString()
	return string.format("Vel: %2.2f/%2.2f, Speed: %3.3f/%3.3f", self.velocity.x, self.velocity.z, self.speed, self.maxSpeedMult)
end

--disabled cause that FX is invisible (even in SW) -M
-- function BlowInWind:SpawnWindTrail(dt)
    -- self.timeSinceSpawn = self.timeSinceSpawn + dt
    -- if self.timeSinceSpawn > self.spawnPeriod and math.random() < 0.8 then 
        -- local wake = SpawnPrefab( "windtrail")
        -- local x, y, z = self.inst.Transform:GetWorldPosition()
        -- wake.Transform:SetPosition( x, y, z )
        -- wake.Transform:SetRotation(self.inst.Transform:GetRotation())
        -- self.timeSinceSpawn = 0
    -- end
-- end

function BlowInWind:CanBlow()
    return (self.inst.components.inventoryitem == nil or (self.inst.components.inventoryitem.is_landed and not self.inst.components.inventoryitem:IsHeld()))
        and self.inst.components.hideandseekhidingspot == nil
end

function BlowInWind:IsOnWater()
    -- For optimization only support floater
    if self.inst.components.floater and self.inst.components.floater:IsFloating() then
        return true
    end
    return false
end

function BlowInWind:OnUpdate(dt)
	
	if not self.inst then
		self:Stop()
		return
	end
	
	if not self:CanBlow() then
        if self.speed ~= 0 then
            self.inst.Physics:SetMotorVel(0,0,0)
            self.speed = 0
        end
		return
	end
	
	if TheWorld.state.hurricane and TheWorld.state.gustspeed > 0 then
		local windspeed = (self.override_angle and (TUNING.SAILSTICK_BONUSSPEEDMULT * TheWorld.state.gustspeed)) or TheWorld.state.gustspeed
		local windangle = (self.override_angle or TheWorld.state.gustangle) * DEGREES
		self.velocity = Vector3(windspeed * math.cos(windangle), 0.0, windspeed * math.sin(windangle))
	elseif self.velocity:Length() > 0 then
		--dumb hack to make sure this item stops
        if self.inst.components.inventoryitem then
			self.inst.components.inventoryitem:ForceLanded(nil, true)
		end
		self.velocity = Vector3(0,0,0)
	else
		return
	end

    -- unbait from traps
    if self.inst.components.bait and self.inst.components.bait.trap then
        self.inst.components.bait.trap:RemoveBait()
    end

    local onwater = self:IsOnWater()

    if not self.onwater then

        if self.velocity:Length() > 1 then self.velocity = self.velocity:GetNormalized() end

        -- Map velocity magnitudes to a useful range of walkspeeds
        local curr_speed = self.averageSpeed
        --[[local player = ThePlayer
        if player and player.components.locomotor then
            curr_speed = (player.components.locomotor:GetRunSpeed() + TUNING.WILSON_WALK_SPEED) / 2
        end]]
        self.speed = Remap(self.velocity:Length(), 0, 1, 0, curr_speed) --maybe only if changing dir??

        -- Do some variation on the speed if velocity is a reasonable amount
        if self.velocity:Length() >= .5 then
            self.speedVarTime = self.speedVarTime + dt
            if self.speedVarTime > SPEED_VAR_PERIOD then 
                self.speedVarTime = 0
                self.speedVarPeriod = GetRandomWithVariance(SPEED_VAR_PERIOD, SPEED_VAR_PERIOD_VARIANCE)
            end
            local speedvar = math.sin(2*PI*(self.speedVarTime / self.speedVarPeriod))
            local mult = Remap(speedvar, -1, 1, self.minSpeedMult, self.maxSpeedMult)
            self.speed = self.speed * mult
        end
        
        -- Walk!
        self.inst.Transform:SetRotation( math.atan2(self.velocity.z, self.velocity.x)/DEGREES )

        self.inst.Physics:SetMotorVel(self.speed,0,0)

        -- if self.speed > 3.0 then
            -- self:SpawnWindTrail(dt)
        -- end

        if onwater then
            self.onwater = true
            if self.inst.components.burnable and self.inst.components.burnable:IsBurning() then
                self.inst.components.burnable:Extinguish() --Do this before anything that required the inventory item component, it gets removed when something is lit on fire and re-added when it's extinguished 
            end

            if self.inst.components.inventoryitem then
                --setting poll_for_landing would delay it by a tick
                self.inst.components.inventoryitem:ForceLanded(true, true)
            end

            if self.inst.components.floater ~= nil then
                local vx, vy, vz = self.inst.Physics:GetMotorVel()
                self.inst.Physics:SetMotorVel(0.5 * vx, 0, 0)
                self.inst:DoTaskInTime(1.0, function(inst)
                    self.inst.Physics:SetMotorVel(0, 0, 0)
                    if self.inst.components.inventoryitem then 
                        self.inst.components.inventoryitem:ForceLanded(true)
                    end
                end)
                self.inst:StopUpdatingComponent(self)
            end
        elseif self.inst.components.inventoryitem then
            self.inst.components.inventoryitem:UpdateWater()
        end
    end
    self.onwater = onwater
end

return BlowInWind
