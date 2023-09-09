local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Inventory = require("components/inventory")

local _GetEquippedItem = Inventory.GetEquippedItem
function Inventory:GetEquippedItem(eslot)
    if eslot == nil then
        return false
    else
        return _GetEquippedItem(self, eslot)
    end
end

local _Equip = Inventory.Equip
function Inventory:Equip(item, ...)
	if item == nil or item.components.equippable == nil or item.components.equippable.equipslot == nil then
        return false
    else
        return _Equip(self, item, ...)
    end
end

function Inventory:HasEquip(prefab)
    for k, v in pairs(self.equipslots) do
        if v.prefab == prefab then
            return true
        end
    end
end

function Inventory:GetWindproofness(slot)
    local windproofness = 0
    if slot then
        local item = self:GetItemSlot(slot)
        if item and item.components.windproofer then
            windproofness = windproofness + item.components.windproofer.GetEffectiveness()
        end
    else
        for k,v in pairs(self.equipslots) do
            if v and v.components.windproofer then
                windproofness = windproofness + v.components.windproofer:GetEffectiveness()  
            end
        end
    end
    return windproofness
end

function Inventory:DropItemBySlot(slot)
    local item = self:RemoveItemBySlot(slot)
    if item ~= nil then
        item.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
        if item.components.inventoryitem ~= nil then
            item.components.inventoryitem:OnDropped(true)
        end
        item.prevcontainer = nil
        item.prevslot = nil
        self.inst:PushEvent("dropitem", { item = item })
    end
end

function Inventory:IsWindproof()
    return self:GetWindproofness() >= 1
end

local _IsInsulated = Inventory.IsInsulated
function Inventory:IsInsulated(...)
    return self.insulated or _IsInsulated(self, ...)
end

-- Disable client prediction of the drop location because it messes with the boattoss rotation
-- Ideally syncing the rotation would be better but client prediction is just so broken when sailing I dont think it will work...
local _DropItemFromInvTile = Inventory.DropItemFromInvTile
function Inventory:DropItemFromInvTile(item, single, ...)
    if self.inst:IsSailing() then
        if not self.inst.sg:HasStateTag("busy") and
            self:CanAccessItem(item) and
            self.inst.components.playercontroller ~= nil then
            local buffaction = BufferedAction(self.inst, nil, ACTIONS.DROP, item)
            buffaction.options.wholestack = not (single and item.components.stackable ~= nil and item.components.stackable:IsStack())
            buffaction.options.instant = self.inst.sg ~= nil and self.inst.sg:HasStateTag("overridelocomote")
            self.inst.components.locomotor:PushAction(buffaction, true)
        end
    else
        return _DropItemFromInvTile(self, item, single, ...)
    end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local function InvSpaceChanged(inst)
    inst:PushEvent("invspacechange", {percent = inst.components.inventory:NumItems() / inst.components.inventory.maxslots})
end

IAENV.AddComponentPostInit("inventory", function(cmp)
    cmp.inst:ListenForEvent("itemget", InvSpaceChanged)
    cmp.inst:ListenForEvent("itemlose", InvSpaceChanged)
    cmp.inst:ListenForEvent("dropitem", InvSpaceChanged)
end)
