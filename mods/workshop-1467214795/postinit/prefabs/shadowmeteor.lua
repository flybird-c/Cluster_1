local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local SMASHABLE_WORK_ACTIONS =
{
	CHOP = true,
	DIG = true,
	HAMMER = true,
	MINE = true,
}
local SMASHABLE_TAGS = { "_combat", "_inventoryitem", "campfire" }
for k, v in pairs(SMASHABLE_WORK_ACTIONS) do
	table.insert(SMASHABLE_TAGS, k.."_workable")
end
local NON_SMASHABLE_TAGS = { "INLIMBO", "playerghost" }

local function beforeexplode(inst)
	if inst.striketask ~= nil then return print("Warning: Island Adventures could not check crashing meteor for water") end
	if not IsOnOcean(inst) then return end

	inst:CancelAllPendingTasks()

	if inst.warnshadow ~= nil then
		inst.warnshadow:Remove()
		inst.warnshadow = nil
	end
	-- inst:DoTaskInTime(.1, function(inst)
		-- if inst.striketask ~= nil then return end
		-- if not IsOnOcean(inst) then return end

		inst.SoundEmitter:PlaySound("dontstarve/common/meteor_impact")

		local shakeduration = .7 * inst.size
		local shakespeed = .02 * inst.size
		local shakescale = .5 * inst.size
		local shakemaxdist = 40 * inst.size
		ShakeAllCameras(CAMERASHAKE.FULL, shakeduration, shakespeed, shakescale, inst, shakemaxdist)

		local x, y, z = inst.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x, y, z, inst.size * TUNING.METEOR_RADIUS, nil, NON_SMASHABLE_TAGS, SMASHABLE_TAGS)
		for i, v in ipairs(ents) do
			--V2C: things "could" go invalid if something earlier in the list
			--     removes something later in the list.
			--     another problem is containers, occupiables, traps, etc.
			--     inconsistent behaviour with what happens to their contents
			--     also, make sure stuff in backpacks won't just get removed
			--     also, don't dig up spawners
			if v:IsValid() and not v:IsInLimbo() then
				if v.components.combat ~= nil then
					v.components.combat:GetAttacked(inst, inst.size * TUNING.METEOR_DAMAGE, nil)
				elseif v.components.boathealth ~= nil --only do boat damage if there is no sailor who re-routes his damage already
				and not (v.components.sailable and v.components.sailable.sailor) then
					v.components.boathealth:DoDelta(- inst.size * TUNING.METEOR_DAMAGE, "combat")
				elseif v.components.workable ~= nil then
					if v.components.workable:CanBeWorked() and not (v.sg ~= nil and v.sg:HasStateTag("busy")) then
						local work_action = v.components.workable:GetWorkAction()
						--V2C: nil action for campfires
						if (work_action == nil or SMASHABLE_WORK_ACTIONS[work_action.id]) and
							(work_action ~= ACTIONS.DIG
							or (v.components.spawner == nil and
								v.components.childspawner == nil)) then
							v.components.workable:WorkedBy(inst, inst.workdone or 20)
						end
					end
				elseif v.components.inventoryitem ~= nil then
					if v.components.container ~= nil then
						-- Spill backpack contents, but don't destroy backpack
						if math.random() <= TUNING.METEOR_SMASH_INVITEM_CHANCE then
							v.components.container:DropEverything()
						end
						Launch(v, inst, TUNING.LAUNCH_SPEED_SMALL)
					elseif v.components.mine ~= nil and not v.components.mine.inactive then
						-- Always smash things on the periphery so that we don't end up with a ring of flung loot
						v.components.mine:Deactivate()
						Launch(v, inst, TUNING.LAUNCH_SPEED_SMALL)
					-- elseif (inst.peripheral or math.random() <= TUNING.METEOR_SMASH_INVITEM_CHANCE)
						-- and not v:HasTag("irreplaceable") then
						-- -- Always smash things on the periphery so that we don't end up with a ring of flung loot
						-- local vx, vy, vz = v.Transform:GetWorldPosition()
						-- SpawnPrefab("ground_chunks_breaking").Transform:SetPosition(vx, 0, vz)
						-- v:Remove()
					else
						Launch(v, inst, TUNING.LAUNCH_SPEED_SMALL)
					end
				end
			end
		end

		--custom water stuff
		SpawnAt("splash_water_big",inst)
		inst:Remove()
	-- end)
end


----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("shadowmeteor", function(inst)


if TheWorld.ismastersim then

	--this triggers a split second before the actual onexplode, roughly when the meteor visually lands
	inst:DoTaskInTime(1.25, beforeexplode)

end


end)

