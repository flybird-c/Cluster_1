local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local unpack = unpack
local TileGroupManager = TileGroupManager

----------------------------------------------------------------------------------------
local Floater = require("components/floater")

function Floater:UpdateAnimations(water_anim, land_anim)
    self.wateranim = water_anim or self.wateranim
    self.landanim = land_anim or self.landanim
    self.no_float_fx = true

    if self.showing_effect then
        self:PlayWaterAnim()
    else
        self:PlayLandAnim()
    end
end

function Floater:PlayWaterAnim()
    if self.wateranim ~= nil then
        local anim = self.wateranim
        if type(self.wateranim) == "function" then
            anim = self.wateranim(self.inst)
        end
    
        if not self.inst.AnimState:IsCurrentAnimation(anim) then
            self.inst.AnimState:PlayAnimation(anim, true)
            self.inst.AnimState:SetTime(math.random())
        end
    
        self.inst.AnimState:OverrideSymbol("water_ripple", "ripple_build", "water_ripple")
        self.inst.AnimState:OverrideSymbol("water_shadow", "ripple_build", "water_shadow")
    end
end

function Floater:PlayLandAnim()
    if self.landanim ~= nil then
        local anim = self.landanim
        if type(self.landanim) == "function" then
            anim = self.landanim(self.inst)
        end

        if not self.inst.AnimState:IsCurrentAnimation(anim) then
            self.inst.AnimState:PlayAnimation(anim, true)
        end

        self.inst.AnimState:OverrideSymbol("water_ripple", "ripple_build", "water_ripple")
        self.inst.AnimState:OverrideSymbol("water_shadow", "ripple_build", "water_shadow")
    end
end

function Floater:PlayThrowAnim()
    if self.showing_effect then
        self:PlayWaterAnim()
    else
        self:PlayLandAnim()
    end

    self.inst.AnimState:ClearOverrideSymbol("water_ripple")
    self.inst.AnimState:ClearOverrideSymbol("water_shadow")
end

-- Other mods use the anim methods (for example skin mods) so we need to wrap them
local _SwitchToFloatAnim = Floater.SwitchToFloatAnim
function Floater:SwitchToFloatAnim(...)
    self:PlayWaterAnim()
    return _SwitchToFloatAnim(self, ...)
end

local _SwitchToDefaultAnim = Floater.SwitchToDefaultAnim
function Floater:SwitchToDefaultAnim(...)
    self:PlayLandAnim()
    return _SwitchToDefaultAnim(self, ...)
end

Floater.SwitchToThrowAnim = Floater.PlayThrowAnim

function Floater:PlaySplashFx(x, y, z)
    if self.splash and (not self.inst.components.inventoryitem or not self.inst.components.inventoryitem:IsHeld()) then
        -- The SW splash effect has a different and iconic sound
        local x, y, z = self.inst.Transform:GetWorldPosition()
        local splash = SpawnPrefab(TheWorld.has_ia_ocean and "splash_water_float" or "splash")
        splash.Transform:SetPosition(x, y, z)
    end
end

local _OnLandedServer = Floater.OnLandedServer
function Floater:OnLandedServer(...)
    local _showing_effect = self.showing_effect
    local _splash = self.splash
    self.splash = false

    local rets = {_OnLandedServer(self, ...)}
    if _showing_effect and not self:ShouldShowEffect() then

        self.inst:PushEvent("floater_stopfloating")
        self._is_landed:set(false)
        self.showing_effect = false

        self:SwitchToDefaultAnim()
    end

    self.splash = _splash
    if _showing_effect ~= self.showing_effect then
        if self.splash then
            self:PlaySplashFx()
        end
    end

    return unpack(rets)
end

local _ShouldShowEffect = Floater.ShouldShowEffect
function Floater:ShouldShowEffect(...)
	-- if not floating dont start floating on impassable tiles (lava)
    local _map = TheWorld.Map
    if not self.showing_effect then
        local pos_x, pos_y, pos_z = self.inst.Transform:GetWorldPosition()
        local tile = _map:GetTileAtPoint(pos_x, pos_y, pos_z) -- TODO: This may need to be modified for hamlet...
        if TileGroupManager:IsImpassableTile(tile) then
            return false
        end
    end

    return _map:RunWithoutIACorners(_ShouldShowEffect, self, ...)
end

local _OnLandedClient = Floater.OnLandedClient
function Floater:OnLandedClient(...)
	if not self.no_float_fx then
		return _OnLandedClient(self, ...)
    else
        self.showing_effect = true
	end
end

--The floater component is incredibly dumb. -M
local _IsFloating = Floater.IsFloating
function Floater:IsFloating(...)
	return _IsFloating(self, ...) and not (self.inst.replica.inventoryitem and self.inst.replica.inventoryitem:IsHeld())
end


----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local function OnHitLand(inst)
    --TODO add monkeyball onlanded bounce sounds
    --local bouncetime = inst.inventoryitem and inst.inventoryitem.bouncesound and inst.inventoryitem.bouncetime
    --if bouncetime then
    --    local vx, vy, vz = inst.Physics:GetVelocity()
    --    vy = vy or 0 --no idea if this even matters, but its in DS....
    --    if vy ~= 0 then
    --        if GetTime() - bouncetime > 0.15 then
    --            inst.SoundEmitter:PlaySound(self.bouncesound)
    --            inst.inventoryitem.bouncetime = GetTime()
    --        end
    --    end
    --end
end

local function OnHitWater(inst)
    local is_held = inst.components.inventoryitem and inst.components.inventoryitem:IsHeld()
    --don't do this if onload or if held (in the latter case, the floater cmp is being stupid and we should probably fix the excess callbacks)
    if not is_held and GetTime() > 1 then
        --don't forget to reject all the sharx drops here
        --don't spawn sharks if the item was boat tossed, this is to prevent abuse -half
        if IsInIAClimate(inst) and not inst:HasTag("spawnnosharx") and not inst:HasTag("monstermeat") and inst.components.edible and inst.components.edible.foodtype == FOODTYPE.MEAT then
            local roll = math.random()
            local chance = TUNING.SHARKBAIT_CROCODOG_SPAWN_MULT * inst.components.edible.hungervalue
            print(inst, "Testing for crocodog/sharx:", tostring(roll) .." < ".. tostring(chance), roll<chance)
            if roll < chance then
                if math.random() < TUNING.SHARKBAIT_SHARX_CHANCE then
                    TheWorld.components.hounded:SummonSpecialSpawn(inst:GetPosition(), "sharx", math.random(TUNING.SHARKBAIT_SHARX_MIN,TUNING.SHARKBAIT_SHARX_MAX))
                else
                    TheWorld.components.hounded:SummonSpecialSpawn(inst:GetPosition(), "crocodog")
                end
            end
        end
    end
end

IAENV.AddComponentPostInit("floater", function(cmp)
    --Maybe explicitly only install the cb on master? -M
    --yes, only install on mastersim. -Z
    if TheNet:GetIsMasterSimulation() then
        cmp.inst:ListenForEvent("floater_startfloating", OnHitWater)
        cmp.inst:ListenForEvent("floater_stopfloating", OnHitLand)
    end
end)
