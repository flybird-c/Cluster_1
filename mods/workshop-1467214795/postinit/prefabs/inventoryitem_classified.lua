local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local function SerializeObsidianCharge(inst, percent)
    inst.obsidian_charge:set((percent or 0) * 63)
end

local function DeserializeObsidianCharge(inst)
    if inst._parent ~= nil then
        inst._parent:PushEvent("obsidianchargechange", {percent = inst.obsidian_charge:value() / 63})
    end
end

local function SerializeInvSpace(inst, percent)
    inst.invspace:set((percent or 0) * 63)
end

local function DeserializeInvSpace(inst)
    if inst._parent ~= nil then
        inst._parent:PushEvent("invspacechange", {percent = inst.invspace:value() / 63})
    end
end

local function SerializeFuse(inst, time)
    inst.fuse:set(time or 0)
end

local function DeserializeFuse(inst)
    if inst._parent ~= nil then
        inst._parent:PushEvent("fusechange", {time = inst.fuse:value()})
    end
end

local function RegisterNetListeners(inst)
    inst:ListenForEvent("obsidianchargedirty", DeserializeObsidianCharge)
    inst:ListenForEvent("invspacedirty", DeserializeInvSpace)
    inst:ListenForEvent("fusedirty", DeserializeFuse)
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("inventoryitem_classified", function(inst)

    inst.longpickup = net_bool(inst.GUID, "inventoryitem.longpickup")
    inst.deployatrange = net_bool(inst.GUID, "deployable.deployatrange")
    inst.deploydistance = net_shortint(inst.GUID, "deployable.deploydistance")
    inst.obsidian_charge = net_smallbyte(inst.GUID, "obsidiantool.obsidian_charge", "obsidianchargedirty")
    inst.invspace = net_smallbyte(inst.GUID, "inventory.invspace", "invspacedirty")
    inst.fuse = net_smallbyte(inst.GUID, "fuse.fuse", "fusedirty")

    inst.longpickup:set(false)
    inst.deployatrange:set(false)
    inst.deploydistance:set(0)
    inst.obsidian_charge:set(0)
    inst.invspace:set(0)
    inst.fuse:set(0)

    if not TheWorld.ismastersim then

        inst.DeserializeObsidianCharge = DeserializeObsidianCharge
        inst.DeserializeInvSpace = DeserializeInvSpace
        inst.DeserializeFuse = DeserializeFuse

        --Delay net listeners until after initial values are deserialized
        inst:DoTaskInTime(0, RegisterNetListeners)
        return

    end

    inst.SerializeObsidianCharge = SerializeObsidianCharge
    inst.SerializeInvSpace = SerializeInvSpace
    inst.SerializeFuse = SerializeFuse
end)
