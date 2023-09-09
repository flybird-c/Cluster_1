local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local function IARescue(inst)
    if TheWorld.has_ia_drowning then
        return "WEREWOODIE_RESURRECT"
    end
end

----------------------------------------------------------------------------------------

local function startwereplayer(inst, data)
	if inst.components.poisonable then
		inst.components.poisonable:SetBlockAll(true)
	end
	inst:AddTag("NOVACUUM")
	if inst.components.drownable ~= nil then
		inst.components.drownable.rescuefn = IARescue
	end
end

------

local function newstate(inst, data)
	--data.statename
	if inst:HasTag("idle") then
		if inst._embarkingboat and inst._embarkingboat:IsValid() then
			inst.components.sailor:Embark(inst._embarkingboat)
			inst._embarkingboat = nil
		end
		inst:RemoveEventCallback("newstate", newstate)
	end
end

local function stop(inst)
	if inst.Physics then
		inst.Physics:Stop()
	end
end

local function stopwereplayer(inst, data)
	if inst.components.poisonable and not inst:HasTag("playerghost") then
		inst.components.poisonable:SetBlockAll(false)
	end
	if  inst:HasTag("NOVACUUM") then
		inst:RemoveTag("NOVACUUM")
	end
	if inst.components.drownable ~= nil then
		inst.components.drownable.rescuefn = nil
	end
	------
	--copy from postinit/player.lua to place weregoose on boat
    local x, y, z = inst.Transform:GetWorldPosition()
	if not inst:CanOnWater(true) and TheWorld.Map:IsOceanAtPoint(x, y, z) and inst.components.sailor then
		local boat = GetClosestBoatInRange(x, y, z, TUNING.AUTOEMBARK_BOATRANGE.WEREGOOSE)
		if boat then
			boat.components.sailable.isembarking = true
			inst._embarkingboat = boat
			--Move there!
			inst:ForceFacePoint(boat:GetPosition():Get())
			local dist = inst:GetPosition():Dist(boat:GetPosition())
			inst.Physics:SetMotorVelOverride(dist / .8, 0, 0)
			inst:DoTaskInTime(.8, stop)
			--Drowning immunity appears to be not needed. -M
			inst:ListenForEvent("newstate", newstate)
		end
	end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("woodie", function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:ListenForEvent("startwereplayer", startwereplayer)
    inst:ListenForEvent("stopwereplayer", stopwereplayer)
end)
