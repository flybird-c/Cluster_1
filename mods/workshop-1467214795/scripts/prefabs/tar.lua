local itemassets =
{
	Asset("ANIM", "anim/tar.zip"),
}
local assets =
{
	Asset("ANIM", "anim/tar_trap.zip"),
}

local itemprefabs=
{
	"tar_trap",
}

local function OnUse(inst, slowinst)
    if not inst.used then
        inst.used = slowinst.sg and slowinst.sg:HasStateTag("moving")
    end
end

local function UpdateSlowdown(self)
    local inst = self.inst

	if inst.used then
		if not inst.components.fueled.consuming then
			inst.components.fueled:StartConsuming()
		end
	else
		if inst.components.fueled.consuming then
			inst.components.fueled:StopConsuming()
		end
	end
	inst.used = false
end

local function CanSlow(self, slowinst)
    return slowinst.components.locomotor ~= nil 
        and slowinst.components.locomotor.enablegroundspeedmultiplier 
end

local function updateAnim(inst,section)
	if section == 1 then
		inst.AnimState:PlayAnimation("idle_25")
	elseif section == 2 then
		inst.AnimState:PlayAnimation("idle_50")
	elseif section == 3 then
		inst.AnimState:PlayAnimation("idle_75")
	elseif section == 4 then
		inst.AnimState:PlayAnimation("idle_full")
	end
end

local function ontakefuelfn(inst)
	-- inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/machine_fuel")
	updateAnim(inst,inst.components.fueled:GetCurrentSection())
end

local function sectionfn(section, oldsection, inst)
	if section == 0 then
		--when we burn out
		if inst.components.burnable then
			inst.components.burnable:Extinguish()
		end
	else
		updateAnim(inst, section)
	end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetLayer( LAYER_BACKGROUND )
	inst.AnimState:SetSortOrder( 3 )

	inst.AnimState:SetBank("tar_trap")
	inst.AnimState:SetBuild("tar_trap")

	inst.AnimState:PlayAnimation("idle_full")

	inst:AddTag("moistureimmunity")
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

    inst:AddComponent("slowingobject")
    inst.components.slowingobject.key = "TAR"
    inst.components.slowingobject.detectradius = 5
    inst.components.slowingobject.range = 1.5
    inst.components.slowingobject.detectperiod = 6 * FRAMES
    inst.components.slowingobject.delay = FRAMES
    inst.components.slowingobject.CanSlow = CanSlow
    inst.components.slowingobject.UpdateSlowdown = UpdateSlowdown
    inst.components.slowingobject.OnUse = OnUse

	inst:AddComponent("inspectable")

	MakeHauntableLaunch(inst)

	MakeLargeBurnable(inst, TUNING.SMALL_BURNTIME)
	MakeLargePropagator(inst)

	inst:AddComponent("fueled")
	inst.components.fueled.fueltype = FUELTYPE.TAR
	inst.components.fueled.accepting = true
	inst.components.fueled.ontakefuelfn = ontakefuelfn
	inst.components.fueled:SetSections(4)
	inst.components.fueled:InitializeFuelLevel(TUNING.TAR_TRAP_TIME/2)
	inst.components.fueled:SetDepletedFn(inst.Remove)
	inst.components.fueled:SetSectionCallback(sectionfn)

	return inst
end


local function quantizepos(pt)
	local x, y, z = TheWorld.Map:GetTileCenterPoint(pt:Get())

	if pt.x > x then
		x = x + 1
	else
		x = x - 1
	end

	if pt.z > z then
		z = z + 1
	else
		z = z - 1
	end

	return Vector3(x,y,z)
end

local function quantizeplacer(inst)
	inst.Transform:SetPosition(quantizepos(inst:GetPosition()):Get())
end

local function oncannotbuild(inst)
	inst:Hide()
	for i, v in ipairs(inst.components.placer.linked) do
		v:Hide()
	end
end

local function placerpostinitfn(inst)
	inst.components.placer.onupdatetransform = quantizeplacer
	inst.components.placer.oncannotbuild = oncannotbuild
end

local function ondeploy(inst, pt, deployer)
    local wall = SpawnPrefab("tar_trap")

	if wall then
		pt = quantizepos(pt)
		wall.AnimState:PlayAnimation("place")
		wall.AnimState:PushAnimation("idle_full")
		wall.Physics:Teleport(pt.x, pt.y, pt.z)

		inst.components.stackable:Get():Remove()

		wall.SoundEmitter:PlaySound("ia/common/poop_splat")
	end
end

local function CanDeploy(inst, pt)
    local _map = TheWorld.Map
    return _map:CanDeployWallAtPoint(inst, pt) and IsLandTile(_map:GetVisualTileAtPoint(pt.x, pt.y, pt.z, 0.4))
end

local function itemfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("tar")
	inst.AnimState:SetBuild("tar")

	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("tar")
	inst:AddTag("moistureimmunity")
	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

	inst._custom_candeploy_fn = CanDeploy

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)

	inst:AddComponent("inventoryitem")

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("tradable")

	inst:AddComponent("inspectable")

	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
	inst.components.fuel.secondaryfueltype = FUELTYPE.TAR

	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
	MakeSmallPropagator(inst)

	inst:AddComponent("deployable")
	inst.components.deployable.ondeploy = ondeploy
	inst.components.deployable:SetDeploySpacing(DEPLOYMODE.CUSTOM)
	inst.components.deployable.deploydistance = 2

	return inst
end

return Prefab( "tar", itemfn, itemassets, itemprefabs),
	Prefab("tar_trap", fn, assets),
	MakePlacer("tar_placer",  "tar_trap", "tar_trap", "idle_full", false, false, false, 1, nil, nil, placerpostinitfn)
