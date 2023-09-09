--------------------------------------------------------------------------
--[[ Whalehunter class definition ]]
-- This is a copy of Hunter specifically for whale hunting
-- It has some hooks to make things easier for mods :)
--------------------------------------------------------------------------

-- c_whalehunt = nil --DEBUG

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Whalehunter should not exist on client")

--------------------------------------------------------------------------
--[[ Dependencies ]]
--------------------------------------------------------------------------

local SourceModifierList = require("util/sourcemodifierlist")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local HUNT_UPDATE = 2

local _dirt_prefab = "whale_bubbles"
local _track_prefab = "whale_track"
local _beast_prefabs = {"whale_blue"}
local _alternate_beast_prefabs = {function(beasts)
	if TheWorld.state.issummer or TheWorld.state.iswinter then
		table.insert(beasts, "whale_white")
	end
end}
local _spawnoverride = nil

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst
	
-- Private
local _activeplayers = {}
local _activehunts = {}

local _validtiles = table.invert({
    WORLD_TILES.OCEAN_MEDIUM,
    WORLD_TILES.OCEAN_DEEP,
    WORLD_TILES.OCEAN_SHIPGRAVEYARD,
})

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local OnUpdateHunt
local ResetHunt

local function GetMaxHunts()
	return #_activeplayers
end

local function RemoveDirt(hunt)
	assert(hunt)
	--print("Whalehunter:RemoveDirt")
	if hunt.lastdirt ~= nil then
		--print("   removing old dirt")
		inst:RemoveEventCallback("onremove", hunt.lastdirt._ondirtremove, hunt.lastdirt)
		hunt.lastdirt:Remove()
		hunt.lastdirt = nil
	--else
		--print("   nothing to remove")
	end
end

local function StopHunt(hunt)
	assert(hunt)
	--print("Whalehunter:StopHunt")

	RemoveDirt(hunt)

	if hunt.hunttask ~= nil then
		--print("   stopping")
		hunt.hunttask:Cancel()
		hunt.hunttask = nil
	--else
		--print("   nothing to stop")
	end
end

local function BeginHunt(hunt)
	assert(hunt)
	--print("Whalehunter:BeginHunt")
	hunt.hunttask = inst:DoPeriodicTask(HUNT_UPDATE, OnUpdateHunt, nil, hunt)
	--print(hunt.hunttask ~= nil and "The Hunt Begins!" or "The Hunt ... failed to begin.")
end

local function StopCooldown(hunt)
	assert(hunt)
	--print("Whalehunter:StopCooldown")
	if hunt.cooldowntask ~= nil then
		--print("    stopping")
		hunt.cooldowntask:Cancel()
		hunt.cooldowntask = nil
		hunt.cooldowntime = nil
	--else
		--print("    nothing to stop")
	end
end

local function OnCooldownEnd(inst, hunt)
	assert(hunt)
	--print("Whalehunter:OnCooldownEnd")

	StopCooldown(hunt) -- clean up references
	StopHunt(hunt)

	BeginHunt(hunt)
end

local function RemoveHunt(hunt)
	StopHunt(hunt)
	for i,v in ipairs(_activehunts) do
		if v == hunt then
			table.remove(_activehunts, i)
			return
		end
	end
	assert(false)
end

local function StartCooldown(inst, hunt, cooldown)
	assert(hunt)
	local cooldown = cooldown or TUNING.WHALEHUNT_COOLDOWN + TUNING.WHALEHUNT_COOLDOWNDEVIATION * (math.random() * 2 - 1)
	--print("Whalehunter:StartCooldown", cooldown)

	StopHunt(hunt)
	StopCooldown(hunt)

	if #_activehunts > GetMaxHunts() then
		RemoveHunt(hunt)
		return
	end

	if cooldown and cooldown > 0 then
		--print("The Hunt begins in", cooldown)
		hunt.activeplayer = nil
		hunt.lastdirt = nil
		hunt.lastdirttime = nil

		hunt.cooldowntask = inst:DoTaskInTime(cooldown, OnCooldownEnd, hunt)
		hunt.cooldowntime = GetTime() + cooldown
	end
end

local function StartHunt()
	--print("Whalehunter:StartHunt")
	-- Given the way hunt is used, it should really be its own class now
	local newhunt =
	{
		lastdirt = nil,
		direction = nil,
		activeplayer = nil,
	}
	table.insert(_activehunts, newhunt)
	inst:DoTaskInTime(0, StartCooldown, newhunt)
	return newhunt
end

-- c_whalehunt = function() 
	-- for i = #_activehunts, 1, -1 do
		-- table.remove(_activehunts, i)
		-- StopHunt(_activehunts[i])
	-- end
	-- table.insert(_activehunts,{})
	-- BeginHunt(_activehunts[1])
-- end --DEBUG

local function IsValidWater(pt)
	--check if the point is too close to the edge fog (this should probably be a public util -M)
	local h, w = TheWorld.Map:GetSize()
	local tx, ty = TheWorld.Map:GetTileCoordsAtPoint(pt.x, pt.y, pt.z)
	if GetDistFromEdge(tx, ty, w, h ) < TUNING.MAPEDGE_PADDING then
		return false
	end
	local tile = TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
	return _validtiles[tile] ~= nil
end

local function GetSpawnPoint(pt, radius, hunt)
	--print("Whalehunter:GetSpawnPoint", tostring(pt), radius)

	local angle = hunt.direction
	if angle then
		local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
		local spawn_point = pt + offset
		
		if IsValidWater(spawn_point) then
			--print(string.format("Whalehunter:GetSpawnPoint RESULT %s, %2.2f", tostring(spawn_point), angle/DEGREES))
			return spawn_point
		end
	end
end

local function SpawnDirt(pt,hunt)
	assert(hunt)
	--print("Whalehunter:SpawnDirt")

	local spawn_pt = GetSpawnPoint(pt, TUNING.WHALEHUNT_SPAWN_DIST, hunt)
	if spawn_pt ~= nil then
		local spawned = SpawnPrefab(_dirt_prefab)
		if spawned ~= nil then
			spawned.Transform:SetPosition(spawn_pt:Get())
			hunt.lastdirt = spawned
			hunt.lastdirttime = GetTime()

			spawned._ondirtremove = function()
				hunt.lastdirt = nil
				ResetHunt(hunt)
			end
			inst:ListenForEvent("onremove", spawned._ondirtremove, spawned)

			return true
		end
	end
	--print("Whalehunter:SpawnDirt FAILED")
	return false
end

local function GetRunAngle(pt, angle, radius)
	local offset, result_angle = FindSwimmableOffset(pt, angle, radius, 14, true, false, IsValidWater)
	--print("   found... ",offset)
	return result_angle
end

local function GetNextSpawnAngle(pt, direction, radius)
	--print("Whalehunter:GetNextSpawnAngle", tostring(pt), radius)

	local base_angle = direction or math.random() * 2 * PI
	local deviation = math.random(-TUNING.WHALEHUNT_TRACK_ANGLE_DEVIATION, TUNING.WHALEHUNT_TRACK_ANGLE_DEVIATION)*DEGREES

	local start_angle = base_angle + deviation
	--print(string.format("   original: %2.2f, deviation: %2.2f, starting angle: %2.2f", base_angle/DEGREES, deviation/DEGREES, start_angle/DEGREES))

	--[[local angle =]] return GetRunAngle(pt, start_angle, radius)
	--print(string.format("Whalehunter:GetSpawnPoint RESULT %s", tostring(angle and angle/DEGREES)))
	--return angle
end

local function StartDirt(hunt,position)
	assert(hunt)

	--print("Whalehunter:StartDirt")

	RemoveDirt(hunt)

	local pt = position --Vector3(player.Transform:GetWorldPosition())

	hunt.numtrackstospawn = math.random(TUNING.WHALEHUNT_MIN_TRACKS, TUNING.WHALEHUNT_MAX_TRACKS)
	hunt.trackspawned = 0
	hunt.direction = GetNextSpawnAngle(pt, nil, TUNING.WHALEHUNT_SPAWN_DIST)
	if hunt.direction ~= nil then
		--print(string.format("   first angle: %2.2f", hunt.direction/DEGREES))

		--print("    numtrackstospawn", hunt.numtrackstospawn)

		-- it's ok if this spawn fails, because we'll keep trying every HUNT_UPDATE
		local spawnRelativeTo =  pt
		if SpawnDirt(spawnRelativeTo, hunt) then
			--print("Suspicious dirt placed for player ")
		end
	--else
		--print("Failed to find suitable dirt placement point")
	end
end

-- are we too close to the last dirtpile of a hunt?
local function IsNearHunt(player)
	for i,hunt in ipairs(_activehunts) do
		if hunt.lastdirt ~= nil and player:IsNear(hunt.lastdirt, TUNING.MIN_JOINED_HUNT_DISTANCE) then
			return true
		end
	end
	return false
end

-- something went unrecoverably wrong, try again after a brief pause
ResetHunt = function(hunt, washedaway)
	assert(hunt)
	--print("Whalehunter:ResetHunt - The Hunt was a dismal failure, please stand by...")
	if hunt.activeplayer ~= nil then
		hunt.activeplayer:PushEvent("huntlosttrail", { washedaway = washedaway })
	end

	StartCooldown(inst, hunt, TUNING.WHALEHUNT_RESET_TIME)
end

-- Don't be tricked by the name. This is not called every frame
OnUpdateHunt = function(inst, hunt)
	assert(hunt)

	--print("Whalehunter:OnUpdateHunt")

	if hunt.lastdirttime ~= nil then
		if hunt.huntedbeast == nil and hunt.trackspawned >= 1 then
			local wet = TheWorld.state.wetness > 15 or TheWorld.state.israining
			if (wet and (GetTime() - hunt.lastdirttime) > (.75*TUNING.SEG_TIME))
				or (GetTime() - hunt.lastdirttime) > (1.25*TUNING.SEG_TIME) then
		
				-- check if the player is currently active in any other hunts
				local playerIsInOtherHunt = false
				for i,v in ipairs(_activehunts) do
					if v ~= hunt and v.activeplayer and hunt.activeplayer then
						if v.activeplayer == hunt.activeplayer then
							playerIsInOtherHunt = true
						end
					end
				end

				-- if the player is still active in another hunt then end this one quietly
				if playerIsInOtherHunt then
					StartCooldown(inst, hunt)
				else
					ResetHunt(hunt, wet) --Wash the tracks away but only if the player has seen at least 1 track
				end

				return
			end
		end
	end

	if hunt.lastdirt == nil then
		-- pick a player that is available, meaning, not being the active participant in a hunt
		local huntingPlayers = {}   
		for i,v in ipairs(_activehunts) do
			if v.activeplayer then
				huntingPlayers[v.activeplayer] = true
			end
		end

		local eligiblePlayers = {}
		for i,v in ipairs(_activeplayers) do
			if not huntingPlayers[v] and not IsNearHunt(v) then
				table.insert(eligiblePlayers, v)
			end
		end
		if #eligiblePlayers == 0 then
			-- Maybe next time?
			return
		end
		local player = eligiblePlayers[math.random(1,#eligiblePlayers)]
		--print("Start hunt for player",player)
		local position = player:GetPosition()
		StartDirt(hunt, position)
	else
		-- if no player near enough, then give up this hunt and start a new one
		local x, y, z = hunt.lastdirt.Transform:GetWorldPosition()
		
		if not IsAnyPlayerInRange(x, y, z, TUNING.MAX_WHALEHUNT_DISTANCE) then
			-- try again rather soon
			StartCooldown(inst, hunt, .1)
		end
	end
end

local function GetAlternateBeastChance()
	local day = TheWorld.state.cycles
	local chance = Lerp(TUNING.WHALEHUNT_ALTERNATE_BEAST_CHANCE_MIN, TUNING.WHALEHUNT_ALTERNATE_BEAST_CHANCE_MAX, day/100)
	return math.clamp(chance, TUNING.WHALEHUNT_ALTERNATE_BEAST_CHANCE_MIN, TUNING.WHALEHUNT_ALTERNATE_BEAST_CHANCE_MAX)
end

local function GetRandomBeastPrefab(t)
	local valid = {}
	for k,v in ipairs(t) do
		if type(v) == "string" then
			table.insert(valid, v)
		elseif type(v) == "function" then
			v(valid) --give the function complete control over the table, for mod madness :D -M
		end
	end
	return #valid > 0 and valid[math.random(#valid)] or nil
end

local function SpawnHuntedBeast(hunt, pt)
	assert(hunt)
	--print("Whalehunter:SpawnHuntedBeast")

	local spawn_pt = GetSpawnPoint(pt, TUNING.WHALEHUNT_SPAWN_DIST, hunt)
	if spawn_pt ~= nil then
		hunt.huntedbeast = SpawnPrefab(
			_spawnoverride or
			(math.random() <= GetAlternateBeastChance() and GetRandomBeastPrefab(_alternate_beast_prefabs)) or
			GetRandomBeastPrefab(_beast_prefabs)
		)

		if hunt.huntedbeast ~= nil then
			--print("Kill the Beast!")
			hunt.huntedbeast.Physics:Teleport(spawn_pt:Get())

			local function OnBeastDeath()
				--print("Whalehunter:OnBeastDeath")
				inst:RemoveEventCallback("onremove", OnBeastDeath, hunt.huntedbeast)
				hunt.huntedbeast = nil
				StartCooldown(inst, hunt)
			end

			inst:ListenForEvent("death", OnBeastDeath, hunt.huntedbeast)
			inst:ListenForEvent("onremove", OnBeastDeath, hunt.huntedbeast)

			hunt.huntedbeast:PushEvent("spawnedforhunt")
			return true
		end
	end
	--print("Whalehunter:SpawnHuntedBeast FAILED")
	return false
end

local function SpawnBubble(num, pt, direction)
	local bubble = SpawnPrefab(_track_prefab)
	local offset = Vector3((num * 5) * math.cos(direction), 0, -(num * 5) * math.sin(direction))
	bubble.Transform:SetPosition((pt + offset):Get())
end

local function HintDirection(pt, direction)
	--Spawn several bubbles in a line pointing towards the next track.
	for i = 0, 3 do
		inst:DoTaskInTime(i * 1.33 + 0.5, function() SpawnBubble(i, pt, direction) end)
	end
end

local function SpawnTrack(spawn_pt, hunt)
	--print("Whalehunter:SpawnTrack")

	if spawn_pt then
		local next_angle = GetNextSpawnAngle(spawn_pt, hunt.direction, TUNING.WHALEHUNT_SPAWN_DIST)
		if next_angle ~= nil then
			local spawned = SpawnPrefab(_track_prefab)
			if spawned ~= nil then
				spawned.Transform:SetPosition(spawn_pt:Get())

				hunt.direction = next_angle

				--print(string.format("   next angle: %2.2f", hunt.direction/DEGREES))
				spawned.Transform:SetRotation(hunt.direction/DEGREES - 90)

				hunt.trackspawned = hunt.trackspawned + 1
				--print(string.format("   spawned %u/%u", hunt.trackspawned, hunt.numtrackstospawn))
				return true
			end
		end
	end
	--print("Whalehunter:SpawnTrack FAILED")
	return false
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function KickOffHunt()
	-- schedule start of a new hunt
	if #_activehunts < GetMaxHunts() then
		StartHunt()
	end
end

local function OnPlayerJoined(src, player)
	for i,v in ipairs(_activeplayers) do
		if v == player then
			return
		end
	end
	table.insert(_activeplayers, player)
	-- one hunt per player. 
	KickOffHunt()
end

local function OnPlayerLeft(src, player)
	for i,v in ipairs(_activeplayers) do
		if v == player then
			table.remove(_activeplayers, i)
			return
		end
	end
end

local WHALE_MUST = {"whale"}
local function OnMegaFlare(inst, data)
	inst:DoTaskInTime(5 + (math.random() * 20), function()
		if data.sourcept and IsOnOcean(data.sourcept) then
			
			local spawnpoint = nil

			-- GET A PLAYER NEAR THE BURST
			local players = FindPlayersInRange(data.sourcept.x, data.sourcept.y, data.sourcept.z, 35)

			--find a spot outside player vision of that player 
			if #players > 0 then
				local offset = FindValidPositionByFan(math.random()*2*PI, 40, 32, function(testoffset)
					local newpt = data.sourcept + testoffset

					if IsValidWater(newpt) then
						local testplayers = FindPlayersInRange(newpt.x, newpt.y, newpt.z, 35)
						if #testplayers == 0 then
							return true
						end
					end
				end)

				if offset then
					spawnpoint = data.sourcept + offset
				end
			end

			--ARE THERE OTHER WHALES NEARBY ALREADY?
			if spawnpoint then
				local ents = TheSim:FindEntities(data.sourcept.x,0,data.sourcept.z, 70, WHALE_MUST)
				if #ents > 0 then
					spawnpoint = nil
				end
			end

			-- SPAWN THEM IN
			if spawnpoint and math.random() < 0.6 then
				local beast = GetRandomBeastPrefab(_alternate_beast_prefabs)
				if beast then
					local players = FindPlayersInRange(spawnpoint.x,spawnpoint.y,spawnpoint.z, 40)
					beast = SpawnPrefab(beast)
					beast.Transform:SetPosition(spawnpoint.x,spawnpoint.y,spawnpoint.z)
					beast.components.combat:SuggestTarget(players[1])
					beast:AddTag("flare_summoned")
				end
			end
		end
	end)
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

for i, v in ipairs(AllPlayers) do
	OnPlayerJoined(self, v)
end

inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, TheWorld)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft, TheWorld)
inst:ListenForEvent("island_megaflare_detonated", OnMegaFlare, TheWorld)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

-- if anything fails during this step, it's basically unrecoverable, since we only have this one chance
-- to spawn whatever we need to spawn.  if that fails, we need to restart the whole process from the beginning
-- and hope we end up in a better place
function self:OnDirtInvestigated(pt, doer)
	assert(doer)

	--print("Whalehunter:OnDirtInvestigated (by "..tostring(doer)..")")

	local hunt = nil
	-- find the hunt this pile belongs to
	for i,v in ipairs(_activehunts) do
		if v.lastdirt ~= nil and v.lastdirt:GetPosition() == pt then
			hunt = v
			inst:RemoveEventCallback("onremove", v.lastdirt._ondirtremove, v.lastdirt)
			break
		end
	end

	if hunt == nil then
		-- we should probably do something intelligent here.
		--print("yikes, no matching hunt found for investigated dirtpile")
		return
	end

	hunt.activeplayer = doer

	if hunt.numtrackstospawn ~= nil and hunt.numtrackstospawn > 0 then
		if SpawnTrack(pt, hunt) then
			print("    ", hunt.trackspawned, hunt.numtrackstospawn)
			if hunt.trackspawned < hunt.numtrackstospawn then
				if SpawnDirt(pt, hunt) then
					HintDirection(pt, hunt.direction)
					--print("...good job, you found a track!")
				else
					--print("SpawnDirt FAILED! RESETTING")
					ResetHunt(hunt)
				end
			elseif hunt.trackspawned == hunt.numtrackstospawn then
				if SpawnHuntedBeast(hunt,pt) then
					--print("...you found the last track, now find the beast!")
					hunt.activeplayer:PushEvent("huntbeastnearby")
					StopHunt(hunt)
				else
					--print("SpawnHuntedBeast FAILED! RESETTING")
					ResetHunt(hunt)
				end
			end
		else
			-- print("SpawnTrack FAILED! RESETTING")
			ResetHunt(hunt)
		end
	end
end


-- Hooks for mods

function self:AddBeast(prefab)
	-- note: "prefab" can also be a function, in that case the function can add the prefab if conditions are met
	table.insert(_beast_prefabs, prefab)
	-- return #_beast_prefabs
end

function self:AddAlternateBeast(prefab)
	-- note: "prefab" can also be a function, in that case the function can add the prefab if conditions are met
	table.insert(_alternate_beast_prefabs, prefab)
	-- return #_alternate_beast_prefabs
end

--------------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------

function self:LongUpdate(dt)
	for i,hunt in ipairs(_activehunts) do
		if hunt.cooldowntask ~= nil and hunt.cooldowntime ~= nil then
			hunt.cooldowntask:Cancel()
			hunt.cooldowntask = nil
			hunt.cooldowntime = hunt.cooldowntime - dt
			hunt.cooldowntask = inst:DoTaskInTime(hunt.cooldowntime - GetTime(), OnCooldownEnd, hunt)
		end
	end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
	local str = ""
	for i, hunt in ipairs(_activehunts) do
		str = str.." Cooldown: ".. (hunt.cooldowntime and string.format("%2.2f", math.max(1, hunt.cooldowntime - GetTime())) or "-")
		if not hunt.lastdirt then
			str = str.." No last dirt."
			--str = str.." Distance: ".. (playerdata.distance and string.format("%2.2f", playerdata.distance) or "-")
			--str = str.."/"..tostring(TUNING.MIN_HUNT_DISTANCE)
		else
			str = str.." Dirt"
			--str = str.." Distance: ".. (playerdata.distance and string.format("%2.2f", playerdata.distance) or "-")
			--str = str.."/"..tostring(TUNING.MAX_DIRT_DISTANCE)
		end
	end
	return str
end

end)
