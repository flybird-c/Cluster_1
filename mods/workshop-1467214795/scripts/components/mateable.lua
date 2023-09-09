
local Mateable = Class(function(self, inst)
	self.inst = inst
	self.onmate = nil
	self.partnerGUID = nil
	self.doesdance = nil
end)

function Mateable:OnSave()
	if self.partnerGUID then
		local t = {
			partnerGUID = self.partnerGUID,
		}
		return t, t
	end
end

function Mateable:OnLoadPostPass(newents, data)
	self.partnerGUID = data.partnerGUID
	if self.partnerGUID then
		if TheWorld.components.doydoyspawner then
			TheWorld.components.doydoyspawner:RequestMate(self.inst, newents[self.partnerGUID])
		end
	end
end

local nomatingtags = {
	"baby", "teen", "mating", "doydoynest", "insprungtrap",
}

function Mateable:CanMate()

	if not TheWorld.state.isday then
		return false
	end

	-- Offscreen doys cannot mate, apparently
	-- Perhaps we could modify this so they skip the state and just spawn a baby if either is asleep -M
	if self.inst:IsAsleep() then
		return false
	end

	for _, tag in pairs(nomatingtags) do
		if self.inst:HasTag(tag) then
			return false
		end
	end

	if self.inst.components.inventoryitem:IsHeld() then
		return false
	end

	if self.inst.components.sleeper:IsAsleep() then
		return false
	end

	return true
end

function Mateable:SetOnMateCallback(onmate)
	self.onmate = onmate
end

function Mateable:SetPartner(partner, doesdance)
	self.partnerGUID = partner.GUID

	if doesdance then
		self.doesdance = true
	else
		self.doesdance = false
	end

	self.inst:AddTag("mating")
end

function Mateable:StopMating()

	-- if self.inst:HasTag("daddy") then
		-- self.inst:RemoveTag("daddy")

		-- local mommy = self:GetPartner()

		-- if mommy then
			-- mommy.components.mateable:RemovePartner()
		-- end

	-- else
		-- self.inst:RemoveTag("mommy")
	-- end
	
	self.inst:RemoveTag("mating")
	self.doesdance = nil
	self.partnerGUID = nil
end

function Mateable:GetPartner()
	return Ents[self.partnerGUID]
end
function Mateable:PartnerValid()
	return Ents[self.partnerGUID] and Ents[self.partnerGUID]:IsValid()
end

function Mateable:Mate()
	
	local partner = Ents[self.partnerGUID]
	
	if self.onmate then
		self.onmate(self.inst, partner)
	end
	
	if partner then
		partner:PushEvent("mateisdone", {mate = self.inst})
	end
	
	self:StopMating()
end

function Mateable:GetDebugString()
	return "Partner: "..tostring(self:GetPartner())..", "..tostring(self.partnerGUID)
end

return Mateable
