local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local function makeanims(stage)
  return {
    idle="idle_"..stage,
    sway1="sway1_loop_"..stage,
    sway2="sway2_loop_"..stage,
    chop="chop_"..stage,
    fallleft="fallleft_"..stage,
    fallright="fallright_"..stage,
    stump="stump_"..stage,
    burning="burning_loop_"..stage,
    burnt="burnt_"..stage,
    chop_burnt="chop_burnt_"..stage,
    idle_chop_burnt="idle_chop_burnt_"..stage,
    blown1="blown_loop_"..stage.."1",
    blown2="blown_loop_"..stage.."2",
    blown_pre="blown_pre_"..stage,
    blown_pst="blown_pst_"..stage
  }
end

local SHORT = "short"
local NORMAL = "normal"
local TALL = "tall"

local anims = {
    [SHORT] = makeanims(SHORT),
    [TALL] = makeanims(TALL),
    [NORMAL] = makeanims(NORMAL),
}

local function push_sway(inst)
    local anim_to_play = (math.random() > .5 and anims[inst.size].sway1) or anims[inst.size].sway2
    inst.AnimState:PushAnimation(anim_to_play, true)
end

local function get_wind_anims(inst, type)
    local animlist = anims[inst.size]
	if type == 1 then
		local anim = math.random(1,2)
		return animlist["blown"..tostring(anim)]
	elseif type == 2 then
		return animlist.blown_pst
    elseif type == 3 then
        return animlist.blown_pre
	end
    return animlist[inst.size].idle
end

local function postinitfn(inst)
	if TheWorld.ismastersim then
		MakeTreeBlowInWindGust(inst, TUNING.PALMCONETREE_WINDBLOWN_SPEED, TUNING.PALMCONETREE_WINDBLOWN_FALL_CHANCE)
		inst.PushSway = push_sway
		inst.WindGetAnims = get_wind_anims
	end
end


----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("palmconetree", postinitfn)
