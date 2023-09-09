local assets = {
    Asset("ANIM", "anim/flotsam.zip"),
    Asset("ANIM", "anim/flotsam_debris.zip"),
}

local prefabs = {
    "flotsam_debris",
}

local flotsam_loot =
{
    ['log']                  = 2.00,
    ['twigs']                = 2.00,
    ['cutgrass']             = 2.00,

    ['boards']               = 1.00,
    ['rope']                 = 1.00,

    ['sunken_boat_trinket_1']  = 0.65,
    ['sunken_boat_trinket_2']  = 0.75,
    ['sunken_boat_trinket_3']  = 0.65,
    --['sunken_boat_trinket_4']  = 0.50,
    ['sunken_boat_trinket_5']  = 0.90,
}

local debris_assets = {
    Asset("ANIM", "anim/boards.zip"),
}

local debris_prefabs = {}

for prefab,chance in pairs(flotsam_loot) do
    table.insert(debris_prefabs, prefab)
end

local DEBRIS_WIDTH = 4

local function SpawnDebris(inst)
    local debris = SpawnPrefab("flotsam_debris")
    debris.entity:SetParent(inst.entity)
    debris.localoffset = Vector3(math.random()*DEBRIS_WIDTH - DEBRIS_WIDTH/2, -0.5, math.random()*DEBRIS_WIDTH - DEBRIS_WIDTH/2)
    debris.Transform:SetPosition(debris.localoffset.x, debris.localoffset.y, debris.localoffset.z)
    debris:AddTag("NOCLICK")
    debris:ListenForEvent("onremove", function() debris:Remove() end, inst)

    return debris
end

local function OnCollide(inst, other)
    if other ~= nil and other:IsValid() and (other == TheWorld or other:HasTag("BLOCKER") or other.components.boatphysics) then
        if inst.components.drifter ~= nil then
            inst.components.drifter:Stop()
        end
    end
end

local function UpdateDebris(inst, softremove)
    if not inst.debris then
        inst.debris = {}
    end

    local currentcount = 0

    for k,v in pairs(inst.debris) do
        currentcount = currentcount + 1
    end

    local num_debris = inst.components.flotsamfisher.lootleft
    local tospawn = num_debris - currentcount

    --print("HAS", currentcount, "WANTS", num_debris, "DELTA BY", tospawn)

    if tospawn < 0 then
        local todestroy = math.abs(tospawn)
        while todestroy > 0 do
            local d = GetRandomItem(inst.debris)
            if d then
                inst.debris[d] = nil
                d:Remove()
            end
            todestroy = todestroy - 1
        end
    else
        for i = 1, tospawn do
            local d = SpawnDebris(inst)
            inst.debris[d] = d
        end
    end
end

local function OnFish(inst, retriever)
    UpdateDebris(inst)
end

local function OnTimer(inst, timerdata)
    if timerdata.name == "decay" then
        inst.components.flotsamfisher:DeltaLoot(-1)
        if inst.components.flotsamfisher.lootleft > 0 then
            UpdateDebris(inst, true)
            inst.components.timer:StartTimer("decay", TUNING.FLOTSAM_DECAY_TIME)
        end
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst:AddTag("blocker")
    inst.entity:AddPhysics()
    inst.Physics:SetMass(100)
    inst.Physics:SetFriction(.1)
	inst.Physics:SetRestitution(.5)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:SetCapsule(0.5, 0.2)

    inst:AddComponent("waterphysics")
    inst.components.waterphysics.restitution = 0.1
    inst.components.waterphysics:SetIsWeak(true)

    inst.AnimState:SetBank("flotsam")
    inst.AnimState:SetBuild("flotsam")
    inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
	inst.AnimState:SetLayer( LAYER_BACKGROUND )

    --just like Boat fragments, flotsam are always wet!
    inst:AddTag("wet")
    --inst:AddTag("FARSELECT")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.WOOD
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 0

    inst:AddComponent("drifter")
    inst.components.drifter.radius = DEBRIS_WIDTH/2 + 3

    inst.Physics:SetCollisionCallback(OnCollide)

    inst:AddComponent("flotsamfisher")
    inst.components.flotsamfisher.flotsam_loot = flotsam_loot
    inst.components.flotsamfisher.onfishfn = OnFish
    inst.components.flotsamfisher.lootleft = math.random(2, 4)

    inst:AddComponent("inspectable")

    UpdateDebris(inst)

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("decay", TUNING.FLOTSAM_DECAY_TIME)
    inst:ListenForEvent("timerdone", OnTimer)

    inst.SoundEmitter:PlaySound("dontstarve/creatures/teasertheparrot/wreckage", "flotsam_loop")

    return inst
end

-- local function swish(inst)
--     local x,y,z = inst.entity:GetParent().Transform:GetWorldPosition()
--     x = inst.localoffset.x + math.sin(GetTime()*3 + inst.localoffset.x + x)*.2
--     y = inst.localoffset.y + math.sin(GetTime()*3)*.1
--     z = inst.localoffset.z + math.sin(GetTime()*3 + inst.localoffset.z + z)*.2
--     inst.Transform:SetPosition(x,y,z)
-- end

local function OnDebrisReplicated(inst)
    local parent = inst.entity:GetParent()
    if parent ~= nil and parent.prefab == "flotsam" then
        if parent.highlightchildren == nil then
            parent.highlightchildren = { inst }
        else
            table.insert(parent.highlightchildren, inst)
        end
    end
end

local debris_anims = {
    "idle",
    "idle2",
    "idle3",
    "idle4",
    "idle5",
    "idle6",
    "idle7",
    "idle8",
    "idle9",
}

local function debris_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("flotsam_debris")
    inst.AnimState:SetBuild("flotsam_debris")
    inst.anim_append = debris_anims[math.random(1, #debris_anims)]
    inst.AnimState:PlayAnimation(inst.anim_append, true)

    --improvement for multiplayer
    --maybe a unique spawn anim would be best?
    inst:AddComponent("spawnfader")

    inst.localoffset = Vector3(0,0,0)
    --inst:DoPeriodicTask(0, swish)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst.OnEntityReplicated = OnDebrisReplicated

        return inst
    end

    return inst
end

return Prefab("flotsam", fn, assets, prefabs),
        Prefab("flotsam_debris", debris_fn, debris_assets, debris_prefabs)
