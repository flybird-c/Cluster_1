local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local LAND = "land"
local WATER = "water"

IAENV.AddComponentPostInit("shadowcreaturespawner", function(cmp)

    --------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local NON_INSANITY_MODE_DESPAWN_INTERVAL = 0.1
local NON_INSANITY_MODE_DESPAWN_VARIANCE = 0.1

local OCEAN_SPAWN_ATTEMPTS = 4

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
local inst = cmp.inst

--Private
local _map = TheWorld.Map

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function IA_SpawnOceanShadowCreature(player)
    local inst = SpawnPrefab("swimminghorror")
    if not (player.components.sanity:GetPercent() < .1 and math.random() < TUNING.TERRORBEAK_SPAWN_CHANCE) then
        inst:SetCrawlingHorror()
    end
    return inst
end

local _players = UpvalueHacker.GetUpvalue(cmp.SpawnShadowCreature, "_players")
local StartTracking = UpvalueHacker.GetUpvalue(cmp.SpawnShadowCreature, "StartTracking")
if not _players or not StartTracking then return end
function cmp:IA_SpawnShadowCreature(player, params)
    params = params or _players[player]

    local position = player:GetPosition()
    if player.components.sanity:GetPercent() < .1 and player:CanOnWater() and player:IsOnOcean() then

        local angle = math.random() * 2 * PI
        local offset = FindSwimmableOffset(position, angle, 15, 12)
        local spawn_x = position.x + offset.x
        local spawn_z = position.z + offset.z

        if _map:IsOceanAtPoint(spawn_x, 0, spawn_z) then

            local ent = IA_SpawnOceanShadowCreature(player)
            ent.Transform:SetPosition(spawn_x, 0, spawn_z)
            StartTracking(player, params, ent)
            return ent
        end
    end
end

local _SpawnShadowCreature = cmp.SpawnShadowCreature
function cmp:SpawnShadowCreature(player, params, ...)
    if self:IA_SpawnShadowCreature(player, params) ~= nil then return end
    return _SpawnShadowCreature(self, player, params, ...)
end
gemrun("hidefn", cmp.SpawnShadowCreature, _SpawnShadowCreature) --poof!

end)


