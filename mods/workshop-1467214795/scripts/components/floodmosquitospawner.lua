--------------------------------------------------------------------------
--[[ FloodMosquitoSpawner class definition ]]
-- based on ButterflySpawner
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "FloodMosquitoSpawner should not exist on client")

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _activeplayers = {}
local _scheduledtasks = {}
local _worldstate = TheWorld.state
local _updating = false
local _mosquitos = {}
local _maxmosquitos = 3

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function GetSpawnPoint(player)
	--Since flood tiles are prefabs in the current implementation, we can use the ButterflySpawner code instead.
	for i = 5, 20, 2 do
		local rad = i
		local x,y,z = player.Transform:GetWorldPosition()
		local mindistance = 10
		local pt = Vector3(x,y,z)

		local theta = 360 * math.random()
		local result_offset = FindValidPositionByFan(theta, rad, 10, function(offset)
			local spawn_point = pt + offset
			if offset:Length() < mindistance then
				return false
			end

			if not IsSurroundedByLandTile(spawn_point.x, spawn_point.y, spawn_point.z, 3) then
				return false
			end

			if IsOnFlood(spawn_point.x, spawn_point.y, spawn_point.z) then
				return true
			end

			return false

		end)
		if result_offset then
			return pt + result_offset
		end
	end

	local rad = 20
	local mindistance = 10
	local x, y, z = player.Transform:GetWorldPosition()
	local floodtiles = TheSim:FindEntities(x, y, z, rad)

	for i, v in ipairs(floodtiles) do
		while v ~= nil and (v.prefab ~= "flood" or player:GetDistanceSqToInst(v) <= mindistance) do
			table.remove(floodtiles, i)
			v = floodtiles[i]
		end
	end

	return next(floodtiles) ~= nil and floodtiles[math.random(1, #floodtiles)] or nil
end

local function SpawnMosquitoForPlayer(player, reschedule)
	local pt = player:GetPosition()
	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 64, { "mosquito" })
	if #ents < _maxmosquitos then
		local spawnflood = GetSpawnPoint(player)
		if spawnflood ~= nil then
			local mosquito = SpawnPrefab("mosquito_poison")
			-- mosquito.components.homeseeker:SetHome(spawnflood)
			mosquito.Physics:Teleport(spawnflood.x, spawnflood.y, spawnflood.z)
			--friendly code to make tightly-knit groups feel less besieged -M
			local mpt = mosquito:GetPosition()
			local player_ents = TheSim:FindEntities(mpt.x, mpt.y, mpt.z, 64, { "player" })
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

local function ScheduleSpawn(player, initialspawn)
	if _scheduledtasks[player] == nil then
		local basedelay = initialspawn and 20 or 50
		_scheduledtasks[player] = player:DoTaskInTime(basedelay + math.random() * 20, SpawnMosquitoForPlayer, ScheduleSpawn)
	end
end

local function CancelSpawn(player)
	if _scheduledtasks[player] ~= nil then
		_scheduledtasks[player]:Cancel()
		_scheduledtasks[player] = nil
	end
end

local function ToggleUpdate(force)
	--SW has seasonprogress > .5, but updates every tick, so effectively the same as >= .5
	if _worldstate.isspring and (_worldstate.seasonprogress or 0) >= .5 and _maxmosquitos > 0 then
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

local function SetMaxMosquitos(max)
	_maxmosquitos = max
	ToggleUpdate(true)
end

local function AutoRemoveTarget(inst, target)
	if _mosquitos[target] ~= nil and target:IsAsleep() then
		target:Remove()
	end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function OnTargetSleep(target)
	inst:DoTaskInTime(0, AutoRemoveTarget, target)
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
-- inst:WatchWorldState("isspring", ToggleUpdate)
inst:WatchWorldState("seasonprogress", ToggleUpdate)
inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, TheWorld)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft, TheWorld)

--------------------------------------------------------------------------
--[[ Post initialization ]]
--------------------------------------------------------------------------

function self:OnPostInit()
	ToggleUpdate(true)
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:SpawnModeNever()
	SetMaxMosquitos(0)
end

function self:SpawnModeHeavy()
	SetMaxMosquitos(6)
end

function self:SpawnModeMed()
	SetMaxMosquitos(4)
end

function self:SpawnModeLight()
	SetMaxMosquitos(2)
end

function self.StartTrackingFn(target)
	if _mosquitos[target] == nil then
		local restore = target.persists -- and 1 or 0
		target.persists = false
		-- if target.components.homeseeker == nil then
			-- target:AddComponent("homeseeker")
		-- else
			-- restore = restore + 2
		-- end
		_mosquitos[target] = restore
		inst:ListenForEvent("entitysleep", OnTargetSleep, target)
	end
end

function self:StartTracking(target)
	self.StartTrackingFn(target)
end

function self.StopTrackingFn(target)
	local restore = _mosquitos[target]
	if restore ~= nil then
		target.persists = restore -- == 1 or restore == 3
		-- if restore < 2 then
			-- target:RemoveComponent("homeseeker")
		-- end
		_mosquitos[target] = nil
		inst:RemoveEventCallback("entitysleep", OnTargetSleep, target)
	end
end

function self:StopTracking(target)
	self.StopTrackingFn(target)
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
	return
	{
		maxmosquitos = _maxmosquitos,
	}
end

function self:OnLoad(data)
	_maxmosquitos = data.maxmosquitos or 3

	-- ToggleUpdate(true)
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
	local nummosquitos = 0
	for k, v in pairs(_mosquitos) do
		nummosquitos = nummosquitos + 1
	end
	return string.format("updating:%s mosquitos:%d/%d", tostring(_updating), nummosquitos, _maxmosquitos)
end

--------------------------------------------------------------------------
--[[ End ]]
--------------------------------------------------------------------------

end)
