chestfunctions = require("scenarios/chestfunctions")

local function OnCreate(inst, scenariorunner)

	local items =
	{
		{
			item = "terrarium",
		},
		{
			--Weapon Items
			item = {"spear_poison", "blowdart_flup", "peg_leg", "cutless", "fireflies", "palmleaf_umbrella", "papyrus", },
		},
		{
			item = "coconade",
			chance = 1/3,
		},
		{
			item = "snakeskin",
			count = math.random(1, 2),
			chance = 1/2,
		},
		{
			item = "antivenom",
			count = math.random(1, 2),
			chance = 1/2,
		},
		{
			item = {"torch", "ia_messagebottleempty" },
			chance = 1/2,
		},
		{
			item = "dubloon",
			count = math.random(6, 15),
			chance = 1/2,
		},
		{
			item = "vine",
			count = math.random(4, 10),
			chance = 1/2,
		},
		{
			item = "bamboo",
			count = math.random(4, 10),
			chance = 1/2,
		},

	}
	chestfunctions.AddChestItems(inst, items)

end

local function OnLoad(inst, scenariorunner)
	-- dummy function so the component doesnt get removed right away so that the terrariumchest_fx can test if they should be created or not
    chestfunctions.InitializeChestTrap(inst, scenariorunner, function() end, 0.0)
end

return
{
	OnLoad = OnLoad,
	OnCreate = OnCreate,
}
