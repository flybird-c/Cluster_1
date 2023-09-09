local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local floor = math.floor

----------------------------------------------------------------------------------------
local PlayerActionPicker = require("components/playeractionpicker")

--replacing the function twice, so logic doesnt need to get copy pasted -Z
local _GetLeftClickActions = PlayerActionPicker.GetLeftClickActions
local function __GetLeftClickActions(self, position, target, ...)
    if self.leftclickoverride ~= nil then
        local actions, usedefault = self.leftclickoverride(self.inst, target, position)
        if not usedefault or (actions ~= nil and #actions > 0) then
            return _GetLeftClickActions(self, position, target, ...)
        end
    end

    local actions = nil
    local useitem = self.inst.replica.inventory:GetActiveItem()
    local equipitem = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local boatitem = self.inst.replica.sailor and self.inst.replica.sailor:GetBoat() and self.inst.replica.sailor:GetBoat().replica.container and self.inst.replica.sailor:GetBoat().replica.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_LAMP)
    local ispassable = self.map:IsPassableAtPoint(position:Get())

    self.disable_right_click = false

    local steering_actions = self:GetSteeringActions(self.inst, position)
    if steering_actions ~= nil then
        -- self.disable_right_click = true
        return _GetLeftClickActions(self, position, target, ...)
    end

    local cannon_aim_actions = self:GetCannonAimActions(self.inst, position, false)
    if cannon_aim_actions ~= nil then
        return _GetLeftClickActions(self, position, target, ...)
    end

    --if we're specifically using an item, see if we can use it on the target entity
    if useitem ~= nil then
        return _GetLeftClickActions(self, position, target, ...)
    elseif target ~= nil and target ~= self.inst then
        --if we're clicking on a scene entity, see if we can use our equipped object on it, or just use it
        if self.inst.components.playercontroller:IsControlPressed(CONTROL_FORCE_INSPECT) and
            target:HasTag("inspectable") and
            (self.inst.CanExamine == nil or self.inst:CanExamine()) and
            (self.inst.sg == nil or self.inst.sg:HasStateTag("moving") or self.inst.sg:HasStateTag("idle") or self.inst.sg:HasStateTag("channeling")) and
            (self.inst:HasTag("moving") or self.inst:HasTag("idle") or self.inst:HasTag("channeling")) then
            return _GetLeftClickActions(self, position, target, ...)
        elseif self.inst.components.playercontroller:IsControlPressed(CONTROL_FORCE_ATTACK) and target.replica.combat ~= nil and self.inst.replica.combat:CanTarget(target) then
            return _GetLeftClickActions(self, position, target, ...)
        elseif equipitem ~= nil and equipitem:IsValid() and not boatitem then
            return _GetLeftClickActions(self, position, target, ...)
        elseif boatitem ~= nil and boatitem:IsValid() and not equipitem then
            actions = self:GetEquippedItemActions(target, boatitem)
        elseif equipitem ~= nil and equipitem:IsValid() and boatitem ~= nil and boatitem:IsValid() then
            local equip_act = self:GetEquippedItemActions(target, equipitem)

            if self.inst.components.playercontroller:IsControlPressed(CONTROL_FORCE_ATTACK) or GetTableSize(equip_act) == 0 then
                actions = self:GetEquippedItemActions(target, boatitem)
            end

            if not actions or (not self.inst.components.playercontroller:IsControlPressed(CONTROL_FORCE_ATTACK) and GetTableSize(equip_act) > 0) then
                return _GetLeftClickActions(self, position, target, ...)
            end
        end

        if actions == nil or #actions == 0 then
            return _GetLeftClickActions(self, position, target, ...)
        end
    end

    if actions == nil and target == nil and ispassable then
        if equipitem ~= nil and equipitem:IsValid() and not boatitem then
            return _GetLeftClickActions(self, position, target, ...)
        elseif boatitem ~= nil and boatitem:IsValid() and not equipitem then
            actions = self:GetPointActions(position, boatitem)
        elseif equipitem ~= nil and equipitem:IsValid() and boatitem ~= nil and boatitem:IsValid() then
            local equip_act = self:GetPointActions(position, equipitem)

            if self.inst.components.playercontroller:IsControlPressed(CONTROL_FORCE_ATTACK) or GetTableSize(equip_act) == 0 then
                actions = self:GetPointActions(position, boatitem)
            end

            if not actions or (not self.inst.components.playercontroller:IsControlPressed(CONTROL_FORCE_ATTACK) and GetTableSize(equip_act) > 0) then
                return _GetLeftClickActions(self, position, target, ...)
            end
        end
        --this is to make it so you don't auto-drop equipped items when you left click the ground. kinda ugly.
        if actions ~= nil then
            for i, v in ipairs(actions) do
                if v.action == ACTIONS.DROP then
                    table.remove(actions, i)
                    break
                end
            end
        end
        if actions == nil or #actions <= 0 then
            return _GetLeftClickActions(self, position, target, ...)
        end
    end

    return actions or {}
end

local _GetRightClickActions = PlayerActionPicker.GetRightClickActions
local function __GetRightClickActions(self, position, target, spellbook, ...)
    if self.disable_right_click then
        return _GetRightClickActions(self, position, target, spellbook, ...)
    end
    if self.rightclickoverride ~= nil then
        local actions, usedefault = self.rightclickoverride(self.inst, target, position)
        if not usedefault or (actions ~= nil and #actions > 0) then
            return _GetRightClickActions(self, position, target, spellbook, ...)
        end
    end

    local steering_actions = self:GetSteeringActions(self.inst, position, true)
    if steering_actions ~= nil then
        --self.disable_right_click = true
        return _GetRightClickActions(self, position, target, spellbook, ...)
    end

    local cannon_aim_actions = self:GetCannonAimActions(self.inst, position, true)
    if cannon_aim_actions ~= nil then
        return _GetRightClickActions(self, position, target, spellbook, ...)
    end

    local actions = nil
    local useitem = self.inst.replica.inventory:GetActiveItem()
    local equipitem = self.inst.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local boatitem = self.inst.replica.sailor and self.inst.replica.sailor:GetBoat() and self.inst.replica.sailor:GetBoat().replica.container and self.inst.replica.sailor:GetBoat().replica.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_LAMP)
    local ispassable = self.map:IsPassableAtPoint(position:Get())

    if target ~= nil and self.containers[target] then
        return _GetRightClickActions(self, position, target, spellbook, ...)
    elseif useitem ~= nil then
        return _GetRightClickActions(self, position, target, spellbook, ...)
    elseif target ~= nil and not target:HasTag("walkableplatform") then

        if equipitem ~= nil and equipitem:IsValid() and not boatitem then
            return _GetRightClickActions(self, position, target, spellbook, ...)
        elseif boatitem ~= nil and boatitem:IsValid() and not equipitem then
            actions = self:GetEquippedItemActions(target, boatitem, true)

            --strip out all other actions for weapons with right click special attacks
            if boatitem.components.aoetargeting ~= nil then
                return (#actions <= 0 or actions[1].action == ACTIONS.CASTAOE) and actions or {}
            end
        elseif equipitem ~= nil and equipitem:IsValid() and boatitem ~= nil and boatitem:IsValid() then
            local equip_act = self:GetEquippedItemActions(target, equipitem, true)

            if self.inst.components.playercontroller:IsControlPressed(CONTROL_FORCE_ATTACK) or GetTableSize(equip_act) == 0 then
                actions = self:GetEquippedItemActions(target, boatitem, true)
                --strip out all other actions for weapons with right click special attacks
                if boatitem.components.aoetargeting ~= nil then
                    return (#actions <= 0 or actions[1].action == ACTIONS.CASTAOE) and actions or {}
                end
            end

            if not actions or (not self.inst.components.playercontroller:IsControlPressed(CONTROL_FORCE_ATTACK) and GetTableSize(equip_act) > 0) then
                return _GetRightClickActions(self, position, target, spellbook, ...)
            end
        end

        if actions == nil or #actions == 0 then
            return _GetRightClickActions(self, position, target, spellbook, ...)
        end
    elseif spellbook then
        -- These use both right and left click so just leave it to the original code
        return _GetRightClickActions(self, position, target, spellbook, ...)
    elseif (equipitem ~= nil and equipitem:IsValid() and (ispassable or (equipitem and equipitem:HasTag("allow_action_on_impassable"))) or
        (boatitem ~= nil and boatitem:IsValid()) or
        ((equipitem ~= nil and equipitem.components.aoetargeting ~= nil and equipitem.components.aoetargeting.alwaysvalid and equipitem.components.aoetargeting:IsEnabled()) or
        (boatitem ~= nil and boatitem.components.aoetargeting ~= nil and boatitem.components.aoetargeting.alwaysvalid and boatitem.components.aoetargeting:IsEnabled()))) then
        --can we use our equipped item at the point?

        if (equipitem and equipitem:IsValid()) and not boatitem then
            return _GetRightClickActions(self, position, target, spellbook, ...)
        elseif (boatitem and boatitem:IsValid()) and not equipitem then
            actions = self:GetPointActions(position, boatitem, true, target)
        elseif (equipitem and equipitem:IsValid()) and (boatitem and boatitem:IsValid()) then
            local equip_act = self:GetPointActions(position, equipitem, true, target)

            if self.inst.components.playercontroller:IsControlPressed(CONTROL_FORCE_ATTACK) or GetTableSize(equip_act) == 0 then
                actions = self:GetPointActions(position, boatitem, true, target)
            end

            if not actions or (not self.inst.components.playercontroller:IsControlPressed(CONTROL_FORCE_ATTACK) and GetTableSize(equip_act) > 0) then
                return _GetRightClickActions(self, position, target, spellbook, ...)
            end
        end
    end
    if (actions == nil or #actions <= 0) and (target == nil or target:HasTag("walkableplatform")) then
        if ispassable then
            return _GetRightClickActions(self, position, target, spellbook, ...)
        elseif self.inst:HasTag("allow_special_point_action_on_impassable") then
            actions = self:GetPointSpecialActions(position, useitem, true)
        end
    end

    return actions or {}
end

-- Imrpoved quantize function that works with rot ocean
local function QuantizeLandingPosition(px, pz)
    px, pz = floor(px), floor(pz)
    if px % 2 == 1 then px = px + 1 end
    if pz % 2 == 1 then pz = pz + 1 end
    return px, pz
end

local LAND_SCAN_STEP_SIZE = 2
local WALL_TAGS = { "wall" }
function PlayerActionPicker:ScanForLandInDir(my_x, my_z, dir_x, dir_z, steps, step_size)
    for i = 0,steps do -- Initial position can have a quantized pos on land so start at 0
        local pt_x, pt_z = QuantizeLandingPosition(my_x + dir_x * i * step_size, my_z + dir_z * i * step_size)

        local is_land = self.map:IsVisualGroundAtPoint(pt_x, 0, pt_z)
        if is_land then
            --search for nearby walls and fences with active physics.
            for _, v in ipairs(TheSim:FindEntities(floor(pt_x), 0, floor(pt_z), 1, WALL_TAGS)) do
                if v ~= self.inst and
                v.entity:IsVisible() and
                v.components.placer == nil and
                v.entity:GetParent() == nil and
                v.Physics:IsActive() then
                    return false, 0, 0
                end
            end
            return true, pt_x, pt_z
        end
    end
    return false, 0, 0
end

local PLATFORM_SCAN_STEP_SIZE = 0.25
local PLATFORM_SCAN_RANGE = 1
function PlayerActionPicker:ScanForPlatformInDir(my_x, my_z, dir_x, dir_z, steps, step_size)
    for i = 1,steps do
        local pt_x, pt_z = my_x + dir_x * i * step_size, my_z + dir_z * i * step_size

        local platform = self.map:GetNearbyPlatformAtPoint(pt_x, 0, pt_z, -PLATFORM_SCAN_RANGE)
        if platform ~= nil then
            return true, pt_x, pt_z, platform
        end
    end
    return false, 0, 0
end

function PlayerActionPicker:ScanForLandingPoint(target_x, target_z)
    local my_x, my_y, my_z = self.inst.Transform:GetWorldPosition()
    local dir_x, dir_z = target_x - my_x, target_z - my_z
    local dir_length = VecUtil_Length(dir_x, dir_z)
    dir_x, dir_z = dir_x / dir_length, dir_z / dir_length

    local land_step_count = dir_length / LAND_SCAN_STEP_SIZE

    local can_hop, hop_x, hop_z = self:ScanForLandInDir(my_x, my_z, dir_x, dir_z, land_step_count, LAND_SCAN_STEP_SIZE)

    if can_hop then
        return can_hop, hop_x, hop_z, nil
    end

    local platform_step_count = (dir_length + PLATFORM_SCAN_RANGE) / PLATFORM_SCAN_STEP_SIZE

    return self:ScanForPlatformInDir(my_x, my_z, dir_x, dir_z, platform_step_count, PLATFORM_SCAN_STEP_SIZE)
end

function PlayerActionPicker:GetLeftClickActions(position, target, ...)
    local actions = __GetLeftClickActions(self, position, target, ...)

    if TheInput:ControllerAttached() then
        return actions
    end

    if (not actions or #actions == 0 or actions[1].action.replacewithdisembark) and self.inst:IsSailing() and self.map:IsPassableAtPoint(position.x, 0, position.z) then
        -- Find the landing position, where water meets the land
        local can_hop, hop_x, hop_z, target_platform = self:ScanForLandingPoint(position.x, position.z)
        if can_hop then
            actions = { BufferedAction(self.inst, nil, ACTIONS.DISEMBARK, nil, Vector3(hop_x, 0, hop_z)) }
        end
    end

    return actions or {}
end

function PlayerActionPicker:GetRightClickActions(position, target, ...)
    return __GetRightClickActions(self, position, target, ...)
end

local _SortActionList = PlayerActionPicker.SortActionList
function PlayerActionPicker:SortActionList(actions, target, ...)
    local ret = _SortActionList(self, actions, target, ...)

    for i, action in ipairs(ret) do
        if action.action == ACTIONS.DEPLOY and action.invobject.replica.inventoryitem then
            local deploydistance = action.invobject.replica.inventoryitem:GetDeployDist()
            if deploydistance ~= 0 then
                action.distance = deploydistance
            end
        end
    end

    return ret
end
