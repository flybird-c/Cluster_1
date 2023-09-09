-- Debug weapon of mass glitchiness
-- TODO: USE UNDERTILE!!!!

local assets =
{
	Asset("ANIM", "anim/trident.zip"),
	Asset("ANIM", "anim/swap_trident.zip"),
}

local prefabs = {}


local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_staffs", "swap_opalstaff")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function terraform(staff, target, pt)
    local caster = staff.components.inventoryitem.owner

    local world = TheWorld
    local map = world.Map

    local original_tile_type = map:GetTileAtPoint(pt:Get())
    local x, y = map:GetTileCoordsAtPoint(pt:Get())

    local targettile = staff.targettile or WORLD_TILES.OCEAN_SHALLOW

    if IsOceanTile(original_tile_type) then
        targettile = WORLD_TILES.DIRT
    end

    map:SetTile(x, y, targettile)
end

local function light_reticuletargetfn()
    return Vector3(ThePlayer.entity:LocalToWorldSpace(5, 0, 0))
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("trident")
	inst.AnimState:SetBuild("trident")
	inst.AnimState:PlayAnimation("idle")

    inst:AddTag("nopunch")
    inst:AddTag("allow_action_on_impassable")

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = light_reticuletargetfn
    inst.components.reticule.ease = true

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(terraform)
    inst.components.spellcaster.canuseonpoint_water = true
    inst.components.spellcaster.canuseonpoint = true
    inst.components.spellcaster.quickcast = true

    return inst
end

return Prefab("terraformstaff", fn, assets, prefabs)
