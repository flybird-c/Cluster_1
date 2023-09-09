local fx = GLOBAL.require("fx")

local function FinalOffset1(inst)
    inst.AnimState:SetFinalOffset(1)
end

local function FinalOffset2(inst)
    inst.AnimState:SetFinalOffset(2)
end

local function FinalOffset3(inst)
    inst.AnimState:SetFinalOffset(3)
end

local function TintOceantFx(inst)
	inst.AnimState:SetOceanBlendParams(TUNING.OCEAN_SHADER.EFFECT_TINT_AMOUNT)
end

local ia_fx = {
    {
    	name = "splash_water",
    	bank = "splash_water",
    	build = "splash_water",
        fn = TintOceantFx,
    	anim = "idle",
	},
    {
    	name = "splash_water_wave",
    	bank = "splash_water",
    	build = "splash_water",
        sound = "ia/common/waves/break",
        fn = TintOceantFx,
    	anim = "idle",
	},
    {
    	name = "splash_water_drop",
    	bank = "splash_water_drop",
    	build = "splash_water_drop",
        fn = TintOceantFx,
    	anim = "idle",
	},
	{
    	name = "splash_water_float",
    	bank = "splash_water_drop",
    	build = "splash_water_drop",
		sound = "ia/common/item_float",
        fn = TintOceantFx,
    	anim = "idle",
	},
	{
    	name = "splash_water_sink",
    	bank = "splash_water_drop",
    	build = "splash_water_drop",
		sound = "ia/common/item_sink",
        fn = TintOceantFx,
    	anim = "idle_sink",
	},
    {
    	name = "splash_water_big",
    	bank = "splash_water_big",
    	build = "splash_water_big",
        fn = TintOceantFx,
    	anim = "idle",
	},
	{
        name = "mining_charcoal_fx",
        bank = "mining_fx",
        build = "mining_fx",
        tint = GLOBAL.Vector3(74/255,93/255,90/255),
        anim = "anim",
    },
	{
        name = "mining_obsidian_fx",
        bank = "glass_mining_fx",
        build = "glass_mining_fx",
        tint = GLOBAL.Vector3(238/255,63/255,32/255),
		anim = "anim",
	},
	{
	    name = "hacking_fx", 
	    bank = "hacking_fx", 
	    build = "hacking_fx", 
	    anim = "idle",
    },
    {
	    name = "hacking_bamboo_fx", 
	    bank = "hacking_bamboo_fx", 
	    build = "hacking_bamboo_fx", 
	    anim = "idle",
    },
	{
	    name = "boat_hit_fx", --dummy fx data, not working quite yet
	    bank = "boat_hit_debris",
	    build = "boat_hit_debris",
	    anim = "hit_rowboat",
    },
	{
    	name = "boat_hit_fx_quackeringram",
	    bank = "boat_hit_debris",
	    build = "boat_hit_debris",
	    anim = "hit_raft_quackeringram",
    },
    {
    	name = "boat_hit_fx_raft_log",
	    bank = "boat_hit_debris",
	    build = "boat_hit_debris",
	    anim = "hit_raft_log",
    },
    {
    	name = "boat_hit_fx_raft_bamboo",
	    bank = "boat_hit_debris",
	    build = "boat_hit_debris",
	    anim = "hit_raft_bamboo",
    },
    {
    	name = "boat_hit_fx_rowboat",
	    bank = "boat_hit_debris",
	    build = "boat_hit_debris",
	    anim = "hit_rowboat",
    },
    {
    	name = "boat_hit_fx_cargoboat",
	    bank = "boat_hit_debris",
	    build = "boat_hit_debris",
	    anim = "hit_cargoboat",
    },
    {
    	name = "boat_hit_fx_armoured",
	    bank = "boat_hit_debris",
	    build = "boat_hit_debris",
	    anim = "hit_armoured",
    },
    {
    	name = "splash_footstep",
    	bank = "splash_footstep",
    	build = "splash_footstep",
    	anim = "anim",
	},
	{
    	name = "splash_footstep_small",
    	bank = "splash_footstep",
    	build = "splash_footstep",
    	anim = "anim",
		transform = GLOBAL.Vector3(0.5,0.5,0.5),
	},
	{
    	name = "splash_footstep_large",
    	bank = "splash_footstep",
    	build = "splash_footstep",
    	anim = "anim",
		transform = GLOBAL.Vector3(1.5,1.5,1.5),
	},
    {
    	name = "jungle_chop",
    	bank = "chop_jungle",
    	build = "chop_jungle",
    	anim = "chop",
	},
    {
    	name = "jungle_fall",
    	bank = "chop_jungle",
    	build = "chop_jungle",
    	anim = "fall",
	},
    {
    	name = "mangrove_chop",
    	bank = "chop_mangrove",
    	build = "chop_mangrove",
    	anim = "chop",
	},
    {
    	name = "mangrove_fall",
    	bank = "chop_mangrove",
    	build = "chop_mangrove",
    	anim = "fall",
	},
    {
		name = "splash_white_small",
    	bank = "bombsplash",
    	build = "water_bombsplash",
    	sound = "turnoftides/common/together/water/splash/small",
    	anim = "splash",
    	fn = function(inst) 
            inst.Transform:SetScale(0.25,0.25,0.25)
            FinalOffset1(inst) 
            TintOceantFx(inst) 
        end,
	},
	{
		name = "splash_white",
    	bank = "bombsplash",
    	build = "water_bombsplash",
    	sound = "turnoftides/common/together/water/splash/medium",
    	anim = "splash",
        fn = function(inst) 
            inst.Transform:SetScale(0.5,0.5,0.5)
            FinalOffset1(inst) 
            TintOceantFx(inst) 
        end,
	},
	{
		name = "splash_white_large",
    	bank = "bombsplash",
    	build = "water_bombsplash",
    	sound = "turnoftides/common/together/water/splash/large",
        fn = function(inst) 
            FinalOffset1(inst) 
            TintOceantFx(inst) 
        end,
    	anim = "splash",
	},
	{
		name = "bombsplash",
    	bank = "bombsplash",
    	build = "water_bombsplash",
        fn = TintOceantFx,
    	anim = "splash",
	},
	{
		name = "lava_bombsplash",
    	bank = "lava_bombsplash",
    	build = "lava_bombsplash",
        fn = TintOceantFx,
    	anim = "splash",
	},
	{
		name = "clouds_bombsplash",
    	bank = "clouds_bombsplash",
    	build = "clouds_bombsplash",
    	anim = "splash",
	},
    {
	    name = "explode_large",
	    bank = "explode_large",
	    build = "explode_large",
	    anim = "large",
        bloom = true,
		sound = "dontstarve/common/blackpowder_explo",
        fn = function(inst)
			inst.AnimState:SetLightOverride(1)
		end,
    },
    {
    	name = "explodering_fx",
    	bank = "explode_ring_fx",
    	build = "explode_ring_fx",
    	anim = "idle",
        fn = function(inst)
			inst.AnimState:SetFinalOffset(-1)
			inst.AnimState:SetOrientation( GLOBAL.ANIM_ORIENTATION.OnGround )
			inst.AnimState:SetLayer( GLOBAL.LAYER_BACKGROUND )
			inst.AnimState:SetSortOrder( -3 )
		end,
	},
	{
		name = "pixel_out",
    	bank = "pixels",
    	build = "pixel_fx",
    	anim = "out",
	},
	{
		name = "pixel_in",
    	bank = "pixels",
    	build = "pixel_fx",
    	anim = "in",
	},
    {
	    name = "small_puff_light", 
	    bank = "small_puff", 
	    build = "smoke_puff_small", 
	    anim = "puff",
	    sound = "dontstarve/common/deathpoof",
	    tintalpha = 0.5,
    },
    {
	    name = "coconut_chunks", 
	    bank = "ground_breaking", 
	    build = "ground_chunks_breaking", 
	    anim = "idle",
	    sound = "ia/creatures/palm_tree_guard/coconut_explode",
	    tint = GLOBAL.Vector3(183/255,143/255,85/255),
	},
	{
	    name = "poop_splat", 
	    bank = "ground_breaking", 
	    build = "ground_chunks_breaking", 
	    anim = "idle",
	    sound = "ia/common/poop_splat",
	    tint = GLOBAL.Vector3(183/255,143/255,85/255),
	},
	{
	    name = "banana_splat", 
	    bank = "ground_breaking", 
	    build = "ground_chunks_breaking", 
	    anim = "idle",
	    sound = "ia/common/poop_splat",
	    tint = GLOBAL.Vector3(229/255,215/255,78/255),
	},
	{
	    name = "smoke_out", 
	    bank = "smoke_out", 
	    build = "smoke_plants", 
	    anim = "smoke_loop",
	    --sound = "dontstarve/common/deathpoof",
	    --tintalpha = 0.5,
    },
    {
	    name = "shock_machines_fx", 
	    bank = "shock_machines_fx", 
	    build = "shock_machines_fx", 
	    anim = "shock",
	    sound = "ia/creatures/jellyfish/electric_land",
        fn = FinalOffset1,
	},
	{
		name = "feathers_packim_fire",
	    bank = "feathers_packim", 
	    build = "feathers_packim_fire", 
	    anim = "transform",
	},
	{
		name = "feathers_packim_fat",
	    bank = "feathers_packim", 
	    build = "feathers_packim", 
	    anim = "transform",
	},
	{
		name = "feathers_packim",
	    bank = "feathers_packim", 
	    build = "feathers_packim", 
	    anim = "transform",
	},
    {
	    name = "boat_death", 
	    bank = "boatdeathshadow", 
	    build = "boat_death_shadows", 
	    anim = "boat_death",
	    tintalpha = 0.5,
    },
    {
    	name = "dragoon_charge_fx",
    	bank = "fx",
    	build = "dragoon_charge_fx",
    	anim = "move",
	},
    {
    	name = "splash_lava_drop",
    	bank = "splash_lava_drop",
    	build = "splash_lava_drop",
    	anim = "idle_sink",
	},
    {
    	name = "splash_clouds_drop",
    	bank = "splash_clouds_drop",
    	build = "splash_clouds_drop",
    	anim = "idle_sink",
	},
    {
    	name = "kraken_ink_splat",
    	bank = "ink",
    	build = "ink_projectile",
    	anim = "splat",
	},
	{
		name = "lava_erupt",
		bank = "lava_erupt",
		build = "lava_erupt",
		anim = "idle",
		sound = "ia/common/volcano/rock_launch",
	},
	{
		name = "fx_book_meteor",
		bank = "lava_erupt",
		build = "lava_erupt",
		anim = "idle",
		sound = "ia/amb/volcano/lava_bubbling",
		transform = GLOBAL.Vector3(0.5,0.5,0.5), -- change scale
		fn = function(inst) 
			inst.AnimState:HideSymbol("rock02")
		end
	},
	{
		name = "lava_bubbling",
		bank = "lava_bubbling",
		build = "lava_erupt",
		anim = "idle",
		sound = "ia/amb/volcano/lava_bubbling",
	},
    {
    	name = "doydoy_mate_fx",
    	bank = "doydoy_mate_fx",
    	build = "doydoy_mate_fx",
		-- sound = "ia/creatures/doydoy/mating_voices_LP",
		-- sound2 = "ia/creatures/doydoy/mating_cloud_LP",
		transform = GLOBAL.Vector3(1.2,1.2,1.2),
    	anim = "mate_pre",
	    animqueue = true,
        fn = function(inst)
			inst.AnimState:SetSortOrder(1)
			inst.AnimState:PushAnimation("mate_loop")
			inst.AnimState:PushAnimation("mate_loop")
			inst.AnimState:PushAnimation("mate_loop")
			inst.AnimState:PushAnimation("mate_pst", false)
			inst.entity:AddSoundEmitter()
			inst.SoundEmitter:PlaySound("ia/creatures/doydoy/mating_voices_LP", "voices_LP")
			inst.SoundEmitter:PlaySound("ia/creatures/doydoy/mating_cloud_LP", "cloud_LP")
			inst:ListenForEvent("onremove", function()
				inst.SoundEmitter:KillAllSounds()
			end)
		end,
	},
    {
    	name = "windswirl",
    	bank = "wind_fx",
    	build = "wind_fx",
    	anim = "side_wind_loop",
	    autorotate = true,
	    nofaced = true,
        fn = function(inst)
			inst.AnimState:SetOrientation( GLOBAL.ANIM_ORIENTATION.OnGround )
			if GLOBAL.TheWorld.state.gustspeed < 0.01 then
				inst:Remove()
			else
				inst.AnimState:SetMultColour(1, 1, 1, GLOBAL.TheWorld.state.gustspeed)
			end
		end,
	},
    -- { --used by blowinwindgustitem, except this thing's invisible, so it'd just clog the network
    	-- name = "windtrail",
    	-- bank = "action_lines",
    	-- build = "action_lines",
    	-- anim = "idle_loop",
	    -- autorotate = true,
	    -- nofaced = true,
	-- },
}

if fx ~= nil then
    for k,v in pairs(ia_fx) do
        table.insert(fx, v)
        if GLOBAL.Settings.last_asset_set ~= nil then
            table.insert(Assets, Asset("ANIM", "anim/".. v.build ..".zip"))
        end
    end
end
