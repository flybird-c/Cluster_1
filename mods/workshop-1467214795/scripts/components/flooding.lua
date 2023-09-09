--Flood tiles are fake water on land tiles, and they're only half as wide as real tiles.
--In SW, it is mostly handled engine-side.
--Flood exists as tides and as Green season puddles.
--The puddle sources are also known as "puddle eyes", but that name is too silly for me to write serious code with it. -M
--They spread flood tiles around themselves, but can be blocked by sandbags.
--There's an implicit bug that prevents the spread if the source tile is blocked directly.
--Sandbags can also be used to entirely remove the flood, but the details are weird and possibly inconsistent.
--Puddles dry up over the course of three days in summer.
--------------------------------------------------------------------------

local GROUND_FLOODPROOF = GROUND_FLOODPROOF
local TileGroupManager = TileGroupManager

local FLOOD_SCALE = 2
local HALF_FLOOD_SCALE = FLOOD_SCALE * 0.5
local FLOOD_OFFSET = -1

return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Private Member variables ]]
--------------------------------------------------------------------------

local _world = TheWorld
local _map = _world.Map
local _ismastersim = _world.ismastersim
local w, h = _map:GetSize()
local flood_w, flood_h = w * FLOOD_SCALE, h * FLOOD_SCALE
local half_flood_map_width, half_flood_map_height = flood_w * 0.5, flood_h * 0.5

local _reference_grid = DataGrid(flood_w, flood_h)
local _blocker_grid = DataGrid(flood_w, flood_h)
local flood_grid_w, flood_grid_h = math.ceil(flood_w / 8), math.ceil(flood_h / 8)
local _flood_grid = DataGrid(flood_grid_w, flood_grid_h)

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

local FLOOD_W_OFFSET = FLOOD_SCALE * half_flood_map_width
local FLOOD_H_OFFSET = FLOOD_SCALE * half_flood_map_height

--------------------------------------------------------------------------
--[[ Public Member variables ]]
--------------------------------------------------------------------------

self.inst = inst

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function GetReferenceCount(x, y)
    return _reference_grid:GetDataAtPoint(x, y) or 0
end

local function SetReferenceCount(x, y, refs)
    _reference_grid:SetDataAtPoint(x, y, refs)
end

local function IsBlocked(x, y)
    return _blocker_grid:GetDataAtPoint(x, y) == true
end

local function SetBlocked(x, y, blocked)
    _blocker_grid:SetDataAtPoint(x, y, blocked == true or nil)
end

local function IsFloodableTile(tile, is_flood_spread)
    if not TileGroupManager:IsLandTile(tile) then
        return false
    end

    --flood spread is almost always valid
    if is_flood_spread then
        return true
    end

    --make sure the ground is not floodproof
    return GROUND_FLOODPROOF[tile] == nil
end

local function GetFloodCoordsAtPoint(x, y, z)
    x = math.floor(((x - FLOOD_OFFSET) + FLOOD_W_OFFSET + HALF_FLOOD_SCALE) / FLOOD_SCALE)
    z = math.floor(((z - FLOOD_OFFSET) + FLOOD_H_OFFSET + HALF_FLOOD_SCALE) / FLOOD_SCALE)
    return x, z
end

local function GetFloodCenterPoint(x, y)
    x = x * FLOOD_SCALE - FLOOD_W_OFFSET + FLOOD_OFFSET
    y = y * FLOOD_SCALE - FLOOD_H_OFFSET + FLOOD_OFFSET
    return x, 0, y
end

local function SpawnNetworkedFlood(x, y)
    local i_x, i_y = math.floor(x / 8), math.floor(y / 8)

    local flood_network = _flood_grid:GetDataAtPoint(i_x, i_y)
    if flood_network == nil then
        flood_network = SpawnPrefab("network_flood")
        flood_network:SetFloodNetworkPosition(i_x, i_y)
        _flood_grid:SetDataAtPoint(i_x, i_y, flood_network)
    end

    local o_x, o_y = (x % 8) + 1, (y % 8) + 1
    flood_network:SetFloodState(o_x, o_y, true)
end

local function DespawnNetworkedFlood(x, y)
    local i_x, i_y = math.floor(x / 8), math.floor(y / 8)

    local flood_network = _flood_grid:GetDataAtPoint(i_x, i_y)
    if flood_network == nil then return end

    local o_x, o_y = (x % 8) + 1, (y % 8) + 1
    flood_network:SetFloodState(o_x, o_y, nil)

    if flood_network:IsEmpty() then
        flood_network:Remove()
        _flood_grid:SetDataAtPoint(i_x, i_y, nil)
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

--For when a sandbag or other floodblocker is removed
local floodblockerremoved =  _ismastersim and function(src, data)
    local x, y = GetFloodCoordsAtPoint(data.blocker.Transform:GetWorldPosition())
    SetBlocked(x, y, false)
    _world:PushEvent("floodblockingupdated", {x = x, y = y, blocked = false})
end or nil

local floodblockercreated = _ismastersim and function(src, data)
    local x, y = GetFloodCoordsAtPoint(data.blocker.Transform:GetWorldPosition())
    SetBlocked(x, y, true)
    _world:PushEvent("floodblockingupdated", {x = x, y = y, blocked = true})
end or nil

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Register events
if _ismastersim then
	inst:ListenForEvent("floodblockerremoved", floodblockerremoved, _world)
	inst:ListenForEvent("floodblockercreated", floodblockercreated, _world)
end

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

if _ismastersim then
    function self:SpawnFloodAtPoint(x, y)
        local refs = GetReferenceCount(x, y)
        refs = refs + 1
        SetReferenceCount(x, y, refs)

        if refs == 1 then
            SpawnNetworkedFlood(x, y)
        end
    end

    function self:DespawnFloodAtPoint(x, y)
        local refs = GetReferenceCount(x, y)
        refs = refs - 1
        SetReferenceCount(x, y, refs)

        assert(refs >= 0)

        if refs == 0 then
            DespawnNetworkedFlood(x, y)
        end
    end
else
    function self:SetFloodedAtPoint(x, y, is_flooded)
        SetReferenceCount(x, y, is_flooded and 1 or nil)
    end
end

self.IsFloodBlocked = _ismastersim and function(_, x, y, is_flood_spread)
    --check sandbags
    if IsBlocked(x, y) then
        return true
    end

    local w_x, w_y, w_z = GetFloodCenterPoint(x, y)
    local tile = _map:GetTileAtPoint(w_x, w_y, w_z)

    if not IsFloodableTile(tile, is_flood_spread) then
        return true
    end

    --flood spread is almost always valid
    if is_flood_spread then
        return false
    end

    --make sure the ground is not floodproof and in the ia climate
    return not IsInClimate(Vector3(w_x, w_y, w_z), "island")
end or nil

function self:IsFloodableTile(tile, is_flood_spread)
    return IsFloodableTile(tile, is_flood_spread)
end

if TheWorld.ismastersim then
    function self:IsFloodTileAtPoint(x, y, z)
        return GetReferenceCount(GetFloodCoordsAtPoint(x, y, z)) > 0
    end
else
    function self:IsFloodTileAtPoint(x, y, z)
        return GetParticleTileState("flood", GetFloodCoordsAtPoint(x, y, z))
    end
end

function self:IsPointOnFlood(x, y, z)
    return self:IsFloodTileAtPoint(x, y, z) and not TheWorld.Map:IsOceanAtPoint(x, y, z)
end

self.OnFlood = self.IsPointOnFlood

function self:GetFloodCoordsAtPoint(x, y, z)
    return GetFloodCoordsAtPoint(x, y, z)
end

function self:GetFloodCenterPoint(x, y, z)
    if z == nil then
        return GetFloodCenterPoint(x, y)
    end
    return GetFloodCenterPoint(GetFloodCoordsAtPoint(x, y, z))
end

function self:GetFloodGridSize()
    return flood_w, flood_h
end

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

self.OnSave = _ismastersim and function(self)
    local data = {}
    data.reference_grid = _reference_grid:Save()
    data.blocker_grid = _blocker_grid:Save()
    return data
end or nil

self.OnLoad = _ismastersim and function(self, data)
    if data then
        _reference_grid:Load(data.reference_grid or {})
        _blocker_grid:Load(data.blocker_grid or {})

        for x = 0, flood_w-1 do
            for y = 0, flood_h-1 do
                if GetReferenceCount(x, y) > 0 then
                    SpawnNetworkedFlood(x, y)
                end
            end
        end
    end
end or nil

--------------------------------------------------------------------------

end)
