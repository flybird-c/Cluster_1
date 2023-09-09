-- 2019 Mobbstar

local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local THIS_VERSION = 2 --INCREMENT THIS NUMBER IF EDITING THE FILE, ONLY EDIT IF TRULY NECESSARY
if rawget(_G, "DYNAMICZOOM_VERSION") ~= nil then
	if DYNAMICZOOM_VERSION >= THIS_VERSION then
		return -- don't load twice, don't load inferior versions
	end
	-- this is the newer version, load and override
end
DYNAMICZOOM_VERSION = THIS_VERSION


local followcamera_ApplyEnvDistance = function(self)
	local mod = 0
	for i, data in ipairs(self.envdistancemods) do
		mod = data.fn(self, mod, data)
	end

	local envdistdelta = mod - self.envdistancemod
	self.mindist = self.mindist + envdistdelta * .5 --The 50% modifier should be fine for all reasonable settings
	self.maxdist = self.maxdist + envdistdelta
	self.distancetarget = math.max(self.mindist, self.distancetarget + envdistdelta)
	self.envdistancemod = mod
	return envdistdelta
end

local followcamera_SetDefault
local followcamera_new_SetDefault = function(self)
	followcamera_SetDefault(self)
	self.envdistancemod = 0
	followcamera_ApplyEnvDistance(self)
end
-- local followcamera_SetDistance
-- local followcamera_new_SetDistance = function(self, dist)
	-- followcamera_ApplyEnvDistance(self, dist - self.distancetarget)
	-- followcamera_SetDistance(self, dist)
-- end

local followcamera_Update
local followcamera_new_Update = function(self, dt)
	if not self.paused and self:IsControllable() then
		self.distance = math.max(self.mindist, self.distance + followcamera_ApplyEnvDistance(self))
	end
	followcamera_Update(self, dt)
end

IAENV.AddClassPostConstruct("cameras/followcamera", function(self)
    if DYNAMICZOOM_VERSION == THIS_VERSION then
		self.envdistancemod = 0
		self.envdistancemods = {}
		followcamera_SetDefault = followcamera_SetDefault or self.SetDefault
		self.SetDefault = followcamera_new_SetDefault
		-- followcamera_SetDistance = followcamera_SetDistance or self.SetDistance
		-- self.SetDistance = followcamera_new_SetDistance
		followcamera_Update = followcamera_Update or self.Update
		self.Update = followcamera_new_Update
	end
end)
