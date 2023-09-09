local assets=
{
  Asset("ANIM", "anim/coconut_cannon.zip"),
}

local prefabs = 
{
  "small_puff_light",
  "coconut_chunks",
  "bombsplash",
}

local FINDSNAKE_MUST_TAGS = { "snake" }
local function CanSpawnSnakes(pos)
    return #TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.TREEGUARD_SNAKE_DENSITY_RANGE, FINDSNAKE_MUST_TAGS) < TUNING.TREEGUARD_SNAKE_MAX_DENSITY
end

local function onhit(inst) --, thrower, target)
	local pos = inst:GetPosition()
	local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 1.5, nil, inst.noTags)

	for k,v in pairs(ents) do
		if v.components.combat and v ~= inst and not v:HasTag("leif") then
			v.components.combat:GetAttacked(inst.thrower, inst.damage)
		end
	end

	if IsOnOcean(inst) then
		SpawnAt("bombsplash", pos)
		inst.SoundEmitter:PlaySound("ia/common/cannon_impact")
		inst.SoundEmitter:PlaySound("ia/creatures/seacreature_movement/splash_large")
	elseif inst.spawnprefabfn ~= nil then
		inst.spawnprefabfn(inst, inst.target, pos)
	end

	inst:Remove()
end

local function trackheight(inst)
	if inst:GetPosition().y < 0.3 then
		onhit(inst)
	end
end

local function onthrown(inst, thrower, pt, time_to_target)
	inst.Physics:SetFriction(.2)
	inst.Transform:SetFourFaced()
	inst:FacePoint(pt:Get())
	inst.AnimState:PlayAnimation("throw", true)

	local shadow = SpawnPrefab("warningshadow")
	shadow.Transform:SetPosition(pt:Get())
	shadow:shrink(time_to_target, 1.75, 0.5)
	
	inst.thrower = thrower
	inst.TrackHeight = inst:DoPeriodicTask(.1, trackheight)
end

local function onremove(inst)
	if inst.TrackHeight then
		inst.TrackHeight:Cancel()
		inst.TrackHeight = nil
	end
end

local function SpawnCoconut(inst, target, pos)
	SpawnAt("small_puff_light", pos)
	if math.random() < 0.05 then
		SpawnAt("coconut", pos)
	else
		SpawnAt("coconut_chunks", pos)
	end
end

local function SpawnBanana(inst, target, pos)
	if math.random() < 0.05 then
		local banana = SpawnAt("cave_banana", pos)
		if banana.components.visualvariant ~= nil then
			banana.components.visualvariant:CopyOf(inst)
		end
	else
		SpawnAt("banana_splat", pos)
	end
end

local function SpawnSnake(inst, target, pos)
	local snake = SpawnAt("snake", pos)

	if math.random() < 0.05 or not CanSpawnSnakes(pos) then
		if snake.components.health then
			snake.components.health:Kill()
		end
	else
		if snake.components.combat then
			snake.components.combat:SuggestTarget(target)
		end
	end
end

local function SpawnSnakePoison(inst, target, pos)
	local snake = SpawnAt("snake_poison", pos)

	if math.random() < 0.05 or not CanSpawnSnakes(pos) then
		if snake.components.health then
			snake.components.health:Kill()
		end
	else
		if snake.components.combat then
			snake.components.combat:SuggestTarget(target)
		end
	end
end

local function common_fn(swap)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("coconut_cannon")
	inst.AnimState:SetBuild("coconut_cannon")
	inst.AnimState:PlayAnimation("throw", true)

	if type(swap) == "table" then
		inst.AnimState:OverrideSymbol("coconut_cannon01", swap[1], swap[2])
	end

	inst:AddTag("thrown")
	inst:AddTag("projectile")

	inst.noTags = {"FX", "DECOR", "INLIMBO", "shadow"}

	inst.persists = false
	
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("throwable")
	inst.components.throwable.onthrown = onthrown
	inst.components.throwable.random_angle = 0
	inst.components.throwable.max_y = 50
	inst.components.throwable.yOffset = 3
	
	inst.OnRemoveEntity = onremove
	
	-- inst:AddComponent("complexprojectile")
	-- inst.components.complexprojectile:SetHorizontalSpeed(10)
	-- -- inst.components.complexprojectile:SetGravity(-35)
	-- inst.components.complexprojectile:SetLaunchOffset(Vector3(0, 3, 0))
	-- inst.components.complexprojectile:SetOnLaunch(onthrown)
	-- inst.components.complexprojectile:SetOnHit(onhit)

	return inst
end

local function coconut_fn()
	local inst = common_fn()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.damage = TUNING.PALMTREEGUARD_COCONUT_DAMAGE
	inst.spawnprefabfn = SpawnCoconut

	return inst
end

local function banana_fn()
	local inst = common_fn({"jungleTreeGuard_build", "banana_cannon01"})

	if not TheWorld.ismastersim then
		return inst
	end

	inst.damage = TUNING.JUNGLETREEGUARD_COCONUT_DAMAGE
	inst.spawnprefabfn = SpawnBanana

	return inst
end

local function snake_fn()
	local inst = common_fn({"jungleTreeGuard_build", "snake_cannon01"})

	if not TheWorld.ismastersim then
		return inst
	end

	inst.damage = TUNING.JUNGLETREEGUARD_COCONUT_DAMAGE
	inst.spawnprefabfn = SpawnSnake

	return inst
end

local function snake_poison_fn()
	local inst = common_fn({"jungleTreeGuard_build", "snakepoison_cannon01"})

	if not TheWorld.ismastersim then
		return inst
	end

	inst.damage = TUNING.JUNGLETREEGUARD_COCONUT_DAMAGE
	inst.spawnprefabfn = SpawnSnakePoison

	return inst
end

return Prefab("treeguard_coconut", coconut_fn, assets, prefabs),
	Prefab("treeguard_banana", banana_fn, assets, prefabs),
	Prefab("treeguard_snake", snake_fn, assets, prefabs),
	Prefab("treeguard_snake_poison", snake_poison_fn, assets, prefabs)
