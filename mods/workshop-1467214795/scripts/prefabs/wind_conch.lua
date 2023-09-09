local assets=
{
    Asset("ANIM", "anim/wind_conch.zip"),
	Asset("ANIM", "anim/swap_wind_conch.zip"),
}

local function onfinished(inst)
    inst:Remove()
end

local function PlayWindConch(inst, musician, instrument)
    if IsInIAClimate(musician) then
        TheWorld:PushEvent("ms_forcehurricane",  TUNING.HURRICANE_WIND_CONCH_LENGTH)
    else
        TheWorld:PushEvent("ms_forceprecipitation")
    end
end

local function HearWindConch(inst, musician, instrument)
    if inst.components.farmplanttendable ~= nil then
		inst.components.farmplanttendable:TendTo(musician)
    end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddNetwork()

	inst:AddTag("horn")

    inst.AnimState:SetBank("wind_conch")
    inst.AnimState:SetBuild("wind_conch")
    inst.AnimState:PlayAnimation("idle")

    inst.hornbuild = "swap_wind_conch"
    inst.hornsymbol = "swap_horn"

    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst)
    inst.components.floater:UpdateAnimations("idle_water", "idle")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    MakeHauntableLaunch(inst)

    inst:AddComponent("instrument")
    inst.components.instrument.range = TUNING.HORN_RANGE
    inst.components.instrument:SetOnHeardFn(HearWindConch)
    inst.components.instrument:SetOnPlayedFn(PlayWindConch)
    inst.components.instrument.sound = "ia/common/magic_seal_conch"

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.PLAY)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.WIND_CONCH_USES)
    inst.components.finiteuses:SetUses(TUNING.WIND_CONCH_USES)
    inst.components.finiteuses:SetOnFinished(onfinished)
    inst.components.finiteuses:SetConsumption(ACTIONS.PLAY, 1)

    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab("wind_conch", fn, assets)
