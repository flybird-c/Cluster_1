local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Health = require("components/health")

function Health:DoPoisonDamage(amount, doer)
    if not self.invincible and self.vulnerabletopoisondamage and self.poison_damage_scale > 0 then
        if amount > 0 then
            self:DoDelta(-amount*self.poison_damage_scale, false, "poison")
        end
    end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddComponentPostInit("health", function(cmp)
    cmp.vulnerabletopoisondamage = true
    cmp.poison_damage_scale = 1
end)
