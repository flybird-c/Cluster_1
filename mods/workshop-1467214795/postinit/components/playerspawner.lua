local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

---------------------Transmitting the world by volcano------------------------

LastMigrator = nil
IAENV.AddComponentPostInit("playerspawner", function(self)

    -- NOTE: Unlike in DST worldmigrators can be on rot boats and on water

    -- Yah... Getting sent all the way to spawn just because someone removed your rot boat at the volcano is uhhh not good...
    local function FindShoreLandOffset(pos)
        local x, y, z = FindRandomPointOnShoreFromOcean(pos.x, 0, pos.z)
        if x ~= nil then
            return Vector3(x - pos.x, 0, z - pos.z)
        end
    end

    local function FindShoreWaterOffset(pos)
        local x, y, z = FindRandomPointOnOceanFromShore(pos.x, 0, pos.z)
        if x ~= nil then
            return Vector3(x - pos.x, 0, z - pos.z)
        end
    end

    local function FindBoatOffset(player, pos, radius)
        local boat = player.components.sailor and player.components.sailor:GetBoat() == nil and GetClosestBoatInRange(pos.x, 0, pos.z, radius + TUNING.AUTOEMBARK_BOATRANGE.MIGRATE_BONUS)
        if boat ~= nil then
            local x, y, z = boat.Transform:GetWorldPosition()
            player.components.sailor:Embark(boat, true)
            return Vector3(x - pos.x, 0, z - pos.z)
        end
    end

    local function FindOffset(player, position, start_angle, radius, attempts, check_los, ignore_walls, customcheckfn)
        local canwater = player:CanOnWater(true)
        local canland = player:CanOnLand(true)
        if canwater and canland then return FindWalkableOffset(position, start_angle, radius, attempts, check_los, ignore_walls, customcheckfn, true, true) end
        if canwater then return FindSwimmableOffset(position, start_angle, radius, attempts, check_los, ignore_walls, customcheckfn) or FindShoreWaterOffset(position) end
        return FindWalkableOffset(position, start_angle, radius, attempts, check_los, ignore_walls, customcheckfn, nil, true) or FindBoatOffset(player, position, radius) or FindShoreLandOffset(position)
    end

    local function NoHoles(pt)
        return not TheWorld.Map:IsPointNearHole(pt)
    end
    
    local function GetDestinationPortalLocation(player)
        local portal = nil
        if player.migration.worldid ~= nil and player.migration.portalid ~= nil then
            for i, v in ipairs(ShardPortals) do
                local worldmigrator = v.components.worldmigrator
                if worldmigrator ~= nil and worldmigrator:IsDestinationForPortal(player.migration.worldid, player.migration.portalid) then
                    portal = v
                    break
                end
            end
        end
    
        if portal ~= nil then
            print("Player will spawn close to portal #"..tostring(portal.components.worldmigrator.id))
            local x, y, z = portal.Transform:GetWorldPosition()

            if portal.components.migratorboatstorage ~= nil then
                portal.components.migratorboatstorage:UnDockPlayerBoat(player)
            end

            local offset = FindOffset(player, Vector3(x, 0, z), math.random() * PI * 2, portal:GetPhysicsRadius(0) + .5, 8, false, true, NoHoles)
    
            --V2C: Do this after caching physical values, since it might remove itself
            --     and spawn in a new "opened" version, making "portal" invalid.
            portal.components.worldmigrator:ActivatedByOther()
    
            if offset ~= nil then
                return x + offset.x, 0, z + offset.z
            end
            return x, 0, z
        elseif player.migration.dest_x ~= nil and player.migration.dest_y ~= nil and player.migration.dest_z ~= nil then
            local pt = Vector3(player.migration.dest_x, player.migration.dest_y, player.migration.dest_z)
            print("Player will spawn near ".. tostring(pt))
            pt = pt + (FindOffset(player, pt, math.random() * PI * 2, 2, 8, false, true, NoHoles) or Vector3(0,0,0))
            return pt:Get()
        else
            -- Return nil and let the og code run...
            -- print("Player will spawn at default location")
            -- return GetNextSpawnPosition()
        end
    end
    
	local _SpawnAtLocation = self.SpawnAtLocation
	self.SpawnAtLocation = function(self, inst, player, x, y, z, isloading, ...)
		-- if migrating, resolve map location
        if player.migration ~= nil then
            LastMigrator = player
            -- make sure we're not just back in our
            -- origin world from a failed migration
            if player.migration.worldid ~= TheShard:GetShardId() then
                x, y, z = GetDestinationPortalLocation(player)
                -- if nil was returned then run the original code
                if x == nil then return _SpawnAtLocation(self, inst, player, x, y, z, isloading, ...) end
                for i, v in ipairs(player.migrationpets) do
                    if v:IsValid() then
                        if v.Physics ~= nil then
                            v.Physics:Teleport(x, y, z)
                        elseif v.Transform ~= nil then
                            v.Transform:SetPosition(x, y, z)
                        end
                    end
                end
            end
            player.migration = nil
            player.migrationpets = nil
        end

		return _SpawnAtLocation(self, inst, player, x, y, z, isloading, ...)
	end
end)