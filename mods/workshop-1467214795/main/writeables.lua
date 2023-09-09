local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local writeables = require("writeables")

local boat_weight = {
    prompt = "", -- Unused
    animbank = "ui_board_5x3",
    animbuild = "ui_board_5x3",
    menuoffset = Vector3(6, -70, 0),

    cancelbtn = {
        text = STRINGS.BEEFALONAMING.MENU.CANCEL,
        cb = nil,
        control = CONTROL_CANCEL
    },

    acceptbtn = {
        text = STRINGS.BEEFALONAMING.MENU.ACCEPT,
        cb = nil,
        control = CONTROL_ACCEPT
    },
}

local fn = loadfile("prefabs/boats")
if fn then
    local boats = {fn()}
    for k, prefab in ipairs(boats) do
        if not string.find(prefab.name, "placer") then
            writeables.AddLayout(prefab.name, boat_weight)
            writeables.AddLayout("player_" .. prefab.name, boat_weight)
        end
    end
end