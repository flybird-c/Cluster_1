return Class(function(self, inst)

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst

--Private
local _ismastersim = TheWorld.ismastersim
local _activeplayers = {}
local task = nil
local blowing = false
local enabled = false

local startfn = nil
local endfn = nil
local destroyfn = nil
local windspeedthreshold = 0
local destroychance = 0.01

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function CanDestroy()
    return self.inst.components.hideandseekhidingspot == nil
end

local function UpdateTask()
	task = nil
	if not self.inst then
		return
	end

	local windspeed = TheWorld.state.gustspeed
	if not blowing then
		if windspeed > windspeedthreshold then
			if _ismastersim and CanDestroy() and math.random() < destroychance then
				for i, player in ipairs(_activeplayers) do
					if self.inst:IsNear(player, TUNING.WINDBLOWN_DESTROY_DIST) then
						if destroyfn then
							destroyfn(self.inst)
						end
						return
					end
				end
			end
			if startfn then
				startfn(self.inst, windspeed)
			end
			blowing = true
		end
	else
		if windspeed < windspeedthreshold then
			if endfn then
				endfn(self.inst, windspeed)
			end
			blowing = false
		end
	end
end

--------------------------------------------------------------------------
--[[ Player handlers ]]
--------------------------------------------------------------------------

if _ismastersim then

local function OnPlayerJoined(src, player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            return
        end
    end
    table.insert(_activeplayers, player)
end

local function OnPlayerLeft(src, player)
    for i, v in ipairs(_activeplayers) do
        if v == player then
            table.remove(_activeplayers, i)
            return
        end
    end
end

--Initialize variables
for i, v in ipairs(AllPlayers) do
    table.insert(_activeplayers, v)
end

--Register events
inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, TheWorld)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft, TheWorld)

end

--------------------------------------------------------------------------
--[[ Private Event Handlers ]]
--------------------------------------------------------------------------

local function OnGustSpeedChanged(src, windspeed)
	if enabled and not task and blowing ~= (windspeed > windspeedthreshold) then
		task = self.inst:DoTaskInTime(math.random() * 0.5 + 1.0, UpdateTask)
	end
end

--Register events
-- inst:WatchWorldState("gustspeed", OnGustSpeedChanged)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

-- --Debug function
-- function self:Destroy()
	-- if destroyfn then
		-- destroyfn(self.inst)
	-- end
	-- blowing = false
-- end

function self:Start(soft)
	if not soft then
		enabled = true
	end
	if IsInIAClimate(self.inst) then
		self.inst:WatchWorldState("gustspeed", OnGustSpeedChanged)
	end
end

function self:Stop(soft)
	if not soft then
		enabled = false
	end
	self.inst:StopWatchingWorldState("gustspeed", OnGustSpeedChanged)
	if blowing and endfn then
		endfn(self.inst, windspeed)
	end
	blowing = false
	if task then
		task:Cancel()
	end
	task = nil
end

function self:SetWindSpeedThreshold(windspeed)
	windspeedthreshold = windspeed
end

function self:SetDestroyChance(chance)
	destroychance = chance
end

function self:SetGustStartFn(fn)
	startfn = fn
end

function self:SetGustEndFn(fn)
	endfn = fn
end

function self:SetDestroyFn(fn)
	destroyfn = fn
end

function self:OnEntitySleep()
	self:Stop(true)
end

function self:OnEntityWake()
	if enabled then
		self:Start(true)
	end
end

function self:OnRemoveEntity()
	self:Stop()
end

function self:OnRemoveFromEntity()
	self:Stop()
end

function self:IsGusting()
	return blowing
end

end)
