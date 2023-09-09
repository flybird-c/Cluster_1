-- hack storygen functions is very trouble, so we rewrite it  -- Jerry

local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

require("map/storygen")

function Story:ProcessWaterContent()
	if self.level.water_content then
		if self.water_content == nil then
			self.water_content = {}
		end

		for room, v in pairs(self.level.water_content) do
			local data = self:GetRoom(room)
			if data then
				table.insert(self.water_content, {checkFn = v.checkFn, data = data})
			end
		end
	end
end

function Story:ShipwreckedPlaceTeleportatoParts()
	local RemoveExitTag = function(node)
		local newtags = {}
		for i, tag in ipairs(node.data.tags) do
			if tag ~= "ExitPiece" then
				table.insert(newtags, tag)
			end
		end
		node.data.tags = newtags
	end

	local IsNodeAnExit = function(node)
		if not node.data.tags then
			return false
		end
		for i, tag in ipairs(node.data.tags) do
			if tag == "ExitPiece" then
				return true
			end
		end
		return false
	end

	local iswaternode = function(node)
		local water_node = node.data.type == "water" or IsOceanTile(node.data.value)
		return water_node
		--return ((setpiece_data.restrict_to == nil or setpiece_data.restrict_to ~= "water") and room.data.type ~= "water") or (setpiece_data.restrict_to and setpiece_data.restrict_to == "water" and (room.data.type == "water" or WorldSim:IsWater(room.data.value)))
	end

	local AddPartToTask = function(part, task)
		local nodeNames = shuffledKeys(task.nodes)
		for i, name in ipairs(nodeNames) do
			if IsNodeAnExit(task.nodes[name]) and not iswaternode(task.nodes[name]) then
				local extra = task.nodes[name].data.terrain_contents_extra
				if not extra then
					extra = {}
				end
				if not extra.static_layouts then
					extra.static_layouts = {}
				end
				table.insert(extra.static_layouts, part)
				RemoveExitTag(task.nodes[name])
				return true
			end
		end
		return false
	end

	local InsertPartnumIntoATask = function(targetDepth, part, tasks)
		for id, task in pairs(tasks) do
			 if task.story_depth == targetDepth then
				local success = AddPartToTask(part, task)
				-- Not sure why we need this, was causeing crash
				-- assert( success or task.id == "TEST_TASK"or task.id == "MaxHome", "Could not add an exit part to task "..task.id)
				return success
			end
		end
		return false
	end

	local parts = self.level.ordered_story_setpieces or {}
	local maxdepth = -1

	for id, task_node in pairs(self.rootNode:GetChildren()) do
		if task_node.story_depth > maxdepth then
			maxdepth = task_node.story_depth
		end
	end


	local partSpread = maxdepth/#parts
	local range = math.ceil(maxdepth/10)
	local plusminus = math.ceil(range/2)

	for partnum = 1, #parts do
		--local minDepth = partnum*partSpread - plusminus
		--local maxDepth = partnum*partSpread + plusminus
		local targetDepth = math.ceil(partnum*partSpread)
		local success = InsertPartnumIntoATask(targetDepth, parts[partnum], self.rootNode:GetChildren())
		if success == false then
			for i = 1, plusminus do
				local tryDepth = targetDepth - i
				if InsertPartnumIntoATask(tryDepth, parts[partnum], self.rootNode:GetChildren()) then
					break
				end
				tryDepth = targetDepth + i
				if InsertPartnumIntoATask(tryDepth, parts[partnum], self.rootNode:GetChildren()) then
					break
				end
			end
		end
	end
end

function Story:InsertWaterSetPieces()
	if self.water_content and self.level.water_setpieces then
		for k, v in ipairs(self.level.water_setpieces) do
			local choicekeys = shuffledKeys(self.water_content)
			local content = self.water_content[math.random(1, #self.water_content)]
			--if content.data.type == "water" or IsOceanTile(content.data.value) then
				if content.data.contents.countstaticlayouts == nil then
					content.data.contents.countstaticlayouts = {}
				end
				if content.data.contents.countstaticlayouts[v] == nil then
					content.data.contents.countstaticlayouts[v] = 0
				end
				content.data.contents.countstaticlayouts[v] = content.data.contents.countstaticlayouts[v] + 1
			--end
		end
	end
end

function Story:ShipwreckedInsertAdditionalSetPieces(task_nodes)
	local obj_layout = require("map/object_layout")

	local function is_water_ok(room, layout)
		local water_room = room.data.type == "water" or IsOceanTile(room.data.value)
		local water_layout = layout and layout.water == true
		return (water_room and water_layout) or (not water_room and not water_layout)
	end

	local tasks = task_nodes or self.rootNode:GetChildren()
	for id, task in pairs(tasks) do
		if task.set_pieces ~= nil and #task.set_pieces > 0 then
			for i, setpiece_data  in ipairs(task.set_pieces) do
				local is_entrance = function(room)
					-- return true if the room is an entrance
					return room.data.entrance ~= nil and room.data.entrance == true
				end
				local is_background_ok = function(room)
					-- return true if the piece is not backround restricted, or if it is but we are on a background
					return setpiece_data.restrict_to ~= "background" or room.data.type == "background"
				end
				local isnt_blank = function(room)
					return room.data.type ~= "blank" and not TileGroupManager:IsImpassableTile(room.data.value)
				end

				local layout = obj_layout.LayoutForDefinition(setpiece_data.name)
				local choicekeys = shuffledKeys(task.nodes)
				local choice = nil
				for _, choicekey in ipairs(choicekeys) do
					if not is_entrance(task.nodes[choicekey]) and is_background_ok(task.nodes[choicekey]) and is_water_ok(task.nodes[choicekey], layout) and isnt_blank(task.nodes[choicekey]) then
						choice = choicekey
						break
					end
				end

				if choice == nil then
					print("Warning! Couldn't find a spot in " .. task.id .. " for " .. setpiece_data.name)
					break
				end

				--print("Placing "..setpiece_data.name.." in "..task.id..":"..task.nodes[choice].id)

				if task.nodes[choice].data.terrain_contents.countstaticlayouts == nil then
					task.nodes[choice].data.terrain_contents.countstaticlayouts = {}
				end
				--print ("Set peice", name, choice, room_choices._et[choice].contents, room_choices._et[choice].contents.countstaticlayouts[name])
				task.nodes[choice].data.terrain_contents.countstaticlayouts[setpiece_data.name] = 1
			end
		end
		if task.random_set_pieces ~= nil and #task.random_set_pieces > 0 then
			for k, setpiece_name in ipairs(task.random_set_pieces) do
				local layout = obj_layout.LayoutForDefinition(setpiece_name)
				local choicekeys = shuffledKeys(task.nodes)
				local choice = nil
				for i, choicekey in ipairs(choicekeys) do
					local is_entrance = function(room)
						-- return true if the room is an entrance
						return room.data.entrance ~= nil and room.data.entrance == true
					end
					local isnt_blank = function(room)
						return room.data.type ~= "blank"
					end

					if not is_entrance(task.nodes[choicekey]) and isnt_blank(task.nodes[choicekey]) and is_water_ok(task.nodes[choicekey], layout) then
						choice = choicekey
						break
					end
				end

				if choice == nil then
					print("Warning! Couldn't find a spot in " .. task.id .. " for " .. setpiece_name)
					break
				end

				--print("Placing "..setpiece_data.name.." in "..task.id..":"..task.nodes[choice].id)

				if task.nodes[choice].data.terrain_contents.countstaticlayouts == nil then
					task.nodes[choice].data.terrain_contents.countstaticlayouts = {}
				end
				--print ("Set peice", name, choice, room_choices._et[choice].contents, room_choices._et[choice].contents.countstaticlayouts[name])
				task.nodes[choice].data.terrain_contents.countstaticlayouts[setpiece_name] = 1
			end
		end
	end
end

function Story:LinkIslandsByKeys(startParentTask, unusedTasks)
	local lastNode = startParentTask

	startParentTask.story_depth = 0
	local story_depth = 1

	--build a table of task graphs
	local layout = {}
	local layoutdepth = 1

	--depth 0 is always the start task
	layout[1] = {}
	--print("Start task " .. startParentTask.id)
	table.insert(layout[1], startParentTask)
	unusedTasks[startParentTask.id] = nil

	local locks = {}
	for l, k in pairs(LOCKS_KEYS) do
		local lock = {keys = k, unlocked = false}
		locks[l] = lock
	end
	locks[LOCKS.NONE].unlocked = true

	local unlockEverything = false

	while GetTableSize(unusedTasks) > 0 do
		--print("Unused tasks " .. GetTableSize(unusedTasks))
		--unlock every lock we can at the current depth
		for lock, lockData in pairs(locks) do
			for i, taskgraph in ipairs(layout[layoutdepth]) do
				--print("\tUnlocking",LOCKS_ARRAY[lock])
				for j, reqKey in pairs(self.tasks[taskgraph.id].keys_given) do
					for k, key in pairs(lockData.keys) do
						if reqKey == key then
							--print("Task " .. taskgraph.id)
							--print("\t\t\tUnlocked!", KEYS_ARRAY[key])
							lockData.unlocked = true
						end
					end
				end
			end
		end

		layoutdepth = layoutdepth + 1
		layout[layoutdepth] = {}

		local addedtasks = 0

		--add every unlocked task to this depth
		for taskid, taskgraph in pairs(unusedTasks) do
			local addtask = false
			for i, lock in pairs(self.tasks[taskid].locks) do
				if locks[lock].unlocked == true then
					addtask = true
				else
					--print("Can't add " .. taskid .. " " .. LOCKS_ARRAY[lock] .. " locked")
				end
			end
			if addtask == true or unlockEverything == true then
				taskgraph.story_depth = story_depth
				story_depth = story_depth + 1
				table.insert(layout[layoutdepth], taskgraph)
				unusedTasks[taskid] = nil
				addedtasks = addedtasks + 1
			end
		end

		--after 1 loop without adding anything unlock everything
		if addedtasks == 0 then
			--print("Added no tasks unlock everything")
			for lock, lockData in pairs(locks) do
				lockData.unlocked = true
			end
			unlockEverything = true
			layoutdepth = layoutdepth - 1
		else
			--print("Added " .. #layout[layoutdepth] .. " tasks at depth " .. layoutdepth)
		end
	end

	--link tasks and seperate by ocean
	print("Linking " .. #layout .. " depths")

	local sprawling = true
	if sprawling == true then
		--random, sprawling
		for depth = #layout, 2, -1 do
			--print("Linking " .. #layout[depth] .. " at depth " .. depth)
			for i, taskgraph in pairs(layout[depth]) do
				--link each task at this depth with a random task in the previous depth
				local taskgraph2 = layout[depth - 1][math.random(1, #layout[depth - 1])]
				local curNode = taskgraph:GetRandomNode()
				local prevDepthNode = taskgraph2:GetRandomNode()

				--print("Linking " .. taskgraph.id .. " -> ".. taskgraph2.id)
				self:SeperateIslandsByOcean(prevDepthNode, curNode, math.random(3, 5)) --CM was 6,10
				--self.rootNode:LockGraph(prevDepthNode.id..'->'..curNode.id, prevDepthNode, curNode, {type="none", key=self.tasks[curNode.id].locks, node=nil})
			end
		end
	else
		--interconnected web
		for depth = #layout, 2, -1 do
			--print("Linking " .. #layout[depth] .. " at depth " .. depth)
			for i, taskgraph in pairs(layout[depth]) do
				--link each task at this depth with a random task in the previous depth
				local node = math.floor(#layout[depth - 1] * ((i - 1) / #layout[depth]) + 1)
				print(node .. " = " .. #layout[depth - 1] .. ", " .. i .. ", " .. #layout[depth])
				assert(1 <= node and node <= #layout[depth - 1])
				local taskgraph2 = layout[depth - 1][node]
				local curNode = taskgraph:GetRandomNode()
				local prevDepthNode = taskgraph2:GetRandomNode()

				--print("Linking " .. taskgraph.id .. " -> ".. taskgraph2.id)
				self:SeperateIslandsByOcean(prevDepthNode, curNode, math.random(5, 15))
				--self.rootNode:LockGraph(prevDepthNode.id..'->'..curNode.id, prevDepthNode, curNode, {type="none", key=self.tasks[curNode.id].locks, node=nil})
			end

			for i = 1, #layout[depth] - 1, 1 do
				local node1 = layout[depth][i]:GetRandomNode()
				local node2 = layout[depth][i + 1]:GetRandomNode()
				self:SeperateIslandsByOcean(node1, node2, 5)
			end
			self:SeperateIslandsByOcean(layout[depth][ #layout[depth] ]:GetRandomNode(), layout[depth][1]:GetRandomNode(), 5)
		end
	end

	return lastNode
end

local function SetClimates(task_node, level)
	local mainclimate = WORLDTYPES.mainclimate[level.overrides.primaryworldtype]
	for k,v in pairs(task_node.nodes) do
		v.data = v.data or {}
		v.data.tags = v.data.tags or {}
		local climate
		for i,name in pairs(CLIMATES) do
			if table.contains(v.data.tags, name.."climate") then
				climate = name
				break
			end
		end
		--if the node doesnt have a set climatetag add one based on the world being generated
		if climate == nil and mainclimate ~= nil then
			table.insert(v.data.tags, mainclimate.."climate")
		end
	end
end

function Story:GenerateNodesForIslands(level)
	--print("Story:GenerateNodesFromTasks creating stories")

	local unusedTasks = {}

	-- Generate all the TERRAIN
	for _, task in pairs(self.tasks) do
		--print("Story:GenerateNodesFromTasks k,task",k,task,  GetTableSize(self.TERRAIN))
		local node = nil
		if task.gen_method == "lagoon" then
			node = self:GenerateIslandFromTask(task, false)
		elseif task.gen_method == "volcano" then
			node = self:GenerateIslandFromTask(task, true)
		else
			node = self:GenerateNodesFromTask(task, task.crosslink_factor or 1)--0.5)
		end
		local add_tags = level.overrides.task_add_tags ~= nil and level.overrides.task_add_tags[task.id] or nil
		if add_tags ~= nil then
			for _, tag in pairs(add_tags) do
				for _, _node in pairs(node.nodes) do
					table.insert(_node.data.tags, tag)
				end
			end
		end
		SetClimates(node, level)
		self.TERRAIN[task.id] = node
		unusedTasks[task.id] = node
	end

	--print("Story:GenerateNodesFromTasks lock terrain")

	local startTasks = {}
	if self.level.valid_start_tasks ~= nil then
		local randomStartTaskName = GetRandomItem(self.level.valid_start_tasks)
		print("Story:GenerateNodesFromTasks start_task " .. randomStartTaskName)
		startTasks[randomStartTaskName] = self.TERRAIN[randomStartTaskName]
	else
		for k, task in pairs(self.tasks) do
			if #task.locks == 0 or task.locks[1] == LOCKS.NONE then
				startTasks[task.id] = self.TERRAIN[task.id]
			end
		end
	end

	--print("Story:GenerateNodesFromTasks finding start parent node")

	local startParentNode = GetRandomItem(self.TERRAIN)
	if  GetTableSize(startTasks) > 0 then
		startParentNode = GetRandomItem(startTasks)
	end

	unusedTasks[startParentNode.id] = nil

    --print("Lock and Key")

	self.finalNode = self:LinkIslandsByKeys(startParentNode, unusedTasks) --startParentNode
	--print("LinkIslandsByKeys")
	--finalNode = self:LinkIslandsByKeys(startParentNode, unusedTasks

	local randomStartNode = startParentNode:GetRandomNode()

	local start_node_data = {id = "START"}

	if self.gen_params.start_node ~= nil then
		start_node_data.data = self:GetRoom(self.gen_params.start_node)
		start_node_data.data.terrain_contents = start_node_data.data.contents
	else
		start_node_data.data = {
			value = WORLD_TILES.GRASS,
			terrain_contents = {
				countprefabs = {
					spawnpoint = 1,
					sapling = 1,
					flint = 1,
					berrybush = 1,
					grass = function () return 2 + math.random(2) end
				}
			}
		}
	end

	start_node_data.data.type = "START"
	start_node_data.data.colour = {r = 0, g = 1, b = 1, a = .80}

	if self.gen_params.start_setpeice ~= nil then
		start_node_data.data.terrain_contents.countstaticlayouts = {}
		start_node_data.data.terrain_contents.countstaticlayouts[self.gen_params.start_setpeice] = 1

		if start_node_data.data.terrain_contents.countprefabs ~= nil then
			start_node_data.data.terrain_contents.countprefabs.spawnpoint = nil
		end
	end

	self.startNode = startParentNode:AddNode(start_node_data)

	--print("Story:GenerateNodesFromTasks adding start node link", self.startNode.id.." -> "..randomStartNode.id)
	startParentNode:AddEdge({node1id = self.startNode.id, node2id = randomStartNode.id})
end

function Story:AddRoadPoison()
	for id, task in pairs(self.rootNode:GetChildren()) do
		for k, v in pairs(task.nodes) do
			if v.type ~= "blank" and v.type ~= "water" then
				if v.data.tags == nil then v.data.tags = {} end
				table.insert(v.data.tags, "RoadPoison")
				table.insert(v.data.tags, "ForceConnected")
			end
		end
	end
end

function Story:ShipwreckedAddBGNodes(min_count, max_count)
	local tasksnodes = self.rootNode:GetChildren(false)
	local bg_idx = 0

	local function getBGRoom(task)
		local room = nil
		if type(task.data.background) == "table" then
			room = task.data.background[math.random(1, #task.data.background)]
		else
			room = task.data.background
		end
		return room
	end

	local function getBGRoomCount(task)
		local a = (task.background_node_range and task.background_node_range[1]) or min_count
		local b = (task.background_node_range and task.background_node_range[2]) or max_count
		return math.random(a, b)
	end

	for taskid, task in pairs(tasksnodes) do

		for nodeid, node in pairs(task:GetNodes(false)) do

			local background = getBGRoom(task)
			if background then
				local background_template = self:GetRoom(background) --self:GetRoom(task.data.background)
				assert(background_template, "Couldn't find room with name ".. background)
				local blocker_blank_template = self:GetRoom(self.level.blocker_blank_room_name)
				if blocker_blank_template == nil then
					blocker_blank_template = {
						type="blank",
						tags = {"RoadPoison", "ForceDisconnected"},
						colour = {r = 0.3, g = .8, b = .5, a = .50},
						value = self.impassible_value
					}
				end

				self:RunTaskSubstitution(task, background_template.contents.distributeprefabs)

				if not node.data.entrance then

					local count = getBGRoomCount(task) --math.random(min_count,max_count)
					local prevNode = nil
					for i = 1, count do

						local new_room = deepcopy(background_template)
						new_room.id = nodeid .. ":BG_" .. bg_idx .. ":" .. background
						new_room.task = task.id


						-- this has to be inside the inner loop so that things like teleportato tags
						-- only get processed for a single node.
						local extra_contents, extra_tags = self:GetExtrasForRoom(new_room)


						local newNode = task:AddNode({
							id = new_room.id,
							data = {
								type = "background",
								colour = new_room.colour,
								value = new_room.value,
								internal_type = new_room.internal_type,
								tags = extra_tags,
								terrain_contents = new_room.contents,
								terrain_contents_extra = extra_contents,
								terrain_filter = self.terrain.filter,
								entrance = new_room.entrance
							}
						})

						task:AddEdge({node1id = newNode.id, node2id = nodeid})
						-- This will probably cause crushng so it is commented out for now
						-- if prevNode then
						-- 	task:AddEdge({node1id=newNode.id, node2id=prevNode.id})
						-- end

						bg_idx = bg_idx + 1
						prevNode = newNode
					end
				else -- this is an entrance node
					for i = 1, 2 do
						local new_room = deepcopy(blocker_blank_template)
						new_room.task = task.id

						local extra_contents, extra_tags = self:GetExtrasForRoom(new_room)

						local blank_subnode = task:AddNode({
							id = nodeid .. ":BLOCKER_BLANK_" .. tostring(i),
							data = {
								type = new_room.type or "blank",
								colour = new_room.colour,
								value = new_room.value,
								internal_type = new_room.internal_type,
								tags = extra_tags,
								terrain_contents = new_room.contents,
								terrain_contents_extra = extra_contents,
								terrain_filter = self.terrain.filter,
								blocker_blank = true,
							}
						})

						task:AddEdge({node1id = nodeid, node2id = blank_subnode.id})
					end
				end
			end
		end

	end
end

function Story:SeperateIslandsByOcean(startnode, endnode, links)
	--print("Link islands by ocean " .. startnode.id .. " -> " .. endnode.id)
	local ocean_graph = Graph("OCEAN_BLANK" .. tostring(self.loop_blanks), {parent = self.rootNode, default_bg = WORLD_TILES.IMPASSABLE, colour = {r = 1, g = 0.8, b = 1, a = 1}, background="BGImpassable" })

	local nodes = {}
	local newNode = nil
	local prevNode = nil
	for i = 1, links, 1 do
		newNode = ocean_graph:AddNode({
			id = "LOOP_BLANK_SUB " .. tostring(self.loop_blanks),
			data = {
				type = "water",
				tags = {"RoadPoison", "ForceDisconnected"},
				colour = {r = 1.0, g = .8, b = 1, a = 1},
				value = self.impassible_value
			}
		})

		if prevNode then
			--print("Story:SeperateIslandsByOcean Adding edge "..newNode.id.." -> "..prevNode.id)
			local edge = ocean_graph:AddEdge({node1id = newNode.id, node2id = prevNode.id})
		end

		self.loop_blanks = self.loop_blanks + 1
		prevNode = newNode
		table.insert(nodes, newNode)
	end

	local firstNode = nodes[1]
	local lastNode = nodes[#nodes]

	self.rootNode:LockGraph(startnode.id .. '->' .. firstNode.id, 	startnode, 	firstNode, {type = "none", key = KEYS.NONE, node = nil})
	self.rootNode:LockGraph(endnode.id .. '->' .. lastNode.id, 		endnode, 	lastNode,  {type = "none", key = KEYS.NONE, node = nil})

	--WorldSim:AddChild(self.rootNode.id, ocean_graph.id, ocean_graph.room_bg, ocean_graph.colour.r, ocean_graph.colour.g, ocean_graph.colour.b, ocean_graph.colour.a)
end

function Story:GenerateIslandFromTask(task, randomize)
	if task.room_choices == nil or type(task.room_choices[1]) ~= "table" then
		return nil
	end

	local task_node = Graph(task.id, {parent = self.rootNode, default_bg = task.room_bg, colour = task.colour, background = task.background_room, random_set_pieces = task.random_set_pieces, set_pieces = task.set_pieces, maze_tiles = task.maze_tiles, treasures = task.treasures, random_treasures = task.random_treasures})
	task_node.substitutes = task.substitutes

	WorldSim:AddChild(self.rootNode.id, task.id, task.room_bg, task.colour.r, task.colour.g, task.colour.b, task.colour.a)

	local layout = {}
	local layoutdepth = 1
	local roomID = 0

	for i = 1, #task.room_choices, 1 do
		layout[layoutdepth] = {}

		local rooms = {}
		for room, count in pairs(task.room_choices[i]) do
			--print("Story:GenerateIslandFromTask adding "..count.." of "..room, self.terrain.rooms[room].contents.fn)
			for id = 1, count do
				table.insert(rooms, room)
			end
		end
		if randomize then
			rooms = shuffleArray(rooms)
		end

		for _, room in ipairs(rooms) do
		--for room, count in pairs(task.room_choices[i]) do
			--print("Story:GenerateIslandFromTask adding "..count.." of "..room, self.terrain.rooms[room].contents.fn)
			--for id = 1, count do
				local new_room = self:GetRoom(room)

				assert(new_room, "Couldn't find room with name "..room)
				if new_room.contents == nil then
					new_room.contents = {}
				end

				-- Do any special processing for this room
				if new_room.contents.fn then
					new_room.contents.fn(new_room)
				end
				new_room.type = room --new_room.type or "normal"
				new_room.id = task.id .. ":" .. roomID .. ":" .. new_room.type
				new_room.task = task.id

				self:RunTaskSubstitution(task, new_room.contents.distributeprefabs)

				-- TODO: Move this to
				local extra_contents, extra_tags = self:GetExtrasForRoom(new_room)

				local newNode = task_node:AddNode({
					id = new_room.id,
					data = {
						type = new_room.entrance and "blocker" or new_room.type,
						colour = new_room.colour,
						value = new_room.value,
						internal_type = new_room.internal_type,
						tags = extra_tags,
						custom_tiles = new_room.custom_tiles,
						custom_objects = new_room.custom_objects,
						terrain_contents = new_room.contents,
						terrain_contents_extra = extra_contents,
						terrain_filter = self.terrain.filter,
						entrance = new_room.entrance
					}
				})

				table.insert(layout[layoutdepth], newNode)
				roomID = roomID + 1
			--end
		end
		layoutdepth = layoutdepth + 1
	end

	--link the nodes in a 'web'
	for depth = #layout, 2, -1 do
		--print("Linking " .. #layout[depth] .. " at depth " .. depth)
		for i = 1, #layout[depth], 1 do
			--link each task at this depth with a random task in the previous depth
			local node = math.floor(#layout[depth - 1] * ((i - 1) / #layout[depth]) + 1)
			--print(node .. " = " .. #layout[depth - 1] .. ", " .. i .. ", " .. #layout[depth])
			assert(1 <= node and node <= #layout[depth - 1])
			local roomnode = layout[depth][i]
			local roomnode2 = layout[depth - 1][node]

			--print("  Linking " .. roomnode.id .. " -> ".. roomnode2.id)
			task_node:AddEdge({node1id = roomnode.id, node2id = roomnode2.id})
		end

		--connect inner layer with itself
		for i = 2, #layout[1], 1 do
			local node1 = layout[1][1]
			local node2 = layout[1][i]
			--print("  Linking " .. node1.id .. " -> ".. node2.id)
			task_node:AddEdge({node1id = node1.id, node2id = node2.id})
		end

		--connect layer nodes
		for i = 2, #layout[depth] - 1, 1 do
			local node1 = layout[depth][i]
			local node2 = layout[depth][i + 1]
			--print("  Linking " .. node1.id .. " -> ".. node2.id)
			task_node:AddEdge({node1id = node1.id, node2id = node2.id})
		end
		--print("  Linking " .. layout[depth][ #layout[depth] ].id .. " -> ".. layout[depth][1].id)
		task_node:AddEdge({node1id = layout[depth][ #layout[depth] ].id, node2id = layout[depth][1].id})
	end

	--print(GetTableSize(task_node))
	return task_node
end

function BuildShipwreckedStory(tasks, story_gen_params, level)
	print("Building Shipwrecked Story", tasks)

	local story = Story("GAME", tasks, terrain, story_gen_params, level)
	story:GenerateNodesForIslands(level)
	story:AddRoadPoison()

	local min_bg = level.background_node_range and level.background_node_range[1] or 0
	local max_bg = level.background_node_range and level.background_node_range[2] or 2

	story:ShipwreckedAddBGNodes(min_bg, max_bg)
	story:ShipwreckedInsertAdditionalSetPieces()
	-- story:InsertAdditionalTreasures()  -- don't use, add treasures in postinit/map/graph  - Jerry
	story:ShipwreckedPlaceTeleportatoParts()
	story:ProcessWaterContent()
	story:InsertWaterSetPieces()


	return {root = story.rootNode, startNode = story.startNode, GlobalTags = story.GlobalTags, water = story.water_content}, story
end
