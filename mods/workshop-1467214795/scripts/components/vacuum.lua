--[[
Copyright (C) 2018 Island Adventures Team

This file is part of Island Adventures.

The source code of this program is shared under the RECEX
SHARED SOURCE LICENSE (version 1.0).
The source code is shared for referrence and academic purposes
with the hope that people can read and learn from it. This is not
Free and Open Source software, and code is not redistributable
without permission of the author. Read the RECEX SHARED
SOURCE LICENSE for details
The source codes does not come with any warranty including
the implied warranty of merchandise.
You should have received a copy of the RECEX SHARED SOURCE
LICENSE in the form of a LICENSE file in the root of the source
directory. If not, please refer to
<https://raw.githubusercontent.com/Recex/Licenses/master/SharedSourceLicense/LICENSE.txt>
]]

local Vacuum = Class(function(self, inst)
    self.inst = inst
    self.vacuumradius = 5
    self.vacuumspeed = 30
    self.consumeradius = 1
    self.noTags = {"FX", "NOCLICK", "DECOR", "INLIMBO", "CLASSIFIED", "STUMP", "BIRD", "NOVACUUM", "player", "irreplaceable", "backpack"}
    self.ignoreplayer = true
    self.playervacuumdamage = 50
    self.playervacuumsanityhit = 0
    self.playervacuumradius = 15
    self.player_hold_distance = 3
    self.spitplayer = false
    self.caught = {}
    self.allowmovement = {}
end)

function Vacuum:TurnOn()
    self.inst:StartUpdatingComponent(self)
end

function Vacuum:TurnOff()
    self.inst:StopUpdatingComponent(self)
end 

function Vacuum:ThrowOut_Player(player)
    local mult = self.playervacuumdamage / self.inst.components.combat.defaultdamage
    self.inst.components.combat:DoAttack(player, nil, nil, nil, mult)

    if not player.components.health:IsDead() then
        --prevent this tag from getting added if you die
        player:AddTag("NOVACUUM") --Shoot player out
        player.components.sanity:DoDelta(self.playervacuumsanityhit) --stupid sanity replica ughhh
    end

    self:LeaveVacuumState(player, true)

    player:PushEvent("vacuum_out", {speed = -self.vacuumspeed})
end

function Vacuum:Release_Held_Players()
    for player, value in pairs(self.caught) do
        if value and player.sg and player.sg:HasStateTag("vacuum_held") then
            self:ThrowOut_Player(player)
        end
    end
end

function Vacuum:SpitItem(item)
    if not item then
        local slot = math.random(1,self.inst.components.inventory:GetNumSlots())
        item = self.inst.components.inventory:DropItemBySlot(slot)
    end

    if item and item.Physics then
        local x, y, z = self.inst.Transform:GetWorldPosition()
        y = 2
        item.Physics:Teleport(x,y,z)
        item:AddTag("NOVACUUM")
        item:DoTaskInTime(2, function() item:RemoveTag("NOVACUUM") end)

		if item.components.inventoryitem then
			item.components.inventoryitem:SetLanded(false, true)
		end
 
        local speed = 8 + (math.random() * 4)
        local angle =  (math.random() * 360) * DEGREES
        item.Physics:SetVel(math.cos(angle) * speed, 10, math.sin(angle) * speed)
    end
end

local vacuumstate = {}
local RedirectSetMotorVel = {}

function EnterVacuumState(ent)
    vacuumstate[ent.Physics] = true
end

function LeaveVacuumState(ent)
    vacuumstate[ent.Physics] = nil
end

local _SetMotorVel = Physics.SetMotorVel
local _SetMotorVelOverride = Physics.SetMotorVelOverride
local _ClearMotorVelOverride = Physics.ClearMotorVelOverride
local _SetRotation = Physics.SetRotation

function Physics:SetMotorVel(...)
    if RedirectSetMotorVel[self] then
        return self:Real_SetMotorVelOverride(...)
    end
    if vacuumstate[self] then
        return nil
    end
    return _SetMotorVel(self, ...)
end

function Physics:Real_SetMotorVelOverride(...)
    --do this to prevent people from using Real_SetMotorVelOverride to bypass this.
    if not vacuumstate[self] then
        return nil
    end
    return _SetMotorVelOverride(self, ...)
end

function Physics:SetMotorVelOverride(...)
    if RedirectSetMotorVel[self] then
        return self:Real_SetMotorVelOverride(...)
    end
    if vacuumstate[self] then
        return nil
    end
    return _SetMotorVelOverride(self, ...)
end

function Physics:ClearMotorVelOverride(...)
    if vacuumstate[self] then
        return nil
    end
    return _ClearMotorVelOverride(self, ...)
end

function Physics:SetRotation(rotation, ...)
    --rotate the current momentum, so you dont do a weird.
    if vacuumstate[self] then
        local mx, my, mz = self:GetMotorVel()
        mx, mz = math.rotate(mx, mz, rotation - self:GetRotation())
        self:Real_SetMotorVelOverride(mx, my, mz)
    end
    return _SetRotation(self, rotation, ...)
end

function Vacuum:EnterVacuumState(player)
    print(player, "EnterVacuumState")
    --mark this player as getting vacuumed by this entity so other vacuums cant grab this entity.
    player.invacuum = self.inst
    EnterVacuumState(player)
    --mark player as caught.
    self.caught[player] = true
end

function Vacuum:LeaveVacuumState(player, partial)
    if IsOnOcean(player) then

    end
    print(player, "LeaveVacuumState")
    self.caught[player] = nil
    LeaveVacuumState(player)
    player.invacuum = nil
    if not partial then
        player:AddTag("NOVACUUM")
        player.Physics:SetMotorVel(0,0,0)
        if player.sg:HasStateTag("vacuum_in") then player.sg:GoToState("vacuumedland") end
        player:DoTaskInTime(5, function(inst) player:RemoveTag("NOVACUUM") end)
    end
end

function Vacuum:OnUpdate(dt)
    -- find entities within radius and vacuum them towards my location
    local pt = self.inst:GetPosition()
    local ents = TheSim:FindEntities(pt.x, 0, pt.z, self.consumeradius, nil, self.noTags)

    for k,v in pairs(ents) do
        if v and v.components.inventoryitem and not v.components.inventoryitem:IsHeld() and v.replica.inventoryitem:CanBePickedUp() then
            if not self.inst.components.inventory:GiveItem(v) then
                self:SpitItem(v)
            end
        end
    end

    ents = TheSim:FindEntities(pt.x, pt.y, pt.z, self.vacuumradius, nil, self.noTags)
    for k,v in pairs(ents) do
        if v and v.Physics and v.components.inventoryitem and not v.components.inventoryitem:IsHeld() and v.replica.inventoryitem:CanBePickedUp() and CheckLOSFromPoint(self.inst:GetPosition(), v:GetPosition()) then
            local x, y, z = v:GetPosition():Get()
            y = .1
            v.Physics:Teleport(x,y,z)
            local dir =  v:GetPosition() - self.inst:GetPosition()
            local angle = math.atan2(-dir.z, -dir.x)
            v.Physics:SetVel(math.cos(angle) * self.vacuumspeed, 0, math.sin(angle) * self.vacuumspeed)
        else
            v:AddTag("NOVACUUM")
            v:DoTaskInTime(1, function() v:RemoveTag("NOVACUUM") end)
        end
    end

    if not self.ignoreplayer or GetTableSize(self.caught) > 0 then
        for i, player in ipairs(AllPlayers) do
            if not player.replica.health:IsDead() and not player:HasTag("playerghost") then
                if player.invacuum == nil or player.invacuum == self.inst then
                    local playerpos = player:GetPosition()
                    local displacement = playerpos - self.inst:GetPosition()
                    local dist = displacement:Length()
                    local angle = math.atan2(-displacement.z, -displacement.x)
                    --Allow the player to get closer if they're wearing something with windproofness
                    local playerDistanceMultiplier =  1 - (player.components.inventory:GetWindproofness() * 0.25)
                    if dist < self.playervacuumradius * playerDistanceMultiplier then
                        local angle = math.atan2(-displacement.z, -displacement.x)

                        if not player:HasTag("NOVACUUM") and (player.components.rider == nil or not player.components.rider:IsRiding()) and (player.invacuum == self.inst or CheckLOSFromPoint(self.inst:GetPosition(), playerpos)) and (dist >= self.player_hold_distance or not self.caught[player]) and not self.spitplayer and not player.sg:HasStateTag("nointerupt") then--Pull player in
                            --print("trying to vacuum in the player")
                            if not self.caught[player] then
                                self:EnterVacuumState(player)
                            end

                            local rx, rz = math.rotate(math.rcos(angle) * self.vacuumspeed, math.rsin(angle) * self.vacuumspeed, math.rad(player.Transform:GetRotation()))

                            RedirectSetMotorVel[player.Physics] = true
                            player.Physics:Real_SetMotorVelOverride(rx, 0, rz)
                            RedirectSetMotorVel[player.Physics] = nil

                            player.components.locomotor:Clear()
                            player:PushEvent("vacuum_in")
                        elseif dist < self.player_hold_distance and self.caught[player] and player.sg and player.sg:HasStateTag("vacuum_in") and not self.spitplayer then
                            player.Physics:Real_SetMotorVelOverride(0, 0, 0)
                            player:PushEvent("vacuum_held")

                        elseif self.spitplayer and dist < self.player_hold_distance and player.sg and player.sg:HasStateTag("vacuum_held") then
                            self:ThrowOut_Player(player)

                        elseif self.spitplayer and self.caught[player] then
                            self:LeaveVacuumState(player)

                        end
                    elseif self.caught[player] then
                        self:LeaveVacuumState(player)
                    end
                end
            end
        end
    end

    self.spitplayer = false
end

return Vacuum
