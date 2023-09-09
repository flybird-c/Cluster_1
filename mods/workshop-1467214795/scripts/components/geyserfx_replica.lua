local function onradiusdirty(inst)
  inst.Light:SetRadius(inst._lightradius:value())
end

local function onintensitydirty(inst)
  inst.Light:SetIntensity(inst._lightintensity:value()/100)
end

local function onfalloffdirty(inst)
  inst.Light:SetFalloff(inst._lightfalloff:value()/100)
end

local function onlightcolordirty(inst)
  inst.Light:SetColour(inst._lightred:value()/255, inst._lightgreen:value()/255, inst._lightblue:value()/255)
end

local GeyserFX = Class(function(self, inst)
    self.inst = inst

    self.inst._lightradius = net_smallbyte(inst.GUID, "geyserfx._lightradius", "radiusdirty")
    self.inst._lightintensity = net_byte(inst.GUID, "geyserfx._lightintensity", "intensitydirty")
    self.inst._lightfalloff = net_byte(inst.GUID, "geyserfx._lightfalloff", "falloffdirty")
    self.inst._lightred = net_byte(inst.GUID, "geyserfx._lightred")
    self.inst._lightgreen = net_byte(inst.GUID, "geyserfx._lightgreen")
    self.inst._lightblue = net_byte(inst.GUID, "geyserfx._lightblue")
    self.inst._lightcolordirty = net_event(inst.GUID, "geyserfx._lightcolordirty")

    self.inst:ListenForEvent("radiusdirty", onradiusdirty)
    self.inst:ListenForEvent("intensitydirty", onintensitydirty)
    self.inst:ListenForEvent("falloffdirty", onfalloffdirty)
    self.inst:ListenForEvent("geyserfx._lightcolordirty", onlightcolordirty)
  end)

function GeyserFX:SetRadius(radius)
  self.inst._lightradius:set(radius)
end

function GeyserFX:SetIntensity(intensity)
  self.inst._lightintensity:set(intensity*100)
end

function GeyserFX:SetFalloff(falloff)
  self.inst._lightfalloff:set(falloff*100)
end

function GeyserFX:SetColour(rgb)
  self.inst._lightred:set(rgb[1]*255)
  self.inst._lightgreen:set(rgb[2]*255)
  self.inst._lightblue:set(rgb[3]*255)
  self.inst._lightcolordirty:push()
end

return GeyserFX