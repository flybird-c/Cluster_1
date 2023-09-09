local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local MinionSpawner = require("components/minionspawner")

local function generatefreepositions(max)
    local pos_table = {}
    for num = 1, max do
        table.insert(pos_table, num)
    end
    return pos_table
end

local POS_MODIFIER = 1.2

function MinionSpawner:RegenerateFreePositions()
	self.freepositions = generatefreepositions(self.maxminions * POS_MODIFIER)
end

function MinionSpawner:DespawnAll()
	self.spawninprogress = false
	for _, minion in pairs(self.minions) do
		minion:DoTaskInTime(math.random(), function()
			if minion:IsAsleep() then
				minion:Remove()
			else
				minion:PushEvent("despawn")
				minion:ListenForEvent("entitysleep", minion.Remove)
			end
		end)
	end
end

function MinionSpawner:SpawnAll()
	for i = 1, self.maxminions do
		self.inst:DoTaskInTime(math.random(2,3) * math.random(), function()
			self:SpawnNewMinion(true)
		end)
	end
end
