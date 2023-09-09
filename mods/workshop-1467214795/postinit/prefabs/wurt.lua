local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local function peruse_meteor(inst)
    inst.components.sanity:DoDelta(TUNING.SANITY_LARGE)
end

local function IARescue(inst)
    if TheWorld.has_ia_drowning then
        return "WURT_RESURRECT"
    end
end

local WARNING_MUST_TAGS = {"flup", "invisible"}
local function UpdateFlupWarnings(inst)
	local disable = (inst.replica.inventory ~= nil and not inst.replica.inventory:IsVisible())

	if not disable then
		local old_warnings = {}
		for t, w in pairs(inst._flup_active_warnings) do
			old_warnings[t] = w
		end

		local x, y, z = inst.Transform:GetWorldPosition()
		local warn_dist = 15
		local flups = TheSim:FindEntities(x, y, z, warn_dist, WARNING_MUST_TAGS)
		for i, t in ipairs(flups) do
			local p1x, p1y, p1z = inst.Transform:GetWorldPosition()
			local p2x, p2y, p2z = t.Transform:GetWorldPosition()
			local dist = VecUtil_Length(p1x - p2x, p1z - p2z)

			if not IsEntityDead(t, true) then
				if inst._flup_active_warnings[t] == nil then
					local fx = SpawnPrefab("wurt_tentacle_warning")
					fx.entity:SetParent(t.entity)
					inst._flup_active_warnings[t] = fx
				else
					old_warnings[t] = nil
				end
			end
		end

		for t, w in pairs(old_warnings) do
			inst._flup_active_warnings[t] = nil
			if w:IsValid() then
				ErodeAway(w, 0.5)
			end
		end
	elseif next(inst._flup_active_warnings) ~= nil then
		for t, w in pairs(inst._flup_active_warnings) do
			if w:IsValid() then
				w:Remove()
			end
		end
		inst._flup_active_warnings = {}
	end
end

local function DisableFlupWarning(inst)
	if inst.flup_warning_task ~= nil then
		inst.flup_warning_task:Cancel()
		inst.flup_warning_task = nil
	end

	for t, w in pairs(inst._flup_active_warnings) do
		if w:IsValid() then
			w:Remove()
		end
	end
	inst._flup_active_warnings = {}
end

local function EnableFlupWarning(inst)
	if inst.player_classified ~= nil then
		inst:ListenForEvent("playerdeactivated", DisableFlupWarning)
		if inst.flup_warning_task == nil then
			inst.flup_warning_task = inst:DoPeriodicTask(0.1, UpdateFlupWarnings)
		end
	else
	    inst:RemoveEventCallback("playeractivated", EnableFlupWarning)
	end
end

IAENV.AddPrefabPostInit("wurt", function(inst)

    if not TheNet:IsDedicated() and TheNet:GetServerGameMode() ~= "lavaarena" and TheNet:GetServerGameMode() ~= "quagmire" then
        inst._flup_active_warnings = {}
        inst:ListenForEvent("playeractivated", EnableFlupWarning)
	end


    if not TheWorld.ismastersim then
        return inst
    end 

    inst.components.itemaffinity:AddAffinity("packim_fishbone", nil, -TUNING.DAPPERNESS_MED, 2)

    inst.components.locomotor:SetFasterOnGroundTile(WORLD_TILES.TIDALMARSH, true)

    inst.components.foodaffinity:AddPrefabAffinity("seaweed", 1.33)

    inst.peruse_meteor = peruse_meteor

    if inst.components.drownable ~= nil then
        inst.components.drownable.fallback_rescuefn = IARescue
    end

end)
