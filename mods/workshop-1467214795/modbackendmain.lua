local modimport = modimport
GLOBAL.setfenv(1, GLOBAL)

modimport("main/worldtiledefs")
modimport("main/tiledefs")
modimport("main/constants")
modimport("main/tuning")
modimport("main/worldsettings_overrides_ia")

require("map/ia_lockandkey")

modimport("postinit/map/task")
modimport("postinit/map/level")
modimport("postinit/map/graph")
modimport("postinit/map/node")
modimport("postinit/map/maptags")
modimport("postinit/map/storygen")
modimport("postinit/map/forest_map")
modimport("postinit/map/terrain")

require("map/ia_layouts")
require("map/ia_boons")
require("map/ia_traps")
require("map/tasks/volcano")
require("map/tasks/shipwrecked")

--fix last minute RoT retrofitting changes <.<
local savefileupgrades = require("savefileupgrades")
for i, v in ipairs(savefileupgrades.upgrades) do
	print("retro",v,v.version)
	if v.version and (v.version == 5.00 or v.version == 5.01 or v.version == 5.0) then
		print("\"Retrofit\" complete")
		v.fn = function(savedata) end
		break
	end
end

if ModManager.worldgen then
    local funcs = {}

    function hook()
        -- passing 2 to to debug.getinfo means 'give me info on the function that spawned
        -- this call to this function'. level 1 is the C function that called the hook.
        local info = debug.getinfo(1)
        if info ~= nil then
        if funcs[info.name] == nil or funcs[info.name] == true then return end
            local i, variables = 1, {""}
            -- now run through all the local variables at this level of the lua stack
            while true do
                local name, value = debug.getlocal(2, i)
                if name == nil then
                    break
                end
                -- this just skips unused variables
                if name ~= "(*temporary)" then
                    variables[tostring(name)] = value
                end
                i = i + 1
            end
                -- this is what dumps info about a function thats been called
            print((info.name or "unknown").. "(".. DataDumper(variables, '').. ")")
        funcs[info.name] = true
        end
    end

    -- tell the debug library to call lua function 'hook 'every time a function call
    -- is made...
    --debug.sethook(hook, "c")

    for k,v in pairs(getmetatable(WorldSim).__index) do
        funcs[k] = false
    end
end
