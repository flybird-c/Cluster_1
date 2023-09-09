local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local function SetDestinationWorld(self, world)

    if self.inst.prefab == "cave_entrance_open" or self.inst.prefab == "cave_entrance" then
        world = IA_CONFIG.caveid or world
    elseif self.inst.prefab == "cave_exit" then
        world = IA_CONFIG.forestid or world
    end

	return world
end

local function fn(inst)
    if not TheWorld.ismastersim then
        return inst
    end

    local old_SetDestinationWorld = inst.components.worldmigrator.SetDestinationWorld
    inst.components.worldmigrator.SetDestinationWorld = function(self, world, permanent)
        world = SetDestinationWorld(self, world)
        old_SetDestinationWorld(self, world, permanent)
    end

end

IAENV.AddPrefabPostInit("cave_entrance_open",fn)
IAENV.AddPrefabPostInit("cave_entrance", fn)
IAENV.AddPrefabPostInit("cave_exit", fn)