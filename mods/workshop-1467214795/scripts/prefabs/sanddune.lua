local assets =
{
    Asset("ANIM", "anim/sand_dune.zip")
}

local prefabs =
{
    "sand",
}

local startregen

-- these should match the animation names to the workleft
local anims = {"low", "med", "full"}

local function onregen(inst)
    inst.components.activatable.inactive = false
    if inst.components.workable.workleft < #anims-1 then
        inst.components.workable:SetWorkLeft(math.floor(inst.components.workable.workleft)+1)
        startregen(inst)
    else
        inst.targettime = nil
    end
end

startregen = function(inst, regentime)
    if inst.components.workable.workleft < #anims-1 then
        -- more to grow
        regentime = regentime or (TUNING.SAND_REGROW_TIME + math.random()*TUNING.SAND_REGROW_VARIANCE)

        if TheWorld.state.iswinter --[[or TheWorld.state.iswet--]] then
        regentime = regentime / 2
        elseif TheWorld.state.isspring --[[or TheWorld.state.isgreen--]] then
        regentime = regentime * 2
        end

        if inst.task then
        inst.task:Cancel()
        end
        inst.task = inst:DoTaskInTime(regentime, onregen, "regen")
        inst.targettime = GetTime() + regentime
    else
        -- no more to do
        if inst.task then
        inst.task:Cancel()
        end
        inst.targettime = nil
    end

    if inst.components.workable.workleft < 1 then
        inst.AnimState:PlayAnimation(anims[1])
    else
        inst.AnimState:PlayAnimation(anims[math.floor(inst.components.workable.workleft)+1])
    end

    -- print('startregen', inst.components.workable.workleft, regentime, anims[inst.components.workable.workleft])
end

local function workcallback(inst, worker, workleft, numworks)
    -- print('trying to spawn sand', inst, worker, workleft)
    if workleft <= 0 then
        inst.components.activatable.inactive = true
    end
        numworks = math.min(numworks, 2)
        local prevworkleft = numworks + workleft
        local spawns = math.min(math.ceil(prevworkleft) - math.ceil(workleft), math.ceil(prevworkleft))

        if spawns > 0 then

            -- figure out which side to drop the loot
            local pt = Vector3(inst.Transform:GetWorldPosition())
            local hispos = Vector3(worker.Transform:GetWorldPosition())
            local targetpt

            --TODO do not use TheCamera for networked activities! -M
            if ((hispos - pt):Dot(TheCamera:GetRightVec()) > 0) then
                targetpt = pt - (TheCamera:GetRightVec()*(.5+math.random()))
            else
                targetpt = pt + (TheCamera:GetRightVec()*(.5+math.random()))
            end

            for i = 1, spawns do
                inst.components.lootdropper:DropLoot(targetpt)
            end

        end

    -- inst.SoundEmitter:PlaySound("ia/common/sandpile")

    startregen(inst)
end

local function onactivate(inst)
    -- SpawnAt("collapse_small", inst)
    inst.SoundEmitter:PlaySound("ia/common/sandpile")
    inst:Remove()
end

local function onsave(inst, data)
    if inst.targettime then
        local time = GetTime()
        if inst.targettime > time then
        data.time = math.floor(inst.targettime - time)
        end
        data.workleft = inst.components.workable.workleft
        -- print('sandhill onsave', data.workleft)
    end
end
local function onload(inst, data)
    if data and data.workleft then
        inst.components.workable.workleft = data.workleft

        if data.workleft <= 0 then
        inst.components.activatable.inactive = true
        end

    end
    -- print('sandhill onload', inst.components.workable.workleft)
    if data and data.time then
        startregen(inst, data.time)
    end
end

-- note: this doesn't really handle skipping 2 regens in a long update
local function LongUpdate(inst, dt)
    if inst.targettime then
        local time = GetTime()
        if inst.targettime > time + dt then
        --resechedule
        local time_to_regen = inst.targettime - time - dt
        -- print ("LongUpdate resechedule", time_to_regen)

        startregen(inst, time_to_regen)
        else
        --skipped a regen, do it now
        -- print ("LongUpdate skipped regen")
        onregen(inst)
        end
    end
end

local function onwake(inst)
    if (TheWorld.state.isspring --[[or TheWorld.state.isgreen--]]) and TheWorld.state.israining then
        if math.random() < TUNING.SAND_DEPLETE_CHANCE and inst.components.workable.workleft > 0 then
        -- the rain made this sandhill shrink
        inst.components.workable.workleft = inst.components.workable.workleft - math.random(0, inst.components.workable.workleft)
        startregen(inst)
        end
    end
end

local function sandhillfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBuild("sand_dune")
    inst.AnimState:SetBank("sand_dune")
    inst.AnimState:PlayAnimation(anims[#anims])

    inst.GetActivateVerb = function() return "SAND" end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.OnLongUpdate = LongUpdate
    inst.OnSave = onsave
    inst.OnLoad = onload
    inst.OnEntityWake = onwake

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddTag("sanddune")

    -- Moved this here from workcallback because it works here too and is more modding friendly at that

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"sand"})
    inst.components.lootdropper.numrandomloot = 1
    inst.components.lootdropper.chancerandomloot = 0.01  -- drop some random item 1% of the time
    inst.components.lootdropper:AddRandomLoot("seashell", 0.01)
    inst.components.lootdropper:AddRandomLoot("rocks", 0.01)
    inst.components.lootdropper:AddRandomLoot("feather_crow", 0.01)
    inst.components.lootdropper:AddRandomLoot("feather_robin", 0.01)
    inst.components.lootdropper:AddRandomLoot("feather_robin_winter", 0.01)
    inst.components.lootdropper:AddRandomLoot("antliontrinket", 0.01)
    inst.components.lootdropper:AddRandomLoot("venomgland", 0.001)
    inst.components.lootdropper:AddRandomLoot("coconut", 0.001)
    inst.components.lootdropper:AddRandomLoot("crab", 0.001)
    inst.components.lootdropper:AddRandomLoot("snake", 0.001)
    inst.components.lootdropper:AddRandomLoot("gears", 0.002)
    inst.components.lootdropper:AddRandomLoot("redgem", 0.002)
    inst.components.lootdropper:AddRandomLoot("dubloon", 0.002)
    inst.components.lootdropper:AddRandomLoot("purplegem", 0.001)

    -- full, med, low
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(#anims-1)
    inst.components.workable:SetOnWorkCallback(workcallback)

    inst:AddComponent("activatable")
    inst.components.activatable.inactive = false
    -- inst.components.activatable.getverb = function() return "SAND" end
    inst.components.activatable.OnActivate = onactivate

    return inst
end

return Prefab("sanddune", sandhillfn, assets, prefabs)
