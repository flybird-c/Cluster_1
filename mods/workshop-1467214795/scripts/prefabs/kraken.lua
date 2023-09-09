local assets =
{
    Asset("ANIM", "anim/quacken.zip"),
    Asset("ANIM", "anim/quacken_yule.zip"),
    Asset("ANIM", "anim/quacken_yule_fx.zip"),
}

local prefabs =
{
    "kraken_tentacle",
    "kraken_projectile",
    "kraken_inkpatch",
    "krakenchest",
    "chesspiece_kraken_sketch",
}

SetSharedLootTable('kraken',
{
    {"piratepack", 1.00},
    {"chesspiece_kraken_sketch", 1.00},
})

local PHASE_HEALTH =
{
    0.75,
    0.50,
    0.25,
    -1.0,
}

local brain = require("brains/krakenbrain")

local function MoveToNewSpot(inst)
    local width, height = TheWorld.Map:GetWorldSize()
    local krakener = TheWorld.components.krakener
    local pos = inst:GetPosition()
    local new_pos = pos

    for i = 1, 500 do
        local offset = FindSwimmableOffset(pos, math.pi * 2 * math.random(), 40, 30)
        if offset then
            new_pos = pos + offset
            local x, y = TheWorld.Map:GetTileCoordsAtPoint(new_pos:Get())
            if (not krakener or krakener:CheckTileCompatibility(new_pos)) and GetDistFromEdge(x, y, width, height) >= 15 then
                break
            end
        end
    end

    inst:PushEvent("move", {pos = new_pos})
end

local function EnterPhaseTrigger(inst)
    if inst.components.health:GetPercent() <= PHASE_HEALTH[inst.health_stage] then
        inst.components.health:SetPercent(PHASE_HEALTH[inst.health_stage])
        inst.health_stage = inst.health_stage + 1
        inst.health_stage = math.min(inst.health_stage, #PHASE_HEALTH)
        MoveToNewSpot(inst)
    end
end

local RETARGET_CANT_TAGS = {"prey"}
local RETARGET_ONOF_TAGS = {"character", "monster", "animal"}
local function RetargetFn(inst)
    return FindEntity(inst, 40, function(guy)
        if guy.components.combat and guy.components.health and not guy.components.health:IsDead() then
            return not (guy.prefab == inst.prefab)
        end
    end, nil, RETARGET_CANT_TAGS, RETARGET_ONOF_TAGS)
end

local function ShouldKeepTarget(inst, target)
    if target and target:IsValid() and target.components.health and not target.components.health:IsDead() then
        local distsq = target:GetDistanceSqToInst(inst)
        return distsq < 1600
    else
        return false
    end
end

local function teleport_override_fn(inst)
    return inst:GetPosition()
end

local RND_OFFSET = 10
local function OnAttack(inst, data)
    local numshots = TUNING.QUACKEN_PROJECTILE_COUNT

    if data.target then
        for i = 1, numshots do
            local offset = Vector3(math.random(-RND_OFFSET, RND_OFFSET), math.random(-RND_OFFSET, RND_OFFSET), math.random(-RND_OFFSET, RND_OFFSET))
            inst.components.thrower:Throw(data.target:GetPosition() + offset)
        end
    end
end

local function SpawnChest(inst)
    inst:DoTaskInTime(3, function()
        if not inst.components.health:IsDead() then  -- Prevention of mistaken death
            return
        end

        inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")

        local chest = SpawnPrefab("krakenchest")
        local x, y, z = inst.Transform:GetWorldPosition()
        chest.Transform:SetPosition(x, 0, z)

        local fx = SpawnPrefab("statue_transition_2")
        fx.Transform:SetPosition(x, y, z)
        fx.Transform:SetScale(1, 2, 1)

        fx = SpawnPrefab("statue_transition")
        fx.Transform:SetPosition(x, y, z)
        fx.Transform:SetScale(1, 1.5, 1)

        chest:AddComponent("scenariorunner")
        chest.components.scenariorunner:SetScript("chest_kraken")
        chest.components.scenariorunner:Run()
    end)
end

local function OnRemove(inst)
    inst.components.minionspawner:DespawnAll()
end

local function OnSave(inst, data)
    data.health_stage = inst.health_stage
end

local function OnLoad(inst, data)
    if data and data.health_stage then
        inst.health_stage = data.health_stage
    end
end

------------------------minionspawner change--------------------------
local function AddPosition(self, num)
    table.insert(self.freepositions, num)
    table.sort(self.freepositions)
end

local function OnLostMinion(self, minion)
    if self.minions[minion] == nil then
        return
    end

    self:AddPosition(minion.minionnumber)

    self.minions[minion] = nil
    self.numminions = self.numminions - 1

    self.inst:RemoveEventCallback("attacked", self._onminionattacked, minion)
    self.inst:RemoveEventCallback("onattackother", self._onminionattack, minion)
    self.inst:RemoveEventCallback("death", self._onminiondeath, minion)
    self.inst:RemoveEventCallback("onremove", self._onminionremoved, minion)

    self.inst:PushEvent("minionchange")
end

local function generatefreepositions(max)
    local pos_table = {}
    for num = 1, max do
        table.insert(pos_table, num)
    end
    return pos_table
end

local POS_MODIFIER = 1.2
local function MakeSpawnLocations(self)
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local ground = TheWorld
    local maxpositions = self.maxminions * POS_MODIFIER
    local useablepositions = {}
    for i = 1, 100 do
        local s = i / 32 -- (num / 2) -- 32.0
        local a = math.sqrt(s * 512)
        local b = math.sqrt(s) * self.distancemodifier
        local pos = Vector3(x + math.sin(a) * b, 0, z + math.cos(a) * b)
        if ground.Map:IsAboveGroundAtPoint(pos.x, pos.y, pos.z, true) and
            self:CheckTileCompatibility(ground.Map:GetTileAtPoint(pos:Get())) and
            ground.Pathfinder:IsClear(x, 0, z, pos.x, 0, pos.z, {ignorewalls = true , allowocean = true}) and
            #TheSim:FindEntities(pos.x, pos.y, pos.z, 1) <= 0 and
            not ground.Map:IsPointNearHole(pos) then
            table.insert(useablepositions, pos)
            if #useablepositions >= maxpositions then
                return useablepositions
            end
        end
    end

    -- if it couldn't find enough spots for minions.
    self.maxminions = #useablepositions
    self.freepositions = generatefreepositions(self.maxminions)

    return #useablepositions > 0 and useablepositions or nil
end

local function SpawnNewMinion(self, force)
    if self.minionpositions == nil then
        self.minionpositions = self:MakeSpawnLocations()
        if self.minionpositions == nil then
            return
        end
    end

    if (force or self.shouldspawn) and not self:MaxedMinions() and #self.freepositions > 0 then
        self.spawninprogress = false

        local num = self.freepositions[math.random(#self.freepositions)]
        local pos = self:GetSpawnLocation(num)
        if pos ~= nil then
            local minion = self:MakeMinion()
            if minion ~= nil then
                minion.sg:GoToState("spawn")
                minion.minionnumber = num
                self:TakeOwnership(minion)
                minion.Transform:SetPosition(pos:Get())
                self:RemovePosition(num)

                if self.onspawnminionfn ~= nil then
                    self.onspawnminionfn(self.inst, minion)
                end
            end
        elseif self.miniontype ~= nil and not self:MaxedMinions() then
            self.minionpositions = self:MakeSpawnLocations()
        end

        if (force or self.shouldspawn) and not self:MaxedMinions() then
            self:StartNextSpawn()
        end
    end
end
-----------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("quacken.tex")
    inst.MiniMapEntity:SetPriority(4)

    MakeCharacterPhysics(inst, 1000, 1)

    inst.AnimState:SetBank("quacken")

    if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
        inst.AnimState:OverrideSymbol("pupil", "quacken", "")
        inst.AnimState:SetBuild("quacken_yule")
        inst.AnimState:AddOverrideBuild("quacken_yule_fx")

        inst.entity:AddLight()
        inst.Light:SetFalloff(3)
        inst.Light:SetColour(1, 0, 0)
    else
        inst.AnimState:SetBuild("quacken")
    end

    inst.AnimState:PlayAnimation("idle_loop", true)

    inst:AddTag("kraken")
    inst:AddTag("epic")
    inst:AddTag("animal")
    inst:AddTag("scarytoprey")
    inst:AddTag("hostile")
    inst:AddTag("largecreature")
    inst:AddTag("birdblocker")
    inst:AddTag("nowaves")

    if not TheNet:IsDedicated() then
        inst:DoTaskInTime(1, function()
            if inst:IsNear(ThePlayer, 60) then
                ThePlayer:PushEvent("KrakenEncounter")  --for danger music on Kraken spawn
            end
        end)
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.health_stage = 1

    inst:AddComponent("inspectable")
    inst:AddComponent("locomotor")
    inst:AddComponent("sanityaura")

    inst:AddComponent("rechargeable")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.QUACKEN_HEALTH)
    inst.components.health.nofadeout = true

    inst:AddComponent("healthtrigger")
    for _, phase_health in ipairs(PHASE_HEALTH) do
        inst.components.healthtrigger:AddTrigger(phase_health, EnterPhaseTrigger)
    end

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(0)
    inst.components.combat:SetAttackPeriod(TUNING.QUACKEN_ATTACK_PERIOD)
    inst.components.combat:SetRange(40, 50)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('kraken')
    if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
        inst.components.lootdropper:AddChanceLoot("winter_ornament_light1", 1)
        inst.components.lootdropper:AddChanceLoot("winter_ornament_light1", 1)
        inst.components.lootdropper:AddChanceLoot("winter_ornament_light1", 1)
        inst.components.lootdropper:AddChanceLoot("winter_ornament_boss_kraken_tentacle", 1)
    end

    inst:AddComponent("thrower")
    inst.components.thrower.throwable_prefab = "kraken_projectile"

    inst:AddComponent("teleportedoverride")
    inst.components.teleportedoverride:SetDestPositionFn(teleport_override_fn)

    inst:AddComponent("minionspawner")
    inst.components.minionspawner.validtiletypes = {
        [WORLD_TILES.OCEAN_SHALLOW] = true,
        [WORLD_TILES.OCEAN_MEDIUM] = true,
        [WORLD_TILES.OCEAN_DEEP] = true,
        [WORLD_TILES.OCEAN_CORAL] = true,
        [WORLD_TILES.MANGROVE] = true,
        [WORLD_TILES.OCEAN_SHIPGRAVEYARD] = true
    }
    inst.components.minionspawner.shouldspawn = false
    inst.components.minionspawner.miniontype = "kraken_tentacle"
    inst.components.minionspawner.distancemodifier = TUNING.QUACKEN_TENTACLE_DIST_MOD
    inst.components.minionspawner.maxminions = TUNING.QUACKEN_MAXTENTACLES
    inst.components.minionspawner._onminionremoved = inst.components.minionspawner._onminiondeath
    inst.components.minionspawner.AddPosition = AddPosition
    inst.components.minionspawner.OnLostMinion = OnLostMinion
    inst.components.minionspawner.SpawnNewMinion = SpawnNewMinion
    inst.components.minionspawner.MakeSpawnLocations = MakeSpawnLocations
    inst.components.minionspawner:RegenerateFreePositions()

    inst:SetStateGraph("SGkraken")
    inst:SetBrain(brain)

    inst:ListenForEvent("onattackother", OnAttack)
    inst:ListenForEvent("death", SpawnChest)
    inst:ListenForEvent("onremove", OnRemove)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("kraken", fn, assets, prefabs)
