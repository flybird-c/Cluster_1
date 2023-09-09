local function OnVolcanoAmbienceDirty(inst)
	if not ThePlayer then
		return
	end

	local player = ThePlayer
	if not player.ash then
		player.ash = SpawnPrefab("ashfx")
		player.ash.entity:SetParent(player.entity)
	end

	if player.ash then
		local ambience = IsInClimate(player, "volcano") and inst.replica.volcanoambience.ambience:value() or nil
		if ambience == "active" then
			player.ash.particles_per_tick = 6
		elseif ambience == "Dormant" then
			player.ash.particles_per_tick = 1
		else
			player.ash.particles_per_tick = 0
		end
	end
end

local function OnPlayerArriveVolcano(world, player)
	if player and player == ThePlayer then
		OnVolcanoAmbienceDirty(world.net)
	end
end

local VolcanoAmbience = Class(function(self, inst)
	self.inst = inst

	self.ambience = net_string(inst.GUID, "volcano.ambience", "volcanoambiencedirty")

	if not TheNet:IsDedicated() then
		inst:ListenForEvent("volcanoambiencedirty", OnVolcanoAmbienceDirty)
		inst:ListenForEvent("playerentered", OnPlayerArriveVolcano, TheWorld)
	end
end)

function VolcanoAmbience:SetVolcanoAmbience(ambience)
	if TheWorld.ismastersim then
		self.ambience:set(ambience)
	end
end

return VolcanoAmbience
