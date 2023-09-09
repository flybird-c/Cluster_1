local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local InventoryItem = require("components/inventoryitem_replica")

local _CanDeploy = InventoryItem.CanDeploy
function InventoryItem:CanDeploy(pt, ...)
    local _map = TheWorld.Map
    if self.inst._tile_candeploy_fn then
        local tile = _map:GetTileAtPoint(pt:Get())
        if not self.inst._tile_candeploy_fn(tile) then
            return false
        end
    end

	return _map:RunWithoutIACorners(_CanDeploy, self, pt, ...)
end

function InventoryItem:SetLongPickup(longpickup)
    self.classified.longpickup:set(longpickup)
end

function InventoryItem:CanLongPickup()
    return self.classified ~= nil and self.classified.longpickup:value()
end

function InventoryItem:GetDeployDist()
    if self.inst.components.deployable then
        return self.inst.components.deployable:GetDeployDist()
    end
    return self.classified ~= nil and self.classified.deploydistance:value() or 0
end

function InventoryItem:DeployAtRange()
    if self.inst.components.deployable then
        self.inst.components.deployable:DeployAtRange()
    end
    return self.classified ~= nil and self.classified.deployatrange:value() or false
end

local _SerializeUsage = InventoryItem.SerializeUsage
function InventoryItem:SerializeUsage(...)
    _SerializeUsage(self, ...)
    if self.inst.components.obsidiantool then
        local charge, maxcharge = self.inst.components.obsidiantool:GetCharge()
        self.classified:SerializeObsidianCharge(charge / maxcharge)
    else
        self.classified:SerializeObsidianCharge(nil)
    end

    if self.inst.components.inventory then
        self.classified:SerializeInvSpace(self.inst.components.inventory:NumItems() / self.inst.components.inventory.maxslots)
    else
        self.classified:SerializeInvSpace(nil)
    end

    if self.inst.components.fuse then
        self.classified:SerializeFuse(self.inst.components.fuse.consuming and self.inst.components.fuse.fusetime or 0)
    else
        self.classified:SerializeFuse(nil)
    end
end

local _DeserializeUsage = InventoryItem.DeserializeUsage
function InventoryItem:DeserializeUsage(...)
    _DeserializeUsage(self, ...)
    if self.classified ~= nil then
        self.classified:DeserializeObsidianCharge()
        self.classified:DeserializeInvSpace()
        self.classified:DeserializeFuse()
    end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddClassPostConstruct("components/inventoryitem_replica", function(cmp)

    local _SetOwner = cmp.SetOwner
    function cmp:SetOwner(owner, ...)
        local boat_owner = owner ~= nil and owner:HasTag("boatcontainer") and owner.components.container ~= nil and owner.components.container.opener
        if boat_owner then
            if self.inst.Network ~= nil then
                self.inst.Network:SetClassifiedTarget(boat_owner)
            end
            if self.classified ~= nil then
                self.classified.Network:SetClassifiedTarget(boat_owner or self.inst)
            end
            return
        end
        return _SetOwner(self, owner, ...)
    end

    if TheWorld.ismastersim then
        cmp.inst:ListenForEvent("obsidianchargechange", function(inst, data)
    		cmp.classified:SerializeObsidianCharge(data.percent)
    	end)
        cmp.inst:ListenForEvent("invspacechange", function(inst, data)
            cmp.classified:SerializeInvSpace(data.percent)
        end)
        cmp.inst:ListenForEvent("fusechange", function(inst, data)
            cmp.classified:SerializeFuse(data.time)
        end)

    	local deployable = cmp.inst.components.deployable
    	if deployable ~= nil then
    		cmp.classified.deployatrange:set(deployable.deployatrange)
            cmp.classified.deploydistance:set(deployable.deploydistance)
    	end
    end

end)
