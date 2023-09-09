local assets=
{
	Asset("ANIM", "anim/tuna.zip"),
}

local prefabs =
{
    "fishmeat_cooked",
}    

local function OnUnWrappedFn(inst, pos, doer)
    if doer and doer.SoundEmitter then
        doer.SoundEmitter:PlaySound("ia/common/can_open")
    else
        --This sound does not play on client, presumably because the Remove gets networked/processed first. -M
        inst.SoundEmitter:PlaySound("ia/common/can_open")
    end
    inst:Remove()
    local steak = SpawnPrefab("fishmeat_cooked")
    if doer and doer.components.inventory then
        --TODO test if we're in the doers inv, remember the slot, and put the steak there. -M
        doer.components.inventory:GiveItem(steak)
    else
        steak.Transform:SetPosition(pos:Get())
        steak.components.inventoryitem:OnDropped(false, .5)
    end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("tuna")
    inst.AnimState:SetBuild("tuna")
    inst.AnimState:PlayAnimation("idle")
    
    inst.pickupsound = "metal"

    MakeInventoryPhysics(inst)

	MakeInventoryFloatable(inst)
	inst.components.floater:UpdateAnimations("idle_water", "idle")

    inst:AddTag("tincan")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)
    
    inst:AddComponent("inspectable")

    MakeHauntableLaunch(inst)
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = 1

    -- inst:AddComponent("useableitem")
    -- inst.components.useableitem.verb = "OPEN"
    -- inst.components.useableitem:SetCanInteractFn(function() return true end)
    -- inst.components.useableitem:SetOnUseFn(function(inst)
        -- inst.SoundEmitter:PlaySound("ia/common/can_open")
        -- local steak = SpawnPrefab("fishmeat_cooked")
        -- ThePlayer.components.inventory:GiveItem(steak)
        -- inst:Remove()
    -- end)
	
	inst:AddComponent("unwrappable")
	-- inst.components.unwrappable.itemdata = {{prefab = "fishmeat_cooked"}}
	inst.components.unwrappable.onunwrappedfn = OnUnWrappedFn

    return inst
end

return Prefab("tunacan", fn, assets, prefabs)
