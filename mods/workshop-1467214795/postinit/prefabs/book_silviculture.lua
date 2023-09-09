local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local CANT_TAGS_PREFAB = {
    book_gardening = {"pickable", "stump", "withered", "barren", "INLIMBO" },
    book_silviculture = {"pickable", "stump", "withered", "barren", "INLIMBO"},
}

local ONEOF_TAGS_PREFAB = {
    book_silviculture = {"silviculture", "tree", "winter_tree"},
}

local function trygrowhackable(inst)
	if not inst:IsValid() or inst:IsInLimbo() or (inst.components.witherable ~= nil and inst.components.witherable:IsWithered()) then
		return false
	end

	if inst.components.hackable ~= nil then
		if inst.components.hackable:CanBeHacked() and inst.components.hackable.caninteractwith then
			return false
		end
		inst.components.hackable:FinishGrowing()
	end
end

local function fn(inst)
    if not TheWorld.ismastersim then
        return
    end

    local CANT_TAGS
    if CANT_TAGS_PREFAB[inst.prefab] then
        CANT_TAGS = CANT_TAGS_PREFAB[inst.prefab]
    end

    local ONEOF_TAGS
    if ONEOF_TAGS_PREFAB[inst.prefab] then
        ONEOF_TAGS = ONEOF_TAGS_PREFAB[inst.prefab]
    end

    local _onread = inst.components.book.onread
    inst.components.book.onread = function(_inst, reader, ...)
        local ret = {_onread(_inst, reader, ...)}
        if ret[1] then
            local x, y, z = reader.Transform:GetWorldPosition()
            local range = 30
            local ents = TheSim:FindEntities(x, y, z, range, nil, CANT_TAGS, ONEOF_TAGS)

            if #ents > 0 then
                trygrowhackable(table.remove(ents, math.random(#ents)))
                if #ents > 0 then
                    local timevar = 1 - 1 / (#ents + 1)
                    for _, ent in ipairs(ents) do
                        ent:DoTaskInTime(timevar * math.random(), trygrowhackable)
                    end
                end
            end
        end

        return unpack(ret)
    end
end

IAENV.AddPrefabPostInit("book_gardening", fn)  -- incase someone wants to use the old unused book for some reason
IAENV.AddPrefabPostInit("book_silviculture", fn)