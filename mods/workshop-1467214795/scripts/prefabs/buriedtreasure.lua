local assets =
{
    Asset("ANIM", "anim/x_marks_spot.zip"),
}

local prefabs =
{
	"ia_messagebottle",
	"collapse_small",
}

local function onfinishcallback(inst, worker)
    inst.MiniMapEntity:SetEnabled(false)
    inst:RemoveComponent("workable")
    --inst.components.hole.canbury = true

	if worker then
		-- figure out which side to drop the loot
		local pt = Vector3(inst.Transform:GetWorldPosition())
		local hispos = Vector3(worker.Transform:GetWorldPosition())

		local he_right = ((hispos - pt):Dot(TheCamera:GetRightVec()) > 0)

		if he_right then
			inst.components.lootdropper:DropLoot(pt - (TheCamera:GetRightVec()*(math.random()+1)))
			inst.components.lootdropper:DropLoot(pt - (TheCamera:GetRightVec()*(math.random()+1)))
		else
			inst.components.lootdropper:DropLoot(pt + (TheCamera:GetRightVec()*(math.random()+1)))
			inst.components.lootdropper:DropLoot(pt + (TheCamera:GetRightVec()*(math.random()+1)))
		end

		inst.SoundEmitter:PlaySound("ia/common/loot_reveal")

		if IsInClimate(inst, "island") then
			if IA_CONFIG.newloot == "all" and not c_findnext("moonrockseed") and math.random() < TheWorld.state.cycles/100 then
				inst.loot = "moonrockseed"
			end
			if IA_CONFIG.newloot ~= "vanilla" and (TheWorld.components.doydoyspawner.numdoydoys + c_countprefabs("doydoyegg")) < 2 and math.random() <= 0.33 then
				inst.loot = "doydoy"
			end
		end

		SpawnTreasureChest(inst.loot, inst.components.lootdropper, inst:GetPosition(), inst.treasurenext)
		inst:Remove()
	end
end

local function OnSave(inst, data)
    data.loot = inst.loot
	data.revealed = inst.revealed
end

local function OnLoad(inst, data)
    if data and data.loot then
        inst.loot = data.loot
		inst.revealed = data.revealed
    end

    if inst.revealed then
		inst:Reveal()
	end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddNetwork()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()

	inst:AddTag("buriedtreasure")
	inst:AddTag("NOCLICK")


	inst.MiniMapEntity:SetIcon("xspot.tex") -- red x for treasure bone x for pirate stash
	inst.MiniMapEntity:SetEnabled(false)

    inst.AnimState:SetBank("x_marks_spot")
    inst.AnimState:SetBuild("x_marks_spot")
    inst.AnimState:PlayAnimation("idle")

	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.entity:Hide()
    inst:AddComponent("inspectable")

    inst.components.inspectable.getstatus = function(inst)
        if not inst.components.workable then
            return "DUG"
        end
    end

	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onfinishcallback)

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"boneshard"})

    inst.loot = ""
    inst.revealed = false

    function inst:Reveal()
    	-- print("Treasure revealed")
    	inst.revealed = true
    	inst.entity:Show()
    	inst.MiniMapEntity:SetEnabled(true)
    	inst:RemoveTag("NOCLICK")
	end

	function inst:RevealFog(player)
		inst:DoTaskInTime(0, function()  -- Delay one frame for new treasure
			-- print("Tresure fog revealed")
			if player.player_classified and player.player_classified.MapExplorer then
				local x, y, z = inst.Transform:GetLocalPosition()
				player.player_classified.MapExplorer:RevealArea(x, 0, z)
			end
		end)
	end

	function inst:IsRevealed()
		return inst.revealed
	end

	function inst:SetRandomTreasure() --for luck hat
		inst:Reveal()
		local treasures = GetTreasureLootDefinitionTable()
		local treasure = GetRandomKey(treasures)
		inst.loot = treasure
	end

	function inst:SetRandomNewTreasure()
		inst:Reveal()
		local treasures = GetNewTreasures()
		local treasure = GetRandomKey(treasures)
		inst.loot = treasure
		if inst.loot == "moonrockseed" and IA_CONFIG.newloot ~= "vanilla" then
			inst.loot = "bananafarmer"
		end
		if inst.loot == "doydoy" and IA_CONFIG.newloot ~= "vanilla" then
			inst.loot = "reedfarmer"
		end
	end

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("buriedtreasure", fn, assets, prefabs)
