--[WARNING]: This file is imported into modclientmain.lua for MiM, be careful!
local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

--SetSkinsOnAnim
local skinmonkey_pieces = {
	leg = {"lowerleg", "upperleg"},
	arm_lower = {"lowerarm"},
	torso = {"upperbody", "lowerbody"},
	torso_pelvis = {},
	-- looks bad
	-- foot = {"monkey_foot"},
	-- hand = {"monkey_hand"},
}

local disabledlayers = {
	"skinmonkey_foot",
	"skinmonkey_hand",
}

local monkey_pieces = {
	"foot",
	"hand",
	"tail"
}

-- Use require here to make sure the global SetSkinsOnAnim has been set
local Skinner = require("components/skinner")

local _SetSkinsOnAnim = SetSkinsOnAnim
function SetSkinsOnAnim(anim_state, prefab, base_skin, clothing_names, monkey_curse, skintype, default_build, ...)
	if prefab ~= "wilbur" then
		return _SetSkinsOnAnim(anim_state, prefab, base_skin, clothing_names, monkey_curse, skintype, default_build, ...)
	end

	for _, layer in pairs(disabledlayers) do
		anim_state:Hide(layer)
	end

	for skin_layer, monkey_layers in pairs(skinmonkey_pieces) do
		anim_state:Hide("skinmonkey_" .. skin_layer)
		for _, monkey_layer in pairs(monkey_layers) do
			anim_state:Show("monkey_" .. monkey_layer)
		end
	end

	local _OverrideSkinSymbol = AnimState.OverrideSkinSymbol
	function AnimState:OverrideSkinSymbol(sym, sym_build, ...)
		local monkey_layers = skinmonkey_pieces[sym]
		if self == anim_state and monkey_layers ~= nil then
			anim_state:Show("skinmonkey_" .. sym)
			for _, monkey_layer in pairs(monkey_layers) do
				anim_state:Hide("monkey_" .. monkey_layer)
			end
		end
		return _OverrideSkinSymbol(self, sym, sym_build, ...)
	end

	local rets = {_SetSkinsOnAnim(anim_state, prefab, base_skin, clothing_names, monkey_curse, skintype, default_build, ...)}

	AnimState.OverrideSkinSymbol = _OverrideSkinSymbol

	for _, sym in pairs(monkey_pieces) do
		anim_state:ShowSymbol(sym)
		anim_state:OverrideSymbol(sym, default_build or "wilbur", sym)
	end

	return unpack(rets)
end

if IAENV.is_mim_enabled then return end --Stop here if MiM

----------------------------------------------------------------------------------------

local sailface = {
	wilson = {
		wilson_none = "wilson_none",
		wilson_ice = "wilson_ice",
		wilson_magma = "wilson_magma",
		wilson_pigguard = "wilson_pigguard", --Event version
		wilson_pigguard_d = "wilson_pigguard", --"real" version
		wilson_shadow = "wilson_shadow",
		wilson_survivor = "wilson_survivor",
		wilson_victorian = "wilson_victorian",
	},
	willow = {
		willow_none = "willow_none",
		willow_ice = "willow_ice",
		willow_magma = "willow_magma",
		willow_victorian = "willow_victorian",
	},
	wolfgang = {
		wolfgang_none = {
			wimpy = "wolfgang_none_wimpy",
			normal = "wolfgang_none_normal",
			mighty = "wolfgang_none_mighty",
		},
		wolfgang_combatant = {
			wimpy = "wolfgang_combatant_wimpy",
			normal = "wolfgang_combatant",
			mighty = "wolfgang_combatant_mighty",
		},
		wolfgang_formal = {
			wimpy = "wolfgang_none_wimpy", --formal wimpy is normal wimpy
			normal = "wolfgang_formal",
			mighty = "wolfgang_formal_mighty",
		},
		wolfgang_gladiator = {
			wimpy = "wolfgang_gladiator_wimpy",
			normal = "wolfgang_gladiator",
			mighty = "wolfgang_gladiator_mighty",
		},
		wolfgang_ice = {
			wimpy = "wolfgang_ice_wimpy",
			normal = "wolfgang_ice",
			mighty = "wolfgang_ice_mighty",
		},
		wolfgang_magma = {
			wimpy = "wolfgang_magma_wimpy",
			normal = "wolfgang_magma",
			mighty = "wolfgang_magma_mighty",
		},
		wolfgang_rose = {
			wimpy = "wolfgang_rose_wimpy",
			normal = "wolfgang_rose",
			mighty = "wolfgang_rose_mighty",
		},
		wolfgang_shadow = {
			wimpy = "wolfgang_shadow_wimpy",
			normal = "wolfgang_shadow",
			mighty = "wolfgang_shadow_mighty",
		},
		wolfgang_survivor = {
			wimpy = "wolfgang_survivor_wimpy",
			normal = "wolfgang_survivor",
			mighty = "wolfgang_survivor_mighty",
		},
		wolfgang_victorian = {
			wimpy = "wolfgang_victorian_wimpy",
			normal = "wolfgang_victorian",
			mighty = "wolfgang_victorian_mighty",
		},
		wolfgang_walrus = { --Event version
			wimpy = "wolfgang_walrus_wimpy",
			normal = "wolfgang_walrus",
			mighty = "wolfgang_walrus_mighty",
		},
		wolfgang_walrus_d = { --"real" version
			wimpy = "wolfgang_walrus_wimpy",
			normal = "wolfgang_walrus",
			mighty = "wolfgang_walrus_mighty",
		},
		wolfgang_wrestler = {
			wimpy = "wolfgang_wrestler_wimpy",
			normal = "wolfgang_wrestler",
			mighty = "wolfgang_wrestler_mighty",
		},
	},
	wendy = {
		wendy_none = "wendy_none",
		wendy_formal = "wendy_formal",
		wendy_ice = "wendy_ice",
		wendy_magma = "wendy_magma",
	},
	wx78 = {
		wx78_none = "wx78_none",
		wx78_formal = "wx78_formal",
		wx78_gladiator = "wx78_gladiator",
		wx78_magma = "wx78_magma",
		wx78_nature = "wx78_nature",
		wx78_rhinorook = "wx78_rhinorook", --Event version
		wx78_rhinorook_d = "wx78_rhinorook", --"real" version
		wx78_victorian = "wx78_victorian",
		wx78_wip = "wx78_wip",
	},
	wickerbottom = {
		wickerbottom_none = "wickerbottom_none",
		wickerbottom_combatant = "wickerbottom_combatant",
		wickerbottom_formal = "wickerbottom_formal",
		wickerbottom_gladiator = "wickerbottom_gladiator",
		wickerbottom_ice = "wickerbottom_ice",
		wickerbottom_lightninggoat = "wickerbottom_lightninggoat", --Event version
		wickerbottom_lightninggoat_d = "wickerbottom_lightninggoat", --"real" version
		wickerbottom_magma = "wickerbottom_magma",
		wickerbottom_rose = "wickerbottom_rose",
		wickerbottom_shadow = "wickerbottom_shadow",
		wickerbottom_survivor = "wickerbottom_survivor",
		wickerbottom_victorian = "wickerbottom_victorian",
	},
	woodie = {
		woodie_none = "woodie_none",
		woodie_combatant = "woodie_combatant",
		woodie_gladiator = "woodie_gladiator",
		-- woodie_magma = "woodie_magma",
		woodie_survivor = "woodie_survivor",
	},
	wes = {
		wes_none = "wes_none",
		wes_combatant = "wes_combatant",
		wes_gladiator = "wes_gladiator",
		wes_magma = "wes_magma",
		wes_mandrake = "wes_mandrake", --Event version
		wes_mandrake_d = "wes_mandrake", --"real" version
		wes_nature = "wes_nature",
		wes_rose = "wes_rose",
		wes_shadow = "wes_shadow",
		wes_survivor = "wes_survivor",
		wes_victorian = "wes_victorian",
		wes_wrestler = "wes_wrestler",
	},
	waxwell = {
		waxwell_none = "waxwell_none",
		waxwell_combatant = "waxwell_combatant",
		waxwell_formal = "waxwell_formal",
		waxwell_gladiator = "waxwell_gladiator",
		waxwell_krampus = "waxwell_krampus", --Event version
		waxwell_krampus_d = "waxwell_krampus", --"real" version
		waxwell_magma = "waxwell_magma",
		waxwell_nature = "waxwell_nature",
		waxwell_survivor = "waxwell_survivor",
		waxwell_unshadow = "waxwell_unshadow",
		waxwell_victorian = "waxwell_victorian",
	},
	wathgrithr = {
		wathgrithr_none = "wathgrithr_none",
		wathgrithr_combatant = "wathgrithr_combatant",
		wathgrithr_cook = "wathgrithr_cook",
		wathgrithr_deerclops = "wathgrithr_deerclops", --Event version
		wathgrithr_deerclops_d = "wathgrithr_deerclops", --"real" version
		wathgrithr_gladiator = "wathgrithr_gladiator",
		wathgrithr_nature = "wathgrithr_nature",
		wathgrithr_survivor = "wathgrithr_survivor",
		wathgrithr_wrestler = "wathgrithr_wrestler",
	},
	webber = {
		webber_none = "webber_none",
		webber_bat = "webber_bat", --Event version
		webber_bat_d = "webber_bat", --"real" version
		webber_ice = "webber_ice",
		webber_magma = "webber_magma",
		webber_victorian = "webber_victorian",
	},
	winona = {
		winona_none = "winona_none",
		winona_combatant = "winona_combatant",
		winona_formal = "winona_formal", --Heirloom version
		winona_formalp = "winona_formal", --"real" version
		winona_gladiator = "winona_gladiator",
		winona_grassgecko = "winona_grassgecko", --Event version
		winona_grassgecko_d = "winona_grassgecko", --"real" version
		winona_magma = "winona_magma",
		winona_rose = "winona_rose", --Heirloom version
		winona_rosep = "winona_rose", --"real" version
		winona_shadow = "winona_shadow", --Heirloom version
		winona_shadowp = "winona_shadow", --"real" version
		winona_survivor = "winona_survivor", --Heirloom version
		winona_survivorp = "winona_survivor", --"real" version
		winona_victorian = "winona_victorian",
	},
	wortox = {
		wortox_none = "wortox_none",
		wortox_minotaur = "wortox_minotaur",
		wortox_original = "wortox_original",
		wortox_survivor = "wortox_survivor",
	},
	wormwood = {
		wormwood_none = "wormwood_none",
	},
	warly = {
		warly_none = "warly_none",
	},
}

local _SetSkinMode = Skinner.SetSkinMode
function Skinner:SetSkinMode(skintype, default_build, ...)
	_SetSkinMode(self, skintype, default_build, ...)

    local skinname = self.skin_name
    local skin_type = self.skintype or ""

    if not skinname or skinname == "" then skinname = self.inst.prefab .."_none" end

    local face = sailface[self.inst.prefab] and sailface[self.inst.prefab][skinname] --or sailface[self.inst.prefab][self.inst.prefab .."_none"] --instead face is nil making the sailfaceless anim play

	if not face then
		self.inst.has_sailface = CUSTOM_CHARACTER_SAILFACES[self.inst.prefab] and CUSTOM_CHARACTER_SAILFACES[self.inst.prefab][skinname] --if someone adds there custom character to this list use the normal sailface anim (for people who made custom sailfaces)
		return
	end

    if self.inst.prefab == "wolfgang" then face = face[skin_type:find("wimpy") and "wimpy" or skin_type:find("mighty") and "mighty" or "normal"] end

    -- print("SETTING SAILFACE", skinname, self.skin_name, face)
    self.inst.AnimState:OverrideSymbol("face_sail", "swap_sailface", face)
	self.inst.has_sailface = true
end

--for debug testing, enable this code:
-- local char_prefab = nil
-- _G.sface = "wilson_none" --set this via console
-- IAENV.AddClassPostConstruct("widgets/skinspuppet", function(inst)
	-- local SetSkins_old = inst.SetSkins
	-- function inst:SetSkins(character, ...)
		-- char_prefab = character
		-- SetSkins_old(self, character, ...)
	-- end

	-- function inst:DoEmote()
		-- self.animstate:SetBank("wilson")
		-- self.animstate:OverrideSymbol("face_sail", "swap_sailface", _G.sface)
		-- self.animstate:PlayAnimation("sail_pre", false)
		-- self.animstate:PushAnimation("sail_loop", false)
		-- self.animstate:PushAnimation("sail_loop", false)
		-- self.animstate:PushAnimation("sail_loop", false)
		-- self.animstate:PushAnimation("sail_pst", false)
		-- -- self.looping = true
	-- end
-- end)
