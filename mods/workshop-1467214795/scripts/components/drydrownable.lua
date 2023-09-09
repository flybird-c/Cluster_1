local DryDrownable = Class(function(self, inst)
    self.inst = inst

	self.enabled = nil

	self.inst:DoTaskInTime(0, function() if self.enabled == nil then self.enabled = true end end) -- delaying the enable until after the character is finished being set up so that the idle state doesnt sink the player while loading
    
    self.break_period = nil
    self.allow_boats = false
end)

function DryDrownable:IsOverLand()
    local x, y, z = self.inst.Transform:GetWorldPosition()
    return (not self.allow_boats and self.inst:GetCurrentPlatform() ~= nil)
        or not TheWorld.Map:IsOceanAtPoint(x, y, z, true)
end

function DryDrownable:IsOnABreak()
    return self.onbreak
end

function DryDrownable:TakeABreak()
    if self.break_period ~= nil and not self.onbreak then
        self.onbreak = true
        self.inst:DoTaskInTime(self.break_period, function() self.onbreak = false end)
    end
end

function DryDrownable:ShouldDrown()
    return (self.inst.components.mapwrapper == nil or self.inst.components.mapwrapper._state == 0)
        and (self.inst.components.sailor == nil or self.inst.components.sailor:IsSailing() and self.inst._embarkingboat == nil)
        and self.enabled
        and self:IsOverLand()
        and (self.inst.components.health == nil or not self.inst.components.health:IsInvincible()) -- god mode check
end

local function _never_invincible()
    return false
end

local function _always_over_land()
    return true
end

function DryDrownable:CanDrownOverLand(allow_invincible)
    local _IsInvincible = allow_invincible and self.inst.components.health ~= nil and self.inst.components.health.IsInvincible or nil
    if _IsInvincible ~= nil then self.inst.components.health.IsInvincible = _never_invincible end
    local _enabled = self.enabled
    self.enabled = self.enabled ~= false
    local _IsOverLand = self.IsOverLand
    self.IsOverLand = _always_over_land
    local ret = self:ShouldDrown()
    self.IsOverLand = _IsOverLand
    self.enabled = _enabled
    if _IsInvincible ~= nil then self.inst.components.health.IsInvincible = _IsInvincible end
    return ret and not self.inst:HasTag("playerghost") -- HACK: Playerghosts dont drown because they lack the onsink sg event
end


local function NoHolesOrPlatforms(pt)
    local _map = TheWorld.Map
    return not (_map:IsPointNearHole(pt) or _map:GetNearbyPlatformAtPoint(pt.x, pt.y, pt.z, 3) ~= nil)
end

local function NoPlayersOrHolesOrPlatforms(pt)
    local _map = TheWorld.Map
    return not (IsAnyPlayerInRange(pt.x, 0, pt.z, 2) or _map:IsPointNearHole(pt) or _map:GetNearbyPlatformAtPoint(pt.x, pt.y, pt.z, 3) ~= nil)
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function NoPlayersOrHoles(pt)
    return not (IsAnyPlayerInRange(pt.x, 0, pt.z, 2) or TheWorld.Map:IsPointNearHole(pt))
end

function DryDrownable:Teleport()
    local target_x, target_y, target_z = self.dest_x, self.dest_y, self.dest_z
    local radius = 2 + math.random() * 3

    local pt = Vector3(target_x, target_y, target_z)
    local angle = math.random() * 2 * PI
    local offset =
        FindSwimmableOffset(pt, angle, radius, 8, true, false, self.allow_boats and NoPlayersOrHoles or NoPlayersOrHolesOrPlatforms) or
        FindSwimmableOffset(pt, angle, radius * 1.5, 6, true, false, self.allow_boats and NoPlayersOrHoles or NoPlayersOrHolesOrPlatforms) or
        FindSwimmableOffset(pt, angle, radius, 8, true, false, self.allow_boats and NoHoles or NoHolesOrPlatforms) or
        FindSwimmableOffset(pt, angle, radius * 1.5, 6, true, false, self.allow_boats and NoHoles or NoHolesOrPlatforms)
    if offset ~= nil then
        target_x = target_x + offset.x
        target_z = target_z + offset.z
    end
    
    if self.inst.Physics ~= nil then
        self.inst.Physics:Teleport(target_x, target_y, target_z)
    elseif self.inst.Transform ~= nil then
        self.inst.Transform:SetPosition(target_x, target_y, target_z)
    end

    local _world = TheWorld
    if _world.components.walkableplatformmanager then -- NOTES(JBK): Workaround for teleporting too far causing the client to lose sync.
        _world.components.walkableplatformmanager:PostUpdate(0)
    end
end

local function _oncameraarrive(inst)
    inst:SnapCamera()
    inst:ScreenFade(true, 2)
end

local function _onarrive(inst)
	if inst.sg.statemem.teleportarrivestate ~= nil then
		inst.sg:GoToState(inst.sg.statemem.teleportarrivestate)
	end

    inst:PushEvent("on_washed_away")
end

function DryDrownable:WashAway()
	self:Teleport()

	if self.inst:HasTag("player") then
	    self.inst:ScreenFade(false)
		self.inst:DoTaskInTime(3, _oncameraarrive)
	end
    self.inst:DoTaskInTime(3.4, _onarrive)
end

function DryDrownable:ShouldDestroyBoat()
    local pt = self.inst:GetPosition()
    local boat = self.inst.components.sailor and self.inst.components.sailor:GetBoat()
    return boat ~= nil and self.inst:GetCurrentPlatform() == nil and FindNearbyOcean(pt, 5) == nil
end

function DryDrownable:DestroyBoat()
    local pt = self.inst:GetPosition()
    local boat = self.inst.components.sailor and self.inst.components.sailor:GetBoat()
    self.inst.components.sailor:Disembark(pt)

    if boat.components.workable then
        boat.components.workable:Destroy(self.inst)
    elseif boat.components.boathealth then
        boat.components.boathealth:MakeEmpty()
    else
        boat:Remove()
    end
end

function DryDrownable:OnHitCoastline(shore_x, shore_y, shore_z)
	self.src_x, self.src_y, self.src_z = self.inst.Transform:GetWorldPosition()

	if shore_x == nil then
        shore_x, shore_y, shore_z = FindRandomPointOnOceanFromShore(self.src_x, self.src_y, self.src_z, self.allow_boats)
	end

	self.dest_x, self.dest_y, self.dest_z = shore_x, shore_y, shore_z

	if self.inst.components.sleeper ~= nil then
		self.inst.components.sleeper:WakeUp()
	end
end

return DryDrownable