--Putting this here and will update over time so it doesn't get corrupted again.
return {

ACTIONFAIL =
{
	REPAIRBOAT = 
	{
		GENERIC = "No further repairs needed.",
	},
	EMBARK = 
	{
		INUSE = "Ah, someone got to the dinghy before me.",
	},
	INSPECTBOAT = 
	{
		INUSE = GLOBAL.STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.STORE.INUSE
	},
},

ANNOUNCE_MAGIC_FAIL = "I don't get this magic stuff.",

ANNOUNCE_SHARX = "Something sounds wet and hungry out there.",

ANNOUNCE_TREASURE = "Buried treasure!",
ANNOUNCE_TREASURE_DISCOVER = "Hear that? That's the sound of treasure plantin'! Let's go!",
ANNOUNCE_MORETREASURE = "I'm spoiled, more treasure!",
ANNOUNCE_OTHER_WORLD_TREASURE = "Doesn't look like anywhere I've been.",
ANNOUNCE_OTHER_WORLD_PLANT = "I thinks this needs a different kinda soil.",

ANNOUNCE_IA_MESSAGEBOTTLE =
{
	"I thought *my* handwriting was bad. Ha.",
},
ANNOUNCE_VOLCANO_ERUPT = "Uh... did anyone else feel that?",
ANNOUNCE_MAPWRAP_WARN = "Lil' hazy over there.",
ANNOUNCE_MAPWRAP_LOSECONTROL = "I can't see where I'm going!",
ANNOUNCE_MAPWRAP_RETURN = "Where am I? Oh, still here.",
ANNOUNCE_CRAB_ESCAPE = "The crab skittered off.",
ANNOUNCE_TRAWL_FULL = "My net's full, time to collect!",
ANNOUNCE_BOAT_DAMAGED = "I should tape these holes up.",
ANNOUNCE_BOAT_SINKING = "I don't think tape will be enough now.",
ANNOUNCE_BOAT_SINKING_IMMINENT = "That's a lotta damage!",
ANNOUNCE_WAVE_BOOST = "Whoo nelly!",

ANNOUNCE_WHALE_HUNT_BEAST_NEARBY = "I see something blubbery over there!",
ANNOUNCE_WHALE_HUNT_LOST_TRAIL = "Drat. I lost the trail.",
ANNOUNCE_WHALE_HUNT_LOST_TRAIL_SPRING = "I can't see the bubbles over the waves.",

DESCRIBE = {
	SEAWEED_STALK = "Lemme get this back in the water somewhere.",

	WILDBOREGUARD = "All I need's a red cape and I can have some fun. Ha!",
	SOLOFISH_DEAD = "Sorry, fella.",
	PURPLE_GROUPER = "What a stupid lookin' face.",
	PURPLE_GROUPER_COOKED = "Face-free.",

	GHOST_SAILOR = "Looks like that dog stayed salty. Ha!",
	FLOTSAM = "A cautionary tale of bad craftsmanship.",
	SUNKEN_BOAT = 
	{
		GENERIC = "You built this ship? No wonder it's sunk, ha!",
		ABANDONED = "Some things even I can't fix.",
	},
	SUNKEN_BOAT_BURNT = "There was nothing left for it anyway.",
	SUNKBOAT = "It's beyond my help.",
	BISQUE = "Cold soup's on!",
	SHARKFINSOUP = "Waiter, there's a shark in my soup!",
	JELLYOPOP = "The stinging's been cooked outta it.",

	BOAT_ENCRUSTED = "A naturally armored ship.",
	BABYOX = "I'm surprised it can stay above the water.",
	BALLPHINHOUSE = "I'd love to know how they built that.",
	DORSALFIN = "I hope nobody needed this.",
	NUBBIN = "It's a nub of a reef.",
	CORALLARVE = "So you're the one who built them rocks.",
	RAINBOWJELLYFISH = "Not a stinger, I guess.",
	RAINBOWJELLYFISH_PLANTED = "That guy had a bright idea. Ha!",
	RAINBOWJELLYFISH_DEAD = "Hope it's safe to eat.",
	RAINBOWJELLYFISH_COOKED = "Taste the rainbow.",
	RAINBOWJELLYJERKY = "No more glow-y stuff left.",
	WALL_ENFORCEDLIMESTONE = "I like where it is current-ly. Ha!",
	WALL_ENFORCEDLIMESTONE_ITEM = "Not as pretty as the reefs, but it's more useful.",
	CROCODOG = "Heheh. I can't take those squeaks seriously.",
	POISONCROCODOG = "Chew on this, ya mutt!",
	WATERCROCODOG = "You can't be that naturally wet.",
	QUACKENBEAK = "I've seen uglier chompers in the factory.",
	QUACKERINGRAM = "I wish I had this for city traffic!",

	CAVIAR = "I don't get the hubbub. They're just fish eggs.",
	CORMORANT = "Loud guy.",

	PURPLE_GROUPER = "What a stupid lookin' face.",
	PIERROT_FISH = "It's a flounder, isn't it?",
	NEON_QUATTRO = "Cool fish. No really, it's chilly.",

	PURPLE_GROUPER_COOKED = "Face-free.",
	PIERROT_FISH_COOKED = "It learned what a fire was.",
	NEON_QUATTRO_COOKED = "It's warmer than before.",

	FISH_FARM = 
	{
		EMPTY = "No farms work without fuel.",
		STOCKED = "The fish hasn't hatched yet.",
		ONEFISH = "Ooh, I see the little guy!",
		TWOFISH = "There's a few more!",
		REDFISH = "It's close to bursting!",
		BLUEFISH  = "It can't hold any more, time to harvest.",
	},

	ROE = "Bit small for eatin'.",
	ROE_COOKED = "Not the kinda fried eggs I'm used to.",
	
	SEA_YARD =
	{
		ON = "Now this is efficiency!",
		OFF = "Maybe I should build an automatic fueler too.",
		LOWFUEL = "I should top it off.",
	},

	SEA_CHIMINEA = 
	{
		EMBERS = "It's almost kaput.",
		GENERIC = "Keeps the fire nice and dry on the sea.",
		HIGH = "Roarin' high.",
		LOW = "It'll be out soon.",
		NORMAL = "It's nice to dry off by.",
		OUT = "I can always light it again.",
	}, 

	TAR = "Glad I'm handling this stuff with gloves.",
	TAR_EXTRACTOR =
	{
		ON = "Is there anything heavy machinery can't do?",
		OFF = "It's better to leave that thing runnin'.",
		LOWFUEL = "It needs a lil fuel.",
	},
	TAR_POOL = "The sea isn't supposed to be black, right?",

	TARLAMP = "That's a handy lil light.",
	TARSUIT = "I know it's water resistant, but come on.",
	TAR_TRAP = "Anyone have a sponge?",

	TROPICALBOUILLABAISSE = "It has different tastes each bite.",
	
	SEA_LAB = "Good thing water doesn't affect this doohickey.",
	WATERCHEST = "It looks like it's gonna sink any moment.",
	QUACKENDRILL = "Is there nothing engineering can't do?",
	HARPOON = "Looking sharp!",
	MUSSEL_BED = "These lil' workers need a new home.",
	ANTIVENOM = "Bleh, tastes like castor oil.",
	POISONBALM = "What'd the bean sprout whip up now?",
	VENOMGLAND = "Haha, gross.",
	BLOWDART_POISON = "Best not breathe in while using this.",
	OBSIDIANMACHETE = "It's powered by hard work. My kind of tool.",
	SPEARGUN_POISON = "High velocity poisoning.",
	OBSIDIANSPEARGUN = "By definition, this is a flame-thrower now. Ha!",
	LUGGAGECHEST = "Could be some good loot in there.",
	PIRATIHATITATOR =
	{
		GENERIC = "That lever is still there.",
		BURNT = "I'll have to build this one again.",
	},
	COFFEEBEANS = "I should toss them over a fire.",
	COFFEE = "Essential for any hard worker!",
	COFFEEBEANS_COOKED = "Ah, the smell of coffee beans in the morning!",
	COFFEEBUSH =
	{
		BARREN = "Buddy needs some ash.",
		WITHERED = "What happened here?",
		GENERIC = "Oh, mama!",
		PICKED = "There's no beans left, aw man.",
	},
	COFFEEBOT = "The pinnacle of engineering.",
	MUSSEL = "The food's on the inside.",
	MUSSEL_FARM =
	{
		 GENERIC = "Looks like some shells from here.",
		 STICKPLANTED = "Work smarter, not harder."
	},

	MUSSEL_STICK = "Sticks can become mussels with enough work.",
	LOBSTER = "Don't get snappy with me.",
	LOBSTERHOLE = "Seems easy to make with those kinda claws.",
	WOBSTERBISQUE = "Hey Warly? Can you just keep makin' this forever?",
    WOBSTERDINNER = "That's some pretty fancy lookin' grub!",
	SEATRAP = "It's a fancy dinner catcher.",
	SANDCASTLE =
	{
		SAND = "It definitely is a sand castle.",
		GENERIC = "Now isn't that cute."
	},
	BOATREPAIRKIT = "Who needs glue? My tape is sticky enough.",

	BALLPHIN = "Intelligent little guy.",
	BOATCANNON = "Excavation crew is here!",
	BOTTLELANTERN = "Where's the power source?",
	BURIEDTREASURE = "Today's my lucky day!",
	BUSH_VINE =
	{
		BURNING = "Oh... darn.",
		BURNT = "Not much that crispy vines can do.",
		CHOPPED = "It's on break.",
		GENERIC = "It's real tangle-y.",
	},
	CAPTAINHAT = "Look at me, I am the captain now. Ha!",
	COCONADE =
	{
		BURNING = "Fire in the hole!",
		GENERIC = "It's definitely creative, I'll give it that.",
	},
	CORAL = "I never built with this stuff before.",
	ROCK_CORAL = "Yup, it's a colorful rock.",
	CRABHOLE = "Those crabs sure know a lot about burying themselves.",
	CUTLASS = "Clean cut on that huge schnoz.",
	DUBLOON = "It's not much, but at least I'm being paid.",
    FABRIC = "Glad I didn't have to tear my clothes for this.",
    FISHINHOLE = "A school of fish, getting them ready for work.",
    GOLDENMACHETE = "This just made my job easier.",
    JELLYFISH = "If you hit it, it hits back. That's the worker class!",
    JELLYFISH_DEAD = "This one won't be doing any work anymore.",
    JELLYFISH_COOKED = "Chewy.",
    JELLYFISH_PLANTED = "Blob away, jelly!",
    JELLYJERKY = "Dried under the sun.",

    ROCK_LIMPET =
    {
        GENERIC = "It's full of the little grubs!",
        PICKED = "No one left to tell the story.",
    },
    BOAT_LOGRAFT = "I could do better...",
    MACHETE = "Hack and slash! Working's always fun.",
    IA_MESSAGEBOTTLEEMPTY = "No more letters left for me.",
    MOSQUITO_POISON = "Can't afford getting bitten by this one.",
    OBSIDIANCOCONADE = "Too much fire can lead to accidents.",
    OBSIDIANFIREPIT =
    {
        EMBERS = "On its last legs.",
        GENERIC = "As hot as a factory furnace.",
        HIGH = "Properly roaring.",
        LOW = "It's gonna go out soon.",
        NORMAL = "About as cozy as it gets out here.",
        OUT = "My sister was afraid of the dark.",
    },
	OX = "I bet they gotta work overtime with all that heavy wet fur.",
	PIRATEHAT = "Yo ho ho, to work we go!",
	BOAT_RAFT = "You'll be fine, Winona. You'll be fine.",
	BOAT_ROW = "If I wanna move, I gotta put my back into it.",
	SAIL_PALMLEAF = "I'll let the wind take over for a while.",
	SANDBAG_ITEM = "Big ol' bag of sand.",
	SANDBAG = "That sure is a bag of sand.",
	SEASACK = "It'll keep my spoils nice and fresh.",
	SEASHELL_BEACHED = "Mhmm, that's a shell.",
	SEAWEED = "It's a bit slimy.",

	SEAWEED_PLANTED = "Sea greens.",
	SLOTMACHINE = "Come on, momma needs a new pair of work gloves!",
	SNAKE_POISON = "That snake don't look right.",
	SNAKESKIN = "The texture feels incredible. I got some ideas for this.",
	SNAKESKINHAT = "Snake-powered storm protection.",
	SOLOFISH = "Here, boy!",
	SPEARGUN = "Requires extra assembly.",
	SWORDFISH = "And I thought my landlord's nose was big. Ha!",
	IA_TRIDENT = "A true tool of the sea.",
	SUNKEN_BOAT_TRINKET_1 = "I don't know how to use this doohickey.", --sextant
	SUNKEN_BOAT_TRINKET_2 = "Looks like Willow's bear might get outta here yet.", --toy boat
	SUNKEN_BOAT_TRINKET_3 = "A light that won't light.", --candle
	SUNKEN_BOAT_TRINKET_4 = "I, uh, uhm... huh?", --sea worther
	SUNKEN_BOAT_TRINKET_5 = "A workboot with no worker attached.", --boot
	TRINKET_IA_13 = "Finally, something drinkable. Debatably.", --orange soda
	TRINKET_IA_14 = "Bleh, a handcrafted mess.", --voodoo doll
	TRINKET_IA_15 = "Someone built this a bit too small.", --ukulele
	TRINKET_IA_16 = "Maybe the rest of the car is down there somewhere?", --license plate
	TRINKET_IA_17 = "So that's what happened to my old pair!", --boot
	TRINKET_IA_18 = "Duct tape can't fix that.", --ancient vase
	TRINKET_IA_19 = "Don't take strange medicines, kids.", --brain cloud pill
	TRINKET_IA_20 = "Nice metalwork for... whatever it is.", --sextant
	TRINKET_IA_21 = "Looks like Willow's bear might get outta here yet.", --toy boat
	TRINKET_IA_22 = "Kitschy.", --wine candle bottle
	TRINKET_IA_23 = "My old boss would know what this needs.", --AAC Device
	--One True Earring is prefabbed "Earring" for some reason
	TURBINE_BLADES = "Beautifully manufactured!",
	TURF_BEACH = "Best not get it in my overalls.",
	TURF_JUNGLE = "Lemme stick this back down somewhere.",
	VOLCANO_ALTAR =
	{
		GENERIC = "Guess it's closed for now.",
		OPEN = "Good thing it mostly takes food, huh?",
	},
	VOLCANO_ALTAR_BROKEN = "Huh... can I fix that?",
	WHALE_BLUE = "Why so blue?",
	WHALE_CARCASS_BLUE = "Uh oh, it's bloating.",
	WHALE_CARCASS_WHITE = "Uh oh, it's bloating.",

	ARMOR_SNAKESKIN = "Practical.",
	SAIL_CLOTH = "Build smarter, not harder.",
	DUG_COFFEEBUSH = "Once I get this into the ground, I can have my grounds. Ha!",
	LAVAPOOL = "Molten lava, stand back!",
	BAMBOO = "Light and sturdy. I could use some more of this.",
	AERODYNAMICHAT = "Function over fashion.",
	POISONHOLE = "Reeks like a factory.",
	BOAT_LANTERN = "Some hands-free light at sea.",
	SWORDFISH_DEAD = "I'm glad I didn't become a shish-kebab.",
	LIMPETS = "A handful of rock-snails.",
	OBSIDIANAXE = "I'm hacking heat!",
	COCONUT = "I gotta hack it open if I want what's inside.",
	COCONUT_SAPLING = "It'll grow up soon enough.",
	COCONUT_COOKED = "This goes well with dessert.",
	BERMUDATRIANGLE = "Huh, the stories always made it sound bigger.",
	SNAKE = "Stay away from me, you snake!",
	SNAKEOIL = "Riiight. I don't buy it.",
	ARMORSEASHELL = "Just you try to poison me now!",
	SNAKE_FIRE = "Hot snake!",
	MUSSEL_COOKED = "It slides right down your throat.",

	PACKIM_FISHBONE = "That fat bird seems to like this fish bone in particular.",
	PACKIM = "Hey, don't go eating all my fish now, y'hear?",

	ARMORLIMESTONE = "It's nearly as sturdy as my own body, ha!",
	TIGERSHARK = "Um, good kitty...?",
	WOODLEGS_KEY1 = "Yep, that's a key.",
	WOODLEGS_KEY2 = "There is no doubt that this is a key.",
	WOODLEGS_KEY3 = "Woah! A key.",
	WOODLEGS_CAGE = "How'd you get in there, you old coot?",
	OBSIDIAN_WORKBENCH = "Turn up the heat, or get out of the forge!",

	NEEDLESPEAR = "It's bigger than your average knitting needle.",
	LIMESTONENUGGET = "These dead coral will be put to good use.",
	DRAGOON = "Those things have never seen leg day in their life.",

	ICEMAKER = 
	{
		OUT = "I need more stuff to burn- er... freeze?",
		VERYLOW = "Gonna need to refuel soon.",
		LOW = "The ice production is slowing down a bit.",
		NORMAL = "I'm gettin' ice just fine currently.",
		HIGH = "It's running a peak performance!",
	},

	DUG_BAMBOOTREE = "Doin' no good out of the ground.",
	BAMBOOTREE =
	{
		BURNING = "Wuh oh, wildfire!",
		BURNT = "That's a shame.",
		CHOPPED = "All gone.",
		GENERIC = "Sturdy, and durable? You're coming with me.", --"Looks pretty sturdy.", -Mob
	},
	
	JUNGLETREE =
	{
		BURNING = "I feel bad for whatever might be living in there.",
		BURNT = "Well, it's all charred now.",
		CHOPPED = "That was a big one.",
		GENERIC = "It's sure bigger than any tree I've seen!",
	},
	SHARK_GILLS = "Well, they won't work on me.",
	LEIF_PALM = "They're making it rain coconuts!",
	OBSIDIAN = "A heat packed rock.",
	BABYOX = "Hey, lil buddy.",
	STUNGRAY = "Since when do they fly?!",
	SHARK_FIN = "What can I do with this now?",
	FROG_POISON = "Uh oh, he looks sick.",
	BOAT_ARMOURED = "Now this is how a handywoman should get around.",
	ARMOROBSIDIAN = "I'm the fire hazard!",
	BIOLUMINESCENCE = "I wanna stick my hand in and scoop some up.",
	SPEAR_POISON = "That's a sick day waiting to happen.",
	SPEAR_OBSIDIAN = "I'm glad I'm not on the business side of it.",
	SNAKEDEN =
	{
		BURNING = "Oh... darn.",
		BURNT = "Not much that crispy vines can do.",
		CHOPPED = "It's on break.",
		GENERIC = "It's real tangle-y.",
	},
	TOUCAN = "Look at the beak on that one!",
	IA_MESSAGEBOTTLE = "Oh hey, look! It's a note.",
	SAND = "Yep, I'm holding a pile of sand.",
	SANDDUNE = "It's all rough and coarse.",
	PEACOCK = "Hey! What do you think you're doin'?",
	VINE = "It's strong! I can tie stuff up with this.",
	SUPERTELESCOPE = "I can see my house from here-- oh wait, just another island.",
	SEAGULL = "Can they get any more noisy?",
	SEAGULL_WATER = "Can you get any more noisy?",
	PARROT = "Wolly want a cracker?",
	ARMOR_LIFEJACKET = "Looks like this boating job comes with some benefits.",
	WHALE_BUBBLES = "What's causing all that?",
	EARRING = "Too fancy for my tastes, thanks.",
	ARMOR_WINDBREAKER = "Happens to everyone.",
	SEAWEED_COOKED = "It's not as slimy anymore.",
	BOAT_CARGO = "It's my big, bouyant toolbox.",
	GASHAT = "It keeps the fumes out. A factory essential.",
	ELEPHANTCACTUS = "Those are some huge spikes on that cactus.",
	DUG_ELEPHANTCACTUS = "I'll plant it a safe distance away from the rest of us.",
	ELEPHANTCACTUS_ACTIVE = "That cactus really doesn't like me.",
	ELEPHANTCACTUS_STUMP = "It's all pokered out.",
	SAIL_FEATHER = "It's as close to a flying machine as I'm gonna get!",
	WALL_LIMESTONE_ITEM = "I should get these set up somewhere.",
	JUNGLETREESEED = "A big tree inside a little cone.",
	JUNGLETREESEED_SAPLING = "I wonder at what point the snakes move in?",
	VOLCANO = "Is that active?! I should be very careful.",
	IRONWIND = "Winona, you've outdone yourself yet again.",
	SEAWEED_DRIED = "Crunchy break snacks.",
	TELESCOPE = "I see you!",
	
	DOYDOY = "Dumber than a box of rocks.",
	DOYDOYBABY = "They're kinda cute when they're babies.",
	DOYDOYEGG = "That's a big'un.",
	DOYDOYEGG_CRACKED = "No sense in letting it go to waste.",
	DOYDOYFEATHER = "It's more useful than other feathers I've seen.",

	PALMTREE =
	{
		BURNING = "I should've had a way to put that out.",
		BURNT = "Shame to let a good palm burn.",
		CHOPPED = "Well that's the end of that.",
		GENERIC = "What a good tree to take my break under.",
	},
	PALMLEAF = "Could be some portable shade.",
	CHIMINEA = "Keeps the fires from gettin' winded. Ha!",
	DOUBLE_UMBRELLAHAT = "Someone produced too many umbrellas.",
	CRAB = 
	{
		GENERIC = "Looks a little crabby to me.",
		HIDDEN = "Hey, don't hide from me!",
	},
	TRAWLNET = "I wonder what I can wrestle up with this?",
	TRAWLNETDROPPED = 
	{
		SOON = "Oh boy, it's sinking now.",
		SOONISH = "Better make sure that's empty before I lose the net.",
		GENERIC = "Look at all that!",
	},
	VOLCANO_EXIT = "I think I'm ready to climb down, too hot up here.",
	SHARX = "It wants my food, my boat, and me!",
	SEASHELL = "Definitely a shell.",
	WHALE_BUBBLES = "What's causing all that?",
	MAGMAROCK = "What's under that pile of rocks?",
	MAGMAROCK_GOLD = "There's gold in them there rocks!",
	CORAL_BRAIN_ROCK = "I feel a bit smarter when I sail by it.",
	CORAL_BRAIN = "I got a piece of coral brain. Now what?",
	SHARKITTEN = "Their mommy can't be far away.",
	SHARKITTENSPAWNER = 
	{
		GENERIC = "Here, kitty kitty!",
		INACTIVE = "Whose job is it to clear that up?",
	},
	LIVINGJUNGLETREE = "Did that tree groan?",
	WALLYINTRO_DEBRIS = "That's beyond my help.",
	MERMFISHER = "He seems to wanna keep to himself.",
	PRIMEAPE = "Enough monkey business!",
	PRIMEAPEBARREL = "I bet half of that isn't even theirs.",
	BARREL_GUNPOWDER = "That's gonna go off with a loud BOOM if I'm not careful.",
	PORTAL_SHIPWRECKED = "Wonder what happened there?",
	MARSH_PLANT_TROPICAL = "Shrubby.",
	TELEPORTATO_SW_POTATO = "Looks like some kinda handcrafted junk.",
	PIKE_SKULL = "Yikes.",
	PALMLEAF_HUT = "Who knew palms were a hundred percent rainproof?",
	LOBSTER_DEAD = "These things are pretty good eating.",
	MERMHOUSE_FISHER = "I could build better.",
	WILDBORE = "Hey, you go your way, I'll go mine.",
	PIRATEPACK = "Dubloons! Don't drop 'em.",
	TUNACAN = "Crazy what you find out at sea.",
	MOSQUITOSACK_YELLOW = "Poison-free. Mostly.",
	SANDBAGSMALL = "These bags of sand are pretty waterproof.",
	FLUP = "Stay in the ground!",
	OCTOPUSKING = "Look at this guy, lazing around on a rock all day.",
	OCTOPUSCHEST = "Got any more of those down there?",
	GRASS_WATER = "It's certainly well watered.",
	WILDBOREHOUSE = "Hardly passes inspection.",
	TURF_SWAMP = "That's a chunk of swamp.",
	FLAMEGEYSER = "Maybe I should stand back.",
	KNIGHTBOAT = "The clockworks have taken over the navy!",
	MANGROVETREE_BURNT = "But how? It's on the water.",
	TIDAL_PLANT = "It's definitely planty.",
	WALL_LIMESTONE = "Just you try to knock that down.",
	LOBSTER_DEAD_COOKED = "Just gotta avoid the shell.",
	BLUBBERSUIT = "Never did I think I'd be wearing this.",
	BLOWDART_FLUP = "I fail to see its usefulness.",
	TURF_MEADOW = "A chunk 'a meadow.",
	TURF_VOLCANO = "A chunk 'a volcano.",
	SWEET_POTATO = "Sweet and starchy.",
	SWEET_POTATO_COOKED = "Hot, mushy, sweet, and starchy.",
	SWEET_POTATO_PLANTED = "That a potato?",
	SWEET_POTATO_SEEDS = "Time to stick these in a farm.",
	BLUBBER = "Piles of whale fat. Fascinating.",
	TELEPORTATO_SW_RING = "Just a piece of a hole. Ha!",
	TELEPORTATO_SW_BOX = "Oh hey, it's a thing! That does... stuff.",
	TELEPORTATO_SW_CRANK = "It's a crank, but with nothing attached to it.",
	TELEPORTATO_SW_BASE = "Looks like the base of something bigger.",
	VOLCANOSTAFF = "This just failed every safety precaution at once.",
	THATCHPACK = "Now I can carry just a slight bit more.",
	SHARK_TEETHHAT = "Call me Winona, queen of the sea!",
	TURF_ASH = "A chunk 'a ash.",
	BOAT_TORCH = "This torch is a little light. Ha!",
	MANGROVETREE = "Doesn't look like it has a lotta wood.",
	HAIL_ICE = "A small chunk of ice.",
	FISH_TROPICAL = "It looks nice and colorful, but a fish is a fish.",
	TIDALPOOL = "That's a big pool of water.",
	WHALE_WHITE = "This sure ain't its first rumble.",
	VOLCANO_SHRUB = "That's to be expected on a volcano.",
	ROCK_OBSIDIAN = "It's solid! Gonna need to call the demolition crew.",
	ROCK_CHARCOAL = "It's a giant charred rock.",
	DRAGOONDEN = "Of course they only have dumbbells.",
	WILBUR_UNLOCK = "It's the king monkey, huh?",
	WILBUR_CROWN = "It says \"Property of W...\" Huh?",
	TWISTER = "Hunker down! That's one angry twister!",
	TWISTER_SEAL = "Who knew a cute lil thing could be so destructive?",
	MAGIC_SEAL = "Now where'd that lil guy get a hold of this thing?",
	WINDSTAFF = "Magic powered motoring!",
	WIND_CONCH = "I can hear the ocean. And a lot of other stuff too.",
	DRAGOONEGG = "Oh is that how they hatch?",
	BUOY = "It makes sure we don't get lost at sea.", 
	TURF_SNAKESKIN = "It's a chunk 'a snake.",
	DOYDOYNEST = "It keeps their eggs nice and safe. Frankly, I'm surprised.",
	ARMORCACTUS = "Right back at ya!",
	BIGFISHINGROD = "I'll catch those fish yet!",
	BRAINJELLYHAT = "I've tapped into the secrets of the coral brain.",
	COCONUT_HALVED = "Now I can get at that water inside.",
	CRATE = "Looks like I'll have to smash it.",
	DEPLETED_BAMBOOTREE = "Might need some fertilizer here.",
	DEPLETED_BUSH_VINE = "Needs some refueling.",
	DEPLETED_GRASS_WATER = "It's all withered up somehow.",
	DOYDOYEGG_COOKED = "Yum, endangered omelette.",
	DRAGOONHEART = "It used to pump a lot of stuff. Mostly protien.",
	DRAGOONSPIT = "What have you been eating??",
	DUG_BUSH_VINE = "That'd get more use in the ground.",
	KRAKEN = "He's mad!",
	KRAKENCHEST = "So this is what he didn't want me trawling up.",
	KRAKEN_TENTACLE = "I best not get dragged under by those things.",
	MAGMAROCK_FULL = "What's under that pile of rocks?",
	MAGMAROCK_GOLD_FULL = "There's gold in them there rocks!",
	MONKEYBALL = "I can't say I get it, but as long as those monkeys are entertained, I'm fine.",
	MUSSELBOUILLABAISE = "I can treat myself every once in a while.",
	MYSTERYMEAT = "How did that abomination happen?",
	OXHAT = "Seashells seems to be great at poison absorption.",
	OX_FLUTE = "Lemme see if I can play this, I've been practicing.",
	OX_HORN = "A souvenir of that time I almost got skewered.",
	PARROT_PIRATE = "Where'd you get that hat from, lil guy?",
	PEG_LEG = "I guess 'ol Woodlegs could always use a spare.",
	PIRATEGHOST = "I'll just be on my way.",
	SANDBAGSMALL_ITEM = "Small lil bag of sand.",
	SHADOWSKITTISH_WATER = "Wowzers!",
	SHIPWRECKED_ENTRANCE = "I think I've saved up enough vacation days.",
	SHIPWRECKED_EXIT = "That's enough tropical getaway for this gal.",
	SAIL_SNAKESKIN = "Just watch those scales catch the wind!",
	SPEAR_LAUNCHER = "Now I can spear things from far away!",
	SWEETPOTATOSOUFFLE = "Good stuff, Warly!",
	SWIMMINGHORROR = "Nessie!",
	TIGEREYE = "I rose up to the challenge of our rival.",
	TURF_MAGMAFIELD = "A chunk 'a magma.",
	TURF_TIDALMARSH = "A chunk 'a marsh.",
	VOLCANO_ALTAR_TOWER = "That's unnerving.",
	WATERYGRAVE = "I feel bad for whoever that was.",
	WHALE_TRACK = "Whale on the horizon, fellas!",
	WILDBOREHEAD = "I can't stand looking at it.",
	BOAT_WOODLEGS = "Now Woodlegs sure knows how to make a boat.",
	WOODLEGSHAT = "It belongs to that salty dog!",
	SAIL_WOODLEGS = "The skull and crossbones really sell the look.",
	SHIPWRECK = "Some things even I can't fix.",
	INVENTORYGRAVE = "Whose was this, do ya think?",
	INVENTORYMOUND = "Whose was this, do ya think?",
	LIMPETS_COOKED = "Welp, down the hatch.",
	RAWLING = "Am I finally losing it? I'm talking to a ball.",
	
	BOOK_METEOR = "What are these, some kinda volcano blueprints?",

	CHESSPIECE_KRAKEN = "Hah, it looks like it's screamin'.",
	--CHESSPIECE_TIGERSHARK = "TEMP, put something here",
	--CHESSPIECE_TWISTER = "TEMP, put something here",
	--CHESSPIECE_SEAL = "TEMP, put something here",

	--SWC
	BOAT_SURFBOARD = "That board finally has a purpose, hey?",
	SURFBOARD_ITEM = "That board finally has a purpose, hey?",

	WALANI = {
		GENERIC = "How's life treating ya, %s?",
		ATTACKER = "Didn't know ya had it in ya, %s!",
		MURDERER = "Murder isn't the kinda work I've been tellin' ya to do %s!",
		REVIVER = "You're good people, %s. Ya could do some more workin' though!",
		GHOST = "You'd probably get cut worse out in the waters, %s.",
		FIRESTARTER = "A fire? That's not like ya, %s. Something up?",
	},

	WILBUR = {
		GENERIC = "Is that a monkey? They even have monkeys in this place!",
		ATTACKER = "That monkey's lookin' mighty feral!",
		MURDERER = "Yikes! Feral monkey!",
		REVIVER = "Thanks for the assist, %s. Didn't know ya could do that!",
		GHOST = "Nothing big, at least for a so-called monkey king! You'll be fine.",
		FIRESTARTER = "That monkey's got a torch!",
	},

	WOODLEGS = {
		GENERIC = "Hey there, %s. Yarr-harr!",
		ATTACKER = "Woah! Watch those angry pirate pegs or yours, matey!",
		MURDERER = "Taking the pirate thing too far, %s!",
		REVIVER = "That was good work there, %s. Your heart's the real treasure here!",
		GHOST = "Shake it off, %s, that's nothin' to a captain!",
		FIRESTARTER = "Quit startin' fires, %s! Check your pegs!",
	},
},
}
