local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local function shrink(inst, time, startsize, endsize)
	inst.AnimState:SetMultColour(1,1,1,0.33)
	inst.Transform:SetScale(startsize, startsize, startsize)
	inst.components.colourtweener:StartTween({1,1,1,0.75}, time)
	inst.components.sizetweener:StartTween(.5, time, inst.Remove)
	inst.SoundEmitter:PlaySound("ia/common/bomb_fall")
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("warningshadow", function(inst)

inst.entity:AddSoundEmitter()

if TheWorld.ismastersim then

	inst.shrink = shrink
	
	inst:AddComponent("sizetweener")
	inst:AddComponent("colourtweener")
	
end


end)
