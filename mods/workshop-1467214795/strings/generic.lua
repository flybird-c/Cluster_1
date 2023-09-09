-- This speech is for Wilson, also mod characters if they don't have quotes already (hence "generic")
return {

	ACTIONFAIL =
	{
		REPAIRBOAT = 
		{
			GENERIC = "She's floating just fine right now.",
		},
		EMBARK = 
		{
			INUSE = "The ship has left port without me!",
		},
		INSPECTBOAT = 
		{
			INUSE = GLOBAL.STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.STORE.INUSE
		},
		OPEN_CRAFTING  = 
		{
			FLOODED = "It's waterlogged!",
		},
		FISH_FLOTSAM = {
			TOOFAR = "It's out of my reach.",
		},
	},

	ANNOUNCE_MAGIC_FAIL = "It won't work here.",

	ANNOUNCE_SHARX = "I'm going to need a bigger boat...",

	ANNOUNCE_TREASURE = "It's a map! And it marks a location!",
	ANNOUNCE_TREASURE_DISCOVER = "Treasure!",
	ANNOUNCE_MORETREASURE = "Seriously? Another one!?",
	ANNOUNCE_OTHER_WORLD_TREASURE = "This map doesn't correlate to my current surroundings.",
	ANNOUNCE_OTHER_WORLD_PLANT = "I don't think this soil has the proper nutrients.",

	ANNOUNCE_IA_MESSAGEBOTTLE =
	{
		"The message is faded. I can't read it.",
	},
	ANNOUNCE_VOLCANO_ERUPT = "That can't be good.",
	ANNOUNCE_MAPWRAP_WARN = "Here be monsters.",
	ANNOUNCE_MAPWRAP_LOSECONTROL = "It would seem my future is foggy.",
	ANNOUNCE_MAPWRAP_RETURN = "I think I felt something brush against my leg...",
	ANNOUNCE_CRAB_ESCAPE = "I could've sworn it was right there...",
	ANNOUNCE_TRAWL_FULL = "My net filled up!",
	ANNOUNCE_BOAT_DAMAGED = "I think I sprung a leak.",
	ANNOUNCE_BOAT_SINKING = "I seem to be sinking.",
	ANNOUNCE_BOAT_SINKING_IMMINENT = "I need to get to land!",
	ANNOUNCE_WAVE_BOOST = "Weeeee!",

	ANNOUNCE_WHALE_HUNT_BEAST_NEARBY = "Follow those bubbles!",
	ANNOUNCE_WHALE_HUNT_LOST_TRAIL = "I wonder where it went...",
	ANNOUNCE_WHALE_HUNT_LOST_TRAIL_SPRING = "The water is too rough!",

	DESCRIBE = {
	
		FLOTSAM = "If only I had some way of hooking on to it from here.",
		SUNKEN_BOAT = 
		{
			GENERIC = "That fellow looks like he wants to talk.",
			ABANDONED = "This is why I hate the water.",
		},		
		SUNKEN_BOAT_BURNT = "It's even less seaworthy than before.",
		
		BOAT_LOGRAFT = "This looks... sort of boat-like...",
		BOAT_RAFT = "This looks adequate.",
		BOAT_ROW = "It runs on elbow grease.",
		BOAT_CARGO = "It has room for all my stuff!",
		BOAT_ARMOURED = "That is one durable boat.",
		BOAT_ENCRUSTED = "A mere shell of a ship.",
		CAPTAINHAT = "The proper boating attire!",
		
		BOAT_TORCH = "This'll keep my hands free.",
		BOAT_LANTERN = "This will do wonders for my night vision!",
		BOATREPAIRKIT = "This will add some float to my boat.",
		BOATCANNON = "The only thing better than a boat is a boat with a cannon.",
		
		BOTTLELANTERN = "A bottle full of sunshine.",
		BIOLUMINESCENCE = "These make a soothing glow.",
		
		BALLPHIN = "Such a round, rubbery fellow.",
		BALLPHINHOUSE = "The place where the ballphins roost.",
		DORSALFIN = "Guess that house is FINished.",
		TUNACAN = "Where did this can come from?",
		
		JELLYFISH = "This creature is pure science!",
		JELLYFISH_DEAD = "It lived a good life. Maybe.",
		JELLYFISH_COOKED = "It's all wriggly.",
		JELLYFISH_PLANTED = "Science works in mysterious, blobby ways.",
		JELLYJERKY = "I'd be a jerk not to eat this.",
		RAINBOWJELLYFISH = "That's a lot of tendrils.",
		RAINBOWJELLYFISH_DEAD = "An electric shock will not revive it. I tried.",
		RAINBOWJELLYFISH_COOKED = "A colorful snack!",
		RAINBOWJELLYFISH_PLANTED = "A colorful blob of science.",
		JELLYOPOP = "Jelly-O pop it right in my mouth!",
		
		CROCODOG = "I'd rather stay away from the business end of that jerk.",
		POISONCROCODOG = "That looks like an experiment gone wrong.",
		WATERCROCODOG = "It's a dog-eat-me world out here.",
		
		PURPLE_GROUPER = "Surf and turf, hold the turf.",
		PIERROT_FISH = "This one's extra water repellent.",
		NEON_QUATTRO = "It looks like a fish, but it feels clammy.",
		PURPLE_GROUPER_COOKED = "That fish is fin-ished.",
		PIERROT_FISH_COOKED = "Gilled to perfection.",
		NEON_QUATTRO_COOKED = "Fried fry.",
		TROPICALBOUILLABAISSE = "I seasoned it with a dash of science.",
		
		FISH_FARM = 
		{
			EMPTY = "I need to find some fish eggs for this.",
			STOCKED = "The fish babies haven't hatched yet.",
			ONEFISH = "There's a fish!",
			TWOFISH = "The fish are still multiplying.",
			REDFISH = "This has been a successful fish experiment!",
			BLUEFISH  = "I'd better start harvesting these!",
		},
		
		ROE = "Fish babies.",
		ROE_COOKED = "Roe, sunny side up.",
		CAVIAR = "I never had it before I came here.",
		
		CORMORANT = "I bet it eats a lot of fish.",
		SEAGULL = "Shoo! Find some other land!",
		SEAGULL_WATER = "Shoo! Find some other water!",
		TOUCAN = "I tou-can't catch him.",
		PARROT = "I find myself fresh out of crackers.",
		PARROT_PIRATE = "I try not to eat anything with a name.",
		
		SEA_YARD =
		{
			ON = "For keeping my ships in tiptop shape!",
			OFF = "It's not in shipshape right now.",
			LOWFUEL = "I'll need to refill it soon.",
		},
		
		SEA_CHIMINEA = 
		{
			EMBERS = "Better put something on it before it goes out.",
			GENERIC = "Science protect my fires out here.",
			HIGH = "I'm glad we're surrounded by water.",
			LOW = "It's getting low.",
			NORMAL = "As cozy as it gets.",
			OUT = "It finally went out.",
		}, 
		
		CHIMINEA = "Take that, wind!",
		
		TAR_EXTRACTOR =
		{
			ON = "It's running smoothly.",
			OFF = "I have to turn it on.",
			LOWFUEL = "I need to refuel that.",
		},
		
		TAR = "Do I have to hold it with my bare hands?",
		TAR_TRAP = "Who's cleaning that up, I wonder?",
		TAR_POOL = "There must be a way to get that tar out.",
		TARLAMP = "That's a real slick lamp.",
		TARSUIT = "I'll pitch a fit if I have to wear that.",
		
		PIRATIHATITATOR =
		{
			GENERIC = "It's twisting my tongue.",
			BURNT = "Fire doesn't really solve naming issues...",
		},
		
		PIRATEHAT = "Fit for a cutthroat scallywag. Or me.",
		
		MUSSEL_FARM =
		{
			GENERIC = "I wonder if they are from Brussels.",
			STICKPLANTED = "I really stuck it to them."
		},

		MUSSEL = "Could use some flexing.",
		MUSSEL_COOKED = "I cook a mean mussel.",
		MUSSELBOUILLABAISE = "Imagine the experiments I could run on it!",
		MUSSEL_BED = "I should find a good spot for these.",
		MUSSEL_STICK = "I'm really going to stick it to those mussels.",
		
		LOBSTER = "What a Wascally Wobster.",
		LOBSTER_DEAD = "You should cook up nicely.",
		LOBSTER_DEAD_COOKED = "I can't wait to eat you.",
		LOBSTERHOLE = "That Wascal is sleeping.",
		WOBSTERBISQUE = "Could use more salt, but that's none of my bisque-ness.",
        WOBSTERDINNER = "If I eat it in the morning is it still dinner?",
		SEATRAP = "For the deadliest catch.",
		
		BUSH_VINE =
		{
			BURNING = "Whoops.",
			BURNT = "I feel like I could have prevented that.",
			CHOPPED = "Take that, nature!",
			GENERIC = "It's all viney!",
		},
		VINE = "Maybe I can tie stuff up with this.",
		DUG_BUSH_VINE = "I suppose I should pick it up.",
		
		ROCK_LIMPET =
		{
			GENERIC = "I could fill a pail with all those snails.",
			PICKED = "I can't fill a pail without snails.",
		},
		
		LIMPETS = "Maybe starving wouldn't be so bad.",
		LIMPETS_COOKED = "Escargotcha!",
		BISQUE = "Cooking that sure kept me bisque-y!",
		
		MACHETE = "I like the cut of this blade.",
		GOLDENMACHETE = "Hack in style!",
		
		THATCHPACK = "I call it a thatchel.",
		PIRATEPACK = "I can keep my booty in here.",
		SEASACK = "I hate when food has that not-so-fresh taste.",
		
		SEAWEED_PLANTED =
        {
            GENERIC = "Is that what passes for food around here?",
            PICKED = "It's plucked clean.",
        },
		
		SEAWEED = "A weed. Of the sea.",
		SEAWEED_COOKED = "Crispy.",
		SEAWEED_DRIED = "Salty!",
		SEAWEED_STALK = "Should plant this somewhere.",
		
		DUBLOON = "I'm rich!",
		SLOTMACHINE = "I suppose I could linger for a moment or two.",
		
		SOLOFISH = "It has that wet-dog smell.",
		SOLOFISH_DEAD = "Good dog.",
		SWORDFISH = "I think this fish evolved to run me through.",
		SWORDFISH_DEAD = "I better not run with this.",
		CUTLASS = "I hope this sword doesn't start to smell...",
		
		SUNKEN_BOAT_TRINKET_1 = "An instrument of some sort.", --sextant
		SUNKEN_BOAT_TRINKET_2 = "Now all I need is a miniaturization machine!", --toy boat
		SUNKEN_BOAT_TRINKET_3 = "Looks kinda soggy.", --candle
		SUNKEN_BOAT_TRINKET_4 = "Scientific!", --sea worther
		SUNKEN_BOAT_TRINKET_5 = "If only I had another!", --boot
		TRINKET_IA_13 = "What is this substance?", --orange soda
		TRINKET_IA_14 = "This thing gives me the creeps...", --voodoo doll
		TRINKET_IA_15 = "Incredible! This guitar has undergone shrinkification!", --ukulele
		TRINKET_IA_16 = "How did this get all the way out here?", --license plate
		TRINKET_IA_17 = "Where's the other one?", --boot
		TRINKET_IA_18 = "A relic of a bygone era!", --vase
		TRINKET_IA_19 = "Clouding of the brain. Never heard of it...", --brain cloud pill
		TRINKET_IA_20 = "I'm not sure what it is, but it makes me feel smarter!", --sextant
		TRINKET_IA_21 = "I ought to measure it to ensure it's to scale.", --toy boat
		TRINKET_IA_22 = "I'm sure someone would like this.", --wine candle
		TRINKET_IA_23 = "Someone lost their words.", --broken aac device
		EARRING = "The fewer holes in my body, the better.",
		
		TURF_BEACH = "Sandy ground.",
		TURF_JUNGLE = "Very gnarled ground.",
		TURF_MAGMAFIELD = "Lava-y floor.",
		TURF_TIDALMARSH = "Marsh-y floor.",
		TURF_ASH = "Ashy turf.",
		TURF_MEADOW = "Meadow-y turf.",
		TURF_VOLCANO = "Volcano-y turf.",
		TURF_SWAMP = "Swampy turf.",
		TURF_SNAKESKIN = "Sssstylish ssssstatement.",
		
		WHALE_BLUE = "That whale has emotional issues.",
		WHALE_CARCASS_BLUE = "Gross. I think the bloating has begun.",
		WHALE_WHITE = "Looks like a fighter.",
		WHALE_CARCASS_WHITE = "Gross. I think the bloating has begun.",
		WHALE_TRACK = "Whale, ho!",
		WHALE_BUBBLES = "Something down there has bad breath.",
		BLUBBERSUIT = "Well, it's something.",
		BLUBBER = "Squishy.",
		HARPOON = "I don't intend to harp on the issue.",
		
		SAIL_PALMLEAF = "This should really transform my boating experience.",
		SAIL_CLOTH = "That wind isn't getting away now!",
		SAIL_SNAKESKIN = "Scale it and sail it!",
		SAIL_FEATHER = "It's feather-light!",
		IRONWIND = "This is how a scientist should travel.",
		
		BERMUDATRIANGLE = "Gives me an uneasy feeling.",
		
		PACKIM_FISHBONE = "This seems like something I should carry around.",
		PACKIM = "I bet I could pack'im full of stuff.",
		
		TIGERSHARK = "Well that's terrifying.",
		MYSTERYMEAT = "I'm not dissecting that.",
		SHARK_GILLS = "I wish I had gills.",
		TIGEREYE = "More eyes means better sight... right?",
		DOUBLE_UMBRELLAHAT = "The second umbrella keeps the first umbrella dry.",
		SHARKITTEN = "You've got to be kitten me!",
		SHARKITTENSPAWNER = 
		{
			GENERIC = "Is that sand pile purring?",
			INACTIVE = "That is a rather large pile of sand.",
		},
		
		WOODLEGS_KEY1 = "Something, somewhere must be locked.",--unused
		WOODLEGS_KEY2 = "This key probably unlocks something.",--unused
		WOODLEGS_KEY3 = "That's a key.",--unused
		WOODLEGS_CAGE = "That seems like an excessive amount of locks.",--unused
		
		CORAL = "Living building material!",
		ROCK_CORAL = "The coral's formed a reef!",
		LIMESTONENUGGET = "Could be a useful building material.",
		NUBBIN = "I want nubbin to do with that.",
		CORALLARVE = "That's a baby coral reef.",
		WALL_LIMESTONE = "Sturdy.",
		WALL_LIMESTONE_ITEM = "These would do more good if I placed them.",
		WALL_ENFORCEDLIMESTONE = "I shelled out for the good stuff.",
		WALL_ENFORCEDLIMESTONE_ITEM = "I have to build it in the water.",
		ARMORLIMESTONE = "I'm sure this will hold up great!",
		CORAL_BRAIN_ROCK = "I wonder what it's plotting...",
		CORAL_BRAIN = "Food for thought.",
		BRAINJELLYHAT = "Two brains means double the ideas!",
		
		SEASHELL = "Maybe I could sell these.",
		SEASHELL_BEACHED = "Sea refuse.",
		ARMORSEASHELL = "Arts and crafts!",
		
		ARMOR_LIFEJACKET = "Keeps me afloat, without my boat!",
		ARMOR_WINDBREAKER = "The wind doesn't stand a chance!",
		
		SNAKE = "I wonder if it'll sell me some oil?",
		SNAKE_POISON = "Even worse than a regular snake!",
		SNAKESKIN = "I'm intrigued AND repelled.",
		SNAKEOIL = "The label says \"Jay's Wondrous Snake Oil!\"",
		SNAKESKINHAT = "It should repel the rain from my hair.",
		ARMOR_SNAKESKIN = "How fashionable!",
		SNAKEDEN =
		{
			BURNING = "Whoops.",
			BURNT = "I feel like I could have prevented that.",
			CHOPPED = "Take that, nature!",
			GENERIC = "It's all viney!",
		},
		
		OBSIDIANFIREPIT =
		{
			EMBERS = "I should put something on the fire before it goes out.",
			GENERIC = "This fire pit is a conductor for even more... fire.",
			HIGH = "Good thing it's contained!",
			LOW = "The fire's getting a bit low.",
			NORMAL = "This is my best invention yet.",
			OUT = "At least I can start it up again.",
		},
		
		OBSIDIAN = "It's a fire rock.",
		ROCK_OBSIDIAN = "Blast it! It won't be mined!",
		OBSIDIAN_WORKBENCH = "I feel inspired.",
		OBSIDIANAXE = "A winning combination!",
		OBSIDIANMACHETE = "It's hot to the touch.",
		SPEAR_OBSIDIAN = "This will leave a mark.",
		VOLCANOSTAFF = "The label says \"Keep out of reach of children.\"",
		ARMOROBSIDIAN = "I'm a genius.",
		COCONADE =
		{
			BURNING = "This seems dangerous.",
			GENERIC = "I'll need to light it first.",
		},
		
		OBSIDIANCOCONADE =
		{
			BURNING = "Fire in the hole!",
			GENERIC = "It's even bombier!",
		},
		
		VOLCANO_ALTAR =
		{
			GENERIC = "It appears to be closed.",
			OPEN = "The altar is open and ready to accept offerings!",
		},
		
		VOLCANO = "My scientific know-how tells me that's a perfectly safe mountain!",
		VOLCANO_EXIT = "There's a cool breeze blowing in from outside.",
		ROCK_CHARCOAL = "Would need an awfully big stocking for that.",
		VOLCANO_SHRUB = "You look ashen.",
		LAVAPOOL = "A bit hot for my tastes.",
		COFFEEBUSH =
		{
			BARREN = "I think it needs to be fertilized.",
			WITHERED = "Looks malnourished.",
			GENERIC = "This is a plant I could learn to love.",
			PICKED = "Maybe they'll grow back?",
		},
		
		COFFEEBEANS = "They could use some roasting.",
		COFFEEBEANS_COOKED = "Heat definitely improved them.",
		DUG_COFFEEBUSH = "This belongs in the ground!",
		COFFEE = "Smells delicious and energizing!",
		
		ELEPHANTCACTUS =
		{
			BARREN = "It could use some ash, but I better stand back afterward.",
			WITHERED = "It could use some ash, but I better stand back afterward.",
			GENERIC = "Yikes! I could poke an eye out!",
			PICKED = "It's safe to approach for now.",
		},
		
		DUG_ELEPHANTCACTUS = "A portable poker plant.",
		ELEPHANTCACTUS_ACTIVE = "That cactus seems abnormally pokey.",
		ELEPHANTCACTUS_STUMP = "It'll sprout pokers again eventually.",
		NEEDLESPEAR = "I'm glad I didn't step on this.",
		ARMORCACTUS = "The best defense is a good offense.",
		
		TWISTER = "I thought it was strangely windy around here.",
		TWISTER_SEAL = "D'awww.",
		TURBINE_BLADES = "Perhaps this powered that beastly storm?",
		MAGIC_SEAL = "This is a powerful artifact.",
		WIND_CONCH = "I can hear the wind trapped within.",
		WINDSTAFF = "There must be a scientific explanation for this.",
		
		DRAGOON = "You're a quick one, aren't you?",
		DRAGOONHEART = "Where the dragoon once stored its feelings.",
		DRAGOONSPIT = "It's SPITacularly disgusting!",
		DRAGOONEGG = "Do I hear cracking?",
		DRAGOONDEN = "Even goons gotta sleep.",
		
		ICEMAKER = 
		{
			OUT = "It needs more fuel.",
			VERYLOW = "I can hear it sputtering.",
			LOW = "It seems to be slowing down.",
			NORMAL = "It's putting along.",
			HIGH = "It's running great!",
		},
		
		HAIL_ICE = "Chilling.",
		
		BAMBOOTREE =
		{
			BURNING = "Bye bye, bamboo.",
			BURNT = "I feel like I could have prevented that.",
			CHOPPED = "Take that, nature!",
			GENERIC = "Golly, it's even floatier than wood!", --"Looks pretty sturdy.", -Mob
		},
		
		BAMBOO = "Maybe I can bamboozle my enemies with this?",
		FABRIC = "Soft cloth made from hard roots!",
		DUG_BAMBOOTREE = "I need to plant this.",
		
		JUNGLETREE =
		{
			BURNING = "What a waste of wood.",
			BURNT = "I feel like I could have prevented that.",
			CHOPPED = "Take that, nature!",
			GENERIC = "That tree needs a hair cut.",
		},
		
		JUNGLETREESEED = "I can hear the hissing of tiny snakes.",
		JUNGLETREESEED_SAPLING = "It will grow into a nice jungle tree.",
		LIVINGJUNGLETREE = "Just like any other tree.",
		
		OX = "These creatures seem reasonable.",
		BABYOX = "Smaller, but just as smelly.",
		OX_HORN = "I grabbed the ox by the horn.",
		OXHAT = "Nice and dry. This helmet will protect me from the elements.",
		OX_FLUTE = "Is it dripping...?",
		
		MOSQUITO_POISON = "These blasted mosquitoes carry a terrible sickness.",
		MOSQUITOSACK_YELLOW = "Part of a yellow mosquito.",
		
		STUNGRAY = "I think I'll keep my distance.",
		POISONHOLE = "I think I'll stay away from that.",
		GASHAT = "Sucks all the stink out.",
		
		ANTIVENOM = "Tastes horrible!",
		VENOMGLAND = "Only poison can cure poison.",
		POISONBALM = "I do love not being poisoned.",
		
		SPEAR_POISON = "Now it's extra deadly.",
		BLOWDART_POISON = "The pointy end goes that way.",
		
		SHARX = "These things sure are persistent.",
		SHARK_FIN = "A sleek fin.",
		SHARKFINSOUP = "It's shark fin-ished!",
		SHARK_TEETHHAT = "What a dangerous looking hat.",
		AERODYNAMICHAT = "It really cuts through the air!",
		
		IA_MESSAGEBOTTLE = "Someone wrote me a note!",
		IA_MESSAGEBOTTLEEMPTY = "Just an empty bottle.",
		BURIEDTREASURE = "Please be a good treasure!",
		
		SAND = "A handy pile of pocket sand.",
		SANDDUNE = "You better stay out of my shoes.",
		SANDBAGSMALL = "This should keep the water out.",
		SANDBAGSMALL_ITEM = "A bag full of sand. Does science know no bounds?",
		SANDCASTLE =
		{
			SAND = "It's a sandcastle, in the sand!",
			GENERIC = "Look what I made!"
		},
		
		SUPERTELESCOPE = "I can see forever!",
		TELESCOPE = "I spy with my little eye...",
		
		DOYDOY = "I feel oddly protective of this dumb bird.",
		DOYDOYBABY = "What a cute little, uh, thing.",
		DOYDOYEGG = "Maybe I should have let it hatch.",
		DOYDOYEGG_COOKED = "A controlled chemical reaction has made this egg matter more nutritious.",
		DOYDOYFEATHER = "Soft AND endangered!",
		DOYDOYNEST = "It's for doydoy eggs, dummy.",
		TROPICALFAN = "Somehow the breeze comes out the back twice as fast.",
		
		PALMTREE =
		{
			BURNING = "What a waste of wood.",
			BURNT = "I feel like I could have prevented that.",
			CHOPPED = "Take that, nature!",
			GENERIC = "How tropical.",
		},
		
		COCONUT = "It requires a large nut hacker.",
		COCONUT_HALVED = "When I click them together, they make horsey sounds.",
		COCONUT_COOKED = "Now I just need a cake.",
		COCONUT_SAPLING = "It doesn't need my help to grow anymore.",
		PALMLEAF = "I'm fond of these fronds.",
		PALMLEAF_UMBRELLA = "My hair looks good wet... it's when it dries that's the problem.",
		PALMLEAF_HUT = "Shade, sweet shade.",
		LEIF_PALM = "Someone gimme a hand with this palm!",
		
		CRAB = 
		{
			GENERIC = "Don't get snappy with me, mister.",
			HIDDEN = "I wonder where that crabbit went?",
		},
		
		CRABHOLE = "They call a hole in the sand their home.",
		
		TRAWLNETDROPPED = 
		{
			SOON = "It is definitely sinking.",
			SOONISH = "I think it's sinking.",
			GENERIC = "It's bulging with potential!",
		},
		
		TRAWLNET = "Nothing but net.",
		IA_TRIDENT = "I wonder how old this artifact is?",
		
		KRAKEN = "Now's not the time for me to be Quacken wise!",
		KRAKENCHEST = "To the victor, the spoils.",
		KRAKEN_TENTACLE = "A beast that never sleeps.",
		QUACKENBEAK = "I'd say I made the pecking order around here quite clear.",
		QUACKENDRILL = "I can get more tar if I used this at sea.",
		QUACKERINGRAM = "Does my ingenuity know no bounds?!",
		
		MAGMAROCK = "I can dig it.",
		MAGMAROCK_GOLD = "I see a golden opportunity.",
		FLAMEGEYSER = "Maybe I should stand back.",
		
		TELEPORTATO_SW_RING = "Looks like I could use this.",
		TELEPORTATO_SW_BOX = "It looks like a part for something.",
		TELEPORTATO_SW_CRANK = "I wonder what this is used for.",
		TELEPORTATO_SW_POTATO = "Seems like it was made with a purpose in mind.",
		TELEPORTATO_SW_BASE = "I think it's missing some parts.",
		
		PRIMEAPE = "Those things are going to be the end of me.",
		PRIMEAPEBARREL = "Here be evil.",
		MONKEYBALL = "I have a strange desire to name it after myself.",
		WILBUR_UNLOCK = "He looks kind of regal.",--unused
		WILBUR_CROWN = "It's oddly monkey-sized.",--unused
		
		MERMFISHER = "You better not try anything fishy.",
		MERMHOUSE_FISHER = "Doesn't smell very good.",
		
		OCTOPUSKING = "I'm a sucker for this guy.",
		OCTOPUSCHEST = "I hope that thing is waterproof.",
		
		SWEET_POTATO = "Looks yammy!",
		SWEET_POTATO_COOKED = "Looks even yammier!",
		SWEET_POTATO_PLANTED = "That's an odd looking carrot.",
		SWEET_POTATO_SEEDS = "My very own plant eggs.",
		SWEET_POTATO_OVERSIZED = "I yam amazed with the results.",
		SWEETPOTATOSOUFFLE = "Sweet potato souffles are a rising trend.",
		
		BOAT_WOODLEGS = "A vessel fit for a scallywag.",
		WOODLEGSHAT = "Does it make me look scurvy... I mean scary!?",
		SAIL_WOODLEGS = "The quintessential pirate sail.",
		
		PEG_LEG = "I can perform amputations if anyone'd like to wear it for real.",
		PIRATEGHOST = "He met a terrible end. I will too if I don't get out of here.",
		
		WILDBORE = "Looks aggressive.",
		WILDBOREHEAD = "It smells as bad as it looks.",
		WILDBOREHOUSE = "What a bore-ing house.",
		
		MANGROVETREE = "I wonder if it's getting enough water?",
		MANGROVETREE_BURNT = "I wonder how that happened.",
		
		PORTAL_SHIPWRECKED = "It's broken.",
		SHIPWRECKED_ENTRANCE = "Ahoy!",
		SHIPWRECKED_EXIT = "And so, I sail away into the horizon!",
		
		TIDALPOOL = "A pool, left by the tides.",
		FISHINHOLE = "This area seems pretty fishy.",
		FISH_TROPICAL = "What a tropical looking fish.",
		TIDAL_PLANT = "Look. A plant.",
		MARSH_PLANT_TROPICAL = "Planty.",
		
		FLUP = "Leave me alone!",
		BLOWDART_FLUP = "Eye see.",
		
		SEA_LAB = "For sea science!",
		BUOY = "Awww yaaaaa buoy!", 
		WATERCHEST = "Watertight, just like all my theories.",
		
		LUGGAGECHEST = "It looks like a premier steamer trunk.",
		WATERYGRAVE = "Sure, I could fish it out of there. But should I?",
		SHIPWRECK = "Poor little boat.",
		BARREL_GUNPOWDER = "How original.",
		RAWLING = "It's my buddy!",
		GRASS_WATER = "I hope you're thirsty, grass.",
		KNIGHTBOAT = "Get off the waterway, you maniac!",
		
		DEPLETED_BAMBOOTREE = "Will it grow again?",
		DEPLETED_BUSH_VINE = "One day it may return.",
		DEPLETED_GRASS_WATER = "Farewell, sweet plant.",
		
		WALLYINTRO_DEBRIS = "Part of a wrecked ship.",--unused
		BOOK_METEOR = "The foreword just says \"Hope you like dragoons.\"",
		CRATE = "There must be a way to open it.",
		SPEAR_LAUNCHER = "Science takes care of me.",
		MUTATOR_TROPICAL_SPIDER_WARRIOR = "Ah, I... just ate! Why don't you give it to one of your spider friends?",
		
		CHESSPIECE_KRAKEN = "I'll never get the seawater out of my hair.",
		CHESSPIECE_TIGERSHARK = "It's slightly less terrifying like this.",
		CHESSPIECE_TWISTER = "It really sends a chisel down my spine.",
		CHESSPIECE_SEAL = "Something so cute could never do any wrong.",
		
		--SWC
		BOAT_SURFBOARD = "Radical!",
		SURFBOARD_ITEM = "Radical!",

		WALANI = {
            GENERIC = "Greetings, %s!",
            ATTACKER = "%s looks shifty, like her boots are full of sand...",
            MURDERER = "Murderer! What got into you, %s?",
            REVIVER = "%s, chills with ghosts.",
            GHOST = "I better concoct a relaxed heart for %s.",
			FIRESTARTER = "Fire? Was that an accident, %s?",
		},

		WILBUR = {
			GENERIC = "Good day to you, %s!",
			ATTACKER = "%s has gone bananas!",
			MURDERER = "%s's gone berserk!",
			REVIVER = "%s, friend of ghosts. Monkey ghosts.",
			GHOST = "%s could use a heart and some bananas.",
			FIRESTARTER = "Someone needs to teach you fire safety, and quick.",
		},

		WOODLEGS = {
            GENERIC = "Greetings, %s!",
            ATTACKER = "%s is taking this pirate thing too seriously.",
            MURDERER = "%s has gone full cutthroat scallywag!",
            REVIVER = "%s, sailing friendships!",
            GHOST = "%s could use a heart, but he'd prefer gold.",
			FIRESTARTER = "Just doing classic pirate stuff, aye %s?",
		},
	},
}
