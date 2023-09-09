
local LAUNCH_SPEED = .2
local RADIUS = .7

local function SetLightRadius(inst, radius)
    inst.Light:SetRadius(radius)
end

local function DisableLight(inst)
    inst.Light:Enable(false)
end

local DAMAGE_CANT_TAGS = {"playerghost", "INLIMBO", --[["NOCLICK",]] "DECOR", "INLIMBO"}
local DAMAGE_ONEOF_TAGS = {"_combat", "pickable", "NPC_workable", "CHOP_workable", "HAMMER_workable", "MINE_workable", "DIG_workable"}
local LAUNCH_MUST_TAGS = {"_inventoryitem"}
local LAUNCH_CANT_TAGS = {"locomotor", "INLIMBO"}

local function DoDamage(inst, targets, skiptoss)
    inst.task = nil

    local x, y, z = inst.Transform:GetWorldPosition()
    if inst.AnimState ~= nil then
        inst.AnimState:PlayAnimation("hit_" .. tostring(math.random(5)))
        inst:Show()
        inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, inst.Remove)

        inst.Light:Enable(true)
        inst:DoTaskInTime(4 * FRAMES, SetLightRadius, .5)
        inst:DoTaskInTime(5 * FRAMES, DisableLight)

        -- local wave_fx = SpawnPrefab("crab_king_waterspout")
        -- wave_fx.Transform:SetScale(1, 0.5, 1)
        -- wave_fx.Transform:SetPosition(x, 0, z)

        local fx = SpawnPrefab("deerclops_lasertrail")
        fx.Transform:SetPosition(x, 0, z)
        fx:FastForward(GetRandomMinMax(.3, .7))
    else
        inst:DoTaskInTime(2 * FRAMES, inst.Remove)
    end

    inst.components.combat.ignorehitrange = true
    for i, v in ipairs(TheSim:FindEntities(x, 0, z, RADIUS + 3, nil, DAMAGE_CANT_TAGS, DAMAGE_ONEOF_TAGS)) do
        if not targets[v] and v:IsValid() and not v:IsInLimbo() and not (v.components.health ~= nil and v.components.health:IsDead()) then
            local vradius = v:GetPhysicsRadius(.5)
            local range = RADIUS + vradius
            if v:GetDistanceSqToPoint(x, y, z) < range * range then
                local isworkable = false
                if v.components.workable ~= nil then
                    local work_action = v.components.workable:GetWorkAction()
                    --V2C: nil action for NPC_workable (e.g. campfires)
                    isworkable =
                        (   work_action == nil and v:HasTag("NPC_workable") ) or
                        (   v.components.workable:CanBeWorked() and
                            (   work_action == ACTIONS.CHOP or
                                work_action == ACTIONS.HAMMER or
                                work_action == ACTIONS.MINE or
                                (   work_action == ACTIONS.DIG and
                                    v.components.spawner == nil and
                                    v.components.childspawner == nil
                                )
                            )
                        )
                end
                if isworkable then
                    targets[v] = true
                    v.components.workable:Destroy(inst)
                    if v:IsValid() and v:HasTag("stump") then
                        v:Remove()
                    end
                elseif v.components.pickable ~= nil
                    and v.components.pickable:CanBePicked()
                    and not v:HasTag("intense") then
                    targets[v] = true
                    local num = v.components.pickable.numtoharvest or 1
                    local product = v.components.pickable.product
                    local x1, y1, z1 = v.Transform:GetWorldPosition()
                    v.components.pickable:Pick(inst) -- only calling this to trigger callbacks on the object
                    if product ~= nil and num > 0 then
                        for i = 1, num do
                            local loot = SpawnPrefab(product)
                            loot.Transform:SetPosition(x1, 0, z1)
                            skiptoss[loot] = true
                            targets[loot] = true
                            Launch(loot, inst, LAUNCH_SPEED)
                        end
                    end
                elseif inst.components.combat:CanTarget(v) and not v:HasTag("kraken_tentacle") then
                    targets[v] = true
                    if inst.caster ~= nil and inst.caster:IsValid() then
                        inst.caster.components.combat.ignorehitrange = true
                        inst.caster.components.combat:DoAttack(v)
                        inst.caster.components.combat.ignorehitrange = false
                    else
                        inst.components.combat:DoAttack(v)
                    end
                    if v:IsValid() then
                        SpawnPrefab("deerclops_laserhit"):SetTarget(v)
                        if not v.components.health:IsDead() then
                            if v.components.freezable ~= nil then
                                if v.components.freezable:IsFrozen() then
                                    v.components.freezable:Unfreeze()
                                elseif v.components.freezable.coldness > 0 then
                                    v.components.freezable:AddColdness(-2)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    inst.components.combat.ignorehitrange = false
    for i, v in ipairs(TheSim:FindEntities(x, 0, z, RADIUS + 3, LAUNCH_MUST_TAGS, LAUNCH_CANT_TAGS)) do
        if not skiptoss[v] then
            local range = RADIUS + v:GetPhysicsRadius(.5)
            if v:GetDistanceSqToPoint(x, y, z) < range * range then
                if v.components.mine ~= nil then
                    targets[v] = true
                    skiptoss[v] = true
                    v.components.mine:Deactivate()
                end
                if not v.components.inventoryitem.nobounce and v.Physics ~= nil and v.Physics:IsActive() then
                    targets[v] = true
                    skiptoss[v] = true
                    Launch(v, inst, LAUNCH_SPEED)
                end
            end
        end
    end
end

local function Trigger(inst, delay, targets, skiptoss)
    if inst.task ~= nil then
        inst.task:Cancel()
        if (delay or 0) > 0 then
            inst.task = inst:DoTaskInTime(delay, DoDamage, targets or {}, skiptoss or {})
        else
            DoDamage(inst, targets or {}, skiptoss or {})
        end
    end
end

local function makelaser(name)
    local function fn()
        local inst = Prefabs["deerclops_" .. name].fn()

        inst:SetPrefabNameOverride("kraken")

        if not TheWorld.ismastersim then
            return inst
        end

        if inst.components.combat then
            inst.components.combat:SetDefaultDamage(TUNING.QUACKEN_TENTACLE_DAMAGE)
        end

        inst.Trigger = Trigger

        return inst
    end

    return Prefab("kraken_" .. name, fn, Prefabs["deerclops_" .. name].assets)
end

return makelaser("laser"),
    makelaser("laserempty")
