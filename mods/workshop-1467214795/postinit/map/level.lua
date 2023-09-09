local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local MULTIPLY = require("map/forest_map").MULTIPLY
local tasks = require("map/tasks")
local tasksets = require("map/tasksets")

local function GetRandomFromLayouts(layouts)
	local area_keys = {}
	for k, v in pairs(layouts) do
		table.insert(area_keys, k)
	end
	local area_idx = math.random(#area_keys)
	local area = area_keys[area_idx]
	local target = nil
	if (area == "Rare" and math.random() < 0.98) or GetTableSize(layouts[area]) < 1 then
		table.remove(area_keys, area_idx)
		area = area_keys[math.random(#area_keys)]
	end

	if GetTableSize(layouts[area]) <1 then
		return nil
	end

	target = {target_area = area, choice = GetRandomKey(layouts[area])}

	return target
end

local function GetAreasForChoice(area, task_set, type)
	local areas = {}

	for i, t in ipairs(task_set) do
		local task = tasks.GetTaskByName(t.id, tasks.taskdefinitions)
		if area == "Shipwrecked_Any" or area == task.room_bg then
			table.insert(areas, t.id)
		end

		if type ~= "trap" and (area == "Any" or area == "Rare") then
			table.insert(areas, t.id)
		end
	end
	if #areas == 0 then
		return nil
	end
	return areas
end

local function AddSingleSetPiece(level, choicefile, type, area, name)
	local choices = require(choicefile)
	assert(choices.Sandbox)

	local chosen = nil
	chosen = GetRandomFromLayouts(choices.Sandbox)

	if area ~= nil and name ~= nil then  -- for test
		chosen = {target_area = area, choice = name}
	end

	if chosen ~= nil then
		if chosen.target_area == "Water" then
			if level.water_setpieces == nil then
				level.water_setpieces = {}
			end
			if level.water_setpieces[chosen.choice] == nil then
				level.water_setpieces[chosen.choice] = {count = 0}
			end
			level.water_setpieces[chosen.choice].count = level.water_setpieces[chosen.choice].count + 1
		else
			if level.set_pieces == nil then
				level.set_pieces = {}
			end

			local areas = GetAreasForChoice(chosen.target_area, level:GetTasksForLevelSetPieces(), type)
			if areas then
				local num_peices = 1
				if level.set_pieces[chosen.choice] ~= nil then
					num_peices = level.set_pieces[chosen.choice].count + 1
				end
				level.set_pieces[chosen.choice] = {count = num_peices, tasks = areas}
			end
		end
	end
end

local function AddAllIASetPieces(level)
	for area, layouts in pairs(IA_AllBoons) do
		for _, name in ipairs(layouts) do
			AddSingleSetPiece(level, "map/boons", "boon", area, name)
		end
	end

	for area, layouts in pairs(IA_AllTraps) do
		for _, name in ipairs(layouts) do
			AddSingleSetPiece(level, "map/traps", "trap", area, name)
		end
	end
end

local function AddSetPieces(level, addall)
	if addall then  -- testing purposes only
		print("Added every IA Set Piece")
		AddAllIASetPieces(level)
		return
	end

	local boons_override = "default"
	local touchstone_override = "default"
	local traps_override = "default"
	-- local poi_override = "default"
	local protected_override = "default"

	if level.overrides ~= nil then
		if level.overrides.boons ~= nil then
			boons_override = level.overrides.boons
		end
		if level.overrides.touchstone ~= nil then
			touchstone_override = level.overrides.touchstone
		end
		if level.overrides.traps ~= nil then
			traps_override = level.overrides.traps
		end
		-- if level.overrides.poi ~= nil then -- poi is not used in SW
		-- 	poi_override = level.overrides.poi
		-- end
		if level.overrides.protected ~= nil then
			protected_override = level.overrides.protected
		end
	end

    if boons_override ~= "never" then
		local boons = math.random( math.floor(3 * MULTIPLY[boons_override]), math.ceil(8 * MULTIPLY[boons_override]) )
		for idx = 1, boons do
			AddSingleSetPiece(level, "map/boons")
		end
	end

	if touchstone_override ~= "default" and level.set_pieces ~= nil and level.set_pieces["ResurrectionStoneSw"] ~= nil then
		if touchstone_override == "never" then
			level.set_pieces["ResurrectionStoneSw"] = nil
		else
			level.set_pieces["ResurrectionStoneSw"].count = math.ceil(level.set_pieces["ResurrectionStoneSw"].count * MULTIPLY[touchstone_override])
		end
	end

    if traps_override ~= "never" then
        AddSingleSetPiece(level, "map/traps", "trap")
    end

	-- if poi_override ~= "never" then
	-- 	AddSingleSetPiece(level, "map/pointsofinterest")
	-- end

	if protected_override ~= "never" then
		AddSingleSetPiece(level, "map/protected_resources")
	end

end

local _ChooseSetPieces = Level.ChooseSetPieces
Level.ChooseSetPieces = function(self, ...)
    local IsShipwrecked = WORLDTYPES.worldgen[self.overrides.primaryworldtype] == "shipwrecked"

    if IsShipwrecked then  -- SW has its own set_pieces
        self.set_pieces = tasksets.GetGenTasks("shipwrecked").set_pieces  -- Replacing set_pieces in SW world
        AddSetPieces(self, self.overrides.alliasetpieces)  -- set this to true to generate every IA set_piece
    end

    _ChooseSetPieces(self, ...)
end

local _ChooseTasks = Level.ChooseTasks
Level.ChooseTasks = function(self, ...)
    _ChooseTasks(self, ...)

    if self.selectedtasks then
        for _, selectedtask in ipairs(self.selectedtasks) do
            local numtoadd = math.random(selectedtask.min, selectedtask.max)
            shuffleArray(selectedtask.task_choices)

            for i = 1, numtoadd do
                self:EnqueueATask(self.chosen_tasks, selectedtask.task_choices[i])
            end
        end
    end

    -- is there enough place for set_pieces?
    if self.set_pieces then
        for name, choicedata in pairs(self.set_pieces or {}) do
            local availabletasks = {}

            for i, task in ipairs(self.chosen_tasks) do
                availabletasks[i] = task.id
            end

            local choices = ArrayIntersection(choicedata.tasks, availabletasks)
            local count = choicedata.count or 1

            if #choices < count then  -- reselect task
                print("Warning! could not find enough to place set_pieces")
                self:ChooseTasks(...)
            end
        end
    end
end
