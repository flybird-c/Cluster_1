
local function pushbloom(inst, target)
    if target.components.bloomer ~= nil then
        target.components.bloomer:PushBloom(inst, "shaders/anim.ksh", -1)
    elseif not target:HasTag("trophyscale_fish") then
        target.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end
end

local function popbloom(inst, target)
    if target.components.bloomer ~= nil then
        target.components.bloomer:PopBloom(inst)
    elseif not target:HasTag("trophyscale_fish") then
        target.AnimState:ClearBloomEffectHandle()
    end
end

local function light_resume(inst, time)
    inst.fx:setprogress(1 - time / inst.components.spell.duration)
end

local function light_start(inst)
    inst.fx:setprogress(0)
end

local function light_ontarget(inst, target)
    if not target or target:HasTag("playerghost") or target:HasTag("overcharge") then
		inst:Remove()
		return
	end
	
    target.rainbowjellylight = inst
    -- target:AddTag(inst.components.spell.spellname)
	
    local function forceremove()
        inst.components.spell:OnFinish()
    end

    --FollowSymbol position still works on blank symbol, just
    --won't be visible, but we are an invisible proxy anyway.
    inst.Follower:FollowSymbol(target.GUID, "", 0, 0, 0)
    inst:ListenForEvent("onremove", forceremove, target)
    inst:ListenForEvent("death", function() inst.fx:setdead() end, target)
	
    if target:HasTag("player") then
        inst:ListenForEvent("ms_becameghost", forceremove, target)
        if target:HasTag("electricdamageimmune") then --this is a bit of a hack, since this does not imply overcharging
            inst:ListenForEvent("ms_overcharge", forceremove, target)
        end
        inst.persists = false
    else
        inst.persists = not target:HasTag("critter")
    end
	
    pushbloom(inst, target)
	
    if target.components.rideable ~= nil then
        local rider = target.components.rideable:GetRider()
        if rider ~= nil then
            pushbloom(inst, rider)
            inst.fx.entity:SetParent(rider.entity)
        else
            inst.fx.entity:SetParent(target.entity)
        end

        inst:ListenForEvent("riderchanged", function(target, data)
            if data.oldrider ~= nil then
                popbloom(inst, data.oldrider)
                inst.fx.entity:SetParent(target.entity)
            end
            if data.newrider ~= nil then
                pushbloom(inst, data.newrider)
                inst.fx.entity:SetParent(data.newrider.entity)
            end
        end, target)
    else
        inst.fx.entity:SetParent(target.entity)
    end
end

local function light_onfinish(inst)
    local target = inst.components.spell.target
    if target ~= nil then
        target.rainbowjellylight = nil

        popbloom(inst, target)

        if target.components.rideable ~= nil then
            local rider = target.components.rideable:GetRider()
            if rider ~= nil then
                popbloom(inst, rider)
            end
        end
    end
end

local function light_onremove(inst)
    inst.fx:Remove()
end

local function lightfn()

    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddFollower()

    -- inst:AddComponent("lighttweener")
    -- inst.light = inst.entity:AddLight()
    -- inst.light:Enable(true)
	
    inst:Hide()
    inst.persists = false --until we get a target

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    local spell = inst:AddComponent("spell")
    inst.components.spell.spellname = "rainbowjellylight"
    -- inst.components.spell:SetVariables({ radius = TUNING.RAINBOWJELLYFISH_LIGHT_RADIUS })
    inst.components.spell.duration = TUNING.RAINBOWJELLYFISH_LIGHT_DURATION
    inst.components.spell.ontargetfn = light_ontarget
    inst.components.spell.onstartfn = light_start
    inst.components.spell.onfinishfn = light_onfinish
    -- inst.components.spell.fn = light_spellfn
    inst.components.spell.resumefn = light_resume
    inst.components.spell.removeonfinish = true

    inst.fx = SpawnPrefab("rainbowjellylight_fx")
    inst.OnRemoveEntity = light_onremove
	
    return inst
end
-----------------------------------------------------------------------
local noupdate_parents = {
	["trophyscale_fish"] = true, --Hornet: I present, the hackiest hack of the land(Even when we pause the spell the fx still updates light frame, so i came up with this...)
}

local function OnUpdateLight(inst, dt)
    local frame =
        inst._lightdead:value() and
        math.ceil(inst._lightframe:value() * .9 + inst._lightmaxframe * .1) or
        (inst._lightframe:value() + dt)

    if frame >= inst._lightmaxframe then
        inst._lightframe:set_local(inst._lightmaxframe)
        inst._lighttask:Cancel()
        inst._lighttask = nil
    else
		local parent = inst.entity:GetParent()
		if parent and not noupdate_parents[parent.prefab] then
			inst._lightframe:set_local(frame)
		end
		
		--colours, only needs to happen if the light is still valid
		inst._colourframe = inst._colourframe + dt
		if inst._colourframe >= 120 then
			inst._colourframe = 0
			inst._colourprev = inst._colouridx
			inst._colouridx = inst._colouridx + 1
			if inst._colouridx > #inst._colours then
				inst._colouridx = 1
			end
		end
		
		--lerp to colour (lighttweener is not used in DST)
		local lerpk = inst._colourframe / 120
		inst.Light:SetColour(
			inst._colours[inst._colourprev][1] * (1 - lerpk) + inst._colours[inst._colouridx][1] * lerpk,
			inst._colours[inst._colourprev][2] * (1 - lerpk) + inst._colours[inst._colouridx][2] * lerpk,
			inst._colours[inst._colourprev][3] * (1 - lerpk) + inst._colours[inst._colouridx][3] * lerpk
		)
		
    end

    inst.Light:SetRadius(TUNING.RAINBOWJELLYFISH_LIGHT_RADIUS * (1 - inst._lightframe:value() / inst._lightmaxframe))
	
end

local function OnLightDirty(inst)
    if inst._lighttask == nil then
        inst._lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
    end
    OnUpdateLight(inst, 0)
end

local function setprogress(inst, percent)
    inst._lightframe:set(math.max(0, math.min(inst._lightmaxframe, math.floor(percent * inst._lightmaxframe + .5))))
    OnLightDirty(inst)
end

local function setdead(inst)
    inst._lightdead:set(true)
    inst._lightframe:set(inst._lightframe:value())
end

local function lightfx_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.Light:SetRadius(0)
    inst.Light:SetIntensity(.8)
    inst.Light:SetFalloff(.5)
    inst.Light:SetColour(0, 0, 0)
    inst.Light:Enable(true)
    inst.Light:EnableClientModulation(true)
	
	inst._colours = {
		{0/255, 180/255, 255/255}, --skyblue
		{240/255, 230/255, 100/255}, -- ochre 
		{251/255, 30/255, 30/255}, -- red
	}
	inst._colouridx = 1
	inst._colourprev = #inst._colours
	inst._colourframe = 0

    inst._lightmaxframe = math.floor(TUNING.RAINBOWJELLYFISH_LIGHT_DURATION / FRAMES + .5)
    inst._lightframe = net_ushortint(inst.GUID, "rainbowjellyfishlight_fx._lightframe", "lightdirty")
    inst._lightframe:set(inst._lightmaxframe)
    inst._lightdead = net_bool(inst.GUID, "rainbowjellyfishlight_fx._lightdead")
    inst._lighttask = nil

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("lightdirty", OnLightDirty)

        return inst
    end

    inst.setprogress = setprogress
    inst.setdead = setdead
    inst.persists = false

    return inst
end


return Prefab( "rainbowjellylight", lightfn),
Prefab( "rainbowjellylight_fx", lightfx_fn)
