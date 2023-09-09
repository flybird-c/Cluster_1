local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local InventoryItemMoisture = require("components/inventoryitemmoisture")

local _GetTargetMoisture = InventoryItemMoisture.GetTargetMoisture
function InventoryItemMoisture:GetTargetMoisture(...)
    if self.inst and self.inst:IsValid() then
        if IsInIAClimate(self.inst) then
            local _israining = rawget(TheWorld.state, "israining")
            local _wetness = rawget(TheWorld.state, "wetness")
            TheWorld.state.israining = TheWorld.state.islandisraining
            TheWorld.state.wetness = TheWorld.state.islandwetness
            local rets = {_GetTargetMoisture(self, ...)}
            TheWorld.state.israining = _israining
            TheWorld.state.wetness = _wetness
            return unpack(rets)
        end
        return _GetTargetMoisture(self, ...)
    end
    if self.inst then
        print(self.inst.prefab.." is not valid, InventoryItemMoisture:GetTargetMoisture will probably be wrong")
    end
    return _GetTargetMoisture(self, ...)
end

local _UpdateMoisture = InventoryItemMoisture.UpdateMoisture
function InventoryItemMoisture:UpdateMoisture(...)
    local t = GetTime()
    local dt = t - self.lastUpdate
    if dt <= 0 then
        return _UpdateMoisture(self, ...)
    end

    if self.inst:IsValid() and not self.inst.components.inventoryitem:IsHeld() and self.inst.components.floater and self.inst.components.floater:IsFloating() then
        self.lastUpdate = t
        if self.moisture < TUNING.MOISTURE_MAX_WETNESS then
            self:SetMoisture(TUNING.MOISTURE_MAX_WETNESS)
        end
    else
        if not self.inst.components.inventoryitem:IsHeld() then
            if self.inst.Transform then
                local x, y, z = self.inst.Transform:GetWorldPosition()
                if x and y and z then
					if IsOnFlood(x, y, z) then
                        local moisture = math.max(self.moisture, TUNING.MOISTURE_FLOOD_WETNESS)
                        if self.moisture < moisture then
                            self:SetMoisture(moisture)
                        end
                    end
                end
            end
        end
        return _UpdateMoisture(self, ...)
    end
end