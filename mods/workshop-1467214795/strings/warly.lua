return{
    --By CheeseNuggets/Goat-Slice c: via 'Shipwrecked Characters'
	ACTIONFAIL = 
	{
--[[
	    REPAIR =
        {
            WRONGPIECE = "That was the incorrect ingredient.",
        },
	    BUILD =
        {
            MOUNTED = "The ground is simply too far below me.",
			HASPET = "I'm already busy with one, two is simply too much.",
        },
		SHAVE =
		{
			AWAKEBEEFALO = "It would be unwise to attempt this while the animal is awake.",
			GENERIC = "Not a shaveable beast.",
			NOBITS = "Nothing to shave.",
		},
		STORE =
		{
			GENERIC = "It is too full.",
			NOTALLOWED = "This is not the place for it.",
		    INUSE = "Right, pardon me. You first.",
		},
		CONSTRUCT =
        {
            INUSE = "Pardon me! It's already being worked on!",
            NOTALLOWED = "That isn't the correct ingredient.",
            EMPTY = "I require the ingredients first.",
            MISMATCH = "That is the incorrect recipe.",
        },
		RUMMAGE =
		{	
			GENERIC = "I cannot right now.",	
			INUSE = "After you!",	
		},
		USEKLAUSSACKKEY =
        {
        	WRONGKEY = "That was the incorrect ingredient.",
        	KLAUS = "We have quite the mess on our hands at the moment, I must try later.",
        },
        COOK =
        {
            GENERIC = "I'm not quite ready yet.",
            INUSE = "Excuse me, may I have a turn? I'm quite the chef myself, you know.",
            TOOFAR = "I'll need to get a little closer to cook with that.",
        },
        GIVE =
        {
		    GENERIC = "I simply cannot do that.",
            DEAD = "Oh dear...",
            SLEEPING = "It's sleeping.",
            BUSY = "Goodness, it seems busy.",
            ABIGAILHEART = "It pains me knowing it will never work.",
            GHOSTHEART = "I don't believe this apparition is real.",
			NOTGEM = "A proper chef knows not to throw just anything into a dish!",
            WRONGGEM = "I need to check the recipe list once more.",
            NOTSTAFF = "That is incorrect. I must try again.",
			MUSHROOMFARM_NEEDSSHROOM = "Could use a fresh mushroom or two.",
            MUSHROOMFARM_NEEDSLOG = "Definitely needs a log of the living variety.",
            SLOTFULL = "The seat is taken.",
            DUPLICATE = "I'm already quite aware of this.",
            NOTSCULPTABLE = "Not so fast, don't want to ruin anything do we?",
			NOTATRIUMKEY = "This is the incorrect ingredient.",
            CANTSHADOWREVIVE = "I simply cannot make it work.",
			WRONGSHADOWFORM = "Not quite right.",
			NOMOON = "I believe it requires a lunar influence.",
			PIGKINGGAME_MESSY = "Cleaning up the kitchen before cooking is a must.",
			PIGKINGGAME_DANGER = "We have much bigger pigs to fry.",
			PIGKINGGAME_TOOLATE = "I'd rather have a clear morning head.",
        },
        GIVETOPLAYER = 
        {
        	FULL = "I have a gift to give you! If you would mind emptying your pockets!",
            DEAD = "Well, I thought it was a fine gift. Nothing to die over.",
            SLEEPING = "Rise and shine, mon ami! I have something for you!",
            BUSY = "I'll have to try again later. They seem quite busy.",
    	},
    	GIVEALLTOPLAYER = 
        {
        	FULL = "Empty your rags, I have something more special, mon ami!",
            DEAD = "I, oh, I see... You're uh... a tad busy.",
            SLEEPING = "Rise and shine! A gift for you awaits!",
            BUSY = "I'll have to try again at a later date.",
    	},
        WRITE =
        {
            GENERIC = "Maybe later. My hands are covered in cooking oil.",
            INUSE = "Write away...",
        },
		DRAW =
        {
            NOIMAGE = "To create art I must first see it!",
        },
        CHANGEIN =
        {
            GENERIC = "I guess it never occurred to me I'd need to change.",
            BURNING = "It, oh, it appears to be on fire.",
			INUSE = "Well, I am excited to see your next outfit.",
        },
        ATTUNE =
        {
            NOHEALTH = "I'm not feeling of the best mind to do so...",
        },
        MOUNT =
        {
            TARGETINCOMBAT = "It would be unwise to attempt this while the animal is angry.",
            INUSE = "Oh. It must belong to someone else.",
        },
        SADDLE =
        {
            TARGETINCOMBAT = "It's too angry to do that.",
        },
		TEACH =
        {
            KNOWN = "Ah. I already knew that.",
            CANTLEARN = "That might be a bit beyond me.",
			WRONGWORLD = "This seems to point to points unknown.",
        },
		WRAPBUNDLE =
        {
            EMPTY = "I'd like to wrap up some fresh ingredients instead.",
        },
]]
		--IA
		REPAIRBOAT = 
	    {
		    GENERIC = "It will not work.",
	    },
	    EMBARK = 
	    {
		   INUSE = "Oh. It must belong to someone else.",
	    },
	    INSPECTBOAT = 
	    {
		   INUSE = GLOBAL.STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.STORE.INUSE
	    },
		--
	},
	-- ACTIONFAIL_GENERIC = "I cannot do that.",
	ANNOUNCE_MAGIC_FAIL = "Sadly, I can not make it work.",
	-- ANNOUNCE_MOUNT_LOWHEALTH = "It's best not to mount a steed that has an empty stomach!",
	-- ANNOUNCE_DIG_DISEASE_WARNING = "Saved it before it expired!",
    -- ANNOUNCE_PICK_DISEASE_WARNING = "That plant must be near its expiration date.",
	-- ANNOUNCE_ACCOMPLISHMENT = "I am triumphant!",
	-- ANNOUNCE_ACCOMPLISHMENT_DONE = "I hope this feeling lasts forever...",
	-- ANNOUNCE_ADVENTUREFAIL = "I shall have to attempt that again.",
	-- ANNOUNCE_BEES = "The honeymakers are upon me!",
	-- ANNOUNCE_BOOMERANG = "Ouch! Damnable thing!",
	-- ANNOUNCE_BURNT = "Charred...",
	-- ANNOUNCE_CANFIX = "\nI believe I could repair that.",
	-- ANNOUNCE_CHARLIE = "What the devil!",
	-- ANNOUNCE_CHARLIE_ATTACK = "Gah! I do believe something bit me!",
	-- ANNOUNCE_COLD = "I'm... getting freezerburn...",
	-- ANNOUNCE_CRAFTING_FAIL = "I am lacking the required ingredients.",
	-- ANNOUNCE_DAMP = "I've been lightly spritzed.",
	-- ANNOUNCE_WET = "I am getting positively drenched.",
	-- ANNOUNCE_WETTER = "I fear I may be water soluble!",
	-- ANNOUNCE_DEERCLOPS = "I do not like that sound one bit!",
	-- ANNOUNCE_CAVEIN = "I do believe the earth above is collapsing.",
--[[
	ANNOUNCE_ANTLION_SINKHOLE = 
	{
		"Oh dear... The ground around us is collapsing.",
		"Incoming!",
		"The ground rumbles.",
	},
	ANNOUNCE_ANTLION_TRIBUTE =
	{
        "I hope this shall calm your nerves.",
        "A lovely gift, for you!",
        "I shall hope this satisfies your needs, great beast.",
		"Bon Appetit!",
	},
]]
	-- ANNOUNCE_SACREDCHEST_YES = "I am triumphant!",
	-- ANNOUNCE_SACREDCHEST_NO = "I suppose not.",
	-- ANNOUNCE_DUSK = "The dinner hour approaches.",
--[[
	ANNOUNCE_EAT =
	{
		GENERIC = "Magnifique!",
		INVALID = "Clearly inedible.",
		PAINFUL = "Aarg! My stomach...",
		SPOILED = "Blech! Why did I allow that to cross my lips?",
		STALE = "That was past its best-by date...",
		PREPARED = "Delectable!",
		SAME_OLD_1 = "I'd prefer some variety.",
		-- SAME_OLD_2 = "So bland.",
		-- SAME_OLD_3 = "I want to eat something different.",
		-- SAME_OLD_4 = "I can't stand this food.",
		-- SAME_OLD_5 = "Enough already!",
		SAME_OLD_2 = "I want to eat something different.",
		SAME_OLD_3 = "I can't stand this food anymore.",
		TASTY = "Tres magnifique!",
		COOKED = "Not very palatable.",
		DRIED = "A bit dry.",
		RAW = "Blech. Completely lacking in every way.",
		YUCKY = "I'm frankly offended by the mere suggestion.",
	},
]]
--[[
	ANNOUNCE_ENCUMBERED =
    {
        "Must...keep marching forward...!",
        "I'll get there... And there'll be a feast...!",
        "I'm carrying the weight of the world...",
        "Crock pots are never this heavy...",
        "Make way! Huhff...Make way.",
        "The ending shall... taste rewarding! ...It always is.",
        "Hmmpfh...",
        "The finish line... I can already taste it...",
        "Lovely... day today... isn't it? Hmmph.",
        "A single step... a single success.",
    },
	ANNOUNCE_ATRIUM_DESTABILIZING = 
    {
		"It's about to blow this kitchen whole!",
		"I will not let the door hit me on the way out!",
		"That is our call to leave!",
	},
]]
	-- ANNOUNCE_RUINS_RESET = "Ah, the worm has turned.",
	-- ANNOUNCE_THURIBLE_OUT = "Darn!",
	-- ANNOUNCE_SNARED = "Trapped!",
	-- ANNOUNCE_REPELLED = "I cannot puncture it while shielded!",
	-- ANNOUNCE_ENTER_DARK = "Darkness, darkness.",
	-- ANNOUNCE_ENTER_LIGHT = "A new day comes with the dawning light.",
	-- ANNOUNCE_FREEDOM = "Freeeeeeee!",
	-- ANNOUNCE_HIGHRESEARCH = "My brain is tingling!",
	-- ANNOUNCE_HOT = "I'm baking like a souffle here...",
	-- ANNOUNCE_HOUNDS = "I recognize that sound. Hunger.",
	-- ANNOUNCE_WORMS = "That was not a comforting sound.",
	-- ANNOUNCE_HUNGRY = "I need food...",
	-- ANNOUNCE_HUNT_BEAST_NEARBY = "Game is close at hand...",
	-- ANNOUNCE_HUNT_LOST_TRAIL = "I have lost the trail.",
	-- ANNOUNCE_HUNT_LOST_TRAIL_SPRING = "The trail has been washed out.",
	-- ANNOUNCE_INSUFFICIENTFERTILIZER = "It requires more manure.",
	-- ANNOUNCE_INV_FULL = "I cannot carry another stitch.",
	-- ANNOUNCE_KNOCKEDOUT = "My head... spinning...",
	-- ANNOUNCE_LIGHTNING_DAMAGE_AVOIDED = "That was much too close!",
	-- ANNOUNCE_LOWRESEARCH = "I did not learn any new tricks from that.",
	-- ANNOUNCE_MOSQUITOS = "Disease with wings!",
	-- ANNOUNCE_NODANGERSIESTA = "This is no time to close my eyes!",
	-- ANNOUNCE_NOWARDROBEONFIRE = "The clothes are long gone by now...",
    -- ANNOUNCE_NODANGERGIFT = "This is not a time for gifts!",
	-- ANNOUNCE_NOMOUNTEDGIFT = "I should like to open this on the ground, not while riding a beefalo.",
	-- ANNOUNCE_NODANGERSLEEP = "In this particular instance I'd prefer not to die in my sleep!",
	-- ANNOUNCE_NODAYSLEEP = "It is too bright to sleep.",
	-- ANNOUNCE_NODAYSLEEP_CAVE = "I'm not tired.",
	-- ANNOUNCE_NOHUNGERSIESTA = "I could use a nice meal first.",
	-- ANNOUNCE_NOHUNGERSLEEP = "My hunger trumps my exhaustion.",
	-- ANNOUNCE_NONIGHTSIESTA = "Siesta in the dark? I think not.",
	-- ANNOUNCE_NONIGHTSIESTA_CAVE = "This does not strike me as a relaxing place for siesta.",
	-- ANNOUNCE_NOSLEEPONFIRE = "I think not! That's a hotbed for danger!",
	-- ANNOUNCE_NODANGERAFK = "I cannot make a quick escape just yet!",
	-- ANNOUNCE_NO_TRAP = "Went off without a hitch.",
	-- ANNOUNCE_PECKED = "Gah! Enough!",
	-- ANNOUNCE_QUAKE = "That is not a comforting sound...",
	-- ANNOUNCE_RESEARCH = "Education is a lifelong process.",
	-- ANNOUNCE_SHELTER = "I am thankful for this tree's protective buffer.",
	-- ANNOUNCE_SOAKED = "I'm wetter than a dish rag!",
	-- ANNOUNCE_THORNS = "Gah!",
	-- ANNOUNCE_TOOL_SLIP = "Everything is slick...",
	-- ANNOUNCE_TORCH_OUT = "Come back, light!",
	-- ANNOUNCE_FAN_OUT = "It fell apart in my hands!",
    -- ANNOUNCE_COMPASS_OUT = "Oh. I believe it broke.",
	-- ANNOUNCE_TRAP_WENT_OFF = "Darn!",
	-- ANNOUNCE_UNIMPLEMENTED = "It is not operational yet.",
	-- ANNOUNCE_WORMHOLE = "I must be unhinged to travel so...",
	-- ANNOUNCE_TOWNPORTALTELEPORT = "Blech... I got sand in my mouth.",
	-- ANNOUNCE_TOADESCAPING = "Don't go just yet, toad! I still have more garlic for you!",
	-- ANNOUNCE_TOADESCAPED = "Darn, we'll have a grandiose meal another time then.",
	
	-- ANNOUNCE_DESPAWN = "Oh dear me. Might this be the final course?",
	-- ANNOUNCE_GHOSTDRAIN = "My humanity is becoming unhinged...",
	-- ANNOUNCE_PETRIFED_TREES = "Hm. Was that the sound of stone being built?",
	-- ANNOUNCE_KLAUS_ENRAGE = "Now's a better time than ever to flee!",
	-- ANNOUNCE_KLAUS_UNCHAINED = "What the deuce? I will be hiding in my crock pot if you need me!",
	-- ANNOUNCE_KLAUS_CALLFORHELP = "It has called upon minions for protection!",
	--hallowed nights
    -- ANNOUNCE_SPOOKED = "Oh dear. I must have ate something past its best-by date.",
	-- ANNOUNCE_BRAVERY_POTION = "Does it come in more flavors than tree?",

	--Island Adventures
    ANNOUNCE_SHARX = "I do believe they wish me harm.",
    ANNOUNCE_TREASURE = "I sense possible riches!",
	ANNOUNCE_TREASURE_DISCOVER = "I sense possible riches!",
    ANNOUNCE_MORETREASURE = "And yet more treasure!",
    ANNOUNCE_OTHER_WORLD_TREASURE = "This seems to point to points unknown.",
    ANNOUNCE_OTHER_WORLD_PLANT = "What are you doing so far from home?",

    ANNOUNCE_IA_MESSAGEBOTTLE =
    {
	"The ink is smudged...",
    },
    ANNOUNCE_VOLCANO_ERUPT = "Incoming!",
    ANNOUNCE_MAPWRAP_WARN = "The implications of this are murky.",
    ANNOUNCE_MAPWRAP_LOSECONTROL = "Oh dear me, I have reached the point of no return.",
    ANNOUNCE_MAPWRAP_RETURN = "I have emerged from the edge of the world.",
    ANNOUNCE_CRAB_ESCAPE = "I was going to make you into a beautiful dinner!",
    ANNOUNCE_TRAWL_FULL = "The net is full!",
	ANNOUNCE_BOAT_DAMAGED = "The vessel is damaged...",
	ANNOUNCE_BOAT_SINKING = "Oh no... I can't die on an empty stomach!",
	ANNOUNCE_BOAT_SINKING_IMMINENT = "Into the soup!",
    ANNOUNCE_WAVE_BOOST = "Whoaaaa!",

	ANNOUNCE_WHALE_HUNT_BEAST_NEARBY = "The beast is close.",
	ANNOUNCE_WHALE_HUNT_LOST_TRAIL = "The beast has slipped by me!",
	ANNOUNCE_WHALE_HUNT_LOST_TRAIL_SPRING = "How can I track anything in this deluge!",
	--
--[[
	BATTLECRY =
	{
		GENERIC = "I'm also an accomplished butcher!",
		PIG = "No part of you will go to waste, cochon!",
		PREY = "You look delicious!",
		SPIDER = "I hope it does not rain after I kill you!",
		SPIDER_WARRIOR = "You will die, pest!",
		DEER = "You've forced my hand!",
	},
	COMBAT_QUIT =
	{
		GENERIC = "There's no shame in running!",
		PIG = "Noooo, those hocks, those chops...",
		PREY = "Whew. I'm out of breath.",
		SPIDER = "I hope it didn't take any bites out of me.",
		SPIDER_WARRIOR = "That could have been worse.",
	},
]]
	DESCRIBE =
	{

		SEAWEED_STALK = "I could plant it for a sustainable source of seaweed.", --copied from the Wikia because I couldn't find it in the game files. -M

--[[
	    MULTIPLAYER_PORTAL = "What fresh devilment is this?",
		MULTIPLAYER_PORTAL_MOONROCK = "It does have quite the elegant glow to it.",
        CONSTRUCTION_PLANS = "A recipe of mad construction.",
        MOONROCKIDOL = "It appears to be some kind of offering.",
        MOONROCKSEED = "I would much rather have this be a distance away from me.",
		ANTLION = 
		{
			GENERIC = "It hungers for something.",
			VERYHAPPY = "Satisfied with our goods.",
			UNHAPPY = "The look in its eyes, the look of being angry and hungry.",
		},
		ANTLIONTRINKET = "A beach toy but without a beach.",
		SANDSPIKE = "Nearly kebab-ed!",
        SANDBLOCK = "I can appreciate good design.",
        GLASSSPIKE = "Glad to still be around to see it.",
        GLASSBLOCK = "Very tasteful.",

		ABIGAIL_FLOWER = 
		{ 
			GENERIC = "It's a quite nice vein of flower.",
			LONG = "It's giving off an unsettling aura...",
			MEDIUM = "I don't like it.",
			SOON = "That flower is an apparition!",
			HAUNTED_POCKET = "I best put this away from me!",
			HAUNTED_GROUND = "There's something not quite right with that flower.",
		},

		BALLOONS_EMPTY = "These will need to be inflated to be useful.",
		BALLOON = "It's a fine decoration piece. For a party.",

		BERNIE_INACTIVE =
		{
			BROKEN = "It's been all broken to bits.",
			GENERIC = "It's a bit burnt up but still cuddly to some.",
		},
		BERNIE_ACTIVE = "The teddy bear has started... Moving. Is this a good sign?",
		BERNIE_BIG = "Oh dear me. I nearly thought it was a real grizzly.",
		BOOK_BIRDS = "A book about birds? Without recipes? Not something I'd spend my time on.",
		BOOK_TENTACLES = "A book of cephalopod related recipes perhaps?",
		BOOK_GARDENING = "I prefer my good old book of culinary recipes.",
		BOOK_SLEEP = "It doesn't have any good cooking recipes in it, does it?",
		BOOK_BRIMSTONE = "There's not a single recipe to be found within.",
		
		WAXWELLJOURNAL = "Who in their right mind would ever link their soul within this?",	
		LIGHTER = "Reminds me of sweet gas stoves...",
		LUCY = "A trusty companion of someone's.",
		SPEAR_WATHGRITHR = "For dramatic kebab-ing.",
	    WATHGRITHRHAT = "Dramatic headgear for protecting one's melon.",

        PLAYER =
        {
            GENERIC = "Salutations, %s!",
            ATTACKER = "%s is acting disarrayed.",
            MURDERER = "Murderer! I will not yield, prepare to be filleted!",
            REVIVER = "%s is good to have beside me!",
            GHOST = "We don't want a friend to go to waste do we? I'll cook you up a heart.",
			FIRESTARTER = "%s is having a bit too much fun with flames.",
        },
		WILSON = 
		{
			GENERIC = "Good afternoon, %s!",
			ATTACKER = "%s is not within the right mind.",
			MURDERER = "I will not yield, %s! I'll filet you!",
			REVIVER = "%s is good to have by my side! Cooking is a form of science, no?",
			GHOST = "We don't want a friend to go to waste do we? I'll cook you up a heart.",
			FIRESTARTER = "%s has been playing with fire a bit too loosely.",
		},
		WOLFGANG = 
		{
			GENERIC = "Bonjour, %s!",
			ATTACKER = "I'd best hide from %s. Don't want to be around for that empty stomach!",
			MURDERER = "You must be diced and then sliced, %s!",
			REVIVER = "%s has a heart as big as his appetite!",
			GHOST = "I should like to cook up a strong hearty heart for %s.",
			FIRESTARTER = "%s, be careful with your tools!",
		},
		WAXWELL = 
		{
			GENERIC = "Salutations, %s.",
			ATTACKER = "Back to your old tricks, %s?",
			MURDERER = "No holding back on this one, %s! It's been coming for much too long!",
			REVIVER = "%s has shown they can care for us. It's the little steps!",
			GHOST = "%s is in need of a heart, then again...",
			FIRESTARTER = "You enjoy making yourself out to be the villain, don't you %s?",
		},
		WX78 = 
		{
			GENERIC = "Salutations, %s!",
			ATTACKER = "Stop acting like such a rude contraption, %s.",
			MURDERER = "You're grinding your own gears, %s!",
			REVIVER = "%s can be a good companion... At times.",
			GHOST = "Only now does %s want a heart.",
			FIRESTARTER = "%s, such an effroyable robot.",
		},
		WILLOW = 
		{
			GENERIC = "Good afternoon, %s!",
			ATTACKER = "%s is on the verge of murder. With a hint of flame.",
			MURDERER = "%s, you cannot cook our friends! Away with you!",
			REVIVER = "I'm happy to have %s on my side but a lighter is simply not a stove!",
			GHOST = "I'll have to cook you up a heart, would you like it burnt?",
			FIRESTARTER = "%s burns with an alarming passion.",
		},
		WENDY = 
		{
			GENERIC = "'Allo, %s!",
			ATTACKER = "%s is quite the little troublemaker.",
			MURDERER = "%s is bloodlust! Stand back, I don't want to have to put my foot down!",
			REVIVER = "A good meal always cheers one up, even if for a moment! Right, %s?",
			GHOST = "Before I get you a heart, %s, could you ask if your sister enjoys ghost peppers?",
			FIRESTARTER = "Oh dear. The best fire is a cooking fire, %s!",
		},
		WOODIE = 
		{
			GENERIC = "Bonjour %s!",
			ATTACKER = "%s is stirring up trouble, knock on wood!",
			MURDERER = "%s is now on the chopping block!",
			REVIVER = "Glad to see %s by my side! I'll keep looking for a recipe with logs.",
			GHOST = "I should like to get %s a heart. Are there wooden hearts around?",
			BEAVER = "%s! Are you okay?",
			BEAVERGHOST = "%s is definitely not okay.",
			FIRESTARTER = "What has happened to your love of logs, %s?",
		},
		WICKERBOTTOM = 
		{
			GENERIC = "Salutations, %s!",
			ATTACKER = "%s's morals are becoming disarrayed.",
			MURDERER = "%s must have their books burnt and seared!",
			REVIVER = "%s is good to have by my side! Have you written any cook books yet?",
			GHOST = "I'll fix you up a heart and a nice cup of tea, %s.",
			FIRESTARTER = "I trust you to know what you're doing, %s!",
		},
		WES = 
		{
			GENERIC = "Bonjour, %s!",
			ATTACKER = "%s, would you mind we talk about this?",
			MURDERER = "I shall never cook a gourmet french meal for you once more, %s!",
			REVIVER = "%s always appreciates a good meal.",
			GHOST = "I'll cook you up a fine heart, %s!",
			FIRESTARTER = "I hope you know of the consequences, mon ami!",
		},
		WEBBER = 
		{
			GENERIC = "'Allo, %s!",
			ATTACKER = "%s is stirring up quite the trouble!",
			MURDERER = "I want to believe in accidents, %s, it must be that childish hunger!",
			REVIVER = "%s is always ready to give warm hugs!",
			GHOST = "%s could use a heart and some extra snacks tonight.",
			FIRESTARTER = "Remember, %s, the best fire is a cooking fire!",
		},
		WATHGRITHR = 
		{
			GENERIC = "Salutations, %s!",
			ATTACKER = "I must avoid %s's spear at all costs.",
			MURDERER = "%s shows no sign of stopping... I shall not cook them supper.",
			REVIVER = "%s is great to have by my side! I'd fear otherwise.",
			GHOST = "A valiant warrior should not go to waste, no? I'll cook you up a heart.",
			FIRESTARTER = "%s starts fires quite dramatically.",
		},
		WINONA =
        {
            GENERIC = "Salutations, %s!",
            ATTACKER = "%s's hunger must know of no bounds.",
            MURDERER = "Given the path you've chosen, I will not yield!",
            REVIVER = "%s is great to have beside me, more hands in the kitchen the better!",
            GHOST = "I'm sure %s would care for a finely crafted heart, no?",
			FIRESTARTER = "%s, must you cast sparks near my cooking so?",
        },
		WORTOX =
        {
            GENERIC = "Salutations, %s.",
            ATTACKER = "Stay away, you! I've had enough of your tricks!",
            MURDERER = "You nasty devil! Perhaps I know of a good imp recipe!",
            REVIVER = "I appreciate the help, %s. But must you turn up your nose at my cooking?",
            GHOST = "If I help you, might you try one of my meals at last?",
            FIRESTARTER = "I will surely come up with a recipe for souls if you cease the fire, %s!",
        },
	    WARLY = 
		{
	        GENERIC = "How do you do, fellow %s?",
	        ATTACKER = "Is a cooking competition what you want, %s?",
	        MURDERER = "Murder! Now it must be you on the menu!",
	        REVIVER = "%s's work is under-appreciated!",
	        GHOST = "I'm sure %s would enjoy a well prepared ghost pepper.",
	        FIRESTARTER = "I'd never burn anything in the kitchen.",
		},
]]

		--SWC
		BOAT_SURFBOARD = "I don't have enough faith in my balance to even think of an attempt!",
		SURFBOARD_ITEM = "I don't have enough faith in my balance to even think of an attempt!",

		WALANI = 
		{
		    GENERIC = "Bonjour, %s!",
	        ATTACKER = "%s, think of the many meals I have made you!",
	        MURDERER = "She's done a truly unforgivable thing.",
	        REVIVER = "%s has a truly kind and caring heart.",
	        GHOST = "I'm sure %s would like comfort food and a heart too, non?",
	        FIRESTARTER = "You are not one I expected forest fires from, %s.",
		},

	    WILBUR = 
		{
	        GENERIC = "Salut, %s my good simian fellow!",
	        ATTACKER = "%s is acting more wild than usual. I think no treats tonight.",
	        MURDERER = "%s is a cruel and unruly king.",
	        REVIVER = "%s is good to have beside me, when not digging through my crock pot.",
	        GHOST = "I'll have to cook up a heart and maybe some banana bread for %s.",
	        FIRESTARTER = "%s appears to enjoy burning. Deuced unsettling.",
		},

	    WOODLEGS = 
		{
			GENERIC = "Salut, %s!",
	        ATTACKER = "%s is on the verge of murder. I wouldn't want an enemy of a pirate, non?",
	        MURDERER = "%s has done truly abominable things.",
	        REVIVER = "%s's love for the sea extends to his crew.",
	        GHOST = "I should like to fix %s up a heart. I'll need one that loves the sea.",
	        FIRESTARTER = "%s must've be on a dangerous plundering with too much fire.",
		},
--[[
        MIGRATION_PORTAL = 
        {
            GENERIC = "This could take me to... strange places.",
            OPEN = "I'm getting dizzy near it...",
            FULL = "There happens to be no room for me.",
        },
		ABIGAIL = "Apparition!",
		ACCOMPLISHMENT_SHRINE = "I always wished to make a name for myself.",
		ACORN = "It rattles.",
        ACORN_SAPLING = "A new beginning...",
		ACORN_COOKED = "This could use something... Anything.",
		ADVENTURE_PORTAL = "What fresh devilment is this?",
		AMULET = "I wear safety.",
		ANCIENT_ALTAR = "A structure from antiquity.",
		ANCIENT_ALTAR_BROKEN = "It is broken.",
		ANCIENT_STATUE = "It gives off strange vibrations.",
		ANIMAL_TRACK = "These tracks point to fresh game.",
		ARMORDRAGONFLY = "Heavy and hot.",
		ARMORGRASS = "How much protection can grass really provide?",
		ARMORMARBLE = "Weighs a ton.",
		ARMORRUINS = "Ancient armor.",
		ARMORSKELETON = "A hearty suit out of hearty stock.",
		SKELETONHAT = "No good could possibly come from wearing this on your head.",
		ARMORSLURPER = "Ah. My appetite wanes under its protection.",
		ARMORSNURTLESHELL = "It allows me to turtle.",
		ARMORWOOD = "Sturdy, but quite flammable.",
		ARMOR_SANITY = "Am I crazy to wear this?",
		ASH =
		{
			GENERIC = "I miss ash covered cheeses. I miss cheeses, period.",
			REMAINS_EYE_BONE = "The eyebone was sacrificed in my travels.",
			REMAINS_GLOMMERFLOWER = "The unusual flower is but ash now.",
			REMAINS_THINGIE = "It is no more.",
		},
		AXE = "A trusty companion in these environs.",
		BABYBEEFALO = 
		{
			GENERIC = "You will fatten up nicely.",
		    SLEEPING = "Wouldn't want to wake it, stress makes meat chewy.",
        },
        BUNDLE = "Valuable ingredients are contained in here.",
        BUNDLEWRAP = "A good food wrap.",
		BACKPACK = "It has my back.",
		BACONEGGS = "Runny eggs... crisp bacon... I could die happy now...",
		BANDAGE = "First aid.",
		BASALT = "Made of strong stuff!",
		BAT = "If I only had a bat...",
		BATBAT = "A gruesome implement.",
		BATWING = "Hmmm, maybe a soup stock of batwings?",
		BATWING_COOKED = "Needs garlic...",
		BATCAVE = "That seems like something I should steer clear of.",
		BEARDHAIR = "Disgusting.",
		BEARGER = "Oh, I don't like you one bit!",
		BEARGERVEST = "Furry refuge from the elements.",
		BEARGER_FUR = "Feels warm.",
		BEDROLL_FURRY = "Cozy.",
		BEDROLL_STRAW = "A little better than bare ground. Scratchy.",
		BEEQUEEN = "I think I'll prefer to partake in honey harvesting elsewhere...",
		BEEQUEENHIVE = 
		{
			GENERIC = "I'd prefer it all in a jar, not the ground.",
			GROWING = "The bees have been cooking up a new home.",
		},
        BEEQUEENHIVEGROWN = "My word, it's huge!",
        BEEGUARD = "Your army cannot protect your sweet honey forever!",
		MINISIGN =
        {
            GENERIC = "Too small for a restaurant sign.",
            UNDRAWN = "I could draw the specials on there.",
        },
        MINISIGN_ITEM = "This would be better off in the ground.",
		HIVEHAT = "I don't consider myself a ruler, but it feels great to be appreciated!",
		BEE =
		{
			GENERIC = "Where there are bees, there is honey!",
			HELD = "Hi, honey.",
		},
		BEEBOX =
		{
			BURNT = "Disastrously caramelized.",
			FULLHONEY = "Honey jackpot!",
			GENERIC = "Home of the honeymakers!",
			NOHONEY = "No more honey...",
			SOMEHONEY = "There is a little honey.",
			READY = "Honey jackpot!",
		},
		MUSHROOM_FARM =
		{
			STUFFED = "A bit overstocked, but more the merrier!",
			LOTS = "I can already taste the soups!",
			SOME = "It's picking up quite well! I'm excited, aren't you?",
			EMPTY = "Let's get it started with a mushroom or spore!",
			ROTTEN = "Looks like it's gone sour, I better clean it up.",
			BURNT = "Charred.",
			SNOWCOVERED = "No mushroom could possibly thrive in this cold.",
		},
		BEEFALO =
		{
			FOLLOWER = "That's it, my friend. I lead, you follow.",
			GENERIC = "Here's the beef.",
			NAKED = "Chin up, it'll grow back.",
			SLEEPING = "The sirloin slumbers...",
			--Domesticated states:
            DOMESTICATED = "This one's quite calm.",
            ORNERY = "It's boiling up!",
            RIDER = "I think I could actually handle this one.",
            PUDGY = "I've spoiled this one with my delicious meals.",
		},
		BEEFALOHAT = "Fits perfectly.",
		BEEFALOWOOL = "The beast's loss is my gain.",
		BEEHAT = "Essential honey harvesting attire.",
		BEESWAX = "A classic protective shield for cheeses and preserved foods!",
		BEEHIVE = "I can hear the activity within.",
		BEEMINE = "Weaponized bees.",
		BEEMINE_MAXWELL = "I pity whoever trips this.",
		BELL = "Should I ring it?",
		BELL_BLUEPRINT = "Fascinating.",
		BERRIES = "Fresh fruit!",
		BERRIES_COOKED = "Could use a pinch of sugar...",
		BERRIES_JUICY = "They spoil at an alarming rate.",
        BERRIES_JUICY_COOKED = "Could use a pinch of sugar.",
		BERRYBUSH =
		{
			BARREN = "They require care and fertilizer.",
			GENERIC = "Berries!",
			PICKED = "More will return.",
			WITHERED = "The heat has stifled these berries.",
			DISEASED = "Why must the plants get sick!",
		    DISEASING = "This plant appears to be curdling.",
			BURNING = "Bushes burn all the same.",
		},
	    BERRYBUSH_JUICY =
		{
			BARREN = "They require care and fertilizer.",
			WITHERED = "The heat spoiled the berries before they did so themselves.",
			GENERIC = "Ripe berries!",
			PICKED = "Maybe I could have preserved them.",
			DISEASED = "Another deathly bush?",
		    DISEASING = "This plant appears to be curdling.",
			BURNING = "Bushes burn all the same.",
		},
		BIGFOOT = "Please do not squish me!",
		BIRCHNUTDRAKE = "What madness is this?",
		BIRDCAGE =
		{
			GENERIC = "Suitable lodgings for a feathered beast.",
			OCCUPIED = "I now have an egg farm!",
			SLEEPING = "Sleep now, lay later.",
			HUNGRY = "Let me cook something nice up for you.",
			STARVING = "Oh, what do birds eat? A nice brisket?",
			DEAD = "Maybe it will wake up.",
			SKELETON = "It is not waking up. Oh dear.",
		},
		BIRDTRAP = "Oh, roast bird! Hm, don't get ahead of yourself, Warly...",
		BIRD_EGG = "Nature's perfect food.",
		BIRD_EGG_COOKED = "Could use a few different herbs...",
		BISHOP = "You don't strike me as particularly spiritual.",
		BISHOP_NIGHTMARE = "You are grinding my gears, dear fellow.",
		BLOWDART_FIRE = "Breathing fire!",
		BLOWDART_FLUP = "How considerate of that dead thing!",
		BLOWDART_PIPE = "They won't know what hit them.",
		BLOWDART_SLEEP = "A sleep aid!",
		BLOWDART_YELLOW = "It's as electrifying as it is a quick cooker.",
		BLUEAMULET = "Brrrrrr!",
		BLUEGEM = "Such a cool blue.",
		BLUEPRINT = 
		{ 
            COMMON = "A recipe for technology!",
            RARE = "You don't see recipes like this just anywhere!",
        },
		SKETCH = "Share your recipes with another mind.",
		BLUE_CAP = "What deliciousness shall you yield?",
		BLUE_CAP_COOKED = "Could use a dash of smoked salt and balsamic vinegar...",
		BLUE_MUSHROOM =
		{
			GENERIC = "Ah, a blue truffle!",
			INGROUND = "It retreats from the light.",
			PICKED = "I hope the truffles are restocked soon.",
		},
		BOARDS = "Sigh. It would be so perfect for grilling salmon.",
		BONESHARD = "I could make a hearty stock with these.",
		BONESTEW = "Warms my soul!",
		BOOMERANG = "Oh good. I have separation anxiety.",
		BUGNET = "For catching alternative protein.",
		BUNNYMAN = "I have so many good rabbit recipes...",
		BUSHHAT = "Snacks to go?",
		BUTTER = "I thought I would never see you again, old friend!",
		BUTTERFLY =
		{
			GENERIC = "Your aerial dance is so soothing to behold...",
			HELD = "Don't slip from my butterfingers.",
		},
		BUTTERFLYMUFFIN = "Delectable!",
		BUTTERFLYWINGS = "I wonder what dishes I could create with these?",
		BUZZARD = "If only you were more turkey than vulture...",
		SHADOWDIGGER = "I don't like you... Not one bit.",
		
		CACTUS =
		{
			GENERIC = "I bet it has a sharp flavor.",
			PICKED = "It will live to prick again.",
		},
		CACTUS_FLOWER = "Such a pretty flower from such a prickly customer!",
		CACTUS_MEAT = "I hope it does not prickle going down.",
		CACTUS_MEAT_COOKED = "Could use some tortillas and melted queso...",
		CAMPFIRE =
		{
			EMBERS = "I should stoke the fire.",
			GENERIC = "To keep the dark at bay.",
			HIGH = "Rivals a grease fire!",
			LOW = "It is getting low.",
			NORMAL = "I should like to sit by you for a moment.",
			OUT = "I will have to light you again.",
		},
		CANE = "Now we are cooking with gas!",
		CARROT = "Fresh picked produce!",
		CARROT_COOKED = "Could use a dash of olive oil and cilantro...",
		CARROT_PLANTED = "Ah, a fresh carrot!",
		CARROT_SEEDS = "Future carrots!",
		CARTOGRAPHYDESK = 
		{	
			GENERIC = "A beautiful map on a beautiful finished desk! Humanity!",
			BURNING = "Why must this place be so cruel?",
			BURNT = "Ah, such a shame. Au revoir.",
		},
		CATCOON = "What perky little ears.",
		CATCOONDEN =
		{
			EMPTY = "Vacant of critters.",
			GENERIC = "How many critters can fit in there?",
		},
		CATCOONHAT = "Not quite my style.",
		CAVE_BANANA = "Just the flavor I needed!",
		CAVE_BANANA_COOKED = "Could use some oats and a few chocolate chips...",
		CAVE_BANANA_TREE = "There must be monkeys close by.",	
        CAVE_ENTRANCE = "I wonder what's underneath that?",
        CAVE_ENTRANCE_RUINS = "I don't care to find out what lies beneath.",
       
       	CAVE_ENTRANCE_OPEN = 
        {
            GENERIC = "Darn.",
            OPEN = "Dare I?",
            FULL = "I wasn't too excited to hop down there any how.",
        },
        CAVE_EXIT = 
        {
            GENERIC = "I should like to see the surface again.",
            OPEN = "Thank goodness.",
            FULL = "What the devil? Let me up!",
        },
		
		CAVE_FERN = "How does anything grow down here?",
		CHARCOAL = "This, a grill and some meat and I'd have dinner.",
		CHESSPIECE_PAWN = 
        {
		GENERIC = "Pawns can do a lot if given the chance.",
		},
        CHESSPIECE_ROOK = 
        {
			GENERIC = "Simply decorative.",
			STRUGGLE = "Something's cooking up!",
		},
        CHESSPIECE_KNIGHT = 
        {
			GENERIC = "A trusty stone steed.",
			STRUGGLE = "Something's cooking up!",
		},
        CHESSPIECE_BISHOP = 
        {
			GENERIC = "Simply decorative.",
			STRUGGLE = "Something's cooking up!",
		},
		CHESSPIECE_MUSE = "It's a very intimidating piece.",
        CHESSPIECE_FORMAL = "Not much of a king without a heavy head.",
        CHESSPIECE_HORNUCOPIA = "A masterpiece! Despite its in-edibleness I enjoy its presence.",
        CHESSPIECE_PIPE = "Never thought I'd see such a peculiar piece out here.",
        CHESSPIECE_DEERCLOPS = "I'm not too comfortable cooking around that.",
        CHESSPIECE_BEARGER = "Not my favorite memoir piece.",
        CHESSPIECE_MOOSEGOOSE = "The beast's stone-meats are a mockery.",
        CHESSPIECE_DRAGONFLY = "Could we get a sculpture of a less bad memory?",
		CHESSJUNK1 = "Broken chess pieces?",
		CHESSJUNK2 = "More broken chess pieces?",
		CHESSJUNK3 = "And yet more broken chess pieces?",
		CHESTER = "You look cute and inedible.",
		CHESTER_EYEBONE =
		{
			GENERIC = "The eye follows me wherever I go...",
			WAITING = "It sleeps.",
		},
		COLDFIRE =
		{
			EMBERS = "I should stoke the fire.",
			GENERIC = "Fire that cools?",
			HIGH = "The flames climb higher!",
			LOW = "It's getting low.",
			NORMAL = "I should like to sit by you for a moment.",
			OUT = "I will have to light you again.",
		},
		COLDFIREPIT =
		{
			EMBERS = "I should stoke the fire.",
			GENERIC = "Fire that cools?",
			HIGH = "The flames climb higher!",
			LOW = "It's getting low.",
			NORMAL = "I should like to sit by you for a moment.",
			OUT = "I will have to light you again.",
		},
		COMPASS =
		{
			E = "East.",
			GENERIC = "Hmm, no reading.",
			N = "North.",
			NE = "Northeast.",
			NW = "Northwest.",
			S = "South.",
			SE = "Southeast.",
			SW = "Southwest.",
			W = "West.",
		},
		COOKEDMANDRAKE = "Could use horseradish...",
		COOKEDMEAT = "Could use a chimichurri sauce...",
		COOKEDMONSTERMEAT = "Could use... uh... I don't even...",
		COOKEDSMALLMEAT = "Could use sea salt...",
		COOKPOT = 
		{
			BURNT = "Tragique.",
			COOKING_LONG = "A masterpiece takes time.",
			COOKING_SHORT = "Nearly there...",
			DONE = "Ahh, fini!",
			EMPTY = "Empty pot, empty heart.",
		},
		COONTAIL = "Chat noodle.",
		CORN = "Corn! Sweet, sweet corn!",
		CORN_COOKED = "Could use miso and lardons...",
		CORN_SEEDS = "The promise of so many more corn dishes!",
		CANARY =
		{
			GENERIC = "I won't be cooking you up any time soon.",
			HELD = "You're a very lovely bird.",
		},
		CANARY_POISONED = "I'll keep a distance.",
		CRITTERLAB = "There's creatures in that den, scurrying about.",
        CRITTER_GLOMLING = "Unbelievably adorable, and such grace!",
        CRITTER_DRAGONLING = "I could use your help cooking, my friend!",
		CRITTER_LAMB = "You're so adorable I could gobble you right up! I won't, of course.",
        CRITTER_PUPPY = "I don't suppose you'll be wanting my scraps?",
        CRITTER_KITTEN = "A very cute companion, brings a smile to one's face!",
		CRITTER_PERDLING = "I won't be gobbling you up, but you surely will be gobbling it up.",
		
		CROW =
		{
			GENERIC = "Raven stew perhaps?",
			HELD = "Hush, my pet.",
		},
		CUTGRASS = "What shall I craft?",
		CUTLICHEN = "Hmm, odd.",
		CUTREEDS = "Smells like greenery.",
		CUTSTONE = "Compressed stones, nice presentation.",
		DEADLYFEAST = "I would not recommend this.",
		DECIDUOUSTREE =
		{
			BURNING = "Au revoir, tree.",
			BURNT = "Crisp, no?",
			CHOPPED = "Sliced!",
			GENERIC = "A bouquet of leaves.",
			POISON = "No thank you!",
		},
		DEER = 
		{
			GENERIC = "It's been a long while since I last had deer...",
			ANTLER = "What a stunning specimen.",
		},
		DEER_ANTLER = "Well, I hope it doesn't miss it.",
        DEER_GEMMED = "Goodness, it's being controlled like some sort of puppet!",
		DEERCLOPS = "I once had a saucier who looked like that.",
		DEERCLOPS_EYEBALL = "Giant eyeball... soup?",
		DEPLETED_GRASS =
		{
			GENERIC = "Well past its expiry date.",
		},
		GOGGLESHAT = "Tres cool.",
        DESERTHAT = "Anything to keep sand out of my dinner!",
		DEVTOOL = "Efficient, oui?",
		DEVTOOL_NODEV = "No, I am a traditionalist.",
		DIRTPILE = "It's making a bit of a mess, isn't it?",
		DIVININGROD =
		{
			COLD = "Hmm, keep looking.",
			GENERIC = "A finely tuned radar stick.",
			HOT = "I can almost smell it!",
			WARM = "I've caught onto something!",
			WARMER = "Warmer, warmer...!",
		},
		DIVININGRODBASE =
		{
			GENERIC = "Is it a chopping block?",
			READY = "How do I turn it on?",
			UNLOCKED = "Preparation complete!",
		},
		DIVININGRODSTART = "That looks important.",
		DRAGONFLY = "I'm not cut out for this.",
		DRAGONFLYCHEST = "Ooh la la, burnproof storage.",
		DRAGONFLYFURNACE = 
		{
			HAMMERED = "Uh, something has been put out of order here...",
			GENERIC = "A spicy furnace, I'll gladly enjoy its presence!", --no gems
			NORMAL = "It's just getting started!", --one gem
			HIGH = "Scalding hot!", --two gems
		},
		DRAGONFRUIT = "So exotic!",
		DRAGONFRUIT_COOKED = "Could use a spread of pudding and chia seeds...",
		DRAGONFRUIT_SEEDS = "They hatch dragonfruits.",
		DRAGONPIE = "Flaky crust, tart filling... heavenly!",
		DRAGON_SCALES = "Hot to the touch!",
		DRUMSTICK = "Dark meat!",
		DRUMSTICK_COOKED = "Could use a light honey garlic glaze...",
		DUG_BERRYBUSH = "Shall I bring it back to life?",
		DUG_BERRYBUSH_JUICY = "Shall I bring it back to life?",
		DUG_GRASS = "Shall I bring it back to life?",
		DUG_MARSH_BUSH = "Shall I bring it back to life?",
		DUG_SAPLING = "Shall I bring it back to life?",
		DURIAN = "That odor...",
		DURIAN_COOKED = "Could use onions and chili...",
		DURIAN_SEEDS = "Even these smell...",
		EARMUFFSHAT = "Ahh, fuzzy!",
		EEL = "Anguille.",
		EEL_COOKED = "Could use some cajun spices...",
		EGGPLANT = "Aubergine!",
		EGGPLANT_COOKED = "Could use tomato sauce and Parmesan...",
		EGGPLANT_SEEDS = "Hatches more eggplants!",
		
		ENDTABLE = 
		{
			BURNT = "I assume someone got a little too paranoid of that thing.",
			GENERIC = "It looks much nicer now that it no longer has suspicious intentions.",
			EMPTY = "It awaits embellishments.",
			WILTED = "It has seen better days.",
			FRESHLIGHT = "Perfect dinner light.",
			OLDLIGHT = "I'd prefer it not to fade, we must refuel it!",
		},
		EVERGREEN =
		{
			BURNING = "Au revoir, tree.",
			BURNT = "Crisp, no?",
			CHOPPED = "Sliced!",
			GENERIC = "A soldier of the exotic forest.",
		},
		EVERGREEN_SPARSE =
		{
			BURNING = "Au revoir, tree.",
			BURNT = "Crisp, no?",
			CHOPPED = "Sliced!",
			GENERIC = "A coneless arbre.",
		},
		EYEBRELLAHAT = "\"Eye\" like it!",
		TWIGGYTREE = 
		{
			BURNING = "Au revoir, stick-tree.",
			BURNT = "Crisp, no?",
			CHOPPED = "Sliced!",
			GENERIC = "A soldier of continued survival.",			
			DISEASED = "It must be raw.",
		},
		TWIGGY_NUT_SAPLING = "It's growing up well!",
        TWIGGY_OLD = "That tree is undercooked.",
		TWIGGY_NUT = "It'll be a thin tree someday.",
		EYEPLANT = "Alluring, no?",
		INSPECTSELF = "I ought to cook up something make me look younger.",
		EYETURRET = "This is my friend, Lazer Oeil!",
		EYETURRET_ITEM = "Wake up!",
		FARMPLOT =
		{
			BURNT = "Stayed in the oven a tad too long.",
			GENERIC = "I can grow my own ingredients!",
			GROWING = "Ah, couldn't be more fresh!",
			NEEDSFERTILIZER = "Needs to be fertilized.",
		},
		FEATHERFAN = "Why is it so big?",
		MINIFAN = "Like a cool ocean breeze.",
		FEATHERHAT = "What am I supposed to do with this?",
		FEATHER_CROW = "A bird's feather, in truffle black.",
		FEATHER_ROBIN = "A bird's feather, in cherry red.",
		FEATHER_ROBIN_WINTER = "A bird's feather, in tuna blue.",
		FEATHER_CANARY = "A bird's feather, in cheddar yellow.",
	    FEATHERPENCIL = "A proper writing tool! I may be able to start writing down recipes again!",
		FEM_PUPPET = "She's trapped!",
		FERTILIZER = "Sauce for my garden!",
		FIREFLIES =
		{
			GENERIC = "A dash of glow.",
			HELD = "My petit lightbulb pets.",
		},
		FIREHOUND = "Chien, on fire!",
		FIREPIT =
		{
			EMBERS = "That fire's almost out!",
			GENERIC = "To warm my fingers and roast sausages.",
			HIGH = "Maximum heat!",
			LOW = "It's getting low.",
			NORMAL = "Parfait.",
			OUT = "I like when it's warm and toasty.",
		},
		FIRESTAFF = "Oven on a stick!",
		FIRESUPPRESSOR =
		{
			LOWFUEL = "Shall I fuel it up?",
			OFF = "He's sleeping.",
			ON = "Make it snow!",
		},
		FISH = "Poisson!",
		FISHINGROD = "I believe I prefer the fish market.",
		FISHSTICKS = "Crunchy and golden outside, flaky and moist inside!",
		FISHTACOS = "Takes me south of the border!",
		FISH_COOKED = "Could use a squeeze of lemon...",
		FISH_RAW = "Doesn't even smell fishy it's so fresh!",
		FLINT = "Sharp as can be!",
		FLOWER = 
		{
            GENERIC = "Charmant.",
            ROSE = "That could help fancy up a dinner.",
        },
		FLOWER_WITHERED = "That flower's been burnt to crisp.",
		FLOWERHAT = "Who doesn't look good in this?!",
		FLOWERSALAD = "Edible art!",
		FLOWER_CAVE = "Ah, a light in the dark.",
		FLOWER_CAVE_DOUBLE = "Ah, a light in the dark.",
		FLOWER_CAVE_TRIPLE = "Ah, a light in the dark.",
		FLOWER_EVIL = "A terrible omen if I ever saw one.",
		FOLIAGE = "Feuillage.",
		FOOTBALLHAT = "Made from pork, to protect my melon.",
	    FOSSIL_PIECE = "Seems a bit too ancient to use for stock.",
        FOSSIL_STALKER =
        {
			GENERIC = "Some more ingredients are yet to be put into place.",
			FUNNY = "That's a mixed flavor meal.",
			COMPLETE = "Can we truly rebuild what was once lost?",
        },
		STALKER = "I can feel my feet shaking in my boots!",
		STALKER_ATRIUM = "I can't take the heat! Get me out of this kitchen!",
        STALKER_MINION = "That should not exist!",
		THURIBLE = "It's heated like a crock pot.",
        ATRIUM_OVERGROWTH = "I couldn't possibly decipher that.",
		FROG =
		{
			DEAD = "I'll eat your legs for dinner!",
			GENERIC = "Frog. A delicacy.",
			SLEEPING = "Bonne nuit, little snack.",
		},
		FROGGLEBUNWICH = "Ah, French cuisine!",
		FROGLEGS = "I am hopping with excitement!",
		FROGLEGS_COOKED = "Could use garlic and clarified butter...",
		FRUITMEDLEY = "Invigorating!",
		FURTUFT = "It's some frayed away fur.", 
		GEARS = "The insides of those naughty machines.",
		GEMSOCKET =
		{
			GEMS = "Gem it!",
			VALID = "Voilà!",
		},
		GHOST = "Could I offer you a ghost pepper?",
		GLOMMER = "I think I like it.",
		GLOMMERFLOWER =
		{
			DEAD = "What a waste.",
			GENERIC = "Tres beau!",
		},
		GLOMMERFUEL = "Looks like bubblegum, tastes like floor.",
		GLOMMERWINGS = "A tiny delicacy.",
		GOATMILK = "Can I make this into cheese?",
		GOLDENAXE = "A golden chopper!",
		GOLDENMACHETE = "Fancy slicer.",
		GOLDENPICKAXE = "That looks nice.",
		GOLDENPITCHFORK = "A golden fork for a giant, oui?",
		GOLDENSHOVEL = "Shiny.",
		GOLDNUGGET = "Yolk yellow, glowing gold!",
		GOOSE_FEATHER = "A plucked goose was here.",
		GRASS =
		{
			BARREN = "Could I get some fertilizer over here?",
			BURNING = "I never burn anything in the kitchen.",
			GENERIC = "A common ingredient for success around here.",
			PICKED = "Plucked clean!",
			WITHERED = "Too hot for you.",
		    DISEASED = "I must keep that plant away from my food!",
			DISEASING = "That plant appears to be spoiling.",
		},
		GRASSGEKKO = 
		{
			GENERIC = "I could cook up such unique things with you.",	
			DISEASED = "It would make me sick to use them in a meal.",
		},
		GRASS_UMBRELLA = "A bit of shade is better than none.",
		GREENAMULET = "For more savvy construction!",
		GREENGEM = "Ahh, a rare attraction!",
		GREENSTAFF = "I probably shouldn't stir soup with this.",
		GREEN_CAP = "Don't crowd the mushrooms.",
		GREEN_CAP_COOKED = "Could use a slathering of butter and chives...",
		GREEN_MUSHROOM =
		{
			GENERIC = "Little champignon!",
			INGROUND = "Did it eat itself...?",
			PICKED = "I eagerly await its rebirth!",
		},
		GUACAMOLE = "More like Greatamole!",
		GUANO = "Poop of the bat.",
		GUNPOWDER = "Boom!",
		HAMBAT = "Mmm, ham popsicle!",
		HAMMER = "For tenderizing boeuf!",
		HAWAIIANSHIRT = "When in Rome...",
		HEALINGSALVE = "Soothing.",
		HEATROCK =
		{
			COLD = "Still cold.",
			FROZEN = "Vanilla ice.",
			GENERIC = "A temperature stone.",
			HOT = "Hot!",
			WARM = "It's warming up nicely.",
		},
		HOME = "Who lives here?",
		HOMESIGN =
		{
			BURNT = "Overcooked.",
		    UNWRITTEN = "There nothing on it to be read.",
			GENERIC = "What's the use in a sign around here?",
		},
		ARROWSIGN_POST =
		{
			GENERIC = "It marks \"Thataway\".",
            UNWRITTEN = "Directional potential.",
			BURNT = "Crisp, no?",
		},
		ARROWSIGN_PANEL =
		{
			GENERIC = "It marks \"Thataway\".",
            UNWRITTEN = "Directional potential.",
			BURNT = "Crisp, no?",
		},
		HONEY = "Nectar of the gods!",
		HONEYCOMB = "Just add milk!",
		HONEYHAM = "Comfort food!",
		HONEYNUGGETS = "Junk food is my guilty pleasure. Shh!",
		HORN = "There's still some hairs inside.",
		HOTCHILI = "Spice up my life!",
		HOUND = "Angry chien!",
		HOUNDBONE = "Hmm, soup stock...",
		HOUNDFIRE = "Fire in the kitchen!",
		HOUNDMOUND = "It smells wet.",
		HOUNDSTOOTH = "Better to lose a tooth than your tongue!",
		ICE = "That's ice.",
		ICEBOX = "The ice box, my second-most loyal culinary companion.",
		ICECREAM = "The heat is sweetly beat!",
		ICEHAT = "Must I wear it?",
		ICEHOUND = "Away, frozen diable!",
		ICEPACK = "Now this I can use!",
		ICESTAFF = "It flash freezes poulet!",
		INSANITYROCK =
		{
			ACTIVE = "And I'm in!",
			INACTIVE = "Do not lick it. Your tongue will get stuck.",
		},
		JAMMYPRESERVES = "Simple, sweet, parfait.",
		KABOBS = "Opa!",
		KILLERBEE =
		{
			GENERIC = "Almost not worth the honey!",
			HELD = "So sassy!",
		},
		KNIGHT = "A tricky cheval!",
		KNIGHT_NIGHTMARE = "Effroyable!",
		KOALEFANT_SUMMER = "Ah, you have fattened up nicely!",
		KOALEFANT_WINTER = "You can't get attached to cute cuts of meat.",
		KRAMPUS = "What the devil!",
		KRAMPUS_SACK = "Infinite pocket space!",
		LANTERN = "It is my night light.",
		--LAVAPOOL = "Spicy!",	
		HUTCH = "You look mildly cute and inedible.",
        HUTCH_FISHBOWL =
        {
            GENERIC = "That's something to tell the folks.",
            WAITING = "Is it alive?",
        },
		LAVASPIT =
		{
			COOL = "The top has cooled like a barfy creme brulee!",
			HOT = "A chef-cuisinier never burns his fingers.",
		},
		LAVA_POND = "Spicy!",
		LAVAE_COCOON = "It appears to have cooled down.",
		LAVAE = "Too hot for eating.",
		LAVAE_PET = 
		{
			STARVING = "It's getting fiery.",
			HUNGRY = "I should like to share my food with it.",
			CONTENT = "A happy customer.",
			GENERIC = "Since it is not edible it shall make a good pet.",
		},
		LAVAE_EGG = 
		{
			GENERIC = "I can only imagine what my sous chef would think of it.",
		},
		LAVAE_EGG_CRACKED =
		{
			COLD = "The egg need proper insulation.",
			COMFY = "The eggs seems... pleased.",
		},
		LAVAE_TOOTH = "Tooth of an...egg.",

		LEIF = "I'm out of my element!",
		LEIF_SPARSE = "I'm out of my element!",
		LICHEN = "Really scraping the barrel for produce here.",
		LIGHTBULB = "Looks like candy.",
		LIGHTNINGGOAT =
		{
			CHARGED = "Goat milkshake!",
			GENERIC = "I had a goat once.",
		},
		LIGHTNINGGOATHORN = "For kabobs, perhaps?",
		LIGHTNING_ROD =
		{
			CHARGED = "Electricity!",
			GENERIC = "I do feel a bit safer now.",
		},
		LITTLE_WALRUS = "Oh, there's a little one!",
		LIVINGLOG = "Magic building blocks!",
		LIVINGTREE = "Tres suspicious...",
		LOCKEDWES = "I'll get you out, mon ami!",
		
		LOG =
		{
			BURNING = "Soon it won't be good for much.",
			GENERIC = "An important aspect of my art.",
		},
		LUREPLANT = "How alluring.",
		LUREPLANTBULB = "Growing meat from the ground? Now I've seen it all...",
		MANDRAKE =
		{
			DEAD = "I should like to get to the root of this mystery...",
			GENERIC = "Have I discovered a new root vegetable?!",
			PICKED = "Do not pick! Do not pick!",
		},
		MANDRAKESOUP = "What an otherworldly flavor!",
		MANDRAKE_COOKED = "Could use... an explanation...",
		MAPSCROLL = "No recipe in sight.",
		MARBLE = "Would make a nice counter top.",
		MARBLEBEAN = "I'll handle it with care.",
		MARBLEBEAN_SAPLING = "Simply unnatural.",
        MARBLESHRUB = "I don't quite understand it, but I'll let it pass.",
		MARBLEPILLAR = "I wonder how many counter tops I could get out of this...",
		MARSH_BUSH =
		{
			BURNING = "It burns like any other bush.",
			GENERIC = "A prickly customer.",
			PICKED = "Not sure I want to do that again.",
		},
		MARSH_PLANT = "I wonder if it is edible.",
		MARSH_PLANT_TROPICAL = "I wonder if it is edible.",
		MARSH_TREE =
		{
			BURNING = "You will not be missed.",
			BURNT = "The wood gives off a unique aroma when burned.",
			CHOPPED = "There. Now you cannot prick anyone.",
			GENERIC = "I am ever so glad I'm not a tree hugger.",
		},
		MAXWELL = "You! You... villain!",
	    MAXWELLHEAD = "He must eat massive sandwiches.",
		MAXWELLLIGHT = "A light is always welcome.",
		MAXWELLLOCK = "But where is the key?",
		MAXWELLPHONOGRAPH = "I wonder what is in his record collection?",
		MAXWELLTHRONE = "Heavy is the bum that sits on the throne...",
		MEAT = "I must remember to cut across the grain.",
		MEATBALLS = "I'm having a ball!",
		MEATRACK =
		{
			BURNT = "Too dry! Too dry!",
			DONE = "Ready to test on my teeth!",
			DRYING = "Not quite dry enough.",
			DRYINGINRAIN = "Now it is more like a rehydrating rack...",
			GENERIC = "Just like the chefs of the stone age!",
		},
		MEAT_DRIED = "Could use chipotle...",
		MERM = "Fishmongers!",
		MERMFISHER = "You bring the sea with you.",
		MERMHEAD =
		{
			BURNT = "I think it needs to burned again! Pee-eew!",
			GENERIC = "Its odor is not improving with time...",
		},
		MERMHOUSE =
		{
			BURNT = "That fire got the smell out.",
			GENERIC = "Fisherfolk live here. I can smell it.",
		},
		MINERHAT = "Aha! Now that is using my head!",
		MINOTAUR = "Stay away!",
		MINOTAURCHEST = "I appreciate the attention to its aesthetic detail.",
		MINOTAURHORN = "I wonder, if ground up into a powder...",
		MOLE =
		 {
		 	ABOVEGROUND = "Are you spying on me?",
		 	HELD = "Do you \"dig\" your new surroundings?",
		 	UNDERGROUND = "Something dwells beneath.",
		 },
		MOLEHAT = "Neat vision!",
		MOLEHILL = "It is a nice hill, but I won't make a mountain of it.",
		MONKEY = "A new species of irritation.",
		MONKEYBARREL = "An absolute madhouse.",
		MONSTERLASAGNA = "What a wasted effort...",
		MONSTERMEAT = "Hmmm, nice marbling...",
		MONSTERMEAT_DRIED = "Could use... better judgment...",
		MOOSE = "I wish you were a bit less moose-y and a lot more goose-y!",
		MOOSEEGG = "I think I'll leave this egg quite alone!",
		MOSQUITO =
		{
			GENERIC = "We disagree on where my blood is best used.",
			HELD = "I do not care to be this close to it! Vile!",
		},
		MOSQUITOSACK = "Ugh! It can only be filled with one thing.",
		MOSQUITOSACK_YELLOW = "Ugh! It can only be filled with one thing.",
		MOSQUITO_POISON = "You not only take, but you also give? Well, no thanks!",
	    MOSSLING = "Looking for your momma? Apologies, but I hope you do not find her.",
		MOUND =
		{
			DUG = "What have I become?",
			GENERIC = "I cannot help wondering what might be down there.",
		},
		MULTITOOL_AXE_PICKAXE = "Oh, I get it! Kind of like a spork!",
        MUSHROOMHAT = "Edible fashion!",
        MUSHROOM_LIGHT2 =
        {
            ON = "This food-light should keep us company!",
            OFF = "It could use a dash of freshly ground pepper... Is it still technically food?",
            BURNT = "Somebody overcooked it.",
        },
        MUSHROOM_LIGHT =
        {
            ON = "It's a very calming light, with an accompanying mushroom scent.",
            OFF = "Food can do wonders!",
            BURNT = "Crisp mushroom, I would have done better.",
        },
		SLEEPBOMB = "Don't inhale the spores!",
        MUSHROOMBOMB = "It's not my area of expertise, better keep a distance.",
        SHROOM_SKIN = "I'll have to think up a special recipe for this.",
        TOADSTOOL_CAP =
        {
            EMPTY = "An empty hole within the earth.",
            INGROUND = "I spot something moving about.",
            GENERIC = "I hoping that it doesn't contain any toxins.",
        },
        TOADSTOOL =
        {
            GENERIC = "Your meats must definitely be hazardous.",
            RAGE = "I wasn't intending to do so, but he seems to be cooking himself.",
        },
        MUSHROOMSPROUT =
        {
            GENERIC = "I'll not be cooking that!",
            BURNT = "Looks as if someone tried to cook it, but I wouldn't recommend using it in a stock.",
        },
        MUSHTREE_TALL =
        {
            GENERIC = "Oh, divine tree of mushrooms... what else can you teach me?",
            BLOOM = "I'll need some strong spices to cover the stench.",
        },
        MUSHTREE_MEDIUM =
        {
            GENERIC = "I have seen the light. Mushrooms do indeed grow on trees.",
            BLOOM = "I'll have to wait until it's well enough to use for soup.",
        },
        MUSHTREE_SMALL =
        {
            GENERIC = "Surely mushrooms do not grow on trees here?",
            BLOOM = "Best not to cook with it at the moment.",
        },
        MUSHTREE_TALL_WEBBED = "That's a sign of danger if I've ever seen one.",
        SPORE_TALL = "Such a calming seed.",
        SPORE_MEDIUM = "What a beautiful shade of red!",
        SPORE_SMALL = "Not for cooking of any sort.",
        SPORE_TALL_INV = "Don't fret, I shall not be using you for soup stock.",
        SPORE_MEDIUM_INV = "Don't fret, I shall not be using you for soup stock.",
        SPORE_SMALL_INV = "Don't fret, I shall not be using you for soup stock.",
		NEEDLESPEAR = "Who shall I stick it to?",
		NIGHTLIGHT = "And I thought fluorescent tubes were a bad invention!",
		NIGHTMAREFUEL = "Who in their right mind would want to fuel MORE nightmares?",
		NIGHTMARELIGHT = "Am I crazy or is this light not helping my situation?",
		NIGHTMARE_TIMEPIECE =
		 {
		 	CALM = "It appears that all is well.",
		 	DAWN = "This nightmare is almost over!",
		 	NOMAGIC = "Magicless.",
		 	STEADY = "Steady on.",
		 	WANING = "Subsiding.",
		 	WARN = "I feel some magic coming on!",
		 	WAXING = "Magic hour!",
		 },
		NIGHTSTICK = "I feel electric!",
		NIGHTSWORD = "This thing slices like a dream!",
		NITRE = "How curious.",
		OBSIDIAN = "Hot rock!",
		ONEMANBAND = "What a racket!",
		OASISLAKE = 
		{
			GENERIC = "It traps trinkets.",
			EMPTY = "Quite the sand pit... Strangely familiar.",
		},
		ORANGEAMULET = "Here one minute, gone the next!",
		ORANGEGEM = "I miss oranges...",
		ORANGESTAFF = "When I hold it it makes the world feel... fast.",
		OPALSTAFF = "Holding it would sure make one feel important.",
        OPALPRECIOUSGEM = "Such an elegant gem.",
		PANDORASCHEST = "It's quite magnificent.",
		PANFLUTE = "This will be music to something's ears.",
		PAPYRUS = "I could write down my recipes on this.",
		WAXPAPER = "Wax paper! Always useful in the kitchen.",
		PARROT = "I can't recall any parrot recipes...",
		PEACOCK = "Pea-ka-boo!",
		PENGUIN = "A cool customer.",
		PEROGIES = "Mmmmm, pockets of palate punching pleasure!",
		PETALS = "Great in salads.",
		PETALS_EVIL = "Not so great in salads.",
		PICKAXE = "For those tough to crack nuts.",
		PIGGUARD = "What are you guarding, besides your own deliciousness?",
		PIGGYBACK = "Cochon bag!",
		PIGHEAD =
		{
			BURNT = "Not even the cheeks are left...",
			GENERIC = "Ooh la la, the things I could do with you!",
		},
		PIGHOUSE =
		{
			BURNT = "Mmmm, barbecue!",
			FULL = "Looks like more than three little piggies in there.",
			GENERIC = "Can I blow this down?",
			LIGHTSOUT = "Yoo hoo! Anybody home?",
		},
		PIGKING = "Well, you've got the chops for it.",
		PIGMAN =
		{
			DEAD = "He wouldn't want himself to go to waste, would he?",
			FOLLOWER = "I do have a magnetic presence, do I not?",
			GENERIC = "Who bred you to walk upright like that? Deuced unsettling...",
			GUARD = "Alright, alright, moving along.",
			WEREPIG = "Aggression spoils the meat.",
		},
		PIGSKIN = "Crackling!",
		PIGTENT = "Sure to deliver sweet dreams.",
		PIGTORCH = "I wonder what it means?",
		PIKE_SKULL = "Yeeouch!",
		PINECONE = "Pine-scented!",
        PINECONE_SAPLING = "One day you'll be a tree.",
		LUMPY_SAPLING = "Despite the odds, it has produced life.",
		PITCHFORK = "Proper farm gear.",
		PLANTMEAT = "Meaty leaves? I'm so confused...",
		PLANTMEAT_COOKED = "Could use less oxymorons...",
		PLANT_NORMAL =
		{
			GENERIC = "The miracle of life!",
			GROWING = "That is it, just a little more...",
			READY = "Fresh-picked produce!",
			WITHERED = "Oh dear me, the crop has failed...",
		},
		POISONHOLE = "I smell trouble...",
		POMEGRANATE = "Wonderful!",
		POMEGRANATE_COOKED = "Could use tahini and mint...",
		POMEGRANATE_SEEDS = "Seedy seeds!",
		POND = "I can't see the bottom...",
		POND_ALGAE = "I can't see the bottom...",
		POOP = "The end result of a fine meal.",
		PORTABLECOOKPOT_ITEM = "What new culinary adventures shall we undertake, old friend.",
		PORTABLECOOKPOT =
		{
            --BURNT = "Nononononono whyyyyyyyyyyyyyyy!?",
			COOKING_LONG = "The flavors need time to meld.",
            COOKING_SHORT = "I threw that meal together!",
            DONE = "Pickup! Oh, old habits...",
            EMPTY = "I would never leave home without it!",
        },
	    GIFT = "Réchauffe le coeur...", --Warms the heart...
        GIFTWRAP = "I'm sure wrapping a gift is much like wrapping up leftovers.",
		POTTEDFERN = "Nature. Tamed.",
		SUCCULENT_POTTED = "Nature. Tamed.",
		SUCCULENT_PLANT = "Pretty plant produce.",
		SUCCULENT_PICKED = "How edible might this possibly be?",
		SENTRYWARD = "A structure for watching the area... Not my preferred choice of home décor.",
		TOWNPORTAL =
        {
			GENERIC = "I can easily gather everyone around for supper.",
			ACTIVE = "An easy-access route opens.",
		},
        TOWNPORTALTALISMAN = 
        {
			GENERIC = "Smells like an aged pepper.",
			ACTIVE = "Can I take a different route?",
		},
        WETPAPER = "I wouldn't recommend using this in the kitchen.",
        WETPOUCH = "What could have possibly been down there?",
		MOONROCK_PIECES = "It seems very... off-putting.",
		MOONBASE =
        {
            GENERIC = "I'd prefer not to get involved with any of that devilish magic.",
            BROKEN = "Astonishing ancient remains, broken to bits.",
            STAFFED = "A masterpiece takes time, but I'm not sure what we're waiting for.",
            WRONGSTAFF = "There must be an incorrect ingredient in there.",
			MOONSTAFF = "Some sort of magic is being powered here...",
        },
		MOONDIAL = 
        {
			GENERIC = "A sparkling water pan, to be used to watch the moon.",
			NIGHT_NEW = "A fresh new moon to begin anew.",
			NIGHT_WAX = "The moon is waxing.",
			NIGHT_FULL = "The moon is full, and still looks as cheesy as ever.",
			NIGHT_WANE = "The moon is waning.",
			CAVE = "The underground areas are blind to the glistening moon lights.",
        },
		POWCAKE = "I would not feed this to my worst enemies. Or would I...",
		PRIMEAPE = "You reek of mischief and other kinds of... reek.",
		PRIMEAPEBARREL = "Someone has a hoarding issue.",
		PUMPKIN = "I'm the pumpking of the world!",
		PUMPKINCOOKIE = "I've outdone myself this time.",
		PUMPKIN_COOKED = "Could use some pie crust and nutmeg...",
		PUMPKIN_LANTERN = "Trick 'r' neat!",
		PUMPKIN_SEEDS = "Seed saver!",
		PURPLEAMULET = "I must be crazy to fool around with this.",
		PURPLEGEM = "It holds deep secrets.",
		RABBIT =
		{
			GENERIC = "I haven't had rabbit in awhile...",
			HELD = "Your little heart is beating so fast.",
		},
		RABBITHOLE =
		{
			GENERIC = "Thump twice if you are fat and juicy.",
			SPRING = "What a pity rabbit season has ended.",
		},
		RABBITHOUSE =
		{
			BURNT = "That was no carrot!",
			GENERIC = "Do my eyes deceive me?",
		},
		RAFT = "Better than swimming, I suppose.",
		RAINCOAT = "For a foggy Paris evening.",
		RAINHAT = "Better than a newspaper.",
		RAINOMETER =
		{
			BURNT = "It measures nothing now...",
			GENERIC = "It measures moisture in the clouds.",
		},
		RATATOUILLE = "A veritable village of vegetables!",
		RAZOR = "If only I had aftershave.",
		REDBARREL = "Skull and cross bones is bad, yes?",
		REDGEM = "A deep fire burns within.",
		RED_CAP = "Could use cream and salt... And less poison.",
		RED_CAP_COOKED = "Perhaps I could make a good soup.",
		RED_MUSHROOM =
		{
			GENERIC = "Can't get fresher than that!",
			INGROUND = "It'll be hard to harvest like that.",
			PICKED = "There's nothing left.",
		},
		REEDS =
		{
			BURNING = "The fire took to those quite nicely.",
			GENERIC = "A small clump of reeds.",
			PICKED = "There's nothing left to pick.",
		},
		REFLECTIVEVEST = "Well, it should be hard to lose.",
		RESEARCHLAB = --Science Machine
		{
			BURNT = "That didn't cook very well.",
			GENERIC = "A centre for learning.",
		},
		RESEARCHLAB2 = --Alchemy Machine
		{
			BURNT = "The fire seemed to find it quite tasty.",
			GENERIC = "Oh, the things I'll learn!",
		},
		RESEARCHLAB3 = --Shadow Manipulator
		{
			BURNT = "The darkness is all burnt up.",
			GENERIC = "It boggles the mind.",
		},
		RESURRECTIONSTATUE =
		{
			BURNT = "It won't be much good now.",
			GENERIC = "Part of my soul is within.",
		},
		RESURRECTIONSTONE = "Looks like some sort of ritual stone.",
		ROBIN =
		{
		    GENERIC = "Good afternoon, sir or madam!",
		    HELD = "It's soft, and surprisingly calm.",
		},
		ROBIN_WINTER =
		{
		    GENERIC = "This little fellow seems quite frigid.",
		    HELD = "Let me lend you my warmth, feathered friend.",
		},
		ROBOT_PUPPET = "Surely no one deserves such treatment!",
		ROCK = "Don't you go rolling off on me.",
		ROCKS = "Bite-sized boulders.",
		ROCKY = "Hmm... I would have to be careful to not chip a tooth.",
	    PETRIFIED_TREE = "It has been turned into stone!",
		ROCK_PETRIFIED_TREE = "It has been turned into stone!",
		ROCK_PETRIFIED_TREE_OLD = "It has been turned into stone!",
		ROCK_ICE =
		{
			GENERIC = "Brr!",
			MELTED = "It's just liquid now.",
		},
		ROCK_ICE_MELTED = "It's just liquid now.",
		ROCK_LIGHT =
		{
		    GENERIC = "The lava has crusted over.",
			LOW = "Like a pie on a proverbial windowsill, it will soon cool.",
			NORMAL = "Nature's fiery fondue pot.",
			OUT = "It has no heat left to give.",
		},
		CAVEIN_BOULDER =
        {
            GENERIC = "Seems rollable.",
            RAISED = "It's in quite the jam.",
        },
		ROOK = "What a rude contraption.",
		ROOK_NIGHTMARE = "An utter monstrosity!",
		ROPE = "A bit too thick to tie up a roast.",
		ROTTENEGG = "Pee-eew!",
		ROYAL_JELLY = "Such a strong jelly.",
        JELLYBEAN = "They can't fill an entire appetite but they can fill your taste buds!",
		SADDLE_BASIC = "Is this proper animal riding equipment?",
        SADDLE_RACE = "Adds a little spice to my ride.",
        SADDLE_WAR = "To equip an animal for a war of sorts.",
        SADDLEHORN = "It's like a spatula for a saddle.",
		SALTLICK = "It's better tasting to the beefalo.",
        BRUSH = "For tidying unkempt beast hair.",
		RUBBLE = "Delicious destruction.",
		RUINSHAT = "Seems unnecessarily fancy.",
		RUINS_BAT = "I could tenderize some meat with this.",
		RUINS_RUBBLE = "Delicious destruction.",
		--RUINSRELIC_PLATE = "I might like to spruce this up before serving.",
		SANITYROCK =
		{
			ACTIVE = "It's tugging on my mind.",
			INACTIVE = "The darkness lurks within.",
		},
		SAPLING =
		{
			BURNING = "Those burn quite dramatically.",
			GENERIC = "Those could be key to my continued survival.",
			PICKED = "There is nothing left for me to grasp!",
			WITHERED = "It could use some love.",
			DISEASED = "It has reached its last cycle.",
			DISEASING = "It appears to be becoming brittle, best to not use it as filler.",
		},
       	SCARECROW = 
   		{
			GENERIC = "A classic! Protect my crops, sir!",
			BURNING = "Hm, the crows must be getting their revenge.",
			BURNT = "It's a very sad sight to behold.",
   		},
		SCULPTINGTABLE=
   		{
			EMPTY = "Sculpting and ceramics aren't really my area of expertise. But I'm open to new flavors!",
			BLOCK = "Never judge a piece before it's finished!",
			SCULPTURE = "Magnifique!",
			BURNT = "Ah, that's not right.",
   		},
 	    SCULPTURE_KNIGHTHEAD = "It's missing its other half, we ought to find it.",
		SCULPTURE_KNIGHTBODY = 
		{
			COVERED = "I'm not quite sure what purpose it serves.",
			UNCOVERED = "I think we're onto something here!",
			FINISHED = "Welcome back to the world, mon ami.",
			READY = "Something's cooking up in there.",
		},
        SCULPTURE_BISHOPHEAD = "To whom do you belong to?",
		SCULPTURE_BISHOPBODY = 
		{
			COVERED = "Hm, a strange aesthetic choice for this area.",
			UNCOVERED = "There's more to be discovered here.",
			FINISHED = "Ah, a finished masterpiece!",
			READY = "Something's cooking up in there.",
		},
        SCULPTURE_ROOKNOSE = "Could I get a hand here with this?",
		SCULPTURE_ROOKBODY = 
		{
			COVERED = "What a strange piece, very unnerving.",
			UNCOVERED = "Just a couple more touch-ups and it should be fini!",
			FINISHED = "All better now! Carry along!",
			READY = "Something's cooking up in there.",
		},
        GARGOYLE_HOUND = "Gah, I do not like staring at it for too long.",
        GARGOYLE_WEREPIG = "That is a very questionable choice in design.",
		
		SEEDS = "You may grow up to be delicious one day.",
		SEEDS_COOKED = "Could use smoked paprika...",
		SEWING_KIT = "Not exactly my specialty.",
		SEWING_TAPE = "Could fix up a patch or two.",
		SHOVEL = "I'm not the landscaping type.",
		SIESTAHUT =
		{
			BURNT = "Overcooked.",
			GENERIC = "Comes in handy after a big lunch.",
		},
		SILK = "Is that sanitary?",
		SKELETON = "I have a bone to pick with you.",
		SKULLCHEST = "What an ominous container.",
		SLURPER = "It is not polite to slurp.",
		SLURPERPELT = "Wear this? What in heavens for?",
		SLURPER_PELT = "Wear this? What in heavens for?",
		SLURTLE = "You would flavor a soup nicely. Your shell could be the bowl!",
		SLURTLEHAT = "Be the snail.",
		SLURTLEHOLE = "Yuck!",
		SLURTLESLIME = "Nature giveth, and nature grosseth.",
		SLURTLE_SHELLPIECES = "If only I had crazy glue.",
		SMALLBIRD =
		{
			GENERIC = "Hello food... uh, friend.",
			HUNGRY = "I suppose I could whip something up for you.",
			STARVING = "You look famished!",
		},
		SMALLMEAT = "Fresh protein!",
		SMALLMEAT_DRIED = "Could use a teriyaki glaze...",
		SNAKE = "Stay back or I'll turn you into something savory!",
		SNURTLE = "Escar-goodness gracious!",
		SPAT = "I'll have remember to properly wash your chops.",
		PHLEGM = "Ugh. Not food safe!",
		SPEAR = "For kebab-ing.",
		SPIDER =
		{
			DEAD = "Please no rain!",
			GENERIC = "You are not for eating.",
			SLEEPING = "It should make itself a silk pillow.",
		},
		SPIDERDEN = "A spider has to live somewhere, I suppose.",
		SPIDEREGGSACK = "This is probably a delicacy somewhere.",
		SPIDERGLAND = "Alternative medicine.",
		SPIDERHAT = "Well, it is on my head now. Best make the most of it.",
		SPIDERHOLE = "I have no reason to investigate any further.",
		SPIDERHOLE_ROCK = "I have no reason to investigate any further.",
		SPIDERQUEEN = "I will not bend the knee to the likes of you!",
		SPIDER_DROPPER = "Ah, the old \"drop from the ceiling and commit violent acts\" act.",
		SPIDER_HIDER = "A spider that turtles!",
		SPIDER_SPITTER = "So many spiders!",
		SPIDER_WARRIOR =
		{
			DEAD = "It knew the risks.",
			GENERIC = "Does this mean you are even more warlike than the others?",
			SLEEPING = "It is having a flashback to the spider war...",
		},
		SPOILED_FOOD = "It is a sin to waste food...",
		STAFFLIGHT = "Too much power to hold in one hand.",
		STAFFCOLDLIGHT = "Cold as ice!",
		STAFF_TORNADO = "Does nature like being tamed?",
		STALAGMITE = "I always get you upside down with stalactites...",
		STALAGMITE_FULL = "Rocks to be had.",
		STALAGMITE_LOW = "Rocks to be had.",
		STALAGMITE_MED = "Rocks to be had.",
		STALAGMITE_TALL = "Rocks to be had.",
		STALAGMITE_TALL_FULL = "Rocks to be had.",
		STALAGMITE_TALL_LOW = "Rocks to be had.",
		STALAGMITE_TALL_MED = "Rocks to be had.",
		LAVA_POND_ROCK = "Rocks to be had.",
		
		STATUEGLOMMER =
		{
			EMPTY = "Oops.",
			GENERIC = "Must have been a pretty important, uh, thingy...",
		},
		STAGEHAND =
        {
			AWAKE = "Keep away from me demon! I do not wish you any harm!",
			HIDING = "That rose is sending me bad omens... I do not like it one bit!",
        },
		STATUE_MARBLE = 
        {
        	GENERIC = "Now that's some fine décor.",
        	TYPE1 = "You appear to be missing a head, madam.",
        	TYPE2 = "Very meaningful décor, you wouldn't see this in any average restaurant.",
        	TYPE3 = "It reminds me of old fancy china, oh how I miss them.",
    	},
		STATUEHARP = "Headless harpsmen.",
		STATUEMAXWELL = "It takes time to thaw a heart of stone.",
		STEELWOOL = "Maybe I could fashion this into a kitchen sponge.",
		STINGER = "I will feel stung if I cannot find a use for this.",
		STRAWHAT = "Now I am on island time.",
        STUFFEDEGGPLANT = "Slightly smoky flesh, savory filling. Ah!",
		SUNKBOAT = "The sea claims all and does not bargain.",
		SWEATERVEST = "I feel so much better all of the sudden.",
		SWEET_POTATO = "Starch never tasted so sweet.",
		SWEET_POTATO_COOKED = "Could use touch of curry and creme freche...",
		SWEET_POTATO_PLANTED = "Starch never tasted so sweet.",
		SWEET_POTATO_SEEDS = "People often confuse yams and sweet potatoes. They're very different!",
		TAFFY = "I hope it never dislodges from my teeth!",
		TALLBIRD = "Leggy.",
		TALLBIRDEGG = "I wonder what its incubation period is?",
		TALLBIRDEGG_COOKED = "Could use sliced fried tomatoes and beans...",
		TALLBIRDEGG_CRACKED =
		{
			COLD = "Oh, you poor egg, you are so cold!",
			GENERIC = "There is activity!",
			HOT = "I hope you don't hardboil.",
			LONG = "This is going to take some dedication.",
			SHORT = "A hatching is in the offing!",
		},
		TALLBIRDNEST =
		{
			GENERIC = "No vacancy here.",
			PICKED = "Empty nest syndrome is setting in.",
		},
		TEENBIRD =
		{
			GENERIC = "You are sort of tall, I guess...",
			HUNGRY = "Teenagers, always hungry!",
			STARVING = "Are you trying to eat me out of base and home?",
		},
		TELEBASE =
		{
			GEMS = "It requires more purple gems.",
			VALID = "It is operational.",
		},
		TELEPORTATO_BASE =
		{
			ACTIVE = "Where shall we go, thing?",
			GENERIC = "It leads somewhere. And that is what I am afraid of.",
			LOCKED = "It denies my access.",
			PARTIAL = "It requires something additional.",
		},
		TELEPORTATO_BOX = "\"This\" likely connects to a \"that.\"",
		TELEPORTATO_CRANK = "Definitely for a cranking action of some kind.",
		TELEPORTATO_POTATO = "This, I do not even...",
		TELEPORTATO_RING = "One ring to teleport them all!",
		TELESTAFF = "Let us take a trip. I am not picky as to where.",
		TENT =
		{
			BURNT = "A good night's sleep, up in smoke.",
			GENERIC = "For roughing it.",
		},
		TENTACLE = "Calamari?",
		TENTACLESPIKE = "This would stick in my throat.",
		TENTACLESPOTS = "Would make a decent kitchen rag.",
		TENTACLE_GARDEN = "If only it were squid and not... whatever it is...",
		TENTACLE_PILLAR = "If only it were squid and not... whatever it is...",
		TENTACLE_PILLAR_ARM = "If only it were squid and not... whatever it is...",
		THULECITE = "Thule-... thulec-... it rolls off the tongue, does it not?",
		THULECITE_PIECES = "A pocketful of thule.",
		TOPHAT = "For a night out on the town...?",
		TORCH = "Not great for caramelizing creme brulee, but it will do for seeing.",
		TRAILMIX = "Energy food!",
		TRANSISTOR = "Positively charged to get my hands on one!",
		TRAP = "I do not wish to be so tricky, but the dinner bell calls me.",
		TRAP_TEETH = "This is not a cruelty-free trap.",
		TRAP_TEETH_MAXWELL = "I must remember where this is...",
		TREASURECHEST =
		{
			BURNT = "Its treasure-chesting days are over.",
			GENERIC = "A safe place to store non-perishables!", --Treasure!
		},
		TREASURECHEST_TRAP = "Hmmm, something does not feel right about this...",
		SACRED_CHEST = 
		{
			GENERIC = "I do not like this chest one bit!",
			LOCKED = "It appears to be judging me as if I were presented as a meal.",
		},
		TREECLUMP = "Someone or something does not want me to tree-spass.",
		TRINKET_1 = "Someone must have really lost their marbles.",
		TRINKET_2 = "I'll hum my own tune.",
		TRINKET_3 = "Some things can't be undone.",
		TRINKET_4 = "Somewhere there's a lawn that misses you.",
		TRINKET_5 = "A rocketship for ants?",
		TRINKET_6 = "These almost look dangerous.",
		TRINKET_7 = "A distraction of little substance.",
		TRINKET_8 = "Ah, memories of bathing.",
		TRINKET_9 = "Buttons that are not so cute.",
		TRINKET_10 = "Manmade masticators.",
		TRINKET_11 = "He doesn't seem trustworthy to me.",
		TRINKET_12 = "I know of no recipe that calls for this.",
		TRINKET_13 = "Somewhere there's a lawn that misses you.",
		TRINKET_14 = "It could use some tea to go with it.",
		TRINKET_15 = "There is no board around to use with this.",
		TRINKET_16 = "There is no board around to use with this.",
		TRINKET_17 = "This eating utensil is too used to be alongside a meal.",
		TRINKET_18 = "I should be careful with this.",
		TRINKET_19 = "An odd used little toy.",
		TRINKET_20 = "Keep this thing away from Wigfrid.",
		TRINKET_21 = "Ah, it's a sad day for I cannot fix this beautiful egg beater.",
		TRINKET_22 = "This yarn wasn't coddled.",
		TRINKET_23 = "I appreciate your help, but I will not be needing it.",
		TRINKET_24 = "Ah, maybe I could store treats in here for the kids.",
		TRINKET_25 = "That smells the opposite of minty-fresh.",
		TRINKET_26 = "I think it's past its ingredient days.",
		TRINKET_27 = "Maybe I could fashion some sort of utensil out of it.",
		TRINKET_28 = "I miss salt and pepper shakers...",
        TRINKET_29 = "I miss salt and pepper shakers...",
        TRINKET_30 = "A piece without a board.",
        TRINKET_31 = "A piece without a board.",		
		TRINKET_32 = "It could make some fine themed decoration.",
        TRINKET_33 = "It's best not to wear rings while in the kitchen.",
        TRINKET_34 = "I prefer not to be tricked any more than I already have.",
        TRINKET_35 = "A flask! I'll be sure to clean it up and give it a proper use!",
		TRINKET_36 = "Attempting to chew with such a commodity is not a good idea.",
		TRINKET_37 = "The only purpose it could serve is a nice camp fire stock.",
		TRINKET_38 = "How much could one really see from afar?", -- Binoculars Griftlands trinket
        TRINKET_39 = "I'd prefer a nice kitchen mitt.", -- Lone Glove Griftlands trinket
        TRINKET_40 = "Perfect for scaling your snails.", -- Snail Scale Griftlands trinket
        TRINKET_41 = "I'm not quite sure what it was. A blender perhaps?", -- Goop Canister Hot Lava trinket
        TRINKET_42 = "Someone's play-thing.", -- Toy Cobra Hot Lava trinket
        TRINKET_43= "There's not much substance to found here.", -- Crocodile Toy Hot Lava trinket
        TRINKET_44 = "You cannot fix everything I suppose.", -- Broken Terrarium ONI trinket
        TRINKET_45 = "Can it pick anything up? I'd like to order a meal.", -- Odd Radio ONI trinket
        TRINKET_46 = "Not the best way one could heat something up.", -- Hairdryer ONI trinket

		HALLOWEENCANDY_1 = "Oh, I had thought there was a whole apple hidden under the coating. But alas.",
        HALLOWEENCANDY_2 = "Bits of waxy fructose corn syrup. Just snacks to go.",
        HALLOWEENCANDY_3 = "Sweet-sweet corn! Albeit a more bite-sized version.",
        HALLOWEENCANDY_4 = "Sweet licorice! I pity those who reject it!",
        HALLOWEENCANDY_5 = "I can only hope its ingredients do not contain the catcoon.",
        HALLOWEENCANDY_6 = "My nose is smelling red flags on these.",
        HALLOWEENCANDY_7 = "Stop wasting these and throwing them out! They're good, just try one!",
        HALLOWEENCANDY_8 = "I feel like it's been years since I've had one of these.",
        HALLOWEENCANDY_9 = "High in calories as it is in taste!",
        HALLOWEENCANDY_10 = "Not too keen on tasting it, but my sweet tooth is demanding a taste!",
        HALLOWEENCANDY_11 = "Sweet blissful chocolate, we meet again!",
		HALLOWEENCANDY_12 = "I am relieved that it is not actual lice.", --ONI meal lice candy
        HALLOWEENCANDY_13 = "Quite the teeth cracker!", --Griftlands themed candy
        HALLOWEENCANDY_14 = "The perfect amount of spice for your life!", --Hot Lava pepper candy
        CANDYBAG = "A sack to carry our festive goodies in!",
		
		HALLOWEEN_ORNAMENT_1 = "One could hang this up someplace.",--Ghost
		HALLOWEEN_ORNAMENT_2 = "I've never been one for these festivities. Much too macabre for my tastes.",--Bat
		HALLOWEEN_ORNAMENT_3 = "I'd like not to step on you.",--Spider
		HALLOWEEN_ORNAMENT_4 = "Not much for eating, is it?",--Tentacle
		HALLOWEEN_ORNAMENT_5 = "I feel much safer knowing it cannot eat me.",--Dangling Spider
		HALLOWEEN_ORNAMENT_6 = "I might need to learn to eat a bit of you.",--Crow

		HALLOWEENPOTION_DRINKS_WEAK = "I cannot pair this with anything.",
		HALLOWEENPOTION_DRINKS_POTENT = "It's quite the hearty mixture!",
        HALLOWEENPOTION_BRAVERY = "I could use a sip of this every other day.",
		HALLOWEENPOTION_FIRE_FX = "Fire infused into a beautiful bottled light show!", 
		MADSCIENCE_LAB = "One must be mad to play around with such a thing.",
		LIVINGTREE_ROOT = "I believe there's a bit of root stuck in it.", 
		LIVINGTREE_SAPLING = "Let's give it space to grow.",
		
		DRAGONHEADHAT = "The most stunning part of the costume set.",
        DRAGONBODYHAT = "Not fit for the kitchen, but it is fit for festivities!",
        DRAGONTAILHAT = "Without it, there is no end.",
        PERDSHRINE =
        {
            GENERIC = "It hungers for something, not quite sure what.",
            EMPTY = "It could use some bait to make it worthwhile.",
            BURNT = "A terrible waste.",
        },
        LUCKY_GOLDNUGGET = "A crisp golden avocado!",
		FIRECRACKERS = "Like oil splattering in a hot pan.",
        REDLANTERN = "I do like festivals like this.",
        PERDFAN = "Like a cool ocean breeze.",
        REDPOUCH = "What might it contain?",
		WARGSHRINE = 
        {
            GENERIC = "It hungers for something, not quite sure what.",
            EMPTY = "It could use a torch to make it worthwhile.",
            BURNT = "A terrible waste.",
        },
        CLAYWARG = 
        {
        	GENERIC = "Definitely not edible!",
        	STATUE = "Even still, it hungers.",
        },
        CLAYHOUND = 
        {
        	GENERIC = "Sit! My meals are not for you!",
        	STATUE = "Might it eat clay kibble?",
        },
        HOUNDWHISTLE = "I'll be sure to use this if any mutts are eyeing my cooking.",
        CHESSPIECE_CLAYHOUND = "A very intimidating piece. I wouldn't recommend eating around it.",
        CHESSPIECE_CLAYWARG = "Not something I'd set up around for dinner. Not a very good omen.",
		PIGSHRINE =
		{
            GENERIC = "An inedible tribute.",
            EMPTY = "I know that hunger. It hungers for meat!",
            BURNT = "A touch overdone.",
		},
		PIG_TOKEN = "What might this craftsmanship be worth?",
		YOTP_FOOD1 = "Magnifique! Finally, a feast fit for me!",
		YOTP_FOOD2 = "Mon dieu! This is not fit for human consumption!",
		YOTP_FOOD3 = "Hm, this isn't anything to write home about.",
		PIGELITE1 = "You are quite the rude fellow.", --BLUE
		PIGELITE2 = "You'll be the one eating the signs here!", --RED
		PIGELITE3 = "Such dirty looks.", --WHITE
		PIGELITE4 = "Landing a sign on my back might land you on our barbecue!", --GREEN

		BISHOP_CHARGE_HIT = "Gah!",
		TRUNKVEST_SUMMER = "Fashionably refreshing.",
		TRUNKVEST_WINTER = "Toasty and trendy.",
		TRUNK_COOKED = "Could use... Hm... I'm stumped...",
		TRUNK_SUMMER = "This meat has a gamey odor.",
		TRUNK_WINTER = "Not the finest cut of meat.",
		TUMBLEWEED = "What secrets do you hold?",
		TURF_SANDY = "It's like an ingredient for the ground.",
		TURF_BADLANDS = "It's like an ingredient for the ground.",
		TURF_CARPETFLOOR = "Make fists with your toes...",
		TURF_CAVE = "It's like an ingredient for the ground.",
		TURF_CHECKERFLOOR = "It's like an ingredient for the ground.",
		TURF_DECIDUOUS = "It's like an ingredient for the ground.",
		TURF_DESERTDIRT = "It's like an ingredient for the ground.",
		TURF_DIRT = "It's like an ingredient for the ground.",
		TURF_FOREST = "It's like an ingredient for the ground.",
		TURF_FUNGUS = "It's like an ingredient for the ground.",
		TURF_FUNGUS_GREEN = "It's like an ingredient for the ground.",
		TURF_GRASS = "Will I need to cut this?",
		TURF_MARSH = "It's like an ingredient for the ground.",
		TURF_MUD = "It's like an ingredient for the ground.",
		TURF_ROCKY = "It's like an ingredient for the ground.",
		TURF_SAVANNA = "It's like an ingredient for the ground.",
		TURF_SINKHOLE = "It's like an ingredient for the ground.",
		TURF_SWAMP = "It's like an ingredient for the ground.",
		TURF_UNDERROCK = "It's like an ingredient for the ground.",
		TURF_WOODFLOOR = "It's like an ingredient for the ground.",
		TURKEYDINNER = "I'm getting sleepy just looking at it!",
		TWIGS = "The start of a good cooking fire.",
		UMBRELLA = "I will try to remember not to open indoors.",
		UNAGI = "More like \"umami\"! Ooooh, mommy!",
		UNIMPLEMENTED = "It appears unfinished.",
		WAFFLES = "Oh, brunch, I have missed you so!",
		WALL_HAY =
		{
			BURNT = "That is what I expected.",
			GENERIC = "Calling it a \"wall\" is kind of a stretch.",
		},
		WALL_HAY_ITEM = "Hay look, a wall!",
		WALL_RUINS = "Look at the carvings...",
		WALL_RUINS_ITEM = "The stories these tell... fascinating...",
		WALL_STONE = "Good stone work.",
		WALL_STONE_ITEM = "I feel secure behind this.",
		WALL_WOOD =
		{
			BURNT = "Wood burns. Who knew? ...Me!?",
			GENERIC = "Putting down stakes.",
		},
		WALL_WOOD_ITEM = "Delivers a rather wooden performance as a wall.",
		WALL_MOONROCK = "Quite the spacious wall.",
		WALL_MOONROCK_ITEM = "Where might I place this?",
		FENCE = "It's but a simple fence.",
        FENCE_ITEM = "Keeps things separated.",
        FENCE_GATE = "Like an oven door.",
        FENCE_GATE_ITEM = "The ingredients for a gate.",
		WALRUS = "They move faster than you'd think.",
		WALRUSHAT = "Smells a little musty...",
		WALRUS_CAMP =
		{
			EMPTY = "Yes, vacancy.",
			GENERIC = "Some outdoorsy types made this.",
		},
		WALRUS_TUSK = "It won't be needing this anymore.",
		WARDROBE = 
		{
			GENERIC = "For freshening up before a dinner meal.",
            BURNING = "Au revoir, wardrobe.",
			BURNT = "Tragique.",
		},
		WARG = "Leader of the pack.",
		WASPHIVE = "Not your average bees.",
		WATERBALLOON = "Plump and ready for throwing.",
		WATERMELON = "Despite its name, it is mostly filled with deliciousness!",
		WATERMELONHAT = "Aaaahhhhhh sweet relief...",
		WATERMELONICLE = "I feel like a kid again!",
		WATERMELON_COOKED = "Could use mint and feta...",
		WATERMELON_SEEDS = "More watermelon, anyone?",
		WEBBERSKULL = "Stop staring at me or I'll bury you!",
		WETGOOP = "I am thankful my sous chefs are not around to witness this abomination...",
		WHIP = "I prefer to whip up a good meal, not other mammals.",
		WINTERHAT = "I know when to don this, and not a minute sooner.",
		WINTEROMETER =
		{
			BURNT = "Foresight is 0/0.",
			GENERIC = "Splendid. I should like to know when the worm is going to turn.",
		},
		
		WINTER_TREE =
        {
			BURNT = "Festive décor in the kitchen can only lead to one thing...",
			BURNING = "It, oh, it appears to be on fire.",
			CANDECORATE = "Cheers to many years!",
			YOUNG = "I can almost taste the feast!",
        },
        WINTER_TREESTAND = "It requires a pine cone.",
        WINTER_ORNAMENT = "The beginning of festivities!",
        WINTER_ORNAMENTLIGHT = "Nothing like a small comforting light to keep the peace.",
		WINTER_ORNAMENTBOSS = "It's the rarest of ornaments!",
		WINTER_ORNAMENTFORGE = "It's quite the spicy ingredient.",
		WINTER_ORNAMENTGORGE = "I must have missed out on the meaning of this one.",
        
        WINTER_FOOD1 = "Gingerbread cookies? It's been years!", --gingerbread cookie
        WINTER_FOOD2 = "Light powdering on a finely cooked base? It truly is a Winter's Feast miracle!", --sugar cookie
        WINTER_FOOD3 = "My sweet tooth demands its peppermint-y greatness!", --candy cane
        WINTER_FOOD4 = "Fruitcakes usually contain dried candies and nuts, not evil.", --fruitcake
		WINTER_FOOD5 = "Season's greetings, season's eatings!", --yule log cake
        WINTER_FOOD6 = "Rich in flavor!", --plum pudding
        WINTER_FOOD7 = "Cider! Although, it's best for a side dish.", --apple cider
        WINTER_FOOD8 = "Could use bits of peppermint, and a melted chocolate glaze.", --hot cocoa
        WINTER_FOOD9 = "Could use some whipped cream with freshly ground cinnamon.", --eggnog

        KLAUS = "Thinking up recipes on such a monstrosity would be quite the challenge.",
        KLAUS_SACK = "Quite the goodie bag.",
		KLAUSSACKKEY = "Some sort of menacing key.",
		WORM =
		{
			DIRT = "Dirty.",
			PLANT = "I see nothing amiss here.",
			WORM = "Worm!",
		},
		WORMHOLE =
		{
			GENERIC = "That is no ordinary tooth-lined hole in the ground!",
			OPEN = "Am I really doing this?",
		},
		WORMHOLE_LIMITED = "These things can look worse?",
		WORMLIGHT = "Radiates deliciousness.",
		WORMLIGHT_LESSER = "A little wrinkle never hurt anybody.",
		WORMLIGHT_PLANT = "Some ingredients may be worth overlooking superstition!",
		YELLOWAMULET = "Puts some pep in my step!",
		YELLOWGEM = "I miss lemons...",
		YELLOWSTAFF = "I could stir a huge pot with this thing!",
		---- FRESHFRUITCREPES = "Is this not a thing of beauty?",
		
		MALE_PUPPET = "Free him!",
		MANRABBIT_TAIL = "The texture is exceptionally comforting.",
		MARBLETREE = "How supremely unnatural!",
		--MONSTERTARTARE = "This is a culinary abomination. I'm appalled.",
		PANDORASCHEST = "It's quite magnificent.",
		PERD = "A fellow with excellent taste.",
		RELIC =
		{
			BROKEN = "A piece of culinary history has been lost.",
			GENERIC = "Ancient kitchenware.",
		},
		RESEARCHLAB4 =
		{
			BURNT = "Nothing but ashes.",
			GENERIC = "I won't even try to pronounce it...",
		},

		ROOK_NIGHTMARE = "What a monstrosity!",
		RUBBLE = "Delicious destruction.",
		RUINS_RUBBLE = "Delicious destruction.",
		TURF_CAVE = "It's like an ingredient for the ground.",
		TURF_DECIDUOUS = "It's like an ingredient for the ground.",
		TURF_FUNGUS_RED = "It's like an ingredient for the ground.",
		TURF_ROAD = "It's like an ingredient for the ground.",
		TURF_DRAGONFLY = "This would do nicely as solid kitchen flooring.",
		
		REVIVER = "It must be soothing to apparitions.",
		SHADOWHEART = "That's.... That's very concerning.",
		ATRIUM_RUBBLE = 
        {
			LINE_1 = "The poor souls in this drawing, hungry.",
			LINE_2 = "Ah, it's a tad too brushed to make it out.",
			LINE_3 = "Some cooking oil seems to covered here.",
			LINE_4 = "Oh dear. Something appears to be popping out of them.",
			LINE_5 = "It appears to be a more advanced city than my own...",
		},
        ATRIUM_STATUE = "How real is this?",
        ATRIUM_LIGHT = 
        {
			ON = "The light to turn your mind and spoil your food.",
			OFF = "Must we power it?",
		},
        ATRIUM_GATE =
        {
			ON = "That should about do it... but at what cost?",
			OFF = "It requires a final ingredient.",
			CHARGING = "It's consuming dark energies...",
			DESTABILIZING = "It's about to blow this kitchen whole!",
			COOLDOWN = "It won't be functioning for quite a while longer.",
        },
        ATRIUM_KEY = "It activates a gateway to some place. Where? That is what I am afraid of.",
		LIFEINJECTOR = "Who shall I stick it to?",
		SKELETON_PLAYER =
		{
			MALE = "%s has been tragically overcooked by %s.",
			FEMALE = "%s has been tragically overcooked by %s.",
			ROBOT = "%s has been tragically overcooked by %s.",
			DEFAULT = "%s has been tragically overcooked by %s.",
		},
		HUMANMEAT = "I... I refuse to cook this.",
		HUMANMEAT_COOKED = "Could use... uh... I don't even...",
		HUMANMEAT_DRIED = "Could use... better judgement...",
		MOONROCKNUGGET = "Bite-sized moon boulders.",
		ROCK_MOON = "I wonder what salts it has.",
		MOONROCKCRATER = "It could use some touching up.",

        REDMOONEYE = "This fancy color-coded rock will help us keep track of this area.",
        PURPLEMOONEYE = "This will help mark various locations.",
        GREENMOONEYE = "A fancy color-coded rock to mark your whereabouts!",
        ORANGEMOONEYE = "It assists with keeping in contact on long travels with others!",
        YELLOWMOONEYE = "It will help make this wretched and unknown place a little more known, but still wretched.",
        BLUEMOONEYE = "It'll help me mark down where to be for dinner.",

		--v2 Winona
        WINONA_CATAPULT = 
        {
        	GENERIC = "Perhaps it flings pies as well.",
        	OFF = "It looks a bit peckish.",
        	BURNING = "Why would anyone want to flambé this?",
        	BURNT = "Nothing but ashes.",
        },
        WINONA_SPOTLIGHT = 
        {
        	GENERIC = "Like in-front of the most regal restaurants!",
        	OFF = "It looks a bit peckish.",
        	BURNING = "Why would anyone want to flambé this?",
        	BURNT = "Nothing but ashes.",
        },
        WINONA_BATTERY_LOW = 
        {
        	GENERIC = "I wouldn't recommend barbecuing on this.",
        	LOWPOWER = "It's getting low on power.",
        	OFF = "I suppose I should turn it on.",
        	BURNING = "Why would anyone want to flambé this?",
        	BURNT = "Nothing but ashes.",
        },
        WINONA_BATTERY_HIGH = 
        {
        	GENERIC = "Magic things and what have you.",
        	LOWPOWER = "It seems to be running low.",
        	OFF = "It looks a bit peckish.",
        	BURNING = "Why would anyone want to flambé this?",
        	BURNT = "Nothing but ashes.",
        },

]]
		--Island Adventures (Shipwrecked) Starts here
		--------------------------------------------------------
		
	--WILDBOREGUARD = "",
	SOLOFISH_DEAD = "Don't worry, mon amie. I will make you delicious.",
	PURPLE_GROUPER = "It couldn't be any fresher!",
	PURPLE_GROUPER_COOKED = "Pan-fried grouper with pigeon peas! Delectable!",

	--GHOST_SAILOR = "",
	FLOTSAM = "Could be a piece of the ship...",
	SUNKBOAT = "The sea claims all and does not bargain.",
	SUNKEN_BOAT =
	{
		ABANDONED = "Where did he go?",
		GENERIC = "Hey fella, need a wing?",
	},
	SUNKEN_BOAT_BURNT = "Yikes! That boat had baaaad luck.",
	SUNKEN_BOAT_TRINKET_1 = "Excuse me?",
	SUNKEN_BOAT_TRINKET_2 = "It cannot help me.",
	SUNKEN_BOAT_TRINKET_3 = "Not much of a candle then, is it?",
	SUNKEN_BOAT_TRINKET_4 = "Sea-what?",
	SUNKEN_BOAT_TRINKET_5 = "Not my size.",
	-- BANANAPOP = "Perhaps not my most complicated dish, but no less tasty.",
	BISQUE = "Utterly divine!",
	-- CEVICHE = "Truly what I live for!",
	SHARKFINSOUP = "I used Nana's secret recipe.",
	JELLYOPOP = "Hmmm... An interesting flavor.",

    ENCRUSTEDBOAT = "It's a bit wobbly.",
    BABYOX = "Worry not, mon chou, I've no interest in veal today.",
    BALLPHINHOUSE = "They're quite social creatures, no?",
    DORSALFIN = "I'd imagine that hurt.",
    NUBBIN = "No coral in sight. Perhaps later.",
    CORALLARVE = "Bonjour, mon petit amie.",
    RAINBOWJELLYFISH = "You might go well in a stew.",
    RAINBOWJELLYFISH_PLANTED = "I see no reason to bother it.",
    RAINBOWJELLYFISH_DEAD = "No sense letting it go to waste.",
    RAINBOWJELLYFISH_COOKED = "You can really taste the \"rainbow\".",
    RAINBOWJELLYJERKY = "The natural sea salt is a great flavor enhancer.",
    WALL_ENFORCEDLIMESTONE = "Good and strong.",
    WALL_ENFORCEDLIMESTONE_ITEM = "I could probably place this at sea without issue.",      
    CROCODOG = "I am not on the menu!",
    POISONCROCODOG = "Don't eat me! I'm not even cooked!",
    WATERCROCODOG = "You look much too hungry!",       
    QUACKENBEAK = "Imagine the meals it could've eaten with that thing!",
    QUACKERINGRAM = "Excuse me everyone, out of my way, please.",

    CAVIAR = "Eat it with a clamshell or the flavor will be ruined.",
    CORMORANT = "The caviar delivery service.",
	PIERROT_FISH = "How would you like to be a nice chowder?",
	NEON_QUATTRO = "Would you prefer to be scorched, or cracked?",
	PIERROT_FISH_COOKED = "Ah, I should have saved the head for soup!",
	NEON_QUATTRO_COOKED = "Sigh. It's not even seasoned.",

    FISH_FARM = 
    {
        	EMPTY = "I'll have to sacrifice caviar ingredients for this.",
			STOCKED = "Just think, market fresh fish every morning!",
			ONEFISH = "Should I make a fish stew with thyme and onion?",
			TWOFISH = "Oh! Boiled fish with celery and goat pepper?",
			REDFISH = "Maybe a chowder with hot pepper and shrimp stock!",
			BLUEFISH  = "Let the cook off begin!",
    },

    ROE = "I can make caviar with canapes!",
    ROE_COOKED = "Could use a squeeze of fresh lemon.",

    SEA_YARD = 
     {
            ON = "Is my boat in need of a touch up?",
            OFF = "Ah, I can't fix my boat right now.",
            LOWFUEL = "It seems to be running low.",
     },
    SEA_CHIMINEA =
     {
            EMBERS = "Worryingly low.",
            GENERIC = "Is this a fire hazard, or a boating hazard?",
            HIGH = "Goodness! It's a grease fire!",
            LOW = "Looks a bit dim.",
            NORMAL = "It's burning steady.",
            OUT = "I can't cook without a fire!",
     }, 

    TAR = "Adds a truly unique flavor to licorice.",
    TAR_EXTRACTOR =
        {
            ON = "It's extracting tar quite vigorously!",
            OFF = "I suppose I should turn it on.",
            LOWFUEL = "It looks a bit peckish.",
        },
    TAR_POOL = "I think there's tar down there.",

    TARLAMP = "What a rustic delight!",
    TARSUIT = "I hope there are no feathers around!",
    TAR_TRAP = "The slowed pace gives you time to enjoy the scenery.",

    TROPICALBOUILLABAISSE = "Such a decadent dish!",

    SEA_LAB = "Couldn't hurt to hit the books now and then.",
    WATERCHEST = "I probably shouldn't keep perishables in it.",
	
	ANTIVENOM = "Could come in very handy.",
	POISONBALM = "I fear that it tastes as terrible as it smells.",
    QUACKENDRILL = "It's tres heavy!",
    HARPOON = "Time to catch myself some dinner.",
    MUSSEL_BED = "Imagine! Fresh mussels, whenever I desire!",
	VENOMGLAND = "The worst kind of gland!",
	BLOWDART_POISON = "A coward's weapon. Suits me fine!",
	OBSIDIANMACHETE = "You could overheat swinging this thing too much.",
	SPEARGUN_POISON = "It would make me sick to use this on good meat.",
	OBSIDIANSPEARGUN = "Ready. Aim. Fire.",
	LUGGAGECHEST = "Please have fresh underwear inside!",
	PIRATIHATITATOR =
	{
		BURNT = "It played its last magic trick.",
		GENERIC = "This reminds me of something...",
	},
	COFFEE = "Magnifique!",
	COFFEEBEANS = "Glorious!",
	COFFEEBEANS_COOKED = "Could use hot water...!",
	--COFFEEBOT = "What a delight!",
	COFFEEBUSH =
	{
		BARREN = "Come back, coffee!",
		GENERIC = "Does that bush grow... coffee beans?!",
		PICKED = "I hope they grow back by tomorrow morning.",
		WITHERED = "Come back, coffee!",
	},
	MUSSEL = "Into my tummy you go! Good bi, valves.",
	MUSSEL_COOKED = "Could use shallots and lemongrass...",
	MUSSEL_FARM =
	{
		GENERIC = "A delightful seafood dinner dwells there.",
		STICKPLANTED = "Stick with me, mussels. I'll take you places!",
	},
	MUSSEL_STICK = "Mussels aren't strong enough to resist this stick!",
	LOBSTER = "Come to me, precious!",
	LOBSTERHOLE = "I am waiting for you!",
	WOBSTERBISQUE = "I've truly outdone myself!",
    WOBSTERDINNER = "Being stranded is no reason not to eat well!!",
	SEATRAP = "I can trick some delicious crustaceans into this!",
	SANDCASTLE =
	{
		GENERIC = "How calming.",
		SAND = "It looks at home here.",
	},
	BOATREPAIRKIT = "A most sensible traveling companion.",

	BALLPHIN = "Chipper fellows.",
	BOATCANNON = "I cannon wait to use this!",
	BOTTLELANTERN = "Shine on!",
	BURIEDTREASURE = "What shall I find?",
	BUSH_VINE =
	{
		BURNING = "Perhaps I could smoke a nice cutlet on it?",
		BURNT = "That smoky aroma always makes me hungry...",
		CHOPPED = "How divine! It has been de-vined.",
		GENERIC = "I do wish those were grapevines...",
	},
	CAPTAINHAT = "I have been promoted!",
	COCONADE =
	{
		BURNING = "This will only burn for so long before...",
		GENERIC = "Weaponized food.",
	},
	CORAL = "What shall I make with you?",
	ROCK_CORAL = "A rainbow searock.",
	CRABHOLE = "Come out, come out!",
	CUTLASS = "En garde!",
	DUBLOON = "Golden ham, golden honey, golden coin.",
	FABRIC = "Soft and crisp, all at once.",
	FISHINHOLE = "Shining, sparkling snacks.",
	GOLDENMACHETE = "Fancy slicer.",
	JELLYFISH = "Electric meduse for dinner?",
	JELLYFISH_COOKED = "Could use sesame oil and chilis...",
	JELLYFISH_DEAD = "Ohh, its petit face.",
	JELLYFISH_PLANTED = "Meduse.",
	JELLYJERKY = "Could use garlic...",

	ROCK_LIMPET =
	{
		GENERIC = "A petit snail farm!",
		PICKED = "I have a soft spot for bivalves!",
	},
	BOAT_LOGRAFT = "These logs might be better suited to a fire...",
	MACHETE = "I could chop many an onion with this!",
	IA_MESSAGEBOTTLEEMPTY = "I wonder what vintage used to be in this bottle...",
	MOSQUITO_POISON = "You not only take, but you also give? Well, no thanks!",
	OBSIDIANCOCONADE = "These are a blast!",
	OBSIDIANFIREPIT =
	{
		EMBERS = "That fire's almost out!",
		GENERIC = "To warm my fingers and roast sausages.",
		HIGH = "Maximum heat!",
		LOW = "It's getting low.",
		NORMAL = "This fire's on fire!",
		OUT = "I like when it's warm and toasty.",
	},
	OX = "Here's the beef!",
	PIRATEHAT = "I do not throw in with these scoundrels. But I like the hat.",
	BOAT_RAFT = "Better than swimming, I suppose.",
	BOAT_ROW = "Free me from the shackles of this island!",
	SAIL_PALMLEAF = "This should speed things up.",
	SANDBAG_ITEM = "No potatoes here. Oh well.",
	SANDBAG = "I was hoping it would be full of potatoes.",
	SEASACK = "Wetter is better.",
	SEASHELL_BEACHED = "What a pretty shell.",
	SEAWEED = "I do not have much experience with this ingredient.",

	SEAWEED_PLANTED = "Sea produce!",
	SLOTMACHINE = "Maybe I'll win something tasty?",
	SNAKE_POISON = "I'll need to butcher you ever so carefully.",
	SNAKESKIN = "Would make a haute apron.",
	SNAKESKINHAT = "Très cool.",
	SOLOFISH = "You'll make a fine filet.",
	SPEARGUN = "Long-range kebab-ing.",
	SWORDFISH = "A deluxe, but dangerous ingredient!",
	IA_TRIDENT = "That's one giant fork!",
	TRINKET_IA_13 = "I'd prefer switcha... With a piece of duff.",
	TRINKET_IA_14 = "Do they work with paring knives?",
	TRINKET_IA_15 = "I prefer the lute, myself.",
	TRINKET_IA_16 = "This has no business calling itself a plate.",
	TRINKET_IA_17 = "I wouldn't wear this, even if it were my size.",
	TRINKET_IA_18 = "I should be careful with this.",
	TRINKET_IA_19 = "An odd prescription.",
	TURBINE_BLADES = "Could work in a food processor.",
	TURF_BEACH = "It's like an ingredient for the ground.",
	TURF_JUNGLE = "It's like an ingredient for the ground.",
	VOLCANO_ALTAR =
	{
		GENERIC = "It appears to be some kind of altar.",
		OPEN = "It accepts offerings, I think.",
	},
	VOLCANO_ALTAR_BROKEN = "Now there will be no pleasing this thing!",
	WHALE_BLUE = "Why the long fishface?",
	WHALE_CARCASS_BLUE = "That is quite a lot of dead whale.",
	WHALE_CARCASS_WHITE = "That is quite a lot of dead whale.",

	ARMOR_SNAKESKIN = "Function, fashion, and four less living snakes.",
	SAIL_CLOTH = "Now we're cooking!",
	DUG_COFFEEBUSH = "TCoffee to go!",
	LAVAPOOL = "Spicy!",
	BAMBOO = "Bamboo shoots are excellent on a nice bed of rice.",
	AERODYNAMICHAT = "Speeds me on my way.",
	POISONHOLE = "I smell trouble...",
	BOAT_LANTERN = "To \"sea\" what's coming!",
	SWORDFISH_DEAD = "The grand poisson!",
	LIMPETS = "They have a salty aroma.",
	OBSIDIANAXE = "You really build up a head of steam swinging this!",
	COCONUT = "Its packaging is tough to open.",
	COCONUT_SAPLING = "Evidence of a coconut uneaten. Sigh.",
	COCONUT_COOKED = "Could use rice and curry spices...",
	BERMUDATRIANGLE = "Shouldn't I boat away from these?",
	SNAKE = "Stay back or I'll turn you into something savory!",
	SNAKEOIL = "Why can't you be olive oil?",
	ARMORSEASHELL = "Seashell mail.",
	SNAKE_FIRE = "Only thing worse than a snake is a snake on fire.",

	PACKIM = "You have a big mouth, mister.",
	PACKIM_FISHBONE = "Picked clean...",

	ARMORLIMESTONE = "With this I will be a stone man.",
	TIGERSHARK = "I wish you were a tiger shrimp instead!",
	OBSIDIAN_WORKBENCH = "I believe it churns out volcanic doohickeys!",

	NEEDLESPEAR = "Who shall I stick it to?",
	LIMESTONENUGGET = "Made from petit fishy skeletons.",
	DRAGOON = "I do not like these fellows one bit.",

	ICEMAKER = 
	{
		HIGH = "Whistle while you work!",
		LOW = "It's still running.",
		NORMAL = "A small luxury.",
		OUT = "It's run dry.",
		VERYLOW = "Nearly out!",
	},

	DUG_BAMBOOTREE = "Shall I bring it back to life?",
	BAMBOOTREE =
	{
		BURNING = "Fricasseed!",
		BURNT = "A terrible waste.",
		CHOPPED = "More will sprout in time.",
		GENERIC = "Some chefs steam rice in bamboo stocks.",
	},
	JUNGLETREE =
	{
		BURNING = "Au revoir, tree.",
		BURNT = "Crisp, no?",
		CHOPPED = "Sliced!",
		GENERIC = "Gigantesque!",
	},
	SHARK_GILLS = "It won't be needing these anymore.",
	LEIF_PALM = "Let us not do anything we will regret, uh... sir...",
	OBSIDIAN = "Hot rock!",
	BABYOX = "Worry not, mon chou, I've no interest in veal today.",
	STUNGRAY = "Ew, smells like its insides have gone bad.",
	SHARK_FIN = "This looks rather bland.",
	FROG_POISON = "A poison hopper.",
	BOAT_ARMOURED = "I am comforted by its seaworthiness.",
	ARMOROBSIDIAN = "Heavy and hot.",
	BIOLUMINESCENCE = "Magnifique...",
	SPEAR_POISON = "It would make me sick to use this on good meat.",
	SPEAR_OBSIDIAN = "Pull the trigger and voila! Dinner is done!",
	SNAKEDEN =
	{
		BURNING = "Perhaps I could smoke a nice cutlet on it?",
		BURNT = "That smoky aroma always makes me hungry...",
		CHOPPED = "How divine! It has been de-vined.",
		GENERIC = "I do wish those were grapevines...",
	},
	TOUCAN = "You are all nose.",
	IA_MESSAGEBOTTLE = "I wonder if it is a secret menu?",
	SAND = "Lots of tiny, tiny stones.",
	SANDDUNE = "The sand has formed a small pile.",
	PEACOCK = "Pea-ka-boo!",
	VINE = "Not a single grape on it...",
	SUPERTELESCOPE = "I knew sharks had an exceptional sense of smell, but their vision!",
	SEAGULL = "I know you're just after my cooking.",
	SEAGULL_WATER = "I know you're just after my cooking.",
	PARROT = "I can't recall any parrot recipes...",
	ARMOR_LIFEJACKET = "Better safe than sorry.",
	WHALE_BUBBLES = "What the deuce?",
	EARRING = "Fancy.",
	ARMOR_WINDBREAKER = "While it is rude to break wind in public, I will make an exception.",
	SEAWEED_COOKED = "Could use toasted sesame seeds...",
	BOAT_CARGO = "For long distance hauls.",
	GASHAT = "Anything to keep poison out of my dinner!",
	ELEPHANTCACTUS = "A big prickly pickle.",
	DUG_ELEPHANTCACTUS = "Shall I bring it back to life?",
	ELEPHANTCACTUS_ACTIVE = "Sword plant!",
	ELEPHANTCACTUS_STUMP = "The pickle will fruit again.",
	SAIL_FEATHER = "I mostly want to pet it.",
	WALL_LIMESTONE_ITEM = "Citrus-infused walls!",
	JUNGLETREESEED = "Cute, no?",
	JUNGLETREESEED_SAPLING = "Even cuter than the seed!",
	VOLCANO = "Oh, this gets better and better...",
	IRONWIND = "Zoom zoom!",
	SEAWEED_DRIED = "Could use Tamari...",
	TELESCOPE = "To see how \"near\" I am to \"far\".",
	
	DOYDOY = "I see potential in this poultry.",
	DOYDOYBABY = "I should let it grow into more food.",
	DOYDOYEGG = "Hello, breakfast.",
	DOYDOYFEATHER = "A feather from my feathered friend.",
	DOYDOYNEST = "It will become tastier with time.",
	DOYDOYEGG_CRACKED = "Spoiled egg?",

	PALMTREE =
	{
		BURNING = "Au revoir, tree.",
		BURNT = "Crisp, no?",
		CHOPPED = "Sliced!",
		GENERIC = "A good leaning tree.",
	},
	PALMLEAF = "These would work well in tamales.",
	CHIMINEA = "I wonder if this could be converted into a pizza oven?",
	DOUBLE_UMBRELLAHAT = "Ridiculous! I want one.",
	CRAB = 
	{
		GENERIC = "Soon you will be a crabcake.",
		HIDDEN = "I can smell you, my sweet!",
	},
	TRAWLNET = "Ah! The life of a fisherman!",
	TRAWLNETDROPPED =
	{
		GENERIC = "I hope the sea obliges my net with worthy catches.",
		SOON = "It is definitely filling up.",
		SOONISH = "It is close to full.",
	},
	VOLCANO_EXIT = "I will not let the door hit me on the way out!",
	SHARX = "Don't eat me, I'm not properly seasoned!",
	SEASHELL = "There's nothing edible left inside.",
	MAGMAROCK = "This rocks.",
	MAGMAROCK_GOLD = "Wonder if I could harvest goldleaf from this?",
	CORAL_BRAIN = "Are these truly brain bits?",
	CORAL_BRAIN_ROCK = "Chewy rock, with a clever finish.",
	SHARKITTEN = "The veal of the sea.",
	SHARKITTENSPAWNER = 
	{
		GENERIC = "That seems like something I should steer clear of.",
		INACTIVE = "A pile of sand like any other.",
	},
	LIVINGJUNGLETREE = "Pardon, but are you sleeping?",
	WALLYINTRO_DEBRIS = "This leaves a bad taste in my mouth...",
	MERMFISHER = "You bring the sea with you.",
	PRIMEAPE = "You reek of mischief and other kinds of... reek.",
	PRIMEAPEBARREL = "Someone has a hoarding issue.",
	BARREL_GUNPOWDER = "Skull and cross bones is bad, yes?",
	PORTAL_SHIPWRECKED = "Looks too rickety to ride to someplace.",
	MARSH_PLANT_TROPICAL = "I wonder if it is edible.",
	PIKE_SKULL = "Yeeouch!",
	PALMLEAF_HUT = "The great indoors!",
	LOBSTER_DEAD = "One step closer to my mouth.",
	MERMHOUSE_FISHER = "Fisherfolk live here. I can smell it.",
	WILDBORE = "Does not look like a placid piggy.",
	PIRATEPACK = "This will straighten my back out.",
	TUNACAN = "Tuna, packed in oil!",
	MOSQUITOSACK_YELLOW = "Ugh! It can only be filled with one thing.",
	SANDBAGSMALL = "Helps keep my dry environment dry.",
	FLUP = "Ack! Away!",
	OCTOPUSCHEST = "Any cold drinks in there?",
	OCTOPUSKING = "Try not to think about his delicious tentacles...",
	GRASS_WATER = "Herbe at sea.",
	WILDBOREHOUSE = "How wild can they be if they live in houses?",
	TURF_SWAMP = "It's like an ingredient for the ground.",
	FLAMEGEYSER = "Watch that flame!",
	KNIGHTBOAT = "Cannon fire! Time to pirate.",
	MANGROVETREE_BURNT = "I'd say its current water content is zero.",
	TIDAL_PLANT = "Inedible.",
	WALL_LIMESTONE = "Zesty wall.",
	LOBSTER_DEAD_COOKED = "Could use garlic-butter...",
	BLUBBERSUIT = "Desperate times call for desperate attire.",
	BLOWDART_FLUP = "How considerate of that dead thing!",
	TURF_MEADOW = "It's like an ingredient for the ground.",
	TURF_VOLCANO = "It's like an ingredient for the ground.",
	SWEET_POTATO = "Starch never tasted so sweet.",
	SWEET_POTATO_COOKED = "Could use touch of curry and crème fraîche...",
	SWEET_POTATO_PLANTED = "Starch never tasted so sweet.",
	SWEET_POTATO_SEEDS = "People often confuse yams and sweet potatoes. They're very different!",
	BLUBBER = "This lard would feed a hungry fire!",
	TELEPORTATO_SW_BASE = "It leads somewhere. And that is what I am afraid of.",
	TELEPORTATO_SW_BOX = "\"This\" likely connects to a \"that.\"",
	TELEPORTATO_SW_CRANK = "Definitely for a cranking action of some kind.",
	TELEPORTATO_SW_POTATO = "This, I do not even...",
	TELEPORTATO_SW_RING = "One ring to teleport them all!",
	VOLCANOSTAFF = "One must be careful with this.",
	THATCHPACK = "Thatch you very much!",
	SHARK_TEETHHAT = "Look upon your king!",
	TURF_ASH = "It's like an ingredient for the ground.",
	BOAT_TORCH = "It's a light so I might \"sea\".",
	MANGROVETREE = "I wonder what its water content is?",
	HAIL_ICE = "Like icecubes.",
	FISH_TROPICAL = "Catch of today!",
	TIDALPOOL = "It traps snacks.",
	WHALE_WHITE = "I have seen the devil!",
	VOLCANO_SHRUB = "I wonder what it used to be?",
	ROCK_OBSIDIAN = "Blast! I cannot mine it!",
	ROCK_CHARCOAL = "Barbecued.",
	DRAGOONDEN = "I do not like these fellows one bit.",
	TWISTER = "Nature's blender!",
	TWISTER_SEAL = "I bet it's delicious, but I just don't have the heart to find out.",
	MAGIC_SEAL = "It's practically dripping with magicks.",
	WINDSTAFF = "Might make a good stirring stick.",
	WIND_CONCH = "Oh, how I'm homesick for conch snacks.",
	BUOY = "A beacon to light my way.", 
	TURF_SNAKESKIN = "It's like an ingredient for the ground.",
	ARMORCACTUS = "If the enemies are pricked half as much as I was making it, it's worth it.",
	BIGFISHINGROD = "A prime ingredient-catcher.",
	BOOK_METEOR = "There's not a single recipe to be found within.",
	BRAINJELLYHAT = "I can feel inspiration seeping into me! Wait, that's brain juice.",
	COCONUT_HALVED = "Delectable.",
	CRATE = "I hope a rations shipment lies within.",
	DEPLETED_BAMBOOTREE = "Perhaps one day it will return.",
	DEPLETED_BUSH_VINE = "It's all used up... for now.",
	DEPLETED_GRASS_WATER = "Will you recover soon, little tuft?",
	DOYDOYEGG_COOKED = "Bon appetit!",
	DRAGOONEGG = "What use is an egg that you cannot eat?",
	DRAGOONHEART = "It is lifeless, yet surprisingly hot to touch.",
	DRAGOONSPIT = "Dangerous and disgusting!",
	DUG_BUSH_VINE = "Now I can put it wherever I want.",
	-- FRESHFRUITCREPES = "Is this not a thing of beauty?",
	KRAKEN = "I can't take the heat! Get me out of this kitchen!",
	KRAKENCHEST = "What treasures do you hold?",
	KRAKEN_TENTACLE = "My poisons do nothing!",
	MAGMAROCK_FULL = "This rocks.",
	MAGMAROCK_GOLD_FULL = "Wonder if I could harvest goldleaf from this?",
	MONKEYBALL = "Seems like a waste of a good banana. Cute though.",
	-- MONSTERTARTARE = "This is a culinary abomination. I'm appalled.", --
	MUSSELBOUILLABAISE = "The artistry in this dish lifts my spirits.", --
	MYSTERYMEAT = "That can't possibly be edible.",
	OXHAT = "Much more waterproof than a chef's hat.",
	OX_FLUTE = "It plays a lilting tune.",
	OX_HORN = "A lovely souvenir from a once powerful beast.",
	PARROT_PIRATE = "Such an amiable creature. Friends?",
	PEG_LEG = "Why on earth do I have this?",
	PIRATEGHOST = "He may be a nice fellow, but I don't intend to find out.",
	SANDBAGSMALL_ITEM = "I'll need to set these up before they do anything.",
	SHADOWSKITTISH_WATER = "Oh dear.",
	SHIPWRECKED_ENTRANCE = "Bonjour!",
	SHIPWRECKED_EXIT = "Au revoir.",
	SAIL_SNAKESKIN = "Perhaps I'll sail to a land of spices.",
	SPEAR_LAUNCHER = "Now we're cooking!",
	SWEETPOTATOSOUFFLE = "Food that feeds the soul and nourishes the body.", --
	SWIMMINGHORROR = "No need to come any closer, sir.",
	TIGEREYE = "Well, it's edible.",
	TRINKET_IA_20 = "It looks expectant.",
	TRINKET_IA_21 = "I'm afraid I won't fit.",
	TRINKET_IA_22 = "Perfect for a candlelit dinner!",
	TURF_MAGMAFIELD = "It's like an ingredient for the ground.",
	TURF_TIDALMARSH = "It's like an ingredient for the ground.",
	VOLCANO_ALTAR_TOWER = "Mon dieu!",
	WATERYGRAVE = "Let's open her up.",
	WHALE_TRACK = "My quarry is near!",
	WILBUR_CROWN = "Finally, the recognition I deserve. Does it get any bigger?",
	WILDBOREHEAD = "Is someone making a gourmet jerky?",
	BOAT_WOODLEGS = "Is that as fast as it goes?",
	WOODLEGSHAT = "It makes me feel... dangerous.",
	SAIL_WOODLEGS = "I'm ready to set sail!",
	SHIPWRECK = "It sails no more.",
	INVENTORYGRAVE = "Here's hoping the next life treats you better.",
	INVENTORYMOUND = "Here's hoping the next life treats you better.",
	LIMPETS_COOKED = "Smooth, salty, scrumptious.",
	RAWLING = "Your hair needs a brushing.",

	CHESSPIECE_KRAKEN = "Calamari with a lemon squeeze, anyone?",
	--CHESSPIECE_TIGERSHARK = "TEMP, put something here",
	--CHESSPIECE_TWISTER = "TEMP, put something here",
	--CHESSPIECE_SEAL = "TEMP, put something here",
	},
--[[
	DESCRIBE_GENERIC = "It is what it is...",
	DESCRIBE_SMOLDERING = "I fear that that is about to cook itself.",
	DESCRIBE_TOODARK = "I cannot see a thing!",
    EAT_FOOD =
	{
		TALLBIRDEGG_CRACKED = "Fresh! Err... perhaps too fresh.",
	},
]]
	WARN_SAME_OLD =
	{ --when inspecting food that already has an active Repeat Meal Penalty
		"I'd rather have something different today.",
		"The taste still lingers on my tongue.",
		"My palette desperately needs more variety.",
	},
}
