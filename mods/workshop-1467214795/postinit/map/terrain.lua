local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

for i, tile in pairs(terrain.filter.daywalkerspawningground) do
    if tile == WORLD_TILES.ASH or tile == WORLD_TILES.VOLCANO or tile == WORLD_TILES.VOLCANO_ROCK then
        table.remove(terrain.filter.daywalkerspawningground, i)
    end
end