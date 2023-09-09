local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local animdata = {
	bankgust = "sapling_floating",
	bankidle = "sapling",
}

local function saplingfn(inst)
	if TheWorld.ismastersim then
		MakePickableBlowInWindGust(inst, TUNING.SAPLING_WINDBLOWN_SPEED, TUNING.SAPLING_WINDBLOWN_FALL_CHANCE, animdata)	
	end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("sapling", saplingfn)
IAENV.AddPrefabPostInit("sapling_moon", saplingfn)
