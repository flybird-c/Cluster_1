local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

-- TODO: This code doesnt not support rot boats properly and may need to be rewritten
----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local WARP_ACTIONS = table.invert({
    "Normal",
    "ToLand",
    "OtherShardToWater",
    "ToWater",
})

local function GetWarpAct(doer, recallmark, target_onwater)
	local is_sailing = doer:IsSailing()

	if is_sailing == target_onwater then
		return WARP_ACTIONS.Normal
	elseif is_sailing and not target_onwater then
		return WARP_ACTIONS.ToLand
	elseif not is_sailing and target_onwater then
		if recallmark ~= nil and (not recallmark:IsMarkedForSameShard()) then
			return WARP_ACTIONS.OtherShardToWater
		else
			return WARP_ACTIONS.ToWater
		end
	end
end

local _Warp_DoCastSpell = nil
local function Warp_DoCastSpell(inst, doer, ...)
	local tx, ty, tz = doer.components.positionalwarp:GetHistoryPosition(false)
	if tx ~= nil then
		local act = GetWarpAct(doer, inst.components.recallmark, TheWorld.Map:IsOceanAtPoint(tx, ty, tz, true))
        if act == WARP_ACTIONS.ToLand then -- If the player is going from water to land...
            doer.components.sailor:Disembark(nil, nil, true) -- Leave the boat behind...
        elseif act == WARP_ACTIONS.ToWater then -- If the player is going from land to water
            -- Niko: We may want to replace the static time with something a bit more dynamic.
            inst:DoTaskInTime(20 * FRAMES, function() -- Once we have teleported...
                local x, y, z = doer.Transform:GetWorldPosition()
                local boat = GetClosestBoatInRange(x, y, z, TUNING.AUTOEMBARK_BOATRANGE.POCKETWATCH)
                if boat ~= nil then
                    doer.components.sailor:Embark(boat, true) -- Mount the player on a nearby boat
                end
            end)
        end
	end
    return _Warp_DoCastSpell(inst, doer, ...)
end

local _Recall_DoCastSpell = nil
local function Recall_DoCastSpell(inst, doer, ...)
	local recallmark = inst.components.recallmark

	if recallmark:IsMarked() then
		local act = GetWarpAct(doer, recallmark, recallmark.recall_onwater)
        if act == WARP_ACTIONS.ToLand then -- If the player is going from water to land...
            doer.components.sailor:Disembark(nil, nil, true) -- Leave the boat behind...
        elseif act == WARP_ACTIONS.ToWater then -- If the player is going from land to water
            -- Niko: We may want to replace the static time with something a bit more dynamic.
            inst:DoTaskInTime(20 * FRAMES, function() -- Once we have teleported...
                local x, y, z = doer.Transform:GetWorldPosition()
                local boat = GetClosestBoatInRange(x, y, z, TUNING.AUTOEMBARK_BOATRANGE.POCKETWATCH)
                if boat ~= nil then
                    doer.components.sailor:Embark(boat, true) -- Mount the player on a nearby boat
                end
            end)
        end
	end
    return _Recall_DoCastSpell(inst, doer, ...)
end

---- Needed for the portal spell.
local NOTENTCHECK_CANT_TAGS = { "FX", "INLIMBO" }
local function noentcheckfn(pt)
    return not TheWorld.Map:IsPointNearHole(pt) and #TheSim:FindEntities(pt.x, pt.y, pt.z, 1, nil, NOTENTCHECK_CANT_TAGS) == 0
end
local function DelayedMarkTalker(player)
	-- if the player starts moving right away then we can skip this
	if player.sg == nil or player.sg:HasStateTag("idle") then 
		player.components.talker:Say(GetString(player, "ANNOUNCE_POCKETWATCH_MARK"))
	end 
end
----

local function Portal_DoCastSpell(inst, doer, target, pos)
	-- Niko: For now I'll just manually overwrite the entire spell.
	local recallmark = inst.components.recallmark

	if recallmark:IsMarked() then
		local pt = inst:GetPosition()
		local offset = FindWalkableOffset(pt, math.random() * 2 * PI, 3 + math.random(), 16, false, true, noentcheckfn, true, true)
						or FindWalkableOffset(pt, math.random() * 2 * PI, 5 + math.random(), 16, false, true, noentcheckfn, true, true)
						or FindWalkableOffset(pt, math.random() * 2 * PI, 7 + math.random(), 16, false, true, noentcheckfn, true, true)
		if offset ~= nil then
			pt = pt + offset
		end

		if not Shard_IsWorldAvailable(recallmark.recall_worldid) then
			return false, "SHARD_UNAVAILABLE"
		end

		local portal = SpawnPrefab("pocketwatch_portal_entrance")
		portal.Transform:SetPosition(pt:Get())
		portal:SpawnExit(recallmark.recall_worldid, recallmark.recall_x, recallmark.recall_y, recallmark.recall_z, recallmark.recall_onwater)
		inst.SoundEmitter:PlaySound("wanda1/wanda/portal_entrance_pre")

        local new_watch = SpawnPrefab("pocketwatch_recall")
		new_watch.components.recallmark:Copy(inst)

		local x, y, z = inst.Transform:GetWorldPosition()
        new_watch.Transform:SetPosition(x, y, z)
		new_watch.components.rechargeable:Discharge(TUNING.POCKETWATCH_RECALL_COOLDOWN)

        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
        if holder ~= nil then
            local slot = holder:GetItemSlot(inst)
            inst:Remove()
            holder:GiveItem(new_watch, slot, Vector3(x, y, z))
        else
            inst:Remove()
        end

		return true
	else
		local x, y, z = doer.Transform:GetWorldPosition()
		recallmark:MarkPosition(x, y, z)
		inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/MarkPosition")

		doer:DoTaskInTime(12 * FRAMES, DelayedMarkTalker) 

		return true
	end
end

local _OldOnActivate = nil
local function Portal_OnActivate(inst, doer)
	_OldOnActivate(inst, doer)
	local PlayerOnWater = doer.components.sailor.sailing
	local TargetOnWater = inst.TargetOnWater

	if not PlayerOnWater == TargetOnWater then
		if TargetOnWater == false then -- Water to land
			doer.components.sailor:Disembark(nil, nil, true)

		elseif TargetOnWater == true then -- Land to water
			doer:DoTaskInTime(4.5, function() -- Once we have teleported...
				local x, y, z = doer.Transform:GetWorldPosition()
				local boat = GetClosestBoatInRange(x, y, z, TUNING.AUTOEMBARK_BOATRANGE.POCKETWATCH)
				if boat ~= nil then
					doer.components.sailor:Embark(boat, true) -- Mount the player on a nearby boat
				end
			end)

		end
	end
end

local _OldSpawnExit = nil
local function Portal_SpawnExit(inst, worldid, x, y, z, onwater)
	_OldSpawnExit(inst, worldid, x, y, z)
	inst.TargetOnWater = onwater
end

local function warp_fn(inst)
	if not TheWorld.ismastersim then 
        return 
    end

    if not _Warp_DoCastSpell then
        _Warp_DoCastSpell = inst.components.pocketwatch.DoCastSpell -- Backup the old function
    end
	inst.components.pocketwatch.DoCastSpell = Warp_DoCastSpell -- Run our override
end

local function recall_fn(inst)
	if not TheWorld.ismastersim then 
        return 
    end

    if not _Recall_DoCastSpell then
        _Recall_DoCastSpell = inst.components.pocketwatch.DoCastSpell -- Backup the old function
    end
	inst.components.pocketwatch.DoCastSpell = Recall_DoCastSpell -- Run our override

end

local function portal_fn(inst)
	if not TheWorld.ismastersim or not TheWorld.has_ia_drowning then return end -- Do not run on client

	-- inst.ActualSpell = inst.components.pocketwatch.DoCastSpell -- We don't need to back up the function sense we are completely replacing it.
	inst.components.pocketwatch.DoCastSpell = Portal_DoCastSpell -- Run our override
end

local function portal_entrance_fn(inst)
	if inst.components.teleporter then
        if not _OldOnActivate then
            _OldOnActivate = inst.components.teleporter.onActivate
        end
		inst.components.teleporter.onActivate = Portal_OnActivate
	end
    if not _OldSpawnExit then
        _OldSpawnExit = inst.SpawnExit
    end
	inst.SpawnExit = Portal_SpawnExit
end


IAENV.AddPrefabPostInit("pocketwatch_warp", warp_fn) -- Backstep
IAENV.AddPrefabPostInit("pocketwatch_recall", recall_fn) -- Backtreck
IAENV.AddPrefabPostInit("pocketwatch_portal", portal_fn) -- Rift
IAENV.AddPrefabPostInit("pocketwatch_portal_entrance", portal_entrance_fn) -- Rift portal entrance
