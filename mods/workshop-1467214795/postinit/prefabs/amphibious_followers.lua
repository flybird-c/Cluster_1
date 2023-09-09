local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

require("stategraphs/commonstates")

require("stategraphs/sailingcommon")

----------------------------------------------------------------------------------------

-- Floating point error yay!
local SAILSTART_TIME = 0.83333331346512
local SAIL_TIME = 3.5999999046326
local SAILSTOP_TIME = 3.5666666030884

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local function hop_pre_onenter(inst)
    inst.components.amphibiouscreature:OnExitOcean()
    inst.components.locomotor:PushTargetSpeed()
end

local function PatchStategraph(sg, idleanim, sailing_config)
    SailingCommonHandlerPatches.AddBoatLocomotion(sg, true, false)

    sailing_config = sailing_config or {}
    sailing_config.cant_run = true

    local events = {
        SailingCommonHandlers.BoostByWaveHandler()
    }

    local states = {}

    SailingCommonStates.AddSailingStates(states, 
    sailing_config,
    {
        pre = idleanim,
        loop = idleanim,
        pst = idleanim,
    },
    nil,
    {
        pre = SAILSTART_TIME,
        loop = SAIL_TIME,
        pst = SAILSTOP_TIME,
    })

    CommonStates.AddAmphibiousCreatureHopStates(states,
    { -- config
        swimming_clear_collision_frame = 5*FRAMES,
        onenters = {
            hop_pre = hop_pre_onenter,
        }
    })

    for k, v in pairs(events) do
        assert(v:is_a(EventHandler), "Non-eventhandler added in mod event table!")
        sg.events[v.name] = v
    end
    for k, v in pairs(states) do
        assert(v:is_a(State), "Non-state added in mod state table!")
        sg.states[v.name] = v
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------

local function DespawnBoat(inst)
    local boat = inst.components.sailor:GetBoat()
    if boat then
        inst.components.sailor:Disembark(nil, true, true)
        boat:PushEvent("despawn")
    end
end

local function SpawnBoat(inst)
    DespawnBoat(inst)

    local boat = SpawnPrefab("boat_critter")

    if inst.boat_scale then
        boat.Transform:SetScale(inst.boat_scale, inst.boat_scale, inst.boat_scale)
    end
    boat.Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst.components.sailor:Embark(boat, true)
end

local function CancelNoLocomoteTask(inst)
    if inst._no_locomotor_task ~= nil then
        inst._no_locomotor_task:Cancel()
        inst._no_locomotor_task = nil
    end
    inst.components.locomotor.disable = false
end

local function StartNoLocomoteTask(inst)
    CancelNoLocomoteTask(inst)
    inst.components.locomotor.disable = true
    inst.components.locomotor:StopMoving()
    inst._no_locomotor_task = inst:DoTaskInTime(12*FRAMES, CancelNoLocomoteTask)
end

local function OnEnterWater(inst)
    inst.hop_distance = inst.components.locomotor.hop_distance
    inst.components.locomotor.hop_distance = 4
    SpawnBoat(inst)
    StartNoLocomoteTask(inst)
end

local function OnExitWater(inst)
    if inst.hop_distance then
        inst.components.locomotor.hop_distance = inst.hop_distance
    end
    DespawnBoat(inst)
    CancelNoLocomoteTask(inst)
end

-- inst.AnimState:SetFloatParams(cutoff_offset, idk but cutoff doesnt work if set to 0, bob_amount)
local function CLIENT_EmbarkedBoat(inst)
    inst.AnimState:SetFloatParams(-0.2, 1, 0.5)
end

local function CLIENT_DisembarkedBoat(inst)
    inst.AnimState:SetFloatParams(0, 0, 0)
end

local function IsValidWorld()
    local _world = TheWorld
    return _world:HasTag("island") or _world.has_ia_boats
end

IAENV.AddPrefabPostInitAny(function(inst)

    if not inst or not inst:HasTag("critter") or not IsValidWorld() then
        return
    end

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("embarkboat", CLIENT_EmbarkedBoat)
        inst:ListenForEvent("disembarkboat", CLIENT_DisembarkedBoat)
    end

    if not TheWorld.ismastersim
        or inst.components.locomotor == nil 
        or not inst.components.locomotor.allow_platform_hopping
        or inst.components.drownable == nil
        or inst:IsAmphibious() then
        return 
    end

    inst.components.drownable.enabled = false

    -- allow others to override us
    inst.boat_scale = inst.boat_scale or 0.8
    inst.momentum_follow_bonus = inst.momentum_follow_bonus or 5

    inst:AddComponent("sailor")
    inst:AddComponent("amphibiouscreature")
    inst.components.amphibiouscreature:SetEnterWaterFn(OnEnterWater)
    inst.components.amphibiouscreature:SetExitWaterFn(OnExitWater)
    inst.components.locomotor.pathcaps = inst.components.locomotor.pathcaps or {}
    inst.components.locomotor.pathcaps.allowocean = true

    -- allow others to override us
    PatchStategraph(inst.sg.sg, inst.boat_idle or "idle_loop")
end)

IAENV.AddPrefabPostInitAny(function(inst)

    if not inst or not inst:HasTag("kitcoon") or not IsValidWorld() then
        return
    end

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("embarkboat", CLIENT_EmbarkedBoat)
        inst:ListenForEvent("disembarkboat", CLIENT_DisembarkedBoat)
    end

    if not TheWorld.ismastersim then
        return 
    end

    inst.components.drownable.enabled = false

    -- allow others to override us
    inst.boat_scale = inst.boat_scale or 0.8
    inst.momentum_follow_bonus = inst.momentum_follow_bonus or 5

    inst:AddComponent("sailor")
    inst:AddComponent("amphibiouscreature")
    inst.components.amphibiouscreature:SetEnterWaterFn(OnEnterWater)
    inst.components.amphibiouscreature:SetExitWaterFn(OnExitWater)
    inst.components.locomotor.pathcaps = inst.components.locomotor.pathcaps or {}
    inst.components.locomotor.pathcaps.allowocean = true

    -- allow others to override us
    PatchStategraph(inst.sg.sg, inst.boat_idle or "idle_loop")
end)

local function TicoonSailStop(inst)
    if inst.components.entitytracker:GetEntity("tracking") then
        if inst.components.questowner.questcomplete then
            inst.sg:GoToState("searching") 
        elseif inst.components.follower.leader then
            inst.sg:GoToState("waiting")
        end
    end
end

local ticoon_config =     
{
    onenters = {
        pst = TicoonSailStop
    },
    ontimeouts = {
        pst = TicoonSailStop
    }
}

IAENV.AddPrefabPostInit("ticoon", function(inst)
    if not IsValidWorld() then
        return
    end

    if not TheNet:IsDedicated() then
        inst:ListenForEvent("embarkboat", CLIENT_EmbarkedBoat)
        inst:ListenForEvent("disembarkboat", CLIENT_DisembarkedBoat)
    end

    if not TheWorld.ismastersim then
        return
    end

    inst.components.drownable.enabled = false

    inst.boat_scale = 0.9
    inst.momentum_follow_bonus = 7

    inst:AddComponent("sailor")
    inst:AddComponent("amphibiouscreature")
    inst.components.amphibiouscreature:SetEnterWaterFn(OnEnterWater)
    inst.components.amphibiouscreature:SetExitWaterFn(OnExitWater)
    inst.components.locomotor.pathcaps = inst.components.locomotor.pathcaps or {}
    inst.components.locomotor.pathcaps.allowocean = true

    PatchStategraph(inst.sg.sg, "idle_loop", ticoon_config)
end)
