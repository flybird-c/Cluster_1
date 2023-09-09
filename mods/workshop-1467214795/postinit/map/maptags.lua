local MapTagger = gemrun("map/maptagger")

local Terrarium_Spawners_Shipwrecked = 
{
	"Terrarium_Jungle_Snakes", 
	"Terrarium_Jungle_Spiders", 
	"Terrarium_Jungle_Fire"
}

MapTagger.AddMapData("Packim_Fishbone", true)
MapTagger.AddMapData("Terrarium_Spawner_Shipwrecked", true)

MapTagger.AddMapTag("Packim_Fishbone", function(tagdata)
	if tagdata["Packim_Fishbone"] == false then
		return
	end
	tagdata["Packim_Fishbone"] = false
	return "ITEM", "packim_fishbone"
end)

MapTagger.AddMapTag("Terrarium_Spawner_Shipwrecked", function(tagdata, level)
	if tagdata["Terrarium_Spawner_Shipwrecked"] == false then
		return
	end
	tagdata["Terrarium_Spawner_Shipwrecked"] = false

	if level ~= nil and level.overrides ~= nil and level.overrides.terrariumchest == "never" then
		return
	end

	return "STATIC", Terrarium_Spawners_Shipwrecked[math.random(#Terrarium_Spawners_Shipwrecked)]
end)

MapTagger.AddMapTag("islandclimate", function(tagdata)
    return "TAG", "islandclimate"
end)

MapTagger.AddMapTag("volcanoclimate", function(tagdata)
    return "TAG", "volcanoclimate"
end)