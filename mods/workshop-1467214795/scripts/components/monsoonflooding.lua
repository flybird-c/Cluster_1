-------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "MonsoonFlooding should not exist on client")

--------------------------------------------------------------------------
--[[ Constants ]]
--------------------------------------------------------------------------

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------
--Public

self.inst = inst

--Private

local _world = TheWorld
local _map = _world.Map
local _flooding = _world.components.flooding

local flood_w, flood_h = _flooding:GetFloodGridSize()

local _israining = false
local _ispuddleseason = false
local _seasonprogress = 0
local _clockprogress = 0

local _puddles = {}
local _puddle_depth = 0
local _spawned_puddles = false
local _time_since_puddle_grow = 0
local _time_since_puddle_dry = 0

local _active_puddles = Queue()
local _inactive_puddles = Queue()

-- for puddles
local _max_puddle_depth = TUNING.MAX_PUDDLE_LEVEL
local _puddle_grow_time = TUNING.PUDDLE_GROW_TIME
local _puddle_dry_time = TUNING.PUDDLE_DRY_TIME
local _puddle_frequency = TUNING.PUDDLE_FREQUENCY

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function SpawnPuddle(x, y)
    local puddle = SpawnPrefab("monsoon_puddle")
    puddle:SetPuddleLocation(x, y)
    puddle.components.puddle:SetPuddleDepth(_puddle_depth)
    table.insert(_puddles, puddle)
end

local function SpawnRandomPuddles()
    for x = 0, flood_w-1 do
        for y = 0, flood_h-1 do
            if math.random() <= _puddle_frequency and not _flooding:IsFloodBlocked(x, y) then
                SpawnPuddle(x, y)
            end
        end
    end
    _spawned_puddles = true
end

local function UpdatePuddleDepth()
    if _puddle_depth == 0 then
        for i, v in ipairs(_puddles) do
            v:Remove()
        end
        _puddles = {}
        _active_puddles:Clear()
        _inactive_puddles:Clear()
    else
        for i, v in ipairs(_puddles) do
            v.components.puddle:SetPuddleDepth(_puddle_depth)
        end
    end
end

local function UpdatePuddleSeason(isspring)
    _ispuddleseason = isspring and (_seasonprogress + _clockprogress) >= 0.25

    if _ispuddleseason then
        inst:StartUpdatingComponent(self)
    end
end

--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function floodblockingupdated(src, data)
    for i, v in ipairs(_puddles) do
        v.components.puddle:OnFloodBlockingUpdated(data.x, data.y, data.blocked)
    end
end

local function seasontick(src, data)
    _seasonprogress = data.progress or 0
    UpdatePuddleSeason(data.season == "spring")
end

local function clocktick(src, data)
    _clockprogress = (data.time or 0) / TheWorld.state[TheWorld.state.season.."length"]
    UpdatePuddleSeason(TheWorld.state.isspring)
end

local function precipitation_islandchanged(src, preciptype)
    _israining = preciptype == "rain"
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------

--Register events

--TODO terraform listener
inst:ListenForEvent("floodblockingupdated", floodblockingupdated, _world)
inst:ListenForEvent("seasontick", seasontick, _world)
inst:ListenForEvent("clocktick", clocktick, _world)
inst:ListenForEvent("precipitation_islandchanged", precipitation_islandchanged, _world)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

function self:SetPuddleSettings(max_level, frequency)
    _max_puddle_depth = math.min(max_level, TUNING.MAX_PUDDLE_LEVEL)
    _puddle_frequency = frequency
end

function self:SpawnPuddle(x, y, z, force)
    if _puddle_depth == 0 then return end -- Fixes some messy behaviour
    local p_x, p_y = _flooding:GetFloodCoordsAtPoint(x, y, z)
    if not _flooding:IsFloodBlocked(p_x, p_y, force) then
        SpawnPuddle(p_x, p_y)

        inst:StartUpdatingComponent(self)
    end
end

function self:AddActivePuddleUpdate(puddle)
    _active_puddles:Push(puddle)
end

function self:AddInactivePuddleUpdate(puddle)
    _inactive_puddles:Push(puddle)
end

function self:RemoveAllPuddles()
    _puddle_depth = 0
    _time_since_puddle_grow = 0
    _time_since_puddle_dry = 0
    UpdatePuddleDepth()
end

----    ----------------------------------------------------------------------
--[[ Update ]]
--------------------------------------------------------------------------

function self:OnUpdate(dt)
    if _ispuddleseason then
        local target_puddle_depth = math.ceil(_max_puddle_depth * math.max(0, ((_seasonprogress + _clockprogress) - 0.25) / 0.75)) --Don't spawn puddles in the first 1/4 of the season

        if _israining and target_puddle_depth > _puddle_depth then
            _time_since_puddle_grow = _time_since_puddle_grow + dt
            if _time_since_puddle_grow > _puddle_grow_time then
                _puddle_depth = _puddle_depth + 1
                _time_since_puddle_grow = 0
                UpdatePuddleDepth()
            end
        end

        if _israining and not _spawned_puddles and _puddle_depth >= 2 then
            SpawnRandomPuddles()
        end
    elseif _spawned_puddles or _puddle_depth > 0 then
        _spawned_puddles = false
        if _puddle_depth > 0 then
            _time_since_puddle_dry = _time_since_puddle_dry + dt
            if _time_since_puddle_dry > _puddle_dry_time then
                _puddle_depth = _puddle_depth - 1
                if _puddle_depth == 1 then _puddle_depth = 0 end
                _time_since_puddle_dry = 0
                UpdatePuddleDepth()
            end
        end
    end

    for i = 1, 2 do
        local puddle = _active_puddles:Pop()
        if puddle then
            puddle:DoUpdate()
        end
    end
    local puddle = _inactive_puddles:Pop()
    if puddle then
        puddle:DoUpdate(true)
    end

    if (_spawned_puddles or not _ispuddleseason) and IsTableEmpty(_puddles) then
        inst:StopUpdatingComponent(self)
    end
end
self.LongUpdate = self.OnUpdate

inst:StartUpdatingComponent(self)

--------------------------------------------------------------------------
--[[ Save/Load ]]
--------------------------------------------------------------------------

function self:OnSave()
    local data = {}

    local references = {}
    local refs

    data.puddles = {}
    for i, v in ipairs(_puddles) do
        data.puddles[i], refs = v:GetSaveRecord()
        if refs then
            for _, v1 in pairs(refs) do
                table.insert(references, v1)
            end
        end
    end

    data.puddle_depth = _puddle_depth
    data.spawned_puddles = _spawned_puddles

    data.time_since_puddle_grow = _time_since_puddle_grow
    data.time_since_puddle_dry = _time_since_puddle_dry

    return data, references

end
function self:OnLoad(data, newents)
    if data == nil then return end

    for i, v in ipairs(data.puddles) do
        _puddles[i] = SpawnSaveRecord(v, newents)
    end

    _puddle_depth = data.puddle_depth
    _spawned_puddles = data.spawned_puddles

    _time_since_puddle_grow = data.time_since_puddle_grow
    _time_since_puddle_dry = data.time_since_puddle_dry
end

--------------------------------------------------------------------------

function self:GetDebugString()
    return string.format("puddles %u, depth %u, active puddle updates %u, inactive puddle updates %u", #_puddles, _puddle_depth, _active_puddles:Size(), _inactive_puddles:Size())
end


end)