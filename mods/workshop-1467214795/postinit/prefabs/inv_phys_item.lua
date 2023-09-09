local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

-- Items that dont have floater and dont sink but should still pass through ocean_limits
local InvPhys = {
    "lost_toy_1",
    "lost_toy_2",
    "lost_toy_7",
    "lost_toy_10",
    "lost_toy_11",
    "lost_toy_14",
    "lost_toy_18",
    "lost_toy_19",
    "lost_toy_42",
    "lost_toy_43",
}

for k, v in pairs(InvPhys) do
    IAENV.AddPrefabPostInit(k, function(inst)
        inst.Physics:SetShouldPassGround(true)
    end)
end
