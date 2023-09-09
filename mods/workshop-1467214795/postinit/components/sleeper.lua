local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

require("components/sleeper")

local _DefaultWakeTest = DefaultWakeTest
function DefaultWakeTest(inst, ...)
    return _DefaultWakeTest(inst, ...) and not (inst.components.poisonable and inst.components.poisonable:IsPoisoned())
end

local _StandardSleepChecks = StandardSleepChecks
function StandardSleepChecks(inst, ...)
    if inst.components.sleeper.onlysleepsfromitems then
        return false
    end
    return _StandardSleepChecks(inst, ...)
end

local _StandardWakeChecks = StandardWakeChecks
function StandardWakeChecks(inst, ...)
    if inst.components.sleeper.onlysleepsfromitems then
        return true
    end
    return _StandardWakeChecks(inst, ...)
end
