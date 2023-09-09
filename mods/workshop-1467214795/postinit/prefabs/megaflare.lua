local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local function flare_eventfn(event, data)
    --check pt for a bit of randomness when nearby another climate -Half
    if TheWorld ~= nil and data.pt ~= nil and IsInIAClimate(data.pt) then
        return "island_megaflare_detonated"
    end
end
local should_set_eventpost = true

IAENV.AddPrefabPostInit("megaflare", function(inst)
    if TheWorld.ismastersim then
    	if should_set_eventpost and TheWorld ~= nil then
            TheWorld:AddPushEventPostFn("megaflare_detonated", flare_eventfn)
            should_set_eventpost = false
        end
    end
end)
