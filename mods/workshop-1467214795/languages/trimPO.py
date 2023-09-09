keywords = [
    #these get used (conditionally)
    "BOAT",
    "POTATO",
    "VOLCANO",
    "OTHER_WORLD",
    "MORETREASURE",
    "TRAWL",
    "WHALE",
    "PRIMEAPE",
    "SAIL",
    ".SEA",
    "_SW_",
    "MACHETE",
    "SWIMMING",
    "SPOILED_FISH",
    "SOLOFISH",
    "PACKIM",
    "TWISTER",
    "SEAL",
    "LOBSTER",
    "JELLY",
    "SNAKE",
    "CANNON",
    "CHIMINEA",
    "COCONUT",
    "COFFEE",
    "PALM",
    "CORAL",
    "CRAB",
    "CUTLASS",
    "BAMBOO",
    "VINE",
    "DOYDOY",
    "DUBLOON",
    "SLOTMACHINE",
    "FISHER",
    "SANDBAG",
    "NAMES.SAND",
    "DESCRIBE.SAND",
    ".TAR",
    "BOTTLE",
    "PIRAT", #removed the E because of PIRATIHATOR
    "CAPTAIN",
    "BRAIN",
    "POISON",
    "STUNGRAY",
    "SPEARGUN",
    "HAIL",
    "WINDBREAKER"
    "AERODYN",
    "SHARK",
    "SHARX",
    "CROC",
    "TOUCAN",
    "PARROT",
    "ANNOUNCE_TREASURE",
    "LIMESTONE",
    "FISHINHOLE",
    "THATCHPACK",
    "MANGROVE",
    "LIFEJACKET",
    ".OX",
    ".BABYOX",
    "ELEPHANTCACTUS",
    "BERMUDA",
    "_IA",
    "EMBARK",
    "SWORDFISH",
    "WATER",
    "VENOM",
    "FABRIC",
    "DOUBLE_UMBRELLA",
    "GASHAT",
    "LIMPET",
    "OBSIDIAN",
    "TIDAL",
    "BALLPHIN",
    "EARRING",
    "LIVINGJUNGLETREE",
    "TELESCOPE",
    "IA_TRIDENT",
    "TURBINE",
    "BEACH",
    "JUNGLE",
    "IRONWIND",
    "MUSSEL",
    "TROPIC",
    "ICEMAKER",
    "ROCK_CHARCOAL",
    "DRAGOON",
    "FLUP",
    "BLUBBER",
##    "FIRERAIN",
    "FISH_",
    "FLAMEGEYSER",
    "FRESHFRUITCREPES",
    "WALLY",
    "KRAKEN",
    "MAGMA",
    "MONSTERTARTARE",
    "MYSTERYMEAT",
    "NEEDLESPEAR",
    "OCTOPUS",
    "PEG_LEG",
    "COCONADE",
    "BURIEDTREASURE",
    "BARREL_GUNPOWDER",
    "SPEAR_LAUNCHER",
    "LUGGAGECHEST",
    "MOSQUITOSACK_YELLOW",
    "RAWLING",
    "TIGEREYE",
    "TUNACAN",
    "SHIPWRECK",
    "MEADOW",
    "BORE",
    "TURF_ASH",
    ".CRATE",
    "FLOTSAM",
    "BIOLUMINESCENCE",
    "MAPWRAP",
    "WAVE",
    "MERMNAMES",
    ".DESCEND",
    "RETRIEVE",
    "FISHOCEAN",
    "GIVE.LOAD",
    "GIVE.CURRENCY",
    ".HACK",
    ".LAUNCH",
    ".PEER",
    "PLANT.STOCK",
    "PLANTONGROWABLE",
    "READMAP",
    "REPAIRBOAT",
    "ROWTO",
    "SURF",
    "ACTIONS.STICK",
    "ACTIONS.THROW",
    "TRAVEL_SURVIVAL",
    "SANDBOXMENU.GREEN",
    "SANDBOXMENU.MILD",
    "SANDBOXMENU.DRY",
    "SANDBOXMENU.WET",
    "CUSTOMIZATIONSCREEN.NAMES.WET_SEASON",
    "CUSTOMIZATIONSCREEN.NAMES.MILD_SEASON",
    "CUSTOMIZATIONSCREEN.NAMES.GREEN_SEASON",
    "CUSTOMIZATIONSCREEN.NAMES.DRY_SEASON",
    "FLOOD",
    "TIDES",
    "SEALAB",
    "TALKINGBIRD",
    "NAUTICAL",
    "SHIPNAMES",
    "WIND_CONCH",
    "SPICEPACK",
    "SEA_", #the underscore is important (diSEAse, reSEArch)
    "_SEA",
    "QUACK",
    "NUBBIN",
    "FISH_FARM",
    "EUREKA",
    "BUOY",
    "BOOK_METEOR",
    "SEASHELL",
    "ARMORCACTUS",
    ".ROE",
    "CAVIAR",
    "PORTABLECOOKPOT",
    "HARPOON",
    "SAILOR",
    "PURPLE_GROUPER",
    "PIERROT_FISH",
    "NEON_QUATTRO",
    "DROWN",
    "DORSAL",
    "CORMORANT",
    "CEVICHE",
    "CALIFORNIAROLL",
    "BISQUE",
    "MERM_TALK",
]
killwords = [
    #these don't get used, even if they have keywords
##    "WILSON.",
##    "WILLOW.",
##    "WOLFGANG.",
##    "WENDY.",
##    "WX78.",
##    "WICKERBOTTOM.",
##    "WAXWELL.",
##    "WATHGRITHR.",
##    "WEBBER.",
    "WATERMELON", #water
	"TELEPORTATO", #potato I think
	"CRAWLING", #rawling -> crawling horror
	"DECID", #poison birchnut
	"MENU.CHAPTERS",
	"ADVENTURELEVEL",
]
forgivewords = [
    #these get used, even if they have killwords
    #use all clearly SW-exclusive ones here
    "WALANI",
    "WOODLEGS",
    "WILBUR",
    "WARLY",
    "walani",
    "woodlegs",
    "wilbur",
    "warly",
	"TELEPORTATO_SW",
]
synonyms = {
    "JUMPIN.ENTER":"JUMPIN.BERMUDA",
    ##"DISMOUNT":"DISEMBARK", #done by the next line
    "MOUNT":"EMBARK",
    "RUMMAGE.INSPECT":"INSPECTBOAT",
    "TRINKET_1":"TRINKET_IA_1",
    "TRINKET_2":"TRINKET_IA_2",
    "DEAD_SWORDFISH":"SWORDFISH_DEAD",
    "ROWBOAT":"BOAT_ROW",
    "CARGOBOAT":"BOAT_CARGO",
    "LOGRAFT":"BOAT_LOGRAFT",
    ".RAFT":".BOAT_RAFT",
    "ARMOUREDBOAT":"BOAT_ARMOURED",
    "ENCRUSTEDBOAT":"BOAT_ENCRUSTED",
    ".SAIL":".SAIL_PALM",
    "FEATHERSAIL":"SAIL_FEATHER",
    "CLOTHSAIL":"SAIL_CLOTH",
    "SNAKESKINSAIL":"SAIL_SNAKESKIN",
    ".TREEGUARD":".LEIF_PALM",
    ".LIMESTONE":".LIMESTONENUGGET",
    "SANDHILL":"SANDDUNE",
    "TROPICAL_FISH":"FISH_TROPICAL",
    "REDBARREL":"BARREL_GUNPOWDER",
    "WRECK":"SHIPWRECK",
    "WORLDGEN.NOUNS.SHIPWRECKED":"WORLDGEN_IA.NOUNS",
    "WORLDGEN.VERBS.SHIPWRECKED":"WORLDGEN_IA.VERBS",
    "RESEARCHLAB5":"SEA_LAB",
}

out = open("ia_fr.po", 'w')
src = open("fr.po", 'r')

skips = False

for line in src:
    if skips == True:
        if len(line) < 4:
            skips = False
        ##print("SKIPPING... " + line)
        continue
    for keyword in synonyms.keys():
        line.replace(keyword, synonyms[keyword])
    if line.find("#. STRINGS.") != -1:
        skips = True
        for keyword in keywords:
            if line.find(keyword) != -1:
                skips = False
                ##print("SKIPS0" + str(skips) + keyword)
                break
        for keyword in killwords:
            if line.find(keyword) != -1:
                skips = True
                ##print("SKIPS1" + str(skips) + keyword)
                break
        for keyword in forgivewords:
            if line.find(keyword) != -1:
                skips = False
                ##print("SKIPS2" + str(skips) + keyword)
                break
        ##print("SKIPS+" + str(skips))
    ##print("SKIPS-" + str(skips))
    if not skips:
        ##print("WRITING... " + line)
        out.write(line)

src.close()
out.close()
