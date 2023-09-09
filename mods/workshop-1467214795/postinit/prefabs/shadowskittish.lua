local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local function SetType(inst)
    if IsInIAClimate(inst) and IsOnOcean(inst) then
        inst.AnimState:SetBank("blobbyshadow")
        inst.AnimState:SetBuild("shadow_skittish_ocean")
    end
end

IAENV.AddPrefabPostInit("shadowskittish", function(inst)
    inst:DoTaskInTime(0, SetType)
end)
