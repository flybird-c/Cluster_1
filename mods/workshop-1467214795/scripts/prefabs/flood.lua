--for networking entities sans actions (a lot less costly)
local AddNetworkProxy = UpvalueHacker.GetUpvalue(Entity.AddNetwork, "AddNetworkProxy")
if not AddNetworkProxy then
    AddNetworkProxy = Entity.AddNetwork
end

local COLUMNS = {}
for i = 1, 8 do
    COLUMNS[i] = 2^(i-1)
end

local function flood_row_factory_function(row)
    return function(inst)
        local row_value = inst.flood_rows[row]:value()

        local flood_x = inst.flood_x + row
        for column = 1, 8 do
            local flood_y = inst.flood_y + column
            local state = checkbit(row_value, COLUMNS[column])

            SetParticleTileState("flood", flood_x, flood_y, state)
        end
    end
end

local row_fns = {}
for i = 1, 8 do
    row_fns[i] = flood_row_factory_function(i)
end

local function RemoveFloods(inst)
    if not inst.flood_x then return end

    for x = 1, 8 do
        local flood_x = inst.flood_x + x
        for y = 1, 8 do
            local flood_y = inst.flood_y + y
            SetParticleTileState("flood", flood_x, flood_y, nil)
        end
    end
end

local function AddFloods(inst)
    if not inst.flood_x then return end

    for i = 1, 8 do
        inst:ListenForEvent("flood_rows["..i.."]dirty", row_fns[i])
        row_fns[i](inst)
    end
end

local function OnRemoveEntity(inst)
    if not inst:IsAsleep() then
        RemoveFloods(inst)
    end
end

local function OnEntitySleep(inst)
    RemoveFloods(inst)
    for i = 1, 8 do
        inst:RemoveEventCallback("flood_rows["..i.."]dirty", row_fns[i])
    end
end

local OnEntityWake = AddFloods

local function RegisterNetListeners(inst)
    local w_x, w_y, w_z = inst.Transform:GetWorldPosition()
    w_x, w_z = w_x - 1, w_z - 1
    inst.flood_x, inst.flood_y = TheWorld.components.flooding:GetFloodCoordsAtPoint(w_x, w_y, w_z)
    inst.flood_x, inst.flood_y = inst.flood_x - 4, inst.flood_y - 4

    if not inst:IsAsleep() then
        AddFloods(inst)
    end

    if TheWorld.ismastersim then
        inst.OnEntitySleep = OnEntitySleep
        inst.OnEntityWake = OnEntityWake
    end
end

local function SetFloodNetworkPosition(inst, x, y)
    local w_x, w_y, w_z = TheWorld.components.flooding:GetFloodCenterPoint(x * 8 + 3, y * 8 + 3)
    inst.Transform:SetPosition(w_x + 1, w_y, w_z + 1)
end

local function SetFloodState(inst, x, y, state)
    local row_value = inst.flood_rows[x]:value()
    if state then
        row_value = setbit(row_value, COLUMNS[y])
    else
        row_value = clearbit(row_value, COLUMNS[y])
    end
    inst.flood_rows[x]:set_local(row_value)
    inst.flood_rows[x]:set(row_value)
end

local function IsEmpty(inst)
    for i = 1, 8 do
        if inst.flood_rows[i]:value() > 0 then
            return false
        end
    end
    return true
end

local function network_fn()
    local inst = CreateEntity()

    AddNetworkProxy(inst.entity)
    inst.entity:AddTransform()

    inst:AddTag("CLASSIFIED")

    inst.persists = false

    inst.flood_rows = {}
    for i = 1, 8 do
        inst.flood_rows[i] = net_byte(inst.GUID, "inst.flood_rows["..i.."]", "flood_rows["..i.."]dirty")
    end

    if not TheNet:IsDedicated() then
        inst:DoTaskInTime(0, RegisterNetListeners)
        inst.OnRemoveEntity = OnRemoveEntity
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.SetFloodNetworkPosition = SetFloodNetworkPosition
    inst.SetFloodState = SetFloodState
    inst.IsEmpty = IsEmpty

    return inst
end

return Prefab("network_flood", network_fn)