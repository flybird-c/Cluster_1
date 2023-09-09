---@diagnostic disable: lowercase-global
GLOBAL.setfenv(1, GLOBAL)

function c_checktile()
	local player = ConsoleCommandPlayer()
	if player then
		local x, y, z = player.Transform:GetLocalPosition()
		local tile = TheWorld.Map:GetTileAtPoint(x, y, z)

		for tile_name, num  in pairs(WORLD_TILES) do
			if tile == num then
				print(tile_name, num)
				break
			end
		end
	end
end

--This is for all players. If you don't care for entities, consider using
-- TheWorld.minimap.MiniMap:EnableFogOfWar(false)
function c_revealmap()
	local size = 2 * TheWorld.Map:GetSize()
	for _, player in pairs(AllPlayers) do
		for x = -size, size, 32 do
			for z = -size, size, 32 do
				player.player_classified.MapExplorer:RevealArea(x, 0, z)
			end
		end
	end

	print(TheWorld.Map:GetSize())
end

function c_poison()
	local player = ConsoleCommandPlayer()
	if player and player.components.poisonable then
		if player.components.poisonable:IsPoisoned() then
			player.components.poisonable:DonePoisoning()
		else
			player.components.poisonable:Poison()
		end
	end
end

function c_bermuda()
	if not TheWorld.ismastersim then return end
	local count = 0
	for k, v in pairs(Ents) do
		if v.prefab == "bermudatriangle" then
			v:Remove()
			count = count + 1
		end
	end
	print("Removed ".. count .." bermudatriangle. Spawning new ones...")

	local width, height = TheWorld.Map:GetSize()

	local function checkTriangle(tile, x, y, points)
		if  tile ~= WORLD_TILES.OCEAN_DEEP then
			return false
		end
		for i = 1, #points, 1 do
			local dx = x - points[i].x
			local dy = y - points[i].y
			local dsq = dx * dx + dy * dy

			if dsq < 50 * 50 then
				return false
			end
		end
		return true
	end

	local points = FindRandomWaterPoints(checkTriangle, TUNING.MAPEDGE_PADDING, 12)

	--convert to entity coords
	for i = 1, #points, 1 do
		points[i].x = (points[i].x - width/2.0)*TILE_SCALE
		points[i].y = (points[i].y - height/2.0)*TILE_SCALE
	end
	---------------------------------
	print(#points .. " points for bermudatriangle")
	if #points < 2 then return print("WARNING: Not enough points for new bermudatriangle") end

	local pair = 0
	local min_distsq = 200 * 200
	local is_farenough = function( marker1, marker2)
		local diffx, diffz = marker2.x - marker1.x, marker2.y - marker1.y
		local mag = diffx * diffx + diffz * diffz
		if mag < min_distsq then
			return false
		end
		return true
	end

	for i = #points, 1, -1 do
		if points[i] then --might be removed already
			for j = #points, 1, -1 do
				if points[j] and i ~= j and is_farenough(points[i], points[j]) then
					local berm1 = SpawnPrefab("bermudatriangle")
					berm1.Transform:SetPosition(points[i].x, 0, points[i].y)
					local berm2 = SpawnPrefab("bermudatriangle")
					berm2.Transform:SetPosition(points[j].x, 0, points[j].y)

					berm1.components.teleporter:Target(berm2)
					berm2.components.teleporter:Target(berm1)

					pair = pair + 1

					table.remove(points, i)
					table.remove(points, j)

					break
				end
			end
		end
	end
	print(pair .. " bermudatriangle pairs placed.")

end

function c_octoking()
	c_spawn('octopusking')
	c_give('californiaroll', 1)
	c_give('seafoodgumbo', 1)
	c_give('bisque', 1)
	c_give('jellyopop', 1)
	c_give('ceviche', 1)
	c_give('surfnturf', 1)
	c_give('wobsterbisque', 1)
	c_give('wobsterdinner', 1)
	c_give('caviar', 1)
	c_give('tropicalbouillabaisse', 1)
	c_give('sharkfinsoup', 1)
end

function c_givetreasuremaps()
	local player = ConsoleCommandPlayer()
	local x,y,z = player.Transform:GetWorldPosition()
	local treasures = TheSim:FindEntities(x, y, z, 10000, {"buriedtreasure"}, {"linktreasure"})
	print("Found " .. #treasures .. " treasures")
	if treasures and type(treasures) == "table" and #treasures > 0 then
		for i = 1, #treasures, 1 do
		local bottle = SpawnPrefab("ia_messagebottle")
		bottle.Transform:SetPosition(x, y, z)
		bottle.treasure = treasures[i]
		if bottle.treasure.debugname then
			bottle.debugmsg = "It's a map to '" .. bottle.treasure.debugname .. "'"
		end
		player.components.inventory:GiveItem(bottle)
		end
	end
end

function c_revealtreasure()
	local player = ConsoleCommandPlayer()
	local x,y,z = player.Transform:GetWorldPosition()
	local treasures = TheSim:FindEntities(x, y, z, 10000, {"buriedtreasure"})
	print("Found " .. #treasures .. " treasures")
	if treasures and type(treasures) == "table" and #treasures > 0 then
		for i = 1, #treasures, 1 do
			treasures[i]:Reveal(treasures[i])
			treasures[i]:RevealFog(treasures[i])
		end
	end
end

function c_erupt()
	local vm = TheWorld.components.volcanomanager
	if vm then
		vm:StartEruption(60.0, 60.0, 60.0, 1 / 8)
	end
end

function c_hurricane(duration_override)
	TheWorld:PushEvent("ms_forcehurricane",  duration_override)
end

function c_kraken()
	local player = ConsoleCommandPlayer()
	local krakener = TheWorld.components.krakener
	if krakener then
    	TheWorld.components.krakener:DoKrakenEvent(true, player)
	end
end

-- function c_treasuretest()
	-- local l = GetTreasureLootDefinitionTable()

	-- for name, data in pairs(l) do
		-- if type(data) == "table" then

			-- if type(data.loot) == "table" then
				-- for k, _ in pairs(data.loot) do
					-- c_prefabexists(k)
				-- end
			-- end
			-- if type(data.random_loot) == "table" then
				-- for k, _ in pairs(data.random_loot) do
					-- c_prefabexists(k)
				-- end
			-- end
			-- if type(data.chance_loot) == "table" then
				-- for k, _ in pairs(data.chance_loot) do
					-- c_prefabexists(k)
				-- end
			-- end
		-- end
	-- end

	-- local t = GetTreasureDefinitionTable()
	-- local obj_layout = require("map/object_layout")

	-- for name, data in pairs(t) do
		-- if type(data) == "table" then
			-- for i, stage in ipairs(data) do
				-- if type(stage) == "table" then
					-- if stage.treasure_set_piece then
						-- obj_layout.LayoutForDefinition(stage.treasure_set_piece)
					-- end
					-- if stage.treasure_prefab then
						-- c_prefabexists(stage.treasure_prefab)
					-- end
					-- if stage.map_set_piece then
						-- obj_layout.LayoutForDefinition(stage.map_set_piece)
					-- end
					-- if stage.map_prefab then
						-- c_prefabexists(stage.map_prefab)
					-- end
					-- if stage.tier == nil then
						-- if stage.loot == nil then
							-- print("missing loot!", name)
						-- elseif l[stage.loot] == nil then
							-- print("missing loot!", name, stage.loot)
						-- end
					-- end
				-- end
			-- end
		-- end
	-- end
-- end

function c_spawntreasure(name)
	local x = c_spawn("buriedtreasure")
	x:Reveal()
	if name then
		x.loot = name
	else
		local treasures = GetTreasureLootDefinitionTable()
		local treasure = GetRandomKey(treasures)
		x.loot = treasure
	end
end

function c_flood()
	local player = ConsoleCommandPlayer()
	local pt = player and player:GetPosition() or {x=0,z=0}
	TheWorld.components.monsoonflooding:SpawnPuddle(pt.x, 0, pt.z)
end

function c_dryflood()
    TheWorld.components.monsoonflooding:OnUpdate(150)
end

function c_growflood()
    TheWorld.components.monsoonflooding:OnUpdate(35)
end

function c_dryallflood()
    for i = 1, 15 do TheWorld.components.monsoonflooding:OnUpdate(150) end
end

function c_growallflood()
    for i = 1, 15 do TheWorld.components.monsoonflooding:OnUpdate(35) end
end

function c_removeallflood()
	TheWorld.components.monsoonflooding:RemoveAllPuddles()
end

function c_test_flood_visual()
	local fx, fy = TheWorld.components.flooding:GetFloodCoordsAtPoint(ThePlayer.Transform:GetWorldPosition())
	SetParticleTileState("flood", fx, fy, true)
end

function c_test_flood_visual_lifetimes()
	local fx, fy = TheWorld.components.flooding:GetFloodCoordsAtPoint(ThePlayer.Transform:GetWorldPosition())
	Debug_ViewFloodLifetimeGrid("flood", fx, fy)
end

--------------------------------------------------------------------------

local unpack = unpack

--------------------------------------------------------------------------
local ConsoleScreen = require("screens/consolescreen")
local TextEdit = require "widgets/textedit"

local prediction_command = {
    "checktile", "revealmap","poison", "bermuda", "octoking",
    "givetreasuremaps", "revealtreasure", "erupt", "hurricane",
    "kraken", "spawntreasure", "flood", "dryflood", "growflood", 
    "growallflood", "dryallflood", "removeallflood",
}

local _DoInit = ConsoleScreen.DoInit
function ConsoleScreen:DoInit(...)
    
    -- Hacky but for some reason I cannot add more commands after the DoInit and cant find out why, neither can Hornet
    local _AddWordPredictionDictionary = TextEdit.AddWordPredictionDictionary
    function TextEdit:AddWordPredictionDictionary(data, ...)
        if data.words and data.delim ~= nil and data.delim == "c_" then
            for k, v in pairs(prediction_command) do
                table.insert(data.words, v)
            end
        end
        
        return _AddWordPredictionDictionary(self, data, ...)
    end

    local rets = {_DoInit(self, ...)}

    TextEdit.AddWordPredictionDictionary = _AddWordPredictionDictionary

    return unpack(rets)
end
