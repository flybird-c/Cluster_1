local scrapbook_prefabs = require("scrapbook_prefabs")
local scrapbookdata = require("screens/redux/scrapbookdata")

local IA_SCRAPBOOK_DEFS = require("prefabs/ia_scrapbook_defs")

for k, v in pairs(IA_SCRAPBOOK_DEFS.ITEMS) do
	if v.anim ~= nil then
		v.name = v.name or k
		v.prefab = k
		v.tex = v.tex or k..".tex"
		v.type = v.type or "item"
		v.deps = v.deps or {}
		v.notes = v.notes or {}
		
		scrapbook_prefabs[k] = true
		scrapbookdata[k] = v
	end
end


for k, v in pairs(IA_SCRAPBOOK_DEFS.MOBS) do
	v.name = k
	v.prefab = k
	v.tex = k..".tex"
	v.type = v.type or "creature"
	v.deps = v.deps or {}
	v.notes = v.notes or {}
	
	scrapbook_prefabs[k] = true
	scrapbookdata[k] = v
end