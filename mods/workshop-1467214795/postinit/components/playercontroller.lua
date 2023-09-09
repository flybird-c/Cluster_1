local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local unpack = unpack

----------------------------------------------------------------------------------------
local PlayerController = require("components/playercontroller")

local _DoControllerUseItemOnSceneFromInvTile = PlayerController.DoControllerUseItemOnSceneFromInvTile
function PlayerController:DoControllerUseItemOnSceneFromInvTile(item, ...)
    local is_equipped = item ~= nil and item:IsValid() and item.replica.equippable and item.replica.equippable:IsEquipped()
    if is_equipped then
        self.inst.replica.inventory:ControllerUseItemOnSceneFromInvTile(item)
    else
        _DoControllerUseItemOnSceneFromInvTile(self, item, ...)
    end
end

local function GetImpassableGroundUseSpecialAction(self, position, right)
    if self.inst:HasTag("allow_special_point_action_on_impassable") then 
        position = position or
            (self.reticule ~= nil and self.reticule.targetpos) or
            (self.terraformer ~= nil and self.terraformer:GetPosition()) or
            (self.placer ~= nil and self.placer:GetPosition()) or
            (self.deployplacer ~= nil and self.deployplacer:GetPosition()) or
            self.inst:GetPosition()

        return CanEntitySeePoint(self.inst, position:Get())
            and not self.map:IsPassableAtPoint(position:Get())
            and self.inst.components.playeractionpicker:GetPointSpecialActions(position, nil, right)[1]
            or nil
    end
end

local _GetGroundUseSpecialAction = PlayerController.GetGroundUseSpecialAction
function PlayerController:GetGroundUseSpecialAction(position, right, ...)
    return GetImpassableGroundUseSpecialAction(self, position, right) or _GetGroundUseSpecialAction(self, position, right, ...)
end

local _GetGroundUseAction = PlayerController.GetGroundUseAction
function PlayerController:GetGroundUseAction(position, ...)
    if self.inst:IsSailing() then
        --Check if the player is close to land and facing towards it
        local angle = self.inst.Transform:GetRotation() * DEGREES
        local x, y, z = self.inst.Transform:GetWorldPosition()
        local target_x, target_z = VecUtil_Normalize(math.cos(angle), -math.sin(angle))
        target_x, target_z = 5 * target_x + x, 5 * target_z + z

        local can_hop, hop_x, hop_z, target_platform = self.inst.components.playeractionpicker:ScanForLandingPoint(target_x, target_z)
        if can_hop then
            return nil, BufferedAction(self.inst, nil, ACTIONS.DISEMBARK, nil, Vector3(hop_x, 0, hop_z))
        end
    end
    return _GetGroundUseAction(self, position, ...)
end

local _OnUpdate = PlayerController.OnUpdate
function PlayerController:OnUpdate(dt)
    local ret = {_OnUpdate(self, dt)}
    if self.inst:IsSailing() then
        --do automagic control repeats
        local isbusy = self:IsBusy()
        --#HACK for hopping prediction
        --ignore server "busy" if server still "boathopping" but we're not anymore
        if isbusy and self.inst.sg ~= nil and self.inst:HasTag("boathopping") and not self.inst.sg:HasStateTag("boathopping") then
            isbusy = false
        end
        local isenabled, ishudblocking = self:IsEnabled()
        if not ret[1] and isenabled and not (self.ismastersim and self.handler == nil and not self.inst.sg.mem.localchainattack) and (self.ismastersim or self.handler ~= nil)
            and not (self.directwalking or isbusy)
            and not (self.locomotor ~= nil and self.locomotor.bufferedaction ~= nil and self.locomotor.bufferedaction.action == ACTIONS.CASTAOE) then
            local attack_control = false
            if self.inst.sg ~= nil then
                attack_control = not self.inst.sg:HasStateTag("attack")
            else
                attack_control = not self.inst:HasTag("attack")
            end
            if attack_control and (self.inst.replica.combat == nil or not self.inst.replica.combat:InCooldown()) then
                attack_control = (self.handler == nil or not IsPaused())
                    and ((self:IsControlPressed(CONTROL_ATTACK) and CONTROL_ATTACK) or
                        (self:IsControlPressed(CONTROL_PRIMARY) and CONTROL_PRIMARY) or
                        (self:IsControlPressed(CONTROL_CONTROLLER_ATTACK) and not self:IsAOETargeting() and CONTROL_CONTROLLER_ATTACK))
                    or nil
                if attack_control ~= nil then
                    --Check for chain attacking first
                    local retarget = nil
                    local buffaction = self.inst:GetBufferedAction()
                    if buffaction and buffaction.action == ACTIONS.ATTACK then
                        retarget = buffaction.target
                    elseif self.inst.sg ~= nil then
                        retarget = self.inst.sg.statemem.attacktarget
                    elseif self.inst.replica.combat ~= nil then
                        retarget = self.inst.replica.combat:GetTarget()
                    end
                    if not (retarget and not IsEntityDead(retarget) and CanEntitySeeTarget(self.inst, retarget)) and self.handler ~= nil then
                    --elseif attack_control ~= CONTROL_PRIMARY and self.handler ~= nil then
                        --Check for starting a new attack, as long as the payer is not busy allow them to attack while on a boat, if the player is idle let the dst code handle it.
                        --this is to account for differences between dst and ds, allowing players to activate a held attack even while moving due to boat momentum

                        -- hmm dst changed this code.. maybe we should update it? - Half
                        local isidle
                        if self.inst.sg ~= nil then
                            isidle = self.inst.sg:HasStateTag("idle") or (self.inst:HasTag("idle") and self.inst:HasTag("nopredict"))
                        else
                            isidle = self.inst:HasTag("idle")
                        end
                        if not isidle then
                            -- Check for primary control button held down in order to attack other nearby monsters
                            if attack_control == CONTROL_PRIMARY and self.actionholding then
                                if self.ismastersim then
                                    self.attack_buffer = CONTROL_ATTACK
                                else
                                    self:DoAttackButton()
                                end
                            elseif not TheInput:IsControlPressed(CONTROL_PRIMARY) then
                                self:OnControl(attack_control, true)
                            end
                        end
                    end
                end
            end
        end
    end
    return unpack(ret)
end

local _GetPickupAction, _fn_i, scope_fn = UpvalueHacker.GetUpvalue(PlayerController.GetActionButtonAction, "GetPickupAction")
local function GetPickupAction(self, target, tool, ...)
    if not target:HasTag("smolder") and tool ~= nil then
        for k, v in pairs(TOOLACTIONS) do
            if target:HasTag(k.."_workable") then
                if tool:HasTag(k.."_tool") then
                    return ACTIONS[k]
                end
                -- break  Remove this break myself bc zarklord not respond to me _(:3」∠)_
            end
        end
    end
    local rets = {_GetPickupAction(self, target, tool)}
    if rets[1] == nil then
        if target.replica.inventoryitem ~= nil and
        target.replica.inventoryitem:CanBePickedUp() and
        not (target:HasTag("heavy") or (not target:HasTag("ignoreburning") and target:HasTag("fire")) or target:HasTag("catchable")) and not target:HasTag("spider") then
            rets[1] = (self:HasItemSlots() or target.replica.equippable ~= nil) and ACTIONS.PICKUP or nil
        end
    end
    return unpack(rets)
end
debug.setupvalue(scope_fn, _fn_i, GetPickupAction)

if not TheNet:IsDedicated() then
    local _IsVisible = Entity.IsVisible
    local function IsVisibleNotLocalNOCLICKed(self)
        return not IsLocalNOCLICKed(self) and _IsVisible(self)
    end

    local _UpdateControllerTargets, _fn_i, scope_fn = UpvalueHacker.GetUpvalue(PlayerController.UpdateControllerTargets, "UpdateControllerInteractionTarget")
    debug.setupvalue(scope_fn, _fn_i, function(self, ...)
        Entity.IsVisible = IsVisibleNotLocalNOCLICKed
        _UpdateControllerTargets(self, ...)
        Entity.IsVisible = _IsVisible
    end)
    --YEAH YEAH, this isn't a player controller post init, but it fits the theme of preventing selection of a entity on the client. -Z
    local _GetEntitiesAtScreenPoint = Sim.GetEntitiesAtScreenPoint
    function Sim:GetEntitiesAtScreenPoint(...)
        local entlist = {}
        for i, ent in ipairs(_GetEntitiesAtScreenPoint(self, ...)) do
            if not IsLocalNOCLICKed(ent) then
                entlist[#entlist + 1] = ent
            end
        end
        return entlist
    end
end

local _GetPickupAction = UpvalueHacker.GetUpvalue(PlayerController.GetActionButtonAction, "GetPickupAction")

if _GetPickupAction then
    local function GetPickupAction(self, target, tool, ...)
        local rets = {_GetPickupAction(self, target, tool, ...)}
        if rets[1] == ACTIONS.PICKUP and TheWorld.items_pass_ground and not TheWorld.Map:RunWithoutIACorners(target.IsOnPassablePoint, target) and self.inst:IsOnPassablePoint() then
            rets[1] = ACTIONS.RETRIEVE
        end
        return unpack(rets)
    end
    UpvalueHacker.SetUpvalue(PlayerController.GetActionButtonAction, GetPickupAction, "GetPickupAction")
end

-- Disable client prediction of the drop location because it messes with the boattoss rotation
-- Ideally syncing the rotation would be better but client prediction is just so broken when sailing I dont think it will work...
local _RemoteDropItemFromInvTile = PlayerController.RemoteDropItemFromInvTile
function PlayerController:RemoteDropItemFromInvTile(item, single, ...)
    if self.inst:IsSailing() then
        if not self.ismastersim then
            if self.locomotor == nil then
                -- NOTES(JBK): Does not call locomotor component functions needed for pre_action_cb, manual call here.
                if ACTIONS.DROP.pre_action_cb ~= nil then
                    ACTIONS.DROP.pre_action_cb(BufferedAction(self.inst, nil, ACTIONS.DROP, item))
                end
                SendRPCToServer(RPC.DropItemFromInvTile, item, single or nil)
            elseif self:CanLocomote() then
                local buffaction = BufferedAction(self.inst, nil, ACTIONS.DROP, item)
                buffaction.preview_cb = function()
                    SendRPCToServer(RPC.DropItemFromInvTile, item, single or nil)
                end
                buffaction.options.instant = self.inst.sg:HasStateTag("overridelocomote")
                self.locomotor:PreviewAction(buffaction, true)
            end
        end
    else
        return _RemoteDropItemFromInvTile(self, item, single, ...)
    end
end
