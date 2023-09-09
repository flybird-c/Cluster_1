return Class(function(self, inst)

local STATES = {
    WAIT = 0,
    WARN = 1,
    MOVEOFF = 2,
    BLIND = 3,
    MOVEBACK = 4,
    RETURN = 5,
}

local _growlsounds = {
	-- 'ia/common/bermuda/sparks_active',
	-- 'ia/creatures/blue_whale/idle',
	'ia/creatures/blue_whale/breach_swim',
	'ia/creatures/cormorant/takeoff',
	'ia/creatures/crocodog/distant',
	'ia/creatures/crocodog/distant',
	-- 'ia/creatures/quacken/enter',
	'ia/creatures/seagull/takeoff',
	-- 'ia/creatures/sharx/distant',
	'ia/creatures/twister/distant',
	'ia/creatures/white_whale/breach_swim',
	'ia/creatures/white_whale/mouth_open',
	-- 'dontstarve/sanity/creature2/attack_grunt',
	-- 'dontstarve/sanity/creature1/taunt',
}
local _boatsounds = {
	'ia/creatures/seacreature_movement/splash_small',
	'ia/creatures/seacreature_movement/splash_medium',
	-- 'ia/creatures/seacreature_movement/splash_large',
	'ia/creatures/seacreature_movement/thrust',
	-- 'ia/common/brain_coral_harvest',
	-- 'ia/common/pickobject_water',
}

self.inst = inst
self._state = net_tinybyte(inst.GUID, "mapwrapper._state", "mapwrapperdirty")

-- This handles mist for us
if not TheNet:IsDedicated() then
	inst:AddChild( SpawnAt("edgefog", inst) )
end


local function PlayFunnyGrowl(inst)
	inst.SoundEmitter:PlaySound(_growlsounds[math.random(#_growlsounds)])
end
local function PlayFunnyBoat(inst)
	inst.SoundEmitter:PlaySound(_boatsounds[math.random(#_boatsounds)])
end

function self:GetState()
    return self._state:value()
end

function self:SetState()
    if TheNet:IsDedicated() then return end
	
	if self.inst ~= ThePlayer then return end
	
	if self:GetState() == STATES.WARN then
		self.inst.components.talker:Say(GetString(self.inst, "ANNOUNCE_MAPWRAP_WARN"))
		
	elseif self:GetState() == STATES.MOVEOFF then
		self.inst.components.talker:Say(GetString(self.inst, "ANNOUNCE_MAPWRAP_LOSECONTROL"))
		if self.inst.HUD then
			TheFrontEnd:Fade(FADE_OUT, 3, nil, nil, nil, "white")
			self.inst.HUD:Hide()
		end

	elseif self:GetState() == STATES.BLIND then
		self.inst:DoTaskInTime(1.4, PlayFunnyGrowl)
		self.inst:DoTaskInTime(2.1, PlayFunnyGrowl)
		self.inst:DoTaskInTime(2.8, PlayFunnyBoat)
		
	elseif self:GetState() == STATES.MOVEBACK then
		if self.inst.HUD then
			TheFrontEnd:Fade(FADE_IN, 6, nil, nil, nil, "white")
		end

	elseif self:GetState() == STATES.RETURN then
		self.inst.components.talker:Say(GetString(self.inst, "ANNOUNCE_MAPWRAP_RETURN"))
		if self.inst.HUD then
			self.inst.HUD:Show()
		end
	end
	
end

self.inst:ListenForEvent("mapwrapperdirty", function() self:SetState() end)
	
end)
