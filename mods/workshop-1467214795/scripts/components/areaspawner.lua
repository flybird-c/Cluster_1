
local function DoSpawn(inst)
    local spawner = inst.components.areaspawner
    if spawner then
        spawner.target_time = nil
        spawner:TrySpawn()
        spawner:Start()
    end
end

local AreaSpawner = Class(function(self, inst)
    self.inst = inst
    self.basetime = 40
    self.randtime = 60
    self.prefabfn = nil
    self.prefab = nil

    self.range = nil
    self.density = nil
    self.spacing = nil

    self.onspawn = nil
    self.spawntest = nil

    self.spawnoffscreen = false
    self.spawnphase = nil
    self.spawntiles = nil
end)

function AreaSpawner:SetPrefab(prefab)
    self.prefab = prefab
end

function AreaSpawner:SetPrefabFn(fn)
    self.prefabfn = fn
end

function AreaSpawner:SetValidTileType(tiles)
    if type(tiles) == "table" then
        self.spawntiles = table.invert(tiles)
    else
        self.spawntiles = table.invert({tiles})
    end
end

function AreaSpawner:SetRandomTimes(basetime, variance, no_reset)
    self.basetime = basetime
    self.randtime = variance
    if self.task and not no_reset then
        self:Stop()
        self:Start()
    end
end

function AreaSpawner:SetDensityInRange(range, density)
    self.range = range
    self.density = density
end

function AreaSpawner:SetMinimumSpacing(spacing)
    self.spacing = spacing
end

function AreaSpawner:SetOnlySpawnOffscreen(offscreen)
    self.spawnoffscreen = offscreen
end

function AreaSpawner:IsSpawnOffscreen()
    return self.spawnoffscreen
end

function AreaSpawner:SetSpawnPhase(phase)
    self.spawnphase = phase
end

function AreaSpawner:SetOnSpawnFn(fn)
    self.onspawn = fn
end

function AreaSpawner:SetSpawnTestFn(fn)
    self.spawntest = fn
end

function AreaSpawner:TrySpawn(prefab)
    prefab = prefab or (self.prefabfn and self.prefabfn()) or self.prefab
    if not self.inst:IsValid() or not prefab then
        return
    end

    local x, y, z = self.inst.Transform:GetWorldPosition()

    if self.spawnoffscreen and not self.inst:IsAsleep() then
        return false
    end

    if self.spawnphase and TheWorld.state.phase ~= self.spawnphase then
        return false
    end

    if (self.range or self.spacing) then
        local ents = TheSim:FindEntities(x, y, z, self.range or self.spacing)
        local count = 0
        for k,v in pairs(ents) do
            if v.prefab == prefab then
                if self.spacing and v:GetDistanceSqToInst(self.inst) < self.spacing*self.spacing then
                    return false
                end
                count = count + 1
            end
        end
        if self.density and count >= self.density then
            return false
        end
    end

    x, y, z = x + self.range * (2.0 * math.random() - 1.0), y, z + self.range * (2.0 * math.random() - 1.0)
    local ground = self.inst:GetCurrentTileType(x, y, z)--map:GetTile(map:GetTileCoordsAtPoint(x, y, z))

    if self.spawntiles and not self.spawntiles[ground] then
        return false
    end

    if self.spawntest and not self.spawntest(self.inst, ground, x, y, z) then
        return false
    end

    local inst = SpawnPrefab(prefab)
    -- transform first incase the callback wants to change it
    inst.Transform:SetPosition(x, y, z)
    if self.onspawn then
        self.onspawn(self.inst, inst, ground)
    end
    return true
end

function AreaSpawner:Start()
    local t = self.basetime + math.random() * self.randtime
    self.target_time = GetTime() + t
    self.task = self.inst:DoTaskInTime(t, DoSpawn)
end


function AreaSpawner:Stop()
    self.target_time = nil
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

function AreaSpawner:OnUpdate(dt)
    self:DebugRender()
end

function AreaSpawner:LongUpdate(dt)
    if self.target_time then
        if self.task then
            self.task:Cancel()
            self.task = nil
        end
        local time_to_wait = self.target_time - GetTime() - dt

        if time_to_wait <= 0 then
            DoSpawn(self.inst)
        else
            self.target_time = GetTime() + time_to_wait
            self.task = self.inst:DoTaskInTime(time_to_wait, DoSpawn)
        end
    end
end

function AreaSpawner:OnSave()
    return
    {
        basetime = self.basetime,
        randtime = self.randtime,
        range = self.range,
        density = self.density,
        spacing = self.spacing,
        spawnphase = self.spawnphase
    }
end

function AreaSpawner:OnLoad(data)
    if data then
        self.basetime = data.basetime or self.basetime
        self.randtime = data.randtime or self.randtime
        self.range = data.range or self.range
        self.density = data.density or self.density
        self.spacing = data.spacing or self.spacing
        self.spawnphase = data.spawnphase or self.spawnphase
    end
end

function AreaSpawner:DebugRender()
    if TheSim:GetDebugRenderEnabled() then
        if self.inst.draw then
            self.inst.draw:Flush()
            self.inst.draw:SetRenderLoop(true)
            self.inst.draw:SetZ(0.15)

            local dim = 2.0 * self.range
            local x, y, z = self.inst.Transform:GetWorldPosition()
            self.inst.draw:Box(x - self.range, z - self.range, dim, dim, 0, 1, 0, 1)
        else
            --TheSim:SetDebugRenderEnabled(true)
            self.inst.draw = self.inst.entity:AddDebugRender()
        end
    end
end

return AreaSpawner
