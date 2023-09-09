--Based on Frograin

return Class(function(self, inst)

assert(TheWorld.ismastersim, "HailRain should not exist on client")

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _activeplayers = {}
local _scheduledtasks = {}
local _worldstate = TheWorld.state
local _map = TheWorld.Map
local _updating = false

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function GetSpawnPoint(pt)
    local function TestSpawnPoint(offset)
        local spawnpoint = pt + offset
        return _map:IsPassableAtPoint(spawnpoint.x, spawnpoint.y, spawnpoint.z, true) and IsInClimate(spawnpoint, "island")
    end

    local theta = math.random() * 2 * PI
    local radius = math.random() * 20 --range taken from SW prefabs/hail.lua
    local resultoffset = FindValidPositionByFan(theta, radius, 12, TestSpawnPoint)

    if resultoffset ~= nil then
        return pt + resultoffset
    end
end

local function SpawnHailForPlayer(player, reschedule)
    local pt = player:GetPosition()
	if IsInClimate(player, "island") then
		local spawn_point = GetSpawnPoint(pt)
		if spawn_point ~= nil then
			SpawnPrefab("hail_ice"):StartFalling(spawn_point.x, spawn_point.y, spawn_point.z)
			--mean code to make tightly-knit groups gain less ice -M
			local player_ents = TheSim:FindEntities(spawn_point.x, spawn_point.y, spawn_point.z, 64, { "player" })
			for i, other_player in pairs(player_ents) do
				if other_player ~= player and _scheduledtasks[other_player] then
					_scheduledtasks[other_player]:Cancel()
					_scheduledtasks[other_player] = nil
					reschedule(other_player)
				end
			end
		end
	end
    _scheduledtasks[player] = nil
    reschedule(player)
end

local function ScheduleSpawn(player)
    if _scheduledtasks[player] == nil then
        --add a min so the dotaskintime does not start with 293759275923750927590 billion seconds
        local max = 10 * (_worldstate.hurricane_progress + 0.5)^2 --dynamically increase the max so the start is quicker and the stop is slower
		local _spawntime = _worldstate.hailrate > 0 and math.min(FRAMES*((1/_worldstate.hailrate) * 20), max) or max --a rewrite of 0.05 * hailrate for ticks/_spawntime instead of ticks*_spawntime, also converting seconds into ticks
        _scheduledtasks[player] = player:DoTaskInTime(_spawntime, SpawnHailForPlayer, ScheduleSpawn)
    end
end

local function CancelSpawn(player)
    if _scheduledtasks[player] ~= nil then
        _scheduledtasks[player]:Cancel()
        _scheduledtasks[player] = nil
    end
end

local function ToggleUpdate(force)
    if _worldstate.islandishailing then
        if not _updating then
            _updating = true
            for i, v in ipairs(_activeplayers) do
                ScheduleSpawn(v, true)
            end
        elseif force then
            for i, v in ipairs(_activeplayers) do
                CancelSpawn(v)
                ScheduleSpawn(v, true)
            end
        end
    elseif _updating then
        _updating = false
        for i, v in ipairs(_activeplayers) do
            CancelSpawn(v)
        end
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnIsHailing(inst, ishailing)
    ToggleUpdate()
end

local function OnPlayerJoined(src, player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            return
        end
    end
    table.insert(_activeplayers, player)
    if _updating then
        ScheduleSpawn(player, true)
    end
end

local function OnPlayerLeft(src, player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            CancelSpawn(player)
            table.remove(_activeplayers, i)
            return
        end
    end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Initialize variables
for i, v in ipairs(AllPlayers) do
    table.insert(_activeplayers, v)
end

--Register events
inst:WatchWorldState("islandishailing", OnIsHailing)

inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, TheWorld)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft, TheWorld)

-- ToggleUpdate(true) --conditions are never true at this point

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

--need to return something so OnLoad gets used
-- function self:OnSave()
	-- return {
	-- }
-- end

-- function self:OnLoad(data)
    -- ToggleUpdate(true)
-- end

function self:OnPostInit()
    ToggleUpdate(true)
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    return string.format("HailRain: updating:%s", tostring(_updating))
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
