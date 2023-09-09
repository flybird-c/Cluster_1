
--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

require("constants")
local easing = require("easing")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local NOWAVE_TAGS = {"nowaves"}
local LANEWAVE_TAGS = {"lanewave"}

local ROW_RADIUS = 24
local COL_RADIUS = 8

local MAPWRAPPER_WARN_RANGE = TUNING.MAPWRAPPER_WARN_RANGE
local WAVE_LANE_SPACING = TUNING.WAVE_LANE_SPACING
local MAX_WAVES = TUNING.MAX_WAVES
local ROGUEWAVE_SPEED_MULTIPLIER = TUNING.ROGUEWAVE_SPEED_MULTIPLIER

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function set_ocean_angle(inst)
    inst.currentAngle = 45 * math.random(0, 7) + 22.5
end

local function SpawnWaveRipple(inst, x, z, angle, speed)
    local wave = SpawnPrefab( "wave_ripple" )
    wave.Transform:SetPosition( x, 0, z )

    --we just need an angle...
    wave.Transform:SetRotation(angle)

    --motor vel is relative to the local angle, since we're now facing the way we want to go we just go forward
    wave.Physics:SetMotorVel(speed, 0, 0)

    wave.idle_time = inst.ripple_idle_time

    return wave
end

local function SpawnRogueWave(inst, x, z, angle, speed)
    local wave = SpawnPrefab( "wave_rogue" )
    wave.Transform:SetPosition( x, 0, z )
    wave.Transform:SetRotation(angle)

    --motor vel is relative to the local angle, since we're now facing the way we want to go we just go forward
    wave.Physics:SetMotorVel(speed, 0, 0)

    wave.idle_time = inst.ripple_idle_time

    return wave
end

local function updateSeasonMod(self)
    if self.worldstate.issummer then
        self.seasonmult = 0.5 * math.sin(PI * self.worldstate.seasonprogress + (PI/2.0)) + 0.5
    else
        self.seasonmult = 1
    end
end

local function onisnight(self, isnight)
    if isnight and not self.worldstate.hurricane then
        self.inst:DoTaskInTime(0.25 * math.random() * TUNING.SEG_TIME, function()
            self.currentSpeed = 0.0
            self.nightreset = true
            self.inst:DoTaskInTime(math.random(10, 15), function()
                self.currentSpeed = 1.0
                self.nightreset = false
                set_ocean_angle(self)
            end)
        end)
    end
end

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

local WaveLaneManager = Class(function(self, inst)
    self.inst = inst

    self.currentAngle = 0
    self.currentSpeed = 1

    self.seasonmult = 1

    self.ripple_speed = 1.5
    self.ripple_per_sec = 10
    self.ripple_idle_time = 5
    self.ripple_spawn_rate = 0

    self.ripple_per_sec_mod = 1.0
    self.ripple_per_sec_mult = 1.5

    self.ripplelanes = {
        [WORLD_TILES.OCEAN_MEDIUM] = true,
        [WORLD_TILES.OCEAN_DEEP] = true,
    }

    self.map = TheWorld.Map
    self.worldstate = TheWorld.state

    set_ocean_angle(self)
    updateSeasonMod(self)
    self:WatchWorldState("isnight", onisnight)
    self:WatchWorldState("cycles", updateSeasonMod)

    self.inst:StartUpdatingComponent(self)
end)

--------------------------------------------------------------------------
--[[ Functions ]]
--------------------------------------------------------------------------

function WaveLaneManager:CanSpawnRippleAtCoords(x, z)
    -- Check if too close to the world edge
    local w, h = self.map:GetSize()
    w = (w * .5 - MAPWRAPPER_WARN_RANGE) * TILE_SCALE
    h = (h * .5 - MAPWRAPPER_WARN_RANGE) * TILE_SCALE
    if x < -w or x > w or z < -h or z > h then
        return false
    end

    -- Check if valid lane
    local tile = self.map:GetTileAtPoint( x, 0, z )
    if not self.ripplelanes[tile] then
        return false
    end

    -- Check if blocked
    local ents = TheSim:FindEntities(x, 0, z, 10, NOWAVE_TAGS)
    if ents ~= nil and #ents > 0 or self.map:GetNearbyPlatformAtPoint(x, 0, z, 2) ~= nil then
        return false
    end

    -- Check if there are no nearby waves already
    local ents = TheSim:FindEntities(x, 0, z, 4, LANEWAVE_TAGS)
    if ents ~= nil and #ents > 0 then
        return false
    end

    return true
end

function WaveLaneManager:SpawnLaneWaveRipple(player, x, y, z)
    local cx, cy, cz = self:GetCurrentVec3()
    local m1 = math.floor(math.random(-ROW_RADIUS, ROW_RADIUS))
    local m2 = WAVE_LANE_SPACING * math.floor(math.random(-COL_RADIUS, COL_RADIUS))
    local tx, tz = x + (2 * m1 * cx + m2 * cz), z + (2 * m1 * cz + m2 * -cx)
    if self:CanSpawnRippleAtCoords(tx, tz) then
        -- Spawn lanewave
        local wave
        if (self.worldstate.isfullmoon and math.random() < 0.25)
            or (self.worldstate.iswinter and math.random() < easing.inOutCirc(1 - ((self.worldstate.winterlength - self.worldstate.elapseddaysinseason) / self.worldstate.winterlength), 0.0, 1.0, 1.0)) then
            wave = SpawnRogueWave(player, tx, tz, -self:GetCurrentAngle(), self.ripple_speed * self:GetCurrentSpeed() * ROGUEWAVE_SPEED_MULTIPLIER)
        else
            wave = SpawnWaveRipple(player, tx, tz, -self:GetCurrentAngle(), self.ripple_speed * self:GetCurrentSpeed())
        end
        wave:AddTag("lanewave")
    end
end

function WaveLaneManager:OnUpdate(dt)
    local gridw, gridh = WAVE_LANE_SPACING, WAVE_LANE_SPACING

    if self:GetCurrentSpeed() > 0.0 then
        self.ripple_spawn_rate = self.ripple_spawn_rate + self.ripple_per_sec * self.ripple_per_sec_mod * self.ripple_per_sec_mult * self.seasonmult * dt

        while self.ripple_spawn_rate > 1.0 do --TODO maybe optimise by calculating the num to spawn
            for i, player in pairs(AllPlayers) do
                if player:IsValid() and player.entity:IsVisible() then
                    local px, py, pz = player.Transform:GetWorldPosition()
                    local ents = TheSim:FindEntities(px, py, pz, ROW_RADIUS, LANEWAVE_TAGS)
                    if #ents < MAX_WAVES then
                        --snap to map lanes
                        local lx, ly, lz = math.floor(px / gridw) * gridw, py, math.floor(pz / gridh) * gridh
                        self:SpawnLaneWaveRipple(player, lx, ly, lz)
                    end
                end
            end
            self.ripple_spawn_rate = self.ripple_spawn_rate - 1.0
        end

    end

    if self.ripple_per_sec_mod <= 0.0 then
        self.inst:StopUpdatingComponent(self)
    end

end

function WaveLaneManager:OnSave()
    if self.nightreset == true then --don't accidentally save the idle phase permamently
        self.currentSpeed = 1.0
        set_ocean_angle(self)
    end
    return
    {
        currentAngle = self.currentAngle,
        currentSpeed = self.currentSpeed
    }
end

function WaveLaneManager:OnLoad(data)
    if data then
        self.currentAngle = data.currentAngle or self.currentAngle
        self.currentSpeed = data.currentSpeed or self.currentSpeed
    end
end

function WaveLaneManager:GetCurrentAngle()
    return self.currentAngle
end

function WaveLaneManager:GetCurrentSpeed()
    return self.currentSpeed
end

function WaveLaneManager:GetCurrentVec3()
    return self.currentSpeed * math.cos(self.currentAngle * DEGREES), 0, self.currentSpeed * math.sin(self.currentAngle * DEGREES)
end

function WaveLaneManager:SetWaveSettings(ripple_per_sec)
    self.ripple_per_sec_mod = ripple_per_sec or 1.0
end

return WaveLaneManager
