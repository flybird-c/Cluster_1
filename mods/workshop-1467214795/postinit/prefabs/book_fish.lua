local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local _onread = nil
local function onread(inst, reader, ...)
	if IsInIAClimate(reader) then
		local FISH_SPAWN_OFFSET = 12
		local x, y, z = reader.Transform:GetWorldPosition()
		local delta_theta = PI2 / 18
		local failed_spawn = false
		local theta = math.random() * 2 * PI
		local failed_attempts = 0
		local max_failed_attempts = 144
		while failed_attempts < max_failed_attempts do
			local spawn_offset = Vector3(math.random(1, 3), 0, math.random(1, 3))
			local spawn_point = Vector3(x + math.cos(theta) * FISH_SPAWN_OFFSET, 0, z + math.sin(theta) * FISH_SPAWN_OFFSET)
			spawn_point = spawn_point + spawn_offset
			local fitsforfish = IsSurroundedByWaterTile(spawn_point, nil, nil, 5)
			if not fitsforfish then
				theta = theta + delta_theta
				failed_attempts = failed_attempts + 1

				if failed_attempts >= max_failed_attempts then
					failed_spawn = true
				end
			else -- Success
				local shoal = SpawnPrefab("fishinhole")
				shoal.Transform:SetPosition(spawn_point:Get())
				shoal:DoTaskInTime(480, shoal.Remove)
				break
			end
		end

		if failed_spawn then
			return false, "NOWATERNEARBY"
		end

		return true
	else
		return _onread(inst, reader, ...)
	end
end


IAENV.AddPrefabPostInit("book_fish", function(inst)
    if not TheWorld.ismastersim then
        return
    end

	if not _onread then
		_onread = inst.components.book.onread
	end
	inst.components.book:SetOnRead(onread)
end)
