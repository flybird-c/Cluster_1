local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local _onequipfn
local function onequipfn(self, owner)
    if owner and owner.sg and owner.sg:HasStateTag("rowing") then return end
	return _onequipfn(self, owner)
end
	
local function startrowing(self,data)
	self.components.equippable.onunequipfn(self, data and data.owner or nil)
	if self.components.inventoryitem.onputininventoryfn then --this should be "turnoff"
		self.components.inventoryitem.onputininventoryfn(self, data and data.owner or nil)
	end
end
local function stoprowing(self,data)
	self.components.equippable.onequipfn(self, data and data.owner or nil)
end

local function postinitfn(inst)
    if TheWorld.ismastersim then
        _onequipfn = inst.components.equippable.onequipfn
        inst.components.equippable.onequipfn = onequipfn
        
        inst:ListenForEvent("startrowing", startrowing)
        inst:ListenForEvent("stoprowing", stoprowing)
    end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("torch", postinitfn)
IAENV.AddPrefabPostInit("redlantern", postinitfn)
