local assets = {
	Asset("ANIM", "anim/quacken_drill.zip"),
}

local SHAKE_DIST = 40

local function spawnoil(inst, pt)
	local oil = SpawnPrefab("tar_pool")
	if oil then
		oil.Transform:SetPosition(pt.x, pt.y, pt.z)
		oil.AnimState:PlayAnimation("place")
		oil.AnimState:PushAnimation("idle", true)
	end
	inst:Remove()
end

local function nextstage(inst, pt)
	if not inst.drillstage then
		inst.AnimState:PlayAnimation("idle", true)
		inst.drillstage = 1
		inst:DoTaskInTime(2, function(inst) nextstage(inst, pt) end)
	elseif inst.drillstage == 1 then
		inst.SoundEmitter:PlaySound("ia/common/quacken_drill/drill")
		inst.AnimState:PlayAnimation("drill")
		inst:ListenForEvent("animover", function(inst) nextstage(inst, pt) end)
		inst.drillstage = 2
	else
		inst.SoundEmitter:PlaySound("ia/common/quacken_drill/underwater_hit")
        ShakeAllCameras(CAMERASHAKE.FULL, 0.7, 0.02, 3, pt, SHAKE_DIST)
		inst:Hide()
		inst:DoTaskInTime(2, function(inst) spawnoil(inst,pt)  end)
	end
end

local function ondeploy(inst, pt, deployer)
	inst:RemoveComponent("inventoryitem")
	inst.Transform:SetPosition(pt.x, pt.y, pt.z)
	inst.AnimState:PlayAnimation("place")
	inst.SoundEmitter:PlaySound("ia/common/quacken_drill/ramp")
	inst:ListenForEvent( "animover", function() nextstage(inst,pt) end)
end

local function test_ground(tile)
	return tile ~= WORLD_TILES.OCEAN_SHIPGRAVEYARD and IsUnBuildableOceanTile(tile)
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)

	inst.AnimState:SetBank("quacken_drill")
	inst.AnimState:SetBuild("quacken_drill")
	inst.AnimState:PlayAnimation("dropped")

	inst:AddTag("fire_proof")

    inst._tile_candeploy_fn = test_ground

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	MakeHauntableLaunch(inst)

	inst:AddComponent("inventoryitem")

	inst:AddComponent("deployable")
	inst.components.deployable.ondeploy = ondeploy
	inst.components.deployable:SetDeployMode(DEPLOYMODE.WATER)

	return inst
end

return Prefab("quackendrill", fn, assets),
	   MakePlacer("quackendrill_placer", "quacken_drill", "quacken_drill", "placer")
