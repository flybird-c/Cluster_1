local assets =
{
	Asset("ANIM", "anim/whale_tracks.zip"),
	Asset("ANIM", "anim/whale_bubbles.zip"),
	Asset("ANIM", "anim/whale_bubble_follow.zip"),
}

local function GetVerb(inst)
	return "INVESTIGATE"
end

local function addbubblefx(inst)
	local fx = SpawnPrefab("whale_bubbles_fx")
	fx.entity:SetParent(inst.entity)
    fx.AnimState:SetTime(math.random())
	local offset = Vector3(math.random(-1, 1) * math.random(), 0, math.random(-1, 1) * math.random())
	fx.Transform:SetPosition(offset:Get())
end

local function OnInvestigated(inst, doer)
	local pt = Vector3(inst.Transform:GetWorldPosition())
	if TheWorld.components.whalehunter then
		TheWorld.components.whalehunter:OnDirtInvestigated(pt, doer)
	end
	inst.AnimState:PlayAnimation("bubble_pst")
    inst:ListenForEvent("animover", inst.Remove)
end

local function bubblefn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("whaletrack")
	inst.AnimState:SetBuild("whale_tracks")
	inst.AnimState:PlayAnimation("bubble_pre")
	inst.AnimState:PushAnimation("bubble_loop", true)
	inst.AnimState:SetRayTestOnBB(true);
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(-3)

    inst.SoundEmitter:PlaySound("ia/common/whale_trail/discovery_LP", "discovery_LP")
	
    inst.GetActivateVerb = GetVerb

	inst:AddTag("dirtpile")
    inst:AddTag("ignorewalkableplatforms")
    inst.no_wet_prefix = true

	local numbubbles = math.random(2, 4)

	for i = 0, numbubbles do
		addbubblefx(inst)
	end
    
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("inspectable")
	inst:AddComponent("activatable")
	-- set required
	inst.components.activatable.OnActivate = OnInvestigated
	inst.components.activatable.inactive = true
	-- inst.components.activatable.getverb = GetVerb
	
    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        OnInvestigated(inst, haunter)
        return true
    end)
	
    inst.persists = false

	return inst
end

local function trackfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("whalebubblefollow")
	inst.AnimState:SetBuild("whale_bubble_follow")
	inst.AnimState:PlayAnimation("bubblepop")
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(-3)

	inst.SoundEmitter:PlaySound("ia/common/whale_trail/bubble_pop")

	inst:AddTag("track")
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst:AddTag("ignorewalkableplatforms")
    
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("animover", inst.Remove)
	
    inst.persists = false

	return inst
end

local function fxfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	-- inst.entity:AddNetwork()
	--[[Non-networked entity]]


	inst.AnimState:SetBank("whalebubbles")
	inst.AnimState:SetBuild("whale_bubbles")
	inst.AnimState:PlayAnimation("bubble_loop", true)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(-3)

    -- inst.SoundEmitter:PlaySound("ia/common/whale_trail/discovery_LP", "discovery_LP")

	-- inst.entity:SetCanSleep(false)
	inst.persists = false

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst:AddTag("ignorewalkableplatforms")

	return inst
end

return Prefab( "whale_bubbles", bubblefn, assets),
Prefab("whale_bubbles_fx", fxfn, assets),
Prefab("whale_track", trackfn, assets)
