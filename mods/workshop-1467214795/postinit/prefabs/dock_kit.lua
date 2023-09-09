local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local IA_DOCK_TILES = table.invert({
    WORLD_TILES.OCEAN_SHALLOW,
    WORLD_TILES.MANGROVE,
    WORLD_TILES.OCEAN_CORAL,
})

local _CLIENT_CanDeployDockKit = nil
local function CLIENT_CanDeployDockKit(inst, pt, mouseover, deployer, rotation, ...)
    local tile = TheWorld.Map:GetTileAtPoint(pt.x, 0, pt.z)
    if IA_DOCK_TILES[tile] then
        local tx, ty = TheWorld.Map:GetTileCoordsAtPoint(pt.x, 0, pt.z)
        local found_adjacent_safetile = false
        for x_off = -1, 1, 1 do
            for y_off = -1, 1, 1 do
                if (x_off ~= 0 or y_off ~= 0) and IsLandTile(TheWorld.Map:GetTile(tx + x_off, ty + y_off)) then
                    found_adjacent_safetile = true
                    break
                end
            end

            if found_adjacent_safetile then break end
        end

        if found_adjacent_safetile then
            local center_pt = Vector3(TheWorld.Map:GetTileCenterPoint(tx, ty))
            return found_adjacent_safetile and TheWorld.Map:CanDeployDockAtPoint(center_pt, inst, mouseover)
        end
    end

    return _CLIENT_CanDeployDockKit(inst, pt, mouseover, deployer, rotation, ...)
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("dock_kit", function(inst)
    if not _CLIENT_CanDeployDockKit then
        _CLIENT_CanDeployDockKit = inst._custom_candeploy_fn
    end
    inst._custom_candeploy_fn = CLIENT_CanDeployDockKit
end)