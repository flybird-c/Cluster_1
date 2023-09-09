local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local LEIFTARGET_MUST_TAGS  = { "tree" }
local LEIFTARGET_ONEOF_TAGS = { "palmtree", "jungletree" }
local LEIFTARGET_CANT_TAGS  = { "leif", "fire", "stump", "burnt", "monster", "FX", "NOCLICK", "DECOR", "INLIMBO" }

local _SpawnNewLeifs

local function SpawnNewLeifs(inst, x, y, z, doer, multiplier, ...)
    local old_ents, num_spawns = _SpawnNewLeifs(inst, x, y, z, doer, multiplier, ...)

    local ents = TheSim:FindEntities(x, y, z, TUNING.LEIF_IDOL_SPAWN_RADIUS, LEIFTARGET_MUST_TAGS, LEIFTARGET_CANT_TAGS, LEIFTARGET_ONEOF_TAGS)

    for i, v in pairs(ents) do
        table.insert(old_ents, v)
    end

    for i, ent in ipairs(ents) do
        if (ent:HasTag("palmtree") and not ent.noleif) or (ent:HasTag("jungletree") and not ent.noleif) then
            if ent.TransformIntoLeif ~= nil then
                ent:TransformIntoLeif(doer)
                num_spawns = num_spawns - 1
            elseif ent.StartMonster ~= nil then
                ent.monster_start_task = ent:DoTaskInTime(math.random(1, 4), DelayedStartMonster)
                num_spawns = num_spawns - 1
            end

            if num_spawns <= 0 then
                break
            end
        end
    end

	return ents, num_spawns
end

IAENV.AddPrefabPostInit("leif_idol", function(inst)

	if inst.SpawnNewLeifs then
		if _SpawnNewLeifs == nil then
			_SpawnNewLeifs = inst.SpawnNewLeifs
		end
		inst.SpawnNewLeifs = SpawnNewLeifs
	end

end)