local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local function onTalkParrot(inst)
	inst.SoundEmitter:PlaySound("ia/creatures/parrot/chirp", "talk")
end
local function doneTalkParrot(inst)
	inst.SoundEmitter:KillSound("talk")
end

local function AddParrot(inst)
    if not inst.components.talkingbird then
        inst:AddComponent("talkingbird")
    end
    if not inst.components.sanityaura then
        inst:AddComponent("sanityaura")
    end
    inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL
end

local function RemoveParrot(inst)
    if inst.components.talkingbird then
        inst:RemoveComponent("talkingbird")
    end
    if inst.components.sanityaura then
        inst:RemoveComponent("sanityaura")
    end
end

local function SanityAura(inst, viewer)
    local bird = inst.components.occupiable and inst.components.occupiable:GetOccupant()
    if bird and bird.prefab == "parrot_pirate" then
        return TUNING.SANITYAURA_SMALL
    end
    return 0
end

local Old_OnOccupied
local function New_OnOccupied(inst, item, ...)
    local bird = inst.components.occupiable and inst.components.occupiable:GetOccupant()
    if bird and bird.prefab == "parrot_pirate" then
        AddParrot(inst)
    end
    if Old_OnOccupied then
        Old_OnOccupied(inst, item, ...)
    end
end
local Old_OnEmptied
local function New_OnEmptied(inst, taker, item, ...)
    RemoveParrot(inst)
    if Old_OnEmptied then
        Old_OnEmptied(inst, taker, item, ...)
    end
end
local Old_OnBirdStarve
local function New_OnBirdStarve(inst, item, ...)
    RemoveParrot(inst)
    if Old_OnBirdStarve then
        Old_OnBirdStarve(inst, item, ...)
    end
end

local Old_OnGetShelfItem
local function New_OnGetShelfItem(inst, item, ...)
    Old_OnGetShelfItem(inst, item, ...)
    if inst.components.occupiable then
        inst.components.occupiable.onoccupied = New_OnOccupied
        inst.components.occupiable.onemptied = New_OnEmptied
        inst.components.occupiable.onperishfn = New_OnBirdStarve
    end
end
IAENV.AddPrefabPostInit("birdcage", function(inst)
    inst.AnimState:SetBank("ia_birdcage")  -- fix pirate parrot has no hat in its cage

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 28
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.colour = Vector3(.9, .4, .4, 1)
    inst:ListenForEvent("donetalking", doneTalkParrot)
    inst:ListenForEvent("ontalk", onTalkParrot)

    if not TheWorld.ismastersim then
        return inst
    end

    if inst.components.shelf then
        if not Old_OnGetShelfItem then
            Old_OnGetShelfItem = inst.components.shelf.onshelfitemfn
        end
        inst.components.shelf.onshelfitemfn = New_OnGetShelfItem
    end
    if inst.components.occupiable then
        if not Old_OnOccupied then
            Old_OnOccupied = inst.components.occupiable.onoccupied
        end
        if not Old_OnEmptied then
            Old_OnEmptied = inst.components.occupiable.onemptied
        end
        if not Old_OnBirdStarve then
            Old_OnBirdStarve = inst.components.occupiable.onperishfn
        end
        inst.components.occupiable.onoccupied = New_OnOccupied
        inst.components.occupiable.onemptied = New_OnEmptied
        inst.components.occupiable.onperishfn = New_OnBirdStarve
    end
end)
