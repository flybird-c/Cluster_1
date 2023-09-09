local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local unpack = unpack

----------------------------------------------------------------------------------------
local Combat = require("components/combat")

function Combat:AddDamageModifier(key, mod)
    self.attack_damage_modifiers[key] = mod
end

function Combat:RemoveDamageModifier(key)
    self.attack_damage_modifiers[key] = nil
end

function Combat:GetDamageModifier()
    local mod = 1
    for k,v in pairs(self.attack_damage_modifiers) do
        mod = mod + v
    end
    return mod
end

function Combat:AddPeriodModifier(key, mod)
    self.attack_period_modifiers[key] = { mod = mod, effective = self.min_attack_period * mod }
    self:SetAttackPeriod(self.min_attack_period * (1+mod))
end

function Combat:RemovePeriodModifier(key)
    if not self.attack_damage_modifiers[key] then return end
    self:SetAttackPeriod(self.min_attack_period - self.attack_period_modifiers[key].effective)
    self.attack_period_modifiers[key] = nil
end

function Combat:GetIsAttackPoison(attacker)
    local poisonAttack = false 
    local poisonGasAttack = false 

    if self.inst:HasTag("poisonable") and attacker then 
        if (attacker.components.combat and attacker.components.combat.poisonous) or 
        ((attacker.components.poisonable and attacker.components.poisonable:IsPoisoned() and attacker.components.poisonable.transfer_poison_on_attack) 
        and (attacker.components.combat and not attacker.components.combat:GetWeapon())) then

            poisonAttack = true 

            if (attacker.components.combat and attacker.components.combat.poisonous and attacker.components.combat.gasattack) then 
                poisonGasAttack = true 
            end 
        end 
    end   

    return poisonAttack, poisonGasAttack
end

local _GetAttacked = Combat.GetAttacked
function Combat:GetAttacked(attacker, damage, weapon, stimuli, ...)
    local poisonAttack, poisonGasAttack = self:GetIsAttackPoison(attacker)

    if poisonGasAttack and self.inst.components.poisonable then 
        self.inst.components.poisonable:Poison(true)
        return
    end

    local blocked = false

    if TUNING.DO_SEA_DAMAGE_TO_BOAT and damage and (self.inst.components.sailor and self.inst.components.sailor.boat and self.inst.components.sailor.boat.components.boathealth) then
        local boathealth = self.inst.components.sailor.boat.components.boathealth
        if damage > 0 and not boathealth:IsInvincible() then
            boathealth:DoDelta(-damage, "combat", attacker and attacker.prefab or "NIL")
        else
            blocked = true
        end

        if not blocked then
            self.inst:PushEvent("boatattacked", {attacker = attacker, damage = damage, weapon = weapon, stimuli = stimuli, redirected=false})

            if self.onhitfn then
                self.onhitfn(self.inst, attacker, damage)
            end

            if attacker then
                attacker:PushEvent("onhitother", {target = self.inst, damage = damage, stimuli = stimuli, redirected=false})
                if attacker.components.combat and attacker.components.combat.onhitotherfn then
                    attacker.components.combat.onhitotherfn(attacker, self.inst, damage, stimuli)
                end
            end
        else
            self.inst:PushEvent("blocked", {attacker = attacker})
        end

        return not blocked
    end

    local rets = {_GetAttacked(self, attacker, damage, weapon, stimuli, ...)}

    if rets[1] and attacker and poisonAttack and self.inst.components and self.inst.components.poisonable then
        self.inst.components.poisonable:Poison()
    end

    return unpack(rets)
end

local _CalcDamage = Combat.CalcDamage
function Combat:CalcDamage(target, weapon, multiplier, ...)
    local rets = {_CalcDamage(self, target, weapon, multiplier, ...)}
    local bonus = self.damagebonus or 0 --not affected by multipliers

    rets[1] = (rets[1]-bonus) * self:GetDamageModifier() + bonus
    return unpack(rets)
end

local _CanAttack = Combat.CanAttack
function Combat:CanAttack(target, ...)
    local rets = {_CanAttack(self, target, ...)}
    if rets[1] then
        for i, v in ipairs(self.notags or {}) do
            if target:HasTag(v) then
                rets[1] = false
                break
            end
        end
    end
    return unpack(rets)
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local function onnotags(self, notags)
    self.inst.replica.combat.notags = notags
end

IAENV.AddComponentPostInit("combat", function(cmp)
    cmp.poisonstrength = 1

    cmp.poisonous = nil
    cmp.gasattack = nil

    cmp.attack_damage_modifiers = {} -- % modifiers on cmp:CalcDamage()
    cmp.attack_period_modifiers = {} -- % modifiers on cmp.min_attack_period

    addsetter(cmp, "notags", onnotags)
end)