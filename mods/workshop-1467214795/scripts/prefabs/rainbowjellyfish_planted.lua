local assets =
{
    Asset("ANIM", "anim/rainbowjellyfish.zip"),
}

local prefabs = {
    "rainbowjellyfish_dead",
}

local brain = require("brains/rainbowjellyfishbrain")

local INTENSITY = 0.65

local function swapColor(inst, light)
    if inst.ispink then
        inst.ispink = false
        inst.isgreen = true
        inst.components.lighttweener:StartTween(light, nil, nil, nil, {0/255, 180/255, 255/255}, 4, swapColor)
    elseif inst.isgreen then
        inst.isgreen = false
        inst.components.lighttweener:StartTween(light, nil, nil, nil, {240/255, 230/255, 100/255}, 4, swapColor)
    else
        inst.ispink = true
        inst.components.lighttweener:StartTween(light, nil, nil, nil, {251/255, 30/255, 30/255}, 4, swapColor)
    end
end

local function turnon(inst)
    inst._switchlightstate:push()
    if inst.Light and not inst.hidden then
        inst.Light:Enable(true)
        local secs = 1 + math.random()
        inst.components.lighttweener:StartTween(inst.Light, 0, nil, nil, nil, 0)
        inst.components.lighttweener:StartTween(inst.Light, INTENSITY, nil, nil, nil, secs, swapColor)
    end
end

local function turnoff(inst)
    if inst.Light then
        inst.Light:Enable(false)
    end
end

local function fadein(inst)
    inst.hidden = false
    inst.AnimState:PlayAnimation("idle")
    inst:Show()
    inst:RemoveTag("NOCLICK")
end

local function fadeout(inst)
    inst.hidden = true
    inst:AddTag("NOCLICK")
    inst:Hide()
end

local function onwake(inst)
    if not TheWorld.state.isday then
        fadein(inst)
        turnon(inst)
    else
        turnoff(inst)
    end
end

local function onsleep(inst)
    if TheWorld.state.isday then
        fadeout(inst)
        turnoff(inst)
    end
end

local function OnDeath(inst)
	if inst.Light then
		local secs = .25
		inst.components.lighttweener:StartTween(inst.Light, 0, nil, nil, nil, secs, turnoff)
	end
end

local function OnWorked(inst, worker)
    -- stupid DST change, explosives do a "work" check before an attack check, this is reversed in SW
    if not worker.components.explosive then
        if worker.components.inventory then
            local toGive = SpawnPrefab("rainbowjellyfish")
            worker.components.inventory:GiveItem(toGive, nil, Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition())))
            worker.SoundEmitter:PlaySound("ia/common/bugnet_inwater")

			if toGive.components.weighable ~= nil then
				toGive.components.weighable:SetPlayerAsOwner(worker)
			end

            inst.Light:Enable(false)
        end
        inst:Remove()
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddNetwork()

    inst.entity:AddTransform()
    inst.Transform:SetScale(0.8, 0.8, 0.8)
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()

    MakeCharacterPhysics(inst, 1, 0.5)

    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("rainbowjellyfish")
    inst.AnimState:SetBuild("rainbowjellyfish")
    inst.AnimState:PlayAnimation("idle", true)

    -- inst.AnimState:SetRayTestOnBB(true);
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(3)

    inst.entity:AddLight()
    inst.Light:SetColour(251 / 255, 30 / 255, 30 / 255)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)
    inst.Light:SetIntensity(0.65)
    inst.Light:SetRadius(1.5)
    inst.Light:SetFalloff(.45)

    inst:AddComponent("lighttweener")
    inst.components.lighttweener:StartTween(inst.Light, nil, nil, nil, {0/255, 180/255, 255/255}, 4, swapColor)

    inst:AddTag("animal")
    inst:AddTag("rainbowjellyfish")

    inst.ispink = true

    inst._switchlightstate = net_event(inst.GUID, "rainbowjellyfish_planted._switchlightstate")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("rainbowjellyfish_planted._switchlightstate", function(inst, data)
            if inst.Light and not inst:HasTag("NOCLICK") then
                local secs = 1 + math.random()
                inst.components.lighttweener:StartTween(inst.Light, 0, nil, nil, nil, 0)
                inst.components.lighttweener:StartTween(inst.Light, INTENSITY, nil, nil, nil, secs, swapColor)
            end
        end)

        return inst
    end

    inst.no_wet_prefix = true

    -- locomotor must be constructed before the stategraph
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.RAINBOWJELLYFISH_WALKSPEED
    inst.components.locomotor.pathcaps = {allowocean = true, ignoreLand = true}

    inst:SetBrain(brain)
    inst:SetStateGraph("SGrainbowjellyfish")

    inst:AddComponent("drydrownable")
    inst.components.drydrownable.break_period = 30 -- There are sooo many of these bastards at the volcano, give them a big break time...

    inst:AddComponent("combat")
    inst.components.combat:SetHurtSound("ia/creatures/jellyfish/hit")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.JELLYFISH_HEALTH)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"rainbowjellyfish_dead"})

    inst:AddComponent("inspectable")

    inst:AddComponent("knownlocations")

    inst:AddComponent("sleeper")
    inst.components.sleeper.onlysleepsfromitems = true

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.NET)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(OnWorked)

    -- light emitting
    inst.OnEntityWake = onwake
    inst.OnEntitySleep = onsleep

    inst:AddComponent("fader")

    inst:WatchWorldState("isday", function()
        if TheWorld.state.isday then
            if inst.Light then
                local secs = 1.5 + math.random()
                inst.components.lighttweener:StartTween(inst.Light, 0, nil, nil, nil, secs, turnoff)
            end
        end
    end)

    inst:WatchWorldState("isdusk", function()
        if TheWorld.state.isdusk then
            turnon(inst)
        end
    end)

    inst:ListenForEvent("death", OnDeath)

    MakeHauntablePanic(inst)
    MakeMediumFreezableCharacter(inst, "jelly")

    return inst
end

return Prefab("rainbowjellyfish_planted", fn, assets, prefabs)
