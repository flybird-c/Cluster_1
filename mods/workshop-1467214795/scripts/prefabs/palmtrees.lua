local assets =
{
    Asset("ANIM", "anim/ia_palmtree_build.zip"),
    Asset("ANIM", "anim/ia_palmtree_normal.zip"),
    Asset("ANIM", "anim/ia_palmtree_short.zip"),
    Asset("ANIM", "anim/ia_palmtree_tall.zip"),
    Asset("ANIM", "anim/cavein_dust_fx.zip"),
    Asset("SOUND", "sound/forest.fsb"),
}

local prefabs =
{
    "charcoal",
    "log",
    "leif_palm",
    "pine_needles_chop",
    "palmleaf",
    "coconut",
}

local function makeanims(stage)
    return {
        idle="idle_" .. stage,
        sway1="sway1_loop_" .. stage,
        sway2="sway2_loop_" .. stage,
        chop="chop_" .. stage,
        fallleft="fallleft_" .. stage,
        fallright="fallright_" .. stage,
        stump="stump_" .. stage,
        burning="burning_loop_" .. stage,
        burnt="burnt_" .. stage,
        chop_burnt="chop_burnt_" .. stage,
        idle_chop_burnt="idle_chop_burnt_" .. stage,
        blown1="blown_loop_" .. stage .. "1",
        blown2="blown_loop_" .. stage .. "2",
        blown_pre="blown_pre_" .. stage,
        blown_pst="blown_pst_" .. stage
    }
end

local SHORT = "short"
local NORMAL = "normal"
local TALL = "tall"

local anims = {
    [SHORT] = makeanims(SHORT),
    [TALL] = makeanims(TALL),
    [NORMAL] = makeanims(NORMAL),
}

SetSharedLootTable("palmtree_short",
{
    {"log", 1.0},
    {"palmleaf", 1.0},
})

SetSharedLootTable("palmtree_normal",
{
    {"log", 1.0},
    {"log", 1.0},
    {"palmleaf", 1.0},
})

SetSharedLootTable("palmtree_tall",
{
    {"log", 1.0},
    {"log", 1.0},
    {"coconut", 1.0},
    {"coconut", 0.33},
    {"palmleaf", 1.0},

})

local function on_pinecone_task(inst)
    local pt = inst:GetPosition()
    local angle = math.random() * 2 * PI
    pt.x = pt.x + math.cos(angle)
    pt.z = pt.z + math.sin(angle)
    inst.components.lootdropper:DropLoot(pt)
    inst.pineconetask = nil
    inst.burntpinecone = true
end

-- For chopping down a tree that's been burnt.
local function chop_down_burnt(inst, chopper)
    inst:RemoveComponent("workable")

    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
    end

    inst.AnimState:PlayAnimation(anims[inst.size].chop_burnt)

    RemovePhysicsColliders(inst)

    inst:ListenForEvent("animover", inst.Remove)

    inst.components.lootdropper:DropLoot()

    inst.components.lootdropper:SpawnLootPrefab("charcoal")
    inst.components.lootdropper:DropLoot()
    if inst.pineconetask then
        inst.pineconetask:Cancel()
        inst.pineconetask = nil
    end
end

local function on_haunt_work(inst, haunter)
    if inst.components.workable ~= nil and math.random() <= TUNING.HAUNT_CHANCE_OFTEN then
        inst.components.workable:WorkedBy(haunter, 1)
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_SMALL
        return true
    end
    return false
end

local function burnt_changes(inst)
    if inst.components.burnable ~= nil then
        inst.components.burnable:Extinguish()
    end

    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    inst:RemoveComponent("growable")
    inst:RemoveComponent("hauntable")
    inst:RemoveComponent("blowinwindgust")
    MakeHauntableWork(inst)

    inst:RemoveTag("shelter")
    inst:RemoveTag("gustable")

    inst.components.lootdropper:SetChanceLootTable(nil)

    if inst.components.workable then
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnWorkCallback(nil)
        inst.components.workable:SetOnFinishCallback(chop_down_burnt)
    end
end

local burnt_highlight_override = {.5,.5,.5}
local function tree_burnt_immediate_helper(inst, immediate)
    if immediate then
        burnt_changes(inst)
    else
        inst:DoTaskInTime(.5, burnt_changes)
    end

    inst.AnimState:PlayAnimation(anims[inst.size].burnt, true)
    inst.MiniMapEntity:SetIcon("palmtree_burnt.tex")

    inst.AnimState:SetRayTestOnBB(true)
    inst:AddTag("burnt")

    inst.highlight_override = burnt_highlight_override

    if inst.components.timer ~= nil and not inst.components.timer:TimerExists("decay") then
        inst.components.timer:StartTimer("decay", GetRandomWithVariance(TUNING.PALMTREE_REGROWTH.DEAD_DECAY_TIME, TUNING.PALMTREE_REGROWTH.DEAD_DECAY_TIME*0.5))
    end
end

local function on_tree_burnt(inst)
    tree_burnt_immediate_helper(inst)
    if not inst.burntpinecone then
        if inst.pineconetask ~= nil then
            inst.pineconetask:Cancel()
        end
        inst.pineconetask = inst:DoTaskInTime(10, on_pinecone_task)
    end
end

local function inspect_tree(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst:HasTag("stump") and "CHOPPED")
        or nil
end

local function WakeUpLeif(ent)
    ent.components.sleeper:WakeUp()
end

local SMASHABLE_TAGS = { "smashable", "_combat" }
local NON_SMASHABLE_TAGS = { "INLIMBO", "playerghost", "irreplaceable", "outofreach" }

local function grounddetection_update(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    if y < 2 then
        inst.fell = true
        inst.Physics:SetMotorVel(0,0,0)
    end

    if y <= 0.2 then
        if inst.shadow then
            inst.shadow:Remove()
        end

        local ents = TheSim:FindEntities(x, 0, z, 2, nil, NON_SMASHABLE_TAGS, SMASHABLE_TAGS)

        for k,v in pairs(ents) do
            if v and v.components.combat and v ~= inst then  -- quakes shouldn't break the set dressing
                v.components.combat:GetAttacked(inst, 20, nil)
            end
        end

        inst.Physics:SetDamping(0.9)

        if inst.updatetask then
            inst.updatetask:Cancel()
            inst.updatetask = nil
        end
    end

    -- Failsafe: if the entity has been alive for at least 1 second, hasn't changed height significantly since last tick, and isn't near the ground, remove it and its shadow
    if inst.last_y and y > 2 and inst.last_y > 2 and (inst.last_y - y  < 1) and inst:GetTimeAlive() > 1 and not inst.fell then
        inst:Remove()
    end
    inst.last_y = y
end

local LEIF_TAGS = {"leif"}
local function on_chop_tree(inst, chopper, chops_remaining, num_chops)
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound(
            chopper ~= nil and chopper:HasTag("beaver") and
            "dontstarve/characters/woodie/beaver_chop_tree" or
            "dontstarve/wilson/use_axe_tree"
        )
    end

    local anim_set = anims[inst.size]
    inst.AnimState:PlayAnimation(anim_set.chop)
    inst.AnimState:PushAnimation(anim_set.sway1, true)

    local x, y, z = inst.Transform:GetWorldPosition()

    local tree_fx = SpawnPrefab("pine_needles_chop")
    tree_fx.Transform:SetPosition(x, y + 2 + math.random() * 2, z)

    -- tell any nearby leifs to wake up
    local ents = TheSim:FindEntities(x, y, z, TUNING.LEIF_REAWAKEN_RADIUS, LEIF_TAGS)
    for i, v in ipairs(ents) do
        if v.components.sleeper ~= nil and v.components.sleeper:IsAsleep() then
            v:DoTaskInTime(math.random(), WakeUpLeif)
        end
        v.components.combat:SuggestTarget(chopper)
    end

    if inst.components.growable and inst.components.growable.stage == 3 then
        local chance = chopper:HasTag("mime") and TUNING.PALMTREE_COCONUT_CHANCE_UNLUCKY or TUNING.PALMTREE_COCONUT_CHANCE
        if math.random() <= chance then
            local coconut = SpawnPrefab("coconut")
            local pt = inst:GetPosition()
            local chopper_pt = chopper:GetPosition()
            local rad = chopper_pt:Dist(pt)
            local vec = (chopper_pt - pt):Normalize()
            local offset = Vector3(vec.x * rad, 4, vec.z * rad)

            coconut.Transform:SetPosition((pt + offset):Get())
            coconut.updatetask = coconut:DoPeriodicTask(0.1, grounddetection_update, 0.05)
        end
    end
end

local function dig_up_stump(inst, chopper)
    inst.components.lootdropper:SpawnLootPrefab("log")
    inst:Remove()
end

local function make_stump(inst)
    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    inst:RemoveComponent("workable")
    inst:RemoveComponent("hauntable")
    inst:RemoveComponent("blowinwindgust")
	inst:RemoveTag("gustable")
    inst:RemoveTag("shelter")

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    MakeHauntableIgnite(inst)

    RemovePhysicsColliders(inst)

    inst:AddTag("stump")
    if inst.components.growable ~= nil then
        inst.components.growable:StopGrowing()
    end

    inst.MiniMapEntity:SetIcon("palmtree_stump.tex")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up_stump)
    inst.components.workable:SetWorkLeft(1)

    -- Start the decay timer if we haven't already.
    if inst.components.timer ~= nil and not inst.components.timer:TimerExists("decay") then
        inst.components.timer:StartTimer("decay", GetRandomWithVariance(TUNING.PALMTREE_REGROWTH.DEAD_DECAY_TIME, TUNING.PALMTREE_REGROWTH.DEAD_DECAY_TIME * 0.5))
    end
end

local function on_chop_tree_down(inst, chopper)
    inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")
    local pt = inst:GetPosition()

    local chopper_on_rightside = true
    if chopper then
        local chopper_position = chopper:GetPosition()
        chopper_on_rightside = (chopper_position - pt):Dot(TheCamera:GetRightVec()) > 0
    else
        -- If we got chopped down by something other than a chopper, just pick a random sway to perform.
        if math.random() > 0.5 then
            chopper_on_rightside = false
        end
    end

    local anim_set = anims[inst.size]
    if chopper_on_rightside then
        inst.AnimState:PlayAnimation(anim_set.fallleft)
        inst.components.lootdropper:DropLoot(pt - TheCamera:GetRightVec())
    else
        inst.AnimState:PlayAnimation(anim_set.fallright)
        inst.components.lootdropper:DropLoot(pt + TheCamera:GetRightVec())
    end

    -- Note: currently just copied from evergreens. Potentially need to revisit.
    inst:DoTaskInTime(0.4, function (inst)
        ShakeAllCameras(CAMERASHAKE.FULL, .25, .03, (inst.size == TALL and .5) or .25, inst, 6)
    end)

    make_stump(inst)
    inst.AnimState:PushAnimation(anim_set.stump)
end

local function sway(inst)
    local anim_to_play = (math.random() > .5 and anims[inst.size].sway1) or anims[inst.size].sway2
    inst.AnimState:PlayAnimation(anim_to_play, true)
    inst.AnimState:SetTime(math.random() * 2)
end

local function push_sway(inst)
    local anim_to_play = (math.random() > .5 and anims[inst.size].sway1) or anims[inst.size].sway2
    inst.AnimState:PushAnimation(anim_to_play, true)
end

--------------------------------------------------------------------------------

local function set_short_burnable(inst)
    if inst.components.burnable == nil then
        inst:AddComponent("burnable")
    end
    inst.components.burnable:AddBurnFX("fire", Vector3(0, 0, 0))
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:SetBurnTime(TUNING.TREE_BURN_TIME / 3.5)
    inst.components.burnable:SetOnIgniteFn(DefaultBurnFn)
    inst.components.burnable:SetOnExtinguishFn(DefaultExtinguishFn)
    inst.components.burnable:SetOnBurntFn(on_tree_burnt)

    -- Equivalent to MakeSmallPropagator
    if inst.components.propagator == nil then
        inst:AddComponent("propagator")
    end
    inst.components.propagator.acceptsheat = true
    inst.components.propagator:SetOnFlashPoint(DefaultIgniteFn)
    inst.components.propagator.flashpoint = 5 + math.random()*5
    inst.components.propagator.decayrate = 0.5
    inst.components.propagator.propagaterange = 5
    inst.components.propagator.heatoutput = 5
    inst.components.propagator.damagerange = 2
    inst.components.propagator.damages = true
end

local function set_short(inst)
    inst.size = SHORT
    if inst.components.workable then
        inst.components.workable:SetWorkLeft(TUNING.PALMTREE_CHOPS_SMALL)
    end
    set_short_burnable(inst)
    inst.components.lootdropper:SetChanceLootTable("palmtree_short")
    inst:AddTag("shelter")
    sway(inst)
end

local function grow_short(inst)
    inst.AnimState:PlayAnimation("grow_tall_to_short")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrowFromWilt")
    set_short_burnable(inst)
    push_sway(inst)
end

--------------------------------------------------------------------------------

local function set_normal_burnable(inst)
    if inst.components.burnable == nil then
        inst:AddComponent("burnable")
    end
    inst.components.burnable:AddBurnFX("fire", Vector3(0, 0, 0))
    inst.components.burnable:SetBurnTime(TUNING.TREE_BURN_TIME / 2)
    inst.components.burnable:SetFXLevel(3)
    inst.components.burnable:SetOnIgniteFn(DefaultBurnFn)
    inst.components.burnable:SetOnExtinguishFn(DefaultExtinguishFn)
    inst.components.burnable:SetOnBurntFn(on_tree_burnt)

    -- Equivalent to MakeSmallPropagator
    if inst.components.propagator == nil then
        inst:AddComponent("propagator")
    end
    inst.components.propagator.acceptsheat = true
    inst.components.propagator:SetOnFlashPoint(DefaultIgniteFn)
    inst.components.propagator.flashpoint = 5 + math.random()*5
    inst.components.propagator.decayrate = 0.5
    inst.components.propagator.propagaterange = 5
    inst.components.propagator.heatoutput = 5
    inst.components.propagator.damagerange = 2
    inst.components.propagator.damages = true
end

local function set_normal(inst)
    inst.size = NORMAL
    if inst.components.workable then
        inst.components.workable:SetWorkLeft(TUNING.PALMTREE_CHOPS_NORMAL)
    end
    set_normal_burnable(inst)
    inst.components.lootdropper:SetChanceLootTable("palmtree_normal")
    inst:AddTag("shelter")
    sway(inst)
end

local function grow_normal(inst)
    inst.AnimState:PlayAnimation("grow_short_to_normal")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
    set_normal_burnable(inst)
    push_sway(inst)
end

--------------------------------------------------------------------------------

local function set_tall_burnable(inst)
    if inst.components.burnable == nil then
        inst:AddComponent("burnable")
    end
    inst.components.burnable:AddBurnFX("fire", Vector3(0, 0, 0))
    inst.components.burnable:SetFXLevel(5)
    inst.components.burnable:SetBurnTime(TUNING.TREE_BURN_TIME / 1.1)
    inst.components.burnable:SetOnIgniteFn(DefaultBurnFn)
    inst.components.burnable:SetOnExtinguishFn(DefaultExtinguishFn)
    inst.components.burnable:SetOnBurntFn(on_tree_burnt)

    -- Equivalent to MakeMediumPropagator
    if inst.components.propagator == nil then
        inst:AddComponent("propagator")
    end
    inst.components.propagator.acceptsheat = true
    inst.components.propagator:SetOnFlashPoint(DefaultIgniteFn)
    inst.components.propagator.flashpoint = 15+math.random()*10
    inst.components.propagator.decayrate = 0.5
    inst.components.propagator.propagaterange = 7
    inst.components.propagator.heatoutput = 8.5
    inst.components.propagator.damagerange = 3
    inst.components.propagator.damages = true
end

local function set_tall(inst)
    inst.size = TALL
    if inst.components.workable then
        inst.components.workable:SetWorkLeft(TUNING.PALMTREE_CHOPS_TALL)
    end
    set_tall_burnable(inst)
    inst.components.lootdropper:SetChanceLootTable("palmtree_tall")
    inst:AddTag("shelter")
    sway(inst)
end

local function grow_tall(inst)
    inst.AnimState:PlayAnimation("grow_normal_to_tall")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
    set_tall_burnable(inst)
    push_sway(inst)
end

--------------------------------------------------------------------------------

local growth_stages = {
    {
        name = SHORT,
        time = function(inst)
            return GetRandomWithVariance(TUNING.PALMTREE_GROW_TIME[1].base, TUNING.PALMTREE_GROW_TIME[1].random)
        end,
        fn = set_short,
        growfn = grow_short,
        leifscale = 0.7,
    },
    {
        name = NORMAL,
        time = function(inst)
            return GetRandomWithVariance(TUNING.PALMTREE_GROW_TIME[2].base, TUNING.PALMTREE_GROW_TIME[2].random)
        end,
        fn = set_normal,
        growfn = grow_normal,
        leifscale=1,
    },
    {
        name = TALL,
        time = function(inst)
            return GetRandomWithVariance(TUNING.PALMTREE_GROW_TIME[3].base, TUNING.PALMTREE_GROW_TIME[3].random)
        end,
        fn = set_tall,
        growfn = grow_tall,
        leifscale=1.25,
    },
}

local function GetGrowthStage(inst)
    return growth_stages[inst.size == SHORT and 1 or inst.size == TALL and 3 or 2]
end

local function growfromseed_handler(inst)
    inst.components.growable:SetStage(1)
    inst.AnimState:PlayAnimation("grow_seed_to_short")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
    push_sway(inst)
end

local function on_timer_done(inst, data)
    -- We only have work to do for the decay timer here.
    if data.name ~= "decay" then
        return
    end

    -- Duplicated from evergreens:
    -- Before we disappear, clean up any loot left on the ground.
    -- Too many objects is as bad for server health as too few!
    local x, y, z = inst.Transform:GetWorldPosition()
    local entities = TheSim:FindEntities(x, y, z, 6)
    local leftone = false
    for k, entity in pairs(entities) do
        if entity.prefab == "log" or entity.prefab == "charcoal" then
            if leftone then
                entity:Remove()
            else
                leftone = true
            end
        end
    end

    inst:Remove()
end

local function on_save(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end

    if inst:HasTag("stump") then
        data.stump = true
    end

    data.size = inst.size
end

local function on_load(inst, data)
    if data == nil then
        return
    end

    inst.size = data.size ~= nil and data.size or NORMAL
    if inst.size == SHORT then
        set_short(inst)
    elseif inst.size == NORMAL then
        set_normal(inst)
    else
        set_tall(inst)
    end

    local is_burnt = data.burnt or inst:HasTag("burnt")
    if data.stump and is_burnt then
        make_stump(inst)
        inst.AnimState:PlayAnimation(anims[inst.size].stump)
        DefaultBurntFn(inst)
    elseif data.stump then
        make_stump(inst)
        inst.AnimState:PlayAnimation(anims[inst.size].stump)
    elseif is_burnt then
        tree_burnt_immediate_helper(inst, true)
    else
        sway(inst)
    end
end

local function on_sleep(inst)
    local do_burnt = inst.components.burnable ~= nil and inst.components.burnable:IsBurning()
    if do_burnt and inst:HasTag("stump") then
        DefaultBurntFn(inst)
    else
        inst:RemoveComponent("burnable")
        inst:RemoveComponent("propagator")
        inst:RemoveComponent("inspectable")
        if do_burnt then
            inst:RemoveComponent("growable")
            inst:AddTag("burnt")
        end
    end
end

local function on_wake(inst)
    if inst:HasTag("burnt") then
        on_tree_burnt(inst)
    else
        if not (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
            local is_stump = inst:HasTag("stump")
            if is_stump then
                if inst.components.burnable == nil then
                    MakeSmallBurnable(inst)
                end

                if inst.components.propagator == nil then
                    MakeMediumPropagator(inst)
                end
            else
                if inst.size == SHORT then
                    set_short_burnable(inst)
                elseif inst.size == NORMAL then
                    set_normal_burnable(inst)
                else
                    set_tall_burnable(inst)
                end
            end
        end
    end

    if inst.components.inspectable == nil then
        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_tree
    end
end

local function find_leif_spawn_target(item)
    if item.components.growable and item.components.growable.stage <= 3 then
        return not item.noleif
    end
end

local function spawn_leif(target)
    local leif = SpawnPrefab("leif_palm")
    leif.AnimState:SetMultColour(target.AnimState:GetMultColour())
    leif:SetLeifScale(target.leifscale)

    if target.chopper ~= nil then
        leif.components.combat:SuggestTarget(target.chopper)
    end

    local x, y, z = target.Transform:GetWorldPosition()
    target:Remove()

    leif.Transform:SetPosition(x, y, z)
    leif.sg:GoToState("spawn")
end

local function TransformIntoLeif(inst, chopper)
    inst.noleif = true
    inst.leifscale = GetGrowthStage(inst).leifscale or 1
    inst.chopper = chopper
    inst:DoTaskInTime(1 + math.random() * 3, spawn_leif)
end

local LEIFTARGET_CANT_TAGS = {"FX", "NOCLICK", "INLIMBO", "stump", "burnt"}
local LEIFTARGET_MUST_TAGS = {"palmtree"}
local function on_chop_tree_down_leif(inst, chopper)
    on_chop_tree_down(inst, chopper)

    local days_survived = TheWorld.state.cycles
    if days_survived >= TUNING.LEIF_MIN_DAY then
        local chance = TUNING.LEIF_PERCENT_CHANCE
        if chopper:HasTag("beaver") then
            chance = chance * TUNING.BEAVER_LEIF_CHANCE_MOD
        elseif chopper:HasTag("woodcutter") then
            chance = chance * TUNING.WOODCUTTER_LEIF_CHANCE_MOD
        end
        if math.random() < chance then
            local numleifs = 3
            if days_survived > 30 then
                numleifs = math.random(3,4)
            elseif days_survived > 80 then
                numleifs = math.random(4,5)
            end

            for k = 1,numleifs do
                local target = FindEntity(inst, TUNING.PALMTREEGUARD_MAXSPAWNDIST, find_leif_spawn_target, LEIFTARGET_MUST_TAGS, LEIFTARGET_CANT_TAGS)
                if target ~= nil then
                    target:TransformIntoLeif(chopper)
                end
            end
        end
    end
end

local function on_haunt_palm_tree(inst, haunter)
    if math.random() <= TUNING.HAUNT_CHANCE_SUPERRARE and
        find_leif_spawn_target(inst) and
        not (inst:HasTag("burnt") or inst:HasTag("stump"))
    then
        inst.leifscale = GetGrowthStage(inst).leifscale or 1
        spawn_leif(inst)

        inst.components.hauntable.hauntvalue = TUNING.HAUNT_HUGE
        inst.components.hauntable.cooldown_on_successful_haunt = false
        return true
    end
    return on_haunt_work(inst, haunter)
end

local function get_wind_anims(inst, type)
	if type == 1 then
		local anim = math.random(1,2)
		return anims[inst.size]["blown" .. tostring(anim)]
	elseif type == 2 then
		return anims[inst.size].blown_pst
	end
	return anims[inst.size].blown_pre
end

local function tree(name, stage, data)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, .25)

        inst.MiniMapEntity:SetIcon("palmtree.tex")
        inst.MiniMapEntity:SetPriority(-1)

        inst:AddTag("plant")
        inst:AddTag("tree")
        inst:AddTag("workable")
        inst:AddTag("shelter")
        inst:AddTag("gustable")

        inst.AnimState:SetBuild("ia_palmtree_build")
        inst.AnimState:SetBank("ia_palmtree")
        inst:SetPrefabName("palmtree")
        inst:AddTag("palmtree") -- for plantregrowth

        MakeSnowCoveredPristine(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        -- Add a random colour multiplier to avoid samey-ness.
        inst.color = 0.5 + math.random() * 0.5
        inst.AnimState:SetMultColour(inst.color, inst.color, inst.color, 1)

        -------------------
        inst.size = (stage == 1 and SHORT)
                or (stage == 2 and NORMAL)
                or (stage == 3 and TALL)
                or nil

        if inst.size == SHORT then
            set_short_burnable(inst)
        elseif inst.size == NORMAL then
            set_normal_burnable(inst)
        else
            set_tall_burnable(inst)
        end

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = inspect_tree

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.CHOP)
        inst.components.workable:SetOnWorkCallback(on_chop_tree)
        inst.components.workable:SetOnFinishCallback(on_chop_tree_down_leif)

        inst:AddComponent("lootdropper")

        inst:AddComponent("growable")
        inst.components.growable.stages = growth_stages
        inst.components.growable:SetStage(stage == 0 and math.random(1, 3) or stage)
        inst.components.growable.loopstages = true
        inst.components.growable.springgrowth = true
        inst.components.growable.magicgrowable = true
        inst.components.growable:StartGrowing()
        inst.growfromseed = growfromseed_handler

        inst:AddComponent("simplemagicgrower")
        inst.components.simplemagicgrower:SetLastStage(#inst.components.growable.stages)

        inst:AddComponent("plantregrowth")
        inst.components.plantregrowth:SetRegrowthRate(TUNING.PALMTREE_REGROWTH.OFFSPRING_TIME)
        inst.components.plantregrowth:SetProduct("coconut_sapling")
        inst.components.plantregrowth:SetSearchTag("palmtree")

        inst:AddComponent("timer") -- Set up a decay timer
        inst:ListenForEvent("timerdone", on_timer_done)

        inst.TransformIntoLeif = TransformIntoLeif

        MakeTreeBlowInWindGust(inst, TUNING.PALMTREE_WINDBLOWN_SPEED, TUNING.PALMTREE_WINDBLOWN_FALL_CHANCE)
        inst.PushSway = push_sway
        inst.WindGetAnims = get_wind_anims

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetOnHauntFn(on_haunt_palm_tree)

        inst.OnSave = on_save
        inst.OnLoad = on_load

        MakeSnowCovered(inst, .01)

        inst.AnimState:SetTime(math.random() * 2)

        if data == "burnt"  then
            on_tree_burnt(inst)
        end

        if data == "stump"  then
            make_stump(inst)
        end

        inst.OnEntitySleep = on_sleep
        inst.OnEntityWake = on_wake

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

return tree("palmtree", 0),
    tree("palmtree_normal", 2),
    tree("palmtree_tall", 3),
    tree("palmtree_short", 1),
    tree("palmtree_burnt", 0, "burnt"),
    tree("palmtree_stump", 0, "stump")
