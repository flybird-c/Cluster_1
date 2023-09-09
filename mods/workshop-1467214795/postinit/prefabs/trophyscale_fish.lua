local IAENV = env
GLOBAL.setfenv(1, GLOBAL)
--TODO, Hornet: I should tie tie this to the individual prefabs and have a "SetOnWeighted(inst, trophyscale)" function or something instead of doing it all here
local function SetFish(inst, item_data)
	if item_data then
		--Bank
		if item_data.prefab == "jellyfish" then
			inst.AnimState:SetBank("scale_o_matic_jellyfish")
		elseif item_data.prefab == "rainbowjellyfish" then
			inst.AnimState:SetBank("scale_o_matic_rainbowjellyfish")
		else
			inst.AnimState:SetBank("scale_o_matic")
		end

		--Light
		if item_data.prefab == "rainbowjellyfish" then
			local light = SpawnPrefab("rainbowjellylight")

			light.components.spell:SetTarget(inst)
			if light:IsValid() then
				if not light.components.spell.target then
					light:Remove()
				else
					light.components.spell:StartSpell()
					light:StopUpdatingComponent(light.components.spell) --Hornet: stinky, This is my hack to get an infinite "spell" since there isnt really functionality for that in the 'spell' component currently
				end
			end
		else
			if inst.rainbowjellylight then
				inst.rainbowjellylight.components.spell:OnFinish()
			end
		end
	end
end
----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------
local function onnewtrophy(inst, data_old_and_new)
	local data_new = data_old_and_new.new
	SetFish(inst, data_new)
end

local function fn(inst)

	if not TheWorld.ismastersim then
		return
	end

	local _OnLoad = inst.OnLoad
	inst.OnLoad = function(inst, ...)
		if inst.components.trophyscale ~= nil then
			local item_data = inst.components.trophyscale:GetItemData()
			SetFish(inst, item_data)
		end

		if _OnLoad ~= nil then
			_OnLoad(inst, ...)
		end
	end

	inst:ListenForEvent("onnewtrophy", onnewtrophy)
end

IAENV.AddPrefabPostInit("trophyscale_fish", fn)
