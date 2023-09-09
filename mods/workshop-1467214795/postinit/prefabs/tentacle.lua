local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local function quackify(inst)
	if IsOnOcean(inst) then
		--The animations are off, gotta make a custom bank if we want them on water. -M
		-- inst.AnimState:SetBank("quacken_tentacle")
		-- inst.AnimState:SetBuild("quacken_tentacle")
		inst:Remove()
	end
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("tentacle", function(inst)


	inst:DoTaskInTime(0, quackify)


end)
