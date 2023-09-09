local assets = {
    Asset("ANIM", "anim/gunpowder_barrel.zip"),
    Asset("ANIM", "anim/explode.zip"),
    Asset("MINIMAP_IMAGE", "barrel_gunpowder")
}

local prefabs = {
    "explode_large",
}

local function OnIgnite(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
end

local function OnExtinguishFn(inst)
    inst.SoundEmitter:KillSound("hiss")
    DefaultExtinguishFn(inst)
end

local function OnExplode(inst)
    inst.SoundEmitter:KillSound("hiss")

    local pos = inst:GetPosition()
    SpawnWaves(inst, 6, 360, 5)
    local splash = SpawnPrefab("bombsplash")
    splash.Transform:SetPosition(pos.x, pos.y, pos.z)

    inst.SoundEmitter:PlaySound("ia/common/powderkeg/powderkeg")
    inst.SoundEmitter:PlaySound("ia/common/powderkeg/splash_medium")
end

local function OnExplodeLand(inst)
    inst.SoundEmitter:KillSound("hiss")
    inst.SoundEmitter:PlaySound("ia/common/powderkeg/powderkeg")
    SpawnPrefab("explode_large").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function OnHit(inst)
    if inst.components.burnable then
        inst.components.burnable:Ignite()
    end
    if inst.components.freezable then
        inst.components.freezable:UnFreeze()
    end
    if inst.components.health then
        inst.components.health:DoFireDamage(0)
    end
end

local function OnHaunt(inst)
	if math.random() <= TUNING.HAUNT_CHANCE_HALF then
		OnHit(inst)
	end
end

local function OnCollide(inst, data)
    local other_boat_physics = data.other.components.boatphysics
    if other_boat_physics == nil then
        return
    end

    local hit_velocity = math.abs(other_boat_physics:GetVelocity() * data.hit_dot_velocity) / other_boat_physics.max_velocity
    if hit_velocity > 1.25 then
		OnHit(inst)
    end
end

local function MakeBarrel(name, land)
    local function fn()
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()
        inst.entity:AddMiniMapEntity()

        inst.MiniMapEntity:SetIcon("barrel_gunpowder.tex")

        MakeWeakWaterObstaclePhysics(inst, 0, 0.8, 2, 0.75)

        inst.AnimState:SetBank("gunpowder_barrel")
        inst.AnimState:SetBuild("gunpowder_barrel")

        inst.AnimState:PlayAnimation(land and "idle" or "idle_water", true)

        if not land then
            inst.AnimState:OverrideSymbol("water_ripple", "ripple_build", "water_ripple")
            inst.AnimState:OverrideSymbol("water_shadow", "ripple_build", "water_shadow")
        end

        inst:AddTag("soulless")
        inst:AddTag("poisonimmune")
        inst:AddTag("explosive")
        
        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inspectable")
        
        if land then
            inst.components.inspectable.nameoverride = "barrel_gunpowder"
        end

        inst:AddComponent("hauntable")
        inst.components.hauntable.onhaunt = OnHaunt
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(1000000)
    
        inst:AddComponent("combat")
        inst.components.combat:SetOnHit(OnHit)
    
        MakeSmallBurnable(inst, 3 + math.random() * 3)
        MakeSmallPropagator(inst)
    
        inst.components.burnable:SetOnBurntFn(nil)
        inst.components.burnable:SetOnIgniteFn(OnIgnite)
        inst.components.burnable:SetOnExtinguishFn(OnExtinguishFn)
    
        inst:AddComponent("explosive")
        inst.components.explosive:SetOnExplodeFn(land and OnExplodeLand or OnExplode)
        inst.components.explosive.explosiverange = TUNING.BARREL_GUNPOWDER_RANGE
        inst.components.explosive.explosivedamage = TUNING.BARREL_GUNPOWDER_DAMAGE
        inst.components.explosive.buildingdamage = 10

        if not land then
            inst:ListenForEvent("on_collide", OnCollide)
        end

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

return MakeBarrel("barrel_gunpowder"),
       MakeBarrel("barrel_gunpowder_land", true)
