local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local animdata = {
	bankgust = "grass_floating",
	bankidle = "grass",
}

local function grass_postinitfn(inst)
	if TheWorld.ismastersim then
		MakePickableBlowInWindGust(inst, TUNING.GRASS_WINDBLOWN_SPEED, TUNING.GRASS_WINDBLOWN_FALL_CHANCE, animdata)
	end
end

local function reeds_postinitfn(inst)
	if TheWorld.ismastersim then
		MakePickableBlowInWindGust(inst, TUNING.REEDS_WINDBLOWN_SPEED, TUNING.REEDS_WINDBLOWN_FALL_CHANCE, animdata)
	end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("grass", grass_postinitfn)
IAENV.AddPrefabPostInit("reeds", reeds_postinitfn)
IAENV.AddPrefabPostInit("monkeytail", reeds_postinitfn) --yes there technically "reeds"
