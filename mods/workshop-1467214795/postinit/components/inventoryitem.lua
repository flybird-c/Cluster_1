local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local InventoryItem = require("components/inventoryitem")

local _ShouldEntitySink = ShouldEntitySink
function ShouldEntitySink(entity, ...)
    local inventory = (entity.components ~= nil and entity.components.inventoryitem) or nil
    return entity:IsValid() and (inventory == nil or not inventory:IsHeld()) and TheWorld.Map:RunWithoutIACorners(_ShouldEntitySink, entity, ...)
end

local _ShouldSink = InventoryItem.ShouldSink
function InventoryItem:ShouldSink(...)
	return self.inst:IsValid() and not self:IsHeld() and TheWorld.Map:RunWithoutIACorners(_ShouldSink, self, ...)
end

local function _ia_get_sinkfx(entity, tile)
    if tile == WORLD_TILES.VOLCANO_LAVA then
        if entity:HasTag("heavy") then
            return "lava_bombsplash"
        end
        return "splash_lava_drop"
    elseif TheWorld:HasTag("volcano") and TileGroupManager:IsImpassableTile(tile) then
        if entity:HasTag("heavy") then
            return "clouds_bombsplash"
        end
        return "splash_clouds_drop"
    end
    return "splash_water_sink"
end

local _SinkEntity = SinkEntity
function SinkEntity(entity, ...)
    if not entity:IsValid() or not TheWorld.has_ia_ocean then
        return _SinkEntity(entity, ...)
    end

    local px, py, pz = 0, 0, 0
    if entity.Transform ~= nil then
        px, py, pz = entity.Transform:GetWorldPosition()
    end

    if entity.components.inventory ~= nil then
        entity.components.inventory:DropEverything()
    end

    if entity.components.container ~= nil then
        entity.components.container:DropEverything()
    end

    local tile = TheWorld.Map:GetTileAtPoint(px, py, pz)
    local fx = SpawnPrefab(_ia_get_sinkfx(entity, tile))
    fx.Transform:SetPosition(px, py, pz)
    --sink sound is done by the fx

    -- If the entity is irreplaceable, respawn it at the player
    if entity:HasTag("irreplaceable") then
        local sx, sy, sz = FindRandomPointOnShoreFromOcean(px, py, pz)
        if sx ~= nil then
            entity.Transform:SetPosition(sx, sy, sz)
        else
            -- Our reasonable cases are out... so let's loop to find the portal and respawn there.
            for k, v in pairs(Ents) do
                if v:IsValid() and v:HasTag("multiplayer_portal") then
                    entity.Transform:SetPosition(v.Transform:GetWorldPosition())
                end
            end
        end
    else
        -- if valid spawn a sunkenprefab
        if GetTileDepth(tile) < OCEAN_DEPTH.VERY_DEEP and not TileGroupManager:IsImpassableTile(tile)
            and entity.components.inventoryitem
            and entity.components.inventoryitem.cangoincontainer
            and entity.persists
            and not entity.nosunkenprefab then
            SpawnPrefab("sunkenprefab"):Initialize(entity)
        end
        entity:Remove()
    end
end

--TODO add monkeyball onlanded bounce sounds
--local _SetLanded = InventoryItem.SetLanded
--function InventoryItem:SetLanded(is_landed, should_poll_for_landing, ...)
--    _SetLanded(self, is_landed, should_poll_for_landing, ...)
    --if self.bouncesound and self.inst.Physics and self.inst.SoundEmitter and not is_landed and should_poll_for_landing then
    --    self.bouncetime = GetTime()
    --end
--end

local _DoDropPhysics = InventoryItem.DoDropPhysics
function InventoryItem:DoDropPhysics(x, y, z, randomdir, speedmult, ...)
    --if randomdir is a Vector3 that means its a tossdir
    if type(randomdir) == "table" and type(randomdir[1]) == "table" and randomdir[1]:IsVector3() and type(randomdir[2]) == "table" and randomdir[2]:IsVector3() then
        local tossdir = randomdir[1]
        --we reset the pos to the players incase the drop action dist was changed from 0
        x, y, z = randomdir[2]:Get()

        self:SetLanded(false, true)

        if self.inst.Physics ~= nil then
            local heavy = self.inst:HasTag("heavy")
            if not self.nobounce then
                y = y + (heavy and .5 or 1)
            end
            self.inst.Physics:Teleport(x + tossdir.x ,y,z + tossdir.z) --move the position a bit so it doesn't clip through the player

            local vel = Vector3(tossdir.x * 4, 5, tossdir.z * 4)
            self.inst.Physics:SetVel(vel.x, vel.y, vel.z)
        else
            self.inst.Transform:SetPosition(x, y, z)
        end
    else
        _DoDropPhysics(self, x, y, z, randomdir, speedmult, ...)
    end
end

-- Only update everything when an item has switched from land to water
function InventoryItem:UpdateWater()
    if not self.pushlandedevents or self.inst:IsAsleep() then return end
    -- TODO: Maybe create a system to push landed events when the item crosses the boundry?
    if self.inst.components.floater then
        if self.inst.components.floater:IsFloating() ~= self.inst.components.floater:ShouldShowEffect() then
            self.inst:PushEvent("on_landed")
        end
    end
    self:TryToSink()
    self.inst:PushEvent("on_update_water")
end

--copy of SetLanded but forces it to send the event regardless of if its already landed along with some other improvements, much better than refreshing it each time -Half
function InventoryItem:ForceLanded(is_landed, should_poll_for_landing)
    if is_landed ~= nil then --if nothing has been set dont change anything
        if not is_landed then

            -- If we're going from landed to not landed
            if self.pushlandedevents then
                self.inst:PushEvent("on_no_longer_landed")
            end
        else

            -- If we're going from not landed to landed
            if self.pushlandedevents then
                self.inst:PushEvent("on_landed")
                self:TryToSink()
            end
        end
    end
    if should_poll_for_landing ~= nil then --if nothing has been set dont change anything
        if should_poll_for_landing then
            self.inst:StartUpdatingComponent(self)
        else
            self.inst:StopUpdatingComponent(self)
        end
    end

    self.is_landed = is_landed
end

local _OnUpdate = InventoryItem.OnUpdate
function InventoryItem:OnUpdate(dt, ...)
    if self.inst.Physics == nil or not self.inst.Physics:ShouldPassGround() then
        return _OnUpdate(self, dt, ...)
    end

    local x,y,z = self.inst.Transform:GetWorldPosition()

    if x and y and z then
        local vely = 0
        if self.inst.Physics then
            local vx, vy, vz = self.inst.Physics:GetVelocity()
            vely = vy or 0

            if (not vx) or (not vy) or (not vz) then
                self:SetLanded(true, false)
            elseif (vx == 0) and (vy == 0) and (vz == 0) then
                self:SetLanded(true, false)
            end
        end

        if y + vely * dt * 1.5 < 0.01 and vely <= 0 then
            --unlike the dst one the ds one doesnt stop updating at this point, instead only stoping the update when (vx == 0) and (vy == 0) and (vz == 0) or they dont exist
            self:UpdateWater()
        end
    else
        self:SetLanded(true, false)
    end
end

local _InheritMoisture = InventoryItem.InheritMoisture
function InventoryItem:InheritMoisture(moisture, iswet, ...)
    if moisture ~= 0 -- Not perfect, but reduce the chance of miss judge
        and moisture == TheWorld.state.wetness
        and iswet == TheWorld.state.iswet
        and IsInIAClimate(self.inst) then

        return _InheritMoisture(self, TheWorld.state.islandwetness, TheWorld.state.islandiswet, ...)
    end
    return _InheritMoisture(self, moisture, iswet, ...)
end

local function onlongpickup(self, longpickup)
    self.inst.replica.inventoryitem:SetLongPickup(longpickup)
end

IAENV.AddComponentPostInit("inventoryitem", function(cmp)
    cmp.longpickup = false

    addsetter(cmp, "longpickup", onlongpickup)
end)