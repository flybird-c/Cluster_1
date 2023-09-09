local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

-----------------------------------------

local fn = require("play_commonfn")

local ERROR = { "ERROR" }

local general_scripts = require("play_generalscripts")

--[[
    MONOLOGUE_EXAMPLE = {
        cast = MONOLOGUE,  -- THIS IS FOR JUST ANYONE. GOES IN A POOL OF RANDOM CHOICE
        lines = {
                    {roles = {"MONOLOGUE"}, duration = 2.5, line = "line 1"},
                    {roles = {"MONOLOGUE"}, duration = 2.5, line = "line 2"},
        }
    }
]]

general_scripts.WALANI1 = {
    cast = { "walani" },
    lines = {
         {roles = {"walani"}, duration = 3.0, line = STRINGS.STAGEACTOR.WALANI1[1]},
         {roles = {"walani"}, duration = 3.0, line = STRINGS.STAGEACTOR.WALANI1[2]},
         {roles = {"walani"}, duration = 3.0, line = STRINGS.STAGEACTOR.WALANI1[3]},
         {roles = {"walani"}, duration = 3.0, line = STRINGS.STAGEACTOR.WALANI1[4]},
         {roles = {"walani"}, duration = 2.0, line = STRINGS.STAGEACTOR.WALANI1[5], anim="emote_sleepy"},
     }
}

general_scripts.WILBUR1 = {
    cast = { "wilbur" },
    lines = {
        {actionfn = fn.actorsbow,   duration = 2.5, },
        {roles = {"wilbur"},     duration = 3.0, line = STRINGS.STAGEACTOR.WILBUR1[1]},
        {roles = {"wilbur"},     duration = 3.0, line = STRINGS.STAGEACTOR.WILBUR1[2]},
        {roles = {"wilbur"},     duration = 2.5, line = STRINGS.STAGEACTOR.WILBUR1[3], anim="emoteXL_angry"},
        {roles = {"wilbur"},     duration = 3.0, line = STRINGS.STAGEACTOR.WILBUR1[4]},
        {roles = {"wilbur"},     duration = 3.0, line = STRINGS.STAGEACTOR.WILBUR1[5]},
        {roles = {"wilbur"},     duration = 3.0, line = STRINGS.STAGEACTOR.WILBUR1[6]},
        {roles = {"wilbur"},     duration = 2.5, line = STRINGS.STAGEACTOR.WILBUR1[7], anim="emoteXL_kiss"},
        {actionfn = fn.actorsbow,   duration = 0.2, },
    }
}

general_scripts.WOODLEGS1 = {
    cast = { "woodlegs" },
    lines = {
        {roles = {"woodlegs"},     duration = 4.0, line = STRINGS.STAGEACTOR.WOODLEGS1[1]},
        {roles = {"woodlegs"},     duration = 4.0, line = STRINGS.STAGEACTOR.WOODLEGS1[2]},
        {roles = {"woodlegs"},     duration = 4.0, line = STRINGS.STAGEACTOR.WOODLEGS1[3]},
        {roles = {"woodlegs"},     duration = 4.0, line = STRINGS.STAGEACTOR.WOODLEGS1[4]},
    }
}
