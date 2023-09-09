local brain = require("brains/stungraybrain")

local assets = {
	Asset("ANIM", "anim/stinkray.zip"),
}

local prefabs = {
	"venomgland",
	"poisonbubble_short",
	"monstermeat",
	"splash_water",
}

local SLEEP_DIST_FROMHOME = 1
local SLEEP_DIST_FROMTHREAT = 20
local MAX_CHASEAWAY_DIST = 80
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 30

local function KeepThreat(inst, threat)
	return IsOnOcean(threat)
end

local function MakeTeam(inst, attacker)
	local leader = SpawnPrefab("teamleader")
	leader:AddTag("stungray")
	leader.components.teamleader.threat = attacker
	leader.components.teamleader.team_type = inst.components.teamattacker.team_type
	leader.components.teamleader:NewTeammate(inst)
	leader.components.teamleader:BroadcastDistress(inst)
	leader.components.teamleader:SetKeepThreatFn(KeepThreat)
end

local RETARGET_CANT_TAGS = {"FX", "NOCLICK","INLIMBO", "stungray"}
local RETARGET_ONEOF_TAGS = {"monster", "character"}
local function Retarget(inst)
	local ta = inst.components.teamattacker

	local newtarget = FindEntity(inst, TUNING.STINKRAY_TARGET_DIST, function(guy)
			return (guy:HasTag("character") or guy:HasTag("monster"))
				and not guy:HasTag("stungray")
				and inst.components.combat:CanTarget(guy)
                and not guy:IsOnValidGround()
	end, nil, RETARGET_CANT_TAGS, RETARGET_ONEOF_TAGS)

	if newtarget and not ta.inteam and not ta:SearchForTeam() then
		MakeTeam(inst, newtarget)
	end

	if ta.inteam and not ta.teamleader:CanAttack() then
		return newtarget
	end
end

local function KeepTarget(inst, target)
	if (inst.components.teamattacker.teamleader and not inst.components.teamattacker.teamleader:CanAttack()) or inst.components.teamattacker.orders == "ATTACK" then
		return not target:IsOnValidGround()
	end
    return false
end

local function OnAttacked(inst, data)
	if not inst.components.teamattacker.inteam and not inst.components.teamattacker:SearchForTeam() then
		MakeTeam(inst, data.attacker)
	elseif inst.components.teamattacker.teamleader then
		inst.components.teamattacker.teamleader:BroadcastDistress()  -- Ask for help!
	end

	if inst.components.teamattacker.inteam and not inst.components.teamattacker.teamleader:CanAttack() then
		local attacker = data and data.attacker
		inst.components.combat:SetTarget(attacker)
		inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("stungray") end, MAX_TARGET_SHARES)
	end
end

local function OnCombatTarget(inst, data)
	-- If you're in a team or have a combat target then run.
	if (data and data.target) or inst.components.teamattacker.inteam then
		inst.components.locomotor:SetShouldRun(true)
	else
		inst.components.locomotor:SetShouldRun(false)
	end
end

local function OnHitOther(inst, other, damage, stimuli)
	SpawnPrefab("poisonbubble_short").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.components.areapoisoner:DoPoison(true)
end

local function SetLocoState(inst, state)
	-- "gotofly" or "gotoswim"
	inst.LocoState = string.lower(state)
end

local function IsLocoState(inst, state)
	return inst.LocoState == string.lower(state)
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

	inst.DynamicShadow:SetSize(1.75, .6)
	inst.DynamicShadow:Enable(false)

	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.Transform:SetNoFaced()

	inst.scale_flying = TUNING.STINKRAY_SCALE_FLYING
	inst.scale_water = TUNING.STINKRAY_SCALE_WATER
	inst.Transform:SetScale(inst.scale_water, inst.scale_water, inst.scale_water)

	MakeGhostPhysics(inst, 1, .5)
	inst.Physics:CollidesWith(COLLISION.LIMITS)

	inst.AnimState:SetBank("stinkray")
	inst.AnimState:SetBuild("stinkray")

	inst:AddTag("monster")
	inst:AddTag("hostile")
	inst:AddTag("stungray")
	inst:AddTag("scarytoprey")
	inst:AddTag("flying")
	inst:AddTag("poisonimmune")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("locomotor")
	inst.components.locomotor:SetSlowMultiplier(1)
	inst.components.locomotor:SetTriggersCreep(false)
	inst.components.locomotor.walkspeed = TUNING.STINKRAY_WALK_SPEED
	inst.components.locomotor.pathcaps = {allowocean = true, ignorecreep = true}

    inst:AddComponent("drydrownable")
    inst.components.drydrownable.break_period = 5
    inst.components.drydrownable.allow_boats = true

	inst:AddComponent("eater")
	inst.components.eater:SetCarnivore()
	inst.components.eater.strongstomach = true

	inst:AddComponent("sleeper")
	inst.components.sleeper:SetResistance(2)
	inst.components.sleeper:SetNocturnal(true)
	inst.components.sleeper.onlysleepsfromitems = true

	inst:AddComponent("combat")
	inst.components.combat.hiteffectsymbol = "bat_body"
	inst.components.combat:SetAttackPeriod(TUNING.STINKRAY_ATTACK_PERIOD)
	inst.components.combat:SetRange(TUNING.STINKRAY_ATTACK_DIST)
	inst.components.combat:SetRetargetFunction(3, Retarget)
	inst.components.combat:SetKeepTargetFunction(KeepTarget)
	inst.components.combat.poisonous = true
	inst.components.combat.gasattack = true
	inst.components.combat.onhitotherfn = OnHitOther
	inst.components.combat:SetDefaultDamage(0)

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.STINKRAY_HEALTH)

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:AddRandomLoot("venomgland", 1)
	inst.components.lootdropper:AddRandomLoot("monstermeat", 2)
	inst.components.lootdropper.numrandomloot = 1

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.canbepickedup = false

	inst:AddComponent("inspectable")

    MakeHauntablePanic(inst)

	inst:AddComponent("knownlocations")

	inst:DoTaskInTime(FRAMES, function() inst.components.knownlocations:RememberLocation("home", inst:GetPosition(), true) end)

	inst:AddComponent("teamattacker")
	inst.components.teamattacker.team_type = "stungray"
	inst.components.teamattacker.run = true

	inst:ListenForEvent("attacked", OnAttacked)
	inst:ListenForEvent("newcombattarget", OnCombatTarget)
	inst:ListenForEvent("losttarget", OnCombatTarget)

	SetLocoState(inst, "swim")
	inst.SetLocoState = SetLocoState
	inst.IsLocoState = IsLocoState

	inst:SetStateGraph("SGstungray")
	inst:SetBrain(brain)

    MakeHauntablePanic(inst)
    MakeAreaPoisoner(inst, 3)
	MakeMediumBurnableCharacter(inst, "ray_face")
	MakeMediumFreezableCharacter(inst, "ray_face")

	return inst
end

return Prefab("stungray", fn, assets, prefabs)
