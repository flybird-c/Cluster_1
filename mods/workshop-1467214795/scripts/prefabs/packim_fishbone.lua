local assets=
{
    Asset("ANIM", "anim/packim_fishbone.zip"),
}

local SPAWN_DIST = 30

local function PackimDead(inst)
	if inst.components.floater then
		inst.components.floater:UpdateAnimations("dead_water", "dead")
	end
	inst.components.inventoryitem:ChangeImageName("packim_fishbone_dead")
end

local function PackimLive(inst)
	if inst.components.floater then
		inst.components.floater:UpdateAnimations("idle_water", "idle_loop")
	end
	inst.components.inventoryitem:ChangeImageName("packim_fishbone")
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function GetSpawnPoint(pt)
	local offset = FindWalkableOffset(pt, math.random() * 2 * PI, SPAWN_DIST, 12, true, true, NoHoles, true)
    if offset ~= nil then
        offset.x = offset.x + pt.x
        offset.z = offset.z + pt.z
        return offset
    end
end

local function SpawnPackim(inst)
    local pt = inst:GetPosition()
    local spawn_pt = GetSpawnPoint(pt)
    if spawn_pt ~= nil then
        local packim = SpawnPrefab("packim")
        if packim ~= nil then
            packim.Physics:Teleport(spawn_pt:Get())
            packim:FacePoint(pt:Get())

            return packim
        end
    -- else
        -- this is not fatal, they can try again in a new location by picking up the bone again
    end
end

local StartRespawn --initialised later

local function StopRespawn(inst)
    if inst.respawntask then
        inst.respawntask:Cancel()
        inst.respawntask = nil
        inst.respawntime = nil
    end
end

local function RebindPackim(inst, packim)
    packim = packim or TheSim:FindFirstEntityWithTag("packim")
    if packim then
		PackimLive(inst)
		inst:ListenForEvent("death", function() StartRespawn(inst, TUNING.PACKIM_RESPAWN_TIME) end, packim)

        if packim.components.follower.leader ~= inst then
            packim.components.follower:SetLeader(inst)
        end
        return true
    end
end

local function RespawnPackim(inst)
    StopRespawn(inst)
    RebindPackim(inst, TheSim:FindFirstEntityWithTag("packim") or SpawnPackim(inst))
end

function StartRespawn(inst, time)
    StopRespawn(inst)

    local time = time or 0
    inst.respawntask = inst:DoTaskInTime(time, RespawnPackim)
    inst.respawntime = GetTime() + time
    if time > 0 then
        PackimDead(inst)
    end
end

local function FixPackim(inst)
	inst.fixtask = nil
	--take an existing FAT BIRD if there is one
	if not RebindPackim(inst) then
        PackimDead(inst)

		if inst.components.inventoryitem.owner then
            local time_remaining = inst.respawntime ~= nil and math.max(0, inst.respawntime - GetTime()) or 0
			StartRespawn(inst, time_remaining)
		end
	end
end

local function OnPutInInventory(inst)
	if not inst.fixtask then
		inst.fixtask = inst:DoTaskInTime(1, FixPackim)
	end
end

local function OnSave(inst, data)
    if inst.respawntime ~= nil then
        local time = GetTime()
        if inst.respawntime > time then
            data.respawntimeremaining = inst.respawntime - time
        end
    end
end

local function OnLoad(inst, data)
    if data == nil then
        return
    end

    if data.respawntimeremaining ~= nil then
        inst.respawntime = data.respawntimeremaining + GetTime()
        if data.respawntimeremaining > 0 then
            PackimDead(inst, true)
        end
    end
end

local function GetStatus(inst)
    return inst.respawntask ~= nil and "WAITING" or nil
end

--idle_water
--dead_water

local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddNetwork()
		
    MakeInventoryPhysics(inst)

    inst:AddTag("packim_fishbone") -- This tag is used to check explicitly for packim_fishbone
    inst:AddTag("irreplaceable")
	inst:AddTag("nonpotatable")

    inst.AnimState:SetBank("fishbone")
    inst.AnimState:SetBuild("packim_fishbone")
    inst.AnimState:PlayAnimation("idle_loop", true)

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle_loop")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem:ChangeImageName("packim_fishbone_dead")
	

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    inst.components.inspectable:RecordViews()

    inst:AddComponent("leader")

    MakeHauntableLaunch(inst)

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave

	inst.fixtask = inst:DoTaskInTime(1, FixPackim)

    return inst
end

return Prefab("packim_fishbone", fn, assets)
