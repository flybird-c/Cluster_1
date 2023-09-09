local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Edible = require("components/edible")

local function onforcequickeat(self, new_value, old_value)
    if old_value ~= nil then
        self.inst:RemoveTag("edible_forcequickeat")
    end
    if new_value ~= nil then
        self.inst:AddTag("edible_forcequickeat")
    end
end

local _OnEaten = Edible.OnEaten
function Edible:OnEaten(eater, ...)
    -- Food is an implicit speed booster if it has caffeine
    if self.caffeinedelta ~= 0 and self.caffeineduration ~= 0 and eater and eater.components.locomotor then
        eater.components.locomotor:SetExternalSpeedAdder(eater, "CAFFEINE", self.caffeinedelta, self.caffeineduration)
    end

    -- Other food based speed modifiers
    if self.surferdelta ~= 0 and self.surferduration ~= 0 and eater and eater.components.locomotor then
        eater.components.locomotor:SetExternalSpeedAdder(eater, "SURF", self.surferdelta, self.surferduration)
    end
    if self.autodrydelta ~= 0 and self.autodryduration ~= 0 and eater and eater.components.locomotor then
        eater.components.locomotor:SetExternalSpeedAdder(eater, "AUTODRY", self.autodrydelta, self.autodryduration)
    end

    if self.autocooldelta ~= 0 and eater and eater.components.temperature then
        local current_temp = eater.components.temperature:GetCurrent()
        local new_temp = math.max(current_temp - self.autocooldelta, TUNING.STARTING_TEMP)
        eater.components.temperature:SetTemperature(new_temp)
    end

	if self.naughtyvalue > 0 and TheWorld.components.kramped and eater:HasTag("player") then
		TheWorld.components.kramped:OnNaughtyAction(self.naughtyvalue, eater)
	end

    _OnEaten(self, eater, ...)
end

function Edible:GetNaughtiness(eater)
    return self.naughtyvalue
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddComponentPostInit("edible", function(cmp)
    cmp.caffeineduration = 0
    cmp.caffeinedelta = 0
    cmp.surferduration = 0
    cmp.surferdelta = 0
    cmp.autodryduration = 0
    cmp.autodrydelta = 0
    cmp.autocooldelta = 0
    cmp.naughtyvalue = 0
    cmp.forcequickeat = false
    
    addsetter(cmp, "forcequickeat", onforcequickeat)
end)
