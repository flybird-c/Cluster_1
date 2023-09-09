GLOBAL.setfenv(1, GLOBAL)

return {

    ACTIONS = {
        -- gotta rewrite walkthrough to be generic -Half
        WALKTO = {
            GENERIC = type(STRINGS.ACTIONS.WALKTO) == "string" and STRINGS.ACTIONS.WALKTO or nil,
            SURFTO = "Surf to",
            SAILTO = "Sail to",
            ROWTO = "Row to",
            SWIMTO = "Swim to"
        },
        JUMPIN = {
            BERMUDA = "Enter"
        },
        ACTIVATE = {
            SAND = "Destroy"
        },
        RUMMAGE = {
            INSPECT = "Inspect"
        },
        UNWRAP = {
            -- if somebody already made this a table, don't overwrite any of their changes -M
            GENERIC = type(STRINGS.ACTIONS.UNWRAP) == "string" and STRINGS.ACTIONS.UNWRAP or nil,
            OPENCAN = "Open" -- tunacan
        },
        PACKUP = STRINGS.ACTIONS.PICKUP,
        OPEN_CRAFTING = {
            FORGING = "Forge with",
        },
        DISEMBARK = "Disembark",
        FISH = {
            GENERIC = type(STRINGS.ACTIONS.FISH) == "string" and STRINGS.ACTIONS.FISH or nil,
            RETRIEVE = "Retrieve",
        },
        UNEQUIP = {
            TRAWLNET = "Detach",
        },
        NAME_BOAT = "Name Boat",
        CUREPOISON = {
            GENERIC = "Quaff",
            GLAND = "Ingest",
        },
        EMBARK = {
            GENERIC = "Embark",
            SURF = "Surf",
        },
        DEPLOY = {
            LAUNCH = "Launch",
        },
        GIVE = {
            PLACE = "Place",
            READY = "Sacrifice",
            CURRENCY = "Spend",
            LOAD = "Load",
        },
        READMAP = "Read",
        RETRIEVE = "Retrieve",
        PEER = "Peer",
        TOGGLEON = "Turn On",
        TOGGLEOFF = "Turn Off",
        STICK = "Plant Stick",
        THROW = "Throw At",
        LAUNCH_THROWABLE = "Launch",
        FISH_FLOTSAM = "Retrieve", --"Fish" in ds
        HACK = "Hack",
    },

    SKIN_NAMES = {
        --Characters
        walani_none = "Walani",
        -- warly_none = "Warly",
        wilbur_none = "Wilbur",
        woodlegs_none = "Woodlegs",

        --Belongings

    },

    SKIN_DESCRIPTIONS = {
        --Characters
        walani_none = "A lazy look for a lazy lass.",
        wilbur_none = "Wilbur's standard stranded attire.",
        woodlegs_none = "The usual look of a seafaring pirate.",

        --Belongings

    },

    CHARACTER_NAMES = {
        walani = "Walani",
        -- warly = "Warly",
        wilbur = "Wilbur",
        woodlegs = "Woodlegs"
    },

    CHARACTER_QUOTES = {
        walani = "\"Forgive me if I don't get up. I don't want to.\"",
        -- warly = "\"Nothing worthwhile is ever done on an empty stomach!\"",
        wilbur = "\"Ooo ooa oah ah!\"",
        woodlegs = "\"Don't ye mind th'scurvy. Yarr-harr-harr!\""
    },

    CHARACTER_TITLES = {
        walani = "The Unperturbable",
        -- warly = "The Culinarian",
        wilbur = "The Monkey King",
        woodlegs = "The Pirate Captain"
    },

    --[[
    LAVAARENA_CHARACTER_DESCRIPTIONS = {
        walani = "",
        -- warly = "",
        wilbur = "",
        woodlegs = ""
    },

    QUAGMIRE_CHARACTER_DESCRIPTIONS = {
        walani = "",
        -- warly = "",
        wilbur = "",
        woodlegs = ""
    },
    --]]

    CHARACTER_ABOUTME = {
        walani = "A temperate, easygoing surfer with a love for keeping it chill. Walani relishes in the art of doing nothing at all.",
        -- warly = "",
        wilbur = "One might question why you'd let a monkey run freely throughout the Constant. Wilbur will not answer this.",
        woodlegs = "Woodlegs is a seasoned, sea-faring pirate on a never ending journey for all treasure he sees fit.",
    },

    CHARACTER_BIOS = {
        walani = {
            { title = "Birthday", desc = "December 17" },
            { title = "Favorite Food", desc = "Seafood Gumbo" },
            { title = "Her past...", desc = "Is yet to be revealed" },
        },
        -- warly = {
        --     { title = "Birthday", desc = "Unknown" },
        --     { title = "Favorite Food", desc = "" },
        --     { title = "His past...", desc = "Is yet to be revealed" },
        -- },
        wilbur = {
            { title = "Birthday", desc = "February 4" },
            { title = "Favorite Food", desc = "Raw and Cooked Bananas" },
            { title = "His past...", desc = "Is yet to be revealed" },
        },
        woodlegs = {
            { title = "Birthday", desc = "September 19" },
            { title = "Favorite Food", desc = "Banana Shake" },
            { title = "His past...", desc = "Is yet to be revealed" },
        },
    },

    CHARACTER_DESCRIPTIONS = {
        walani = "*Loves surfing\n*Dries off quickly\n*Is a pretty chill gal",
        -- warly = "*Has a refined palate\n*Cooks in custom kitchenware\n*Brings a stylish chef pouch",
        wilbur = "*Can't talk\n*Slow as biped, but fast as quadruped\n*Is a monkey",
        woodlegs = "*Can sniff out treasure\n*Captain of the \"Sea Legs\"\n*Pirate"
    },

    CHARACTER_SURVIVABILITY = {
        walani = "Slim",
        wilbur = "Slim",
        woodlegs = "Grim",
    },

    FLOODEDITEM = "Flooded",
    GOURMETPREFIX = "Gourmet ", -- Please note that the space is intentional, so translations may use hyphons or whatever -M
    GOURMETGENERIC = "Dish", -- failsafe, in case the original name is invalid

    NAMES = {
        WALANI = "Walani",
        -- WARLY = "Warly",
        WILBUR = "Wilbur",
        WOODLEGS = "Woodlegs",

        DROWNING = "Drowning",
        POISON = "Poison",

        CRAB = "Crabbit",
        CRABHOLE = "Crabbit Den",
        CRAB_HIDDEN = "Shifting Sands",
        SAND = "Sand",
        SANDDUNE = "Sandy Pile", -- Changed from "Sandy Dune"

        ROCK_CORAL = "Coral Reef",
        CORAL = "Coral",
        CRITTERLAB_WATER = "Coral Den",

        BARREL_GUNPOWDER = "Gunpowder Barrel", -- Changed from "Barrel o' Gunpowder"
        BARREL_GUNPOWDER_LAND = "Gunpowder Barrel",

        SEAWEED = "Seaweed",
        SEAWEED_COOKED = "Roasted Seaweed", -- Changed from "Cooked Seaweed"
        SEAWEED_DRIED = "Dried Seaweed",
        SEAWEED_PLANTED = "Seaweed",

        LIMESTONE = "Limestone",
        LIMESTONENUGGET = "Limestone",

        SWORDFISH = "Swordfish",
        SWORDFISH_DEAD = "Dead Swordfish", -- Changed from "Swordfish"
        SOLOFISH = "Dogfish",
        SOLOFISH_DEAD = "Dead Dogfish", -- Changed from "Dogfish"

        FISHINHOLE = "Shoal", -- Changed from "School of Fish"

        FISH_TROPICAL = "Tropical Fish",
        PONDFISH_TROPICAL = "Tropical Fish",

        PURPLE_GROUPER = "Purple Grouper",
        PIERROT_FISH = "Pierrot Fish",
        NEON_QUATTRO = "Neon Quattro",

        PONDPURPLE_GROUPER = "Live Purple Grouper",
        PONDPIERROT_FISH = "Live Pierrot Fish",
        PONDNEON_QUATTRO = "Live Neon Quattro",

        PURPLE_GROUPER_COOKED = "Cooked Purple Grouper",
        PIERROT_FISH_COOKED = "Cooked Pierrot Fish",
        NEON_QUATTRO_COOKED = "Cooked Neon Quattro",

        DST_FISHINGROD = STRINGS.NAMES.FISHINGROD,
        DST_OCEANFISHINGROD = STRINGS.NAMES.OCEANFISHINGROD,
        IA_FISHINGROD = "Simple Fishing Rod",
        IA_OCEANFISHINGROD = "Advanced Fishing Rod",

        SPOILED_FISH_LARGE = "Large Spoiled Fish",

        BOAT_RAFT = "Raft",
        BOAT_LOGRAFT = "Log Raft",
        BOAT_ROW = "Row Boat",
        BOAT_CARGO = "Cargo Boat",
        BOAT_ARMOURED = "Armored Boat", -- "Armoured Boat", renamed to be more consistent
        BOAT_ENCRUSTED = "Encrusted Boat",
        BOAT_SURFBOARD = "Surfboard",
        SURFBOARD_ITEM = "Surfboard",
        BOAT_WOODLEGS = "The \"Sea Legs\"",

        SAIL_PALMLEAF = "Thatch Sail",
        SAIL_CLOTH = "Cloth Sail",
        SAIL_SNAKESKIN = "Snakeskin Sail",
        SAIL_FEATHER = "Feather Lite Sail",
        IRONWIND = "Iron Wind",
        BOAT_LANTERN = "Boat Lantern",
        TRAWLNET = "Trawl Net",
        TRAWLNETDROPPED = "Trawl Net",
        BOATCANNON = "Boat Cannon",
        CANNONSHOT = "Cannonball",
        WOODLEGS_CANNONSHOT = "Cannonball",

        BUSH_VINE = "Viney Bush",
        SNAKEDEN = "Viney Bush",
        VINE = "Vine",
        DUG_BUSH_VINE = "Viney Bush Root",

        BAMBOOTREE = "Bamboo Patch",
        BAMBOO = "Bamboo",

        MUSSEL = "Mussel",
        MUSSEL_COOKED = "Cooked Mussel",
        MUSSEL_STICK = "Mussel Stick",
        MUSSEL_FARM = "Mussels",

        IA_MESSAGEBOTTLE = "Message in a Bottle",
        IA_MESSAGEBOTTLEEMPTY = "Empty Bottle",
        BURIEDTREASURE = "X Marks the Spot",

        -- These are copied over from SW directly and haven't really been looked at yet

        TURF_BEACH = "Beach Turf",
        TURF_JUNGLE = "Jungle Turf",
        TURF_SWAMP = "Swamp Turf",

        TURF_VOLCANO = "Volcano Turf",
        TURF_ASH = "Ashy Turf",
        TURF_MAGMAFIELD = "Magma Turf",
        TURF_TIDALMARSH = "Tidal Marsh Turf",
        TURF_MEADOW = "Meadow Turf",

        PORTAL_SHIPWRECKED = "Malfunctioning Novelty Ride",

        BOOK_METEOR = "Joy of Volcanology",

        TRINKET_IA_13 = "Orange Soda",
        TRINKET_IA_14 = "Voodoo Doll",
        TRINKET_IA_15 = "Ukulele",
        TRINKET_IA_16 = "License Plate",
        TRINKET_IA_17 = "Old Boot",
        TRINKET_IA_18 = "Ancient Vase",
        TRINKET_IA_19 = "Brain Cloud Pill",
        TRINKET_IA_20 = "Sextant",
        TRINKET_IA_21 = "Toy Boat",
        TRINKET_IA_22 = "Wine Bottle Candle",
        TRINKET_IA_23 = "Broken AAC Device", -- AAC = Augmentative and Alternative Communication

        SUNKEN_BOAT_TRINKET_1 = "Sextant",
        SUNKEN_BOAT_TRINKET_2 = "Toy Boat", -- "Prototype 0021",
        SUNKEN_BOAT_TRINKET_3 = "Soaked Candle",
        SUNKEN_BOAT_TRINKET_4 = "Sea Worther",
        SUNKEN_BOAT_TRINKET_5 = "Old Boot",

        PRIMEAPE = "Prime Ape",
        PRIMEAPEBARREL = "Prime Ape Hut",
        WILDBOREHOUSE = "Wildbore House",
        WILDBORE = "Wildbore",
        WILDBOREGUARD = "Wildbore Guard",
        WOODLEGS_CAGE = "Woodlegs' Cage",
        WOODLEGS_KEY1 = "Bone Key",
        WOODLEGS_KEY2 = "Golden Key",
        WOODLEGS_KEY3 = "Iron Key",
        BERRYBUSH_SNAKE = "Berry Bush",
        BERRYBUSH2_SNAKE = "Berry Bush",
        DOYDOY = "Doydoy",
        DOYDOYBABY = "Baby Doydoy",
        DOYDOYTEEN = "Teen Doydoy",
        DOYDOYEGG = "Doydoy Egg",
        DOYDOYEGG_CRACKED = "Cracked Doydoy Egg",
        DOYDOYEGG_COOKED = "Fried Doydoy Egg",
        DOYDOYNEST = "Doydoy Nest",
        DOYDOYFEATHER = "Doydoy Feather",
        DUG_BAMBOOTREE = "Bamboo Root",
        PALMLEAF_HUT = "Palm Leaf Hut",
        PALMLEAF_UMBRELLA = "Palm Leaf Umbrella",
        THATCHPACK = "Thatch Pack",
        GRASS_WATER = "Grass",

        PIRATEPACK = "Booty Bag",
        PEG_LEG = "Peg Leg",

        SEASHELL = "Seashell",
        SEASHELL_BEACHED = "Seashell",
        PALMTREE = "Palm Tree",
        LEIF_PALM = "Treeguard",
        COCONUT = "Coconut",
        COCONUT_SAPLING = "Palm Tree Sapling",
        COCONUT_HALVED = "Halved Coconut",
        COCONUT_COOKED = "Roasted Coconut",

        MACHETE = "Machete",
        GOLDENMACHETE = "Luxury Machete",
        TELESCOPE = "Spyglass",
        SUPERTELESCOPE = "Super Spyglass",
        BERMUDATRIANGLE = "Electric Isosceles",
        SANDBAG = "Sandbag",
        SANDBAG_ITEM = "Sandbag",
        SANDBAGSMALL = "Sandbag",
        SANDBAGSMALL_ITEM = "Sandbag",
        DUBLOON = "Dubloons",

        OBSIDIAN_BENCH = "Obsidian Workbench",
        OBSIDIAN_BENCH_BROKEN = "Broken Obsidian Workbench",

        JUNGLETREE = "Jungle Tree",
        LEIF_JUNGLE = "Treeguard",
        JUNGLETREESEED = "Jungle Tree Seed",
        JUNGLETREESEED_SAPLING = "Jungle Tree Sapling",

        BANANA_TREE = "Banana Tree",
        BANANA = "Banana",
        BANANA_COOKED = "Cooked Banana",

        BOAT_INDICATOR = "Don't Click On Me!",
        ARMOR_LIFEJACKET = "Life Jacket",
        ROCK_LIMPET = "Limpet Rock",
        LIMPETS = "Limpets",
        LIMPETS_COOKED = "Cooked Limpets",
        SWEET_POTATO = "Sweet Potato",
        SWEET_POTATO_COOKED = "Cooked Sweet Potato",
        SWEET_POTATO_SEEDS = "Stellar Seeds",
        KNOWN_SWEET_POTATO_SEEDS = "Sweet Potato Seeds",
        SWEET_POTATO_PLANTED = "Sweet Potato",
        SWEET_POTATO_OVERSIZED = "Giant Sweet Potato",
        SWEET_POTATO_OVERSIZED_ROTTEN = "Giant Rotting Sweet Potato",
        FARM_PLANT_SWEET_POTATO = "Sweet Potato Plant",

        LUGGAGECHEST = "Steamer Trunk",
        OCTOPUSCHEST = "Octo Chest",

        PEACOCK = "Peacock", -- what.
        COCONADE = "Coconade",
        OBSIDIANCOCONADE = "Obsidian Coconade",
        MONKEYBALL = "Silly Monkey Ball",
        OX = "Water Beefalo",
        BABYOX = "Baby Water Beefalo",

        TOUCAN = "Toucan",
        SEAGULL = "Seagull",
        SEAGULL_WATER = "Seagull",
        PARROT = "Parrot",
        CORMORANT = "Cormorant",

        TUNACAN = '"Ballphin Free" Tuna', -- this isnt the right formatting, right...?

        SEATRAP = "Sea Trap",

        DRAGOON = "Dragoon",
        DRAGOONEGG = "Dragoon Egg",
        DRAGOONSPIT = "Dragoon Saliva",
        DRAGOONDEN = "Dragoon Den",
        DRAGOONHEART = "Dragoon Heart",
        SNAKE = "Snake",
        SNAKE_POISON = "Poison Snake",
        VENOMGLAND = "Venom Gland",
        LOBSTER = "Wobster",
        LOBSTER_DEAD = "Dead Wobster",
        LOBSTER_DEAD_COOKED = "Delicious Wobster",
        LOBSTERHOLE = "Wobster Den",
        BALLPHIN = "Bottlenose Ballphin",
        BALLPHINHOUSE = "Ballphin Palace",
        DORSALFIN = "Dorsal Fin",
        FLOATER = "Floater",
        NUBBIN = "Coral Nubbin",
        CORALLARVE = "Coral Larva",
        WHALE_BLUE = "Blue Whale",
        WHALE_WHITE = "White Whale",
        WHALE_CARCASS_BLUE = "Blue Whale Carcass",
        WHALE_CARCASS_WHITE = "White Whale Carcass",

        WHALE_BUBBLES = "Suspicious Bubbles",

        BLUBBER = "Blubber",
        BLUBBERSUIT = "Blubber Suit",

        ANTIVENOM = "Anti Venom",
        BLOWDART_POISON = "Poison Dart",
        POISONHOLE = "Poisonous Hole",
        SPEAR_POISON = "Poison Spear",

        FABRIC = "Cloth",

        OBSIDIANAXE = "Obsidian Axe",
        OBSIDIANMACHETE = "Obsidian Machete",
        OBSIDIANSPEARGUN = "Obsidian Speargun",
        SPEAR_OBSIDIAN = "Obsidian Spear",
        ARMOROBSIDIAN = "Obsidian Armor",

        CAPTAINHAT = "Captain Hat",
        PIRATEHAT = "Pirate Hat",
        WORNPIRATEHAT = "Worn Pirate Hat",
        GASHAT = "Particulate Purifier",
        AERODYNAMICHAT = "Sleek Hat",

        JELLYFISH = "Jellyfish",
        JELLYFISH_PLANTED = "Jellyfish",
        JELLYFISH_DEAD = "Dead Jellyfish",
        JELLYFISH_COOKED = "Cooked Jellyfish",
        JELLYJERKY = "Dried Jellyfish",

        RAINBOWJELLYFISH = "Rainbow Jellyfish",
        RAINBOWJELLYFISH_PLANTED = "Rainbow Jellyfish",
        RAINBOWJELLYFISH_DEAD = "Dead Rainbow Jellyfish",
        RAINBOWJELLYFISH_COOKED = "Cooked Rainbow Jellyfish",
        RAINBOWJELLYJERKY = "Dried Rainbow Jellyfish",

        SPEARGUN = "Speargun",
        SPEARGUN_POISON = "Poison Speargun",

        HARPOON = "Harpoon",

        IA_TRIDENT = "Trident",

        ARMOR_SNAKESKIN = "Snakeskin Jacket",
        SNAKESKINHAT = "Snakeskin Hat",
        SNAKESKIN = "Snakeskin",

        BIGFISHINGROD = "Sport Fishing Rod",

        CHIMINEA = "Chiminea",
        OBSIDIANFIREPIT = "Obsidian Fire Pit",
        OBSIDIAN = "Obsidian",
        LAVAPOOL = "Lava Pool",
        EARRING = "One True Earring",
        CUTLASS = "Cutlass Supreme",
        ARMORSEASHELL = "Seashell Suit",
        SEASACK = "Sea Sack",
        PIRATIHATITATOR = "Piratihatitator",
        SLOTMACHINE = "Slot Machine",
        VOLCANO = "Volcano",
        VOLCANO_EXIT = "Volcano Exit",
        VOLCANO_ALTAR = "Volcano Altar of Snackrifice",
        VOLCANOSTAFF = "Volcano Staff",
        ICEMAKER = "Ice Maker 3000",
        COFFEEBEANS = "Coffee Beans",
        COFFEE = "Coffee",
        COFFEEBEANS_COOKED = "Roasted Coffee Beans",
        COFFEEBUSH = "Coffee Plant",
        DUG_COFFEEBUSH = "Coffee Plant",
        CHEFPACK = "Chef Pouch",
        MAILPACK = "Letter Carrier Bag",
        -- PORTABLECOOKPOT = "Portable Crock Pot",
        -- PORTABLECOOKPOT_ITEM = "Portable Crock Pot",
        ELEPHANTCACTUS = "Elephant Cactus",
        ELEPHANTCACTUS_ACTIVE = "Prickly Elephant Cactus",
        ELEPHANTCACTUS_STUMP = "Elephant Cactus Stump",
        DUG_ELEPHANTCACTUS = "Elephant Cactus",
        ARMORCACTUS = "Cactus Armor",
        NEEDLESPEAR = "Cactus Spike",
        PALMLEAF = "Palm Leaf",
        ARMORLIMESTONE = "Limestone Suit",
        WALL_LIMESTONE = "Limestone Wall",
        WALL_LIMESTONE_ITEM = "Limestone Wall",
        WALL_ENFORCEDLIMESTONE = "Sea Wall",
        WALL_ENFORCEDLIMESTONE_ITEM = "Sea Wall",
        ARMOR_WINDBREAKER = "Windbreaker",
        BOTTLELANTERN = "Bottle Lantern",
        SANDCASTLE = "Sand Castle",
        DOUBLE_UMBRELLAHAT = "Dumbrella",
        HAIL_ICE = "Hail",

        -- CALIFORNIAROLL = "California Roll",
        -- SEAFOODGUMBO = "Seafood Gumbo",
        BISQUE = "Bisque",
        -- CEVICHE = "Ceviche",
        JELLYOPOP = "Jelly-O Pop",
        -- BANANAPOP = "Banana Pop",
        WOBSTERBISQUE = "Wobster Bisque",
        WOBSTERDINNER = "Wobster Dinner",
        SHARKFINSOUP = "Shark Fin Soup",
        -- SURFNTURF = "Surf 'n' Turf",

        SWEETPOTATOSOUFFLE = "Sweet Potato Souffle",
        -- MONSTERTARTARE = "Monster Tartare",
        -- FRESHFRUITCREPES = "Fresh Fruit Crepes",
        MUSSELBOUILLABAISE = "Mussel Bouillabaise",

        BIOLUMINESCENCE = "Bioluminescence",
        SHARK_FIN = "Shark Fin",
        SHARK_GILLS = "Shark Gills",
        STUNGRAY = "Stink Ray",
        TURBINE_BLADES = "Turbine Blades",
        TIGERSHARK = "Tiger Shark",
        TIGEREYE = "Eye of the Tiger Shark",
        SHARKITTEN = "Sharkitten",
        BOATREPAIRKIT = "Boat Repair Kit",
        OBSIDIAN_WORKBENCH = "Obsidian Workbench",
        RAWLING = "Rawling",
        PACKIM_FISHBONE = "Fishbone",
        PACKIM = "Packim Baggims",
        SHARX = "Sea Hound",
        SNAKEOIL = "Snake Oil",

        CROCODOG = "Crocodog",
        POISONCROCODOG = "Yellow Crocodog",
        WATERCROCODOG = "Blue Crocodog",

        FROG_POISON = "Poison Frog",

        MYSTERYMEAT = "Bile-Covered Slop",

        OCTOPUSKING = "Yaarctopus",

        MAGMAROCK = "Magma Pile",
        MAGMAROCK_GOLD = "Magma Pile",
        ROCK_OBSIDIAN = "Obsidian Boulder",
        ROCK_CHARCOAL = "Charcoal Boulder",
        VOLCANO_SHRUB = "Burnt Ash Tree",

        FLUP = "Flup",

        CORAL_BRAIN_ROCK = "Brainy Sprout",
        CORAL_BRAIN = "Brainy Matter",
        BRAINJELLYHAT = "Brain of Thought",
        EUREKAHAT = "Eureka! Hat", -- wha...

        MANGROVETREE = "Mangrove",
        FLAMEGEYSER = "Krissure",
        TIDALPOOL = "Tidal Pool",
        TIDAL_PLANT = "Plant",

        TELEPORTATO_SW_RING = "Ring Thing",
        TELEPORTATO_SW_BOX = "Screw Thing",
        TELEPORTATO_SW_CRANK = "Grassy Thing",
        TELEPORTATO_SW_POTATO = "Wooden Potato Thing",
        TELEPORTATO_SW_BASE = "Wooden Platform Thing",
        TELEPORTATO_SW_CHECKMATE = "Wooden Platform Thing",

        KNIGHTBOAT = "Floaty Boaty Knight",

        LIVINGJUNGLETREE = "Regular Jungle Tree",

        WALLYINTRO_DEBRIS = "Debris",
        WALLYINTRO = "Rude Bird",

        BLOWDART_FLUP = "Eyeshot",

        MOSQUITO_POISON = "Poison Mosquito",

        MERMFISHER = "Fishermerm",
        MERMHOUSE_FISHER = "Fishermerm's Hut",
        MERMHOUSE_FISHER_CRAFTED = "Anglermerm House",
        MERMHOUSE_TROPICAL = "Merm Hut",
        MOSQUITOSACK_YELLOW = "Yellow Mosquito Sack",
        SHARK_TEETHHAT = "Shark Tooth Crown",
        BOAT_TORCH = "Boat Torch",

        MARSH_PLANT_TROPICAL = "Plant",
        WILDBOREHEAD = "Wildbore Head",

        SWIMMINGHORROR = "Swimming Horror",

        CRATE = "Crate",
        BUOY = "Buoy",

        SHARKITTENSPAWNER_ACTIVE = "Sharkitten Den",
        SHARKITTENSPAWNER_INACTIVE = "Sandy Pile",

        TWISTER = "Sealnado",
        TWISTER_SEAL = "Seal",

        SHIPWRECK = "Wreck",
        WRECKOF = "Wreck of the %s",
        TURF_SNAKESKIN = "Snakeskin Rug",

        WILBUR_UNLOCK = "Soggy Monkey",
        WILBUR_CROWN = "Tarnished Crown",

        MAGIC_SEAL = "Magic Seal",
        WIND_CONCH = "Howling Conch",
        WINDSTAFF = "Sail Stick",

        SHIPWRECKED_ENTRANCE = "Seaworthy",
        SHIPWRECKED_EXIT = "Seaworthy",

        SUNKEN_BOAT = "Sunken Boat",
        FLOTSAM = "Flotsam",

        INVENTORYWATERYGRAVE = "Watery Grave",
        WATERYGRAVE = "Watery Grave",
        PIRATEGHOST = "Pirate Ghost",

        KRAKEN = "Quacken",
        KRAKEN_TENTACLE = "Quacken Tentacle",
        WOODLEGSHAT = "Lucky Hat",
        SPEAR_LAUNCHER = "Speargun",

        KRAKENCHEST = "Chest of the Depths",

        OX_FLUTE = "Dripple Pipes",
        OXHAT = "Horned Helmet",
        OX_HORN = "Horn",

        QUACKENBEAK = "Quacken Beak",
        QUACKERINGRAM = "Quackering Ram",
        QUACKENDRILL = "Quacken Drill",

        TAR = "Tar",
        TAR_EXTRACTOR = "Tar Extractor",
        TAR_POOL = "Tar Slick",
        TAR_TRAP = "Tar Trap",
        TARLAMP = "Tar Lamp",
        TARSUIT = "Tar Suit",

        SEA_YARD = "Sea Yard",
        SEA_CHIMINEA = "Buoyant Chiminea",

        ROE = "Roe",
        ROE_COOKED = "Cooked Roe",
        FISH_FARM = "Fish Farm",

        TROPICALBOUILLABAISSE = "Tropical Bouillabaisse",
        CAVIAR = "Caviar",

        SEA_LAB = "Sea Lab",
        WATERCHEST = "Sea Chest",

        SEAWEED_STALK = "Seaweed Stalk",
        MUSSEL_BED = "Mussel Bed",

        TROPICALFAN = "Tropical Fan",

        TERRAFORMSTAFF = "Atlantis Staff",

        POISONBALM = "Poison Balm",

        FIRERAIN = "Dragoon Egg",

        SHADOWHACKER_BUILDER = "Shadow Hacker",

        MUTATOR_TROPICAL_SPIDER_WARRIOR = "Tropical Switcherdoodle",

        TROPICAL_SPIDER_WARRIOR = "Tropical Spider Warrior",

        TURF_RUINSBRICK_GLOW_BLUEPRINT = "Ancient Flooring Blueprint",

        CHESSPIECE_KRAKEN = "Quacken Figure",
        CHESSPIECE_KRAKEN_BUILDER = "Quacken Figure",

        CHESSPIECE_TIGERSHARK = "Tiger Shark Figure",
        CHESSPIECE_TIGERSHARK_BUILDER = "Tiger Shark Figure",

        CHESSPIECE_TWISTER = "Sealnado Figure",
        CHESSPIECE_TWISTER_BUILDER = "Sealnado Figure",

        CHESSPIECE_SEAL = "Seal Figure",
        CHESSPIECE_SEAL_BUILDER = "Seal Figure",
    },

    RECIPE_DESC = {
        MUTATOR_TROPICAL_SPIDER_WARRIOR = "Comes with a mystery filling!",
        SHADOWHACKER_BUILDER = "Hack and slash!",
        POISONBALM = "The excruciating pain means it's working.",
        ANTIVENOM = "Cures that not-fresh \"poison\" feeling.",
        BLOWDART_POISON = "Spit poison at your enemies.",
        BOAT_ROW = "Row, row, row your boat!",
        BALLPHINHOUSE = "EeEe! EeEe!",
        MACHETE = "Hack stuff!",
        GOLDENMACHETE = "Hack stuff with elegance (and metal)!",
        ARMOR_LIFEJACKET = "Safety first!",
        TELESCOPE = "See across the sea.",
        SUPERTELESCOPE = "See across more sea.",
        PALMLEAF_HUT = "Escape the rain. Mostly.",
        SANDBAG_ITEM = "Sand. Water's greatest enemy.",
        CHIMINEA = "Fire and wind don't mix.",
        PIRATEHAT = "It's a pirate's life for ye!",
        WORNPIRATEHAT = "It's a pirate's life for ye!",
        PIRATIHATITATOR = "Make your pirate hat... magic!",
        SLOTMACHINE = "Leave nothing to chance! Except this.",
        ICEMAKER = "Ice, ice, baby!",
        VOLCANOSTAFF = "The sky is falling!",
        MUSSEL_STICK = "Mussels stick to it!",
        SEATRAP = "It's a trap for sea creatures.",
        LIMESTONENUGGET = "Stone, with a hint of lime.",
        ARMORLIMESTONE = "Sartorial reef.",
        WALL_RUINEDLIMESTONE_ITEM = "Tough wall segments, sorta.",
        WALL_ENFORCEDLIMESTONE_ITEM = "Strong wall segments to build at sea.",
        ARMOR_WINDBREAKER = "Break some wind!",
        BOTTLELANTERN = "Glowing ocean goo in a bottle.",
        OBSIDIANAXE = "Like a regular axe, only hotter.",
        OBSIDIANMACHETE = "Hack'n'burn!",
        OBSIDIANFIREPIT = "The fieriest of all fires!",
        BOAT_RAFT = "Totally sort of seaworthy.",
        SURFBOARD_ITEM = "Cowabunga dudes!",
        BOAT_CARGO = "Hoarding at sea!",
        BOAT_ENCRUSTED = "A tank on high seas!",
        SAIL_PALMLEAF = "Catch the wind!",
        SAIL_CLOTH = "Catch even more wind!",
        SAIL_SNAKESKIN = "Heavy duty wind catcher.",
        SAIL_FEATHER = "Like a bird's wing, for your boat!",
        BOAT_LANTERN = "Shed some light on the situation.",
        BOATCANNON = "It's got your boat's back.",
        TRAWLNET = "The patient fisher is always rewarded.",
        CAPTAINHAT = "Wear one. Your boat will respect you more.",
        NUBBIN = "There's nubbin better!",
        SEASACK = "Keeps your food fresher, longer!",
        ARMORSEASHELL = "Pretty poison prevention.",
        SPEAR_OBSIDIAN = "How about a lil fire with your spear?",
        ARMOROBSIDIAN = "Hot to the touch.",
        COCONADE = "KA-BLAM!",
        OBSIDIANCOCONADE = "KA-BLAMMIER!",
        SPEAR_LAUNCHER = "Laterally eject your spears.",
        SPEARGUN = "Never sail without one!",
        SPEARGUN_POISON = "Sick shot!",
        OBSIDIANSPEARGUN = "Hot shot!",
        CUTLASS = "Fish were harmed in the making of this.",
        SANDCASTLE = "Therapeutic and relaxing.",
        WALL_LIMESTONE_ITEM = "Strong wall segments.",
        FABRIC = "Bamboo is so versatile!",
        IA_MESSAGEBOTTLEEMPTY = "Don't forget to recycle!",
        ICE = "Water of the solid kind.",
        AERODYNAMICHAT = "Aerodynamic design for efficient travel.",
        GASHAT = "Keep nasty airborne particulates away!",
        SNAKESKINHAT = "Keep the rain out, and look cool doing it.",
        ARMOR_SNAKESKIN = "Stay dry and leathery.",
        ARMORCACTUS = "Prickly to the touch.",
        SPEAR_POISON = "Jab'em with a sick stick.",
        IRONWIND = "Motorin'!",
        BOATREPAIRKIT = "Stay afloat in that boat!",
        MONKEYBARREL = "Monkey around by putting monkeys around.",
        BRAINJELLYHAT = "Well aren't you clever?",
        EUREKAHAT = "For when inspiration strikes.",
        BOAT_ARMOURED = "Shell out for this hearty vessel.",
        THATCHPACK = "Carry a light load.",
        BOAT_LOGRAFT = "Boat at your own risk.",
        SANDBAGSMALL_ITEM = "Floodproof.",
        WALL_LIMESTONE = "Tough wall segments.",
        GOLDNUGGET = "Gold! Gold! Gold!",
        BLUBBERSUIT = "A disgusting way to stay dry.",
        BOAT_TORCH = "See, at sea.",
        PRIMEAPEBARREL = "More monkeys!",
        MONKEYBALL = "Get down to monkey business.",
        MERMHOUSE_FISHER_CRAFTED = "A home fit for skilled fisher.",
        WILDBOREHOUSE = "Pig out!",
        DRAGOONDEN = "Enter the Dragoon's Den.",
        BOAT_SURFBOARD = "Hang ten!",
        DOUBLE_UMBRELLAHAT = "Definitely function over fashion.",
        SHARK_TEETHHAT = "Look formidable on the seas.",
        CHEFPACK = "Freshen up your foodstuffs.",
        -- PORTABLECOOKPOT_ITEM = "Better than any takeaway food.",
        BUOY = "Mark your place in the water.",
        WIND_CONCH = "The gales come early.",
        WINDSTAFF = "May the wind be always at your back.",
        TURF_SNAKESKIN = "Really ties the room together.",
        DOYDOYNEST = "Just doy it.",
        SHIPWRECKED_ENTRANCE = "Take a vacation. Go somewhere less awful.",
        WOODLEGSHAT = "Sniff out treasures.",
        BOAT_WOODLEGS = "Go do some pirate stuff.",
        OX_FLUTE = "Make the world weep.",
        OXHAT = "Shell out for some poison protection.",
        BOOK_METEOR = "On comets, meteors and eternal stardust.",
        PALMLEAF_UMBRELLA = "Posh & portable tropical protection.",
        QUACKERINGRAM = "Everybody better get out of your way!",
        TAR_EXTRACTOR = "This offshore rig knows the drill.",
        SEA_YARD = "Keep your boats ship-shape!",
        SEA_CHIMINEA = "Fire that floats!",
        FISH_FARM = "Grow your own fishfood with roe!",
        TARLAMP = "A light for your hand, or for your boat!",
        TARSUIT = "The slickest way to stay dry.",
        SEA_LAB = "Unlock crafting recipes... at sea!",
        WATERCHEST = "Davy Jones' storage locker.",
        MUSSEL_BED = "Relocate your favorite mollusc.",
        QUACKENDRILL = "For Deep Sea Quacking.",
        TROPICALFAN = "Luxuriously soft, luxuriously tropical.",
        TURF_BEACH = "A patch of warm sand.",
        TURF_JUNGLE = "A chunk of wild jungle.",
        TURF_MEADOW = "A patch of peaceful meadow.",
        TURF_MAGMAFIELD = "A chunk of accumulated sediment.",
        TURF_ASH = "Ashy ground from the volcano.",
        TURF_VOLCANO = "Magmatic ground from the volcano.",
        TURF_TIDALMARSH = "Your marsh away from home.",
        TURF_RUINSBRICK_GLOW_BLUEPRINT = "Build a floor in the style of a long-gone civilization.",
        TRANSMUTE_BAMBOO = "Transmute Vine into Bamboo.",
        TRANSMUTE_VINE = "Transmute Bamboo into Vine.",
        TRANSMUTE_SAND = "Transmute Limestone into Sand.",
        TRANSMUTE_LIMESTONE = "Transmute Sand into Limestone.",
        TRANSMUTE_OBSIDIAN = "Transmute Dragoon Heart into Obsidian.",
        TRANSMUTE_DRAGOONHEART = "Transmute Obsidian into Dragoon Heart.",
        TRANSMUTE_DUBLOONS = "Transmute Gold Nugget into a Dubloons.",
        TRANSMUTE_JELLY = "Transmute Rainbow Jellyfish into Jellyfish.",
        TRANSMUTE_RAINBOWJELLY = "Transmute Jellyfish into Rainbow Jellyfish.",
        CHESSPIECE_KRAKEN_BUILDER = "A terrifying sea monster, minus the sea.",
        CHESSPIECE_TIGERSHARK_BUILDER = "Sculpt a fearsome feline figurehead.",
        CHESSPIECE_TWISTER_BUILDER = "Capture the heart of a raging storm!",
        CHESSPIECE_SEAL_BUILDER = "Sculpt an adorable innocent seal.",
    },

    --now unused
    TABS = {
        NAUTICAL = "Nautical",
        OBSIDIAN = "Obsidian"
    },

    PARROTNAMES = {"Danjaya", "Jean Claud Van Dan", "Donny Jepp", "Crackers", "Sully", "Reginald VelJohnson",
                   "Dan Van 3000", "Van Dader", "Dirty Dan", "Harry", "Sammy", "Zoe", "Kris", "Trent", "Harrison",
                   "Alethea", "Jonny Dregs", "Frankie", "Pollygon", "Vixel", "Hank", "Cutiepie", "Vegetable", "Scurvy",
                   "Black Beak", "Octoparrot", "Migsy", "Amy", "Victoire", "Cornelius", "Long John", "Dr Hook",
                   "Horatio", "Iago", "Wilde", "Murdoch", "Lightoller", "Boxhall", "Moody", "Phillips", "Fleet",
                   "Barrett", "Wisecracker"},

    MERMNAMES = {"Glorpy", "Gloppy", "Blupper", "Glurtski", "Glummer", "Gluts", "Slerm", "Sloosher", "Slurnnious",
                 "Brutter", "Glunt", "Mropt", "Shlorpen", "Blunser", "Fthhhhh", "Blort", "Slpslpslp", "Glorpen",
                 "Rut Rut", "Mrwop", "Glipn", "Glert", "Sherpl", "Shlubber", "Christian", "Dan", "Drew", "Dave", "Jon",
                 "Matt", "Nathan", "Vic"},

    BALLPHINNAMES = {"Miah", "Marius", "Brian", "Sushi", "Bait", "Chips", "Poseidon", "Flotsam", "Jetsam", "Seadog",
                     "Gilly", "Fin", "Flipper", "Chum", "Seabreeze", "Tuna", "Sharky", "Wanda", "Neptune", "Seasalt",
                     "Phlipper", "Miso", "Wasabi", "Jaws", "Babel", "Earl", "Fishi"},

    SHIPNAMES = {"Nautilus", "Mackay-Bennett", "Mary Celeste", "Beagle", "Monitor", "Santa Maria", "Bluenose",
                 "Adriatic", "Nomadic", "Mauretania", "Endeavour", "Batavia", "Edmund Fitzgerald", "Pequod",
                 "Mississinewa", "African Queen", "Mont-Blanc", "Anita Marie", "Caine", "Orca", "Pharaoh", "Nellie",
                 "Piper Maru", "Minnow", "Syracusia", "Baron of Renfrew", "Ariel", "Blackadder", "Hispaniola",
                 "Pelican", "Golden Hind", "Resolution", "Nina Clara", "Pinafore"},

    BORE_TALK_FOLLOWWILSON = {"YOU OK BY ME", "I LOVE FRIEND", "YOU IS GOOD", "I FOLLOW!"},
    BORE_TALK_FIND_LIGHT = {"SCARY", "NO LIKE DARK", "WHERE IS SUN?", "STAY NEAR FIRE", "FIRE IS GOOD"},
    BORE_TALK_LOOKATWILSON = {"WHO ARE YOU?", "YOU NOT BORE.", "UGLY MONKEY MAN", "YOU HAS MEAT?"},
    BORE_TALK_RUNAWAY_WILSON = {"TOO CLOSE!", "STAY 'WAY!", "YOU BACK OFF!", "THAT MY SPACE."},
    BORE_TALK_FIGHT = {"I KILL NOW!", "YOU GO SMASH!", "RAAAWR!", "NOW YOU DUN IT!", "GO 'WAY!", "I MAKE YOU LEAVE!"},
    BORE_TALK_RUN_FROM_SPIDER = {"SPIDER BAD!", "NO LIKE SPIDER!", "SCARY SPIDER!"},
    BORE_TALK_HELP_CHOP_WOOD = {"KILL TREE!", "SMASH MEAN TREE!", "I PUNCH TREE!"},
    BORE_TALK_HELP_HACK = {"I HELP GET BUSH!", "I PUNCH BUSH!", "WE PUNCHIN' PLANTS NOW?"},
    BORE_TALK_ATTEMPT_TRADE = {"WHAT YOU GOT?", "BETTER BE GOOD.", "NO WASTE MY TIME."},
    BORE_TALK_PANIC = {"NOOOOO!", "TOO DARK! TOO DARK!", "AAAAAAAAAH!!"},
    BORE_TALK_PANICFIRE = {"HOT HOT HOT!", "OWWWWW!", "IT BURNS!"},
    BORE_TALK_FIND_MEAT = {"ME HUNGRY!", "YUM!", "I EAT FOOD!", "TIME FOR FOOD!"},
    BORE_TALK_EAT_MEAT = {"NOM NOM NOM", "YUM!"},
    BORE_TALK_GO_HOME = {"HOME TIME!", "HOME! HOME!"},

    -- fight and find_food are unused (find food overrides the wurt translated string from dst aswell)
    -- MERM_TALK_FIND_FOOD = {"Flut!", "Glort grolt flut.", "Florty glut."},
    MERM_TALK_PANIC = {{"Just wanted fish!", "GLOP GLOP GLOP!"}, {"Aaah!", "GLORRRRRP!"},
                       {"Florp! Florp!", "FLOPT! FTHRON!"}},
    -- MERM_TALK_FIGHT = {"GLIE, FLORPY FLOPPER!", "NO! G'WUT OFF, GLORTER!", "WULT FLROT, FLORPER!"},
    MERM_TALK_RUNAWAY = {{"Cut line!", "Florpy glrop glop!"}, {"Bad thing! Bad thing!", "GLORP! GLOPRPY GLUP!"},
                         {"Protect fish!", "Glut glut flrop!"}},
    MERM_TALK_GO_HOME = {{"Sleep with fishes.", "Wort wort flrot."},
                         {"Fish friend. Not food.", "Wrut glor gloppy flort."}},
    MERM_TALK_FISH = {{"Go fish.", "Blut flort."}, {"Fresh fish. Good.", "Glurtsu gleen."},
                      {"I am anglermerm. Go fish.", "Blet blurn."}},
    MERM_TALK_HELP_HACK_BUSH = {{"Glurp glurp, florp!", "Chop chop, florp!"}, {"Glort blut, flort!", "Work hard, flort!"},
                      {"Glorp Glurtsu flopt!", "Mermfolk together strong!"}},

    BALLPHIN_TALK_FOLLOWWILSON = {"EE!! EE!!", "EEEE!", "EEE, EE?", "EE EEE EE"},
    BALLPHIN_TALK_HOME = {"NEEEEE!!", "Nee! NEe!", "NEE! NEE!"},
    BALLPHIN_TALK_FIND_LIGHT = {"EEEK! EEEK!", "EEK EEK EEK!"},
    BALLPHIN_TALK_PANIC = {"EEEEEEEEH!!", "EEEEEEEEE!!"},
    BALLPHIN_TALK_FIND_MEAT = {"Eee?", "Eee eee ee?", "Ee, ee?"},
    BALLPHIN_TALK_HELP_MINE_CORAL = {"KEEEEEE!", "KEE! KEE!", "KEEE!"},

    SUNKEN_BOAT_SQUAWKS = {"Squaak!", "Raaawk!"},
    SUNKEN_BOAT_REFUSE_TRADE = {"Sqwaak! Useless junk!", "Go away! Sqwaak!", "Wolly does NOT want THAT.", "Land lubber!"},
    SUNKEN_BOAT_ACCEPT_TRADE = {"Thanks, matey!", "A fair trade!", "Yaarr. Thanks buddy."},
    SUNKEN_BOAT_IDLE = {"Sqwaaaak!", "Where's me treasures?", "Wolly wants a cracker.", "Abandon ship! Abandon ship!",
                        "Thar she blows!", "Treasures from the sea?", "Lost! Lost! Waaark? Lost!",
                        "The treasure's going down!"},

    RAWLING = {
        in_inventory = {"Let's cut the bottom out of the basket."},

        equipped = {"You can carry me. For a couple of steps.", "Is this some kind of Canadian joke?",
                    "Feel \"free\" to throw me."},

        on_thrown = {"To the peach basket!", "Shoot!", "You miss 100% of the shots you don't take!",
                     "I believe I can fly!"},

        on_ground = {"I could use a little pick me up."},

        in_container = {"This isn't a peach basket..."},

        on_pickedup = {"Is that you, James?", "You're MY MVP!"},

        on_dropped = {"Dribble me!"},

        on_ignite = {"I'm on fire!", "Ow ow ow ow ow!"},

        on_extinguish = {"Saved!"},

        on_bounced = {"Ouch!", "Nothin' but peaches!", "Splish!", "Rejected!"},

        on_hit_water = {"Swish!"},

        on_haunt = {"Peach basket is that you?!", "I don't like this kind of dribbling!"}
    },

    TALKINGBIRD = {
        in_inventory = {"Adventure!", "You stink!", "SQUAAAWK!", "Hey you!", "Chump!", "Nerd!", "Treasure!",
                        "Walk the plank!", "Cracker!"},

        in_container = {"Don't bury me!", "Out, out!", "Sunk!", "Me eyes! Me eyes!", "Too dark!"},

        on_ground = {"Nice one!", "Chump!", "Big head!", "You stink!"},

        on_pickedup = {"Chump!", "Hello!", "Feed me!", "I'm hungry!", "Ouch!"}, --unused in sw but used in ia for hungry birdcage strings

        on_dropped = {"Chump!", "Bye now!", "See ya chump!", "Goodbye!"},

        on_mounted = {"Onward!", "Uh-oh!", "Are you sure about this?"},

        on_dismounted = {"Land!", "Solid ground!", "We made it!"},

        other_owner = {"Help!", "Ack!", "Scurvy!", "Save me!", "I'm okay!"}
    },

    SCRAPBOOK = {
        SPECIALINFO = {
            COFFEEBEANS_COOKED = "Increases movement speed by 83.33%.\n\nDuration 30 seconds.",
            COFFEE = "Increases movement speed by 83.33%.\n\nDuration 4 minutes.",
            TROPICALBOUILLABAISSE = "Reduces temperature.\n\nIncreases movement speed by 33%.\n\nAccelerates wetness decrease.\n\nDuration 1 minute.",
            AERODYNAMICHAT = "Increases movement speed by 25%.\n\nProvides 50% resistance against strong winds.",
            BRAINJELLYHAT = "Let's you craft recipes that have not been prototyped.",
            ANTI_PHYSICAL_POISON = "Protects against poison from physical contact.",
            ANTI_NON_PHYSICAL_POISON = "Protects against poison from non physical contact.",
            PIRATEHAT = "Increases the map reveal range while sailing.",
            SHARK_TEETHHAT = "Restores 6.6 sanity per minute while on boat.",
            WOODLEGSHAT = "Spawns X Marks the Spot treasure every 800 seconds.",
            CAPTAINHAT = "Makes your boat lose its durability at half rate while sailing.",
            ARMOROBSIDIAN = "Makes you immune to fire.",
            ARMORWINDBREAKER = "Prevents you from being slowed by strong winds.",
            MOSQUITOSACK_YELLOW = "Can be used to heal 20 health.",
            DRAGOONMETEORS = "Summons several Dragoon Eggs.",
            PACKIM = "Things can be stored in Packim Baggims much like a treasure chest.\n\nHe loves to eat fish food.",
            PIRATEPACK = "Generates a Dubloon once per day while being continuously worn.",
            POISONCURE = "Cures poison.",
            VENOMGLAND = "Cures poison at cost of up to 75 health.",
            SNAKEOIL = "The possibilities of its use are almost endless.",
            SAIL_PALMLEAF = "Increases sailing speed by 20%.",
            SAIL_CLOTH = "Increases sailing speed by 30%.",
            SAIL_SNAKESKIN = "Increases sailing speed by 25%.",
            SAIL_FEATHER = "Increases sailing speed by 40%.",
            IRONWIND = "Increases sailing speed by 50%.",
            WINDSTAFF = "Redirects strong winds so they blow in the same direction that you are traveling.",
            OX_FLUTE = "Summons rain.",
            WIND_CONCH = "Summons strong winds.",
            EYESHOT = "Stuns birds on hit.",
            POISONDART = "Shoots projectiles that poison targets.",
        },
    },

    UI = {
        SERVERCREATIONSCREEN = {
            ISLANDSONLY = "Islands",
            ISLANDSANDVOLCANO = "Islands And Volcano",
        },
        WORLDGEN_IA = {
            VERBS = { -- "Keelhauling",
            "Inundating with", "Setting course for", "Hoisting"},
            NOUNS = {"jungle...", "deep, dark waters...", "palms...", "snakes...", "sea monsters...",
                     "a bottle of rum...", "fish heads...", "chests and chests of dubloons...", "chatty parrots...",
                     "seafood...", "vast ocean...", "thalassophobia...", "jetsam..."}
        },
        COOKBOOK = {
            FOOD_EFFECTS_NAUGHTY = "Considered naughty",
            FOOD_EFFECTS_SPEED_BOOST = "Accelerates movement",
            FOOD_EFFECTS_TROPICAL_BOUILLABAISSE = "Cools, accelerates, dries"
        },
        CRAFTING = {
            NEEDSSEALAB = "Use a sea lab to build a prototype!",
            NEEDSOBSIDIAN_BENCH = "Find the Obsidian Workbench to forge this at.",

            NEEDSBOATMODEIA = "Enable IA Boats in this world to access this recipe.",
            NEEDSBOATMODEDST = "Enable DST Boats in this world to access this recipe.",

            NEEDSGAMEMODEROG = "Travel to a desolate forest to prototype this recipe.",
            NEEDSGAMEMODESW = "Travel to a tropical paradise to prototype this recipe.",
            NEEDSGAMEMODEHAM = "Travel to a deeply dangerous jungle to prototype this recipe.",
        },
        CUSTOMIZATIONSCREEN = {
            CLOCKTYPE = "Clock Type",
            MILD = "Mild",
            HURRICANE = "Hurricane",
            DRY = "Dry",
            MONSOON = "Monsoon",
            PRIMARYWORLDTYPE = "World Type",
            ISLANDQUANTITY = "Island Quantity",
            ISLANDSIZE = "Island Size",
            VOLCANO = "Volcano",
            DRAGOONEGG = "Dragoon Eggs",
            TIDES = "Tides",
            FLOODS = "Floods",
            OCEANWAVES = "Waves",
            POISON = "Poison",
            BERMUDATRIANGLE = "Electric Isosceles",
            VOLCANOISLAND = "Volcano Island",

            NO_DST_BOATS = "DST Boats (WIP)",
            HAS_IA_BOATS = "IA Boats (WIP)", -- All of this is probably temp but deadly drowning seems cool -Arti
            HAS_IA_DROWNING = "Deadly Drowning",

            FISHINHOLE = "Shoals",
            SEASHELL = "Seashells",
            BUSH_VINE = "Viney Bushes",
            SEAWEED = "Seaweeds",
            SANDHILL = "Sandy Piles",
            CRATE = "Crates",
            BIOLUMINESCENCE = "Bioluminescence",
            CORAL = "Corals",
            CORAL_BRAIN_ROCK = "Brainy Sprouts",
            BAMBOO = "Bamboo",
            TIDALPOOL = "Tidal Pools",
            POISONHOLE = "Poisonous Holes",
            MAGMA_ROCKS = "Magma Rocks",
            TAR_POOL = "Tar Pools",

            SWEET_POTATO = "Sweet Potatoes",
            SWEET_POTATO_REGROWTH = "Sweet Potatoes",
            LIMPETS = "Limpets",
            MUSSEL_FARM = "Mussels",

            PALMTREE_REGROWTH = "Palm Trees",
            JUNGLETREE_REGROWTH = "Jungle Trees",
            MANGROVETREE_REGROWTH = "Mangrove Trees",

            WILDBORES = "Wildbore Houses",
            WILDBORES_SETTING = "Wildbores",
            WHALEHUNT = "Whaling",
            CRABHOLE = "Crabbit Holes",
            CRAB_SETTING = "Crabbits",
            OX = "Water Beefalos",
            SOLOFISH = "Dogfish",
            SOLOFISH_SETTING = "Dogfish",
            DOYDOY = "Doydoys",
            JELLYFISH = "Jellyfish",
            JELLYFISH_SETTING = "Jellyfish",
            LOBSTER = "Wobster Dens",
            LOBSTER_SETTING = "Wobsters",
            SEAGULL = "Seagulls",
            BALLPHIN = "Ballphin Palaces",
            BALLPHIN_SETTING = "Ballphins",
            PRIMEAPE = "Prime Ape Huts",
            PRIMEAPE_SETTING = "Prime Apes",
            FISHERMERM = "Fisher Merm Huts",
            FISHERMERM_SETTING = "Fisher Merms",
            SHARKITTEN_SETTING = "Sharkittens",
            DRAGOON_SETTING = "Dragoons",

            SHARX = "Sea Hounds",
            CROCODOG = "Crocodogs",
            TWISTER = "Sealnado",
            TIGERSHARK = "Tiger Sharks",
            KRAKEN = "Quacken",
            FLUP = "Flup",
            MOSQUITO = "Poison Mosquitos",
            SWORDFISH = "Swordfish",
            SWORDFISH_SETTING = "Swordfish",
            STUNGRAY = "Stink Rays",
            STUNGRAY_SETTING = "Stink Rays",
            PRESETLEVELS = {
                SURVIVAL_SHIPWRECKED_CLASSIC = "Shipwrecked",
                SURVIVAL_VOLCANO_CLASSIC = "Volcano",
            },
            PRESETLEVELDESC = {
                SURVIVAL_SHIPWRECKED_CLASSIC = "A tropical paradise?",
                SURVIVAL_VOLCANO_CLASSIC = "The top of the tropical volcano",
            },
            TASKSETNAMES = {
                SHIPWRECKED = "shipwrecked",
                VOLCANO = "Volcano",
            }
        },
        SANDBOXMENU = {
            ADDVOLCANO = "Add Volcano",

            SHIPWRECKED = "Shipwrecked Portal",
            VOLCANO = "Volcano Portal",

            IA_NOCAVES_TITLE = "No Cave Entrances!",
            IA_NOCAVES_BODY = "Island-only worlds don't have cave entrances (unless you got an add-on mod for that).\nDo you want to remove the caves from this server?",
            ADDLEVEL_WARNING_IA = "Island-only worlds don't have cave entrances (unless you got an add-on mod for that).\nYou might not be able to access the caves!",
            CUSTOMIZATIONPREFIX_IA = "Shipwrecked ", -- Please note that the space is intentional, so translations may use hyphons or whatever -M
            SLIDEVERYRARE = "Much Less",
            CLOCKTYPE_DEFAULT = "Default",
            CLOCKTYPE_SHIPWRECKED = "Tropical",
            -- CLOCKTYPE_HAMLET = "Plateau",
            WORLDTYPE_DEFAULT = "Forest",
            WORLDTYPE_MERGED = "Merged",
            WORLDTYPE_ISLANDS = "Islands",
            WORLDTYPE_ISLANDSONLY = "Islands Only",
            WORLDTYPE_VOLCANOONLY = "Volcano Only",
        },
        CRAFTING_STATION_FILTERS = {
            FORGING = "Volcanic",
        },
        CRAFTING_FILTERS = {
            NAUTICAL = "Nautical",
        },
        SERVERLISTINGSCREEN = {
            IA_SEASONS = {
                AUTUMN = "Mild",
                WINTER = "Hurricane",
                SUMMER = "Dry",
                SPRING = "Monsoon",
            },
            DST_SEASONS = deepcopy(STRINGS.UI.SERVERLISTINGSCREEN.SEASONS),
            SEASONS = {
                MILD = "Mild",
                HURRICANE = "Hurricane",
                MONSOON = "Monsoon",
                DRY = "Dry",
            }
        },

        SKILLTREE = {
            WILSON = {
                IA_WILSON_ALCHEMY_1_DESC = "Transform 3 Twigs into a Log & a Log into 2 Twigs.\nTransform 2 Vines into a Bamboo & 2 Bamboo into a Vine.",

                IA_WILSON_ALCHEMY_2_DESC = "Transform 2 Red Gems into a Blue Gem & 2 Blue Gems into a Red Gem.\nTransform a Blue and Red Gem into a Purple Gem.",
        
                -- IA_WILSON_ALCHEMY_5_DESC = "Transform 3 Purple Gems into an Orange Gem.\nTransform 3 Orange Gems into a Yellow Gem.",

                IA_WILSON_ALCHEMY_6_DESC = "Transform 3 Yellow Gems into a Green Gem.\nTransform 6 Gems of different colors into an Iridescent Gem.\nTransform Dragoon Heart into 3 Obsidian & 4 Obsidian into Dragoon Heart.",
        
                IA_WILSON_ALCHEMY_3_DESC = "Transform 3 Rocks into a Flint & 2 Flint into Rocks.",
        
                IA_WILSON_ALCHEMY_7_DESC = "Transform 3 Nitre into a Gold Nugget & 2 Gold Nuggets into Nitre.\nTransform 2 Gold Nuggets into 3 Dubloons.",
        
                IA_WILSON_ALCHEMY_8_DESC = "Transform 2 Cut Stone into Marble & Marble into Cut Stone.\nTransform 2 Marble into Moon Rock.\nTransform Limestone into 4 Sand & 5 Sand into Limestone.",
        
                IA_WILSON_ALCHEMY_4_DESC = "Transform 3 Morsels into a Meat & a Meat into 2 Morsels.\nTransform a Rainbow Jellyfish into 2 Jellyfish & 3 Jellyfish into a Rainbow Jellyfish.",
        
                IA_WILSON_ALCHEMY_9_DESC = "Transform 2 Beard Hair into Beefalo Wool & 2 Beefalo Wool into Beard Hair.",
        
                IA_WILSON_ALCHEMY_10_DESC = "Transform 6 Rot into Manure.\nTransform 2 Hound's Teeth into a Bone Shards & 2 Bone Shards into a Hound's Tooth.",
            },
        },

        PLANTREGISTRY = {
            DESCRIPTIONS = {
                SWEET_POTATO = "It be th' sweetest tater on th' seven seas. -W",
            },

        },
        
    },

    STAGEACTOR = {
        WALANI1 = -- Aloha ʻOe
        {
            "Proudly swept the rain by the cliffs",
            "As it glided through the trees",
            "Still following ever the bud",
            "The Lehua flower of the vale...",
            "", anim="emote_sleepy",
        },
        WILBUR1 =
        {
            "Ooae Oooh Oaoa!",
            "Ooh? Ooae!",
            "'Nonos!",
            "Oo, Oaoh.",
            "Oooa Ooe!",
            "Ooae. Oooh!",
            "'Nanas!",
        },
        WOODLEGS1 =
        {
            "Wit' me shell on the bottom, I stood so tall.",
            "'Til me cradle compelled me t' obstinate goal.",
            "Now me lives are all gone, me corpse among sand.",
            "Me first name's me bein'; 'n second me end.",
        },
    },

    _STATUS_ANNOUNCEMENTS = {
        _ = {
            STAT_NAMES = {
                IA_BOAT = "Boat",
            },
            ANNOUNCE_IA_BOAT = {
                FORMAT_STRING = "{THIS} {BOAT} {HAS} ({STAT}) {HEALTH}",
                THIS = "This",
                HAS = "has",
                HEALTH = "health",
            }
        },
        UNKNOWN = {
            IA_BOAT = {
                FULL  = "This boat is in perfect condition!",
                HIGH  = "This craft is still seaworthy.",
                MID   = "This ship is a bit beaten-up.",
                LOW   = "This boat is in urgent need of repairs!",
                EMPTY = "This ship is sinking!",
            },
        },
    },
}
