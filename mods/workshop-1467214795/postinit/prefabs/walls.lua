local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------
local walls = {
    wall_hay = {
        WINDBLOWN_SPEED = TUNING.WALLHAY_WINDBLOWN_SPEED,
        WINDBLOWN_DAMAGE_CHANCE = TUNING.WALLHAY_WINDBLOWN_DAMAGE_CHANCE,
        WINDBLOWN_DAMAGE = TUNING.WALLHAY_WINDBLOWN_DAMAGE,
    },
    wall_wood = {
        WINDBLOWN_SPEED = TUNING.WALLHAY_WINDBLOWN_SPEED,
        WINDBLOWN_DAMAGE_CHANCE = TUNING.WALLHAY_WINDBLOWN_DAMAGE_CHANCE,
        WINDBLOWN_DAMAGE = TUNING.WALLHAY_WINDBLOWN_DAMAGE,
    },
}

local function fn(inst)
    local windblown_prefab = inst.prefab and walls[inst.prefab]
    if windblown_prefab and windblown_prefab.WINDBLOWN_SPEED and windblown_prefab.WINDBLOWN_DAMAGE_CHANCE and windblown_prefab.WINDBLOWN_DAMAGE then
        MakeHammerableBlowInWindGust(inst, windblown_prefab.WINDBLOWN_SPEED, windblown_prefab.WINDBLOWN_DAMAGE_CHANCE, windblown_prefab.WINDBLOWN_DAMAGE)
    end
end

for i,v in pairs(walls) do
    IAENV.AddPrefabPostInit(i, fn)
end

