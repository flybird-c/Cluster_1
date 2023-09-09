local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local spec_meatrack_items = {
	fish_tropical = "tropical_fish",
	solofish_dead = "dogfish",
	swordfish_dead = "swordfish",
	--fish_med = "fish_raw",
	--fish_small = "fish_raw_small",
}
--NOTE: at some point rainbowjellyfish were updated to have a unique drying texture in sw -Half

local onstartdryingold
local function onstartdrying(inst, ingredient, buildfile)
	if spec_meatrack_items[ingredient] then
		ingredient = spec_meatrack_items[ingredient]
	end
	onstartdryingold(inst, ingredient, buildfile)
end

local ondonedryingold
local function ondonedrying(inst, product, buildfile)
	if spec_meatrack_items[product] then
		product = spec_meatrack_items[product]
	end
	ondonedryingold(inst, product, buildfile)
end

local getstatus
local function getstatus_ia(inst)
	local ret = getstatus(inst)
	if ret and IsInIAClimate(inst) then
		if ret:find("DRYINGINRAIN") then
			if not TheWorld.state.islandisraining then
				ret = ret:gsub("DRYINGINRAIN","DRYING")
			end
		elseif TheWorld.state.islandisraining then
			ret = ret:gsub("DRYING","DRYINGINRAIN")
		end
	end
	return ret
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("meatrack", function(inst)
	if TheWorld.ismastersim then
		if not onstartdryingold then
			onstartdryingold = inst.components.dryer.onstartdrying
		end
		inst.components.dryer:SetStartDryingFn(onstartdrying)
		if not ondonedryingold then
			ondonedryingold = inst.components.dryer.ondonedrying
		end
		inst.components.dryer:SetDoneDryingFn(ondonedrying)
		if not getstatus then
			getstatus = inst.components.inspectable.getstatus
		end
		inst.components.inspectable.getstatus = getstatus_ia
	end
end)
