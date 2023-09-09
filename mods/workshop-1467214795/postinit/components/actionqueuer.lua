local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

IAENV.AddComponentPostInit("actionqueuer", function(self)
    if not self.AddActionList then return end

    self.AddActionList("allclick", "HACK")

    self.AddActionList("leftclick", "REPAIRBOAT", "RETRIEVE")

    self.AddActionList("noworkdelay", "HACK")

    self.AddActionList("tools", "HACK")

    self.AddActionList("autocollect", "HACK")

    if not self.EndlessRepeat then -- Check for Lazy Controls
        self.AddAction("leftclick", "HARVEST", function(target)
            return target.prefab ~= "birdcage"
                and not (target.prefab == "fish_farm"
                    and target.current_volume ~= nil
                    and target.current_volume:value() == 1)
        end)
        self.AddAction("noworkdelay", "HARVEST", function(target)
            return not (target.prefab == "fish_farm"
                and target.current_volume ~= nil
                and target.current_volume:value() == 2)
        end)
    end
end)
