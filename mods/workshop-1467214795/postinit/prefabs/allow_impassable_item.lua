local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local prefabs = {
    "orangestaff",
}

local function fn(inst)
    -- For use on sw boats
    inst:AddTag("allow_action_on_impassable")
end

for _, prefab in ipairs(prefabs) do
    IAENV.AddPrefabPostInit(prefab, fn)
end
