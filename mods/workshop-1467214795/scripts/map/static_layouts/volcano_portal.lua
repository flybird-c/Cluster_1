return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 2, --最大边界值
  height = 2, --最大边界值，一定要设置成正方形！
  tilewidth = 64,  --像素点，推荐64
  tileheight = 64, --像素点，推荐64
  properties = {},
  tilesets = {
    {
      name = "tiles",
      firstgid = 1,
      tilewidth = 64,   --像素点，推荐64
      tileheight = 64,  --像素点，推荐64
      spacing = 0,
      margin = 0,
      image = "../../../../tools/tiled/dont_starve/tiles.png",
      imagewidth = 510,   --不要动
      imageheight = 384,  --不要动
      properties = {},
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "BG_TILES",
      x = 0,
      y = 0,
      width = 2,  --最大边界值
      height = 2, --最大边界值
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        51, 51,
        51, 51,

      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "multiplayer_portal",
          shape = "rectangle",
          x = 64,
          y = 64,
          width = 64,
          height = 64,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "spawnpoint_master",
          shape = "rectangle",
          x = 64,
          y = 64,
          width = 64,
          height = 64,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
