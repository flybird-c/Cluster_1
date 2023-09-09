local assets =
{
    Asset("ANIM", "anim/fishschool.zip")
}

local prefabs =
{
    "pondfish_tropical",
}

local FISH_STATES =
{
    FULL = "full",
    HALF = "half",
    GONE = "gone",
}

local function SetFishState(inst, state)
    inst.fish_state = state
end

local function GetFishState(inst)
    return inst.fish_state
end

local function PlayAnimation(inst, anim, loop)
    local state = inst:GetFishState()
    anim = anim .. "_" .. state
    inst.AnimState:PlayAnimation(anim, loop)
end

local function PushAnimation(inst, anim, loop)
    local state = inst:GetFishState()
    anim = anim .. "_" .. state
    inst.AnimState:PushAnimation(anim, loop)
end

local function getactiveperiod(inst)
    local activeTime = TUNING.TOTAL_DAY_TIME * 2

    if TheWorld.state.iswinter then  -- or TheWorld.state.iswet then
        activeTime = TUNING.TOTAL_DAY_TIME
    elseif TheWorld.state.isspring then  -- or TheWorld.state.isgreen then
        activeTime = TUNING.TOTAL_DAY_TIME * 3
    end

    return activeTime
end

local function getinactiveperiod(inst)
    local inactiveTime = TUNING.TOTAL_DAY_TIME

    if TheWorld.state.iswinter or TheWorld.state.iswet then
        inactiveTime = TUNING.TOTAL_DAY_TIME * 3
    elseif TheWorld.state.isspring or TheWorld.state.isgreen then
        inactiveTime = TUNING.TOTAL_DAY_TIME * 0.5
    end

    return inactiveTime
end

local function isbeingfished(inst)
    return inst.isbeingfished
end

local function scatter(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
    end

    if isbeingfished(inst) then
        inst.scatterTime = GetTime() + 2
        inst.task = inst:DoTaskInTime(2, inst.scatter, "scatter")
    else
        inst.regroupTime = getinactiveperiod(inst) + GetTime()
        PlayAnimation(inst, "idle_pst")
        local animLength = inst.AnimState:GetCurrentAnimationLength()
        inst.MiniMapEntity:SetEnabled(false)
        inst.active = false
        inst.task = inst:DoTaskInTime(getinactiveperiod(inst), inst.regroup, "regroup")
        inst.SoundEmitter:PlaySound("ia/common/fish_scatter")

        inst:DoTaskInTime(animLength, function(inst)
            inst:Hide()
        end)
    end
end

local function regroup(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
    end

    inst:Show()
    inst.scatterTime = getactiveperiod(inst) + GetTime()
    PlayAnimation(inst, "idle_pre")
    PushAnimation(inst, "idle_loop", true)
    inst.MiniMapEntity:SetEnabled(true)
    inst.active = true
    inst.task = inst:DoTaskInTime(getactiveperiod(), inst.scatter, "scatter")
end

local function onlongupdate(inst, dt)
    if inst.task ~= nil then
        inst.task:Cancel()
    end
    local time = GetTime() + dt
    if inst.active then
        if time > inst.scatterTime then
            inst:scatter()
        else
            inst.task = inst:DoTaskInTime(inst.scatterTime - time, inst.scatter, "scatter")
            inst.scatterTime = inst.scatterTime - dt
        end
    else
        if time > inst.regroupTime then
            inst:regroup()
        else
            inst.task = inst:DoTaskInTime(inst.regroupTime - time, inst.regroup, "regroup")
            inst.regroupTime = inst.regroupTime - dt
        end
    end
end

local function onfishdelta(inst)
    local percent = inst.components.fishable:GetFishPercent()

    if percent >= 0.50 then
        inst:SetFishState(FISH_STATES.FULL)
    elseif percent > 0 then
        inst:SetFishState(FISH_STATES.HALF)
    else
        inst:SetFishState(FISH_STATES.GONE)
    end

    PushAnimation(inst, "idle_loop", true)
end

local function onsave(inst, data)
    if data == nil then
        data = {}
    end

    data.active = inst.activeTime
    data.fish_state = inst:GetFishState()
    if data.active then
        if inst.scatterTime ~= nil then
            data.timeuntilscatter = inst.scatterTime - GetTime()
            data.timeuntilregroup = nil
        end
    else
        if inst.regroupTime ~= nil then
            data.timeuntilregroup = inst.regroupTime - GetTime()
            data.timeuntilscatter = nil
        end
    end
end

local function onload(inst, data)
    if data then
        if data.fish_state then
            inst:SetFishState(data.fish_state)
        end
        if data.active then
            inst.active = true
            inst.MiniMapEntity:SetEnabled(true)
            inst.task = inst:DoTaskInTime(data.timeuntilscatter or 0, inst.scatter, "scatter")
            inst.scatterTime = GetTime() + (data.timeuntilscatter or 0)
        else
            inst.active = false
            PlayAnimation(inst, "idle_pst", false)
            inst.MiniMapEntity:SetEnabled(false)
            inst.task = inst:DoTaskInTime(data.timeuntilregroup or 0, inst.regroup, "regroup")
            inst.regroupTime = GetTime() + (data.timeuntilregroup or 0)
        end
    end
end

local function oncollide(inst, other)
    if not inst.active then return end

    if other and other.sg and other.sg:HasStateTag("running") then
        if not isbeingfished(inst) and inst:IsNear(other, 3.5) then
            scatter(inst)
        end
    end
end

local function OnHaunt(inst)
    scatter(inst)
end  -- had to put scattering in a separate function so that shoals don't randomly scatter after loading

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()
    inst.entity:AddNetwork()

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("fish2.tex")

    inst.Physics:SetCylinder(4, 2)
    inst.Physics:SetCollides(false)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:SetCollisionCallback(oncollide)

    inst.AnimState:SetBuild("fishschool")
    inst.AnimState:SetBank("fishschool")
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(-3)
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("ignorewalkableplatforms")

    inst.no_wet_prefix = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    -- Likley an oversight caused by copy and pasted code...
    -- inst.components.inspectable.nameoverride = "pond"

    inst:AddComponent("fishable")
    inst.components.fishable:SetRespawnTime(TUNING.FISH_SCHOOL_RESPAWN)
    inst.components.fishable:AddFish("pondfish_tropical")
    inst.components.fishable.OnFishDelta = onfishdelta
    local numFish = math.random(TUNING.FISH_SCHOOL_MIN, TUNING.FISH_SCHOOL_MAX)
    inst.components.fishable.maxfix = numFish
    inst.components.fishable.fishleft = numFish

    inst.regroup = regroup
    inst.scatter = scatter
    inst.GetFishState = GetFishState
    inst.SetFishState = SetFishState
    inst:SetFishState(FISH_STATES.FULL)
    PlayAnimation(inst, "idle_loop", true)

    inst:AddComponent("hauntable")
    inst.components.hauntable.onhaunt = OnHaunt

    inst.active = true
    local activeTime = getactiveperiod()
    local inactiveTime = getinactiveperiod()
    local currentTime = math.random(0, activeTime + inactiveTime)
    local timeLeft

    if currentTime >= activeTime then
        inst.active = false
        currentTime = currentTime - activeTime
        timeLeft = inactiveTime - currentTime
        inst.regroupTime = timeLeft + GetTime()
        inst.task = inst:DoTaskInTime(timeLeft, inst.regroup, "regroup")
        inst.MiniMapEntity:SetEnabled(false)
    else
        timeLeft = activeTime - currentTime
        inst.scatterTime = timeLeft + GetTime()
        inst.task = inst:DoTaskInTime(timeLeft, inst.scatter, "scatter")
    end

    inst.OnLoad = onload
    inst.OnSave = onsave
    inst.OnLongUpdate = onlongupdate

    return inst
end

return Prefab("fishinhole", fn, assets, prefabs)
