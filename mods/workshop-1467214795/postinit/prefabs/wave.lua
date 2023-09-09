local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("wave_med", function(inst)
	inst.Physics:SetCollisionCallback(CollideWithWave)
    inst.DoSplash = DoWaveSplash
end)