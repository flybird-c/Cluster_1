local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local _sanityfn
local FIRE_TAGS = { "fire" }
local function sanityfn(inst, ...)
    local _map = TheWorld.Map

    local delta = _sanityfn(inst, ...)

    -- Using burnable is too risky...
    local x, y, z = inst.Transform:GetWorldPosition()
    local max_rad = 10
    local ents = TheSim:FindEntities(x, y, z, max_rad, FIRE_TAGS)
    for i, v in ipairs(ents) do
        if v.components.geyserfx ~= nil and v.components.geyserfx.state ~= 0 then
            local rad = v.components.geyserfx:GetRadius() or 1
            local sz = TUNING.SANITYAURA_SMALL * math.min(max_rad, rad) / max_rad
            local distsq = inst:GetDistanceSqToInst(v) - 9
            -- shift the value so that a distance of 3 is the minimum
            delta = delta + sz / math.max(1, distsq)
        end
    end

    -- Note: IsTileGridValid seem to have been a check for invalid tiles and likley interiors too
    -- So instead we can simply check to make sure we are sending numbers
    if type(x) == "number" and IsInClimate(inst, "volcano") then
        local dist = _map:GetClosestTileDist(x, y, z, WORLD_TILES.VOLCANO_LAVA, 4)
        if dist <= 4 then
            delta = math.max(delta, TUNING.SANITYAURA_MED * (1 - (dist / 4)))
        end
    end

    return delta
end

IAENV.AddPrefabPostInit("willow", function(inst)
    if not TheWorld.ismastersim then
        return 
    end

    if inst.components.sanity ~= nil then
        if not _sanityfn then
            _sanityfn = inst.components.sanity.custom_rate_fn
        end
        inst.components.sanity.custom_rate_fn = sanityfn
    end
end)
