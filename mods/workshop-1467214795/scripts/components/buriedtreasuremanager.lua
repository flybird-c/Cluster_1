local function IsSurroundedByTile(x, y, radius, checkfn)
    if not checkfn(TheWorld.Map:GetTileAtPoint(x, 0, y)) then
        return false
    end

	radius = radius or 1
	for i = -radius, radius, 1 do
		if not checkfn(TheWorld.Map:GetTileAtPoint(x - radius, 0, y + i)) or not checkfn(TheWorld.Map:GetTileAtPoint(x + radius, 0, y + i)) then
			return false
		end
	end
	for i = -(radius - 1), radius - 1, 1 do
		if not checkfn(TheWorld.Map:GetTileAtPoint(x + i, 0, y - radius)) or not checkfn(TheWorld.Map:GetTileAtPoint(x + i, 0, y + radius)) then
			return false
		end
	end
	return true
end

local function GetRandomPoint(checkfn)
    local map_width, map_height = TheWorld.Map:GetSize()
    local x, y
    for i = 1, 10000 do
        x = math.random(-map_width, map_width)
        y = math.random(-map_height, map_height)

        if IsSurroundedByTile(x, y, 1, checkfn) then
            return x, y
        end
    end

    return x, y
end

local BuriedTreasureManager = Class(function(self, inst)
    self.inst = inst

    self._timer = TheWorld.components.timer

    TheWorld:ListenForEvent("read_ia_messagebottle", function(src, GUID)
        self:StartSpawnMesssagebottleTimer(string.format("%d", GUID) .. "ia_messagebottle", TUNING.IA_MESSAGEBOTTLE_RESPAWN_TIME)
    end)

    TheWorld:ListenForEvent("timerdone", function(src, data)
        if not string.find(data.name, "ia_messagebottle") then
            return
        end

        self:SpawnNewMessageBottle()
    end)
end)

function BuriedTreasureManager:GetBuriedTreasure()
    local buriedtreasures = TheSim:FindEntities(0, 0, 0, 10000, {"buriedtreasure", "NOCLICK"})
    return GetRandomItem(buriedtreasures)
end

function BuriedTreasureManager:SpawnNewTreasure()
    local x, y = GetRandomPoint(IsLandTile)

    local buriedtreasure = SpawnPrefab("buriedtreasure")
    buriedtreasure:SetRandomNewTreasure()
    buriedtreasure.Transform:SetPosition(x, 0, y)

    return buriedtreasure
end

function BuriedTreasureManager:SpawnNewMessageBottle()
    local x, y = GetRandomPoint(IsOceanTile)

    local ia_messagebottle = SpawnPrefab("ia_messagebottle")
    ia_messagebottle.Transform:SetPosition(x, 0, y)

    return ia_messagebottle
end

function BuriedTreasureManager:StartSpawnMesssagebottleTimer(name, timeleft)
    self._timer:StartTimer(name, timeleft)
end

return BuriedTreasureManager