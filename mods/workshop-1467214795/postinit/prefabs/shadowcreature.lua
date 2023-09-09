local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local function ExchangeWithSwimmingTerror(inst, target, x, y, z)
    -- nessie my love
    if inst.components.combat.target then
        local target = inst.components.combat.target
        local x,y,z = target.Transform:GetWorldPosition()
        if target:CanOnWater(true) and target:GetCurrentPlatform() == nil and TheWorld.Map:IsOceanAtPoint(x,y,z,true) then
            local sx,sy,sz = inst.Transform:GetWorldPosition()
            local radius = 0
            local theta = inst:GetAngleToPoint(Vector3(x,y,z)) * DEGREES
            while TheWorld.Map:IsVisualGroundAtPoint(sx,sy,sz) and radius < 30 do
                radius = radius + 2
                local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
                sx = sx + offset.x
                sy = sy + offset.y
                sz = sz + offset.z
            end

            if radius < 30 then
                local shadow = SpawnPrefab("swimminghorror")
                if inst.prefab == "crawlinghorror" then
                    shadow:SetCrawlingHorror()
                end
                shadow.components.health:SetPercent(inst.components.health:GetPercent())
                shadow.Transform:SetPosition(sx,sy,sz)
                shadow.sg:GoToState("appear")
                shadow.components.combat:SetTarget(target)
                TheWorld:PushEvent("ms_exchangeshadowcreature", {ent = inst, exchangedent = shadow})
                local fx = SpawnPrefab("shadow_teleport_in")
                fx.Transform:SetPosition(sx,sy,sz)
            end
            return true
        end
    end
end

local ExchangeWithOceanTerror = nil
local function IA_ExchangeWithOceanTerror(inst, ...)
    return ExchangeWithSwimmingTerror(inst) or ExchangeWithOceanTerror(inst, ...)
end

local ExchangeWithTerrorBeak = nil
local function IA_ExchangeWithTerrorBeak(inst, ...)
    return ExchangeWithSwimmingTerror(inst) or ExchangeWithTerrorBeak(inst, ...)
end

local function fn(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    if inst.ExchangeWithOceanTerror then
        if not ExchangeWithOceanTerror then
            ExchangeWithOceanTerror = inst.ExchangeWithOceanTerror
        end
        inst.ExchangeWithOceanTerror = IA_ExchangeWithOceanTerror
    end

    if inst.ExchangeWithTerrorBeak then
        if not ExchangeWithTerrorBeak then
            ExchangeWithTerrorBeak = inst.ExchangeWithTerrorBeak
        end
        inst.ExchangeWithTerrorBeak = IA_ExchangeWithTerrorBeak
    end
end

IAENV.AddPrefabPostInit("terrorbeak", fn)
IAENV.AddPrefabPostInit("oceanhorror", fn)

local crawlinghorror_ExchangeWithOceanTerror
local function crawlinghorror_IA_ExchangeWithOceanTerror(inst, ...)
    return ExchangeWithSwimmingTerror(inst) or crawlinghorror_ExchangeWithOceanTerror and crawlinghorror_ExchangeWithOceanTerror(inst, ...)
end

local function crawlinghorror_fn(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    inst.followtoboat = true

    if inst.ExchangeWithOceanTerror and not crawlinghorror_ExchangeWithOceanTerror then
        crawlinghorror_ExchangeWithOceanTerror = inst.ExchangeWithOceanTerror
    end
    inst.ExchangeWithOceanTerror = crawlinghorror_IA_ExchangeWithOceanTerror
end


IAENV.AddPrefabPostInit("crawlinghorror", crawlinghorror_fn)