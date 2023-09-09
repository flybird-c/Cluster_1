local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local Spell = require("components/spell")

local _OnSave = Spell.OnSave

function Spell:OnSave(...)
	local ret = {_OnSave(self, ...)} --ret[1] == data

	if self.target ~= nil and self.target.components.trophyscale then --Hornet: We need OnTarget to run again onload for the rainbow jellyfish in fish tanks
		return ret[1], { self.target.GUID }
	end

    return unpack(ret)
end