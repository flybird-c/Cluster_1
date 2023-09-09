local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local _onequipfn
local function onequipfn(self, owner)
	if owner and owner.sg and owner.sg:HasStateTag("rowing") then return end
	return _onequipfn(self, owner)
end
local _ontakefuelfn
local function ontakefuelfn(self)
	local owner = self.components.inventoryitem.owner
	if owner and owner.sg and owner.sg:HasStateTag("rowing") then return end
	return _ontakefuelfn(self)
end
local _turnonfn
local function turnonfn(self)
	local owner = self.components.inventoryitem.owner
	if owner and owner.sg and owner.sg:HasStateTag("rowing") then
		self.components.machine.oncooldown = false
		self:DoTaskInTime(0,function() self.components.machine:TurnOff() end)
		return
	end
	return _turnonfn(self)
end
-- local _ondropfn
-- local function ondropfn(self)
	-- local owner = self.components.inventoryitem.owner
	-- if owner and owner.sg and owner.sg:HasStateTag("rowing") then return end
	-- return _ondropfn(self)
-- end
	
local function startrowing(self,data)
	self.components.equippable.onunequipfn(self, data and data.owner or nil)
	self.components.machine:TurnOff()
end
local function stoprowing(self,data)
	self.components.equippable.onequipfn(self, data and data.owner or nil)
	self.components.machine:TurnOn()
end


----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("lantern", function(inst)


if TheWorld.ismastersim then

	_onequipfn = inst.components.equippable.onequipfn
	inst.components.equippable.onequipfn = onequipfn
	_ontakefuelfn = inst.components.fueled.ontakefuelfn
	inst.components.fueled.ontakefuelfn = ontakefuelfn
	_turnonfn = inst.components.machine.turnonfn
	inst.components.machine.turnonfn = turnonfn
	-- _ondropfn = inst.components.inventoryitem.ondropfn
	-- inst.components.inventoryitem.ondropfn = ondropfn
	
	inst:ListenForEvent("startrowing", startrowing)
	inst:ListenForEvent("stoprowing", stoprowing)
	
end


end)
