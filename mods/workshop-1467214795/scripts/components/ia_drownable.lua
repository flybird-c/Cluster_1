local unpack = unpack

----------------------------------------------------------------------------------------
local Drownable = require("components/drownable")

-- Turned into a seperate cmp that uses inheritance to be more readable
-- Also mobb said it was a good idea :/

local IA_Drownable = Class(Drownable, function(self, inst, ...)
    Drownable._ctor(self, inst, ...)
end)

-- Step 1: Initialize drowning
function IA_Drownable:OnFallInOcean(shore_x, shore_y, shore_z, ...)
    local rets = {Drownable.OnFallInOcean(self, shore_x, shore_y, shore_z, ...)}

    if self.inst.components.burnable then
        self.inst.components.burnable:Extinguish()
    end

    if self.inst:HasTag("player") and self.inst.sg and self.inst.sg:HasStateTag("drowning") then
        self.inst.sg:AddStateTag("temp_invincible")
        if self.inst.Transform then
            self.inst:DoTaskInTime(0, function(_inst)
                -- Prevents misjudges (like respawning over water)
                if self.inst.sg and self.inst.sg:HasStateTag("drowning") and not self.inst.sg:HasStateTag("jumping") then
                    SpawnAt("boat_death", self.inst)
                end
            end)
        end
    end

    return unpack(rets)
end

local function _should_drop_on_death(item, rescue_item)
    return item ~= nil and not item.components.inventoryitem.keepondeath and not item.components.curseditem and item ~= rescue_item
end

local function _should_drop_on_drown(item, rescue_item)
    return item ~= nil and not item:HasTag("irreplaceable") and not item.components.inventoryitem.keepondrown and item ~= rescue_item
end

-- Step 2: Drop items
function IA_Drownable:DropInventory(...)
    if not self:ShouldDrownToDeath() and not self:ShouldDropItems() then
		return
	end

	local inv = self.inst.components.inventory
	if inv ~= nil then
        local to_drop = {}

        local testitem = self:ShouldDrownToDeath() and _should_drop_on_death or _should_drop_on_drown
        local rescue_item = type(self.rescue_data) == "table" and self.rescue_data or nil
    
        for k = 1, inv.maxslots do
            local item = inv.itemslots[k]
            if testitem(item, rescue_item) then
                table.insert(to_drop, item)
            end
        end
    
        for k, item in pairs(inv.equipslots) do
            if testitem(item, rescue_item) then
                table.insert(to_drop, item)
            end
        end

        for i, item in pairs(to_drop) do
            Launch(inv:DropItem(item, true), self.inst, 2)
        end
	end
end

local function _spawn_log_raft_debris(pt)
    local debris = {}
    local crafting = GetValidRecipe("boat_lograft")
    if crafting ~= nil and crafting.ingredients ~= nil then
        for _, ingredient in pairs(crafting.ingredients) do
            for i = 1, ingredient.amount do
                table.insert(debris, SpawnPrefab(ingredient.type))
            end
        end
    end

    for i, item in pairs(debris) do
        local offset = FindWalkableOffset(pt, math.random()*2*PI, math.random()*2+2, 8)

        if offset then
            item.Transform:SetPosition((pt + offset):Get())
        else
            item.Transform:SetPosition(pt:Get())
        end

        item:Hide()
        item:DoTaskInTime(math.random()*3, function()
            item:Show()
            SpawnAt("sand_puff", item)
        end)
    end

    if not TheWorld.state.isday then
        local light = SpawnPrefab("spawnlight_multiplayer")
        light.Transform:SetPosition(pt.x, 0, pt.z)
    end
end

local function _player_oncameraarrive(inst)
    inst:SnapCamera()
end

local function _player_onarrive(inst)
    inst:ScreenFade(true, .4, false)
end

local function _oncameraarrive(inst)
    local drownable = inst.components.drownable
    drownable:Teleport()
end

local function _onarrive(inst)
	if inst.sg.statemem.teleportarrivestate ~= nil then
		inst.sg:GoToState(inst.sg.statemem.teleportarrivestate)
	end

    inst:PushEvent("on_washed_ashore")
end

-- Step 3: Stop drowning and decide the drownie's fate
function IA_Drownable:WashAshore(...)
    if self:ShouldDrownToDeath() then
        self:DrownToDeath()
    else
        if self.inst:HasTag("player") then
            _spawn_log_raft_debris(Point(self.dest_x, self.dest_y, self.dest_z))
            self.inst:ScreenFade(false, .4, false)
            self.inst:DoTaskInTime(3, _player_onarrive)
            self.inst:DoTaskInTime(3.4, _player_oncameraarrive)
        end
        self.inst:DoTaskInTime(3, _oncameraarrive)
        self.inst:DoTaskInTime(3.4, _onarrive)
    end
end

function IA_Drownable:ShouldDrownToDeath()
    return self.inst:HasTag("player")
        and self.inst.components.health ~= nil 
        and self.rescue_data == nil
        and GetGhostEnabled()
end

-- Step 3A: Death
function IA_Drownable:DrownToDeath()
    self.inst.components.health:DoDelta(-self.inst.components.health.currenthealth, nil, "drowning", true, nil, true)
end

return IA_Drownable