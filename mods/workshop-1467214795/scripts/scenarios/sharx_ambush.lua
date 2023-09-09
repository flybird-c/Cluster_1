
local SHARX_SPAWN_DIST = 40

local function SpawnSharx(inst, threatprefab, target)
	local threat = SpawnPrefab(threatprefab)
	if threat then
		local x, y, z = inst.Transform:GetWorldPosition()
		local rads = math.random(0, 359) * DEGREES
		threat.Transform:SetPosition(x + SHARX_SPAWN_DIST * math.cos(rads), y, z + SHARX_SPAWN_DIST * math.sin(rads))
		threat.components.combat:SetTarget(target)
	end
end

local function TriggerTrap(inst, data, scenariorunner)
	local loots = {"smallmeat", "smallmeat", "smallmeat", "spear_launcher", "spear"}
	for i = 1, #loots, 1 do
		local prefab = SpawnPrefab(loots[i])
		inst.components.container:GiveItem(prefab)
	end

	local threats = {"sharx","crocodog"}
	local threat = threats[math.random(#threats)]
	for i = 1, 3, 1 do
		inst:DoTaskInTime(math.random(0, 3), function() SpawnSharx(inst, threat, data.sailor) end)
	end

	scenariorunner:ClearScenario()
end

local function OnCreate(inst, scenariorunner)
	inst.components.boathealth:SetPercent(GetRandomWithVariance(0.48, 0.1))
end

local function OnLoad(inst, scenariorunner)
    inst.scene_embarkedkfn = function(_inst, data) TriggerTrap(_inst, data, scenariorunner) end
	inst:ListenForEvent("embarked", inst.scene_embarkedkfn)
end

local function OnDestroy(inst)
    if inst.scene_embarkedkfn then
        inst:RemoveEventCallback("embarked", inst.scene_embarkedkfn)
        inst.scene_embarkedkfn = nil
    end
end

return
{
	OnCreate = OnCreate,
	OnLoad = OnLoad,
	OnDestroy = OnDestroy
}