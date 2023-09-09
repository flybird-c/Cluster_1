local assets =
{
  Asset("ANIM", "anim/coral_rock.zip"),
  Asset("MINIMAP_IMAGE", "rock_coral")
}

local prefabs = {
  'coral',
  'limestonenugget',
  'coral_underwater_fx',
}

SetSharedLootTable( 'coral_full',
  {
    {'coral', 1.00},
    {'coral', 0.50},
  })

SetSharedLootTable( 'coral_med',
  {
    {'coral', 1.00},
    {'coral', 0.25},
  })

SetSharedLootTable( 'coral_low',
  {
    {'limestonenugget', 1.00},
    {'limestonenugget', 0.66},
    {'limestonenugget', 0.33},
	{'corallarve', 1.00},
  })

local function growtime(inst) return TUNING.TOTAL_DAY_TIME * 6 end

local function SetLow(inst)
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.AnimState:PlayAnimation('low'..inst.animnumber, true)
    inst.underwater.AnimState:PlayAnimation('low'..inst.animnumber, true)
    inst.components.workable:SetWorkLeft(1)
    inst.components.growable:StartGrowing()
    inst.components.lootdropper:SetChanceLootTable('coral_low')
end

local function SetMedium(inst)
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.AnimState:PlayAnimation('med'..inst.animnumber, true)
    inst.underwater.AnimState:PlayAnimation('med'..inst.animnumber, true)
    inst.components.workable:SetWorkLeft(TUNING.CORAL_MIN - 4)
    inst.components.growable:StartGrowing()
    inst.components.lootdropper:SetChanceLootTable('coral_med')
end

local function SetFull(inst)
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.AnimState:PlayAnimation('full'..inst.animnumber, true)
    inst.underwater.AnimState:PlayAnimation('full'..inst.animnumber, true)
    inst.components.workable:SetWorkLeft(TUNING.CORAL_MINE)
    inst.components.lootdropper:SetChanceLootTable('coral_full')
end

local growth_stages ={
    { name = "low", time = growtime, fn = SetLow, anim = "low" },
    { name = "med", time = growtime, fn = SetMedium, transition = "low_to_med", anim = "med" },
    { name = "full", fn = SetFull, transition = "med_to_full", anim = "full" }
}

local function OnGrowth(inst, last, current)
    if growth_stages[current].transition then
        inst.AnimState:PlayAnimation(growth_stages[current].transition..inst.animnumber)
        inst.AnimState:PushAnimation(growth_stages[current].anim..inst.animnumber, true)
        inst.underwater.AnimState:PlayAnimation(growth_stages[current].transition..inst.animnumber)
        inst.underwater.AnimState:PushAnimation(growth_stages[current].anim..inst.animnumber, true)
    else
        inst.AnimState:PlayAnimation(growth_stages[current].anim..inst.animnumber, true)
        inst.underwater.AnimState:PlayAnimation(growth_stages[current].anim..inst.animnumber, true)
    end
end

local function OnWork(inst, worker, workleft, numworks)
    local pt = Point(inst.Transform:GetWorldPosition())
	if workleft <= 0 and inst.components.growable.stage == 1 then
		--Hammered
        inst.SoundEmitter:PlaySound("ia/common/coral_break")
        SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst.components.lootdropper:DropLoot(pt)
        inst:Remove()
    else
        if workleft <= 1 and inst.components.growable.stage ~= 1 then
            inst.SoundEmitter:PlaySound("ia/common/coral_break")
            inst.components.lootdropper:DropLoot(pt)
            inst.components.growable:SetStage(1)
        elseif workleft <= 5 and workleft > 1 and inst.components.growable.stage ~= 2 then
            inst.components.lootdropper:DropLoot(pt)
            inst.components.growable:SetStage(2)
            -- inst.SoundEmitter:PlaySound("ia/common/coral_mine")
        end
    end
end

local function OnSave(inst, data)
    data.animnumber = inst.animnumber
    data.stage = inst.components.growable.stage
end

local function OnLoad(inst, data)
    if data then
        inst.animnumber = data.animnumber or math.random(1, 3)

        inst.components.growable:SetStage(data.stage and data.stage or 3)
    end    
end

local LappingSound
local function StartLappingSound(inst)
    local dt = 3 + math.random()*3
    inst.task = inst:DoTaskInTime(dt, function(inst) LappingSound(inst) end)
end
LappingSound = function(inst)
    inst.SoundEmitter:PlaySound("ia/common/lapping_coral")
    StartLappingSound(inst)
end

local function OnWake(inst)
    StartLappingSound(inst)
end
local function OnSleep(inst)
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
end

local DAMAGE_SCALE = 0.3
local function OnCollide(inst, data)
    local boat_physics = data.other.components.boatphysics
    if boat_physics ~= nil then
        local hit_velocity = math.floor(math.abs(boat_physics:GetVelocity() * data.hit_dot_velocity) * DAMAGE_SCALE / boat_physics.max_velocity + 0.5)
        -- TODO custom tuning
        inst.components.workable:WorkedBy(data.other, hit_velocity * TUNING.SEASTACK_MINE)
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("coral_rock")
    inst.AnimState:SetBuild("coral_rock")

    inst.AnimState:HideSymbol("coral_underwater")

    MakeWaterObstaclePhysics(inst, 1.33, nil, 0.75)

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("rock_coral.tex")

    inst:AddTag("coral")
    
    MakeSnowCoveredPristine(inst)
    
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.underwater = SpawnPrefab("coral_underwater_fx")
    inst.underwater.entity:SetParent(inst.entity)
    inst.underwater.Transform:SetPosition(0,0,0)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('coral_full')

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.CORAL_MINE)

    inst.components.workable:SetOnWorkCallback(OnWork)

    local r = 0.8 + math.random() * 0.2
    local g = 0.8 + math.random() * 0.2
    local b = 0.8 + math.random() * 0.2
    -- inst.AnimState:SetMultColour(r, g, b, 1)
    -- No longer colours the wake like in sw
    inst.AnimState:SetSymbolMultColour("coral_base", r, g, b, 1)
    inst.AnimState:SetSymbolMultColour("coral_leaf", r, g, b, 1)
    inst.animnumber = math.random(1, 3)

    inst:AddComponent("growable")
    inst.components.growable.stages = growth_stages
    inst:DoTaskInTime(0, function(inst)
        inst.components.growable:SetOnGrowthFn(OnGrowth)
        end)
    inst.components.growable:SetStage(3)

    --inst:AddComponent("waveobstacle")

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    MakeSnowCovered(inst, .01)

    inst:ListenForEvent("on_collide", OnCollide)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

local function underwaterfxfn()
  local inst = CreateEntity()

  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddNetwork()

  inst.AnimState:SetBank("coral_rock")
  inst.AnimState:SetBuild("coral_rock")

  inst.AnimState:SetLayer(LAYER_BACKGROUND)

  inst.AnimState:HideSymbol("coral_base")
  inst.AnimState:HideSymbol("coral_leaf")
  inst.AnimState:HideSymbol("ripple2")
  inst.AnimState:HideSymbol("wake")
    
  inst:AddTag("DECOR")

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
      return inst
  end

inst.persists = false

return inst
end

return Prefab("rock_coral", fn, assets, prefabs),
Prefab("coral_underwater_fx", underwaterfxfn, assets, prefabs)