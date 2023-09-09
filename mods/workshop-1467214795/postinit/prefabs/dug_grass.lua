local IAENV = env
GLOBAL.setfenv(1, GLOBAL)
----------------------------------------------------------------------------------------

local VISUALVARIANT_PREFABS = require("prefabs/visualvariant_defs").VISUALVARIANT_PREFABS

-- gotta overwrite this for hamlets tall grass anyway :/
local function ondeploy(inst, pt, deployer)
    local tree = SpawnPrefab("grass")
    if tree ~= nil then
        tree.Transform:SetPosition(pt:Get())
        inst.components.stackable:Get():Remove()
        if tree.components.pickable ~= nil then
            tree.components.pickable:OnTransplant()
        end
        if tree.components.visualvariant then
            tree.components.visualvariant:CopyOf(inst)
        end
        if deployer ~= nil and deployer.SoundEmitter ~= nil then
            --V2C: WHY?!! because many of the plantables don't
            --     have SoundEmitter, and we don't want to add
            --     one just for this sound!
            deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
        end
    end
end

local function fn(inst)

    if not TheWorld.ismastersim then
        return inst
    end

    if inst.components.deployable ~= nil then
        inst.components.deployable.ondeploy = ondeploy
    end
    
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("dug_grass", fn)
