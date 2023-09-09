local DoydoySpawner = Class(function(self, inst)
	self.inst = inst
	-- self.inst:StartUpdatingComponent(self)
	self.doydoys = {}
	self.numdoydoys = 0
	self.doydoycap = TUNING.DOYDOY_MAX_POPULATION
	
	self:ScheduleSpawn()
end)

function DoydoySpawner:ScheduleSpawn(dt)
	
	if self.spawntask then self.spawntask:Cancel() end
	
	dt = dt or TUNING.DOYDOY_SPAWN_TIMER + math.random()*TUNING.DOYDOY_SPAWN_VARIANCE
	self.spawntime = GetTime() + dt
	self.spawntask = self.inst:DoTaskInTime(dt, function()
		if TheWorld.state.isday and self:TryToSpawn() then
			self:ScheduleSpawn()
		else
			self:ScheduleSpawn(TUNING.SEG_TIME)
		end
	end)
	-- print("DoydoySpawner:ScheduleSpawn",dt)
end

-- This function is for on-load and does not affect our spawntime
function DoydoySpawner:RequestMate(mommy, daddy)
	-- both partners will trigger this function, but the second call will fail in CanMate
	if mommy and mommy.components.mateable:CanMate() and mommy.sg
	and daddy and daddy.components.mateable:CanMate() and daddy.sg
	and mommy:GetDistSqToInst(daddy) <= TUNING.DOYDOY_MATING_RANGE then
		daddy.components.mateable:SetPartner(mommy, true)
		mommy.components.mateable:SetPartner(daddy, false)
	end
end

local nomatingtags = {
	"baby", "teen", "mating", "doydoynest", "insprungtrap",
}

function DoydoySpawner:TryToSpawn()
	-- print("DoydoySpawner:TryToSpawn", self.numdoydoys, "/", self.doydoycap)

	if self.numdoydoys < 2 or self.numdoydoys >= self.doydoycap then
		return false
	end

	local mommy
	local daddy

	-- find a new mother
	for k, _ in pairs(self.doydoys) do
		if k.components.mateable and k.components.mateable:CanMate() then
			local pt = k:GetPosition()
			local daddys = TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.DOYDOY_MATING_RANGE, {"doydoy"}, nomatingtags) 
			if #daddys > 1 then

				for _, d in pairs(daddys) do
					if d ~= k and not d.components.inventoryitem:IsHeld() then
						daddy = d
						break
					end
				end

				if daddy then
					mommy = k
					break
				end
			end
		end
	end

	if not mommy then
		-- print("DoydoySpawner:TryToSpawn no mommy found")
		return false
	end

	if not mommy.sg then
		-- print("DoydoySpawner:TryToSpawn no mommy.sg")
		return false
	end
	
	-- print("DoydoySpawner:TryToSpawn parents found!")
	daddy.components.mateable:SetPartner(mommy, true)
	mommy.components.mateable:SetPartner(daddy, false)

	-- self:ScheduleSpawn(TUNING.DOYDOY_SPAWN_TIMER + math.random()*TUNING.DOYDOY_SPAWN_VARIANCE)
	
	return true
end


function DoydoySpawner:OnSave()
	return 
	{
		timetospawn = math.max(0, self.spawntime - GetTime()),
		doydoycap = self.doydoycap,
	}
end

function DoydoySpawner:OnLoad(data)
	self.doydoycap = data.doydoycap or TUNING.DOYDOY_MAX_POPULATION
	if self.doydoycap > 0 then
		self:ScheduleSpawn(data.timetospawn)
	end
end

-- function DoydoySpawner:LongUpdate(dt)
	-- if self.timetospawn > 0 then
		-- self.timetospawn = self.timetospawn - dt
	-- end
-- end

-- function DoydoySpawner:OnUpdate( dt )
	-- if self.timetospawn > 0 then
		-- self.timetospawn = self.timetospawn - dt
	-- end
	
	-- if TheWorld.state.isday then
		-- if self.timetospawn <= 0 then
			-- self:TryToSpawn()
		-- end
	-- end
-- end

function DoydoySpawner:StartTracking(inst)

	if self.doydoys[inst] ~= nil then return end
	
	self.doydoys[inst] = true
	self.numdoydoys = self.numdoydoys + 1
end

function DoydoySpawner:StopTracking(inst)

	if self.doydoys[inst] == nil then return end
	
	self.doydoys[inst] = nil
	self.numdoydoys = self.numdoydoys - 1
end

function DoydoySpawner:IsTracking(inst)
	return self.doydoys[inst] ~= nil
end

function DoydoySpawner:GetInnocenceValue()
	if self.numdoydoys <= 2 then
		return TUNING.DOYDOY_INNOCENCE_REALLY_BAD
	elseif self.numdoydoys <= 4 then
		return TUNING.DOYDOY_INNOCENCE_BAD
	elseif self.numdoydoys <= 10 then
		return TUNING.DOYDOY_INNOCENCE_LITTLE_BAD
	else
		return TUNING.DOYDOY_INNOCENCE_OK
	end
end

function DoydoySpawner:GetDebugString()
	return "numdoydoys: "..self.numdoydoys.."\tNext spawn: "..tostring(self.spawntime - GetTime())
end

function DoydoySpawner:SpawnModeNever()
	self.doydoycap = 0
	self.spawntime = nil
	if self.spawntask then self.spawntask:Cancel() end
end

function DoydoySpawner:SpawnModeHeavy()
	self.doydoycap = TUNING.DOYDOY_MAX_POPULATION * 2
	-- self.timetospawn = TUNING.DOYDOY_SPAWN_TIMER / 2
end

function DoydoySpawner:SpawnModeMed()
	self.doydoycap = TUNING.DOYDOY_MAX_POPULATION
	-- self.timetospawn = TUNING.DOYDOY_SPAWN_TIMER
end

function DoydoySpawner:SpawnModeLight()
	self.doydoycap = TUNING.DOYDOY_MAX_POPULATION / 2
	-- self.timetospawn = TUNING.DOYDOY_SPAWN_TIMER * 2
end

return DoydoySpawner
