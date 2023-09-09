
local function OnIgnite(inst)
	inst.components.sentientball:Say(STRINGS.RAWLING.on_ignite)
end

local function OnExtinguish(inst)
	inst.components.sentientball:Say(STRINGS.RAWLING.on_extinguish)
end

local SentientBall = Class(function(self, inst)
	self.inst = inst

	-- this prevents saying too much on events
	self.last_say_time = 0

	self:ScheduleConversation(60 + math.random() * 60)
	
	
	inst:ListenForEvent("onignite", OnIgnite)
	inst:ListenForEvent("onextinguish", OnExtinguish)
end)


function SentientBall:OnDropped()
	self:Say(STRINGS.RAWLING.on_dropped)
end

function SentientBall:OnThrown()
	self:Say(STRINGS.RAWLING.on_thrown)
end

function SentientBall:OnEquipped()
	self:Say(STRINGS.RAWLING.equipped)
end



function SentientBall:Say(list)
	if GetTime() > self.last_say_time + 4 then
		self.inst.components.talker:Say(list[math.random(#list)])
		self.last_say_time = GetTime()
        self:ScheduleConversation(60 + math.random() * 60)
	end
end

local function OnMakeConvo(inst, self)
    self.convo_task = nil
    self:MakeConversation()
end

function SentientBall:ScheduleConversation(delay)
    if self.convo_task ~= nil then
        self.convo_task:Cancel()
    end
    self.convo_task = self.inst:DoTaskInTime(delay or 10 + math.random() * 5, OnMakeConvo, self)
end

function SentientBall:MakeConversation()
	local grand_owner = self.inst.components.inventoryitem:GetGrandOwner()
	local owner = self.inst.components.inventoryitem.owner
	local quiplist
	
	if owner == nil then
		--on the ground
		quiplist = STRINGS.RAWLING.on_ground
	elseif self.inst.components.equippable and self.inst.components.equippable:IsEquipped() then
		--currently equipped
		quiplist = STRINGS.RAWLING.equipped
    elseif owner.components.inventoryitem ~= nil and owner.components.inventoryitem.owner == self.owner then
        --in backpack
		quiplist = STRINGS.RAWLING.in_container
	elseif owner:HasTag("player") then
		--in player inventory
		quiplist = STRINGS.RAWLING.in_inventory
	else
		--owned by someone else
		quiplist = STRINGS.RAWLING.other_owner
	end

	if quiplist then
		self:Say(quiplist)
	end
end

return SentientBall
