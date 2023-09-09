local assets =
{
    Asset("ANIM", "anim/twister_build.zip"),
    Asset("ANIM", "anim/twister_seal.zip"),
}


SetSharedLootTable("twister_seal",
{
	{"meat", 1.00},	
	{"meat", 1.00},	
	{"meat", 1.00},	
	{"meat", 1.00},
	{"magic_seal", 1.00},
	{"chesspiece_seal_sketch", 1.00},
	--Drop an item here too?
})

local function OnEntitySleep(inst)
	--This means the player let the seal live.
	--Let the seal escape & leave a gift of some sort behind.
	local seal = SpawnPrefab("magic_seal")
	local sketch = SpawnPrefab("chesspiece_seal_sketch")
	seal.Transform:SetPosition(inst:GetPosition():Get())
	sketch.Transform:SetPosition(inst:GetPosition():Get())
	inst:Remove()
end

local function fn()
    local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

	MakePoisonableCharacter(inst)
	MakeCharacterPhysics(inst, 1000, 1)
	inst.DynamicShadow:SetSize(2.5, 1.5)

	inst.Transform:SetTwoFaced()

	inst.AnimState:SetBank("twister")
	inst.AnimState:SetBuild("twister_build")
	inst.AnimState:PlayAnimation("seal_idle", true)

	inst:AddTag("noepicmusic")
    inst:AddTag("ignorewalkableplatformdrowning")

  	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetChanceLootTable("twister_seal")

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.TWISTER_SEAL_HEALTH)

	inst:AddComponent("combat")

	inst:SetStateGraph("SGtwister_seal")
	
    local brain = require("brains/twistersealbrain")
    inst:SetBrain(brain)

    inst:DoTaskInTime(1*FRAMES, function()
    	inst:ListenForEvent("entitysleep", OnEntitySleep)
    end)

	return inst
end

return Prefab("twister_seal", fn, assets, {})
