--There are two functions that will install mods, ServerModSetup and ServerModCollectionSetup. Put the calls to the functions in this file and they will be executed on boot.

--ServerModSetup takes a string of a specific mod's Workshop id. It will download and install the mod to your mod directory on boot.
	--The Workshop id can be found at the end of the url to the mod's Workshop page.
	--Example: http://steamcommunity.com/sharedfiles/filedetails/?id=350811795
	--ServerModSetup("350811795")

--ServerModCollectionSetup takes a string of a specific mod's Workshop id. It will download all the mods in the collection and install them to the mod directory on boot.
	--The Workshop id can be found at the end of the url to the collection's Workshop page.
	--Example: http://steamcommunity.com/sharedfiles/filedetails/?id=379114180
	--ServerModCollectionSetup("379114180")
-- --  一秒5捡
-- ServerModSetup("850518166")
-- --  999堆叠
-- ServerModSetup("831523966")
-- --  防卡-改
-- ServerModSetup("2505341606")
-- --  5格装备
-- ServerModSetup("2373346252")
-- --  快速砍树
-- ServerModSetup("1751811434")
-- --  全球定位
-- ServerModSetup("378160973")
-- --  木牌传送
-- ServerModSetup("2119742489")
-- --  保温石无耐久
-- ServerModSetup("466732225")
-- --  Show Me(中文)
-- ServerModSetup("2287303119")
-- --  中文语言包
-- ServerModSetup("1301033176")
-- --  重生
-- ServerModSetup("1301033176")
--  海难api
ServerModSetup("1378549454")
--  海难
ServerModSetup("1467214795")
