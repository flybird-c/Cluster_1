local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Weapon = require("components/weapon")

function Weapon:SetPoisonous() 
    self.stimuli = "poisonous" 
end

local _OnAttack = Weapon.OnAttack
function Weapon:OnAttack(attacker, target, ...)
    _OnAttack(self, attacker, target, ...)
    
    if self.inst.components.obsidiantool then
        self.inst.components.obsidiantool:Use(attacker, target)
    end
end

