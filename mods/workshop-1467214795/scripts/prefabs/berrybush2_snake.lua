local prefabs = {
    "berrybush2",
    "snake",
}

local function SpawnDiseasePuff(inst)
    SpawnPrefab("disease_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function setberries(inst, pct)
    if inst._setberriesonanimover then
        inst._setberriesonanimover = nil
        inst:RemoveEventCallback("animover", setberries)
    end

    local berries =
        (pct == nil and "") or
        (pct >= .9 and "berriesmost") or
        (pct >= .33 and "berriesmore") or
        "berries"

    for i, v in ipairs({ "berries", "berriesmore", "berriesmost" }) do
        if v == berries then
            inst.AnimState:Show(v)
        else
            inst.AnimState:Hide(v)
        end
    end
end

local function cancelsetberriesonanimover(inst)
    if inst._setberriesonanimover then
        setberries(inst, nil)
    end
end

local function shake(inst)
    if inst.components.pickable ~= nil and
        not inst.components.pickable:CanBePicked() and
        inst.components.pickable:IsBarren() then
        inst.AnimState:PlayAnimation("shake_dead")
        inst.AnimState:PushAnimation("dead", false)
    else
        inst.AnimState:PlayAnimation("shake")
        inst.AnimState:PushAnimation("idle")
    end
    cancelsetberriesonanimover(inst)
    inst.SoundEmitter:PlaySound("ia/creatures/snake/snake_bush")
end

local function spawn_snake(inst)
	local snake = SpawnPrefab("snake")
	local spawnpos = inst:GetPosition()
	local offset = FindWalkableOffset(spawnpos, math.random() * 2 * PI, 1, 8, true, false, IsPositionValidForEnt(inst, 2))
	spawnpos = offset ~= nil and spawnpos + offset or spawnpos
	snake.Transform:SetPosition(spawnpos:Get())
end

local function check_spawn_snake(inst)
    if inst:IsValid() then
        local distsq = inst:GetDistanceSqToClosestPlayer()

        if distsq < 4 then
            if math.random() > 0.75 then
				spawn_snake(inst)
                shake(inst)
            end
        end

        inst:DoTaskInTime(5+(math.random()*2), check_spawn_snake)
    end
end

local function OnHaunt(inst)
    shake(inst)
    if math.random() <= TUNING.HAUNT_CHANCE_RARE then
		spawn_snake(inst)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_COOLDOWN_LARGE
	else
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_COOLDOWN_TINY
    end
    return true
end

local function fn()
	local inst = Prefabs["berrybush2"].fn()
	
	if not inst.SoundEmitter then inst.entity:AddSoundEmitter() end

    inst.realprefab = "berrybush2_snake"

    inst:SetPrefabName("berrybush2")

	if not TheWorld.ismastersim then
		return inst
	end

    inst:DoTaskInTime(5+(math.random()*2), check_spawn_snake)

	AddHauntableCustomReaction(inst, OnHaunt, false, false, true)
	
	return inst
end


return Prefab("berrybush2_snake", fn, nil, prefabs)
