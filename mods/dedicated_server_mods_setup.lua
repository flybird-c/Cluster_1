--There are two functions that will install mods, ServerModSetup and ServerModCollectionSetup. Put the calls to the functions in this file and they will be executed on boot.

--ServerModSetup takes a string of a specific mod's Workshop id. It will download and install the mod to your mod directory on boot.
	--The Workshop id can be found at the end of the url to the mod's Workshop page.
	--Example: http://steamcommunity.com/sharedfiles/filedetails/?id=350811795
	--ServerModSetup("350811795")

--ServerModCollectionSetup takes a string of a specific mod's Workshop id. It will download all the mods in the collection and install them to the mod directory on boot.
	--The Workshop id can be found at the end of the url to the collection's Workshop page.
	--Example: http://steamcommunity.com/sharedfiles/filedetails/?id=379114180
	--ServerModCollectionSetup("379114180")
ServerModSetup("350811795")
ServerModSetup("1378549454")
ServerModSetup("1467214795")
ServerModSetup("1530801499")
ServerModSetup("1751811434")
ServerModSetup("2048852282")
ServerModSetup("2287303119")
ServerModSetup("2373346252")
ServerModSetup("2505341606")
ServerModSetup("2771698903")
ServerModSetup("378160973")
ServerModSetup("831523966")
ServerModSetup("850518166")
ServerModSetup("949808360")
