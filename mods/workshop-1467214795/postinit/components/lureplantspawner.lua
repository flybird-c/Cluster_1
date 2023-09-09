local IAENV = env
GLOBAL.setfenv(1, GLOBAL)
---------------------------------

local IA_TILES = table.invert({
    WORLD_TILES.MEADOW,
    WORLD_TILES.JUNGLE,
    WORLD_TILES.TIDALMARSH,
    WORLD_TILES.BEACH
})

IAENV.AddComponentPostInit("lureplantspawner", function(cmp)
    local VALID_TILES
    local function Setup()
        for i, v in ipairs(cmp.inst.event_listening["ms_playerjoined"][TheWorld]) do
            if UpvalueHacker.GetUpvalue(v, "ScheduleTrailLog") then
                VALID_TILES =  UpvalueHacker.GetUpvalue(v, "ScheduleTrailLog", "LogPlayerLocation", "VALID_TILES")
                break
            end
        end

        assert(VALID_TILES)
    end

    if not pcall(Setup) then return IA_MODULE_ERROR("lureplantspawner") end

    for i,v in pairs(IA_TILES) do
        VALID_TILES[i] = (#VALID_TILES+v+1)
    end
end)
