local brain = require "brains/birdbrain"

local function onTalkParrot(inst)
	inst.SoundEmitter:PlaySound("ia/creatures/parrot/chirp", "talk") 
end
local function doneTalkParrot(inst)
	inst.SoundEmitter:KillSound("talk")
end

local function ShouldSleep(inst)
    return DefaultSleepTest(inst) and not inst.sg:HasStateTag("flight")
end

local BIRD_TAGS = { "bird" }
local function OnAttacked(inst, data)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 30, BIRD_TAGS)
    local num_friends = 0
    local maxnum = 5
    for k, v in pairs(ents) do
        if v ~= inst then
            v:PushEvent("gohome")
            num_friends = num_friends + 1
        end

        if num_friends > maxnum then
            return
        end
    end
end

local function OnTrapped(inst, data)
    if data and data.trapper and data.trapper.settrapsymbols then
        data.trapper.settrapsymbols(inst.trappedbuild)
    end
end

local function OnPutInInventory(inst)
    --Otherwise sleeper won't work if we're in a busy state
    inst.sg:GoToState("idle")
end

local function OnDropped(inst)
	if IsOnOcean(inst) then
        inst.sg:GoToState("flyaway")
	else
		inst.sg:GoToState("stunned")
	end
end

local function ChooseItem()
    local mercy_items =
    {
        "flint",
        "flint",
        "flint",
        "twigs",
        "twigs",
        "cutgrass",
    }
    return mercy_items[math.random(#mercy_items)]
end

local function ChooseSeeds()
    -- return not TheWorld.state.iswinter and "seeds" or nil
    return "seeds"
end

local function SpawnPrefabChooser(inst)
    if inst.prefab == "parrot_pirate" then
        return "dubloon"
    elseif inst.prefab == "cormorant" then
        return --loot already spawned on landing
    elseif inst.prefab == "seagull" and not TheWorld.state.iswinter then
        return
    end

    if TheWorld.state.cycles <= 3 then
        -- The item drop is for drop-in players, players from the start of the game have to forage like normal
        return ChooseSeeds()
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, 20, true)

    -- Give item if only fresh players are nearby
    local oldestplayer = -1
    for i, player in ipairs(players) do
        if player.components.age ~= nil then
            local playerage = player.components.age:GetAgeInDays()
            if playerage >= 3 then
                return ChooseSeeds()
            elseif playerage > oldestplayer then
                oldestplayer = playerage
            end
        end
    end

    -- Lower chance for older players to get item
    return oldestplayer >= 0
        and math.random() < .35 - oldestplayer * .1
        and ChooseItem()
        or ChooseSeeds()
end

local function EatCormorantLoot(inst, bait)
	if bait and not inst.bufferedaction then
		inst.bufferedaction = BufferedAction(inst, bait, ACTIONS.EAT)
	end
end
local function SpawnCormorantLoot(inst)
	if not inst.bufferedaction and IsOnOcean(inst)
	and math.random() <= TUNING.CROW_LEAVINGS_CHANCE then
		inst.components.periodicspawner:TrySpawn("roe")
	end
end
local function ScheduleCormorantLoot(inst)
	local pos = inst:GetPosition()
	if pos.y > 1 then
		local vx, vy, vz = inst.Physics:GetMotorVel()
		inst:DoTaskInTime(pos.y / math.abs(vy) + .1, SpawnCormorantLoot)
	end
end

--------------------------------------------------------------------------

local function makebird(name, soundname, feathername, bank, water_bank, commonpostfn, masterpostfn)
    local featherpostfix = feathername or name

    local assets =
    {
        Asset("ANIM", "anim/crow.zip"),
        Asset("ANIM", "anim/".. name .."_build.zip"),
        Asset("SOUND", "sound/birds.fsb"),
    }

    if bank ~= nil then
        table.insert(assets, Asset("ANIM", "anim/"..bank..".zip"))
    end

    if water_bank ~= nil then
        table.insert(assets, Asset("ANIM", "anim/"..water_bank..".zip"))
    end

    local prefabs =
    {
        "seeds",
        "smallmeat",
        "cookedsmallmeat",

        --mercy items
        "flint",
        "twigs",
        "cutgrass",
    }

    if feathername ~= "none" then
        table.insert(prefabs, "feather_"..featherpostfix)
	end

    local soundbank = "ia"
	if type(soundname) == "table" then
		soundbank = soundname.bank
        soundname = soundname.name
	end

    local function fn()
        local inst = CreateEntity()

        --Core components
        inst.entity:AddTransform()
        inst.entity:AddPhysics()
        inst.entity:AddAnimState()
        inst.entity:AddDynamicShadow()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()
        inst.entity:AddLightWatcher()

        --Initialize physics
        inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
        inst.Physics:ClearCollisionMask()
        if water_bank ~= nil then
            -- Birds that float can pass through LIMITS walls, i.e. when hopping.
            inst.Physics:CollidesWith(COLLISION.GROUND)
        else
            inst.Physics:CollidesWith(COLLISION.WORLD)
        end
        inst.Physics:SetMass(1)
        inst.Physics:SetSphere(1)

        inst:AddTag("bird")
        inst:AddTag(name)
        inst:AddTag("smallcreature")
        inst:AddTag("likewateroffducksback")
        inst:AddTag("stunnedbybomb")

        --cookable (from cookable component) added to pristine state for optimization
        inst:AddTag("cookable")

        inst.Transform:SetTwoFaced()

        inst.AnimState:SetBank(bank or "crow")
        inst.AnimState:SetBuild(name.."_build")
        inst.AnimState:PlayAnimation("idle")

        inst.DynamicShadow:SetSize(1, .75)
        inst.DynamicShadow:Enable(false)

        MakeFeedableSmallLivestockPristine(inst)

        if commonpostfn ~= nil then commonpostfn(inst) end

        if water_bank ~= nil then
            MakeInventoryFloatable(inst)
            --dont use floaterfx as its handled by the water_bank
            inst.components.floater.no_float_fx = true
            inst.components.floater.splash = false
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.sounds =
        {
            takeoff = soundbank.."/creatures/"..soundname.."/takeoff",
            chirp = soundbank.."/creatures/"..soundname.."/chirp",
            flyin = "dontstarve/birds/flyin",
        }

        inst.trappedbuild = name.."_build"

        inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
        inst.components.locomotor:EnableGroundSpeedMultiplier(false)
        inst.components.locomotor:SetTriggersCreep(false)
        inst:SetStateGraph("SGbird")

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:AddRandomLoot("feather_"..featherpostfix, 1)
        inst.components.lootdropper:AddRandomLoot("smallmeat", 1)
        inst.components.lootdropper.numrandomloot = 1

        inst:AddComponent("occupier")

        inst:AddComponent("eater")
        inst.components.eater:SetDiet({ FOODTYPE.SEEDS }, { FOODTYPE.SEEDS })

        inst:AddComponent("sleeper")
        inst.components.sleeper.watchlight = true
        inst.components.sleeper:SetSleepTest(ShouldSleep)

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.nobounce = true
        inst.components.inventoryitem.canbepickedup = false
        inst.components.inventoryitem.canbepickedupalive = true
        --if water_bank ~= nil then --sw birds fly away but dst ones sink (there more used to the water i guess)
        --    inst.components.inventoryitem:SetSinks(true)
        --end

        inst:AddComponent("cookable")
        inst.components.cookable.product = "cookedsmallmeat"

        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(TUNING.BIRD_HEALTH)
        inst.components.health.murdersound = "dontstarve/wilson/hit_animal"

        inst:AddComponent("inspectable")

        if water_bank ~= nil then
            inst.flyawaydistance = TUNING.WATERBIRD_SEE_THREAT_DISTANCE
        else
            inst.flyawaydistance = TUNING.BIRD_SEE_THREAT_DISTANCE
        end

        if TheNet:GetServerGameMode() ~= "quagmire" then
            inst:AddComponent("combat")
            inst.components.combat.hiteffectsymbol = "crow_body"

            MakeSmallBurnableCharacter(inst, "crow_body")
            MakeTinyFreezableCharacter(inst, "crow_body")
        end

        inst:SetBrain(brain)

        inst:AddComponent("hauntable")
        inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)
        inst.components.hauntable.panicable = true

        if not GetGameModeProperty("disable_bird_mercy_items") then
            inst:AddComponent("periodicspawner")
            inst.components.periodicspawner:SetPrefab(SpawnPrefabChooser)
            inst.components.periodicspawner:SetDensityInRange(20, 2)
            inst.components.periodicspawner:SetMinimumSpacing(8)
        end

        inst:ListenForEvent("ontrapped", OnTrapped)
        inst:ListenForEvent("attacked", OnAttacked)

        local birdspawner = TheWorld.components.birdspawner
        if birdspawner ~= nil then
            inst:ListenForEvent("onremove", birdspawner.StopTrackingFn)
            inst:ListenForEvent("enterlimbo", birdspawner.StopTrackingFn)
            -- inst:ListenForEvent("exitlimbo", birdspawner.StartTrackingFn)
            birdspawner:StartTracking(inst)
        end

        MakeFeedableSmallLivestock(inst, TUNING.BIRD_PERISH_TIME, OnPutInInventory, OnDropped)

        if masterpostfn ~= nil then masterpostfn(inst) end

        if water_bank ~= nil then
            -- Only switch banks if we have passed the water boundry/rot boat boundry
            -- If we check the floater events then the takeoff anim will be incorrect
            inst:ListenForEvent("on_landed", function(inst) 
                if inst.components.floater:ShouldShowEffect() then
                    inst.AnimState:SetBank(water_bank)
                else
                    inst.AnimState:SetBank(bank or "crow")
                end
            end)
        end

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

local function parrot_pirate_common(inst)
    inst:AddComponent("talker")
    inst.components.talker.fontsize = 28
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(.9, .4, .4, 1)
    inst:ListenForEvent("donetalking", doneTalkParrot)
    inst:ListenForEvent("ontalk", onTalkParrot)
end

local function parrot_pirate_master(inst)
    inst.components.inspectable.nameoverride = "PARROT"

    inst:AddComponent("named")
    inst.components.named.possiblenames = STRINGS.PARROTNAMES
    inst.components.named:PickNewName()
    inst.components.health.canmurder = false

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL

    inst:AddComponent("talkingbird")
end

local function seagull_master(inst)
  inst.components.eater:SetOmnivore()
end

local function cormorant_common(inst)
	inst.Transform:SetScale(0.85, 0.85, 0.85)
end

local function cormorant_master(inst)
    inst.components.eater:SetOmnivore()
	inst.components.periodicspawner.onspawn = EatCormorantLoot

	inst:DoTaskInTime(0, ScheduleCormorantLoot)
end

return makebird("parrot", "parrot", "robin", nil),
    makebird("parrot_pirate", "parrot", "robin", "parrot_pirate_bank", nil, parrot_pirate_common, parrot_pirate_master),
    makebird("toucan", "toucan", "crow"),
    makebird("cormorant", "cormorant", "crow", "seagull", "cormorant_water", cormorant_common, cormorant_master),
    makebird("seagull", "seagull","robin_winter", "seagull", "seagull_water", nil, seagull_master)
