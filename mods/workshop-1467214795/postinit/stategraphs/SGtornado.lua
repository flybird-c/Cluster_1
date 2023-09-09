local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local WORK_ACTIONS =
{
    HACK = true,
}

local TARGET_TAGS = {}
for k in pairs(WORK_ACTIONS) do
    table.insert(TARGET_TAGS, k .. "_workable")
end
local TARGET_IGNORE_TAGS = {"INLIMBO"}

local _destroystuff
local function destroystuff(inst, ...)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 3, nil, TARGET_IGNORE_TAGS, TARGET_TAGS)
    for i, v in ipairs(ents) do
        -- stuff might become invalid as we work or damage during iteration
        if v ~= inst.WINDSTAFF_CASTER and v:IsValid() then
            if v.components.hackable ~= nil and
                v.components.hackable:CanBeHacked() and
                WORK_ACTIONS.HACK then
                SpawnPrefab("collapse_small").Transform:SetPosition(v.Transform:GetWorldPosition())
                v.components.hackable:Hack(inst, 2)
                -- v.components.hackable:Destroy(inst)
            elseif (v.components.inventoryitem == nil
                or not v.components.inventoryitem:IsHeld()) and  -- Coconut fix -Half
                v.components.workable ~= nil and
                v.components.workable:CanBeWorked() and
                v.components.workable:GetWorkAction() and
                WORK_ACTIONS[v.components.workable:GetWorkAction().id] then
                SpawnPrefab("collapse_small").Transform:SetPosition(v.Transform:GetWorldPosition())
                v.components.workable:WorkedBy(inst, 2)
                -- v.components.workable:Destroy(inst)
            end
        end
    end
    if _destroystuff then _destroystuff(inst, ...) end
end

IAENV.AddStategraphPostInit("tornado", function(sg)
    if not TheWorld.ismastersim then
        return
    end

    if not _destroystuff then
        local _idle_onenter = sg.states["idle"].onenter
        _destroystuff = UpvalueHacker.GetUpvalue(_idle_onenter, "destroystuff")
        UpvalueHacker.SetUpvalue(_idle_onenter, destroystuff, "destroystuff")
    end
end)

