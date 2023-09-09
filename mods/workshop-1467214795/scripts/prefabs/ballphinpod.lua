local assets = {
    -- Asset("ANIM", "anim/arrow_indicator.zip"),
}

local prefabs = {"ballphin"}

local function InMood(inst)
    if inst.components.periodicspawner then
        inst.components.periodicspawner:Start()
    end
    if inst.components.herd then
        for k, v in pairs(inst.components.herd.members) do
            k:PushEvent("entermood")
        end
    end
end

local function LeaveMood(inst)
    if inst.components.periodicspawner then
        inst.components.periodicspawner:Stop()
    end
    if inst.components.herd then
        for k, v in pairs(inst.components.herd.members) do
            k:PushEvent("leavemood")
        end
    end
    inst.components.mood:CheckForMoodChange()
end

local function AddMember(inst, member)
    if inst.components.mood then
        if inst.components.mood:IsInMood() then
            member:PushEvent("entermood")
        else
            member:PushEvent("leavemood")
        end
    end
end

local function CanSpawn(inst)
    return inst.components.herd and not inst.components.herd:IsFull()
end

local function OnSpawned(inst, newent)
    if inst.components.herd then
        inst.components.herd:AddMember(newent)
        for member, i in pairs(inst.components.herd.members) do
            local newhome = member.components.homeseeker and member.components.homeseeker:HasHome() and member.components.homeseeker.home
            if newhome and newhome.components.childspawner then
                newhome.components.childspawner:TakeOwnership(newent)
                break
            end
        end
    end
end

local function OnEmpty(inst)
    inst:Remove()
end

-- local function OnFull(inst)
-- TODO: mark some ballphin for death
-- end

local function fn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    -- inst.AnimState:SetBank("arrow_indicator")
    -- inst.AnimState:SetBuild("arrow_indicator")
    -- inst.AnimState:PlayAnimation("arrow_loop", true)

    inst:AddTag("herd")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("herd")
    inst.components.herd:SetMemberTag("ballphin")
    inst.components.herd:SetGatherRange(TUNING.BALLPHINPOD_RANGE)
    inst.components.herd:SetUpdateRange(20)
    inst.components.herd:SetOnEmptyFn(OnEmpty)
    -- inst.components.herd:SetOnFullFn(OnFull)
    inst.components.herd:SetAddMemberFn(AddMember)

    inst:AddComponent("mood")
    inst.components.mood:SetMoodTimeInDays(TUNING.BALLPHIN_MATING_SEASON_LENGTH, TUNING.BALLPHIN_MATING_SEASON_WAIT, TUNING.BALLPHIN_MATING_ALWAYS, TUNING.BALLPHIN_MATING_SEASON_LENGTH, TUNING.BALLPHIN_MATING_SEASON_WAIT, TUNING.BALLPHIN_MATING_ENABLED)
    inst.components.mood:SetMoodSeason(SEASONS.MILD)
    inst.components.mood:SetInMoodFn(InMood)
    inst.components.mood:SetLeaveMoodFn(LeaveMood)
    inst.components.mood:CheckForMoodChange()

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetNotFloatsam(true)
    inst.components.periodicspawner:SetRandomTimes(TUNING.BALLPHIN_MATING_SEASON_BABYDELAY, TUNING.BALLPHIN_MATING_SEASON_BABYDELAY_VARIANCE)
    inst.components.periodicspawner:SetPrefab("ballphin")
    inst.components.periodicspawner:SetOnSpawnFn(OnSpawned)
    inst.components.periodicspawner:SetSpawnTestFn(CanSpawn)
    inst.components.periodicspawner:SetDensityInRange(20, 6)
    inst.components.periodicspawner:SetOnlySpawnOffscreen(true)

    return inst
end

return Prefab("ballphinpod", fn, assets, prefabs)
