require("map/lockandkey")

local function AddSimpleKeyLock(name)
    table.insert(KEYS_ARRAY, name)
    KEYS[name] = #KEYS_ARRAY
    table.insert(LOCKS_ARRAY, name)
    LOCKS[name] = #KEYS_ARRAY
    LOCKS_KEYS[LOCKS[name]] = {KEYS[name]}
end

AddSimpleKeyLock("ISLAND1")
AddSimpleKeyLock("ISLAND2")
AddSimpleKeyLock("ISLAND3")
AddSimpleKeyLock("ISLAND4")
AddSimpleKeyLock("ISLAND5")