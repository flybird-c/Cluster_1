local prefabs = {
	"bioluminescence",
}

local spawnchildren

local function regenchildren(inst)
    inst.regentime = nil
    spawnchildren(inst)
end

local function onchildworked(inst, child, data)
    table.removearrayvalue(inst.children, child)

    inst:RemoveEventCallback("onpickup", inst.onchildworked, child)
    inst:RemoveEventCallback("onremove", inst.onchildworked, child)

    if #inst.children == 0 then
        local st = TheWorld.state

        local timetoregen = ((st.autumnlength + st.winterlength + st.springlength + st.summerlength) / 2) * TUNING.TOTAL_DAY_TIME
        inst.regentime = timetoregen + GetTime()
        inst:DoTaskInTime(timetoregen, regenchildren)
    end
end

spawnchildren = function(inst)
    if #inst.children ~= 0 or inst.regentime ~= nil then
        return
    end

	local numChildren = 6
	local numBranches = 2
	local maxAngle = 120 * DEGREES
	local distanceBetween = 3
	local lastAngle = 0
	local x, y, z = inst.Transform:GetWorldPosition()
	local startAngle = math.random() * 360 * DEGREES

	for i = 1, numBranches do
		startAngle = startAngle + ((45 + math.random() * 270 ) * DEGREES)
		for ii = 1, numChildren do
			local angle  = startAngle + -maxAngle / 2 +  math.random() * maxAngle
			x = x + math.cos(angle) * distanceBetween
			z = z + math.sin(angle) * distanceBetween
			local onWater = IsSurroundedByWaterTile(x, y, z, 2)
			if not onWater then
				break
			end
			local child = SpawnPrefab("bioluminescence")
	     	child.Transform:SetPosition(x,y,z)
            inst.children[#inst.children + 1] = child
            inst:ListenForEvent("onpickup", inst.onchildworked, child)
            inst:ListenForEvent("onremove", inst.onchildworked, child)
		end
	end
end

local function OnSave(inst, data)
    data.children = {}

    for i, v in ipairs(inst.children) do
        table.insert(data.children, v.GUID)
    end

    if inst.regentime ~= nil then
        data.regentime = inst.regentime - GetTime()
    end

    return #data.children >= 1 and data.children or nil
end

local function OnLoad(inst, data, newents)
    if data and data.regentime then
        inst.regentime = data.regentime + GetTime()
        inst:DoTaskInTime(data.regentime, regenchildren)
    end
end

local function OnLoadPostPass(inst, newents, data)
    if data and data.children then
        for i, v in ipairs(data.children) do
            local child = newents[v]
            if child then
                child = child.entity
                inst.children[i] = child
                inst:ListenForEvent("onpickup", inst.onchildworked, child)
                inst:ListenForEvent("onremove", inst.onchildworked, child)
            end
        end
    end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()

	inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    inst:AddTag("ignorewalkableplatforms")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

    inst.children = {}

    inst.onchildworked = function(child, data) onchildworked(inst, child, data) end

	inst:DoTaskInTime(5*FRAMES, spawnchildren)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

return Prefab("bioluminescence_spawner", fn, nil, prefabs)
