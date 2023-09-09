local assets =
{
    Asset("ANIM", "anim/geyser.zip"),
    Asset("MINIMAP_IMAGE", "geyser"),
}

local FX_PRE =
{
    {percent = 1.0, anim = "active_pre", radius = 0, intensity = .8, falloff = .33, colour = {255/255, 187/255, 187/255}, soundintensity = .1},
    {percent = 1.0 - (24 / 42), sound = "ia/common/flamegeyser_lp", radius = 1, intensity = .8, falloff = .33, colour = {255/255, 187/255, 187/255}, soundintensity = 1},
    {percent = 0.0, sound = "ia/common/flamegeyser_lp", radius = 3.5, intensity = .8, falloff = .33, colour = {255/255, 187/255, 187/255}, soundintensity = 1},
}

local FX_LEVELS =
{
    {percent = 1.0, anim = "active_loop", sound = "ia/common/flamegeyser_lp", radius = 3.5, intensity = .8, falloff = .33, colour = {255/255, 187/255, 187/255}, soundintensity = 1},
}

local FX_PST  =
{
    {percent = 1.0, anim = "active_pst", sound = "ia/common/flamegeyser_lp", radius = 3.5, intensity = .8, falloff = .33, colour = {255/255, 187/255, 187/255}, soundintensity = 1},
    {percent = 1.0 - (61/96), sound = "ia/common/flamegeyser_out", radius = 0, intensity = .8, falloff = .33, colour = {255/255, 187/255, 187/255}, soundintensity = .1},
}

local function StartBurning(inst)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.Light:Enable(true)

    inst.components.geyserfx:Ignite()
    inst:AddTag("fire")
end

local function OnIgnite(inst)
    StartBurning(inst)
end

local function OnBurn(inst)
    inst.components.fueled:StartConsuming()
    inst.components.propagator:StartSpreading()
    inst.components.geyserfx:SetPercent(inst.components.fueled:GetPercent())
    inst:AddComponent("cooker")
end

local function SetIgniteTimer(inst)
    inst.ignite_task = inst:DoTaskInTime(GetRandomWithVariance(TUNING.FLAMEGEYSER_REIGNITE_TIME, TUNING.FLAMEGEYSER_REIGNITE_TIME_VARIANCE), function()
        inst.ignite_task = nil
        if not inst:HasTag("flooded") then
            inst.components.fueled:SetPercent(1.0)
            OnIgnite(inst)
        end
    end)
end

local function OnErupt(inst)
    StartBurning(inst)
    inst.components.fueled:SetPercent(1.0)
    OnBurn(inst)
    ShakeAllCameras(CAMERASHAKE.FULL, .7, .02, 0.75, inst, 15)
end

local function OnExtinguish(inst, setTimer)
    inst.AnimState:ClearBloomEffectHandle()
    inst.components.fueled:StopConsuming()
    inst.components.propagator:StopSpreading()
    inst.components.geyserfx:Extinguish()
    if inst.components.cooker then
        inst:RemoveComponent("cooker")
    end
    if setTimer ~= false then
        SetIgniteTimer(inst)
    end
    inst:RemoveTag("fire")
end

local function OnIdle(inst)
    inst.AnimState:PlayAnimation("idle_dormant", true)
    inst.Light:Enable(false)
    inst:StopUpdatingComponent(inst.components.geyserfx)
end

local DAMAGE_RANGE = {2, 2, 2, 2}
local PROPAGATE_RANGES = {1, 2, 3, 4}
local HEAT_OUTPUTS = {2, 5, 5, 10}
local function onfuelchange(newsection, oldsection, inst)
	if newsection <= 0 then
		OnExtinguish(inst)
	else
		inst.components.propagator.damagerange = DAMAGE_RANGE[newsection]
		inst.components.propagator.propagaterange = PROPAGATE_RANGES[newsection]
		inst.components.propagator.heatoutput = HEAT_OUTPUTS[newsection]
	end
end

local function onfuelupdate(inst)
	if not inst.components.fueled:IsEmpty() and not inst:IsAsleep() then
		inst.components.geyserfx:SetPercent(inst.components.fueled:GetPercent())
	end
end

local function OnLoad(inst, data)
    if not inst.components.fueled:IsEmpty() then
        OnIgnite(inst)
    else
        SetIgniteTimer(inst)
    end
end

-- local heats = { 70, 85, 100, 115 }
-- local function GetHeatFn(inst)
--     return 100 --heats[inst.components.geyserfx.level] or 20
-- end

-- Looks like they commented out the original because geysrfx only has one level....
-- So lets redo this based on the state! -Half
local HEAT_RANGES = { 70, 100, 85, 115 } -- IDLE, BURN, EXTINGUISH, IGNITE
local function GetHeatFn(inst)
    local state = inst.components.geyserfx ~= nil and (inst.components.geyserfx.state + 1)
    return not inst:HasTag("flooded") and state ~= nil and HEAT_RANGES[state] or 20
end

local function onStartFlooded(inst)
    inst.components.fueled:SetPercent(0)
    OnExtinguish(inst, false)
end


local function onStopFlooded(inst)
    SetIgniteTimer(inst)
end

local function OnExploded(inst, data)
    if not (data.explosive and data.explosive:HasTag("coconade")) then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()

    local fx = SpawnPrefab("mining_fx")
    if fx then
        inst.SoundEmitter:PlaySound("ia/common/dig_rockpile")
        fx.Transform:SetPosition(x, y, z)
        fx.Transform:SetScale(1.3, 1.3, 1.3)
    end

    inst:Remove()
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, 2.05)
    inst.Physics:SetCollides(false)

    inst.MiniMapEntity:SetIcon("geyser.tex")
    inst.AnimState:SetBank("geyser")
    inst.AnimState:SetBuild("geyser")
    inst.AnimState:PlayAnimation("idle_dormant", true)

    inst:AddTag("HASHEATER")
    inst:AddTag("flamegeyser")

    inst.Light:EnableClientModulation(true)

    inst:AddComponent("floodable")
    inst.components.floodable:SetFX(nil, .1) -- init update faster

    inst:DoTaskInTime(1, function()
        inst.components.floodable:SetFX(nil, 10) -- now update normal again
    end)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("heater")
    inst.components.heater.heatfn = GetHeatFn

    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = TUNING.FLAMEGEYSER_FUEL_MAX
    inst.components.fueled.accepting = false
    inst:AddComponent("propagator")
    inst.components.propagator.damagerange = 2
    inst.components.propagator.damages = true

    inst.components.fueled:SetSections(4)
    inst.components.fueled.rate = 1
    inst.components.fueled.period = 1
    inst.components.fueled:SetUpdateFn(onfuelupdate)
    inst.components.fueled:SetSectionCallback(onfuelchange)
    inst.components.fueled:InitializeFuelLevel(TUNING.FLAMEGEYSER_FUEL_START)

    inst.components.floodable.onStartFlooded = onStartFlooded
    inst.components.floodable.onStopFlooded = onStopFlooded

    inst:AddComponent("geyserfx")
    inst.components.geyserfx.usedayparamforsound = true
    inst.components.geyserfx.lightsound = "ia/common/flamegeyser_open"
    -- inst.components.geyserfx.extinguishsound = "ia/common/flamegeyser_out"
    inst.components.geyserfx.pre = FX_PRE
    inst.components.geyserfx.levels = FX_LEVELS
    inst.components.geyserfx.pst = FX_PST

    if not inst.components.fueled:IsEmpty() then
        OnIgnite(inst)
    end

    inst:ListenForEvent("explosion", OnExploded)
    
    inst.OnIgnite = OnIgnite
    inst.OnErupt = OnErupt
    inst.OnBurn = OnBurn
    inst.OnIdle = OnIdle

    return inst
end

return Prefab("flamegeyser", fn, assets)
