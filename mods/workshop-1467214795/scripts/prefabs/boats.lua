local MakeVisualBoatEquip = require("prefabs/visualboatequip")

local rowboatassets = {
    Asset("ANIM", "anim/rowboat_basic.zip"),
    Asset("ANIM", "anim/rowboat_build.zip"),
    Asset("ANIM", "anim/rowboat_idles.zip"),
    Asset("ANIM", "anim/rowboat_paddle.zip"),
    Asset("ANIM", "anim/rowboat_trawl.zip"),
    Asset("ANIM", "anim/swap_sail.zip"),
    Asset("ANIM", "anim/swap_lantern_boat.zip"),
    Asset("ANIM", "anim/boat_hud_row.zip"),
    Asset("ANIM", "anim/boat_inspect_row.zip"),
    Asset("ANIM", "anim/flotsam_rowboat_build.zip"),
}

local raftassets = {
    Asset("ANIM", "anim/raft_basic.zip"),
    Asset("ANIM", "anim/raft_build.zip"),
    Asset("ANIM", "anim/raft_idles.zip"),
    Asset("ANIM", "anim/raft_paddle.zip"),
    Asset("ANIM", "anim/raft_trawl.zip"),
    Asset("ANIM", "anim/boat_hud_raft.zip"),
    Asset("ANIM", "anim/boat_inspect_raft.zip"),
    Asset("ANIM", "anim/flotsam_bamboo_build.zip"),
}

local surfboardassets = {
    Asset("ANIM", "anim/raft_basic.zip"),
    Asset("ANIM", "anim/raft_surfboard_build.zip"),
    Asset("ANIM", "anim/raft_idles.zip"),
    Asset("ANIM", "anim/raft_paddle.zip"),
    Asset("ANIM", "anim/raft_trawl.zip"),
    Asset("ANIM", "anim/boat_hud_raft.zip"),
    Asset("ANIM", "anim/boat_inspect_raft.zip"),
    Asset("ANIM", "anim/flotsam_surfboard_build.zip"),
    Asset("ANIM", "anim/surfboard.zip"),
}

local cargoassets = {
    Asset("ANIM", "anim/rowboat_basic.zip"),
    Asset("ANIM", "anim/rowboat_cargo_build.zip"),
    Asset("ANIM", "anim/rowboat_idles.zip"),
    Asset("ANIM", "anim/rowboat_paddle.zip"),
    Asset("ANIM", "anim/rowboat_trawl.zip"),
    Asset("ANIM", "anim/swap_sail.zip"),
    Asset("ANIM", "anim/swap_lantern_boat.zip"),
    Asset("ANIM", "anim/boat_hud_cargo.zip"),
    Asset("ANIM", "anim/boat_inspect_cargo.zip"),
    Asset("ANIM", "anim/flotsam_cargo_build.zip"),
}

local armouredboatassets = {
    Asset("ANIM", "anim/rowboat_basic.zip"),
    Asset("ANIM", "anim/rowboat_armored_build.zip"),
    Asset("ANIM", "anim/rowboat_idles.zip"),
    Asset("ANIM", "anim/rowboat_paddle.zip"),
    Asset("ANIM", "anim/rowboat_trawl.zip"),
    Asset("ANIM", "anim/swap_sail.zip"),
    Asset("ANIM", "anim/swap_lantern_boat.zip"),
    Asset("ANIM", "anim/boat_hud_row.zip"),
    Asset("ANIM", "anim/boat_inspect_row.zip"),
    Asset("ANIM", "anim/flotsam_armoured_build.zip"),
}

local encrustedboatassets = {
    Asset("ANIM", "anim/rowboat_basic.zip"),
    Asset("ANIM", "anim/rowboat_encrusted_build.zip"),
    Asset("ANIM", "anim/rowboat_idles.zip"),
    Asset("ANIM", "anim/rowboat_paddle.zip"),
    Asset("ANIM", "anim/rowboat_trawl.zip"),
    Asset("ANIM", "anim/swap_sail.zip"),
    Asset("ANIM", "anim/swap_lantern_boat.zip"),
    Asset("ANIM", "anim/boat_hud_encrusted.zip"),
    Asset("ANIM", "anim/boat_inspect_encrusted.zip"),
  -- TODO: add encrusted flotsam
    Asset("ANIM", "anim/flotsam_armoured_build.zip"),
}

local lograftassets = {
    Asset("ANIM", "anim/raft_basic.zip"),
    Asset("ANIM", "anim/raft_log_build.zip"),
    Asset("ANIM", "anim/raft_idles.zip"),
    Asset("ANIM", "anim/raft_paddle.zip"),
    Asset("ANIM", "anim/raft_trawl.zip"),
    Asset("ANIM", "anim/boat_hud_raft.zip"),
    Asset("ANIM", "anim/boat_inspect_raft.zip"),
    Asset("ANIM", "anim/flotsam_lograft_build.zip"),
}

local woodlegsboatassets = {
    Asset("ANIM", "anim/rowboat_basic.zip"),
    Asset("ANIM", "anim/pirate_boat_build.zip"),
    Asset("ANIM", "anim/rowboat_idles.zip"),
    Asset("ANIM", "anim/rowboat_paddle.zip"),
    Asset("ANIM", "anim/rowboat_trawl.zip"),
    Asset("ANIM", "anim/boat_hud_raft.zip"),
    Asset("ANIM", "anim/boat_inspect_raft.zip"),
    Asset("ANIM", "anim/flotsam_rowboat_build.zip"),
    Asset("ANIM", "anim/pirate_boat_placer.zip"),
}

local critterboatassets = {
    Asset("ANIM", "anim/ocean_trawler_orange.zip"),
    Asset("ANIM", "anim/splash_water_rot.zip"),
    Asset("ANIM", "anim/swimming_ripple.zip"),
    Asset("MINIMAP_IMAGE", "ocean_trawler_down")
}

local prefabs = {
    "rowboat_wake",
    "boat_hit_fx",
    "boat_hit_fx_raft_log",
    "boat_hit_fx_raft_bamboo",
    "boat_hit_fx_rowboat",
    "boat_hit_fx_cargoboat",
    "boat_hit_fx_armoured",
    "flotsam_armoured",
    "flotsam_bamboo",
    "flotsam_cargo",
    "flotsam_lograft",
    "flotsam_rowboat",
    "flotsam_surfboard",
}

local function Sink(inst)
    local sailor = inst.components.sailable:GetSailor()
    if sailor then
        sailor.components.sailor:Disembark(nil, nil, true)

        sailor:PushEvent("onsink", {ia_boat = inst})

        sailor.SoundEmitter:PlaySound(inst.sinksound)
    end
    if inst.components.container then
        inst.components.container:DropEverything()
    end

    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("run_loop", true)
end

local function onworked(inst, worker)
    inst.components.lootdropper:DropLoot()
    if inst.components.container then
        inst.components.container:DropEverything()
    end
    SpawnAt("collapse_small", inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:Remove()
end

local function onrepaired(inst, doer, repair_item)
    inst.SoundEmitter:PlaySound("ia/common/boatrepairkit")
end

local function ondisembarked(inst)
    inst.components.workable:SetWorkable(false)
end

local function onembarked(inst)
    inst.components.workable:SetWorkable(true)
end

local function onopen(inst)
    if inst.components.sailable.sailor == nil then
        inst.SoundEmitter:PlaySound("ia/common/boat/inventory_open")
    end
end

local function onclose(inst)
    if inst.components.sailable.sailor == nil then
        inst.SoundEmitter:PlaySound("ia/common/boat/inventory_close")
    end
end

local _Write = nil
local function Write(self, doer, text, ...)
    if not text then
        text = self.text
        if doer and doer.tool_prefab then
            doer.components.inventory:GiveItem(SpawnPrefab(doer.tool_prefab), nil, self.inst:GetPosition())
        end
    else
        self.inst.SoundEmitter:PlaySound("dontstarve/common/together/draw")
    end

    self.inst.boatname:set(text and text ~= "" and text or "")
    return _Write(self, doer, text, ...)
end

local _Writable_OnLoad = nil
local function Writable_OnLoad(self, ...)
    _Writable_OnLoad(self, ...)
    local text = self.text
    self.inst.boatname:set(text and text ~= "" and text or "")
end

local function common()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddPhysics()
    inst.entity:AddMiniMapEntity()

    inst:AddTag("ia_boat")
    inst:AddTag("sailable")

    inst.Transform:SetFourFaced()
    inst.MiniMapEntity:SetPriority(5)

    inst.AnimState:SetFinalOffset(FINALOFFSET_MIN) -- TODO causes minor visual issues find something better

    inst.Physics:SetCylinder(0.25, 2) -- MakeWeakWaterObstaclePhysics(inst, nil, 0.25, 2)

    inst.no_wet_prefix = true

    inst.boatvisuals = {}

    inst.boatname = net_string(inst.GUID, "boatname")

    inst.displaynamefn = function(_inst)
        local name = _inst.boatname:value()
        return name ~= "" and name or STRINGS.NAMES[string.upper(_inst.prefab)]
    end

    inst:AddComponent("highlightchild")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("writeable")
    inst:RemoveEventCallback("onbuilt", inst.event_listening.onbuilt[inst][1])
    inst.components.writeable:SetDefaultWriteable(false)
    inst.components.writeable:SetAutomaticDescriptionEnabled(false)

    if not _Write then
        _Write = inst.components.writeable.Write
    end
    inst.components.writeable.Write = Write

    if not _Writable_OnLoad then
        _Writable_OnLoad = inst.components.writeable.OnLoad
    end
    inst.components.writeable.OnLoad = Writable_OnLoad

    inst:AddComponent("sailable")
    inst.components.sailable.sanitydrain = TUNING.RAFT_SANITY_DRAIN
    inst.components.sailable.movementbonus = TUNING.RAFT_SPEED
    inst.components.sailable.flotsambuild = "flotsam_bamboo_build"
    inst.components.sailable.maprevealbonus = TUNING.MAPREVEAL_RAFT_BONUS

    inst.landsound = "ia/common/boatjump_land_bamboo"
    inst.sinksound = "ia/common/boat/sinking/bamboo"

    inst.waveboost = TUNING.WAVEBOOST

    inst:AddComponent("rowboatwakespawner")

    inst:AddComponent("boathealth")
    inst.components.boathealth:SetDepletedFn(Sink)
    inst.components.boathealth:SetHealth(TUNING.RAFT_HEALTH, TUNING.RAFT_PERISHTIME)
    inst.components.boathealth.leakinghealth = TUNING.RAFT_LEAKING_HEALTH
    inst.components.boathealth.damagesound = "ia/common/boat/damage/bamboo"
    inst.components.boathealth.hitfx = "boat_hit_fx_raft_bamboo"

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onworked)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("lootdropper")

    inst:AddComponent("repairable")
    inst.components.repairable.repairmaterial = "boat"
    inst.components.repairable.onrepaired = onrepaired

    inst:ListenForEvent("embarked", onembarked)
    inst:ListenForEvent("disembarked", ondisembarked)

    inst.onworked = onworked

    inst:AddComponent("flotsamspawner")

    inst.components.flotsamspawner.flotsamprefab = "flotsam_bamboo"

    inst:AddSpoofedComponent("boatcontainer", "container")

    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose

    inst:AddComponent("boatvisualmanager")
    
    -- inst:AddComponent("bloomer")
    inst:AddComponent("colouradder")
    inst:AddComponent("eroder")

    return inst
end

local function surfboard_pickupfn(inst, guy)
    local item = SpawnPrefab(inst.boat_item)
    if item then
        local value = inst.boatname:value()
        local name = value and value ~= "" and value or ""
        item.components.writeable:SetText(name)
        item.boatname:set(name)

        guy.components.inventory:GiveItem(item)
        item.components.pocket:GiveItem(inst.prefab, inst)
    end

    return true
end

local function surfboard_common()
    local inst = common()

    inst:AddTag("surfboard")

    if not TheNet:IsDedicated() then
        inst.sailing_music = {"ia/music/music_surfing_day", "ia/music/music_surfing_night"}
    end

    if not TheWorld.ismastersim then
        function inst.OnEntityReplicated(_inst)
            _inst.replica.sailable.creaksound = "ia/common/boat/creaks/creaks"
            _inst.replica.sailable.sailsound = "ia/common/sail_LP/surfboard"
            _inst.replica.sailable.sailloopanim = "surf_loop"
            _inst.replica.sailable.sailstartanim = "surf_pre"
            _inst.replica.sailable.sailstopanim = "surf_pst"
            _inst.replica.sailable.alwayssail = true
        end
        return inst
    end

    inst.board = nil

    inst.components.boathealth.hitfx = nil

    inst.sinksound = "ia/common/boat/sinking/log_cargo"
    inst.replica.sailable.sailsound = "ia/common/sail_LP/surfboard"
    inst.replica.sailable.sailloopanim = "surf_loop"
    inst.replica.sailable.sailstartanim = "surf_pre"
    inst.replica.sailable.sailstopanim = "surf_pst"
    inst.components.sailable.alwayssail = true

    inst:AddComponent("pickupable")
    inst.components.pickupable:SetOnPickupFn(surfboard_pickupfn)
    inst:SetInherentSceneAltAction(ACTIONS.RETRIEVE)

    inst:ListenForEvent("embarked", function(_inst)
        _inst.components.pickupable.canbepickedup = false
        _inst:SetInherentSceneAltAction(nil)
    end)

    inst:ListenForEvent("disembarked", function(_inst)
        _inst.components.pickupable.canbepickedup = true
        _inst:SetInherentSceneAltAction(ACTIONS.RETRIEVE)
    end)

    return inst
end

local function surfboard_item_ondropped(inst)
    --If this is a valid place to be deployed, auto deploy yourself.
    local pt = inst:GetPosition()
    if inst.components.deployable and TheWorld.Map:CanDeployAquaticAtPointInWater(pt, {distance=4, platform_buffer_min=2, platform_buffer_max=2, boat = true}) then
        inst.components.deployable:ForceDeploy(pt, inst)
    end
end

local function surfboard_item_ondeploy(inst, pt, deployer)
    local boat = inst.components.pocket:RemoveItem(inst.boat) or SpawnPrefab(inst.boat)
	if boat then
        local value = inst.boatname:value()
        local name = value and value ~= "" and value or ""
        boat.components.writeable:SetText(name)
        boat.boatname:set(name)

        local x, y, z = pt:Get()
		boat.components.flotsamspawner.inpocket = false
		boat.Physics:SetCollides(false)
		boat.Physics:Teleport(x, y, z)
		boat.Physics:SetCollides(true)
		inst:Remove()
	end
end

local function surfboard_candeploy(inst, pt, mouseover, deployer)
    return TheWorld.Map:IsDeployPointClear(pt, nil, 3.2)
       and TheWorld.Map:CanDeployAquaticAtPointInWater(pt, {distance=4, platform_buffer_min=2, platform_buffer_max=2, boat = true}, deployer)
end

local function item_common()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()

    inst.MiniMapEntity:SetPriority(5)

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)

    inst:AddTag("ia_boat")

    inst.boatname = net_string(inst.GUID, "boatname")

    inst._custom_candeploy_fn = surfboard_candeploy

    inst.displaynamefn = function(_inst)
        local name = _inst.boatname:value()
        return name ~= "" and name or STRINGS.NAMES[string.upper(_inst.prefab)]
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.boat = nil

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.notboattossable = true
    inst.components.inventoryitem.nobounce = true

    inst:ListenForEvent("floater_startfloating", surfboard_item_ondropped)
    inst:ListenForEvent("update_water", surfboard_item_ondropped)

    inst:AddComponent("pocket")

    inst:AddComponent("deployable")
    inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM)
    inst.components.deployable.ondeploy = surfboard_item_ondeploy
    inst.components.deployable.deploydistance = 3

    inst:AddComponent("writeable")
    inst.components.writeable:SetDefaultWriteable(false)
    inst.components.writeable:SetAutomaticDescriptionEnabled(false)
    if not _Write then
        _Write = inst.components.writeable.Write
    end
    inst.components.writeable.Write = Write

    if not _Writable_OnLoad then
        _Writable_OnLoad = inst.components.writeable.OnLoad
    end
    inst.components.writeable.OnLoad = Writable_OnLoad

    return inst
end

local function DisableMouseThrough()
    return true
end

local function critterboat_ripple(inst)
    local inst = CreateEntity()

    --V2C: speecial =) must be the 1st tag added b4 AnimState component
    inst:AddTag("can_offset_sort_pos")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.persists = false

    inst:AddTag("NOBLOCK")
    inst:AddTag("FX")
    inst:AddTag("ignorewalkableplatforms")
    inst.AnimState:OverrideSymbol("water_fx_ripple", "swimming_ripple", "water_fx_ripple")
    inst.AnimState:SetBank("ocean_trawler")
    inst.AnimState:SetBuild("ocean_trawler_orange")
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle_full", true)
    inst.AnimState:SetSortWorldOffset(0, -0.6, 0) -- Below the floaty

    inst.AnimState:HideSymbol("water_line")
    inst.AnimState:HideSymbol("trawler_bits")
    inst.AnimState:HideSymbol("net_untied")
    inst.AnimState:HideSymbol("net_medium")
    inst.AnimState:HideSymbol("net_full")
    inst.AnimState:HideSymbol("net_empty")
    inst.AnimState:HideSymbol("net")
    inst.AnimState:HideSymbol("hoist_rope_strip")
    inst.AnimState:HideSymbol("hoist_disc")

    inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)

    inst.CanMouseThrough = DisableMouseThrough

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    return inst
end

local function critterboat_visual_common(inst)
    inst.AnimState:SetBank("ocean_trawler")
    inst.AnimState:SetBuild("ocean_trawler_orange")
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle_full", true)
    inst.AnimState:SetSortWorldOffset(0, -0.15, 0) -- Above the critter

    inst.AnimState:HideSymbol("water_shadow")
    inst.AnimState:HideSymbol("net_untied")
    inst.AnimState:HideSymbol("net_medium")
    inst.AnimState:HideSymbol("net_full")
    inst.AnimState:HideSymbol("net_empty")
    inst.AnimState:HideSymbol("net")
    inst.AnimState:HideSymbol("hoist_disc")
    inst.AnimState:HideSymbol("hoist_rope_strip")

    inst.AnimState:Hide("pole")
    inst.AnimState:Hide("trawler_bits")
    inst.AnimState:Hide("knot")
    inst.AnimState:Hide("spool")
    inst.AnimState:Hide("back_water_ol")

    inst.AnimState:Hide("base_back")

    inst.components.boatvisualanims.presailanim = "overload"
    inst.components.boatvisualanims.sailanim = "idle"
    inst.components.boatvisualanims.postsailanim = "idle_medium"
    inst.components.boatvisualanims.idleanim = "idle_full"

    inst.CanMouseThrough = DisableMouseThrough

	return inst
end

local function critterboat_common()
    local inst = CreateEntity()

    --V2C: speecial =) must be the 1st tag added b4 AnimState component
    inst:AddTag("can_offset_sort_pos")
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddPhysics()

    inst:AddTag("critter_boat")

    inst.Transform:SetFourFaced()

    inst.Physics:SetCylinder(0.25,2)

    inst.no_wet_prefix = true

    inst.boatvisuals = {}

    inst.CanMouseThrough = DisableMouseThrough

    inst:AddComponent("highlightchild")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.Sink = Sink

    inst:AddComponent("sailable")

    inst.landsound = "ia/common/boatjump_land_bamboo"
    inst.sinksound = "ia/common/boat/sinking/bamboo"

    inst.waveboost = TUNING.WAVEBOOST

    inst:AddComponent("rowboatwakespawner")

    inst:AddComponent("boatvisualmanager")

    -- inst:AddComponent("bloomer")
    inst:AddComponent("colouradder")
    inst:AddComponent("eroder")

    inst.persists = false

    return inst
end

local function raftfn()
    local inst = common()

    inst.AnimState:SetBank("raft")
    inst.AnimState:SetBuild("raft_build")
    inst.AnimState:PlayAnimation("run_loop", true)
    inst.MiniMapEntity:SetIcon("boat_raft.tex")

    if not TheWorld.ismastersim then
        function inst.OnEntityReplicated(inst)
            inst.replica.sailable.creaksound = "ia/common/boat/creaks/bamboo"
        end
        return inst
    end

    inst.components.container:WidgetSetup("boat_raft")

    inst.components.boathealth:SetHealth(TUNING.RAFT_HEALTH, TUNING.RAFT_PERISHTIME)
    inst.components.boathealth.leakinghealth = TUNING.RAFT_LEAKING_HEALTH
    inst.components.boathealth.damagesound = "ia/common/boat/damage/bamboo"
    inst.components.boathealth.hitfx = "boat_hit_fx_raft_bamboo"

    inst.landsound = "ia/common/boatjump_land_bamboo"
    inst.sinksound = "ia/common/boat/sinking/bamboo"

    inst.components.sailable.sanitydrain = TUNING.RAFT_SANITY_DRAIN
    inst.components.sailable.movementbonus = TUNING.RAFT_SPEED
    inst.components.sailable.flotsambuild = "flotsam_bamboo_build"
    inst.components.sailable.maprevealbonus = TUNING.MAPREVEAL_RAFT_BONUS
    inst.components.sailable.hitmoisturerate = TUNING.RAFT_HITMOISTURERATE

    inst.replica.sailable.creaksound = "ia/common/boat/creaks/bamboo"

    inst.components.flotsamspawner.flotsamprefab = "flotsam_bamboo"

    return inst
end

local function lograftfn()
    local inst = common()

    inst.AnimState:SetBank("raft")
    inst.AnimState:SetBuild("raft_log_build")
    inst.AnimState:PlayAnimation("run_loop", true)
    inst.MiniMapEntity:SetIcon("boat_lograft.tex")

    if not TheWorld.ismastersim then
        function inst.OnEntityReplicated(inst)
            inst.replica.sailable.creaksound = "ia/common/boat/creaks/log"
        end
        return inst
    end

    inst.components.container:WidgetSetup("boat_lograft")

    inst.components.boathealth:SetHealth(TUNING.LOGRAFT_HEALTH, TUNING.LOGRAFT_PERISHTIME)
    inst.components.boathealth.leakinghealth = TUNING.LOGRAFT_LEAKING_HEALTH
    inst.components.boathealth.damagesound = "ia/common/boat/damage/log"
    inst.components.boathealth.hitfx = "boat_hit_fx_raft_log"

    inst.landsound = "ia/common/boatjump_land_log"
    inst.sinksound = "ia/common/boat/sinking/log_cargo"

    inst.components.sailable.sanitydrain = TUNING.LOGRAFT_SANITY_DRAIN
    inst.components.sailable.movementbonus = TUNING.LOGRAFT_SPEED
    inst.components.sailable.flotsambuild = "flotsam_lograft_build"
    inst.components.sailable.maprevealbonus = TUNING.MAPREVEAL_LOGRAFT_BONUS
    inst.components.sailable.hitmoisturerate = TUNING.RAFT_HITMOISTURERATE

    inst.components.boathealth.damagesound = "ia/common/boat/damage/log"

    inst.components.flotsamspawner.flotsamprefab = "flotsam_lograft"

    return inst
end

local function rowboatfn()
    local inst = common()

    inst.AnimState:SetBank("rowboat")
    inst.AnimState:SetBuild("rowboat_build")
    inst.AnimState:PlayAnimation("run_loop", true)
    inst.MiniMapEntity:SetIcon("boat_row.tex")

    if not TheWorld.ismastersim then
        function inst.OnEntityReplicated(inst)

        end
        return inst
    end

    inst.components.container:WidgetSetup("boat_row")

    inst.components.boathealth:SetHealth(TUNING.ROWBOAT_HEALTH, TUNING.ROWBOAT_PERISHTIME)
    inst.components.boathealth.leakinghealth = TUNING.ROWBOAT_LEAKING_HEALTH
    inst.components.boathealth.damagesound = "ia/common/boat/damage/row"
    inst.components.boathealth.hitfx = "boat_hit_fx_rowboat"

    inst.landsound = "ia/common/boatjump_land_wood"
    inst.sinksound = "ia/common/boat/sinking/row"

    inst.components.sailable.sanitydrain = TUNING.ROWBOAT_SANITY_DRAIN
    inst.components.sailable.movementbonus = TUNING.ROWBOAT_SPEED
    inst.components.sailable.flotsambuild = "flotsam_rowboat_build"
    inst.components.sailable.maprevealbonus = TUNING.MAPREVEAL_ROWBOAT_BONUS

    inst.components.flotsamspawner.flotsamprefab = "flotsam_rowboat"

    return inst
end

local function armouredboatfn()
    local inst = common()

    inst.AnimState:SetBank("rowboat")
    inst.AnimState:SetBuild("rowboat_armored_build")
    inst.AnimState:PlayAnimation("run_loop", true)
    inst.MiniMapEntity:SetIcon("boat_armoured.tex")

    if not TheWorld.ismastersim then
        function inst.OnEntityReplicated(inst)
            inst.replica.sailable.creaksound = "ia/common/boat/creaks/armoured"
        end
        return inst
    end

    inst.components.container:WidgetSetup("boat_armoured")

    inst.components.boathealth:SetHealth(TUNING.ARMOUREDBOAT_HEALTH, TUNING.ARMOUREDBOAT_PERISHTIME)
    inst.components.boathealth.leakinghealth = TUNING.ARMOUREDBOAT_LEAKING_HEALTH
    inst.components.boathealth.damagesound = "ia/common/boat/damage/armoured"
    inst.components.boathealth.hitfx = "boat_hit_fx_armoured"

    inst.landsound = "ia/common/boatjump_land_shell"
    inst.sinksound = "ia/common/boat/sinking/row"

    inst.components.sailable.sanitydrain = TUNING.ARMOUREDBOAT_SANITY_DRAIN
    inst.components.sailable.movementbonus = TUNING.ARMOUREDBOAT_SPEED
    inst.components.sailable.flotsambuild = "flotsam_armoured_build"
    inst.components.sailable.maprevealbonus = TUNING.MAPREVEAL_ARMOUREDBOAT_BONUS
    inst.components.sailable:SetHitImmunity(TUNING.ARMOUREDBOAT_HIT_IMMUNITY)

    inst.replica.sailable.creaksound = "ia/common/boat/creaks/armoured"

    inst.components.flotsamspawner.flotsamprefab = "flotsam_armoured"

    return inst
end

local function encrustedboatfn()
    local inst = common()

    inst.AnimState:SetBank("rowboat")
    inst.AnimState:SetBuild("rowboat_encrusted_build")
    inst.AnimState:PlayAnimation("run_loop", true)
    inst.MiniMapEntity:SetIcon("boat_encrusted.tex")

    if not TheWorld.ismastersim then
        function inst.OnEntityReplicated(inst)
            inst.replica.sailable.creaksound = "ia/common/boat/creaks/encrusted"
        end
        return inst
    end

    inst.waveboost = TUNING.ENCRUSTEDBOAT_WAVEBOOST

    inst.components.container:WidgetSetup("boat_encrusted")

    inst.components.boathealth:SetHealth(TUNING.ENCRUSTEDBOAT_HEALTH, TUNING.ENCRUSTEDBOAT_PERISHTIME)
    inst.components.boathealth.leakinghealth = TUNING.ENCRUSTEDBOAT_LEAKING_HEALTH
    inst.components.boathealth.damagesound = "ia/common/boat/damage/encrusted"
    inst.components.boathealth.hitfx = "boat_hit_fx_armoured"

    inst.landsound = "ia/common/boatjump_land_shell"
    inst.sinksound = "ia/common/boat/sinking/row"

    inst.components.sailable.sanitydrain = TUNING.ENCRUSTEDBOAT_SANITY_DRAIN
    inst.components.sailable.movementbonus = TUNING.ENCRUSTEDBOAT_SPEED
    inst.components.sailable.flotsambuild = "flotsam_armoured_build"
    inst.components.sailable.maprevealbonus = TUNING.MAPREVEAL_ENCRUSTEDBOAT_BONUS
    inst.components.sailable:SetHitImmunity(TUNING.ENCRUSTEDBOAT_HIT_IMMUNITY)

    inst.replica.sailable.creaksound = "ia/common/boat/creaks/encrusted"

    inst.components.flotsamspawner.flotsamprefab = "flotsam_armoured"

    return inst
end

local function cargofn()
    local inst = common()

    inst.AnimState:SetBank("rowboat")
    inst.AnimState:SetBuild("rowboat_cargo_build")
    inst.AnimState:PlayAnimation("run_loop", true)
    inst.MiniMapEntity:SetIcon("boat_cargo.tex")

    if not TheWorld.ismastersim then
        function inst.OnEntityReplicated(inst)
            inst.replica.sailable.creaksound = "ia/common/boat/creaks/cargo"
        end
        return inst
    end

    inst.components.container:WidgetSetup("boat_cargo")

    inst.components.boathealth:SetHealth(TUNING.CARGOBOAT_HEALTH, TUNING.CARGOBOAT_PERISHTIME)
    inst.components.boathealth.damagesound = "ia/common/boat/damage/cargo"
    inst.components.boathealth.hitfx = "boat_hit_fx_cargoboat"

    inst.landsound = "ia/common/boatjump_land_wood"
    inst.sinksound = "ia/common/boat/sinking/log_cargo"

    inst.components.sailable.sanitydrain = TUNING.CARGOBOAT_SANITY_DRAIN
    inst.components.sailable.movementbonus = TUNING.CARGOBOAT_SPEED
    inst.components.sailable.flotsambuild = "flotsam_rowboat_build"
    inst.components.sailable.maprevealbonus = TUNING.MAPREVEAL_CARGOBOAT_BONUS

    inst.replica.sailable.creaksound = "ia/common/boat/creaks/cargo"

    inst.components.flotsamspawner.flotsamprefab = "flotsam_cargo"

    return inst
end

local function woodlegsboatfn()
    local inst = common()

    inst.AnimState:SetBank("rowboat")
    inst.AnimState:SetBuild("pirate_boat_build")
    inst.AnimState:PlayAnimation("run_loop", true)
    inst.MiniMapEntity:SetIcon("boat_woodlegs.tex")

    if not TheWorld.ismastersim then
        function inst.OnEntityReplicated(inst)
            inst.replica.sailable.creaksound = "ia/common/boat/creaks/armoured"
        end
        return inst
    end

    inst.components.container:WidgetSetup("boat_woodlegs")
    inst.components.container.canbeopened = false

    inst.components.boathealth:SetHealth(TUNING.WOODLEGSBOAT_HEALTH, TUNING.ARMOUREDBOAT_PERISHTIME)
    inst.components.boathealth.leakinghealth = TUNING.WOODLEGSBOAT_LEAKING_HEALTH
    inst.components.boathealth.damagesound = "ia/common/boat/damage/armoured"
    inst.components.boathealth.hitfx = "boat_hit_fx_armoured"

    inst.landsound = "ia/common/boatjump_land_shell"
    inst.sinksound = "ia/common/boat/sinking/row"

    inst.components.sailable.sanitydrain = 0
    inst.components.sailable.movementbonus = TUNING.WOODLEGSBOAT_SPEED
    inst.components.sailable.flotsambuild = "flotsam_armoured_build"
    inst.components.sailable.maprevealbonus = TUNING.MAPREVEAL_WOODLEGSBOAT_BONUS
    inst.components.sailable:SetHitImmunity(TUNING.WOODLEGSBOAT_HIT_IMMUNITY)

    inst.replica.sailable.creaksound = "ia/common/boat/creaks/armoured"

    inst.components.flotsamspawner.flotsamprefab = "flotsam_rowboat"

    inst:DoTaskInTime(0.1, function(inst)
        local sailitem = inst.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_SAIL)
        if sailitem == nil then
            local sail = SpawnPrefab("sail_woodlegs")
            inst.components.container:Equip(sail)
        end
        local torchitem = inst.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_LAMP)
        if torchitem == nil then
            local cannon = SpawnPrefab("woodlegs_boatcannon")
            inst.components.container:Equip(cannon)
        end
    end)

    return inst
end

local function DespawnCritterboat(inst)
    SpawnPrefab("splash_water").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function critterboatfn()
    local inst = critterboat_common()

    inst.AnimState:AddOverrideBuild("splash_water_rot")
    inst.AnimState:OverrideSymbol("water_fx_blue", "swimming_ripple", "water_fx_blue")
    inst.AnimState:OverrideSymbol("water_fx_shadow", "swimming_ripple", "water_fx_shadow")

    inst.AnimState:SetBank("ocean_trawler")
    inst.AnimState:SetBuild("ocean_trawler_orange")
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle_full", true)
    inst.AnimState:SetSortWorldOffset(0, -0.55, 0) -- Below the critter

    inst.AnimState:HideSymbol("net_untied")
    inst.AnimState:HideSymbol("net_medium")
    inst.AnimState:HideSymbol("net_full")
    inst.AnimState:HideSymbol("net_empty")
    inst.AnimState:HideSymbol("net")
    inst.AnimState:HideSymbol("hoist_disc")
    inst.AnimState:HideSymbol("hoist_rope_strip")
    inst.AnimState:HideSymbol("water_shadow")
    inst.AnimState:HideSymbol("water_line")

    inst.AnimState:Hide("pole")
    inst.AnimState:Hide("trawler_bits")
    inst.AnimState:Hide("knot")
    inst.AnimState:Hide("spool")

    inst.AnimState:Hide("base_front")

    if not TheWorld.ismastersim then
        function inst.OnEntityReplicated(_inst)
            _inst.replica.sailable.presailanim = "overload"
            _inst.replica.sailable.sailanim = "idle"
            _inst.replica.sailable.postsailanim = "idle_medium"
            _inst.replica.sailable.idleanim = "idle_full"
            _inst.replica.sailable.creaksound = "ia/common/boat/creaks/creaks"
            _inst.replica.sailable.sailsound = "ia/common/sail_LP/surfboard"
            _inst.replica.sailable.alwayssail = true
        end
        return inst
    end

    inst:ListenForEvent("despawn", DespawnCritterboat)

    inst.replica.sailable.presailanim = "overload"
    inst.replica.sailable.sailanim = "idle"
    inst.replica.sailable.postsailanim = "idle_medium"
    inst.replica.sailable.idleanim = "idle_full"
    inst.replica.sailable.creaksound = "ia/common/boat/creaks/creaks"
    inst.replica.sailable.sailsound = "ia/common/sail_LP/surfboard"
    inst.components.sailable.unoccupiedanim = "idle_full"
    inst.components.sailable.alwaysoccupied = true
    inst.components.sailable.alwayssail = true
    inst.components.sailable.offset = {x = 0, y = 0.5, z = 0}

    -- Front of the boat
    inst.components.boatvisualmanager:SpawnBoatEquipVisuals(inst, "boat_critter")

    -- Boat ripples
    ---------------------
	inst.ripple = SpawnPrefab("boat_critter_ripple")
	inst.ripple.entity:SetParent(inst.entity)
	inst.ripple.Transform:SetPosition(0,0,0)
    ---------------------

    inst.landsound = "ia/common/boatjump_land_shell"
    inst.sinksound = "ia/common/boat/sinking/row"

    return inst
end

local function surfboardfn()
    local inst = surfboard_common()

    inst.boat_item = "surfboard_item"

    inst.AnimState:SetBank("raft")
    inst.AnimState:SetBuild("raft_surfboard_build")
    inst.AnimState:PlayAnimation("run_loop", true)

    inst.MiniMapEntity:SetIcon("boat_surfboard.tex")

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.container:WidgetSetup("boat_surfboard")

    inst.waveboost = TUNING.SURFBOARD_WAVEBOOST
    inst.wavesanityboost = TUNING.SURFBOARD_WAVESANITYBOOST

    inst.components.sailable.movementbonus = TUNING.SURFBOARD_SPEED
    inst.components.sailable.maprevealbonus = TUNING.MAPREVEAL_RAFT_BONUS
    inst.components.sailable.hitmoisturerate = TUNING.SURFBOARD_HITMOISTURERATE
    inst.components.sailable.flotsambuild = "flotsam_surfboard_build"

    inst.perishtime = TUNING.SURFBOARD_PERISHTIME
    inst.components.boathealth.maxhealth = TUNING.SURFBOARD_HEALTH
    inst.components.boathealth:SetHealth(TUNING.SURFBOARD_HEALTH, inst.perishtime)

    inst.components.boathealth.damagesound = "ia/common/boat/damage/surfboard"

    --  inst:AddComponent("characterspecific")
    --  inst.components.characterspecific:SetOwner("walani")

    inst.components.flotsamspawner.flotsamprefab = "flotsam_surfboard"

    return inst
end

local function surfboarditemfn()
    local inst = item_common()

    inst.boat = "boat_surfboard"

    inst.MiniMapEntity:SetIcon("boat_surfboard.tex")

    inst.AnimState:SetBank("surfboard")
    inst.AnimState:SetBuild("surfboard")
    inst.AnimState:PlayAnimation("idle")

    return inst
end

return Prefab("boat_raft", raftfn, raftassets, prefabs),
Prefab("boat_lograft", lograftfn, lograftassets, prefabs),
Prefab("boat_row", rowboatfn, rowboatassets, prefabs),
Prefab("boat_armoured", armouredboatfn, armouredboatassets, prefabs),
Prefab("boat_encrusted", encrustedboatfn, encrustedboatassets, prefabs),
Prefab("boat_cargo", cargofn, cargoassets, prefabs),
Prefab("boat_woodlegs", woodlegsboatfn, woodlegsboatassets, prefabs),
MakeVisualBoatEquip("boat_critter", critterboatassets, nil, critterboat_visual_common),
Prefab("boat_critter_ripple", critterboat_ripple, critterboatassets, prefabs),
Prefab("boat_critter", critterboatfn, critterboatassets, prefabs),
Prefab("boat_surfboard", surfboardfn, surfboardassets, prefabs),
Prefab("surfboard_item", surfboarditemfn, surfboardassets, prefabs),
--the 2 is offset for controller users (Bullkelp from basegame also uses 2)
MakePlacer("boat_raft_placer", "raft", "raft_build", "run_loop", nil, nil, nil, nil, nil, nil, nil, 2),
MakePlacer("boat_lograft_placer", "raft", "raft_log_build", "run_loop", nil, nil, nil, nil, nil, nil, nil, 2),
MakePlacer("boat_row_placer", "rowboat", "rowboat_build", "run_loop", nil, nil, nil, nil, nil, nil, nil, 2),
MakePlacer("boat_armoured_placer", "rowboat", "rowboat_armored_build", "run_loop", nil, nil, nil, nil, nil, nil, nil, 2),
MakePlacer("boat_encrusted_placer", "rowboat", "rowboat_encrusted_build", "run_loop", nil, nil, nil, nil, nil, nil, nil, 2),
MakePlacer("boat_cargo_placer", "rowboat", "rowboat_cargo_build", "run_loop", nil, nil, nil, nil, nil, nil, nil, 2),
MakePlacer("boat_woodlegs_placer", "pirate_boat_placer", "pirate_boat_placer", "idle", nil, nil, nil, nil, nil, nil, nil, 2),
MakePlacer("surfboard_item_placer", "raft", "raft_surfboard_build", "run_loop", nil, nil, nil, nil, nil, nil, nil, 2)