local assets = {}
local prefabs = {"flup"}

local function spawntestfn(inst, ground, x, y, z)
	-- crude copy from watervisuals.lua
	for i = -1, 1, 1 do
		if IsOnOcean(x - 1, y, z + i, true) or IsOnOcean(x + 1, y, z + i, true) then
			return false
		end
	end
	for i = -2, 0, 1 do
		if IsOnOcean(x + i, y, z -1, true) or IsOnOcean(x + i, y, z + 1, true) then
			return false
		end
	end

	return true
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddNetwork()

    inst:AddTag("NOBLOCK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("areaspawner")
    inst.components.areaspawner:SetValidTileType(WORLD_TILES.TIDALMARSH)
    inst.components.areaspawner:SetPrefab("flup")
    inst.components.areaspawner:SetDensityInRange(40, 5)
    inst.components.areaspawner:SetMinimumSpacing(10)
    inst.components.areaspawner:SetSpawnTestFn(spawntestfn)
    inst.components.areaspawner:SetRandomTimes(TUNING.TOTAL_DAY_TIME * 3, TUNING.TOTAL_DAY_TIME)
    inst.components.areaspawner:Start()

    return inst
end

local function dense_fn()
    local inst = fn()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.areaspawner:SetDensityInRange(40, 10)

    return inst
end

local function sparse_fn()
    local inst = fn()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.areaspawner:SetDensityInRange(40, 2)

    return inst
end

return Prefab("flupspawner", fn, assets, prefabs),
    Prefab("flupspawner_dense", dense_fn, assets, prefabs),
    Prefab("flupspawner_sparse", sparse_fn, assets, prefabs)
