local IAENV = env
GLOBAL.setfenv(1, GLOBAL)
local function fn(inst)
    if TheWorld.ismastersim then
        local _SCAN_CAN = UpvalueHacker.GetUpvalue(inst.TryFindTarget, "SCAN_CAN")
        table.insert(_SCAN_CAN, "scannable")
    end
end

IAENV.AddPrefabPostInit("wx78_scanner", fn)
