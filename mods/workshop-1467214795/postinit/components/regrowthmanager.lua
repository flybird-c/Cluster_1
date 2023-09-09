local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

IAENV.AddComponentPostInit("regrowthmanager", function(self)
    local _worldstate = TheWorld.state

    self:SetRegrowthForType("sweet_potato_planted", TUNING.SWEET_POTATO_REGROWTH_TIME, "sweet_potato_planted", function()
        return not (_worldstate.isnight or _worldstate.iswinter or _worldstate.snowlevel > 0) and TUNING.SWEET_POTATO_REGROWTH_TIME_MULT or 0
    end)

    self:SetRegrowthForType("crabhole", TUNING.RABBITHOLE_REGROWTH_TIME, "crabhole", function()
        return (_worldstate.issummer and TUNING.RABBITHOLE_REGROWTH_TIME_SUMMER_MULT or TUNING.RABBITHOLE_REGROWTH_TIME_MULT > 0) and 1 or 0
    end)

    self:SetRegrowthForType("coral_brain_rock", TUNING.CORAL_BRAIN_REGROW_TIME, "coral_brain_rock", function()
        return TUNING.CORAL_BRAIN_REGROW_TIME_MULT
    end)

    self:SetRegrowthForType("shipwreck", TUNING.SHIPWRECK_REGROW_TIME, "shipwreck", function()
        return _worldstate.iswinter and (_worldstate.isnight and 2 or 1) or 0
    end)

    -- TODO Add configs for them
end)
