---@diagnostic disable: lowercase-global
local function en_zh(en, zh)  -- Other languages don't work
    return (locale == "zh" or locale == "zhr" or locale == "zht") and zh or en
end

-- Mod Name
name = en_zh("Island Adventures - Shipwrecked", "岛屿冒险")
-- Mod Authors
author = "The Island Adventures Team"

-- Mod Version
version = "0.12.05"
version_title = en_zh("Uncharted Waters", "未知水域")

-- Mod Description
description = en_zh(
	"Embark on a tropical journey across the seas, Together! Island Adventures brings the archipelago of Don't Starve: Shipwrecked to you!\n\nShould you encounter a problem, please tell us everything about the problem so we can repair things!",
	"一起踏上穿越海洋的热带之旅！岛屿冒险为你带来饥荒：海难的海洋!\n\n 如果你遇到问题,请告诉我们有关问题的一切，这样我们就可以修复它\n\n"
)

description = description .. "\n\nVersion: " .. version .. "\n\"" .. version_title .. "\""

-- In-game link to a thread or file download on the Klei Entertainment Forums
-- The fourm thread is so outdated....
forumthread = "" -- "/topic/95080-island-adventures-the-shipwrecked-port/"

IslandAdventures = true

folder_name = folder_name or "workshop-"
if not folder_name:find("workshop-") then
	--name = "1 " .. name .. " - GitLab Ver." -- DST mod menu now natively supports pinning mods to top.
	name = name .. " - GitLab Ver." -- DST mod menu now natively supports pinning mods to top.
	description = description .. "\n\nRemember to manually update! The version number does NOT increase with every gitlab update."
	IslandAdventuresGitlab = true
end

-- Don't Starve API version
-- Note: We set this to 10 so that it's incompatible with single player.
api_version = 10
-- Don't Starve Together API version
api_version_dst = 10

-- Priority of which our mod will be loaded
-- Below 0 means other mods will override our mod by default.
-- Above 0 means our mod will override other mods by default.
priority = 2

-- Forces user to reboot game upon enabling the mod
restart_required = false

-- Engine/DLC Compatibility
-- Don't Starve (Vanilla, no DLCs)
dont_starve_compatible = false
-- Don't Starve: Reign of Giants
reign_of_giants_compatible = false
-- Don't Starve: Shipwrecked
shipwrecked_compatible = false
-- Don't Starve Together
dst_compatible = true

-- Client-only mods don't affect other players or the server.
client_only_mod = false
-- Mods which add new objects are required by all clients.
all_clients_require_mod = true

-- Server search tags for the mod.
server_filter_tags =
{
    "island_adventures",
	"island adventures",
	"island",
	"adventures",
	"shipwrecked",
}

-- Preview image
icon_atlas = "ia-icon.xml"
icon = "ia-icon.tex"

mod_dependencies = {
    {--GEMCORE
        workshop = "workshop-1378549454",
        ["GemCore"] = false,
        ["[API] Gem Core - GitLab Version"] = true,
    },
}

local options_enable = {
	{description = en_zh("Disabled", "关闭"), data = false},
	{description = en_zh("Enabled", "开启"), data = true},
}

local options_count = {
	{description = en_zh("Disabled", "关闭"), data = false},
	{description = "1", data = "1"},
	{description = "2", data = "2"},
	{description = "3", data = "3"},
	{description = "4", data = "4"},
	{description = "5", data = "5"},
}

-- Thanks to the Gorge Extender by CunningFox for making me aware of this being possible -M
local function Breaker(title_en, title_zh)  --hover does not work, as this item cannot be hovered
	return {name = en_zh(title_en, title_zh) , options = {{description = "", data = false}}, default = false}
end

configuration_options =
{
	Breaker("Gameplay Features", "游戏功能"),
	{
		name = "newloot",
		label = en_zh("Treasures", "宝藏类型"),
        hover = en_zh("Changes what kinds of treasures spawn from treasure hunting.", "改变寻宝过程中产生的宝藏种类"),
        options =
        {
			{
				description = en_zh("DST + SW"),
				hover = en_zh("Treasures from original SW along with new ones with DST loot.", "来自SW的宝藏以及带有DST战利品的新宝藏"),
				data = "all"
			},
			{
				description = en_zh("No Orb", "无天体球"),
				hover = en_zh("DST + SW, but without Celestial Orb.", "DST+SW,但没有天体球"),
				data = "part"
			},
            {	description = en_zh("SW"),
				hover = en_zh("Only treasures from original SW.", "只有来自SW原版的宝藏"),
				data = "vanilla"
			},
        },
		default = "all"
	},
	{
        name = "octopustrade",
        label = en_zh("Additional Yaarctopus Trades", "章鱼王交易补充"),
        hover = en_zh("Allows to trade rest of Shipwrecked dishes to Yaarctopus for various items.", "与章鱼王交易给予一些新物品"),
    },
	{
        name = "slotmachineloot",
        label = en_zh("Additional Slot Machine Loot", "老虎机掉落补充"),
        hover = en_zh("Adds new prizes to Slot Machine.", "为老虎机添加新掉落"),
    },

	Breaker("Character Refreshes", "人物修改"),
	{
		name = "oldwarly",
		label = en_zh("Pre-Official Warly", "旧版沃利"),
        hover = en_zh("This mod had Warly before he was announced as an official DST character. Use this option to restore the IA Warly.", "使用IA旧版沃利"),
		default = false
	},

	Breaker("Mobs", "生物改变"),
	{
		name = "octopuskingtweak",
		label = en_zh("Yaarctopus Multiplayer Trading", "章鱼王多人交易"),
        hover = en_zh(
			"Yaarctopus now can trade with each player once per day, instead of being able to trade just only once per day.",
			"章鱼王现在每天可以和每个玩家交易一次,而不是每天只能交易一次。"
		),
	},
	{
		name = "pondfishable",
		label = en_zh("RoT-Style Fish", "RoT型鱼类"),
        hover = en_zh("SW Fish will have alive/dead states just like the rest of the DST Fish.", "SW鱼将具有与其他DST鱼一样的活/死状态"),
	},
	{
		name = "tuningmodifiers",
		label = en_zh("Combat Modifiers", "战斗调整"),
		hover = en_zh(
			"Monsters have more health, bosses deal less damage, and armour breaks faster. Klei decided that, we're just playing along.",
			"怪物的生命值更高,BOSS造成的伤害更少,盔甲被破坏的速度更快"
		),
	},

	Breaker("Items & Structures", "物品和建筑"),
	{
		name = "newplayerboats",
		label = en_zh("Free Rafts", "免费木筏"),
        hover = en_zh("Players will be given a pre-crafted Log Raft on new join or resurrection.", "玩家在新加入或复活时将获得一个预先制作的木筏"),
	},
	{
		name = "windgustable",
		label = en_zh("Wind Mechanics", "风力学"),
        hover = en_zh("Choose what can be affected by strong winds, mainly for builders and people who are experiencing lag.", "选择受强风影响的物品，主要针对建筑和刮风很卡的人"),
        options =
        {
			{
				description = en_zh("All", "所有"),
				hover = en_zh("Wind affects everything as normal.", "所有东西都会受到风的影响") ,
				data = "all"
			},
			{
				description = en_zh("NoWalls", "排除墙"),
				hover = en_zh("Walls won't be damaged by strong winds.", "墙不会被强风破坏"),
				data = "nowalls"
			},
			{
				description = en_zh("NoItems", "排除物品"),
				hover = en_zh("Items won't be blown by strong winds.", "物品不会被强风吹走，可能有助于缓解卡顿"),
				data = "noitems"
			},
			{
				description = en_zh("NoWalls-NoItems", "排除墙和物品"),
				hover = en_zh("Walls won't be damaged and items won't be blown.", "物品不会被强风吹走，墙不会被强风破坏"),
				data = "nowallsnoitems"
			},
            {	description = en_zh("None", "关闭所有"),
				hover = en_zh("Nothing will be picked, hacked, choped, hammered or blown by strong winds.", "风不会影响任何事物,包括人物的移速"),
				data = "none"
			},
        },
		default = "all",
	},
	{
		name = "limestonerepair",
		label = en_zh("Limestone Repairs", "石灰石墙的修补"),
        hover = en_zh("Coral and Limestone can be used to repair Limestone Walls and Sea Walls.", "珊瑚和石灰石可用于修复石灰岩墙和海上墙"),
	},
    {
        name = "droplootground", --could be extended to other loot too
        label = en_zh("Drop Hacked Bamboo & Vines", "掉落竹子和藤蔓"),
        hover   = en_zh("Hacking Bamboo & Vines does not give the loot directly to the hacker, instead drops it on the floor.", "砍伐竹子和藤蔓掉落在地上，而不是直接进入玩家背包"),
    },
	{
		name = "windstaffbuff",
		label = en_zh("Sail Stick Speed Bonus", "桅杆加速效果"),
        hover = en_zh("Strong Winds affected by the Sail Stick are stronger than normal, making users faster.", "选择桅杆的加速倍数"),
        options =
        {
			{description = "None", data = 1},
			{description = "1.5x", data = 1.5},
			{description = "2x", data = 2},
            {description = "3x", data = 3},
        },
		default = 2,
	},

	Breaker("Cut Content Restoration", "Cut Content Restoration"),
    {
        name = "leif_jungle",
        label = en_zh("Jungle Treeguard", "Jungle Treeguard"),
        hover = en_zh("Re-adds the fearsome snake-slinging treeguard", "Re-adds the fearsome snake-slinging treeguard"),
        default = false,
    },

	Breaker("Misc.", "杂项"),
    {
        name = "locale",
        label = en_zh("Force Translation", "强制翻译"),
        hover = en_zh("Select a translation to enable it regardless of language packs.", "选择翻译以启用它，而不是自动"),
        options =
		{
			{description = "None", data = false},
			{description = "Deutsch", data = "de"},
			{description = "Español", data = "es"},
			{description = "Français", data = "fr"},
			{description = "Italiano", data = "it"},
			{description = "한국어", data = "ko"},
			{description = "Polski", data = "pl"},
			{description = "Português", data = "pt"},
			{description = "Русский", data = "ru"},
			{description = "中文 (简体)", data = "sc"},
			{description = "中文 (繁体)", data = "tc"},
		},
        default = false,
    },
    {
        name = "dynamicmusic",
        label = en_zh("Dynamic Music", "音乐"),
        hover   = en_zh("If you have problems using IA with other Music Mods, disable this. The unique Combat and Work music will not play.", "若与其他音乐MOD一起使用时遇到问题,请禁用此功能。海难音乐不会播放"),
    },
	{
		name = "devmode",
		label = en_zh("Dev Mode", "开发模式"),
        hover = en_zh("Enable this to turn your keyboard into a minefield of crazy debug hotkeys. (Only use if you know what you are doing!)"),
		default = false,
	},

	Breaker("4 Shard Dedicated Servers", "多(三层以上)世界选项,不要乱改"),
	{
		name = "quickseaworthy",
		label = en_zh("Quick Seaworthy Travel", "快速传送"),
        hover = en_zh(
			"Skips the animation of Seaworthy and instantly teleports the player to another shard when Seaworthy is used.",
			"跳过海洋之椅动画,并在使用时立即将玩家传送到另一个世界。"
		),
		default = false,
	},
	{
		name = "forestid",
		label = en_zh("Forest Shard ID", "森林世界ID"),
        hover = en_zh("Using Seaworthy in Shipwrecked Shard will send players to Forest Shard with corresponding ID. (Change this config only if you know what you are doing!)", "使用海洋之椅时会将在海难的玩家传送到所选的id对应的世界"),
        options = options_count,
		default = false,
	},
	{
		name = "caveid",
		label = en_zh("Cave Shard ID", "洞穴世界ID"),
        hover = en_zh("Using Cave Entrances in Forest Shard will send players to Cave Shard with corresponding ID. (Change this config only if you know what you are doing!)", "使用洞穴时会将玩家传送到所选的id对应的世界"),
        options = options_count,
		default = false,
	},
	{
		name = "shipwreckedid",
		label = en_zh("Shipwrecked Shard ID", "海难世界ID"),
        hover = en_zh("Using Seaworthy in Forest Shard will send players to Shipwrecked Shard with corresponding ID. (Change this config only if you know what you are doing!)", "使用海洋之椅时会将在联机世界的玩家传送到所选的id对应的世界"),
        options = options_count,
		default = false,
	},
	{
		name = "volcanoid",
		label = en_zh("Volcano Shard ID", "火山世界ID"),
        hover = en_zh("Travelling via Volcano will send player to Volcano Shard with corresponding ID. (Change this config only if you know what you are doing!)", "使用火山时会将玩家传送到所选的id对应的世界"),
        options = options_count,
		default = false,
	},
    	-- {
		-- name = "codename",
		-- label = "Fancy Name",
        -- hover = "This sentence explains the option in greater detail.",
		-- options =
		-- {
			-- {description = "Disabled", data = false},
			-- {description = "Enabled", data = true},
		-- },
		-- default = false,
	-- },
}

-- Add default settings for options, don't have to rewrite same every time
for i = 1, #configuration_options do
	configuration_options[i].options = configuration_options[i].options or options_enable
	configuration_options[i].default = configuration_options[i].default == nil and true or configuration_options[i].default
end
