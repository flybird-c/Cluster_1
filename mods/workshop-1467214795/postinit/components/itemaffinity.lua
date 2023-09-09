local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local ItemAffinity = require("components/itemaffinity")

--have to override it to keep priority and not apply the effect twice, once for inventory and once for equipslots
--adds support for items in the head, body and hands equipslots
function ItemAffinity:RefreshAffinity()
    self:SortAffinities()
    self.inst.components.sanity.externalmodifiers:RemoveModifier(self.inst)

    for i,v in ipairs(self.affinities) do
        if v.prefab and (self.inst.components.inventory:Has(v.prefab, 1) or self.inst.components.inventory:HasEquip(v.prefab)) then
            self.inst.components.sanity.externalmodifiers:SetModifier(self.inst, v.sanity_bonus)
            break
        elseif v.tag and (self.inst.components.inventory:HasItemWithTag(v.tag, 1) or self.inst.components.inventory:EquipHasTag(v.tag)) then
            self.inst.components.sanity.externalmodifiers:SetModifier(self.inst, v.sanity_bonus)
            break
        end
    end
end

IAENV.AddComponentPostInit("itemaffinity", function(cmp)
    cmp.inst:ListenForEvent("equip", function() cmp:RefreshAffinity() end)
    cmp.inst:ListenForEvent("unequip", function() cmp:RefreshAffinity() end)
end)
