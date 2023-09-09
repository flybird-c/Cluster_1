-- This speech is for Walter
return {

	ACTIONFAIL =
	{
		REPAIRBOAT = 
		{
			GENERIC = "Hey, I don't think that needs fixing!",
		},
		EMBARK = 
		{
			INUSE = "You go on ahead, Woby and I will catch up!",
		},
		INSPECTBOAT = 
		{
			INUSE = GLOBAL.STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.STORE.INUSE
		},
		OPEN_CRAFTING  = 
   		{
        FLOODED = "Welp, guess we can live without science.",
		}, 

	},
	
	ANNOUNCE_MAGIC_FAIL = "Yeah, let's be sensible about this.",
	
	ANNOUNCE_SHARX = "Whoa, a real shark attack!",
	
	ANNOUNCE_TREASURE = "Treasure?",
	ANNOUNCE_TREASURE_DISCOVER = "What's it, girl? Treasure up ahead?",
	ANNOUNCE_MORETREASURE = "Oh! There's more treasure!",
	ANNOUNCE_OTHER_WORLD_TREASURE = "That's pretty far to go for treasure, but I'm up for it.",
	ANNOUNCE_OTHER_WORLD_PLANT = "Yup, all plants need their habitats.",
	
	ANNOUNCE_IA_MESSAGEBOTTLE =
	{
		"I can't make anything out of it.",
	},
	ANNOUNCE_VOLCANO_ERUPT = "A real eruption! Things are getting exciting.",
	ANNOUNCE_MAPWRAP_WARN = "I think I saw a fog monster up ahead!",
	ANNOUNCE_MAPWRAP_LOSECONTROL = "W-whoa, it's dragging me in! Hi, fog monster!",
	ANNOUNCE_MAPWRAP_RETURN = "Wait, I had so many questions to ask you! Drat...",
	ANNOUNCE_CRAB_ESCAPE = "Umm, my handbook has nothing on how to deal with this...",
	ANNOUNCE_TRAWL_FULL = "And that's a haul done! Let's take a look, Woby.",
	ANNOUNCE_BOAT_DAMAGED = "I wonder if there's a badge for boat maintenance.",
	ANNOUNCE_BOAT_SINKING = "We may need to repair this soon, haha...",
	ANNOUNCE_BOAT_SINKING_IMMINENT = "I-I don't think I can swim my way back!",
	ANNOUNCE_WAVE_BOOST = "Woohoo!",
	
	ANNOUNCE_WHALE_HUNT_BEAST_NEARBY = "We're close to the sea monster! Yes!",
	ANNOUNCE_WHALE_HUNT_LOST_TRAIL = "We'll get you next time, sea monster!",
	ANNOUNCE_WHALE_HUNT_LOST_TRAIL_SPRING = "I can't keep track of the trail like this.",

	DESCRIBE = {
	
		FLOTSAM = "I wonder if a sea monster got them?",
		SUNKEN_BOAT = 
		{
			GENERIC = "We should introduce it to Polly someday!",
			ABANDONED = "Oh, it took off.",
		},
		
		SUNKEN_BOAT_BURNT = "It was Willow, wasn't it?",
		SUNKBOAT = "Could be the handiwork of a sea monster!",

		BOAT_LOGRAFT = "Just like the ones we used to make to cross rivers!",
		BOAT_RAFT = "I didn't have bamboo back home, but it's so handy!",
		BOAT_ROW = "We're getting better at carving boats.",
		BOAT_CARGO = "You can fit almost all your camping goods in there!",
		BOAT_ARMOURED = "Appropriate protection against giant sea monster teeth!",
		BOAT_ENCRUSTED = "I don't really understand how it doesn't sink.",
		CAPTAINHAT = "It makes me look like a real captain!",

		BOAT_TORCH = "It's important to have good visibility while sailing.",
		BOAT_LANTERN = "Hey, that's pretty bright!",
		BOATREPAIRKIT = "I'll need to maintain Woby's boat as well.",
		BOATCANNON = "A portable cannon! Not bad.",

		BOTTLELANTERN = "Light the way, lantern.",
		BIOLUMINESCENCE = "I wish I had a jar on me.",

		BALLPHIN = "Dolphins! I heard about them in a radio show.",
		BALLPHINHOUSE = "That must be where the dolphins live. Makes sense.",
		DORSALFIN = "You could probably scare a kid with this. But not me.",
		TUNACAN = "Not catching it yourself takes the joy out of it.",

		JELLYFISH = "Ha ha... you wouldn't sting me... right little guy?",
		JELLYFISH_DEAD = "It's not dangerous like this, right?",
		JELLYFISH_COOKED = "Well, survivors can't be picky.",
		JELLYFISH_PLANTED = "We'd better keep our distance, Woby.",
		JELLYJERKY = "Dried jellyfish just isn't real jerky.",
		RAINBOWJELLYFISH = "At least I know it can't sting me.",
		RAINBOWJELLYFISH_PLANTED = "Look at the colors on that one, Woby!",
		RAINBOWJELLYFISH_DEAD = "Haha... Whoops.",
		RAINBOWJELLYFISH_COOKED = "That's some pretty looking food.",
		JELLYOPOP = "All food's better on a stick.",

		CROCODOG = "Oh, I've never seen a dog like that before!",
		POISONCROCODOG = "Who's a good boy?",
		WATERCROCODOG = "Yup. Definitely smells of dog.",
	
		PURPLE_GROUPER = "Aww, it's got a massive forehead!",
		PIERROT_FISH = "Well, those are nice stripes.",
		NEON_QUATTRO = "At least it's not made of ice.",
		PURPLE_GROUPER_COOKED = "That cooked nicely.",
		PIERROT_FISH_COOKED = "That's a beautiful lunch right there.",
		NEON_QUATTRO_COOKED = "I'm glad it doesn't melt when you cook it.",
		TROPICALBOUILLABAISSE = "That's some rich fish flavor!",

		FISH_FARM = 
		{
			EMPTY = "We need roe if we want fish.",
			STOCKED = "Nope, nothing's hatched yet.",
			ONEFISH = "Look, there's a fish!",
			TWOFISH = "There's another! We're starting our own herd!",
			REDFISH = "I don't think there's a badge for farming fish...",
			BLUEFISH  = "Oh boy, sure would be a shame if all this fish lured in a sea monster!",
		},
	
		ROE = "It's fish eggs. Haha, ew...",
		ROE_COOKED = "How did they arrange in rows like that?",
		CAVIAR = "Seems real fancy for desert island food.",

		CORMORANT = "Hey, that's not a crow!",
		SEAGULL = "Well, it's in my pocket guide.",
		SEAGULL_WATER = "Well, it's in my pocket guide.",
		TOUCAN = "Okay, that one's definitely unfamiliar.",
		PARROT = "A parrot! Do you speak, birdie?",
		PARROT_PIRATE = "It's a real pirate parrot!",

		SEA_YARD =
		{
			ON = "Boat maintenance is of top priority when sailing.",
			OFF = "Well, it needs to be turned on.",
			LOWFUEL = "I'd better find something to fuel it with.",
		},
	
		SEA_CHIMINEA = 
		{
			EMBERS = "We should really fuel it soon.",
			GENERIC = "Anyone want to hear a scary story at sea?",
			HIGH = "Woah! I don't think that's safe.",
			LOW = "It needs more fuel.",
			NORMAL = "Perfect temperature for roasting marshmallows.",
			OUT = "All we need is more wood!",
		}, 

		CHIMINEA = "It's a wind-proof campfire.",

		TAR_EXTRACTOR =
		{
			ON = "You can really tell it's working by the smell alone.",
			OFF = "You want tar, you turn it on.",
			LOWFUEL = "Better not tar-ry and fuel it soon. Heheh.",
		},

		TAR = "Well, that's one way to keep a fire lit.",
		TAR_TRAP = "I don't think this is good for the environment...",
		TAR_POOL = "Oh, that's a pool of tar!",
		TARLAMP = "I think I'd rather use a flashlight still.",
		TARSUIT = "I'd better remember not to cook anything wearing this.",

		PIRATIHATITATOR =
		{
			GENERIC = "This reminds me of the story of that cursed pirate and his treasure and-",
			BURNT = "Whoops, story time's over.",
		},

		PIRATEHAT = "It really makes you look like a real pirate.",

		MUSSEL_FARM =
		{
			GENERIC = "Oh, this is just like that one story with the stranded man- Oh...",
			STICKPLANTED = "We'll have to wait until the mussels take the bait."
		},

		MUSSEL = "Real mussels, foraged straight from the sea!",
		MUSSEL_COOKED = "Hmm, they're pretty good!",
		MUSSELBOUILLABAISE = "Whoa, that smells great! Thanks, Warly!",
		MUSSEL_BED = "I suppose this is the next step after foraging.",
		MUSSEL_STICK = "Now we can reach them!",

		LOBSTER = "Shellfish are basically bugs of the sea.",
		LOBSTER_DEAD = "Well, it'll make a good dinner.",
		LOBSTER_DEAD_COOKED = "Mmm, smells good!",
		LOBSTERHOLE = "That's where the Wobsters make camp.",
        WOBSTERBISQUE = "It's tasty, I like it!",
        WOBSTERDINNER = "This seems pretty fancy for camping food.",
		SEATRAP = "Now we can catch sea bugs as well!",

		BUSH_VINE =
		{
			BURNING = "You're supposed to gather kindling first, THEN start the fire!",
			BURNT = "That one couldn't wait to be kindling...",
			CHOPPED = "That one's already been picked.",
			GENERIC = "I wonder if any cool bugs live among those vines.",
		},
		VINE = "Foraged vines, perfect for kindling and crafting.",
		DUG_BUSH_VINE = "Hey Woby, do you see a good spot to plant this?",
	
		ROCK_LIMPET =
		{
			GENERIC = "Hey, look at all the cool snails on that one!",
			PICKED = "No more interesting bugs to pick.",
		},

		LIMPETS = "More snails for my collection.",
		LIMPETS_COOKED = "Well, I guess it IS food...",
		BISQUE = "Hey, this is pretty good! What's in it?",

		MACHETE = "It's a real explorer's tool!",
		GOLDENMACHETE = "Seems a bit fancy for explorer work.",

		THATCHPACK = "It can fit a few supplies! And a lot more bugs.",
		PIRATEPACK = "It's got a curse that makes gold out of nothing!",
		SEASACK = "Keeps my snacks fresh. And a bit salty.",

		SEAWEED_PLANTED =
        {
            GENERIC = "Hey, I think that's some edible seaweed! Or a hidden monster.",
            PICKED = "It was just seaweed, I guess.",
        },

		SEAWEED = "Sea monster hair. Duh.",
		SEAWEED_COOKED = "It's... A pile of goop. Sigh.",
		SEAWEED_DRIED = "Hey, that's pretty good!",
		SEAWEED_STALK = "I should probably put it back in the ocean.",

		DUBLOON = "Ow... I guess it's not chocolate, after all.",
		SLOTMACHINE = "Yeah, definitely too young for this.",
		
		SOLOFISH = "Look, Woby! It's a friend! Fetch!",
		SOLOFISH_DEAD = "I'd better not let Woby see this, haha...",
		SWORDFISH = "I didn't expect it to be a LITERAL swordfish! That's so cool!",
		SWORDFISH_DEAD = "We should probably put this to good use. Besides eating.",
		CUTLASS = "That's a real pirate sword! Yes!!",

		SUNKEN_BOAT_TRINKET_1 = "They never taught us how to use those.", --sextant
		SUNKEN_BOAT_TRINKET_2 = "Nope, Woby can't ride that..", --toy boat
		SUNKEN_BOAT_TRINKET_3 = "Mom would've loved this centerpiece.", --candle
		SUNKEN_BOAT_TRINKET_4 = "That's deeefinitely something magical.", --sea worther
		SUNKEN_BOAT_TRINKET_5 = "Way too big. Also, it's falling apart.", --boot
		TRINKET_IA_13 = "I don't think we should drink the soda we found out here.", --orange soda
		TRINKET_IA_14 = "Yup, that's totally cursed.", --voodoo doll
		TRINKET_IA_15 = "Hey, we could sing songs around a campfire with this!", --ukulele
		TRINKET_IA_16 = "Hmm...", --license plate
		TRINKET_IA_17 = "Way too big. Also, it's falling apart.", --boot
		TRINKET_IA_18 = "My mom loved her fine china. Sigh...", --vase
		TRINKET_IA_19 = "That's... dangerous.", --brain cloud pill
		TRINKET_IA_20 = "They never taught us how to use one of these.", --sextant
		TRINKET_IA_21 = "Nope, Woby can't ride that.", --toy boat
		TRINKET_IA_22 = "Mom would've loved this on the dinner table.", --wine candle
		TRINKET_IA_23 = "Uh, I don't really know what it is.", --broken aac device
		EARRING = "More for the collection! Uh, it's not cursed, right?",
		
		TURBINE_BLADES = "You can really get some speed with this!",

		TURF_BEACH = "A patch of ground.",
		TURF_JUNGLE = "A patch of ground.",
		TURF_MAGMAFIELD = "A patch of ground.",
		TURF_TIDALMARSH = "A patch of ground.",
		TURF_ASH = "A patch of ground.",
		TURF_MEADOW = "A patch of ground.",
		TURF_VOLCANO = "A patch of ground.",
		TURF_SWAMP = "A patch of ground.",
		TURF_SNAKESKIN = "A patch of carpet.",

		WHALE_BLUE = "It's a real whale! Just like that one radio show about a ship of whale hunters, and-",
		WHALE_CARCASS_BLUE = "I'm preeeety sure that's not safe to be around.",
		WHALE_WHITE = "Uh-oh, I think it's mad about that harpoon...",
		WHALE_CARCASS_WHITE = "Welp, we managed to hunt it down.",
		WHALE_TRACK = "Air bubbles left by an animal... Or better yet, a sea monster!",
		WHALE_BUBBLES = "Where are you, big guy? I just want to be friends!",
		BLUBBERSUIT = "Oh, this is some real survivor stuff!",
		BLUBBER = "Woby loves chewing on these in particular.",
		HARPOON = "Hm, I don't think I have a badge for spearfishing...",

		SAIL_PALMLEAF = "It's always impressive how much you can make with things found in the wild!",
		SAIL_CLOTH = "A Pinetree Pioneer can adapt to any environment!",
		SAIL_SNAKESKIN = "The snakes wouldn't end up like this if they didn't try to eat me!",
		SAIL_FEATHER = "It's eye-catching. Maybe it'll draw the attention of a big sea monster?",
		IRONWIND = "Yup, definitely not something you'd usually find in nature.",


		BERMUDATRIANGLE = "Hey, I heard about those in the radio! Let's take a closer look!",
	
		PACKIM_FISHBONE = "Ugh, rotten fish- Oh, it doesn't reek.",
		PACKIM = "It's not that monster-like, but I still like it!",

		TIGERSHARK = "This makes so much more sense, honestly.",
		MYSTERYMEAT = "Ugh, that sure ruined my appetite.",
		SHARK_GILLS = "Was she a fish or a cat?",
		TIGEREYE = "I think it's keeping an eye on us. Get it? Because it's an eye?",
		DOUBLE_UMBRELLAHAT = "This feels silly...",
		SHARKITTEN = "Aww, they're so cute!",
		SHARKITTENSPAWNER = 
		{
			GENERIC = "It must be the home of a giant monster! I need to take a closer look!",
			INACTIVE = "Well, now it's just a pile of sand.",
		},

		WOODLEGS_KEY1 = "Not a skeleton... But even better! A spooky key!",--Unused
		WOODLEGS_KEY2 = "What do you think this'll open, Woby?",--Unused
		WOODLEGS_KEY3 = "Oh, it's a key!",--Unused
		WOODLEGS_CAGE = "Woah! Who left you locked up in there, mister?",--Unused

		CORAL = "That's some coral.",
		ROCK_CORAL = "Hey, I think those are coral reefs!",
		LIMESTONENUGGET = "Maybe they could make a really nifty fire pit.",
		NUBBIN = "It's nubbin important. Get it? Nubbin?",
		CORALLARVE = "Where should we put the corals, Woby?",
		WALL_LIMESTONE = "Looks pretty sturdy.",
		WALL_LIMESTONE_ITEM = "Looks pretty sturdy.",
		WALL_ENFORCEDLIMESTONE = "This'll make a good sea monster enclosure.",
		WALL_ENFORCEDLIMESTONE_ITEM = "Yup, walls that float.",
		ARMORLIMESTONE = "Can I even walk wearing that?",
		CORAL_BRAIN_ROCK = "That's one bright coral. Get it, bright- Oh, forget it.",
		CORAL_BRAIN = "It's pretty cool to look at, at least.",
		BRAINJELLYHAT = "Fills your head with the equivalent of ten- no, twenty Pinetree Pioneer handbooks!",

		SEASHELL = "Is there anything inside it? No? Aw...",
		SEASHELL_BEACHED = "Hey, that's a shell!",
		ARMORSEASHELL = "Shells are pretty handy when you get a bunch of them.",

		ARMOR_LIFEJACKET = "Finally, a real life jacket- Uh, no offense, Wes.",
		ARMOR_WINDBREAKER = "Seems a bit out of place in the wilderness, but it has an use.",

		SNAKE = "Woah, when did I last see one of these?",
		SNAKE_POISON = "Watch out! Look at the colors on that one!",
		SNAKESKIN = "It's slick. We might be able to use this for something.",
		SNAKEOIL = "Come on, even a child wouldn't fall for this...",
		SNAKESKINHAT = "Can I make Woby a little, matching one?",
		ARMOR_SNAKESKIN = "Wearing hunted animal skins, that's some real survivor stuff!",
		SNAKEDEN =
		{
			BURNING = "That's, one way to get rid of snakes?",
			BURNT = "At least the snakes can't bother us again.",
			CHOPPED = "Nothing left to gather here.",
			GENERIC = "Some vines. With snakes in it, if we're lucky.",
		},

		OBSIDIANFIREPIT =
		{
			EMBERS = "We need more fuel for the fire!",
			GENERIC = "Anyone want to hear a scary story?",
			HIGH = "Woah! I don't think that's safe...",
			LOW = "It might need some fuel.",
			NORMAL = "Perfect temperature for marshmallows.",
			OUT = "All we'll need later is more wood!",
		},

		OBSIDIAN = "I'd better be careful not to cut myself with this.",
		ROCK_OBSIDIAN = "It's really hardy for glass.",
		OBSIDIAN_WORKBENCH = "I wonder if an alien dumped it here?",
		OBSIDIANAXE = "This seems like a fire hazard...",
		OBSIDIANMACHETE = "This must be what adventurers use in the North Pole.",
		SPEAR_OBSIDIAN = "Great for getting your points across... Heh.",
		VOLCANOSTAFF = "Yeah... If Willow gets her hands on this, we're doomed.",
		ARMOROBSIDIAN = "Woah! It's not even burning me!",
		COCONADE =
		{
			BURNING = "Get clear!",
			GENERIC = "Yup. That's an exploding coconut.",
		},

		OBSIDIANCOCONADE =
		{
			BURNING = "Stay clear of the blast!",
			GENERIC = "An exploding glass coconut. What could go wrong?",
		},

		VOLCANO_ALTAR =
		{
			GENERIC = "Did that bowl-thing just whisper something?",
			OPEN = "What will happen if it's not sated? Aah, the suspense!",
		},

		VOLCANO = "It's a real volcano! I have to get a closer look!",
		VOLCANO_EXIT = "Maybe we should go back down.",
		ROCK_CHARCOAL = "We won't have to burn more trees if we get our coal from here!",
		VOLCANO_SHRUB = "I'm surprised they grew up until that point at all, honestly.",
		LAVAPOOL = "Yep, that's toasty alright.",
		COFFEEBUSH =
		{
			BARREN = "Oh, all it needs is... Drat, my handbook has nothing about growing coffee.",
			WITHERED = "It doesn't like the weather.",
			GENERIC = "Some people call it java because it grows near lava. Makes sense!",
			PICKED = "If I wait long enough, they'll grow back.",
		},

		COFFEEBEANS = "I wish these were cocoa beans.",
		COFFEEBEANS_COOKED = "Smells great!",
		DUG_COFFEEBUSH = "You are coming  with me, florp.",
		COFFEE = "Mom would kill me if she caught me drinking this.",

		ELEPHANTCACTUS =
		{
			BARREN = "I-I think I'm fine with not feeding it ashes, honestly.",
			WITHERED = "It doesn't like the weather. Maybe that's a good thing...?",
			GENERIC = "I think that's a monster in disguise!",
			PICKED = "Ow!! Does anyone have a bandage?!",
		},

		DUG_ELEPHANTCACTUS = "I'm not too keen on planting that one, honestly.",
		ELEPHANTCACTUS_ACTIVE = "I think that one's a monster in disguise!",
		ELEPHANTCACTUS_STUMP = "Ow!! Does anyone have a bandage?!",
		NEEDLESPEAR = "Just in case we needle something pointy... Okay, that was bad.",
		ARMORCACTUS = "No hugging while you're wearing that.",
		
		TWISTER = "The wind is alive! Hello, wind! Can you hear me?",
		TWISTER_SEAL = "Huh. Aw... It was just a little seal.",
		MAGIC_SEAL = "This'll come in handy... I think.",
		WIND_CONCH = "You can really hear the wind if you hold it by your ear! ...Wait a minute.",
		WINDSTAFF = "This looks like it could be very useful while sailing.",

		DRAGOON = "They remind me of Wolfgang. Just harder to get along with!",
		DRAGOONHEART = "This wouldn't have happened if it wasn't such a goon.",
		DRAGOONSPIT = "It not nice to spit!",
		DRAGOONEGG = "A real dragon egg!",
		DRAGOONDEN = "You can really tell it houses a gym rat. Or, gym goon.",

		ICEMAKER = 
		{
			OUT = "It just needs something to burn, right?",
			VERYLOW = "We'd better fetch it some fuel!",
			LOW = "It could probably use some more fuel",
			NORMAL = "That's ice! Get it, like nice? Ugh, forget it.",
			HIGH = "Brr, that's cold!",
		},

		HAIL_ICE = "They hurt a bit when they fall on your head.",
	
		BAMBOOTREE =
		{
			BURNING = "Hey, that's how forest fires start!",
			BURNT = "What a waste.",
			CHOPPED = "I think these grow back fast.",
			GENERIC = "They're called bamBOO, but there's nothing ghost-like about them.",
		},

		BAMBOO = "Tropical foraged material!",
		FABRIC = "This would make a superb scout scarf.",
		DUG_BAMBOOTREE = "Woby, do you see a good spot to plant this?",
		
		JUNGLETREE =
		{
			BURNING = "That's not how campfires work!",
			BURNT = "That one couldn't wait to be a campfire...",
			CHOPPED = "This tree looks stumped. Heh, nice one Walter.",
			GENERIC = "Look at the size of that tree! Well, I guess we've seen bigger...",
		},

		JUNGLETREESEED = "I'd better find a good spot to plant this.",
		JUNGLETREESEED_SAPLING = "One day you'll be a nice big tree.",
		LIVINGJUNGLETREE = "Can you talk? What's it like being a tree?",


		OX = "Woby smells like that when she's drenched.",
		BABYOX = "Hey little guy!",--unused
		OX_HORN = "Nope, not a decent bugle.",
		OXHAT = "Hey, that came out looking pretty good!",
		OX_FLUTE = "Being able to control nature is pretty nifty.",

		MOSQUITO_POISON = "You wouldn't want to make me sick, right little guy?",
		MOSQUITOSACK_YELLOW = "I'm not... squeamish...",

		STUNGRAY = "Woah, someone's had chili day!",
		POISONHOLE = "That's a safety hazard!",
		GASHAT = "I could really have used something like this before.",

		ANTIVENOM = "It's bitter, so it's good for you!",
		VENOMGLAND = "It's brimming with venom... Haha...",
		POISONBALM = "I'll gladly take a balm over a syrup...",
		
		SPEAR_POISON = "Now we can sting them back!",
		BLOWDART_POISON = "Not as good as my slingshot, but it'll do.",

		SHARX = "Is that a dog that mutated into a shark? Or a shark that turned dog-like?",
		SHARK_FIN = "You could probably scare people if you swam with this strapped on your head.",
		SHARKFINSOUP = "It's tasty, I like it!",
		SHARK_TEETHHAT = "Really makes you look dangerous.",
		AERODYNAMICHAT = "It's like a good walking stick, but for your head.",

		IA_MESSAGEBOTTLE = "There's a note inside.",
		IA_MESSAGEBOTTLEEMPTY = "I could shove a few more bugs in there. My pockets are getting full.",
		BURIEDTREASURE = "Let's get to digging, Woby!",

		SAND = "That's sand.",
		SANDDUNE = "Woby likes digging into those the most.",
		SANDBAGSMALL = "This'll keep the camp flood-proof.",
		SANDBAGSMALL_ITEM = "Sand. In a bag.",
		SANDCASTLE =
		{
			SAND = "Yeah, it's not meant to last anyway.",
			GENERIC = "Hey, that's a nice castle."
		},

		SUPERTELESCOPE = "Eye sure can see a lot from here! Heh, good one Walter.",
		TELESCOPE = "That's an ingenious use for a bottle.",
		
		DOYDOY = "It's not dumb, it's just... Distracted. Very easily.",
		DOYDOYBABY = "Aw, look who's a sweet round thing!",
		DOYDOYEGG = "Oh, that's a big egg!",
		DOYDOYEGG_COOKED = "That's just how nature goes sometimes.",
		DOYDOYFEATHER = "Pillow material.",
		DOYDOYNEST = "Woah, did they build the doydoy head themselves?",
		TROPICALFAN = "I'm a big fan of keeping cool. Get it? Because... Forget it.",
	
		PALMTREE =
		{
			BURNING = "That's not good...",
			BURNT = "Fire safety is important, everyone.",
			CHOPPED = "That palm looks stumped... Haha, this never gets old.",
			GENERIC = "That's a palm tree.",
		},

		COCONUT = "Something tasty in the palm of my hand... Get it? Because it came from a palm tree?",
		COCONUT_HALVED = "Island food! Well, specifically an island fruit.",
		COCONUT_COOKED = "Goes to show you can forage for your own food anywhere.",
		COCONUT_SAPLING = "It'll be a tree someday.",
		PALMLEAF = "That's a big leaf.",
		PALMLEAF_UMBRELLA = "Improvisation is a top-importance skill in the wilderness.",
		PALMLEAF_HUT = "A perfect shelter, built from foraged material!",
		LEIF_PALM = "They've come to take their revenge!!",

		CRAB = 
		{
			GENERIC = "That's a crabbit. Come here little guy!",
			HIDDEN = "C'mon, get back here!",
		},

		CRABHOLE = "That's its den!",

		TRAWLNETDROPPED = 
		{
			SOON = "That's about to sink.",
			SOONISH = "It's going to sink soon.",
			GENERIC = "Let's see if it's caught anything interesting.",
		},

		TRAWLNET = "Fishing with a hand-woven net, real survivor stuff.",
		IA_TRIDENT = "What's the point? Well, there's three points.",

		KRAKEN = "Finally!! A real sea monster!",
		KRAKENCHEST = "Hey, it dropped treasure!",
		KRAKEN_TENTACLE = "It's attached to that big sea monster!",
		QUACKENBEAK = "That's a big beak.",
		QUACKENDRILL = "I'm not too keen on polluting the ocean, honestly.",
		QUACKERINGRAM = "Self-defense at sea, obviously.",

		MAGMAROCK = "It's a pile of rocks.",
		MAGMAROCK_GOLD = "Hey, that might be worth digging into!",
		FLAMEGEYSER = "A real geyser! Oh, I should probably keep my distance.",

		TELEPORTATO_SW_RING = "This doesn't seem all that natural...",--unused
		TELEPORTATO_SW_BOX = "Yup, definitely not something you'd find in nature.",--unused
		TELEPORTATO_SW_CRANK = "I wonder what left this here... Aliens, maybe?",--unused
		TELEPORTATO_SW_BASE = "This looks important.",--unused
		TELEPORTATO_SW_POTATO = "If you squint it looks like an alien's head.",--unused

		PRIMEAPE = "I don't think I've ever seen this kind of them in zoos!",
		PRIMEAPEBARREL = "If I left my room that messy, mom would yell at me.",
		MONKEYBALL = "This'll buy us some time with those monkeys.",
		WILBUR_UNLOCK = "A Pinetree Pioneer always helps those in need!",--unused
		WILBUR_CROWN = "It fits Woby's head, but not mine.",--unused

		MERMFISHER = "W-wait, I just want you to teach me how to spearfish!",
		MERMHOUSE_FISHER = "Smells like someone deserves their fishing badge.",

		OCTOPUSKING = "It's a retired pirate! That's so cool.",
		OCTOPUSCHEST = "Um, thanks!",

		SWEET_POTATO = "Sweet, a potato! Of the sweet kind!",
		SWEET_POTATO_COOKED = "Reminds me of mom's casserole. Sigh...",
		SWEET_POTATO_PLANTED = "I don't think that one's a carrot.",
		SWEET_POTATO_SEEDS = "We should find a place to plant these.",
		SWEETPOTATOSOUFFLE = "That smells superb! I'll dig right in, thanks Warly!",

		BOAT_WOODLEGS = "A real pirate ship! Does it have any ghosts?",
		WOODLEGSHAT = "That's a real pirate's hat!",
		SAIL_WOODLEGS = "The skull-and-bones is really iconic, isn't it?",

		PEG_LEG = "I don't think anyone would want to wear this for real, Wilson...",
		PIRATEGHOST = "I knew it, pirate curses were real! This would make a great midnight broadcast...",

		WILDBORE = "Oh, that's an angry pig!",
		WILDBOREHEAD = "Wait, Woby, don't chew on it!",
		WILDBOREHOUSE = "Honestly, I'd rather just camp forever.",

		MANGROVETREE = "Not the first seaborne tree we've seen.",
		MANGROVETREE_BURNT = "I don't know what to say, honestly.",

		PORTAL_SHIPWRECKED = "It's not working.",--In SW it's used for broken seaworthy --unused
		SHIPWRECKED_ENTRANCE = "Just a kid's novelty ride... Or is it? Aah, the suspense!",
		SHIPWRECKED_EXIT = "I don't know why I never expected this to work, honestly.",

		TIDALPOOL = "That's a pool left from tidal movement. Here, it's in my handbook.",
		FISHINHOLE = "I could try my hand at fishing there.",
		FISH_TROPICAL = "Look at the colors on that one!",
		TIDAL_PLANT = "It's a plant by the pool.",
		MARSH_PLANT_TROPICAL = "I wonder if there's any bugs living there.",

		FLUP = "Eye can see you... Get it, because-AAH!",
		BLOWDART_FLUP = "Well, this is pretty pathetic...",

		SEA_LAB = "They don't teach you how to build labs on water at school.",
		BUOY = "It's good to leave marks behind so you don't get lost.", 
		WATERCHEST = "A supply box that swims will come in handy.",

		LUGGAGECHEST = "Should we take a peek inside, Woby?",
		WATERYGRAVE = "Well, we know there's no skeleton down there.",
		SHIPWRECK = "That's a ship's wreck.",
		BARREL_GUNPOWDER = "I'd better make sure none of the younger kids sail near that.",
		RAWLING = "A real talking object! Are you a ghost haunting a basketball?",
		GRASS_WATER = "That's some waterlogged grass.",
		KNIGHTBOAT = "Quit horsing around!",

		DEPLETED_BAMBOOTREE = "It needs something to help it grow.",--unused?
		DEPLETED_BUSH_VINE = "It could use something to help it grow.",--unused?
		DEPLETED_GRASS_WATER = "Well, at least we know it's not thirsty.",--unused?

		WALLYINTRO_DEBRIS = "I'm sure we could salvage something from it", 
		BOOK_METEOR = "I'd better make sure not to get on her bad side.",
		CRATE = "I should bust that open.",
		SPEAR_LAUNCHER = "It gets your points across- Okay, fine, this joke got old.",
		MUTATOR_TROPICAL_SPIDER_WARRIOR = "Hey, cookies! Um... What are these made of, exactly?",

		CHESSPIECE_KRAKEN = "The stonework is Quacken! Get it?",
		--CHESSPIECE_TIGERSHARK = "TEMP, put something here",
		--CHESSPIECE_TWISTER = "TEMP, put something here",
		CHESSPIECE_SEAL = "He must have been sculpted at the age of six.",

		--SWC
		BOAT_SURFBOARD = "Uh, maybe I'll learn to surf someday.",
		SURFBOARD_ITEM = "That's Walani's.",

		WALANI = {
		    GENERIC = "What's up, %s?",
	        ATTACKER = "Maybe you need to 'chillax' a bit, %s.",
	        MURDERER = "You... How could you do such a thing?",
	        REVIVER = "%s is very dependable.",
	        GHOST = "Don't worry %s, Woby and I will get you back to napping in no time!",
	        FIRESTARTER = "Setting a real campfire isn't that much effort, %s.",
		},

		WILBUR = {
            GENERIC = "Hello, %s!",
            ATTACKER = "That's enough monkeying around, %s.",
            MURDERER = "You've gone bananas, %s!",
            REVIVER = "%s would make a good Pinetree Pioneer captain.",
            GHOST = "Will a banana make you feel better? Alright, alright I'll fetch a heart!",
            FIRESTARTER = "No, no! Fire bad, fire bad!",
		},

		WOODLEGS = {
            GENERIC = "It's a real pirate! Do you have any cool stories, %s?",
            ATTACKER = "%s seems worked up.",
            MURDERER = "I knew it! Once a pirate, always a pirate!",
            REVIVER = "%s is good at handling ghosts.",
            GHOST = "This reminds me of that one podcast with the cursed pirate- Fine, I'll fix you up!",
            FIRESTARTER = "We really need that fire safety meeting.",
		},
	},
}
