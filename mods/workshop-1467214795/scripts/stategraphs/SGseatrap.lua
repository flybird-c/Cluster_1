local events =
{
    EventHandler("ondropped", function(inst)
        if inst.components.trap then
			if IsOnOcean(inst) then
				inst.components.trap:Set()
				inst.sg:GoToState("idle")
			else
				inst.sg:GoToState("idle_ground")
            end
        end
    end),
    EventHandler("onpickup", function(inst)
        if inst.components.trap ~= nil then
            inst.components.trap:Disarm()
        end
    end),
    EventHandler("harvesttrap", function(inst, data)
        if inst.components.trap ~= nil then
            inst.components.trap:Disarm(data ~= nil and data.sprung)
        end
    end),
}

local states =
{
	State{
		name = "idle_ground",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("idle")
		end,
	},

    State{
        name = "idle",
        onenter = function(inst)
			if inst.components.trap.bait then
				inst.AnimState:PlayAnimation("idle_baited", true)
			else
				inst.AnimState:PlayAnimation("idle_water", true)
			end
        end,

        events =
        {
            EventHandler("springtrap", function(inst, data)
                if data ~= nil and data.loading then
                    inst.sg:GoToState(inst.components.trap.lootprefabs ~= nil and "full" or "empty")
                elseif inst.entity:IsAwake() then
                    inst.sg:GoToState("sprung")
                else
                    inst.components.trap:DoSpring()
                    inst.sg:GoToState(inst.components.trap.lootprefabs ~= nil and "full" or "empty")
                end
            end),
			EventHandler("baited", function(inst)
				inst.AnimState:PlayAnimation("idle_baited", true)
			end),
        },
    },

    State{
        name = "full",
        onenter = function(inst, target)
            inst.AnimState:PlayAnimation("trap_loop", true)
            -- inst.SoundEmitter:PlaySound(inst.sounds.rustle)
        end,

        events =
        {
            EventHandler("harvesttrap", function(inst) inst.sg:GoToState("idle") end),
            -- EventHandler("animover", function(inst) inst.sg:GoToState("full") end),
        },
    },

    State{
        name = "empty",
        onenter = function(inst, target)
            inst.AnimState:PlayAnimation("side", true)
        end,

        events =
        {
            EventHandler("harvesttrap", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "sprung",
        onenter = function(inst, target)
			if inst.components.trap.bait then
				inst.AnimState:PlayAnimation("trap_baited_pre")
			else
				inst.AnimState:PlayAnimation("trap_pre")
			end
        end,

		timeline =
		{
			TimeEvent(13*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("ia/common/sea_trap/drop")
			end),
			TimeEvent(15*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("ia/common/sea_trap/ground_hit")
			end),
			TimeEvent(17*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound("ia/common/sea_trap/flag")
				inst.components.trap:DoSpring()
			end),
		},

        events =
        {
            EventHandler("animover", function(inst)
                -- inst.SoundEmitter:PlaySound(inst.sounds.close)
                -- inst.components.trap:DoSpring()
                inst.sg:GoToState(inst.components.trap.lootprefabs ~= nil and "full" or "empty")
            end),
        },
    },
}

return StateGraph("seatrap", states, events, "idle")
