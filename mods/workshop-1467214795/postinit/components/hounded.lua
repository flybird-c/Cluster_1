local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local _crocspawnmonsoonvariant = true
local _crocspawndryvariant = true
local _crocspawndata = {
	monsoon_prefab = "watercrocodog",
	dry_prefab = "poisoncrocodog",
	base_prefab = "crocodog",
}

local SPAWNTYPES = {
	sharx = IsOnOcean,
	vampirebat = IsOnLand,
	knightboat = IsOnOcean,
}

IAENV.AddComponentPostInit("hounded", function(cmp)
    --This is just a crude bandaid fix because other mods override inst.OnUpdate, but we need its upvalues -M
    local trueOnUpdate = cmp.LongUpdate
    --local upvname, upvalue = debug.getupvalue(trueOnUpdate, 1) --TODO ideally loop through all using UpvalueHacker
    --while upvname == "_OnUpdate" or upvname == "OnUpdate_old" do
    	--trueOnUpdate = upvalue
    	--upvname, upvalue = debug.getupvalue(trueOnUpdate, 1)
    --end
	
	local _spawndata = UpvalueHacker.GetUpvalue(cmp.SetSpawnData, "_spawndata")
    local _CheckForWaterImunity = UpvalueHacker.GetUpvalue(trueOnUpdate, "CheckForWaterImunity")
    local _targetableplayers = UpvalueHacker.GetUpvalue(_CheckForWaterImunity, "_targetableplayers")
    local _SummonSpawn = UpvalueHacker.GetUpvalue(cmp.SummonSpawn, "SummonSpawn")
    local _GetSpecialSpawnChance = UpvalueHacker.GetUpvalue(_SummonSpawn, "GetSpawnPrefab", "GetSpecialSpawnChance")

    local function GetSpecialCrocChance()
    	-- same as hound chance, except we undo the season modifier
        local chance = _GetSpecialSpawnChance()
        return TheWorld.state.issummer and chance * 2/3 or chance
    end

	local function GetCrocSpawnPrefab(upgrade)
		if upgrade and _crocspawndata.upgrade_spawn then
			return _crocspawndata.upgrade_spawn
		end

		local do_seasonal_spawn = math.random() < GetSpecialCrocChance()

		if do_seasonal_spawn then
			if _crocspawnmonsoonvariant
			 and ((TheWorld.state.isspring and TheWorld.state.elapseddaysinseason / (TheWorld.state.elapseddaysinseason+TheWorld.state.remainingdaysinseason) > 0.25)
			 or (TheWorld.state.issummer and TheWorld.state.elapseddaysinseason / (TheWorld.state.elapseddaysinseason+TheWorld.state.remainingdaysinseason) < 0.25)) then
				return _crocspawndata.monsoon_prefab
			end
			if _crocspawndryvariant and TheWorld.state.issummer then
				return _crocspawndata.dry_prefab
			end
		end

		return _crocspawndata.base_prefab
	end

    local function SummonSpawn(pt, upgrade)
        local __spawndata
		local climate = GetClimate(pt)
		if IsClimate(climate, "volcano") then
			return
    	elseif type(upgrade) == "table" and upgrade.upgrade_spawn then
            __spawndata = _spawndata
            cmp:SetSpawnData(upgrade)
        elseif IsClimate(climate, "island") then
            __spawndata = _spawndata
			upgrade = {upgrade_spawn = GetCrocSpawnPrefab(upgrade)}
			cmp:SetSpawnData(upgrade)
        end

		local _FindValidPositionByFan = FindValidPositionByFan
		local _FindWalkableOffset = FindWalkableOffset

		local spawnfn = type(upgrade) == "table" and SPAWNTYPES[upgrade.upgrade_spawn] or nil

		FindValidPositionByFan = function(arg1, arg2, arg3, fn, ...)
			return _FindValidPositionByFan(arg1, arg2, arg3, function(offset, ...) return (spawnfn == nil or spawnfn(offset + pt)) and IsInClimate(offset + pt, CLIMATES[climate]) and fn(offset, ...) end, ...)
		end
		FindWalkableOffset = function(arg1, arg2, arg3, arg4, arg5, arg6, fn, ...)
			return _FindWalkableOffset(arg1, arg2, arg3, arg4, arg5, arg6, function(point, ...) return (spawnfn == nil or spawnfn(point)) and IsInClimate(point, CLIMATES[climate]) and fn(point, ...) end, ...)
		end

    	local rets = {_SummonSpawn(pt, upgrade)}

		if __spawndata ~= nil then
			cmp:SetSpawnData(__spawndata)
		end

		FindValidPositionByFan = _FindValidPositionByFan
		FindWalkableOffset = _FindWalkableOffset

		return unpack(rets)
    end

	local function CheckForWaterImunity(player, ...)
		local climate = not _targetableplayers[player.GUID] and GetClimate(player) or nil
        if IsClimate(climate, "volcano") then
            -- block hound wave targeting when target is in the volcano climate
            _targetableplayers[player.GUID] = "notarget"
		elseif IsClimate(climate, "island") then
			_targetableplayers[player.GUID] = "land"
        else
            return _CheckForWaterImunity(player, ...)
        end
    end

    -- Note: always set the deepest value first, or else we'd need to upvalue our own modifications
    UpvalueHacker.SetUpvalue(cmp.SummonSpawn, SummonSpawn, "SummonSpawn")
    UpvalueHacker.SetUpvalue(trueOnUpdate, CheckForWaterImunity, "CheckForWaterImunity")

    function cmp:SummonSpecialSpawn(pt, prefab, num)
    	if pt == nil or prefab == nil then return end
		local hounds = {}
		local hound = nil
    	for i = 1, (num and math.max(num, 1) or 1), 1 do
    		hound = SummonSpawn(pt, {upgrade_spawn = prefab})
			if hound ~= nil then
				table.insert(hounds, hound)
			end
    	end
		return hounds
    end

	function cmp:SetCrocSpawnData(data)
		_crocspawndata = data
	end

	function cmp:SetCrocDryVariant(enabled)
		_crocspawndryvariant = enabled
	end

	function cmp:SetCrocMonsoonVariant(enabled)
		_crocspawnmonsoonvariant = enabled
	end
end)
