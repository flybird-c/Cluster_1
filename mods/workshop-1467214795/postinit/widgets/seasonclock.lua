local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

-----------------------------------------------------------------------------------------


---------------------------------copy from Combined Status-------------------------------
local COLOURS =
{
	AUTUMN = Vector3(205 / 255, 79 / 255, 57 / 255),
	WINTER = Vector3(149 / 255, 191 / 255, 242 / 255),
	SPRING = Vector3(84 / 168, 200 / 255, 84 / 255),
	SUMMER = Vector3(255 / 255, 206 / 255, 139 / 255),
}

local IA_COLOURS =
{
	AUTUMN =  Vector3(255 / 255, 206 / 255, 139 / 255),     -- Mild
	WINTER = Vector3(149 / 255, 191 / 255, 242 / 255),		-- Hurricane
	SPRING = Vector3(84 / 168, 200 / 255, 84 / 255),		-- Monsoon
	SUMMER = Vector3(205 / 255, 79 / 255, 57 / 255),		-- Dry
}
-----------------------------------------------------------------------------------------

local function ChangeSeasonClock(inst)
    local seasonclock = inst.HUD.controls.seasonclock

    if IsInIAClimate(inst) then
        STRINGS.UI.SERVERLISTINGSCREEN.SEASONS = STRINGS.UI.SERVERLISTINGSCREEN.IA_SEASONS

        UpvalueHacker.SetUpvalue(seasonclock.OnSeasonLengthsChanged, IA_COLOURS, "COLOURS")
    else
        STRINGS.UI.SERVERLISTINGSCREEN.SEASONS = STRINGS.UI.SERVERLISTINGSCREEN.DST_SEASONS

        UpvalueHacker.SetUpvalue(seasonclock.OnSeasonLengthsChanged, COLOURS, "COLOURS")
    end

    inst.HUD.controls.seasonclock:OnSeasonLengthsChanged()
end

local function pcallChangeSeasonClock(inst)
    local success = pcall(ChangeSeasonClock, inst)  -- considering som theme mod maybe change season clock, use pcall protect  -- Jerry
    if not success then
        print("change season clock fail")
    end
end

IAENV.AddPlayerPostInit(function(inst)
    if not TheNet:IsDedicated() then
        inst:DoTaskInTime(0, function()
            if inst ~= ThePlayer then
                return
            end

            if inst.HUD.controls.seasonclock then  -- if player turn on Combined Status
                inst:ListenForEvent("climatechange", pcallChangeSeasonClock)
                pcallChangeSeasonClock(inst)
            end
        end)
    end
end)

