local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

IAENV.AddPrefabPostInit("underwater_salvageable", function(inst)
    if TheWorld.has_ia_ocean then
    inst.AnimState:OverrideMultColour(0.75, 1, 1, 0.75)
    end
end)