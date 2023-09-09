-- Make the actions
local IAENV = env

GLOBAL.setfenv(1, GLOBAL)

local _Actionctor = Action._ctor
Action._ctor = function(self, data, instant, rmb, distance, ghost_valid, ghost_exclusive, canforce, rangecheckfn, ...)
    if data == nil then
        data = {}
    elseif type(data) ~= "table" then
        print("WARNING: Positional Action parameters are deprecated. Please pass action a table instead.")
        data = {priority=data}
    end
    self.replacewithdisembark = data.replacewithdisembark
    _Actionctor(self, data, instant, rmb, distance, ghost_valid, ghost_exclusive, canforce, rangecheckfn, ...)
end

--TODO theres gotta be a better way to set these...
local _CheckFishingOceanRange = ACTIONS.FISH_OCEAN.customarrivecheck
local _ExtraDropDist = ACTIONS.DROP.extra_arrive_dist
local _ExtraPickupRange = ACTIONS.PICK.extra_arrive_dist

local function SailorAction(doer, sailing, normal, ...)
    if doer ~= nil and doer:IsSailing() then
        if type(sailing) == "function" then
            sailing = sailing(doer, ...)
        end
        return sailing
    end
    if type(normal) == "function" then
        normal = normal(doer, ...)
    end
    return normal
end

--TODO theres gotta be a better way to set these...
local ExtraDropDist = function(doer, ...) return SailorAction(doer, 0, _ExtraDropDist, ...) end
ACTIONS.DROP.extra_arrive_dist = ExtraDropDist
ACTIONS.FILL_OCEAN.extra_arrive_dist = ExtraDropDist

local ExtraPickupRange = function(doer, ...) return SailorAction(doer, 0, _ExtraPickupRange, ...) end
ACTIONS.PICK.extra_arrive_dist = ExtraPickupRange
ACTIONS.PICKUP.extra_arrive_dist = ExtraPickupRange
ACTIONS.COMBINESTACK.extra_arrive_dist = ExtraPickupRange

ACTIONS.DROP.replacewithdisembark = true

local REPAIRBOAT = Action({distance = 3})
REPAIRBOAT.id = "REPAIRBOAT"
REPAIRBOAT.str = "Repair"
IAENV.AddAction(REPAIRBOAT)

local READMAP = Action({priority = 4, rmb = true, mount_valid = true})
READMAP.id = "READMAP"
READMAP.str = STRINGS.ACTIONS.READMAP
IAENV.AddAction(READMAP)

local RETRIEVE = Action({priority = 2, distance = 3, mount_valid = true})
RETRIEVE.id = "RETRIEVE"
RETRIEVE.str = STRINGS.ACTIONS.RETRIEVE
IAENV.AddAction(RETRIEVE)

local CUREPOISON = Action({mount_valid = true})
CUREPOISON.id = "CUREPOISON"
CUREPOISON.str = STRINGS.ACTIONS.CUREPOISON
IAENV.AddAction(CUREPOISON)

local PEER = Action({priority = 10, instant = false, rmb = true, distance = 40, mount_valid = true})
PEER.id = "PEER"
PEER.str = STRINGS.ACTIONS.PEER
IAENV.AddAction(PEER)

local EMBARK = Action({priority = 2, distance = 6, invalid_hold_action=true})
EMBARK.id = "EMBARK"
EMBARK.str = STRINGS.ACTIONS.EMBARK
IAENV.AddAction(EMBARK)

local DISEMBARK = Action({priority = 1, distance = 2.5, invalid_hold_action=true})
DISEMBARK.id = "DISEMBARK"
DISEMBARK.str =STRINGS.ACTIONS.DISEMBARK
IAENV.AddAction(DISEMBARK)

local HACK = Action({mindistance = 1.75, silent_fail = true}) --changed from distance to mindistance to fix whale carcass -M --no idea how dst workactions dont play actionfail strings but silent_fail works -Half
HACK.id = "HACK"
HACK.str = STRINGS.ACTIONS.HACK
IAENV.AddAction(HACK)

local TOGGLEON = Action({priority = 2})
TOGGLEON.id = "TOGGLEON"
TOGGLEON.str = STRINGS.ACTIONS.TOGGLEON
IAENV.AddAction(TOGGLEON)

local TOGGLEOFF = Action({priority = 2})
TOGGLEOFF.id = "TOGGLEOFF"
TOGGLEOFF.str = STRINGS.ACTIONS.TOGGLEOFF
IAENV.AddAction(TOGGLEOFF)

local STICK = Action()
STICK.id = "STICK"
STICK.str = STRINGS.ACTIONS.STICK
IAENV.AddAction(STICK)

local MATE = Action()
MATE.id = "MATE"
MATE.str = ""
IAENV.AddAction(MATE)

local CRAB_HIDE = Action()
CRAB_HIDE.id = "CRAB_HIDE"
CRAB_HIDE.str = ""
IAENV.AddAction(CRAB_HIDE)

local TIGERSHARK_FEED = Action()
TIGERSHARK_FEED.id = "TIGERSHARK_FEED"
TIGERSHARK_FEED.str = ""
IAENV.AddAction(TIGERSHARK_FEED)

local FLUP_HIDE = Action()
FLUP_HIDE.id = "FLUP_HIDE"
FLUP_HIDE.str = ""
IAENV.AddAction(FLUP_HIDE)

local DRAGOON_LAVASPIT = Action()
DRAGOON_LAVASPIT.id = "DRAGOON_LAVASPIT"
DRAGOON_LAVASPIT.str = ""
IAENV.AddAction(DRAGOON_LAVASPIT)

local THROW = Action({priority = 0, instant = false, rmb = true, distance = 20, mount_valid = true})
THROW.id = "THROW"
THROW.str = STRINGS.ACTIONS.THROW
IAENV.AddAction(THROW)

local LAUNCH_THROWABLE = Action({priority = 0, instant = false, rmb = true, distance = 20})
LAUNCH_THROWABLE.id = "LAUNCH_THROWABLE"
LAUNCH_THROWABLE.str = STRINGS.ACTIONS.LAUNCH_THROWABLE
IAENV.AddAction(LAUNCH_THROWABLE)

local PACKUP = Action({priority = 2, rmb = true})
PACKUP.id = "PACKUP"
PACKUP.str = STRINGS.ACTIONS.PICKUP
IAENV.AddAction(PACKUP)

local NAME_BOAT = Action({distance = 2, mount_valid = true})
NAME_BOAT.id = "NAME_BOAT"
NAME_BOAT.str = STRINGS.ACTIONS.NAME_BOAT
IAENV.AddAction(NAME_BOAT)

local FISH_FLOTSAM = Action({customarrivecheck = function(doer, dest, ...)
    return SailorAction(doer,
        function (_doer, _dest, ...)
            return _doer:GetDistanceSqToPoint(_dest:GetPoint()) <= 4^2
        end,
        _CheckFishingOceanRange, dest, ...)
    end
})
FISH_FLOTSAM.id = "FISH_FLOTSAM"
FISH_FLOTSAM.str = STRINGS.ACTIONS.FISH_FLOTSAM
IAENV.AddAction(FISH_FLOTSAM)

FISH_FLOTSAM.fn = ACTIONS.FISH.fn
--NOTE: maxdistance is used in the sg, its set here to make it more mod friendly
FISH_FLOTSAM.maxdistance = 8

local _DROPfn = ACTIONS.DROP.fn
ACTIONS.DROP.fn = function(act, ...)
    if act.doer ~= nil
        and act.invobject ~= nil
        and act.invobject.components.inventoryitem ~= nil
        and not act.invobject.components.inventoryitem.notboattossable
        and act.doer.Transform ~= nil
        and act.doer:IsSailing()
        and act.doer.components.inventory ~= nil then
            local rot = act.doer.Transform:GetRotation() * DEGREES
            return  rot ~= nil and act.doer.components.inventory:DropItem(
                        act.invobject,
                        act.options.wholestack and
                            not (act.invobject ~= nil and
                            act.invobject.components.stackable ~= nil and
                            act.invobject.components.stackable.forcedropsingle),
                        {Vector3(math.cos(rot),0,-math.sin(rot)), act.doer:GetPosition()}, --replace randomdir with tossdir
                        act:GetActionPoint()
                    ) or nil
    else
        return _DROPfn(act, ...)
    end
end

DRAGOON_LAVASPIT.fn = function(act)
    if act.doer and act.target then
        local spit = SpawnPrefab("dragoonspit")
        local x, y, z = act.doer.Transform:GetWorldPosition()
        local downvec = TheCamera:GetDownVec() -- TODO no good in multiplayer
        local vec = downvec:GetNormalized()
        local offsetvec = Vector3(vec.x, -.3, vec.z) * 1.7

        spit.Transform:SetPosition(x + offsetvec.x, y + offsetvec.y, z + offsetvec.z)
        spit.Transform:SetRotation(act.doer.Transform:GetRotation())
        return true
    end
end

REPAIRBOAT.fn = function(act)
    if act.target and act.target ~= act.invobject and act.target.components.repairable and act.invobject and act.invobject.components.repairer then
        return act.target.components.repairable:Repair(act.doer, act.invobject)
    elseif act.doer.components.sailor and act.doer.components.sailor.boat and act.doer.components.sailor.boat.components.repairable and act.invobject and act.invobject.components.repairer then
        return act.doer.components.sailor.boat.components.repairable:Repair(act.doer, act.invobject)
    end
end

READMAP.fn = function(act)
    if act.invobject ~= nil and act.invobject:HasTag("scroll") and act.invobject.components ~= nil and act.invobject.components.mapspotrevealer ~= nil then
        act.invobject.components.mapspotrevealer:RevealMap(act.doer)
        return true
    end
end

local _PICKUPtable = ACTIONS.PICKUP
RETRIEVE.fn = function(act, ...)
    if act.doer.components.inventory and act.target and act.target.components.pickupable and not act.target:IsInLimbo() then
        act.doer:PushEvent("onpickup", {item = act.target})
        return act.target.components.pickupable:OnPickup(act.doer)
    end
    return _PICKUPtable.fn(act, ...)
end

CUREPOISON.strfn = function(act)
    if act.invobject and act.invobject:HasTag("venomgland") then
        return "GLAND"
    end
end

local _WALKTOstrfn = ACTIONS.WALKTO.strfn
ACTIONS.WALKTO.strfn = function(act, ...)
    local boat = act.doer.replica.sailor and act.doer.replica.sailor:GetBoat()
    if boat then
        if boat:HasTag("surfboard") then
            return "SURFTO"
        elseif boat.replica.sailable then
            if boat.replica.sailable:GetIsSailEquipped() then
                return "SAILTO"
            else
                return "ROWTO"
            end
        else
            --unused but i dont see any reason to remove it
            return "SWIMTO"
        end
    end
    if _WALKTOstrfn then
        return _WALKTOstrfn(act, ...)
    end
end

local _UNEQUIPstrfn = ACTIONS.UNEQUIP.strfn
ACTIONS.UNEQUIP.strfn = function(act, ...)
    return ((act.invobject ~= nil and
        act.invobject:HasTag("trawlnet") or
        GetGameModeProperty("non_item_equips") or
        act.doer.replica.inventory:GetNumSlots() <= 0)
        and "TRAWLNET") or _UNEQUIPstrfn(act, ...)
end

CUREPOISON.fn = function(act)
    if act.invobject and act.invobject.components.poisonhealer then
        local target = act.target or act.doer
        return act.invobject.components.poisonhealer:Cure(target)
    end
end

ACTIONS.PEER.fn = function(act)
    --For use telescope
    local telescope = act.invobject or (act.doer and act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS))

    if telescope and telescope.components.telescope and telescope.components.telescope.canuse then
        return telescope.components.telescope:Peer(act.doer, act.GetActionPoint and act:GetActionPoint() or act.pos)
    end
end

EMBARK.strfn = function(act)
    local obj = act.target
    if obj:HasTag("surfboard") then
        return "SURF"
    end
end

EMBARK.fn = function(act)
    if act.target.components.sailable then
        act.doer.components.sailor:Embark(act.target)
        return true
    end
end

DISEMBARK.fn = function(act)
    if act.doer.components.sailor then
        if act.doer.components.sailor:IsSailing() then
            local pos = act.GetActionPoint and act:GetActionPoint() or act.pos
            act.doer.components.sailor:Disembark(pos)
            return true
        end
    end
end

local _DoToolWork = UpvalueHacker.GetUpvalue(ACTIONS.CHOP.fn, "DoToolWork")
local function DoToolWork(act, workaction, ...)
    if act.target.components.hackable ~= nil and
    act.target.components.hackable:CanBeHacked() and
    workaction == ACTIONS.HACK then
        if act.invobject and act.invobject.components.obsidiantool then
            act.invobject.components.obsidiantool:Use(act.doer, act.target)
        end
        act.target.components.hackable:Hack(
            act.doer,
            (   (   act.invobject ~= nil and
                act.invobject.components.tool ~= nil and
                act.invobject.components.tool:GetEffectiveness(workaction)
            ) or
            (   act.doer ~= nil and
                act.doer.components.worker ~= nil and
                act.doer.components.worker:GetEffectiveness(workaction)
            ) or
            1
            ) *
            (   act.doer.components.workmultiplier ~= nil and
                act.doer.components.workmultiplier:GetMultiplier(workaction) or
                1
            )
        )
        return true
    elseif act.target.components.workable ~= nil and
    act.target.components.workable:CanBeWorked() and
    act.target.components.workable:GetWorkAction() == workaction then
        if act.invobject and act.invobject.components.obsidiantool then
            act.invobject.components.obsidiantool:Use(act.doer, act.target)
        end
    end
    return _DoToolWork(act, workaction, ...)
end
UpvalueHacker.SetUpvalue(ACTIONS.CHOP.fn, DoToolWork, "DoToolWork")

HACK.fn = function(act)
    DoToolWork(act, ACTIONS.HACK)
    return true
end

HACK.validfn = function(act)
    return (act.target.components.hackable ~= nil and
     act.target.components.hackable:CanBeHacked()) or
     (act.target.components.workable ~= nil and
     act.target.components.workable:CanBeWorked() and
     act.target.components.workable:GetWorkAction() == ACTIONS.HACK )--this fixes hacking a nonvalid target when holding the mouse
end

TOGGLEON.fn = function(act)
    local tar = act.target or act.invobject
    if tar and tar.components.equippable and tar.components.equippable:IsEquipped() and tar.components.equippable.togglable and not tar.components.equippable:IsToggledOn() then
        tar.components.equippable:ToggleOn()
        return true
    end
end

TOGGLEOFF.fn = function(act)
    local tar = act.target or act.invobject
    if tar and tar.components.equippable and tar.components.equippable:IsEquipped() and tar.components.equippable.togglable and tar.components.equippable:IsToggledOn() then
        tar.components.equippable:ToggleOff()
        return true
    end
end

STICK.fn = function(act)
    if act.target.components.stickable then
        act.target.components.stickable:PokedBy(act.doer, act.invobject)
        return true
    end
end

MATE.fn = function(act)
    if act.target == act.doer then
        return false
    end

    if act.doer.components.mateable then
        act.doer.components.mateable:Mate()
        return true
    end
end

CRAB_HIDE.fn = function(act)
    --Dummy action for crab.
end

TIGERSHARK_FEED.fn = function(act)
    --Drop some gross food near your kittens
    local doer = act.doer
    if doer and doer.components.lootdropper then
        doer.components.lootdropper:SpawnLootPrefab("mysterymeat")
    end
end

FLUP_HIDE.fn = function(act)
    --Dummy action for flup hiding
end

THROW.fn = function(act)
    local thrown = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if act.target and not act.pos then
        act:SetActionPoint(act.target:GetPosition())
    end
    if thrown and thrown.components.throwable then
        local pos = act.GetActionPoint and act:GetActionPoint() or act.pos or act.doer:GetPosition()  --act.doer:GetPosition() Prevent error from monkey when throwing  -jarry
        thrown.components.throwable:Throw(pos, act.doer)
        return true
    end
end

LAUNCH_THROWABLE.fn = function(act)
    if act.target and not act.pos then
        act:SetActionPoint(act.target:GetPosition())
    end
    local pos = act.GetActionPoint and act:GetActionPoint() or act.pos
    if act.invobject.components.thrower then
        act.invobject.components.thrower:Throw(pos)
    end
    return true
end

NAME_BOAT.fn = function(act)
    local boat = nil
    if act.target and act.target:HasTag("ia_boat") then
        boat = act.target
    elseif act.doer.components.sailor and act.doer.components.sailor.boat then
        boat = act.doer.components.sailor.boat
    end

    if boat and boat.components.writeable then
        if boat.components.writeable:IsBeingWritten() then
            return false, "INUSE"
        end

        act.doer.tool_prefab = act.invobject.prefab
        if act.invobject.components.stackable then
            act.invobject.components.stackable:Get():Remove()
        else
            act.invobject:Remove()
        end
        boat.components.writeable:BeginWriting(act.doer)
        return true
    end
end

--distance changes between SW and DST used for looking inside boats from shore
local _RUMMAGEextra_arrive_dist = ACTIONS.RUMMAGE.extra_arrive_dist
ACTIONS.RUMMAGE.extra_arrive_dist = function(doer, dest, ...)
    local ret = _RUMMAGEextra_arrive_dist ~= nil and _RUMMAGEextra_arrive_dist(doer, dest, ...) or 0
    if dest ~= nil then
		local target_x, target_y, target_z = dest:GetPoint()

		local is_on_water = TheWorld.Map:IsOceanTileAtPoint(target_x, 0, target_z) and not TheWorld.Map:IsPassableAtPoint(target_x, 0, target_z)
		if is_on_water then
            -- 2 with the ARRIVE_STEP (0.15), player radius (0.5) and boat radius (0.25) subtracted from it is aproximatly 1.1
			return 1.1 + ret
		end
	end
    return ret
end
-- ACTIONS.RUMMAGE.priority = 1

local _RUMMAGEstrfn = ACTIONS.RUMMAGE.strfn
function ACTIONS.RUMMAGE.strfn(act, ...)
    local targ = act.target or act.invobject

    return targ ~= nil and
        targ.replica.container and
        targ.replica.container.type == "boat" and
        (targ.replica.container:IsOpenedBy(act.doer) and "CLOSE" or
        "INSPECT") or _RUMMAGEstrfn(act, ...)
end

local _RUMMAGEfn = ACTIONS.RUMMAGE.fn
function ACTIONS.RUMMAGE.fn(act, ...)
    local ret = {_RUMMAGEfn(act, ...)}
    if ret[1] == nil then
        local targ = act.target or act.invobject

        if targ ~= nil and targ.components.container ~= nil then
            if not targ.components.container.canbeopened and targ.components.container.type == "boat" then
                if CanEntitySeeTarget(act.doer, targ) then
                    act.doer:PushEvent("opencontainer", { container = targ })
                    targ.components.container:Open(act.doer)
                end
                return true
            end
        end
    end
    return unpack(ret)
end

local _EQUIPfn = ACTIONS.EQUIP.fn
function ACTIONS.EQUIP.fn(act, ...)
    if act.doer.components.inventory and act.invobject.components.equippable.equipslot then
        return _EQUIPfn(act, ...)
    end
    --Boat equip slots
    if act.doer.components.sailor and act.doer.components.sailor.boat and act.invobject.components.equippable.boatequipslot then
        local boat = act.doer.components.sailor.boat
        if boat.components.container and boat.components.container.hasboatequipslots then
            boat.components.container:Equip(act.invobject)
        end
    end
end

local _UNEQUIPfn = ACTIONS.UNEQUIP.fn
function ACTIONS.UNEQUIP.fn(act, ...)
    if act.invobject.components.equippable.boatequipslot and act.invobject.parent then
        local boat = act.invobject.parent
        if boat.components.container then
            boat.components.container:Unequip(act.invobject.components.equippable.boatequipslot)
            if act.invobject.components.inventoryitem.cangoincontainer and not GetGameModeProperty("non_item_equips") then
                act.doer.components.inventory:GiveItem(act.invobject)
            else
                act.doer.components.inventory:DropItem(act.invobject, true, true)
            end
        elseif boat.components.inventory and act.invobject.components.equippable.equipslot then
            return _UNEQUIPfn(act, ...)
        end
        return true
    else
        return _UNEQUIPfn(act, ...)
    end
end

local _OPEN_CRAFTINGfn = ACTIONS.OPEN_CRAFTING.fn
function ACTIONS.OPEN_CRAFTING.fn(act, ...)
    if act.target:HasTag("flooded") then
        return false, "FLOODED"
    else
        return _OPEN_CRAFTINGfn(act, ...)
    end
end

local _DEPLOYstrfn = ACTIONS.DEPLOY.strfn
ACTIONS.DEPLOY.strfn = function(act, ...)
    if act.invobject and act.invobject:HasTag("ia_boat") then
        return "LAUNCH"
    end
    return _DEPLOYstrfn(act, ...)
end

local _UNWRAPstrfn = ACTIONS.UNWRAP.strfn
function ACTIONS.UNWRAP.strfn(act, ...)
    local tunacan = act.target or act.invobject
    if tunacan ~= nil and tunacan:HasTag("tincan") then
        return "OPENCAN"
    end
    return _UNWRAPstrfn and _UNWRAPstrfn(act, ...)
end

local _JUMPINstrfn = ACTIONS.JUMPIN.strfn
function ACTIONS.JUMPIN.strfn(act, ...)
    if act.target ~= nil and act.target:HasTag("bermudatriangle") then
        return "BERMUDA"
    end
    return _JUMPINstrfn(act, ...)
end

local _GIVEstrfn = ACTIONS.GIVE.strfn
function ACTIONS.GIVE.strfn(act, ...)
	local targ = act.target or act.invobject
	
	if targ and targ:HasTag("doydoynest") then
		return "PLACE"
	end
	if targ and targ:HasTag("altar") then
		return "READY"
	end
	if targ and targ:HasTag("slotmachine") then 
		return "CURRENCY"
	end
	if targ and targ:HasTag("loadable") then
		return "LOAD"
	end
    return _GIVEstrfn(act, ...)
end

-- Patch for bermuda triangle wormholes
local _JUMPINfn = ACTIONS.JUMPIN.fn
function ACTIONS.JUMPIN.fn(act, ...)
    if act.doer ~= nil
    and act.doer.sg ~= nil
    and act.doer.sg.currentstate.name == "jumpin_pre"
    and not act.doer:HasTag("playerghost") --just use the default ghost states if ghost
    and act.target ~= nil
    and act.target:HasTag("bermudatriangle")
    and act.target.components.teleporter ~= nil
    and act.target.components.teleporter:IsActive() then
        act.doer.sg:GoToState("jumpinbermuda", { teleporter = act.target })
        return true
    end
    return _JUMPINfn(act, ...)
end

-- Patch for hackable things
local _FERTILIZEfn = ACTIONS.FERTILIZE.fn
function ACTIONS.FERTILIZE.fn(act, ...)
    local rets = {_FERTILIZEfn(act, ...)}
    if rets[1] then return rets[1] end
    if act.invobject ~= nil and act.invobject.components.fertilizer ~= nil then
        if not (act.doer ~= nil and act.doer.components.rider ~= nil and act.doer.components.rider:IsRiding()) then
            if act.target ~= nil then
                if act.target.components.hackable and act.target.components.hackable:CanBeFertilized() then
                    rets[1] = act.target.components.hackable:Fertilize(act.invobject, act.doer)
                    TheWorld:PushEvent("CHEVO_fertilized", {target = act.target, doer = act.doer})
                end
            end
        end
        if not rets[1] and act.doer ~= nil and (act.target == nil or act.doer == act.target) then
            if act.doer.components.fertilizable ~= nil then
                rets[1] = act.doer.components.fertilizable:Fertilize(act.invobject)
                --applied = act.invobject.components.fertilizer:Heal(act.doer)
            end
        end

        if rets[1] then
            act.invobject.components.fertilizer:OnApplied(act.doer, act.target)
        end

        return unpack(rets)
    end
end

local _HARVESTvalidfn = ACTIONS.HARVEST.validfn
function ACTIONS.HARVEST.validfn(act, ...)
    if act.target and act.target.components.breeder then --Dont continue to harvest if it cannot be harvested, fixes a crash trying to spawn a nil -Half
        return act.target:HasTag("breederharvest")
    else
        return (_HARVESTvalidfn and _HARVESTvalidfn(act, ...)) or true --if a validfn is added use that or send back true so everything works normally
    end
end

local _HARVESTfn = ACTIONS.HARVEST.fn
function ACTIONS.HARVEST.fn(act, ...)
    if act.target and act.target.components.breeder then
        return act.target.components.breeder:Harvest(act.doer)
    else
        return _HARVESTfn(act, ...)
    end
end

local _PLANTfn = ACTIONS.PLANT.fn
function ACTIONS.PLANT.fn(act, ...)
    if act.doer.components.inventory ~= nil and act.invobject ~= nil and act.target.components.breeder ~= nil then
        local seed = act.doer.components.inventory:RemoveItem(act.invobject)
        if seed then
            if act.target.components.breeder:Seed(seed) then
                return true
            else
                --UGH, this is gross.
                act.doer.components.inventory:GiveItem(seed)
            end
        end
    end
    return _PLANTfn(act, ...)
end

--[[ TODO: This doesnt work with lag comp for some reason? (DST bug...)
local function Fillfn(_fn, act, ...)
    local _flood = TheWorld.components.flooding
    if _flood == nil then return _fn(act, ...) end

    local source_object, filled_object = nil, nil

    if act.target == nil then
        filled_object = act.invobject
    else
        if act.target:HasTag("watersource") then
            source_object = act.target
            filled_object = act.invobject
        elseif act.invobject:HasTag("watersource") then
            source_object = act.invobject
            filled_object = act.target
        end
    end

    if filled_object == nil then
        return _fn(act, ...)
    elseif source_object ~= nil
        and filled_object.components.fillable ~= nil
        and source_object.prefab == filled_object.components.fillable.filledprefab then
        if not filled_object.components.fillable.oceanwatererrorreason or filled_object.components.fillable.acceptsoceanwater or source_object.components.watersource == nil or not source_object.components.watersource.isoceanwater then
            return _fn(act, ...)
        else
            return false, filled_object.components.fillable.oceanwatererrorreason
        end
    end

    local groundpt = act:GetActionPoint()
    if groundpt ~= nil then
        local success
        if _flood.mode == "tides" then -- TODO
            success = filled_object.components.fillable.acceptsoceanwater and _flood:IsPointOnFlood(groundpt.x, 0, groundpt.z)
        else
            success = _flood:IsPointOnFlood(groundpt.x, 0, groundpt.z)
        end

        if success then
            filled_object.components.fillable:Fill()
            return true
        else
            return _fn(act, ...)
        end
    end

    return _fn(act, ...)
end

local _FIllfn = ACTIONS.FILL.fn
ACTIONS.FILL.fn = function(...) return Fillfn(_FIllfn, ...) end
local _FIll_OCEANfn = ACTIONS.FILL_OCEAN.fn
ACTIONS.FILL_OCEAN.fn = function(...) return Fillfn(_FIll_OCEANfn, ...) end
]]

local _FISHfn = ACTIONS.FISH.fn
function ACTIONS.FISH.fn(act, ...)
    if act.doer and act.doer.components.fishingrod then
        --mermfisher
        act.doer.components.fishingrod:StartFishing(act.target, act.doer)
        return true
    end
    return _FISHfn(act, ...)
end

--warly
local _COOKfn = ACTIONS.COOK.fn
function ACTIONS.COOK.fn(act, ...)
    if IA_CONFIG.oldwarly and act.doer ~= nil and act.doer:HasTag("masterchef") and act.target.components.stewer ~= nil then
        if act.target.components.stewer:IsCooking() then
            --Already cooking
            return _COOKfn(act, ...)
        end
        act.target.components.stewer.gourmetcook = true
        local cooking = require("cooking")
        cooking.enableWarly = true
        local ret = {_COOKfn(act, ...)}
        cooking.enableWarly = false
        if not act.target.components.stewer:IsCooking() then
            act.target.components.stewer.gourmetcook = false
        end
        return unpack(ret)
    end
    return _COOKfn(act, ...)
end

local _STOREstrfn = ACTIONS.STORE.strfn
function ACTIONS.STORE.strfn(act, ...)
    return _STOREstrfn(act, ...) or (act.target ~= nil and act.target.prefab == "portablecookpot" and "COOK")
end

local _FISHstrfn = ACTIONS.FISH.strfn
function ACTIONS.FISH.strfn(act, ...)
    if act.target and (act.target.components.workable or act.target:HasTag("FISH_workable") --[[or act.target.components.sinkable--]]) then
        return "RETRIEVE"
    end
    if _FISHstrfn then
        return _FISHstrfn(act, ...)
    end
end

local _HAMMERextra_arrive_dist = ACTIONS.HAMMER.extra_arrive_dist
function ACTIONS.HAMMER.extra_arrive_dist(inst, dest, bufferedaction)
    local distance = _HAMMERextra_arrive_dist and _HAMMERextra_arrive_dist(inst, dest, bufferedaction) or 0
    if inst ~= nil and dest ~= nil then
        local dx, dy, dz = dest:GetPoint()
        if IsOnOcean(inst) ~= IsOnOcean(dx, dy, dz) then
            distance = distance + 1
        end
    end
    return distance
end

local _GIVEfn = ACTIONS.GIVE.fn
function ACTIONS.GIVE.fn(act, ...)
    if act.target then
        if act.invobject.components.appeasement and act.target.components.appeasable then
            return act.target.components.appeasable:AcceptGift(act.doer, act.invobject)
        end
    end
    if _GIVEfn then
        return _GIVEfn(act, ...)
    end
end

---------------------------------------------------------------------
------------------------COMPONENT ACTIONS----------------------------
---------------------------------------------------------------------

IAENV.AddComponentAction("SCENE", "breeder", function(inst, doer, actions, right)
    if inst:HasTag("breederharvest") and doer.replica.inventory then
        table.insert(actions, ACTIONS.HARVEST)
    end
end)

IAENV.AddComponentAction("SCENE", "sailable", function(inst, doer, actions, right)
    if inst:HasTag("sailable") and not (doer.replica.rider and doer.replica.rider:IsRiding()) then
        if not right then
            table.insert(actions, ACTIONS.EMBARK)
        end
    end
end)

IAENV.AddComponentAction("USEITEM", "poisonhealer", function(inst, doer, target, actions, right)
    if inst:HasTag("poison_antidote") and target and target:HasTag("poisonable") then
        if target:HasTag("poison") or
        (target:HasTag("player") and
        ((target.components.poisonable and target.components.poisonable:IsPoisoned()) or
        (target.player_classified and target.player_classified.ispoisoned:value()) or
        inst:HasTag("poison_vaccine"))) then
            table.insert(actions, ACTIONS.CUREPOISON)
        end
    end
end)

IAENV.AddComponentAction("USEITEM", "seedable", function(inst, doer, target, actions, right)
    if target:HasTag("breeder") and target:HasTag("canbeseeded") then
        table.insert(actions, ACTIONS.PLANT)
    end
end)

IAENV.AddComponentAction("USEITEM", "sticker", function(inst, doer, target, actions, right)
    if target:HasTag("canbesticked") then
        table.insert(actions, ACTIONS.STICK)
    end
end)

IAENV.AddComponentAction("USEITEM", "drawingtool", function(inst, doer, target, actions, right)
    if target:HasTag("ia_boat") then
        table.insert(actions, ACTIONS.NAME_BOAT)
    end
end)


IAENV.AddComponentAction("USEITEM", "tool", function(inst, doer, target, actions, right)
    if inst:HasTag("HACK_tool") and target:HasTag("HACK_workable") then
        table.insert(actions, ACTIONS.HACK)
    end
end)

IAENV.AddComponentAction("USEITEM", "appeasement", function(inst, doer, target, actions, right)
    if target:HasTag("appeasable") then
        table.insert(actions, ACTIONS.GIVE)
    end
end)

IAENV.AddComponentAction("POINT", "throwable", function(inst, doer, pos, actions, right, target)
    if right and not TheWorld.Map:IsGroundTargetBlocked(pos) and not (inst.replica.equippable and not inst.replica.equippable:IsEquipped()) then
        table.insert(actions, ACTIONS.THROW)
    end
end)

IAENV.AddComponentAction("POINT", "thrower", function(inst, doer, pos, actions, right, target)
    if right and not TheWorld.Map:IsGroundTargetBlocked(pos) and not (inst.replica.equippable and not inst.replica.equippable:IsEquipped()) then
        table.insert(actions, ACTIONS.LAUNCH_THROWABLE)
    end
end)

IAENV.AddComponentAction("POINT", "telescope", function(inst, doer, pos, actions, right, target)
    if right and inst:HasTag("telescope") then
        table.insert(actions, ACTIONS.PEER)
    end
end)

IAENV.AddComponentAction("EQUIPPED", "throwable", function(inst, doer, target, actions, right)
    if right and
        not (doer.components.playercontroller ~= nil and
            doer.components.playercontroller.isclientcontrollerattached) and
        not TheWorld.Map:IsGroundTargetBlocked(target:GetPosition()) and
        not (inst.replica.equippable and not inst.replica.equippable:IsEquipped()) and
        target ~= doer then
        table.insert(actions, ACTIONS.THROW)
    end
end)

IAENV.AddComponentAction("EQUIPPED", "thrower", function(inst, doer, target, actions, right)
    if right and
        not (doer.components.playercontroller ~= nil and
            doer.components.playercontroller.isclientcontrollerattached) and
        not TheWorld.Map:IsGroundTargetBlocked(target:GetPosition()) and
        not (inst.replica.equippable and not inst.replica.equippable:IsEquipped()) and
        target ~= doer then
        table.insert(actions, ACTIONS.LAUNCH_THROWABLE)
    end
end)

IAENV.AddComponentAction("INVENTORY", "repairer", function(inst, doer, actions, right)
    if doer and doer.replica.sailor and doer.replica.sailor:GetBoat() then
        local boat = doer.replica.sailor:GetBoat()
        for k, v in pairs(MATERIALS) do
            if boat:HasTag("repairable_"..v) then
                if inst:HasTag("health_"..v) and boat.replica.boathealth ~= nil then
                    table.insert(actions, ACTIONS.REPAIRBOAT)
                end
                return
            end
        end
    end
end)

IAENV.AddComponentAction("INVENTORY", "poisonhealer", function(inst, doer, actions, right)
    if inst:HasTag("poison_antidote") and doer:HasTag("poisonable") and
    (doer:HasTag("player") and
    ((doer.components.poisonable and doer.components.poisonable:IsPoisoned()) or
    (doer.player_classified and doer.player_classified.ispoisoned:value()) or
    inst:HasTag("poison_vaccine"))) then
        table.insert(actions, ACTIONS.CUREPOISON)
    end
end)

IAENV.AddComponentAction("INVENTORY", "drawingtool", function(inst, doer, actions)
    if doer and doer.replica.sailor and doer.replica.sailor:GetBoat() then
        table.insert(actions, ACTIONS.NAME_BOAT)
    end
end)

IAENV.AddComponentAction("ISVALID", "hackable", function(inst, action, right)
    return action == ACTIONS.HACK and inst:HasTag("HACK_workable")
end)

local COMPONENT_ACTIONS = UpvalueHacker.GetUpvalue(EntityScript.CollectActions, "COMPONENT_ACTIONS")
local SCENE = COMPONENT_ACTIONS.SCENE
local USEITEM = COMPONENT_ACTIONS.USEITEM
local POINT = COMPONENT_ACTIONS.POINT
local EQUIPPED = COMPONENT_ACTIONS.EQUIPPED
local INVENTORY = COMPONENT_ACTIONS.INVENTORY

local _SCENEcontainer = SCENE.container
function SCENE.container(inst, doer, actions, right, ...)
    if not inst:HasTag("bundle") and not inst:HasTag("burnt") and
    doer.replica.inventory ~= nil and
    not (doer.replica.rider ~= nil and
    doer.replica.rider:IsRiding()) and
    right and inst.replica.container.type == "boat" then
        table.insert(actions, ACTIONS.RUMMAGE)
    else
        _SCENEcontainer(inst, doer, actions, right, ...)
    end
end

local _SCENEinventoryitem = SCENE.inventoryitem
function SCENE.inventoryitem(inst, doer, actions, right, ...)
   if TheWorld.items_pass_ground and not TheWorld.Map:RunWithoutIACorners(inst.IsOnPassablePoint, inst) and doer:IsOnPassablePoint() then
        if inst.replica.inventoryitem:CanBePickedUp() and
        doer.replica.inventory ~= nil and (doer.replica.inventory:GetNumSlots() > 0 or inst.replica.equippable ~= nil) and
        not (inst:HasTag("catchable") or (not inst:HasTag("ignoreburning") and (inst:HasTag("fire") or inst:HasTag("smolder")))) and
        (not inst:HasTag("spider") or (doer:HasTag("spiderwhisperer") and right)) and
        (right or not inst:HasTag("heavy")) and
        not (right and inst.replica.container ~= nil and inst.replica.equippable == nil) then
            table.insert(actions, ACTIONS.RETRIEVE)
        end
    --fix for tarlamp since its considered to be on fire.
    elseif inst:HasTag("ignoreburning") and (inst:HasTag("fire") or inst:HasTag("smolder")) then
        if inst.replica.inventoryitem:CanBePickedUp() and
            doer.replica.inventory ~= nil and (doer.replica.inventory:GetNumSlots() > 0 or inst.replica.equippable ~= nil) and
            not inst:HasTag("catchable") and (right or not inst:HasTag("heavy")) and
            (not inst:HasTag("spider") or (doer:HasTag("spiderwhisperer") and right)) and
            not (right and inst.replica.container ~= nil and inst.replica.equippable == nil) then
            table.insert(actions, ACTIONS.PICKUP)
        end
    else
       _SCENEinventoryitem(inst, doer, actions, right, ...)
    end
end

local _SCENErideable = SCENE.rideable
function SCENE.rideable(inst, doer, actions, right, ...)
    if not (doer and doer:IsSailing()) then
        return _SCENErideable(inst, doer, actions, right, ...)
    end
end

local _USEITEMfertilizer = USEITEM.fertilizer
function USEITEM.fertilizer(inst, doer, target, actions, ...)
    if not inst:HasTag("fertilizer_volcanic") and not inst:HasTag("fertilizer_oceanic") and not target:HasTag("witherable_volcanic") and not target:HasTag("witherable_oceanic") then
        _USEITEMfertilizer(inst, doer, target, actions, ...)
    elseif inst:HasTag("fertilizer_volcanic") then
        if target:HasTag("witherable_volcanic") and target:HasTag("barren") then
            table.insert(actions, ACTIONS.FERTILIZE)
        end
    elseif inst:HasTag("fertilizer_oceanic") then
        if target:HasTag("witherable_oceanic") and target:HasTag("barren") then
            table.insert(actions, ACTIONS.FERTILIZE)
        end
    end
end

local _USEITEMfishingrod = USEITEM.fishingrod
function USEITEM.fishingrod(inst, doer, target, actions, ...)
    if target:HasTag("flotsamfisher") and not inst.replica.fishingrod:HasCaughtFish() then
        if target ~= inst.replica.fishingrod:GetTarget() then
            table.insert(actions, ACTIONS.FISH_FLOTSAM)
        elseif doer.sg == nil or doer.sg:HasStateTag("fishing") then
            table.insert(actions, ACTIONS.REEL)
        end
    else
        return _USEITEMfishingrod(inst, doer, target, actions, ...)
    end
end

local _USEITEMfuel = USEITEM.fuel
function USEITEM.fuel(inst, doer, target, actions, right, ...)
    local _actioncount = #actions
    _USEITEMfuel(inst, doer, target, actions, right, ...)
    if #actions == _actioncount then --if _USEITEMfuel didn't add an action, we process the "secondaryfuel"
        if not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding())
            or (target.replica.inventoryitem ~= nil and target.replica.inventoryitem:IsGrandOwner(doer)) then
            if inst.prefab ~= "spoiled_food" and
                inst:HasTag("quagmire_stewable") and
                target:HasTag("quagmire_stewer") and
                target.replica.container ~= nil and
                target.replica.container:IsOpenedBy(doer) then
                return
            end
            for k, v in pairs(FUELTYPE) do
                if inst:HasTag(v.."_secondaryfuel") then
                    if target:HasTag(v.."_fueled") then
                        table.insert(actions, inst:GetIsWet() and ACTIONS.ADDWETFUEL or ACTIONS.ADDFUEL)
                    end
                end
            end
        end
    end
end

local _USEITEMlighter = USEITEM.lighter
function USEITEM.lighter(inst, doer, target, actions, ...)
    local wasLimbo
    if target:HasTag("allowinventoryburning") and target:HasTag("INLIMBO") then
        target:RemoveTag("INLIMBO")
        wasLimbo = true
    end
    _USEITEMlighter(inst, doer, target, actions, ...)
    if wasLimbo then
        target:AddTag("INLIMBO")
    end
end

local _USEITEMrepairer = USEITEM.repairer
function USEITEM.repairer(inst, doer, target, actions, right, ...)
    if right then
        _USEITEMrepairer(inst, doer, target, actions, right, ...)
    else
        for k, v in pairs(MATERIALS) do
            if target:HasTag("repairable_"..v) then
                if inst:HasTag("health_"..v) and target.replica.boathealth ~= nil then
                    table.insert(actions, ACTIONS.REPAIRBOAT)
                end
                return
            end
        end
    end
end

local _POINTdeployable = POINT.deployable
function POINT.deployable(inst, doer, pos, actions, right, target, ...)
    if right and inst.replica.inventoryitem ~= nil and inst.replica.inventoryitem:CanDeploy(pos, nil, doer, (doer.components.playercontroller ~= nil and doer.components.playercontroller.deployplacer ~= nil) and doer.components.playercontroller.deployplacer.Transform:GetRotation() or 0) then
        return _POINTdeployable(inst, doer, pos, actions, right, target, ...)
    end
end

local _POINTblinkstaff = POINT.blinkstaff
function POINT.blinkstaff(inst, doer, pos, actions, right, target, ...)
    if right and doer and doer:IsSailing() then
        local x,y,z = pos:Get()
        if right and TheWorld.Map:IsOceanAtPoint(x, y, z) and not TheWorld.Map:IsGroundTargetBlocked(pos) and not doer:HasTag("steeringboat") and not doer:HasTag("rotatingboat") then
            table.insert(actions, ACTIONS.BLINK)
        end
    else
        return _POINTblinkstaff(inst, doer, pos, actions, right, target, ...)
    end
end

-- local _POINTfillable = POINT.fillable
-- function POINT.fillable(inst, doer, pos, actions, right, target, ...)
--     local _flood = TheWorld.components.flooding
--     if inst:HasTag("fillable_showoceanaction") 
--         and (inst:HasTag("allow_action_on_impassable") or inst.replica.equippable == nil or not inst.replica.equippable:IsEquipped()) 
--         and _flood ~= nil and _flood:IsPointOnFlood(pos.x, 0, pos.z) then
--         table.insert(actions, ACTIONS.FILL)
--     else
--         return _POINTfillable(inst, doer, pos, actions, right, target, ...)
--     end
-- end

local _EQUIPPEDlighter = EQUIPPED.lighter
function EQUIPPED.lighter(inst, doer, target, actions, ...)
    local wasLimbo
    if target:HasTag("allowinventoryburning") and target:HasTag("INLIMBO") then
        target:RemoveTag("INLIMBO")
        wasLimbo = true
    end
    _EQUIPPEDlighter(inst, doer, target, actions, ...)
    if wasLimbo then
        target:AddTag("INLIMBO")
    end
end

--patch for wormwood
local _INVENTORYfertilizer = INVENTORY.fertilizer
function INVENTORY.fertilizer(inst, doer, actions, ...)
    if not inst:HasTag("fertilizer_volcanic") and not inst:HasTag("fertilizer_oceanic") then
        _INVENTORYfertilizer(inst, doer, actions, ...)
    end
end

local _EQUIPPEDfishingrod = EQUIPPED.fishingrod
function EQUIPPED.fishingrod(inst, doer, target, actions, ...)
    if target:HasTag("flotsamfisher") and not inst.replica.fishingrod:HasCaughtFish() then
        if target ~= inst.replica.fishingrod:GetTarget() then
            table.insert(actions, ACTIONS.FISH_FLOTSAM)
        elseif doer.sg == nil or doer.sg:HasStateTag("fishing") then
            table.insert(actions, ACTIONS.REEL)
        end
    else
        return _EQUIPPEDfishingrod(inst, doer, target, actions, ...)
    end
end

local _USEITEMfertilizer = USEITEM.fertilizer
local _EQUIPPEDfertilizer = EQUIPPED.fertilizer
function EQUIPPED.fertilizer(inst, doer, target, actions, ...)
    _USEITEMfertilizer(inst, doer, target, actions, ...)
    if _EQUIPPEDfertilizer then
        _EQUIPPEDfertilizer(inst, doer, target, actions, ...)
    end
end

local _INVENTORYmapspotrevealer = INVENTORY.mapspotrevealer
function INVENTORY.mapspotrevealer(inst, doer, actions, right, ...)
    if not inst:HasTag("scroll") then
        _INVENTORYmapspotrevealer(inst, doer, actions, right, ...)
    else
        table.insert(actions, ACTIONS.READMAP)
    end
end


local _INVENTORYequippable = INVENTORY.equippable
function INVENTORY.equippable(inst, doer, actions, ...)
    local canEquip = true
    if inst.replica.equippable:BoatEquipSlot() ~= "INVALID" and inst.replica.equippable:EquipSlot() == "INVALID" then --Can only be equipped on a boat
        canEquip = false

        local sailor = doer.replica.sailor
        local boat = sailor and sailor:GetBoat()
        if boat and boat.replica.container.hasboatequipslots and boat.replica.container.enableboatequipslots then
            canEquip = true
        end
    end

    if not inst.replica.equippable:IsEquipped() and canEquip then
        _INVENTORYequippable(inst, doer, actions, ...)
    elseif inst.replica.equippable:IsEquipped() then
        if inst:HasTag("togglable") then
            if inst:HasTag("toggled") then
                table.insert(actions, ACTIONS.TOGGLEOFF)
            else
                table.insert(actions, ACTIONS.TOGGLEON)
            end
        else
            _INVENTORYequippable(inst, doer, actions, ...)
        end
    end
end

local _USEITEMsmother = USEITEM.smotherer
function USEITEM.smotherer(inst, doer, target, actions, ...)
    if not target:HasTag("flamegeyser") and not (inst.prefab == "ice" and target:HasTag("lavapool")) then
        return _USEITEMsmother(inst, doer, target, actions, ...)
    end
end

local function ActionCanMapSoulhop(act)
    if act.invobject == nil and act.doer and act.doer.CanSoulhop then
        return act.doer:CanSoulhop(act.distancecount)
    end
    return false
end

local BLINK_MAP_MUST = { "CLASSIFIED", "globalmapicon", "fogrevealer" }
local _ACTIONS_MAP_REMAPblink = ACTIONS_MAP_REMAP[ACTIONS.BLINK.code]
ACTIONS_MAP_REMAP[ACTIONS.BLINK.code] = function(act, targetpos, ...)
    local doer = act.doer
    if doer == nil or not doer:IsSailing() then
        return _ACTIONS_MAP_REMAPblink(act, targetpos, ...)
    end
    local aimassisted = false
    local distoverride = nil
    if not TheWorld.Map:IsOceanAtPoint(targetpos.x, targetpos.y, targetpos.z) then
        return nil
    end
    -- -- NOTES(JBK): No map tile at the cursor but the area might contain a boat that has a maprevealer component around it.
    -- -- First find a globalmapicon near here and look for if it is from a fogrevealer and assume it is on landable terrain.
    -- local ents = TheSim:FindEntities(targetpos.x, targetpos.y, targetpos.z, PLAYER_REVEAL_RADIUS * 0.4, BLINK_MAP_MUST)
    -- local revealer = nil
    -- local MAX_WALKABLE_PLATFORM_DIAMETERSQ = TUNING.MAX_WALKABLE_PLATFORM_RADIUS * TUNING.MAX_WALKABLE_PLATFORM_RADIUS * 4 -- Diameter.
    -- for _, v in ipairs(ents) do
    --     if doer:GetDistanceSqToInst(v) > MAX_WALKABLE_PLATFORM_DIAMETERSQ then -- Ignore close boats because the range for aim assist is huge.
    --         revealer = v
    --         break
    --     end
    -- end
    -- if revealer ~= nil then
    --     return nil
    -- end
    -- -- NOTES(JBK): Ocuvigils are normally placed at the edge of the boat and can result in the teleportee being pushed out of the boat boundary.
    -- -- The server will make the adjustments to the target position without the client being able to know so we force the original distance to be an override.
    -- targetpos.x, targetpos.y, targetpos.z = revealer.Transform:GetWorldPosition()
    -- distoverride = act.pos:GetPosition():Dist(targetpos)
    -- if revealer._target ~= nil then
    --     -- Server only code.
    --     local boat = revealer._target:GetCurrentPlatform()
    --     if boat == nil then
    --         -- This should not happen but in case it does fail the act to not teleport onto water.
    --         return nil
    --     end
    --     targetpos.x, targetpos.y, targetpos.z = boat.Transform:GetWorldPosition()
    -- end
    -- aimassisted = true
    local dist = distoverride or act.pos:GetPosition():Dist(targetpos)
    local act_remap = BufferedAction(doer, nil, ACTIONS.BLINK_MAP, act.invobject, targetpos)
    local dist_mod = ((doer._freesoulhop_counter or 0) * (TUNING.WORTOX_FREEHOP_HOPSPERSOUL - 1)) * act.distance
    local dist_perhop = (act.distance * TUNING.WORTOX_FREEHOP_HOPSPERSOUL * TUNING.WORTOX_MAPHOP_DISTANCE_SCALER)
    local dist_souls = (dist + dist_mod) / dist_perhop
    act_remap.maxsouls = TUNING.WORTOX_MAX_SOULS
    act_remap.distancemod = dist_mod
    act_remap.distanceperhop = dist_perhop
    act_remap.distancefloat = dist_souls
    act_remap.distancecount = math.clamp(math.ceil(dist_souls), 1, act_remap.maxsouls)
    -- act_remap.aimassisted = aimassisted
    if not ActionCanMapSoulhop(act_remap) then
        return nil
    end
    return act_remap
end

-- TODO: This is a quick tmp -Half
local function SetupOceanBoundryTest(action, allow_boats)
    local _fn = action.fn
    action.fn = function(act, ...)
        if act and act.doer and act.doer.Transform and act.target and act.target.Transform then
            local _map = TheWorld.Map
            local x, y, z = act.target.Transform:GetWorldPosition()
            local px, py, pz = act.doer.Transform:GetWorldPosition()
            
            if not act.doer:CanOnWater(true) and (not allow_boats or _map:GetPlatformAtPoint(px, py, pz) == nil) and _map:IsOceanAtPoint(x, y, z, act.target:HasTag("ignorewalkableplatforms")) then return false, "MUSTSAIL" end
            if not act.doer:CanOnLand(true) and not _map:IsOceanAtPoint(x, y, z, act.target:HasTag("ignorewalkableplatforms")) then return false, "CANTSAIL" end
        end
        return _fn ~= nil and _fn(act, ...)
    end
end

SetupOceanBoundryTest(ACTIONS.ENTER_GYM)
-- SetupOceanBoundryTest(ACTIONS.JUMPIN) -- This causes a softlock...
SetupOceanBoundryTest(ACTIONS.MOUNT_PLANK)
SetupOceanBoundryTest(ACTIONS.MOUNT, true)
SetupOceanBoundryTest(ACTIONS.MIGRATE, true)
