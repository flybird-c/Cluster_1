--[WARNING]: This file is imported into modclientmain.lua, be careful!

local IAENV = env
local AddPrefabPostInit = AddPrefabPostInit
GLOBAL.setfenv(1, GLOBAL)

local _basic_init_fn = basic_init_fn
function basic_init_fn(inst, build_name, def_build, ...)
    if inst and inst.components.visualvariant then
        inst.components.visualvariant:Set()
    end
    return _basic_init_fn(inst, build_name, def_build, ...)
end

local _glasscutter_init_fn = glasscutter_init_fn
function glasscutter_init_fn(inst, build_name, ...)
    inst.components.symbolswapdata:SetData("swap_glasscutter", "swap_glasscutter", true)
    return _glasscutter_init_fn(inst, build_name, ...)
end

local _glasscutter_clear_fn = glasscutter_clear_fn
function glasscutter_clear_fn(inst, ...)
    inst.components.symbolswapdata:SetData("swap_glasscutter", "swap_glasscutter")
    return _glasscutter_clear_fn(inst, ...)
end

double_umbrellahat_init_fn  = function(inst, build_name) basic_init_fn(inst, build_name, "hat_double_umbrella") end
double_umbrellahat_clear_fn = function(inst) basic_clear_fn(inst, "hat_double_umbrella") end

gashat_init_fn  = function(inst, build_name) basic_init_fn(inst, build_name, "hat_gas") end
gashat_clear_fn = function(inst) basic_clear_fn(inst, "hat_gas") end

palmleaf_hut_init_fn  = function(inst, build_name) 
	if build_name == "ms_palmleaf_hut_cawnival" then
		if inst.shadow ~= nil then basic_init_fn(inst.shadow, build_name, "palmleaf_hut_shdw") end
		if not inst.components.placer then
			local skin_fx = SKIN_FX_PREFAB["siestahut_cawnival"]
			if skin_fx ~= nil and (skin_fx[1] ~= nil and skin_fx[1]:len() > 0 and skin_fx[1] or nil) ~= nil then
				inst:DoTaskInTime(1 + math.random() * 1.2, function()
					inst._vfx_fx_inst = SpawnPrefab(skin_fx[1])
					inst._vfx_fx_inst.entity:AddFollower()
					inst._vfx_fx_inst.entity:SetParent(inst.entity)
					inst._vfx_fx_inst.Follower:FollowSymbol(inst.GUID, "hut_body", -125, -75, 0)
				end)
			end
		end
	end
	basic_init_fn(inst, build_name, "palmleaf_hut")
 end
palmleaf_hut_clear_fn = function(inst)
	basic_clear_fn(inst, "palmleaf_hut")
	if inst._vfx_fx_inst ~= nil then
		inst._vfx_fx_inst:Remove()
		inst._vfx_fx_inst = nil
	end
	if inst.shadow ~= nil then 
		basic_clear_fn(inst.shadow, "palmleaf_hut_shdw")
	end	
end
palmleaf_hut_shadow_clear_fn = function(inst) basic_clear_fn(inst.shadow, "palmleaf_hut_shdw") end

ITEM_DISPLAY_BLACKLIST.ms_palmleaf_hut_cawnival_shdw = true	-- Hide shadow in menu

STRINGS.SKIN_NAMES.ms_double_umbrellahat_legacy			= "Beach Dumbrella"
STRINGS.SKIN_DESCRIPTIONS.ms_double_umbrellahat_legacy 	= "Protect your head and your hat from the elements at the same time with this beach dumbrella!"

STRINGS.SKIN_NAMES.ms_hat_gas_legacy 					= "Gas Mask"
STRINGS.SKIN_DESCRIPTIONS.ms_hat_gas_legacy 			= "Keep the good air in and the bad air out with this homemade air filter."

STRINGS.SKIN_NAMES.ms_palmleaf_hut_cawnival 			= "Cawnival Hut"
STRINGS.SKIN_DESCRIPTIONS.ms_palmleaf_hut_cawnival 		= "Don't let a rainy day at the Cawnival stop the fun!"

if IAENV.is_mim_enabled then return end --Stop here if MiM

RegisterInventoryItemAtlas("images/ia_skins.xml", "ms_double_umbrellahat_legacy.tex")
RegisterInventoryItemAtlas("images/ia_skins.xml", "ms_hat_gas_legacy.tex")
RegisterInventoryItemAtlas("images/ia_skins.xml", "ms_palmleaf_hut_cawnival.tex")

pcall(function()
	if RESKIN_FX_INFO then
		RESKIN_FX_INFO["palmleaf_hut"] = {offset = 0, scale = 1.7}
	end
end)

local function OnEquip(inst, data)
	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil and skin_build == "ms_hat_gas_legacy" then
		-- or use fullhelm_onequip() in hats.lua
		data.owner.AnimState:Hide("HAIR_PIGTAILS")
		data.owner.AnimState:Hide("HEAD_HAT")
	end
end

local function OnUnequip(inst, data)
	local skin_build = inst:GetSkinBuild()
	if skin_build ~= nil and skin_build == "ms_hat_gas_legacy" then
		data.owner.AnimState:Show("HAIR_PIGTAILS")
	end
end

AddPrefabPostInit("gashat", function(inst)
	if not TheWorld.ismastersim then return end
	
	inst:ListenForEvent("equipped", OnEquip)
	inst:ListenForEvent("unequipped", OnUnequip)
end)

--machete_init_fn = function(inst, build_name) basic_init_fn( inst, build_name, "machete" ) end
--machete_clear_fn = function(inst) basic_clear_fn(inst, "machete" ) end