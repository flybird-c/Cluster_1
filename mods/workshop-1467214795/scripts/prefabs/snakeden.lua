local assets=
{
  Asset("ANIM", "anim/bush_vine.zip"),
}


local prefabs =
{
  "vine",
  "dug_bush_vine",
  "hacking_fx",
  "snake_poison",
  "snake",
}

local onshake

local function stopshaking(inst)
    if inst.shaketask then
        inst.shaketask:Cancel()
        inst.shaketask = nil
    end
end

local function startshaking(inst)
    stopshaking(inst)
    inst.shaketask = inst:DoTaskInTime(5+(math.random()*2), onshake)
end

local function spawnsnake(inst, target)

    if math.random() < TUNING.SNAKE_POISON_CHANCE and TheWorld.state.cycles >= TUNING.SNAKE_POISON_START_DAY then
        inst.components.childspawner.childname = "snake_poison"
    else
        inst.components.childspawner.childname = "snake"
    end

    local snake = inst.components.childspawner:SpawnChild()
    if snake then
        local spawnpos = inst:GetPosition()
        spawnpos = spawnpos + TheCamera:GetDownVec()
        snake.Transform:SetPosition(spawnpos:Get())
        if snake and target and snake.components.combat then
        snake.components.combat:SetTarget(target)
        end
    end

    return snake
end

local function ontransplantfn(inst)
    if inst.components.hackable then
        inst.components.hackable:MakeBarren()
    end
end

local function dig_up(inst, chopper)
    if inst.components.hackable and inst.components.hackable:CanBeHacked() then
        inst.components.lootdropper:SpawnLootPrefab("vine")
    end
    if inst.components.hackable and not inst.components.hackable.withered then
        inst.components.lootdropper:SpawnLootPrefab("dug_bush_vine")
        inst.components.lootdropper:SpawnLootPrefab("snakeskin")
    else
        inst.components.lootdropper:SpawnLootPrefab("vine")
    end
    inst:Remove()
end

local function onregenfn(inst)
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle", true)
    inst.Physics:SetCollides(true)
end

local function makeemptyfn(inst)
    if inst.components.hackable and inst.components.hackable.withered then
        inst.AnimState:PlayAnimation("dead_to_empty")
        inst.AnimState:PushAnimation("hacked_idle")
    else
        inst.AnimState:PlayAnimation("hacked_idle")
    end
    inst.Physics:SetCollides(false)

    inst.EvacuateAllChildren(inst)
end

local function makebarrenfn(inst)
    if inst.components.hackable and inst.components.hackable.withered then
        if not inst.components.hackable.hasbeenhacked then
        inst.AnimState:PlayAnimation("full_to_dead")
        else
        inst.AnimState:PlayAnimation("empty_to_dead")
        end
        inst.AnimState:PushAnimation("idle_dead")
    else
        inst.AnimState:PlayAnimation("idle_dead")
    end
    inst.Physics:SetCollides(true)

    inst.EvacuateAllChildren(inst)
end


local function onhackedfn(inst, hacker, hacksleft)
    local fx = SpawnPrefab("hacking_fx")
    local x, y, z= inst.Transform:GetWorldPosition()
    fx.Transform:SetPosition(x,y + math.random()*2,z)

    if(hacksleft <= 0) then

        inst.AnimState:PlayAnimation("disappear")

        if inst.components.hackable and inst.components.hackable:IsBarren() then
        inst.AnimState:PushAnimation("idle_dead")
        inst.Physics:SetCollides(true)
        else
        inst.Physics:SetCollides(false)
        inst.SoundEmitter:PlaySound("ia/common/vine_drop")
        inst.AnimState:PushAnimation("hacked_idle")
        end
    else
        inst.SoundEmitter:PlaySound("ia/common/vine_hack")
        inst.AnimState:PlayAnimation("chop")
        inst.AnimState:PushAnimation("idle")
    end

    spawnsnake(inst, hacker)
end

local function startspawning(inst)
    if inst.components.childspawner then
        local frozen = (inst.components.freezable and inst.components.freezable:IsFrozen())
        if not frozen and not TheWorld.state.isday then
        inst.components.childspawner:StartSpawning()
        end
    end
end

local function stopspawning(inst)
    if inst.components.childspawner then
        inst.components.childspawner:StopSpawning()
    end
end

onshake = function (inst)
    if inst.components.hackable and not inst.components.hackable.withered and not inst.components.hackable.hasbeenhacked and inst.components.hackable.hacksleft > 0 then

        inst.SoundEmitter:PlaySound("ia/creatures/snake/snake_bush")
        inst.AnimState:PlayAnimation("rustle_snake", false)
        inst.AnimState:PushAnimation("idle", true)

        startshaking(inst)
    end
end

local function onspawnsnake(inst)
    if inst:IsValid() and inst.components.hackable and inst.components.hackable.hacksleft > 0 then
        inst.SoundEmitter:PlaySound("ia/creatures/snake/snake_bush")
        inst.AnimState:PlayAnimation("rustle", false)
        inst.AnimState:PushAnimation("idle", true)
    end
end

local function SpawnDefenders(inst, target)
    if inst.components.childspawner.childreninside > 0 then
        for i=1,inst.components.childspawner.childreninside do
        local snake = spawnsnake(inst)
            if snake and snake.components.combat and target then
                snake.components.combat:SetTarget(target)
                snake.components.combat:BlankOutAttacks(1.5 + math.random() * 2)
            end
        end
    end
end

local function onwake(inst)
    startshaking(inst)
end

local function onsleep(inst)
    stopshaking(inst)
end

local function onremove(inst)
    stopshaking(inst)
end

local function onplayernear(inst, player)
    if inst.components.hackable and not inst.components.hackable.withered and not inst.components.hackable.hasbeenhacked and inst.components.hackable.hacksleft > 0 then
        stopshaking(inst)
        spawnsnake(inst, player)
    end
end

local function onplayerfar(inst)
    if inst.components.hackable and not inst.components.hackable.withered and not inst.components.hackable.hasbeenhacked and inst.components.hackable.hacksleft > 0 then
        startshaking(inst)
    end
end

local function inspect_vine(inst)
    if inst:HasTag("burnt") then
        return "BURNT"
    elseif inst:HasTag("stump") then
        return "CHOPPED"
    end
end

local function CanTarget(guy)
    return not guy.components.health:IsDead()
end

local function OnHaunt(inst)
    if math.random() <= TUNING.HAUNT_CHANCE_HALF then
        local target = FindEntity(
            inst,
            25,
            CanTarget,
            { "_combat", "_health", "character" }, --see entityreplica.lua
            { "player", "spider", "INLIMBO" }
        )
        if target ~= nil then
            SpawnDefenders(inst, target)
            inst.components.hauntable.hauntvalue = TUNING.HAUNT_MEDIUM
            return true
        end
    end

    return false
end

local function OnIgnite(inst)
    SpawnDefenders(inst)
    DefaultBurnFn(inst)
end

local function OnEvacuateAllChildren(inst)
    SpawnDefenders(inst)

    for k, v in pairs(inst.components.childspawner.childrenoutside) do
    if v.components.knownlocations then
        c.components.knownlocations:ForgetLocation("home")
    end

    self.inst:RemoveEventCallback("ontrapped", self._onchildkilled, v)
    self.inst:RemoveEventCallback("death", self._onchildkilled, v)
    self.inst:RemoveEventCallback("detachchild", self._onchildkilled, v)
    end

    inst.components.childspawner.childrenoutside = {}
end

local function OnIsDusk(inst)
    if inst.components.hackable and not inst.components.hackable.withered and not inst.components.hackable.hasbeenhacked and inst.components.hackable.hacksleft > 0 then
        startspawning(inst)
    end
end

local function OnIsDay(inst)
    if inst.components.hackable and not inst.components.hackable.withered and not inst.components.hackable.hasbeenhacked and inst.components.hackable.hacksleft > 0 then
        stopspawning(inst)
    end
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    local minimap = inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .35)

    minimap:SetIcon( "vinebush.tex" )

    inst.AnimState:SetBank("bush_vine")
    inst.AnimState:SetBuild("bush_vine")
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetTime(math.random()*2)
    local color = 0.75 + math.random() * 0.25
    inst.AnimState:SetMultColour(color, color, color, 1)

    inst:AddTag("vine")
    inst:AddTag("plant")
    inst:AddTag("silviculture") -- for silviculture book

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("hackable")
    inst.components.hackable:SetUp("vine", TUNING.VINE_REGROW_TIME)
    inst.components.hackable.onregenfn = onregenfn
    inst.components.hackable.onhackedfn = onhackedfn
    inst.components.hackable.makeemptyfn = makeemptyfn
    inst.components.hackable.makebarrenfn = makebarrenfn
    inst.components.hackable.max_cycles = 20
    inst.components.hackable.cycles_left = 20
    inst.components.hackable.ontransplantfn = ontransplantfn
    inst.components.hackable.hacksleft = TUNING.VINE_HACKS
    inst.components.hackable.maxhacks = TUNING.VINE_HACKS

    inst:AddComponent("lootdropper")
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = inspect_vine

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up)
    inst.components.workable:SetWorkLeft(1)

    MakeHackableBlowInWindGust(inst, TUNING.VINE_WINDBLOWN_SPEED, 0)

    MakeMediumBurnable(inst)
    inst.components.burnable:SetOnIgniteFn(OnIgnite)
    MakeSmallPropagator(inst)

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "snake"
    inst.components.childspawner:SetRegenPeriod(TUNING.SNAKEDEN_REGEN_TIME)
    inst.components.childspawner:SetSpawnPeriod(TUNING.SNAKEDEN_RELEASE_TIME)

    inst.components.childspawner:SetSpawnedFn(onspawnsnake)
    inst.components.childspawner:SetMaxChildren(TUNING.SNAKEDEN_MAX_SNAKES)
    --inst.components.childspawner:ScheduleNextSpawn(0)

    inst.EvacuateAllChildren = OnEvacuateAllChildren

    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(TUNING.SNAKEDEN_TRAP_DIST, TUNING.SNAKEDEN_CHECK_DIST)
    inst.components.playerprox:SetOnPlayerNear(onplayernear)
    inst.components.playerprox:SetOnPlayerFar(onplayerfar)
    inst.components.playerprox.period = math.random()*0.16+0.32 -- mix it up a little

    inst:AddComponent("hauntable")
    inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_MEDIUM
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst.OnEntityWake = onwake
    inst.OnEntitySleep = onsleep
    inst.OnRemoveEntity = onremove

    inst:WatchWorldState("isdusk", OnIsDusk)
    inst:WatchWorldState("isday", OnIsDay)

    return inst
end


return Prefab("snakeden", fn, assets, prefabs)
