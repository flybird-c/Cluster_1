local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local BirdSpawner = require("components/birdspawner")

local birdvstile = {
    [WORLD_TILES.DIRT] = "toucan",
    [WORLD_TILES.ROCKY] = "toucan",
    [WORLD_TILES.SAVANNA] = {"parrot", "toucan"},
    [WORLD_TILES.GRASS] = "parrot",
    [WORLD_TILES.FOREST] = {"toucan", "parrot"},
    [WORLD_TILES.MARSH] = "toucan",

    [WORLD_TILES.SNAKESKIN] = {"toucan", "parrot"},

    [WORLD_TILES.MEADOW] = "toucan",
    [WORLD_TILES.BEACH] = "toucan",
    [WORLD_TILES.JUNGLE] = "parrot",
    -- [WORLD_TILES.SWAMP] = "toucan"
    -- [WORLD_TILES.MANGROVE] = "seagull",
    -- [WORLD_TILES.MAGMAFIELD] = "toucan",
    -- [WORLD_TILES.TIDALMARSH] = "toucan",
}

local SCARYTOPREY_TAGS = { "scarytoprey" }
local function IsDangerNearby(x, y, z)
    local ents = TheSim:FindEntities(x, y, z, 8, SCARYTOPREY_TAGS)
    return next(ents) ~= nil
end

local function RelevantSpawnBird(self, bird_prefab, spawnpoint, ignorebait)

    local bird = SpawnPrefab(bird_prefab)
    if math.random() < .5 then
        bird.Transform:SetRotation(180)
    end
    if bird:HasTag("bird") then
        spawnpoint.y = 15
    end

    if bird.components.eater and not ignorebait then
        local bait = TheSim:FindEntities(spawnpoint.x, 0, spawnpoint.z, 15)
        local _map = TheWorld.Map
        for k, v in pairs(bait) do
            local x, y, z = v.Transform:GetWorldPosition()

            if IsOnFlood(x, y, z) then -- birds can't spawn at flood
                break
            end

            if bird_prefab == "seagull" and v.components.pickable and v.components.pickable.product == "limpets" and v.components.pickable.canbepicked then
                local target_pos = Vector3(x, y, z)
                local angle = math.random(0, 360)
                local offset = FindWalkableOffset(target_pos, angle * DEGREES, math.random() + 0.5, 4, false, false)
                if not offset then return end
                local prefab_at_target = self:PickBird(target_pos + offset)
                if bird_prefab == prefab_at_target then
                    spawnpoint = Vector3(target_pos.x, spawnpoint.y, target_pos.z) + offset
                    bird.bufferedaction = BufferedAction(bird, v, ACTIONS.PICK)
                end
                break
            elseif bird.components.eater:CanEat(v) and not v:IsInLimbo() and v.components.bait and
                not (v.components.inventoryitem and v.components.inventoryitem:IsHeld()) and not IsDangerNearby(x, y, z) and
                (bird.components.floater ~= nil or _map:IsPassableAtPoint(x, y, z)) then
                spawnpoint.x, spawnpoint.z = x, z
                bird.bufferedaction = BufferedAction(bird, v, ACTIONS.EAT)
                break
            elseif v.components.trap and v.components.trap.isset and
                (not v.components.trap.targettag or bird:HasTag(v.components.trap.targettag)) and
                not v.components.trap.issprung and math.random() < TUNING.BIRD_TRAP_CHANCE and
                not IsDangerNearby(x, y, z) and (bird.components.floater ~= nil or _map:IsPassableAtPoint(x, y, z)) then
                spawnpoint.x, spawnpoint.z = x, z
                break
            end
        end
    end

    bird.Physics:Teleport(spawnpoint:Get())

    return bird
end

IAENV.AddComponentPostInit("birdspawner", function(cmp)
    local _SpawnBird = cmp.SpawnBird
    function cmp:SpawnBird(spawnpoint, ignorebait)
        if IsOnFlood(spawnpoint:Get()) then -- birds can't spawn at flood
            return
        end

        local tile = TheWorld.Map:GetTileAtPoint(spawnpoint:Get())
        local bird_prefab = nil

        local climate = GetClimate(spawnpoint)
        if IsClimate(climate, "volcano") then
            return
        elseif IsClimate(climate, "island") then
            if IsOnOcean(spawnpoint) and not TheWorld.state.iswinter then
                if math.random() < TUNING.CORMORANT_CHANCE then
                    bird_prefab = "cormorant"
                else
                    bird_prefab = "seagull"
                end
            else
                if tile == WORLD_TILES.BEACH and TheWorld.state.iswinter then
                    bird_prefab = "seagull"
                elseif birdvstile[tile] ~= nil and not TheWorld.state.iswinter then
                    if type(birdvstile[tile]) == "table" then
                        bird_prefab = GetRandomItem(birdvstile[tile])
                    else
                        bird_prefab = birdvstile[tile]
                    end

                    if bird_prefab == "parrot" and math.random() < TUNING.PARROT_PIRATE_CHANCE then
                        bird_prefab = "parrot_pirate"
                    end
                else
                    return -- SW explicitly does not spawn birds on undefined turfs
                end
            end
        else
            return _SpawnBird(self, spawnpoint, ignorebait)
        end

        return RelevantSpawnBird(self, bird_prefab, spawnpoint, ignorebait)
    end

    function cmp:PickBird(spawnpoint)
        local world = TheWorld
        local map = world.Map
        local tile = map:GetTileAtPoint(spawnpoint.x, spawnpoint.y, spawnpoint.z)
        if world.state.iswinter then
            -- if tile == WORLD_TILES.BEACH and self.seagulspawn then
            if tile == WORLD_TILES.BEACH then
                return "seagull"
            else
                return nil
            end
        end
    end
end)
