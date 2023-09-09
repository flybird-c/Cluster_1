local IAENV = env
GLOBAL.setfenv(1, GLOBAL)
----------------------------------------------------------------------------------------

-- this sucks but idc
local canmorph = nil
local triggernearbymorph = nil
local FINDGRASSGEKKO_MUST_TAGS = { "grassgekko" }
local function onmorphtimer(inst, data)
    local morphing = data.name == "morphing"
    if morphing or data.name == "morphrelay" then
        if morphing and canmorph(inst) then
            local x, y, z = inst.Transform:GetWorldPosition()
            if #TheSim:FindEntities(x, y, z, TUNING.GRASSGEKKO_DENSITY_RANGE, FINDGRASSGEKKO_MUST_TAGS) < TUNING.GRASSGEKKO_MAX_DENSITY then
                local gekko = SpawnPrefab("grassgekko")
                if gekko.components.visualvariant ~= nil then
                    gekko.components.visualvariant:CopyOf(inst)
                end
                gekko.Transform:SetPosition(x, y, z)
                gekko.sg:GoToState("emerge")

                local partfx = SpawnPrefab("grasspartfx")
                if partfx.components.visualvariant ~= nil then
                    partfx.components.visualvariant:CopyOf(inst)
                end
                partfx.Transform:SetPosition(x, y, z)
                partfx.Transform:SetRotation(inst.Transform:GetRotation())
                partfx.AnimState:SetMultColour(inst.AnimState:GetMultColour())

                triggernearbymorph(inst, false)
                inst:Remove()
                return
            end
        end
        inst.components.worldsettingstimer:StartTimer("morphdelay", GetRandomWithVariance(TUNING.GRASSGEKKO_MORPH_DELAY, TUNING.GRASSGEKKO_MORPH_DELAY_VARIANCE))
        triggernearbymorph(inst, false)
    end
end

local function fn(inst)
	inst:DoTaskInTime(0, function(inst)
        if inst:IsValid() and inst:HasTag("renewable") and IsInClimate(inst, "volcano") then
            inst:RemoveTag("renewable")
        end
    end)

    
    if not TheWorld.ismastersim then
        return inst
    end

    if not triggernearbymorph and inst.components.pickable ~= nil and inst.components.pickable.ontransplantfn ~= nil then
        triggernearbymorph = UpvalueHacker.GetUpvalue(inst.components.pickable.ontransplantfn, "makemorphable", "onmorphtimer", "triggernearbymorph")
        canmorph = UpvalueHacker.GetUpvalue(inst.components.pickable.ontransplantfn, "makemorphable", "onmorphtimer", "canmorph")
        UpvalueHacker.SetUpvalue(inst.components.pickable.ontransplantfn, onmorphtimer, "makemorphable", "onmorphtimer")
    end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("grass", fn)
