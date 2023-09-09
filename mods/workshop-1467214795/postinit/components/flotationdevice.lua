local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local FlotationDevice = require("components/flotationdevice")

function FlotationDevice:SetTest(test)
    self.testfn = test
end

function FlotationDevice:Test()
    if self.testfn ~= nil then
        return self.testfn(self.inst)
    end
    return true
end

function FlotationDevice:GetRescueData()
    return {source = self.inst}
end

IAENV.AddComponentPostInit("flotationdevice", function(cmp)
    cmp.testfn = nil
end)