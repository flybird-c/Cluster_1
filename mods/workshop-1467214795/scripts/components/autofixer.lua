local AutoFixer = Class(function(self, inst)
    self.inst = inst

    --V2C: Recommended to explicitly add tag to prefab pristine state
    inst:AddTag("autofixer")

    self.users = {}
    self.locked = false

    self.onremoveuser = function(user) self:TurnOff(user) end
	
	self.boatents = {}
	self._oldboatents = {}

	self.inst:StartUpdatingComponent(self)
end)

function AutoFixer:OnRemoveFromEntity()
    self.inst:RemoveTag("autofixer")
    for i, user in ipairs(self.users) do
        self.inst:RemoveEventCallback("onremove", self.onremoveuser, user)
        if self.stopfixing then
            self.stopfixing(self.inst, user)
        end        
    end
    self.users = nil
end

AutoFixer.OnRemoveEntity = AutoFixer.OnRemoveFromEntity

function AutoFixer:OnSave()
    return {locked = self.locked}
end

function AutoFixer:OnLoad(data)
    if data then
        self.locked = data.locked
    end
end

function AutoFixer:SetAutoFixUserTestFn(fn)
    self.autofixusertest = fn
end

function AutoFixer:SetCanTurnOnFn(fn)
    self.canturnon = fn
end

function AutoFixer:SetOnTurnOnFn(fn)
    self.onturnon = fn
end

function AutoFixer:SetOnTurnOffFn(fn)
    self.onturnoff = fn
end

function AutoFixer:SetStartFixingFn(fn)
    self.startfixing = fn
end

function AutoFixer:SetStopFixingFn(fn)
    self.stopfixing = fn
end

function AutoFixer:CanAutoFixUser(user)
    return not self.locked and (self.autofixusertest == nil or self.autofixusertest(self.inst, user))
end

function AutoFixer:TurnOn(user) 
    if not self.locked and (self.canturnon == nil or self.canturnon(self.inst)) then
        local _usercount = #self.users
        if not table.contains(self.users, user) then
            table.insert(self.users, user)
            self.inst:ListenForEvent("onremove", self.onremoveuser, user)
            if self.startfixing then
                self.startfixing(self.inst, user)
            end
        end
        if self.onturnon and _usercount == 0 and #self.users >= 1 then
            self.onturnon(self.inst)
        end
    end
end

function AutoFixer:TurnOff(user)
    if user == nil then
        local users = {}
        for i, v in ipairs(self.users) do
            users[i] = v
        end
        for i, v in ipairs(users) do
            self:TurnOff(v)
        end
        return
    end
    local _usercount = #self.users
    if table.contains(self.users, user) then
        table.removearrayvalue(self.users, user)
        self.inst:RemoveEventCallback("onremove", self.onremoveuser, user)
        if self.stopfixing then
            self.stopfixing(self.inst, user)
        end
    end
    if self.onturnoff and _usercount > 0 and #self.users <= 0 then
        self.onturnoff(self.inst)
    end
end

function AutoFixer:IsOn()
    return #self.users > 0
end

--Hornet: For the fixing boats without players on them config option.
function AutoFixer:OnUpdate()
	local pos = self.inst:GetPosition()
    
	self.boatents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.SEA_YARD_REPAIR_DISTANCE, { "ia_boat" })
	local boatents_inverted = table.invert(self.boatents)
	
	for k, v in pairs(self._oldboatents) do --Hornet: you are not near us any longer, abueno adios máster.
		if not boatents_inverted[v] then
			self:TurnOff(v)
		end
	end

    for k, v in pairs(self.boatents) do
        if v.components.sailable and v.components.boathealth and v:IsValid() then
            if self:CanAutoFixUser(v) then
                self:TurnOn(v)
            end
        end
    end
	
	self._oldboatents = self.boatents
end

return AutoFixer