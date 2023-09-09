
local oldPickRandomTrinket = PickRandomTrinket
function PickRandomTrinket()
	if math.random() < 11 / (NUM_TRINKETS + 11) then
		return "trinket_ia_".. math.random(13,23)
	else
		return oldPickRandomTrinket()
	end
end

local assets =
{
    Asset("ANIM", "anim/sea_trinkets.zip"),
    Asset("ANIM", "anim/trinkets_ia.zip"),
}

local TRADEFOR =
{
    -- [1] = {"rewardprefab"},
    [4] = {"seaworther_icon"},
}

local seaworther_assets_icon =
{
    Asset("MINIMAP_IMAGE", "moonrockseed"),
}

local seaworther_prefabs_icon =
{
    "globalmapicon",
}

local sunken_boat_trinket_imageoverride = {
    "trinket_ia_20",
    "trinket_ia_21",
    "trinket_ia_22",
    nil, --sea worther
    "trinket_ia_17",
}

local function storeincontainer(inst, container)
    if container ~= nil and container.components.container ~= nil then
        inst:ListenForEvent("onputininventory", inst._oncontainerownerchanged, container)
        inst:ListenForEvent("ondropped", inst._oncontainerownerchanged, container)
        inst:ListenForEvent("onremove", inst._oncontainerremoved, container)
        inst._container = container
    end
end

local function unstore(inst)
    if inst._container ~= nil then
        inst:RemoveEventCallback("onputininventory", inst._oncontainerownerchanged, inst._container)
        inst:RemoveEventCallback("ondropped", inst._oncontainerownerchanged, inst._container)
        inst:RemoveEventCallback("onremove", inst._oncontainerremoved, inst._container)
        inst._container = nil
    end
end

local function tostore(inst, owner)
    if inst._container ~= owner then
        unstore(inst)
        storeincontainer(inst, owner)
    end
    owner = owner.components.inventoryitem ~= nil and owner.components.inventoryitem:GetGrandOwner() or owner
    if inst._owner ~= owner then
        inst._owner = owner
        inst.icon.entity:SetParent(owner.entity)
    end
end

local function toground(inst)
    unstore(inst)
    inst._owner = nil
    inst.icon.entity:SetParent(inst.entity)
end

local function OnRemoveEntity(inst)
    if inst.icon ~= nil then
        inst.icon:Remove()
    end
end

local function MakeTrinket(num, prefix, tuning)
    local prefabs = TRADEFOR[num]

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        local amin = num > 6 and "trinkets_ia" or "sea_trinkets"
        inst.AnimState:SetBank(amin)
        inst.AnimState:SetBuild(amin)
        inst.AnimState:PlayAnimation(tostring(num))

        inst:AddTag("molebait")
        inst:AddTag("cattoy")

        if num == 4 then  --for sea worther
            inst:AddTag("irreplaceable")
            inst:AddTag("nonpotatable") --teleportato support
        end

        MakeInventoryFloatable(inst)
        if num == 4 or num >= 13 then
            inst.components.floater:UpdateAnimations(tostring(num).."_water", tostring(num))
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("appeasement")
        inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_LARGE

        inst:AddComponent("inspectable")
        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("inventoryitem")
        if num ~= 4 then
            inst:AddComponent("tradable")
            inst.components.tradable.goldvalue = TUNING.GOLD_VALUES[tuning][num] or 3
            inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES[tuning][num] or 3
            inst.components.tradable.tradefor = TRADEFOR[num]

            -- if num >= HALLOWEDNIGHTS_TINKET_START and num <= HALLOWEDNIGHTS_TINKET_END then
                -- if IsSpecialEventActive(SPECIAL_EVENTS.HALLOWED_NIGHTS) then
                    -- inst.components.tradable.halloweencandyvalue = 5
                -- end
            -- end

            if num <= 5 then
                local imageoverride = sunken_boat_trinket_imageoverride[num] or nil
                if imageoverride ~= nil then
                    inst.components.inventoryitem:ChangeImageName(imageoverride)
                end
            end

            inst.components.tradable.rocktribute = math.ceil(inst.components.tradable.goldvalue / 3)

            MakeHauntableLaunchAndSmash(inst)
        else --for sea worther
            inst._owner = nil
            inst._container = nil

            inst._oncontainerownerchanged = function(container)
                tostore(inst, container)
            end

            inst._oncontainerremoved = function()
                unstore(inst)
            end

            inst.icon = SpawnPrefab("seaworther_icon")
            inst.icon.entity:SetParent(inst.entity)
            inst:ListenForEvent("onputininventory", tostore)
            inst:ListenForEvent("ondropped", toground)

            inst.OnRemoveEntity = OnRemoveEntity

            MakeHauntableLaunch(inst)
        end

        inst:AddComponent("bait")

        return inst
    end

    return Prefab(prefix .. tostring(num), fn, assets, prefabs)
end

local function icon_init(inst)
    inst.icon = SpawnPrefab("globalmapicon")
    inst.icon.MiniMapEntity:SetPriority(11)
    inst.icon:TrackEntity(inst)
end

local function seaworther_iconfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("sunken_boat_trinket_4.tex")
    inst.MiniMapEntity:SetPriority(11)
    inst.MiniMapEntity:SetCanUseCache(false)
    inst.MiniMapEntity:SetDrawOverFogOfWar(true)

    inst:AddTag("CLASSIFIED")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.icon = nil
    inst:DoTaskInTime(0, icon_init)
    inst.OnRemoveEntity = inst.OnRemoveEntity
    inst.persists = false

    return inst
end

local ret = {}
for k = 13, 23 do
    table.insert(ret, MakeTrinket(k, "trinket_ia_", "IA_TRINKETS"))
end
--Note: these are seperate prefabs because they have different values than there sw counterparts
for k = 1, 5 do
    table.insert(ret, MakeTrinket(k, "sunken_boat_trinket_", "SUNKEN_BOAT_TRINKETS"))
end

table.insert(ret, Prefab("seaworther_icon", seaworther_iconfn, seaworther_assets_icon, seaworther_prefabs_icon))

return unpack(ret)
