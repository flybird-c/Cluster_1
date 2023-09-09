local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local nodebrisdmg
local function nodebrisdmg_ia(inst, amount, overtime, cause, ignore_invincible, afflicter, ...)
	return nodebrisdmg and nodebrisdmg(inst, amount, overtime, cause, ignore_invincible, afflicter, ...)
		or cause == "coconut" --might need afflicter tags in the future -M
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local function fn(inst)

    inst:AddTag("poisonimmune")

    if TheWorld.ismastersim then
        if inst.components.health then
            inst.components.health.poison_damage_scale = 0 -- immune to poison
            nodebrisdmg = inst.components.health.redirect
            inst.components.health.redirect = nodebrisdmg_ia
        end
    end
end

IAENV.AddPrefabPostInit("shadowworker", fn)
IAENV.AddPrefabPostInit("shadowprotector", fn)
