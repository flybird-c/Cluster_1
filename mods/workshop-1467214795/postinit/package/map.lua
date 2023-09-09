GLOBAL.setfenv(1, GLOBAL)

local assert = assert
local unpack = unpack
local math = math
local TILE_SCALE = TILE_SCALE
local TileGroupManager = TileGroupManager

local tiles = require("worldtiledefs")

local RenderTileOrder = {}
for i, v in ipairs(tiles.ground) do
    RenderTileOrder[v[1]] = i
end

local function MaxTile(tile1, tile2)
    if (RenderTileOrder[tile2] or 0) > (RenderTileOrder[tile1] or 0) then
        return tile2
    end
    return tile1
end

function Map:GetVisualTileAtPoint(ptx, pty, ptz, percentile)
    local tilecenter_x, tilecenter_y, tilecenter_z  = self:GetTileCenterPoint(ptx, 0, ptz)
    local tx, ty = self:GetTileCoordsAtPoint(ptx, 0, ptz)
    local tile = self:GetTile(tx, ty)

    if tilecenter_x and tilecenter_z then
        percentile = percentile or 0.25
        local xpercent = ((tilecenter_x - ptx) / TILE_SCALE) + .5
        local ypercent = ((tilecenter_z - ptz) / TILE_SCALE) + .5

        local x_off = 0
        local y_off = 0

        if xpercent < percentile then
            x_off = 1

        elseif xpercent > 1 - percentile then
            x_off = -1
        end

        if ypercent < percentile then
            y_off = 1

        elseif ypercent > 1 - percentile then
            y_off = -1
        end

        if x_off == 0 and y_off == 0 then
            return tile
        elseif x_off == 0 or y_off == 0 then
            return MaxTile(tile, self:GetTile(tx + x_off, ty + y_off))
        end
        tile = MaxTile(tile, self:GetTile(tx + x_off, ty))
        tile = MaxTile(tile, self:GetTile(tx, ty + y_off))
        tile = MaxTile(tile, self:GetTile(tx + x_off, ty + y_off))
        return tile
    end
    return WORLD_TILES.IMPASSABLE
end

local function checkinsidecorner(self, tx, ty, x_off, y_off)
    return TileGroupManager:IsOceanTile(self:GetTile(tx + x_off, ty)) 
        and TileGroupManager:IsOceanTile(self:GetTile(tx, ty + y_off))
end

local function checkoutsidecorner(self, tx, ty, x_off, y_off)
    return TileGroupManager:IsOceanTile(self:GetTile(tx + x_off, ty))
        or TileGroupManager:IsOceanTile(self:GetTile(tx, ty + y_off))
end

local function checkedge(self, tx, ty, x_off, y_off)
    return TileGroupManager:IsOceanTile(self:GetTile(tx + x_off, ty)) 
        or TileGroupManager:IsOceanTile(self:GetTile(tx, ty + y_off))
        or TileGroupManager:IsOceanTile(self:GetTile(tx + x_off, ty + y_off))
end

local _ignore_ia_corners = nil
function Map:InternalIsVisualIAOceanAtPoint(ptx, pty, ptz, percentile, check_corners)
    -- Note: This is only usefull when ocean has overhang onto land
    -- This is a cheaper function used specifically to check if its an ocean tile
    assert(self.ia_overhang)
    local tx, ty = self:GetTileCoordsAtPoint(ptx, 0, ptz)

    if TileGroupManager:IsOceanTile(self:GetTile(tx, ty)) then
        return true
    end

    local tilecenter_x, tilecenter_y, tilecenter_z  = self:GetTileCenterPoint(ptx, 0, ptz)
    if tilecenter_x and tilecenter_z then
        if _ignore_ia_corners then check_corners = false end
        percentile = percentile or 0.25
        local xpercent = ((tilecenter_x - ptx) / TILE_SCALE) + .5
        local ypercent = ((tilecenter_z - ptz) / TILE_SCALE) + .5

        local x_off = 0
        local y_off = 0

        if xpercent < percentile then
            x_off = 1

        elseif xpercent > 1 - percentile then
            x_off = -1
        end

        if ypercent < percentile then
            y_off = 1

        elseif ypercent > 1 - percentile then
            y_off = -1
        end

        if x_off == 0 and y_off == 0 then
            if check_corners then
                -- inside corners
                if xpercent + ypercent <  0.5 + percentile then
                    -- bottom left corner
                    return checkinsidecorner(self, tx, ty, 1, 1)
                elseif xpercent + ypercent > 1.5 - percentile then
                    -- top right corner
                    return checkinsidecorner(self, tx, ty, -1, -1)
                elseif xpercent + 0.5 - percentile < ypercent then
                    -- top left corner
                    return checkinsidecorner(self, tx, ty, 1, -1)
                elseif xpercent > ypercent + 0.5 - percentile then
                    -- bottom right corner
                    return checkinsidecorner(self, tx, ty, -1, 1)
                end
            end
            return false
        elseif x_off == 0 or y_off == 0 then
            return TileGroupManager:IsOceanTile(self:GetTile(tx + x_off, ty + y_off))
        elseif check_corners 
            and ((x_off == 1 and y_off == 1 and xpercent + ypercent > 0.5 - percentile) -- bottom left corner
            or (x_off == -1 and y_off == -1 and xpercent + ypercent < 1.5 + percentile) -- top right corner
            or (x_off == 1 and y_off == -1 and xpercent +  0.5 + percentile > ypercent) -- top left corner
            or (x_off == -1 and y_off == 1 and xpercent < ypercent +  0.5 + percentile)) then -- bottom right corner
            -- outside corners
            return checkoutsidecorner(self, tx, ty, x_off, y_off)
        end
        return checkedge(self, tx, ty, x_off, y_off)
    end
end

-- Okay so this is very hacky but....
-- Essentially in SW the corners are not calcuated at all
-- But in order to keep compatibility with most dst content
-- for example combat targeting and amphibiouscreatures and embarkers
-- and proper spawn locations.. etc
-- the corners are calculated by default for IsVisualGroundAtPoint
-- So I just use this hack to disable the corners for floating items
-- and placement checks to be more accurrate to sw
function Map:RunWithoutIACorners(fn, ...)
    local _ignore_ia_corners = _ignore_ia_corners
    _ignore_ia_corners = true
    local rets = {fn(...)}
    _ignore_ia_corners = _ignore_ia_corners
    return unpack(rets)
end

-- Overhang patches --
local _IsVisualGroundAtPoint = Map.IsVisualGroundAtPoint
function Map:IsVisualGroundAtPoint(x, y, z, ...)
    if self.ia_overhang and self:InternalIsVisualIAOceanAtPoint(x, y, z, nil, true) then
        -- What a pain dst's IsVisualGround doesnt support reversed overhang..
        return false
    end
    return _IsVisualGroundAtPoint(self, x, y, z, ...)
end

---------------------------------------------------------

local function _test_is_land_tile_at_point(x, y, z, map)
    return map:IsActualLandTileAtPoint(x, y, z)
end

local function _test_is_water_tile_at_point(x, y, z, map)
    return map:IsActualOceanTileAtPoint(x, y, z)
end

local function _test_is_not_above_land_tile_at_point(x, y, z, map)
    return not map:IsActualOceanTileAtPoint(x, y, z)
end

--------------------- IsCloseToTile ---------------------

function Map:IsCloseToTile(x, y, z, radius, tile_scale, typefn, ...)
    if radius == 0 then return typefn(x, y, z, ...) end
    -- Correct improper radiuses caused by changes to the radius based on overhang
    if radius < 0 then return self:IsSurroundedByTile(x, y, z, radius * -1, tile_scale, typefn, ...) end
    
    local num_edge_points = math.ceil((radius*2) / tile_scale) - 1

    --test the corners first
    if typefn(x + radius, y, z + radius, ...) then return true end
    if typefn(x - radius, y, z + radius, ...) then return true end
    if typefn(x + radius, y, z - radius, ...) then return true end
    if typefn(x - radius, y, z - radius, ...) then return true end

    --if the radius is less than 2(1 after the -1), it won't have any edges to test and we can end the testing here.
    if num_edge_points == 0 then return false end

    local dist = (radius*2) / (num_edge_points + 1)
    --test the edges next
    for i = 1, num_edge_points do
        local idist = dist * i
        if typefn(x - radius + idist, y, z + radius, ...) then return true end
        if typefn(x - radius + idist, y, z - radius, ...) then return true end
        if typefn(x - radius, y, z - radius + idist, ...) then return true end
        if typefn(x + radius, y, z - radius + idist, ...) then return true end
    end

    --test interior points last
    for i = 1, num_edge_points do
        local idist = dist * i
        for j = 1, num_edge_points do
            local jdist = dist * j
            if typefn(x - radius + idist, y, z - radius + jdist, ...) then return true end
        end
    end
    return false
end

function Map:IsCloseToLand(x, y, z, radius, ignore_impassable)
    if self.ia_overhang then
        if ignore_impassable ~= nil then
            return self:IsCloseToTile(x, y, z, radius - 1, 4, _test_is_land_tile_at_point, self)
        else
            return self:IsCloseToTile(x, y, z, radius + 1, 4, _test_is_land_tile_at_point, self)
                and self:IsCloseToTile(x, y, z, radius - 1, 4, _test_is_not_above_land_tile_at_point, self)
        end
    end
    return self:IsCloseToTile(x, y, z, radius + 1, 4, _test_is_land_tile_at_point, self)
end

function Map:IsCloseToWater(x, y, z, radius, ...)
    if self.ia_overhang then
        return self:IsCloseToTile(x, y, z, radius + 1, 4, _test_is_water_tile_at_point, self)
    end
    return self:IsCloseToTile(x, y, z, radius - 1, 4, _test_is_water_tile_at_point, self)
end

---------------------------------------------------------

------------------- IsSurroundedByTile ------------------

function Map:IsSurroundedByTile(x, y, z, radius, tile_scale, typefn, ...)
    if radius == 0 then return typefn(x, y, z, ...) end
    -- Correct improper radiuses caused by changes to the radius based on overhang
    if radius < 0 then return self:IsCloseToTile(x, y, z, radius * -1, tile_scale, typefn, ...) end

    local num_edge_points = math.ceil((radius*2) / tile_scale) - 1

    --test the corners first
    if not typefn(x + radius, y, z + radius, ...) then return false end
    if not typefn(x - radius, y, z + radius, ...) then return false end
    if not typefn(x + radius, y, z - radius, ...) then return false end
    if not typefn(x - radius, y, z - radius, ...) then return false end

    --if the radius is less than 2(1 after the -1), it won't have any edges to test and we can end the testing here.
    if num_edge_points == 0 then return true end

    local dist = (radius*2) / (num_edge_points + 1)
    --test the edges next
    for i = 1, num_edge_points do
        local idist = dist * i
        if not typefn(x - radius + idist, y, z + radius, ...) then return false end
        if not typefn(x - radius + idist, y, z - radius, ...) then return false end
        if not typefn(x - radius, y, z - radius + idist, ...) then return false end
        if not typefn(x + radius, y, z - radius + idist, ...) then return false end
    end

    --test interior points last
    for i = 1, num_edge_points do
        local idist = dist * i
        for j = 1, num_edge_points do
            local jdist = dist * j
            if not typefn(x - radius + idist, y, z - radius + jdist, ...) then return false end
        end
    end
    return true
end

function Map:IsSurroundedByLand(x, y, z, radius, ignore_impassable)
    if self.ia_overhang then
        if ignore_impassable then 
            return self:IsSurroundedByTile(x, y, z, radius + 1, 4, _test_is_land_tile_at_point, self) 
        else
            return self:IsSurroundedByTile(x, y, z, radius + 1, 4, _test_is_not_above_land_tile_at_point, self)
                and self:IsSurroundedByTile(x, y, z, radius - 1, 4, _test_is_land_tile_at_point, self)
        end
    end
    return self:IsSurroundedByTile(x, y, z, radius - 1, 4, _test_is_land_tile_at_point, self)
end

local _IsSurroundedByWater = Map.IsSurroundedByWater
function Map:IsSurroundedByWater(x, y, z, radius, ...)
    if self.ia_overhang then
        --subtract 1 to radius for map overhang, way cheaper than doing an IsVisualGround test
        --if the radius is less than 2(1 after the -1), We only need to check if the current point is an ocean tile
        return self:IsSurroundedByTile(x, y, z, radius - 1, 4, _test_is_water_tile_at_point, self)
    end
    return _IsSurroundedByWater(self, x, y, z, radius, ...)
end

---------------------------------------------------------

function Map:IsActualAboveGroundAtPoint(x, y, z, allow_water)
    local tile = self:GetTileAtPoint(x, y, z)
    local valid_water_tile = (allow_water == true) and TileGroupManager:IsOceanTile(tile)
    return valid_water_tile or TileGroupManager:IsLandTile(tile)
end

function Map:IsActualLandTileAtPoint(x, y, z)
    local tile = self:GetTileAtPoint(x, y, z)
    return TileGroupManager:IsLandTile(tile)
end

function Map:IsActualOceanTileAtPoint(x, y, z)
    local tile = self:GetTileAtPoint(x, y, z)
    return TileGroupManager:IsOceanTile(tile)
end

---------------------------------------------------------

local _IsAboveGroundAtPoint = Map.IsAboveGroundAtPoint
function Map:IsAboveGroundAtPoint(x, y, z, allow_water, ...)
    if self.ia_overhang and not allow_water and self:InternalIsVisualIAOceanAtPoint(x, y, z, 0.375) then
        return false
    end
    return _IsAboveGroundAtPoint(self, x, y, z, allow_water, ...)
end

local _IsLandTileAtPoint = Map.IsLandTileAtPoint
function Map:IsLandTileAtPoint(x, y, z, ...)
    if self.ia_overhang and self:InternalIsVisualIAOceanAtPoint(x, y, z, 0.375) then
        return false
    end
    return _IsLandTileAtPoint(self, x, y, z, ...)
end

local _IsOceanTileAtPoint = Map.IsOceanTileAtPoint
function Map:IsOceanTileAtPoint(x, y, z, allow_boats, ...)
    -- Because our overhang is reversed we pretend the overhang is an oceantile for better
    -- compatibility with dst's overhang checks
    if self.ia_overhang then
        return self:InternalIsVisualIAOceanAtPoint(x, y, z, 0.375)
    end
    return _IsOceanTileAtPoint(self, x, y, z, ...)
end

---------------------------------------------------------

local _IsOceanAtPoint = Map.IsOceanAtPoint
function Map:IsOceanAtPoint(x, y, z, allow_boats, ...)
    if self.ia_overhang then
        -- Optimization no need to call not self:IsVisualGroundAtPoint(x, y, z) or self:IsOceanTileAtPoint
        return self:InternalIsVisualIAOceanAtPoint(x, y, z, nil, true) 
            and (allow_boats or self:GetPlatformAtPoint(x, z) == nil)	
    end
    return _IsOceanAtPoint(self, x, y, z, ...)
end

---------------------------------------------------------

local _CanPlantAtPoint = Map.CanPlantAtPoint
function Map:CanPlantAtPoint(x, y, z, ...)
    if self.ia_overhang and self:InternalIsVisualIAOceanAtPoint(x, y, z) then
        return false
    end
    return _CanPlantAtPoint(self, x, y, z, ...)
end

----------------------

local BASE_TILES = {
    [WORLD_TILES.VOLCANO_ROCK] = true,
    [WORLD_TILES.BEACH] = true,
}

local _CanPlaceTurfAtPoint = Map.CanPlaceTurfAtPoint 
function Map:CanPlaceTurfAtPoint(x, y, z, ...)
    return _CanPlaceTurfAtPoint(self, x, y, z, ...) or BASE_TILES[self:GetTileAtPoint(x, y, z)]
end

local _CanDeployAtPoint = Map.CanDeployAtPoint
function Map:CanDeployAtPoint(pt, inst, ...)
    return _CanDeployAtPoint(self, pt, inst, ...)
end

-- Patch some deploy checks to stop placing "land" on sw boats
local force_check_player = nil
local _IsDeployPointClear = Map.IsDeployPointClear
function Map:IsDeployPointClear(pt, inst, min_spacing, min_spacing_sq_fn, near_other_fn, check_player, custom_ignore_tags, ...)
    return _IsDeployPointClear(self, pt, inst, min_spacing, min_spacing_sq_fn, near_other_fn, force_check_player or check_player, custom_ignore_tags, ...)
end

local _IsDeployPointClear2 = Map.IsDeployPointClear2
function Map:IsDeployPointClear2(pt, inst, object_size, object_size_fn, near_other_fn, check_player, custom_ignore_tags, ...)
    return _IsDeployPointClear2(self, pt, inst, object_size, object_size_fn, near_other_fn, force_check_player or check_player, custom_ignore_tags, ...)
end

local DOCK_CANT_TAGS = {"tarpit"}
local _CanDeployDockAtPoint = Map.CanDeployDockAtPoint
function Map:CanDeployDockAtPoint(pt, inst, mouseover, ...)
    local _force_check_player = force_check_player
    force_check_player = true
    local ret = _CanDeployDockAtPoint(self, pt, inst, mouseover, ...)
    if ret then
        -- TILE_SCALE is the dimension of a tile; 1.0 is the approximate overhang, but we overestimate for safety.
        local min_distance_from_entities = (TILE_SCALE/2) + 1.2
        local dockblockers = TheSim:FindEntities(pt.x, 0,pt. z, min_distance_from_entities, DOCK_CANT_TAGS)
        ret = dockblockers == nil or #dockblockers == 0
    end
    force_check_player = _force_check_player
    return ret
end

local _CanDeployBoatAtPointInWater = Map.CanDeployBoatAtPointInWater
function Map:CanDeployBoatAtPointInWater(pt, inst, mouseover, data, ...)
    if TheWorld.no_dst_boats then
        return false
    end

    local _force_check_player = force_check_player
    force_check_player = true
    local ret = _CanDeployBoatAtPointInWater(self, pt, inst, mouseover, data, ...)
    force_check_player = _force_check_player
    return ret
end

---------------------------------------------------------

-- This entire method sucks and should be redone -Half
function Map:CanDeployAquaticAtPointInWater(pt, data, player)
    -- Will probabbly replace this with a is surrounded by water test eventually
    local x, y, z = pt:Get()

    if self:GetNearbyPlatformAtPoint(x, y, z, data.platform_buffer_min or TUNING.BOAT.NO_BUILD_BORDER_RADIUS) ~= nil then
        return false
    end

    local boating = true
    local platform = false
    if player ~= nil then
        local px, py, pz = player.Transform:GetWorldPosition()
        boating = self:IsOceanAtPoint(px, py, pz)
        platform = self:GetPlatformAtPoint(px,py,pz)
    end

    if data.boat and not TheWorld.has_ia_boats then
        return false
    end

    if boating or platform then
        if platform and platform.components.walkableplatform and math.sqrt(platform:GetDistanceSqToPoint(x, 0, z)) > platform.components.walkableplatform.platform_radius + (data.platform_buffer_max or 0.5) + 1.3 then --1.5 is closer but some distance should be cut for ease of use
            return false
        end
        local min_buffer = data.aquatic_buffer_min or 2
        -- Add 1 for overhang
        return self:IsSurroundedByWater(x, y, z, min_buffer + 1)
    else
        if data.noshore then --used by the ballphinhouse
            return false
        end

        if not TileGroupManager:IsOceanTile(self:GetVisualTileAtPoint(x, y, z)) then
            return false
        end

        local min_buffer = data.shore_buffer_min or 0.5

        if not self:IsSurroundedByWater(x, y, z, min_buffer) then
            return false
        end

        local max_buffer = data.shore_buffer_max or 2

        if not self:IsCloseToLand(x, y, z, max_buffer, true) then
            return false
        end

        return true
    end
end

---------------------------------------------------------

-- Placing on ocean or not
local _CanDeployRecipeAtPoint = Map.CanDeployRecipeAtPoint
function Map:CanDeployRecipeAtPoint(pt, recipe, rot, player, ...)

    if not recipe.aquatic or BUILDMODE.WATER ~= recipe.build_mode then
        return self:RunWithoutIACorners(_CanDeployRecipeAtPoint, self, pt, recipe, rot, player, ...)
    end

    return (recipe.testfn == nil or recipe.testfn(pt, rot))
        and self:IsDeployPointClear(pt, nil, recipe.min_spacing or 3.2)
        and self:CanDeployAquaticAtPointInWater(pt, recipe.aquatic, player)
end

local function IsNearOther(other, pt, min_spacing_sq)
    --FindEntities range check is <=, but we want <
    return other:GetDistanceSqToPoint(pt.x, 0, pt.z) < (other.deploy_extra_spacing ~= nil and math.max(other.deploy_extra_spacing * other.deploy_extra_spacing, min_spacing_sq) or min_spacing_sq)
end

local function IsNearOtherWallOrPlayer(other, pt, min_spacing_sq)
    if other:HasTag("wall") or other:HasTag("player") then
        local x, y, z = other.Transform:GetWorldPosition()
        return math.floor(x) == math.floor(pt.x) and math.floor(z) == math.floor(pt.z)
    end
    return IsNearOther(other, pt, min_spacing_sq)
end

function Map:CanDeployWaterWallAtPoint(pt, inst)
    -- We assume that walls use placer.snap_to_meters, so let's emulate the snap here.
    pt = Vector3(math.floor(pt.x) + 0.5, pt.y, math.floor(pt.z) + 0.5)

    local x,y,z = pt:Get()
    local ispassable, is_overhang = self:IsPassableAtPointWithPlatformRadiusBias(x,y,z, true, true, TUNING.BOAT.NO_BUILD_BORDER_RADIUS, self.ia_overhang)
    return ispassable and self:IsDeployPointClear(pt, inst, 1, nil, IsNearOtherWallOrPlayer) and self:CanDeployAtPointInWater(pt, inst)
end

local VOLCANO_PLANT_TILES = table.invert{
    WORLD_TILES.MAGMAFIELD,
    WORLD_TILES.ASH,
    WORLD_TILES.VOLCANO,
}

function Map:CanVolcanoPlantAtPoint(x, y, z)
    local tile = self:GetTileAtPoint(x, y, z)
    return VOLCANO_PLANT_TILES[tile]
end

local _CanDeployPlantAtPoint = Map.CanDeployPlantAtPoint
function Map:CanDeployPlantAtPoint(pt, inst, ...)
    if inst:HasTag("volcanicplant") then
        return self:CanVolcanoPlantAtPoint(pt:Get()) and self:IsDeployPointClear(pt, inst, inst.replica.inventoryitem ~= nil and inst.replica.inventoryitem:DeploySpacingRadius() or DEPLOYSPACING_RADIUS[DEPLOYSPACING.DEFAULT])
    else
        return _CanDeployPlantAtPoint(self, pt, inst, ...)
    end
end

local SANDBAG_TAGS = { "sandbag" }
local _CanDeployWallAtPoint = Map.CanDeployWallAtPoint
function Map:CanDeployWallAtPoint(pt, inst, ...)

    for i, v in ipairs(TheSim:FindEntities(pt.x, 0, pt.z, 2, SANDBAG_TAGS)) do
        if v ~= inst and v.entity:IsVisible() and v.components.placer == nil and v.entity:GetParent() == nil then
            local opt = v:GetPosition()
            -- important to remove sign in order to calculate accuracte distance
            if math.abs(math.abs(opt.x) - math.abs(pt.x)) < 1 and math.abs(math.abs(opt.z) - math.abs(pt.z)) < 1 then
                return false
            end
        end
    end

    return _CanDeployWallAtPoint(self, pt, inst, ...)
end

function Map:GetClosestTileDist(x, y, z, tile, radius)
    x, y = self:GetTileXYAtPoint(x, y, z)
    for r = 1, radius do
        if tile == self:GetTile(x - r, y) or tile == self:GetTile(x + r, y) or tile == self:GetTile(x, y - r) or tile == self:GetTile(x, y + r) then
            return r
        end

        for i = 1, r - 1 do
            if tile == self:GetTile(x + r, y + i) or tile == self:GetTile(x + r, y - i) or tile == self:GetTile(x - r, y + i) or tile == self:GetTile(x - r, y - i)
                or tile == self:GetTile(x + i, y + r) or tile == self:GetTile(x + i, y - r) or tile == self:GetTile(x - i, y + r) or tile == self:GetTile(x - i, y - r)
            then
                return math.sqrt(r * r + i * i)
            end
        end

        if tile == self:GetTile(x + r, y + r) or tile == self:GetTile(x + r, y - r) or tile == self:GetTile(x - r, y + r) or tile == self:GetTile(x - r, y - r) then
            return math.sqrt(2) * r
        end
    end

    return radius + 1
end

-- Copy of IsPassableAtPointWithPlatformRadiusBias that only checks the platform

local WALKABLE_PLATFORM_TAGS = {"walkableplatform"}
function Map:GetNearbyPlatformAtPoint(pos_x, pos_y, pos_z, extra_radius)
	if pos_z == nil then -- to support passing in (x, z) instead of (x, y, x)
		pos_z = pos_y
		pos_y = 0
	end
    local entities = TheSim:FindEntities(pos_x, pos_y, pos_z, math.max(TUNING.MAX_WALKABLE_PLATFORM_RADIUS + (extra_radius or 0), 0), WALKABLE_PLATFORM_TAGS) -- DST allows negitives but I dont want to risk it -Half
    for i, v in ipairs(entities) do
        if v.components.walkableplatform and math.sqrt(v:GetDistanceSqToPoint(pos_x, 0, pos_z)) <= v.components.walkableplatform.platform_radius + (extra_radius or 0) then
            return v
        end
    end
    return nil
end
