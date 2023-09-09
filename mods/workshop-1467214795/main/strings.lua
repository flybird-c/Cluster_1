--[WARNING]: This file is imported into modclientmain.lua for MiM, be careful!
local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

-- The actual strings are located in island_adventures/strings/common.lua
-- Note to translators: Update the POT file using IA_makePOT() in the in-game console if we forget to

-- Update this list when adding files
local _speech = {
	"generic",
	"willow",
	"wolfgang",
	"wendy",
	"wx78",
	"wickerbottom",
	"woodie",
	--"wes",
	"waxwell",
	"wathgrithr",
	"webber",
	"winona",
	"wortox",
	"wormwood",
	"warly",
	"wurt",
	"walter",
	"wanda",
}

local _newspeech = {
	"walani",
	"wilbur",
	"woodlegs",
}

local _generate_whitelist = {
    "wilbur",
}

local _languages = {
	de = "de", --german
	es = "es", --spanish
	fr = "fr", --french
	it = "it", --italian
	ko = "ko", --korean
	--Note: The only language mod I found that uses "pt" is also brazilian portuguese -M
	pt = "pt", --portuguese
	br = "pt", --brazilian portuguese
	pl = "pl", --polish
	ru = "ru", --russian
	zh = "sc", --chinese
	chs = "sc", --chinese mod
	sc = "sc", --simple chinese
	tc = "tc", --traditional chinese
	cht = "tc", --chinese mod
}

local function merge(target, new, soft)
	if not target then
		target = {}
	end

	for k, v in pairs(new) do
		if type(v) == "table" then
			target[k] = type(target[k]) == "table" and target[k] or {}
			merge(target[k], v)
		else
			if target[k] then
				if soft then
					-- print("couldn't add " ..  k, " (already is \"" ..  target[k]  .. "\")")
				else
					-- print("replacing " ..  k, " (with \"" ..  v  .. "\")")
					target[k] = v
				end
			else
				target[k] = v
			end
		end
	end
	return target
end

-- Install our crazy loader!
local function import(modulename)
	print("modimport (strings file): " .. IAENV.MODROOT .. "strings/" .. modulename)
	-- if string.sub(modulename, #modulename-3,#modulename) ~= ".lua" then
		-- modulename = modulename .. ".lua"
	-- end
	local result = kleiloadlua(IAENV.MODROOT .. "strings/" .. modulename)
	if result == nil then
		error("Error in custom import: Stringsfile " .. modulename .. " not found!")
	elseif type(result) == "string" then
		error("Error in custom import: Island Adventures importing strings/" .. modulename .. "!\n" .. result)
	else
		setfenv(result, IAENV) -- in case we use mod data
		return result()
	end
end

merge(STRINGS, import("common.lua"))

-- add these strings properly
for _,v in pairs(STRINGS.UI.WORLDGEN_IA.VERBS) do
	table.insert(STRINGS.UI.WORLDGEN.VERBS, v)
end
for _,v in pairs(STRINGS.UI.WORLDGEN_IA.NOUNS) do
	table.insert(STRINGS.UI.WORLDGEN.NOUNS, v)
end

local function GetAllStrings(lst, obj)
    if type(obj) ~= "table" then
        lst[obj] = true
    else
        for _,v in pairs(obj) do
            GetAllStrings(lst, v)
        end
    end
end

local function GenerateWhitelist(stringtable)
    local strings = {}
    GetAllStrings(strings, stringtable)
    stringtable._WHITELIST = strings
end

local IsTheFrontEnd = rawget(_G, "TheFrontEnd") and rawget(_G, "IsInFrontEnd") and IsInFrontEnd()

if not IsTheFrontEnd then
    -- add character speech
    for _,v in pairs(_speech) do
    	merge(STRINGS.CHARACTERS[string.upper(v)], import(v .. ".lua"))
    end
    for _,v in pairs(_newspeech) do
    	STRINGS.CHARACTERS[string.upper(v)] = import(v .. ".lua")
    end

    for _,v in pairs(_generate_whitelist) do
        GenerateWhitelist(STRINGS.CHARACTERS[string.upper(v)])
    end
end

-- local function printIfMissing(tia, tv, stack)
	-- for k,v in pairs(tia) do
		-- if not tv[k] then
			-- print(stack .. "." .. tostring(k))
		-- elseif type(v) ~= type(tv[k]) then
			-- print("WRONG TYPE!",stack .. "." .. tostring(k))
		-- elseif type(v) == "table" then
			-- printIfMissing(v,tv[k],stack .. "." .. tostring(k))
		-- end
	-- end
-- end
-- printIfMissing(import("warly.lua"),STRINGS.CHARACTERS.WARLY,"WARLY")


local retrofitkeys = {
	LOGRAFT = "BOAT_LOGRAFT",
	RAFT = "BOAT_RAFT",
	ROWBOAT = "BOAT_ROW",
	CARGOBOAT = "BOAT_CARGO",
	ARMOUREDBOAT = "BOAT_ARMOURED",
	ENCRUSTEDBOAT = "BOAT_ENCRUSTED",
	SAIL = "SAIL_PALM",
	FEATHERSAIL = "SAIL_FEATHER",
	CLOTHSAIL = "SAIL_CLOTH",
	SNAKESKINSAIL = "SAIL_SNAKESKIN",
	WRECK = "SHIPWRECK",
	SANDHILL = "SANDDUNE",
	LIMESTONE = "LIMESTONENUGGET",
	REDBARREL = "BARREL_GUNPOWDER",
	TREEGUARD = "LEIF_PALM",
	FISH_RAW_SMALL = "FISH_SMALL",
	TROPICAL_FISH = "FISH_TROPICAL",
	DEAD_SWORDFISH = "SWORDFISH_DEAD",
	RESEARCHLAB5 = "SEA_LAB",
}

IAENV.AddGamePostInit(function()
	-- Retrofit mod character speech
	for wilson, speech in pairs(STRINGS.CHARACTERS) do
		if speech.DESCRIBE then
			for oldkey, newkey in pairs(retrofitkeys) do
				if not speech.DESCRIBE[newkey] then
					speech.DESCRIBE[newkey] = speech.DESCRIBE[oldkey]
				end
			end
			--trinkets are a special case, 13-23 is used for different trinkets in DST
			if speech.DESCRIBE.TRINKET_13 and not speech.DESCRIBE.TRINKET_24 then
				for i = 13, 23 do
					speech.DESCRIBE["TRINKET_IA_" .. tostring(i)] =
						speech.DESCRIBE["TRINKET_IA_" .. tostring(i)]
						or speech.DESCRIBE["TRINKET_" .. tostring(i)]
				end
			end
		end
		--special cases
		if speech.ACTION_FAIL and not speech.ACTION_FAIL.INSPECTBOAT then
			speech.ACTION_FAIL.INSPECTBOAT = speech.ACTION_FAIL.STORE
		end
	end
end)


-- TRANSLATIONS --
local function ConvertEscapeCharactersToString(str)
	local newstr = string.gsub(str, "\n", "\\n")
	newstr = string.gsub(newstr, "\r", "\\r")
	newstr = string.gsub(newstr, "\"", "\\\"")

	return newstr
end

local function flattenStringsTable(src, root, target)
	assert(type(src) == "table", "flattenStringsTable requires a table to flatten!")
	root = root or ""
	target = target or {}
	for k, v in pairs(src) do
		if type(v) == "table" then
			flattenStringsTable(v, root .. k .. ".", target)
		else
			--TODO special exception for worldgen flavour strings?
				--increment k by the number of vanilla strings
			target[root .. k] = ConvertEscapeCharactersToString(tostring(v))
		end
	end
	return target
end

IA_makePOT = function()
	--create the file
	local file, errormsg = io.open(IAENV.MODROOT  ..  "languages/strings.pot", "w")
	if not file then print("FAILED TO GENERATE .POT:\n" ..  tostring(errormsg)) return end

	--write header
	file:write('#. Note to translators: Update the POT file using IA_makePOT() in the in-game console if we forget to\n')
	file:write('msgid ""\n')
	file:write('msgstr ""\n')
	file:write('"Application: Don\'t Starve\\n"\n')
	file:write('"POT Version: 2.0\\n"\n\n')

	--gather all the strings
	local _strings = flattenStringsTable(import("common.lua"), "STRINGS.")
	for _,v in pairs(_speech) do
		flattenStringsTable(import(v .. ".lua"), "STRINGS.CHARACTERS." .. string.upper(v) .. ".", _strings)
	end
	for _,v in pairs(_newspeech) do
		flattenStringsTable(import(v .. ".lua"), "STRINGS.CHARACTERS." .. string.upper(v) .. ".", _strings)
	end

	--write all the strings
	for k, v in pairs(_strings) do
		file:write('#. ' .. k .. "\n")
		file:write('msgctxt "' .. k .. '"\n')
		file:write('msgid "' .. v .. '"\n')
		file:write('msgstr ""\n\n')
	end

	--done
	file:close()
end


IA_makePOfromLua = function(lang)
	--create the file
	local file, errormsg = io.open(IAENV  ..  "strings/temp/new_" .. lang .. ".po", "w")
	if not file then print("FAILED TO GENERATE .PO:\n" ..  tostring(errormsg)) return end

	--write header
	file:write('msgid ""\n')
	file:write('msgstr ""\n')
	file:write('"Language: ia_' .. lang .. '\n"\n')
	file:write('"Content-Type: text/plain; charset=utf-8\n"\n')
	file:write('"Content-Transfer-Encoding: 8bit\n"\n')
	file:write('"POT Version: 2.0\\n"\n\n')

	--gather and write all the strings
	local _strings = flattenStringsTable(import("temp/strings_" .. lang .. ".lua"), "STRINGS.")
	for k, v in pairs(_strings) do
		file:write('#. ' .. k .. "\n")
		file:write('msgctxt "' .. k .. '"\n')
		file:write('msgid "' .. v .. '"\n') -- could extract original string using k
		file:write('msgstr "' .. v .. '"\n\n')
	end
	-- loaded by strings.lua
	-- for _,v in pairs(_speech) do
		-- _strings = flattenStringsTable(import("temp/speech_" .. (v == "generic" and "wilson" or v) .. ".lua"), "STRINGS.CHARACTERS." .. string.upper(v) .. ".")
		-- for k, v in pairs(_strings) do
			-- file:write('#. ' .. k .. "\n")
			-- file:write('msgctxt "' .. k .. '"\n')
			-- file:write('msgid "' .. v .. '"\n')
			-- file:write('msgstr "' .. v .. '"\n\n')
		-- end
	-- end
	for _,v in pairs(_newspeech) do
		_strings = flattenStringsTable(import("temp/speech_" .. v .. "_" .. lang .. ".lua"), "STRINGS.CHARACTERS." .. string.upper(v) .. ".")
		for k, v in pairs(_strings) do
			file:write('#. ' .. k .. "\n")
			file:write('msgctxt "' .. k .. '"\n')
			file:write('msgid "' .. v .. '"\n')
			file:write('msgstr "' .. v .. '"\n\n')
		end
	end

	--done
	file:close()
end

require("translator")


--hook this for translation mods
local LoadPOFile_old = LanguageTranslator.LoadPOFile
LanguageTranslator.LoadPOFile = function(self, fname, lang)
	LoadPOFile_old(self, fname, lang)
	if _languages[lang] then
		local _defaultlang = self.defaultlang
		-- Translator doesn't let us append existing languages
		-- instead we make "new" languages, then manually merge them into the actual language data
		self:LoadPOFile("languages/ia_" .. _languages[lang] .. ".po", lang .. "_TEMP")
		merge(
			self.languages[lang],
			self.languages[lang .. "_TEMP"],
			true
		)
		self.languages[lang .. "_TEMP"] = nil

		self.defaultlang = _defaultlang
	end
end

--apply force settings and detect official translations

local desiredlang = nil
local IA_CONFIG = rawget(_G, "IA_CONFIG")
if IA_CONFIG and IA_CONFIG.locale then
	desiredlang = IA_CONFIG.locale
--only use default in FrontEnd or if locale is not set
elseif (IsTheFrontEnd or IA_CONFIG) and LanguageTranslator.defaultlang then
	desiredlang = LanguageTranslator.defaultlang
end

if desiredlang and _languages[desiredlang] then
	-- This only runs once. In order to make it last after loading other POs, adjust LoadPOFile to use IA_CONFIG. -M
	local _defaultlang = LanguageTranslator.defaultlang
	LanguageTranslator:LoadPOFile("languages/ia_" .. _languages[desiredlang] .. ".po", desiredlang .. "_TEMP")
	if _defaultlang then
		merge(LanguageTranslator.languages[_defaultlang], LanguageTranslator.languages[desiredlang .. "_TEMP"], true)
		LanguageTranslator.defaultlang = _defaultlang
	end
	TranslateStringTable(STRINGS)
	LanguageTranslator.languages[desiredlang .. "_TEMP"] = nil
	LanguageTranslator.defaultlang = _defaultlang
end
