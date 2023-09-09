GLOBAL.setfenv(1, GLOBAL)

local worldsettings_overrides = require("worldsettings_overrides")
local applyoverrides_post = worldsettings_overrides.Post

local function OverrideTuningVariables(tuning)
    if tuning ~= nil then
        for k, v in pairs(tuning) do
            if BRANCH == "dev" then
                assert(TUNING[k] ~= nil, string.format("%s does not exist in TUNING, either fix the spelling, or add the value to TUNING.", k))
            end
            ORIGINAL_TUNING[k] = TUNING[k]
            TUNING[k] = v
        end
    end
end

local SPAWN_MODE_FN =
{
    never = "SpawnModeNever",
    always = "SpawnModeHeavy",
    often = "SpawnModeMed",
    rare = "SpawnModeLight",
}

local function SetSpawnMode(spawner, difficulty)
    if spawner ~= nil then
        local fn_name = SPAWN_MODE_FN[difficulty]
        if fn_name then
            spawner[fn_name](spawner)
        end
    end
end

local SEASON_FRIENDLY_LENGTHS =
{
    noseason = 0,
    veryshortseason = TUNING.SEASON_LENGTH_FRIENDLY_VERYSHORT,
    shortseason = TUNING.SEASON_LENGTH_FRIENDLY_SHORT,
    default = TUNING.SEASON_LENGTH_FRIENDLY_DEFAULT,
    longseason = TUNING.SEASON_LENGTH_FRIENDLY_LONG,
    verylongseason = TUNING.SEASON_LENGTH_FRIENDLY_VERYLONG,
}

local SEASON_HARSH_LENGTHS =
{
    noseason = 0,
    veryshortseason = TUNING.SEASON_LENGTH_HARSH_VERYSHORT,
    shortseason = TUNING.SEASON_LENGTH_HARSH_SHORT,
    default = TUNING.SEASON_LENGTH_HARSH_DEFAULT,
    longseason = TUNING.SEASON_LENGTH_HARSH_LONG,
    verylongseason = TUNING.SEASON_LENGTH_HARSH_VERYLONG,
}

local MULTIPLY = {
    ["never"] = 0,
    ["veryrare"] = 0.25,
    ["rare"] = 0.5,
    ["uncommon"] = 0.75,
    ["default"] = 1, 
    ["often"] = 1.5,
    ["mostly"] = 1.75,
    ["always"] = 2,
    ["insane"] = 4,
}
local MULTIPLY_COOLDOWNS = {
    ["never"] = 0,
    ["veryrare"] = 2,
    ["rare"] = 1.5,
    ["default"] = 1,
    ["often"] = .5,
    ["always"] = .25,
}
local MULTIPLY_WAVES = {
    ["never"] = 0,
    ["veryrare"] = 0.25,
    ["rare"] = 0.5,
    ["default"] = 1,
    ["often"] = 1.25,
    ["always"] = 1.5,
}

--Overrides are after Load.
--To allow island components to Load, this is usually handled PreLoad in postinit/prefabs/world.lua
--However, the first time the world starts, there is no load, so this is the next-best opportunity.
applyoverrides_post.primaryworldtype = function(difficulty)
    if WORLDTYPES.volcanoclimate[difficulty] and not TheWorld:HasTag("volcano") then
        TheWorld:AddTag("volcano")
    end

    if WORLDTYPES.islandclimate[difficulty] and not TheWorld:HasTag("island") then
        TheWorld:AddTag("island")
        local volcanoisland = TheWorld.topology.ia_worldgen_version and TheWorld.topology and TheWorld.topology.overrides and TheWorld.topology.overrides.volcanoisland or "none"
        if volcanoisland == "always" and not TheWorld:HasTag("volcano") then
            TheWorld:AddTag("volcano")
        end
    end

    if not WORLDTYPES.defaultclimate[difficulty] and TheWorld:HasTag("forest") then
        TheWorld:RemoveTag("forest")
    end

    if TheWorld.SpawnIaPrefab then
        TheWorld:SpawnIaPrefab()
    end

    if TheWorld.InstallIaComponents then
        TheWorld:InstallIaComponents()
    end
end

applyoverrides_post.volcano = function(difficulty)
    if difficulty == "never" then
        local vm = TheWorld.components.volcanomanager
        if vm then
            vm:SetIntensity(0)
        end
    end
end

applyoverrides_post.dragoonegg = function(difficulty)
    local vm = TheWorld.components.volcanomanager
    if vm then
        vm:SetFirerainIntensity(MULTIPLY[difficulty] or 1)
    end
end

--[[
    applyoverrides_post.tides = function(difficulty)
    if difficulty == "never" then
        local tideflooding = TheWorld.components.tideflooding
        if tideflooding then
            tideflooding:SetMaxTideModifier(0)
        end
    end
end]]

applyoverrides_post.mild = function(difficulty)
    if difficulty == "random" then
        TheWorld:PushEvent("ms_setseasonlength_tropical", {season = "autumn", length = GetRandomItem(SEASON_FRIENDLY_LENGTHS), random = true})
    else
        TheWorld:PushEvent("ms_setseasonlength_tropical", {season = "autumn", length = SEASON_FRIENDLY_LENGTHS[difficulty]})
    end
end

applyoverrides_post.hurricane = function(difficulty)
    if difficulty == "random" then
        TheWorld:PushEvent("ms_setseasonlength_tropical", {season = "winter", length = GetRandomItem(SEASON_HARSH_LENGTHS), random = true})
    else
        TheWorld:PushEvent("ms_setseasonlength_tropical", {season = "winter", length = SEASON_HARSH_LENGTHS[difficulty]})
    end
end

applyoverrides_post.monsoon = function(difficulty)
    if difficulty == "random" then
        TheWorld:PushEvent("ms_setseasonlength_tropical", {season = "spring", length = GetRandomItem(SEASON_FRIENDLY_LENGTHS), random = true})
    else
        TheWorld:PushEvent("ms_setseasonlength_tropical", {season = "spring", length = SEASON_FRIENDLY_LENGTHS[difficulty]})
    end
end

applyoverrides_post.dry = function(difficulty)
    if difficulty == "random" then
        TheWorld:PushEvent("ms_setseasonlength_tropical", {season = "summer", length = GetRandomItem(SEASON_HARSH_LENGTHS), random = true})
    else
        TheWorld:PushEvent("ms_setseasonlength_tropical", {season = "summer", length = SEASON_HARSH_LENGTHS[difficulty]})
    end
end

applyoverrides_post.floods = function(difficulty)
    local monsoonflooding = TheWorld.components.monsoonflooding
    if monsoonflooding then
        local lvl = TUNING.MAX_PUDDLE_LEVEL --15,
        local freq = TUNING.PUDDLE_FREQUENCY --0.005,
		monsoonflooding:SetPuddleSettings(math.min(1, MULTIPLY[difficulty] or 1) * lvl, (MULTIPLY[difficulty] or 1) * freq)
    end
end

applyoverrides_post.oceanwaves = function(difficulty)
    local wlm = TheWorld.components.wavelanemanager
    if wlm then
        wlm:SetWaveSettings(MULTIPLY[difficulty] or 1)
    end
    local wm = TheWorld.components.wavemanager
    if wm ~= nil then
        wm:SetWaveSettings(MULTIPLY_WAVES[difficulty] or 1)
    end
end

applyoverrides_post.poison = function(difficulty)
    IA_CONFIG.poisonenabled = difficulty ~= "never"
end

applyoverrides_post.tigershark = function(difficulty)
    local tigersharker = TheWorld.components.tigersharker
    if tigersharker then
        tigersharker:SetChanceModifier(MULTIPLY[difficulty] or 1)
        tigersharker:SetCooldownModifier(MULTIPLY_COOLDOWNS[difficulty] or 1)
    end
end

applyoverrides_post.kraken = function(difficulty)
    local krakener = TheWorld.components.krakener
    if krakener then
        krakener:SetChanceModifier(MULTIPLY[difficulty] or 1)
        krakener:SetCooldownModifier(MULTIPLY_COOLDOWNS[difficulty] or 1)
    end
end

applyoverrides_post.twister = function(difficulty)
    local tuning_vars = {
        never = {
            SPAWN_TWISTER = false,
        },
        rare = {
            TWISTER_ATTACKS_PER_SEASON = 2,
            TWISTER_ATTACKS_OFF_SEASON = false,
        },
        --[[
        default = {
            TWISTER_ATTACKS_PER_SEASON = 4,
            TWISTER_ATTACKS_OFF_SEASON = false,
            SPAWN_TWISTER = true,
        },
        --]]
        often = {
            TWISTER_ATTACKS_PER_SEASON = 8,
            TWISTER_ATTACKS_OFF_SEASON = false,
        },
        always = {
            TWISTER_ATTACKS_PER_SEASON = 10,
            TWISTER_ATTACKS_OFF_SEASON = true,
        },
    }
    OverrideTuningVariables(tuning_vars[difficulty])
end

applyoverrides_post.mosquitos = function(difficulty)
    if TheWorld.components.floodmosquitospawner then
        SetSpawnMode(TheWorld.components.floodmosquitospawner, difficulty)
    end
end

local chess_fn = applyoverrides_post.chess
applyoverrides_post.chess = function(difficulty, ...)
    if chess_fn then
        chess_fn(difficulty, ...)
    end

    local chessnavy = TheWorld.components.chessnavy
    if chessnavy then
        chessnavy:SetDifficultyMultiplier(nil)
        chessnavy:SetFrequencyMultiplier(nil)
        if difficulty == "never" then
            -- chessnavy:SetDifficultyMultiplier(0)
            -- chessnavy:SetFrequencyMultiplier(90)
            chessnavy:SetEnabled(false)
        else
            chessnavy:SetEnabled(true)
        end
        if difficulty == "rare" then
            -- chessnavy:SetDifficultyMultiplier(.5)
            chessnavy:SetFrequencyMultiplier(2)
        elseif difficulty == "often" then
            chessnavy:SetDifficultyMultiplier(1.3)
            chessnavy:SetFrequencyMultiplier(.8)
        elseif difficulty == "always" then
            chessnavy:SetDifficultyMultiplier(1.5)
            chessnavy:SetFrequencyMultiplier(.6)
        end
    end
end

--[[applyoverrides_post.clock_segs = function(difficulty)
    if type(difficulty) == "table" then
        TheWorld:PushEvent("ms_setseasonclocksegs", difficulty)
    end
end]]

applyoverrides_post.crab_setting = function(difficulty)
    local tuning_vars =
    {
        never = {
            CRAB_ENABLED = false,
        },
        few = {
            CRAB_RESPAWN_TIME = TUNING.DAY_TIME_DEFAULT*6,
        },
        --[[
        default = {
            CRAB_RESPAWN_TIME = TUNING.DAY_TIME_DEFAULT*4,
            CRAB_ENABLED = true,
        },
        --]]
        many = {
            CRAB_RESPAWN_TIME = TUNING.DAY_TIME_DEFAULT*2,
        },
        always = {
            CRAB_RESPAWN_TIME = TUNING.DAY_TIME_DEFAULT*1,
        },
    }
    OverrideTuningVariables(tuning_vars[difficulty])
end

applyoverrides_post.wildbores_setting = function(difficulty)
    local tuning_vars =
    {
        never = {
            WILDBOREHOUSE_ENABLED = false,
        },
        few = {
            WILDBOREHOUSE_SPAWN_TIME = TUNING.TOTAL_DAY_TIME*6,
        },
        --[[
        default = {
            WILDBOREHOUSE_SPAWN_TIME  = TUNING.TOTAL_DAY_TIME*4,
            WILDBOREHOUSE_ENABLED = true,
        },
        --]]
        many = {
            WILDBOREHOUSE_SPAWN_TIME = TUNING.TOTAL_DAY_TIME*2,
        },
        always = {
            WILDBOREHOUSE_SPAWN_TIME = TUNING.TOTAL_DAY_TIME*1,
        },
    }
    OverrideTuningVariables(tuning_vars[difficulty])
end

applyoverrides_post.ballphin_setting = function(difficulty)
    local tuning_vars =
    {
        never = {
            BALLPHINHOUSE_ENABLED = false,
        },
        few = {
            BALLPHINHOUSE_REGEN_TIME = TUNING.TOTAL_DAY_TIME*6,
        },
        --[[
        default = {
            BALLPHINHOUSE_REGEN_TIME  = TUNING.TOTAL_DAY_TIME*4,
            BALLPHINHOUSE_ENABLED = true,
        },
        --]]
        many = {
            BALLPHINHOUSE_REGEN_TIME = TUNING.TOTAL_DAY_TIME*2,
        },
        always = {
            BALLPHINHOUSE_REGEN_TIME = TUNING.TOTAL_DAY_TIME*1,
        },
    }
    OverrideTuningVariables(tuning_vars[difficulty])
end

applyoverrides_post.primeape_setting = function(difficulty)
    local tuning_vars =
    {
        never = {
            PRIMEAPE_HUT_ENABLED = false,
        },
        few = {
            PRIMEAPE_HUT_REGEN_PERIOD = TUNING.SEG_TIME*6,
            PRIMEAPE_HUT_SPAWN_PERIOD = TUNING.SEG_TIME*2,
            PRIMEAPE_HUT_CHILDREN = {min = 3, max = 4},
        },
        --[[
        default = {
            PRIMEAPE_HUT_REGEN_PERIOD  = TUNING.SEG_TIME*4,
            PRIMEAPE_HUT_SPAWN_PERIOD = TUNING.SEG_TIME,
            PRIMEAPE_HUT_CHILDREN = {min = 3, max = 4},
            PRIMEAPE_HUT_ENABLED = true,
        },
        --]]
        many = {
            PRIMEAPE_HUT_REGEN_PERIOD = TUNING.SEG_TIME*2,
            PRIMEAPE_HUT_SPAWN_PERIOD = TUNING.SEG_TIME,
            PRIMEAPE_HUT_CHILDREN = {min = 4, max = 6},
        },
        always = {
            PRIMEAPE_HUT_REGEN_PERIOD = TUNING.SEG_TIME*1,
            PRIMEAPE_HUT_SPAWN_PERIOD = TUNING.SEG_TIME*0.5,
            PRIMEAPE_HUT_CHILDREN = {min = 6, max = 8},
        },
    }
    OverrideTuningVariables(tuning_vars[difficulty])
end

applyoverrides_post.lobster_setting = function(difficulty)
    local tuning_vars =
    {
        never = {
            LOBSTER_ENABLED = false,
        },
        few = {
            LOBSTER_RESPAWN_TIME = TUNING.DAY_TIME_DEFAULT*6,
        },
        --[[
        default = {
            LOBSTER_RESPAWN_TIME = TUNING.DAY_TIME_DEFAULT*4,
            LOBSTER_ENABLED = true,
        },
        --]]
        many = {
            LOBSTER_RESPAWN_TIME = TUNING.DAY_TIME_DEFAULT*2,
        },
        always = {
            LOBSTER_RESPAWN_TIME = TUNING.DAY_TIME_DEFAULT*1,
        },
    }
    OverrideTuningVariables(tuning_vars[difficulty])
end

applyoverrides_post.jellyfish_setting = function(difficulty)
    local tuning_vars =
    {
        never = {
            JELLYFISH_ENABLED = false,
        },
        few = {
            JELLYFISH_REGEN_PERIOD = TUNING.SEG_TIME*4,
            JELLYFISH_SPAWNER_JELLYFISH = 3,
        },
        --[[
        default = {
            JELLYFISH_REGEN_PERIOD = TUNING.SEG_TIME*2,
            JELLYFISH_SPAWNER_JELLYFISH = 5,
            JELLYFISH_ENABLED = true,
        },
        --]]
        many = {
            JELLYFISH_REGEN_PERIOD = TUNING.SEG_TIME*1,
            JELLYFISH_SPAWNER_JELLYFISH = 7,
        },
        always = {
            JELLYFISH_REGEN_PERIOD = TUNING.SEG_TIME*0.5,
            JELLYFISH_SPAWNER_JELLYFISH = 10,
        },
    }
    OverrideTuningVariables(tuning_vars[difficulty])
end

applyoverrides_post.swordfish_setting = function(difficulty)
    local tuning_vars =
    {
        never = {
            SWORDFISH_ENABLED = false,
        },
        few = {
            SWORDFISH_REGEN_PERIOD = TUNING.SWORDFISH_REGEN_PERIOD*1.5,
            SWORDFISH_SPAWN_PERIOD = TUNING.SWORDFISH_SPAWN_PERIOD*1.5,
        },
        --[[
        default = {
            SWORDFISH_REGEN_PERIOD = TUNING.SWORDFISH_REGEN_PERIOD*1,
            SWORDFISH_SPAWN_PERIOD = TUNING.SWORDFISH_SPAWN_PERIOD*1,
            SWORDFISH_ENABLED = true,
        },
        --]]
        many = {
            SWORDFISH_REGEN_PERIOD = TUNING.SWORDFISH_REGEN_PERIOD*0.5,
            SWORDFISH_SPAWN_PERIOD = TUNING.SWORDFISH_SPAWN_PERIOD*0.5,
        },
        always = {
            SWORDFISH_REGEN_PERIOD = TUNING.SWORDFISH_REGEN_PERIOD*0.25,
            SWORDFISH_SPAWN_PERIOD = TUNING.SWORDFISH_SPAWN_PERIOD*0.25,
        },
    }
    OverrideTuningVariables(tuning_vars[difficulty])
end

applyoverrides_post.solofish_setting = function(difficulty)
	local tuning_vars =
	{
		never = {
			SOLOFISH_ENABLED = false,
		},
		few = {
			SOLOFISH_REGEN_PERIOD = TUNING.TOTAL_DAY_TIME * 6
		},
		--[[
		default = {
			SOLOFISH_REGEN_PERIOD = TUNING.TOTAL_DAY_TIME * 4
			SOLOFISH_ENABLED = true,
		},
		--]]
		many = {
			SOLOFISH_REGEN_PERIOD = TUNING.TOTAL_DAY_TIME * 2
		},
		always = {
			SOLOFISH_REGEN_PERIOD = TUNING.TOTAL_DAY_TIME * 1
		},
	}
	OverrideTuningVariables(tuning_vars[difficulty])
end

applyoverrides_post.stungray_setting = function(difficulty)
    local tuning_vars =
    {
        never = {
            STINKRAY_ENABLED = false,
        },
        few = {
            STINKRAY_REGEN_PERIOD = TUNING.STINKRAY_REGEN_PERIOD*1.5,
        },
        --[[
        default = {
            SWORDFISH_REGEN_PERIOD = TUNING.STINKRAY_REGEN_PERIOD*1,
            STINKRAY_ENABLED = true,
        },
        --]]
        many = {
            STINKRAY_REGEN_PERIOD = TUNING.STINKRAY_REGEN_PERIOD*0.5,
        },
        always = {
            STINKRAY_REGEN_PERIOD = TUNING.STINKRAY_REGEN_PERIOD*0.25,
        },
    }
    OverrideTuningVariables(tuning_vars[difficulty])
end

applyoverrides_post.fishermerm_setting = function(difficulty)
    local tuning_vars =
    {
        never = {
            MERMHOUSE_FISHER_ENABLED = false,
        },
        few = {
            MERMHOUSE_FISHER_REGEN_TIME = TUNING.TOTAL_DAY_TIME * 8,
            MERMHOUSE_FISHER_CRAFTED_MERMS = 1,
            MERMHOUSE_FISHER_MERMS = 1,
        },
        --[[
        default = {
            MERMHOUSE_FISHER_REGEN_TIME = TUNING.TOTAL_DAY_TIME * 4,
            MERMHOUSE_FISHER_CRAFTED_MERMS = 1,
            MERMHOUSE_FISHER_MERMS = 2,
            MERMHOUSE_FISHER_ENABLED = true,
        },
        --]]
        many = {
            MERMHOUSE_FISHER_REGEN_TIME = TUNING.TOTAL_DAY_TIME * 2,
            MERMHOUSE_FISHER_CRAFTED_MERMS = 2,
            MERMHOUSE_FISHER_MERMS = 3,
        },
        always = {
            MERMHOUSE_FISHER_REGEN_TIME = TUNING.TOTAL_DAY_TIME * 1,
            MERMHOUSE_FISHER_CRAFTED_MERMS = 3,
            MERMHOUSE_FISHER_MERMS = 4,
        },
    }
    OverrideTuningVariables(tuning_vars[difficulty])
end

applyoverrides_post.sharkitten_setting = function(difficulty)
    local tuning_vars =
    {
        never = {
            SHARKITTEN_ENABLED = false,
        },
        few = {
            SHARKITTEN_REGEN_PERIOD = TUNING.SHARKITTEN_REGEN_PERIOD * 2,
            SHARKITTEN_SPAWN_PERIOD = TUNING.SHARKITTEN_SPAWN_PERIOD * 2,
            SHARKITTENSPAWNER_SHARKITTENS = 2,
        },
        --[[
        default = {
            SHARKITTEN_REGEN_PERIOD = TUNING.SHARKITTEN_REGEN_PERIOD * 1,
            SHARKITTEN_SPAWN_PERIOD = TUNING.SHARKITTEN_SPAWN_PERIOD * 1,
            SHARKITTENSPAWNER_SHARKITTENS = 4,
            SHARKITTEN_ENABLED  = true,
        },
        --]]
        many = {
            SHARKITTEN_REGEN_PERIOD = TUNING.SHARKITTEN_REGEN_PERIOD * 0.5,
            SHARKITTEN_SPAWN_PERIOD = TUNING.SHARKITTEN_SPAWN_PERIOD * 0.5,
            SHARKITTENSPAWNER_SHARKITTENS = 6,
        },
        always = {
            SHARKITTEN_REGEN_PERIOD = TUNING.SHARKITTEN_REGEN_PERIOD * 0.25,
            SHARKITTEN_SPAWN_PERIOD = TUNING.SHARKITTEN_SPAWN_PERIOD * 0.25,
            SHARKITTENSPAWNER_SHARKITTENS = 8,
        },
    }
    OverrideTuningVariables(tuning_vars[difficulty])
end

applyoverrides_post.dragoon_setting = function(difficulty)
    local tuning_vars =
    {
        never = {
            DRAGOON_ENABLED = false,
        },
        few = {
            DRAGOON_REGEN_PERIOD = TUNING.SEG_TIME*6,
            DRAGOON_SPAWN_PERIOD = TUNING.SEG_TIME*2,
            DRAGOON_CHILDREN = {min = 3, max = 4},
        },
        --[[
        default = {
            DRAGOON_REGEN_PERIOD  = TUNING.SEG_TIME*4,
            DRAGOON_SPAWN_PERIOD = TUNING.SEG_TIME,
            DRAGOON_CHILDREN = {min = 3, max = 4},
            DRAGOON_ENABLED = true,
        },
        --]]
        many = {
            DRAGOON_REGEN_PERIOD = TUNING.SEG_TIME*2,
            DRAGOON_SPAWN_PERIOD = TUNING.SEG_TIME,
            DRAGOON_CHILDREN = {min = 4, max = 6},
        },
        always = {
            DRAGOON_REGEN_PERIOD = TUNING.SEG_TIME*1,
            DRAGOON_SPAWN_PERIOD = TUNING.SEG_TIME*0.5,
            DRAGOON_CHILDREN = {min = 6, max = 8},
        },
    }
    OverrideTuningVariables(tuning_vars[difficulty])
end

applyoverrides_post.palmtree_regrowth = function(difficulty)
    local tuning_vars =
    {
        never = {
            PALMTREE_REGROWTH_TIME_MULT = 0,
        },
        veryslow = {
            PALMTREE_REGROWTH_TIME_MULT = 0.25,
        },
        slow = {
            PALMTREE_REGROWTH_TIME_MULT = 0.5,
        },
        --[[
        default = {
            PALMTREE_REGROWTH_TIME_MULT = 1,
        },
        --]]
        fast = {
            PALMTREE_REGROWTH_TIME_MULT = 1.5,
        },
        veryfast = {
            PALMTREE_REGROWTH_TIME_MULT = 3,
        },
    }
    OverrideTuningVariables(tuning_vars[difficulty])
end

applyoverrides_post.jungletree_regrowth = function(difficulty)
    local tuning_vars =
    {
        never = {
            JUNGLETREE_REGROWTH_TIME_MULT = 0,
        },
        veryslow = {
            JUNGLETREE_REGROWTH_TIME_MULT = 0.25,
        },
        slow = {
            JUNGLETREE_REGROWTH_TIME_MULT = 0.5,
        },
        --[[
        default = {
            JUNGLETREE_REGROWTH_TIME_MULT = 1,
        },
        --]]
        fast = {
            JUNGLETREE_REGROWTH_TIME_MULT = 1.5,
        },
        veryfast = {
            JUNGLETREE_REGROWTH_TIME_MULT = 3,
        },
    }
    OverrideTuningVariables(tuning_vars[difficulty])
end

--[[applyoverrides_post.mangrovetree_regrowth = function(difficulty)
    local tuning_vars =
    {
        never = {
            MANGROVETREE_REGROWTH_TIME_MULT = 0,
        },
        veryslow = {
            MANGROVETREE_REGROWTH_TIME_MULT = 0.25,
        },
        slow = {
            MANGROVETREE_REGROWTH_TIME_MULT = 0.5,
        },
        --default = {
            --MANGROVETREE_REGROWTH_TIME_MULT = 1,
        --},
        fast = {
            MANGROVETREE_REGROWTH_TIME_MULT = 1.5,
        },
        veryfast = {
            MANGROVETREE_REGROWTH_TIME_MULT = 3,
        },
    }
    OverrideTuningVariables(tuning_vars[difficulty])
end]]

applyoverrides_post.sweet_potato_regrowth = function(difficulty)
    local tuning_vars =
    {
        never = {
            SWEET_POTATO_REGROWTH_TIME_MULT = 0,
        },
        veryslow = {
            SWEET_POTATO_REGROWTH_TIME_MULT = 0.25,
        },
        slow = {
            SWEET_POTATO_REGROWTH_TIME_MULT = 0.5,
        },
        --default = {
            --SWEET_POTATO_REGROWTH_TIME_MULT = 1,
        --},
        fast = {
            SWEET_POTATO_REGROWTH_TIME_MULT = 1.5,
        },
        veryfast = {
            SWEET_POTATO_REGROWTH_TIME_MULT = 3,
        },
    }
    OverrideTuningVariables(tuning_vars[difficulty])
end

applyoverrides_post.no_dst_boats = function(difficulty)
    local _world = TheWorld
    if difficulty == "always" then
        _world.no_dst_boats = false
    elseif difficulty == "none" then
        _world.no_dst_boats = true
    else
        local primaryworldtype = _world.topology and _world.topology.overrides and _world.topology.overrides.primaryworldtype or nil
        _world.no_dst_boats = primaryworldtype == "islandsonly" or primaryworldtype == "volcanoonly"
    end
end

applyoverrides_post.has_ia_boats = function(difficulty)
    local _world = TheWorld
    if difficulty == "always" then
        _world.has_ia_boats = true
    elseif difficulty == "none" then
        _world.has_ia_boats = false
    else
        local primaryworldtype = _world.topology and _world.topology.overrides and _world.topology.overrides.primaryworldtype or nil
        _world.has_ia_boats = primaryworldtype == "islandsonly" or primaryworldtype == "volcanoonly"
    end
end

applyoverrides_post.has_ia_drowning = function(difficulty)
    local _world = TheWorld
    if difficulty == "always" then
        _world.has_ia_drowning = true
    elseif difficulty == "none" then
        _world.has_ia_drowning = false
    else
        local primaryworldtype = _world.topology and _world.topology.overrides and _world.topology.overrides.primaryworldtype or nil
        _world.has_ia_drowning = primaryworldtype == "islandsonly" or primaryworldtype == "volcanoonly"
    end
end
