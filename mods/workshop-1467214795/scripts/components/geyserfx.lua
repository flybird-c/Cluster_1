local sin = math.sin
local gettime = GetTime

local STATE_IDLE = 0
local STATE_BURN = 1
local STATE_EXTINGUISH = 2
local STATE_IGNITE = 3

local function onlightradius(self, radius)
    self.inst.Light:SetRadius(radius)
    self.inst.replica.geyserfx:SetRadius(radius)
end

local function onlightintensity(self, intensity)
    self.inst.Light:SetIntensity(intensity)
    self.inst.replica.geyserfx:SetIntensity(intensity)
end

local function onlightfalloff(self, falloff)
    self.inst.Light:SetFalloff(falloff)
    self.inst.replica.geyserfx:SetFalloff(falloff)
end

local function onlightrgb(self, rgb)
    self.inst.Light:SetColour(rgb[1], rgb[2], rgb[3])
    self.inst.replica.geyserfx:SetColour(rgb)
end

local GeyserFX = Class(function(self, inst)
    self.inst = inst
    self.state = STATE_BURN
    self.level = nil
    self.playingsound = nil
    self.levels = {}
    self.pre = {}
    self.pst = {}
    self.usedayparamforsound = false
    self.current_radius = 1
    self.lightsound = nil
    self.extinguishsound = nil

    self.radius = 0
    self.intensity = 0
    self.falloff = 0
    self.rgb = { 0, 0, 0}

    inst:DoTaskInTime(0, function()
        if not self.inst:IsAsleep() then
            self.inst:StartUpdatingComponent(self) 
        end
    end)
end,
nil,
{
    radius = onlightradius,
    intensity = onlightintensity,
    falloff = onlightfalloff,
    rgb = onlightrgb,
})

function GeyserFX:OnEntitySleep()
    self.inst:StopUpdatingComponent(self)
end

function GeyserFX:OnEntityWake()
    self.inst:StartUpdatingComponent(self) 
end

function GeyserFX:GetRadius()
    return self.radius
end

function GeyserFX:SetPercentInternal(levels, p, loop)
    local percent = math.clamp(p, 0.0, 1.0)

    local la = 1
    local lb = #levels
    for i = 1, #levels, 1 do
        if levels[i].percent >= percent and levels[i].percent < levels[la].percent then la = i end
        if levels[i].percent <= percent and levels[i].percent > levels[lb].percent then lb = i end
    end

    la = math.max(la, 1)
    lb = math.min(lb, #levels)
    local levela = levels[la]
    local levelb = levels[lb]

    if levela ~= self.level then
        self.level = levela
        if levela.anim then
        self.inst.AnimState:PlayAnimation(levela.anim, loop)
        end
    end

    local t = 0.0
    if levela ~= levelb then
        t = (levelb.percent - percent) / (levelb.percent - levela.percent)
    end
    self.current_radius = Lerp(levelb.radius, levela.radius, t)

    self.radius = self.current_radius
    self.intensity = Lerp(levelb.intensity, levela.intensity, t)
    self.falloff = Lerp(levelb.falloff, levela.falloff, t)
    self.rgb = { Lerp(levelb.colour[1], levela.colour[1], t), Lerp(levelb.colour[2], levela.colour[2], t), Lerp(levelb.colour[3], levela.colour[3], t) }
    --print("levela", levela.percent, levela.intensity, levela.radius, levela.falloff)
    --print("levelb", levelb.percent, levelb.intensity, levelb.radius, levelb.falloff)
    --print("geyser", percent, t, intensity, radius, falloff)

    self.inst.Light:Enable(true)

    if self.playingsound ~= levela.sound then
        if self.playingsound then
            self.inst.SoundEmitter:KillSound(self.playingsound)
            self.playingsound = nil
        end
        if levela.sound then
            self.playingsound = levela.sound
            self.inst.SoundEmitter:PlaySound(levela.sound, "fire")
        end
    end

    if levela.soundintensity or levelb.soundintensity then
        local soundintensity = Lerp(levela.soundintensity or 0, levelb.soundintensity or 0, t)
        self.inst.SoundEmitter:SetParameter("fire", "intensity", soundintensity)
    end
end

function GeyserFX:SetPrePercent(percent)
    self.state = STATE_IGNITE
    self.inst:StartUpdatingComponent(self)
    self:SetPercentInternal(self.pre, percent, false)
end

function GeyserFX:SetPercent(percent)
    self.state = STATE_BURN
    self:SetPercentInternal(self.levels, percent, true)
end

function GeyserFX:SetPstPercent(percent)
    self.state = STATE_EXTINGUISH
    self:SetPercentInternal(self.pst, percent, false)
end

function GeyserFX:OnUpdate(dt)
    if self.state == STATE_IGNITE then
        local percent = 1.0 - (self.inst.AnimState:GetCurrentAnimationTime()/self.inst.AnimState:GetCurrentAnimationLength())
        self:SetPrePercent(percent)
        if self.inst.AnimState:AnimDone() then
            if self.inst.OnBurn then
                self.inst:OnBurn()
            end
            self.state = STATE_BURN
        end
    elseif self.state == STATE_EXTINGUISH then
        local percent = 1.0 - (self.inst.AnimState:GetCurrentAnimationTime()/self.inst.AnimState:GetCurrentAnimationLength())
        self:SetPstPercent(percent)
        if self.inst.AnimState:AnimDone() then
            if self.inst.OnIdle then
                self.inst:OnIdle()
            end
            self.state = STATE_IDLE
        end
    end

    local time = gettime()*30
    local flicker = ( sin( time ) + sin( time + 2 ) + sin( time + 0.7777 ) ) / 2.0 -- range = [-1 , 1]
    flicker = ( 1.0 + flicker ) / 2.0 -- range = 0:1
    self.radius = self.current_radius + flicker*.05

    if self.usedayparamforsound then
        local isday = TheWorld.state.isday
        if isday ~= self.isday then
            self.isday = isday
            local val = isday and 1 or 2
            self.inst.SoundEmitter:SetParameter( "fire", "daytime", val )
        end
    end
end

function GeyserFX:Ignite()
    if self.lightsound then
        self.inst.SoundEmitter:PlaySound(self.lightsound)
    end
    self:SetPrePercent(1.0)
end

--- Kill the fx.
function GeyserFX:Extinguish()
    self.inst.SoundEmitter:KillSound("fire")
    if self.extinguishsound then
        self.inst.SoundEmitter:PlaySound(self.extinguishsound)
    end
    self:SetPstPercent(1.0)
end

return GeyserFX
