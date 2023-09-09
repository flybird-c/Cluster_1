local assets=
{
	Asset("ANIM", "anim/portal_shipwrecked.zip"),
	Asset("ANIM", "anim/portal_shipwrecked_build.zip"),
}

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:SetTime(0.65 * inst.AnimState:GetCurrentAnimationLength())
	inst.AnimState:PushAnimation("idle_off")
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle_off")
	inst.SoundEmitter:PlaySound("ia/common/portal/place")
end

local function OnActivate(inst, doer)
	local paras = {player = doer, portalid = 998, worldid = (TheWorld:HasTag("island") or TheWorld:HasTag("volcano")) and IA_CONFIG.forestid or IA_CONFIG.shipwreckedid}

	if IA_CONFIG.quickseaworthy then
		inst.components.activatable.inactive = true
		TheWorld:PushEvent("ms_playerdespawnandmigrate", paras)
	else
		inst.components.workable:SetWorkable(false)
		doer.player_classified.ishudvisible:set(false)
		ChangeToObstaclePhysics(doer)
		doer:PushEvent("shipwrecked_portal")

		inst:DoTaskInTime(7.5, function()
			ChangeToCharacterPhysics(doer)
			TheWorld:PushEvent("ms_playerdespawnandmigrate", paras)
		end)

		inst:DoTaskInTime(8, function(_inst)
			_inst:Show()
			ChangeToObstaclePhysics(_inst)
			_inst.components.activatable.inactive = true
			_inst.components.workable:SetWorkable(true)
		end)
	end
end

local function Open(inst)
    inst.AnimState:PushAnimation("idle_off")

	inst.components.workable:SetWorkable(true)
    inst.components.activatable.inactive = true

	inst.components.inspectable.nameoverride = nil
	inst.components.named:SetName(nil)
end

local function Close(inst)
	inst.AnimState:PlayAnimation("idle_broken")

	inst.components.workable:SetWorkable(false)
    inst.components.activatable.inactive = false
	
	inst.components.inspectable.nameoverride = "portal_shipwrecked"
	inst.components.named:SetName(STRINGS.NAMES.PORTAL_SHIPWRECKED)
end

local function onloadpostpass(inst)
	if inst.components.worldmigrator then
		inst.components.worldmigrator:SetDestinationWorld(nil, true)
	end
end

local function OnHaunt(inst, haunter)
	if inst.components.workable.workable then
		local paras = {player = haunter, portalid = 998, worldid = (TheWorld:HasTag("island") or TheWorld:HasTag("volcano")) and IA_CONFIG.forestid or IA_CONFIG.shipwreckedid}
		TheWorld:PushEvent("ms_playerdespawnandmigrate", paras)
	end
end

local _SetDestinationWorld = nil
local function SetDestinationWorld(self, world, permanent, ...)
	world = nil
	--ensure it link forest or ia world  -Jerry
	if TheWorld:HasTag("island") or TheWorld:HasTag("volcano") then
		world = IA_CONFIG.forestid
	else
		world = IA_CONFIG.shipwreckedid
	end

	if world then
		Open(self.inst)
	else
		Close(self.inst)
	end

	_SetDestinationWorld(self, world, permanent, ...)
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

    inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetIcon("shipwrecked_exit.tex")

	MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("boatportal")
    inst.AnimState:SetBuild("portal_shipwrecked_build")
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle_off")

    inst:AddTag("shipwrecked_portal")

	inst.no_wet_prefix = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")

	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	inst:AddComponent("activatable")
	inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.inactive = false
	inst.components.activatable.quickaction = true
	inst.components.activatable.forcenopickupaction = true

	inst:AddComponent("worldmigrator")
	inst.components.worldmigrator.id = 998
	inst.components.worldmigrator.receivedPortal = 998
	inst.components.worldmigrator:SetEnabled(false)
	if not _SetDestinationWorld then
		_SetDestinationWorld = inst.components.worldmigrator.SetDestinationWorld
	end
    inst.components.worldmigrator.SetDestinationWorld = SetDestinationWorld

	inst:AddComponent("hauntable")
	inst.components.hauntable.onhaunt = OnHaunt
	inst.components.hauntable.hauntvalue = TUNING.HAUNT_LARGE

	inst:AddComponent("named")

	inst:ListenForEvent("onbuilt", onbuilt)

	inst.OnLoadPostPass = onloadpostpass

	if not TheShard:GetDefaultShardEnabled() then
		Close(inst)
	end

    return inst
end


SetSharedLootTable('shipwrecked_exit',
{
    {'sunken_boat_trinket_4', 1},
    {'nightmarefuel', 1},
	{'nightmarefuel', 1},
	{'livinglog', 1},
	{'livinglog', 1},
})

-- backwards compatability
local function exit_fn()
	local inst = fn()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.components.lootdropper:SetChanceLootTable('shipwrecked_exit')

	-- for the moment these two prefabs are identical, but leave them as separate prefabs in case
	-- the behaviour ever changes between SW and Forest
	return inst
end

return Prefab("shipwrecked_entrance", fn, assets),
	MakePlacer("shipwrecked_entrance_placer", "boatportal", "portal_shipwrecked_build", "idle_off"),
	Prefab("shipwrecked_exit", exit_fn, assets)
