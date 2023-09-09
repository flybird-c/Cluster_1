local assets_blue = {
    Asset("ANIM", "anim/whale_carcass.zip"),
    Asset("ANIM", "anim/whale_carcass_build.zip"),
    -- Asset("MINIMAP_IMAGE", "whale_carcass"),
}
local assets_white = {
    Asset("ANIM", "anim/whale_carcass.zip"),
    Asset("ANIM", "anim/whale_moby_carcass_build.zip"),
    -- Asset("MINIMAP_IMAGE", "whale_carcass"),
}

local prefabs =
{
    "fishmeat",
    "boneshard",
    "coconade",
    "tophat",
    "sail",
    "gashat",
    "blowdart_sleep",
    "blowdart_poison",
    "blowdart_fire",
    "cutlass",
    "clothsail",
    "lobster_dead",
    "spear_launcher",
    "coconut",
    "boat_lantern",
    "bottlelantern",
    "telescope",
    "captainhat",
    "piratehat",
    "spear",
    "seatrap",
    "machete",
    "messagebottleempty",
    -- "fishmeat",
    -- "boneshard",
    "seaweed",
    "seashell",
    "jellyfish",
    "coral",
    "harpoon",
    "blubber",
    "bamboo",
    "vine",
}

local alwaysloot_blue = {"blubber", "blubber", "blubber", "blubber", "fishmeat", "fishmeat", "fishmeat", "fishmeat"}
local alwaysloot_white = {"blubber", "blubber", "blubber", "blubber", "fishmeat", "fishmeat", "fishmeat", "fishmeat", "harpoon", "boneshard"}

local loots = {
    {
        -- LOW % ITEMS, 2 of these are picked
        "coconade",
        -- "raft", -- flies away
        "tophat",
        "sail_palmleaf",
        "gashat",
        -- "boatcannon",
        "blowdart_sleep",
        "blowdart_poison",
        "blowdart_fire",
        "cutlass",
    },
    {
        -- MEDIUM % ITEMS, 3 of these
        "sail_cloth",
        "lobster_dead",
        "spear_launcher",
        "coconut",
        "boat_lantern",
        "bottlelantern",
        "telescope",
        "captainhat",
        "piratehat",
        "spear",
        "seatrap",
        "machete",
        "ia_messagebottleempty",
    },
    {
        -- HIGH % ITEMS, 4 of these
        "blubber",
        "fishmeat",
        "boneshard",
        "seaweed",
        -- "seashell",
        "jellyfish",
        "coral",
        "vine",
        "bamboo",
    },
}

local bluesounds = {
    stinks = "ia/creatures/blue_whale/bloated_stinks",
    bloated1 = "ia/creatures/blue_whale/bloated_plump_1",
    bloated2 = "ia/creatures/blue_whale/bloated_plump_2",
    explosion = "ia/creatures/blue_whale/explosion",
    hit = "ia/creatures/blue_whale/blubber_hit",
}

local whitesounds = {
    stinks = "ia/creatures/white_whale/bloated_stinks",
    bloated1 = "ia/creatures/white_whale/bloated_plump_1",
    bloated2 = "ia/creatures/white_whale/bloated_plump_2",
    explosion = "ia/creatures/white_whale/explosion",
    hit = "ia/creatures/white_whale/blubber_hit",
}

local function playsinglestinksound(inst) inst.SoundEmitter:PlaySound(inst.sounds.stinks) end
local function playstinksounds(inst, delay)
    delay = delay or 20 * FRAMES
    -- animation bloat3 takes 81 frames, or ~2.434 seconds
    inst.soundtask1 = inst:DoPeriodicTask(2.434, playsinglestinksound, delay)
    inst.soundtask2 = inst:DoPeriodicTask(2.434, playsinglestinksound, delay + 18*FRAMES)
    inst.soundtask3 = inst:DoPeriodicTask(2.434, playsinglestinksound, delay + 48*FRAMES)
end
local function killstinksounds(inst)
    if inst.soundtask1 then
        inst.soundtask1:Cancel()
        inst.soundtask2:Cancel()
        inst.soundtask3:Cancel()
        inst.soundtask1 = nil
        inst.soundtask2 = nil
        inst.soundtask3 = nil
    end
end

local function workcallback(inst, worker, workleft)
    killstinksounds(inst)
    inst.SoundEmitter:PlaySound(inst.sounds.hit)
    inst.AnimState:PlayAnimation("idle_trans2_3")
    inst.AnimState:PushAnimation("idle_bloat3",true)
    playstinksounds(inst)
end

local function workfinishedcallback(inst, worker)
    -- inst.components.growable:SetStage(#growth_stages)
    inst.components.growable:DoGrowth()
end

local function burst(inst)
    if inst.persists then
        inst.persists = false
        inst.AnimState:PlayAnimation("explode", false)
        inst.SoundEmitter:PlaySound(inst.sounds.explosion)

        inst:DoTaskInTime(57 * FRAMES, function (inst)
            -- cannot use "explosive" as it force-removes in DST
            for i, v in ipairs(AllPlayers) do
                local distSq = v:GetDistanceSqToInst(inst)
                local k = math.max(0, math.min(1, distSq / 1600))
                local intensity = k * (k - 2) + 1 --easing.outQuad(k, 1, -1, 1)
                if intensity > 0 then
                    v:ScreenFlash(intensity)
                    v:ShakeCamera(CAMERASHAKE.FULL, .7, .02, intensity / 2)
                end
            end

            local x, y, z = inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, y, z, 3, nil, {"INLIMBO"})

            for i, v in ipairs(ents) do
                if v ~= inst and v:IsValid() and not v:IsInLimbo() then
                    if v.components.workable ~= nil and v.components.workable:CanBeWorked() then
                        v.components.workable:WorkedBy(inst, 10)
                    end

                    --Recheck valid after work
                    if v:IsValid() and not v:IsInLimbo() then
                        if v.components.combat ~= nil and not (v.components.health ~= nil and v.components.health:IsDead()) then
                            local dmg = inst.explosivedamage
                            if v.components.explosiveresist ~= nil then
                                dmg = dmg * (1 - v.components.explosiveresist:GetResistance())
                                v.components.explosiveresist:OnExplosiveDamage(dmg, inst)
                            end
                            v.components.combat:GetAttacked(inst, dmg, nil)
                        end

                        v:PushEvent("explosion", { explosive = inst })
                    end
                end
            end

            TheWorld:PushEvent("explosion", {damage = inst.explosivedamage})
        end )

        inst:DoTaskInTime(58 * FRAMES, function(inst)

            local i = 1
            for ii = 1, i + 1 do
                inst.components.lootdropper.speed = 3 + (math.random() * 8)
                local loot = GetRandomItem(loots[i])
                local newprefab = inst.components.lootdropper:SpawnLootPrefab(loot)
                if newprefab then
                    local vx, vy, vz = newprefab.Physics:GetVelocity()
                    newprefab.Physics:SetVel(vx, 20+(math.random() * 5), vz)
                end
            end
        end)
        inst:DoTaskInTime(60 * FRAMES, function(inst)
            local i = 2
            for ii = 1, i + 1 do
                inst.components.lootdropper.speed = 4 + (math.random() * 8)
                local loot = GetRandomItem(loots[i])
                local newprefab = inst.components.lootdropper:SpawnLootPrefab(loot)
                if newprefab then
                    local vx, vy, vz = newprefab.Physics:GetVelocity()
                    newprefab.Physics:SetVel(vx, 25 + (math.random() * 5), vz)
                end
            end
        end)
        inst:DoTaskInTime(63 * FRAMES, function(inst)
            local i = 3
            for ii = 1, i + 1 do
                inst.components.lootdropper.speed = 6 + (math.random() * 8)
                local loot = GetRandomItem(loots[i])
                local newprefab = inst.components.lootdropper:SpawnLootPrefab(loot)
                if newprefab then
                    local vx, vy, vz = newprefab.Physics:GetVelocity()
                    newprefab.Physics:SetVel(vx, 30+(math.random() * 5), vz)
                end
            end

            inst.components.lootdropper:DropLoot()
        end)

        inst:ListenForEvent("animqueueover", function(inst)
            inst:Remove()
        end)
    end
end

local growth_stages = {
    {
        name = "bloat1",
        time = function(inst)
            return GetRandomWithVariance(TUNING.WHALE_ROT_TIME[1].base, TUNING.WHALE_ROT_TIME[1].random)
        end,
        fn = function (inst)
            inst.AnimState:PlayAnimation("idle_pre")
            inst.AnimState:PushAnimation("idle_bloat1", true)
            inst.components.workable:SetWorkable(false)
        end,
    },
    {
        name = "bloat2",
        time = function(inst)
            return GetRandomWithVariance(TUNING.WHALE_ROT_TIME[1].base, TUNING.WHALE_ROT_TIME[1].random)
        end,
        fn = function (inst)
            inst.AnimState:PlayAnimation("idle_trans1_2")
            inst.SoundEmitter:PlaySound(inst.sounds.bloated1)
            inst.AnimState:PushAnimation("idle_bloat2", true)
            inst.components.workable:SetWorkable(false)
        end,
    },
    {
        name = "bloat3",
        time = function(inst)
            return GetRandomWithVariance(TUNING.WHALE_ROT_TIME[2].base, TUNING.WHALE_ROT_TIME[2].random)
        end,
        fn = function (inst)
            inst.AnimState:PlayAnimation("idle_trans2_3")
            inst.SoundEmitter:PlaySound(inst.sounds.bloated2)
            inst.AnimState:PushAnimation("idle_bloat3", true)
            playstinksounds(inst)
            inst.components.workable:SetWorkable(true)
        end,
    },
    {
        name = "explode",
        time = function(inst)
            return GetRandomWithVariance(TUNING.WHALE_ROT_TIME[2].base, TUNING.WHALE_ROT_TIME[2].random)
        end,
        fn = function (inst)
            inst.components.workable:SetWorkable(false)
            killstinksounds(inst)

            -- Replicate ds behaviour so people dont get there reward turned to rot -Half
            inst.readytoburst = true
            if not inst:IsAsleep() then
                burst(inst)
            end
        end,
    },
}

local function OnHaunt(inst)
    if inst.components.growable --and inst.components.growable.stage ~= 4
    and math.random() <= TUNING.HAUNT_CHANCE_RARE then
        inst.components.growalbe:DoGrowth()
        inst.components.hauntable.hauntvalue = TUNING.HAUNT_LARGE
        return true
    end

    return false
end

local function OnEntityWake(inst)
    if inst.readytoburst then
        inst:DoTaskInTime(0, burst)
    end
end


local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()

    inst.MiniMapEntity:SetIcon("whale_carcass.tex")

    MakeWaterObstaclePhysics(inst, 1.3, nil, 1)

    inst.AnimState:SetBank("whalecarcass")
    inst.AnimState:SetBuild("whale_carcass_build")

    -- inst:AddTag("carcass")

    return inst
end

local function fn_master(inst)
    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")

    inst:AddComponent("growable")
    -- inst.components.growable.springgrowth = true
    inst.components.growable.growoffscreen = true
    inst.components.growable.stages = growth_stages
    inst.components.growable:StartGrowing()

    -- inst:AddComponent("explosive")

    -- inst.components.explosive.lightonexplode = false
    -- inst.components.explosive.noremove = true

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HACK)

    inst.components.workable:SetOnWorkCallback(workcallback)
    inst.components.workable:SetOnFinishCallback(workfinishedcallback)
    inst.components.workable:SetWorkable(false)

    inst:AddComponent("hauntable")
    inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_MEDIUM
    inst.components.hauntable:SetOnHauntFn(OnHaunt)

    inst:ListenForEvent("entitywake", OnEntityWake)

    -- Remind me why Capy used states when the spiderden does the same without -M
    -- inst:SetStateGraph("SGwhalecarcass")
end

local function bluefn()
    local inst = fn()

    inst.AnimState:SetBuild("whale_carcass_build")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    fn_master(inst)

    inst.components.lootdropper:SetLoot(alwaysloot_blue)

    inst.sounds = bluesounds

    inst.components.growable:SetStage(1)
    inst.components.growable:StartGrowing()

    inst.components.workable:SetWorkLeft(TUNING.WHALE_BLUE_EXPLOSION_HACKS)
    inst.components.workable:SetWorkable(false)
    inst.explosivedamage = TUNING.WHALE_BLUE_EXPLOSION_DAMAGE

    return inst
end

local function whitefn()
    local inst = fn()

    inst.Transform:SetScale(1.25, 1.25, 1.25)

    inst.AnimState:SetBuild("whale_moby_carcass_build")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    fn_master(inst)

    inst.components.lootdropper:SetLoot(alwaysloot_white)

    inst.sounds = whitesounds

    inst.components.growable:SetStage(1)
    inst.components.growable:StartGrowing()

    inst.components.workable:SetWorkLeft(TUNING.WHALE_WHITE_EXPLOSION_HACKS)
    inst.components.workable:SetWorkable(false)
    inst.explosivedamage = TUNING.WHALE_WHITE_EXPLOSION_DAMAGE

    return inst
end

return Prefab("common/objects/whale_carcass_blue", bluefn, assets_blue, prefabs),
    Prefab("common/objects/whale_carcass_white", whitefn, assets_white, prefabs)
