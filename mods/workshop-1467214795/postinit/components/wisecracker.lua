local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local function bermudatriangleexit(inst, data)
    inst.components.talker:Say(GetString(inst, "ANNOUNCE_WORMHOLE"))
end

local function crab_fail(inst, data)
    inst.components.talker:Say(GetString(inst, "ANNOUNCE_CRAB_ESCAPE"))
end

local function trawl_full(inst, data)
    inst.components.talker:Say(GetString(inst, "ANNOUNCE_TRAWL_FULL"))
end

local function boat_damaged(inst, data)
    inst.components.talker:Say(GetString(inst, data.message))
end

local function boostbywave(inst, data)
    if not inst.last_wave_boost_talk or GetTime() - inst.last_wave_boost_talk > TUNING.SEG_TIME * 3 then
        inst.last_wave_boost_talk = GetTime()
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_WAVE_BOOST"))
    end
end

local function whalehuntlosttrail(inst, data)
    if data.washedaway then
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_WHALE_HUNT_LOST_TRAIL_SPRING"))
    else
        inst.components.talker:Say(GetString(inst, "ANNOUNCE_WHALE_HUNT_LOST_TRAIL"))
    end
end

local function whalehuntbeastnearby(inst, data)
    inst.components.talker:Say(GetString(inst, "ANNOUNCE_WHALE_HUNT_BEAST_NEARBY"))
end

local function treasureuncover(inst, data)
    inst.components.talker:Say(GetString(inst, "ANNOUNCE_TREASURE_DISCOVER"))
end

local function magic_fail(inst, data)
    inst.components.talker:Say(GetString(inst, "ANNOUNCE_MAGIC_FAIL"))
end

IAENV.AddComponentPostInit("wisecracker", function(cmp)
    cmp.inst:ListenForEvent("bermudatriangleexit", bermudatriangleexit)
    cmp.inst:ListenForEvent("crab_fail", crab_fail)
    cmp.inst:ListenForEvent("trawl_full", trawl_full)
    cmp.inst:ListenForEvent("boat_damaged", boat_damaged)
    cmp.inst:ListenForEvent("boostbywave", boostbywave)
    cmp.inst:ListenForEvent("whalehuntlosttrail", whalehuntlosttrail)
    cmp.inst:ListenForEvent("whalehuntbeastnearby", whalehuntbeastnearby)
    cmp.inst:ListenForEvent("treasureuncover", treasureuncover)
    -- This is just for the volcano staff used underground
    cmp.inst:ListenForEvent("magic_fail", magic_fail)
end)
