require "stategraphs/SGbermudatriangle"

local assets=
{
	Asset("ANIM", "anim/bermudatriangle.zip"),
	Asset("ANIM", "anim/teleporter_worm.zip"),
	Asset("ANIM", "anim/teleporter_worm_build.zip"),
    Asset("SOUND", "sound/common.fsb"),
}


local function GetStatus(inst)
	if inst.sg.currentstate.name ~= "idle" then
		return "OPEN"
	end
end

local function OnSave(inst, data)
	if inst.disable_sanity_drain then
		data.disable_sanity_drain = true
	end
end

local function OnLoad(inst, data)
	if data ~= nil and data.disable_sanity_drain then
		inst.disable_sanity_drain = true
	end
end

local function OnActivate(inst, doer, target)
	if doer:HasTag("player") then
        ProfileStatsSet("wormhole_used", true)
        AwardPlayerAchievement("wormhole_used", doer)

        local other = inst.components.teleporter.targetTeleporter
        if other ~= nil then
            DeleteCloseEntsWithTag({"WORM_DANGER"}, other, 15)
        end
		
        if doer.components.talker ~= nil then
            doer.components.talker:ShutUp()
        end
        if doer.components.sanity ~= nil and not doer:HasTag("nowormholesanityloss") and not inst.disable_sanity_drain then
            doer.components.sanity:DoDelta(-TUNING.SANITY_MED)
        end

        --Sounds are triggered in player's stategraph
	elseif doer.SoundEmitter then
		inst.SoundEmitter:PlaySound("ia/common/bermuda/spark")
	end
end

local function OnDoneTeleporting(inst, obj)
    if inst.closetask ~= nil then
        inst.closetask:Cancel()
    end
    inst.closetask = inst:DoTaskInTime(1.5, function()
        if not (inst.components.teleporter:IsBusy() or
                inst.components.playerprox:IsPlayerClose()) then
            inst.sg:GoToState("closing")
        end
    end)
    -- inst.SoundEmitter:PlaySound("ia/common/bermuda/spark")

    if obj ~= nil and obj:HasTag("player") then
        obj:DoTaskInTime(1, obj.PushEvent, "bermudatriangleexit") -- for wisecracker
    end
end

local function OnActivateByOther(inst, source, doer)
    if not inst.sg:HasStateTag("open") then
        inst.sg:GoToState("opening")
    end
end

local function onnear(inst)
    if inst.components.teleporter:IsActive() and not inst.sg:HasStateTag("open") then
        inst.sg:GoToState("opening")
    end
end

local function onfar(inst)
    if not inst.components.teleporter:IsBusy() and inst.sg:HasStateTag("open") then
        inst.sg:GoToState("closing")
    end
end

local function onaccept(inst, giver, item)
    inst.components.inventory:DropItem(item)
    inst.components.teleporter:Activate(item)
end

local function StartTravelSound(inst, doer)
    inst.SoundEmitter:PlaySound("ia/common/bermuda/spark")
    doer:PushEvent("wormholetravel", WORMHOLETYPE.BERMUDA) --Event for playing local travel sound
end

local function fn(Sim)
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("bermudatriangle.tex")
   
    inst.AnimState:SetBank("bermudatriangle")
    inst.AnimState:SetBuild("bermudatriangle")
    inst.AnimState:PlayAnimation("idle_loop", true)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(-3)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    
	inst.Transform:SetScale(1.3, 1.3, 1.3)

    inst:AddTag("bermudatriangle")
    --trader, alltrader (from trader component) added to pristine state for optimization
    inst:AddTag("trader")
    inst:AddTag("alltrader")
    inst:AddTag("ignorewalkableplatforms")

    inst:AddTag("antlion_sinkhole_blocker")
	
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:SetStateGraph("SGbermudatriangle")
    
    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus

	inst:AddComponent("playerprox")
	inst.components.playerprox:SetDist(4,5)
    inst.components.playerprox.onnear = onnear
    inst.components.playerprox.onfar = onfar

	inst:AddComponent("teleporter")
	inst.components.teleporter.onActivate = OnActivate
    inst.components.teleporter.onActivateByOther = OnActivateByOther
	inst.components.teleporter.offset = 0
	
    inst:ListenForEvent("starttravelsound", StartTravelSound) -- triggered by player stategraph
    inst:ListenForEvent("doneteleporting", OnDoneTeleporting)

	inst:AddComponent("inventory")

	inst:AddComponent("trader")
    inst.components.trader.acceptnontradable = true
    inst.components.trader.onaccept = onaccept
    inst.components.trader.deleteitemonaccept = false

    inst.OnSave = OnSave
	inst.OnLoad = OnLoad

    return inst
end

return Prefab("bermudatriangle", fn, assets) 
