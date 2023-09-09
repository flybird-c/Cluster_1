local assets =
{
    Asset("ANIM", "anim/ia_books.zip"),
    Asset("ANIM", "anim/swap_ia_books.zip"),
    --Asset("SOUND", "sound/common.fsb"),
}

local prefabs = -- this should really be broken up per book...
{
    "splash_ocean",
    "book_fx"
}



local book_defs =
{
    {
        name = "book_meteor",
        uses = TUNING.BOOK_USES_LARGE,
        fx = "fx_book_meteor",
        fn = function(inst, reader)
            local delay = 0.0
            for i = 1, TUNING.VOLCANOBOOK_FIRERAIN_COUNT, 1 do
                local pos = Vector3(reader.Transform:GetWorldPosition())
                local x, y, z = TUNING.VOLCANOBOOK_FIRERAIN_RADIUS * UnitRand() + pos.x, pos.y, TUNING.VOLCANOBOOK_FIRERAIN_RADIUS * UnitRand() + pos.z
                reader:DoTaskInTime(delay, function(inst)
                    local firerain = SpawnPrefab("firerain")
                    firerain.Transform:SetPosition(x, y, z)
                    firerain:StartStep()
                end)
                delay = delay + TUNING.VOLCANOBOOK_FIRERAIN_DELAY
            end
            return true
        end,
        perusefn = function(inst,reader)
            if reader.peruse_meteor then
                reader.peruse_meteor(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK","BOOK_METEOR"))
            return true
        end,
    },
}

local function MakeBook(def)
    local prefabs
    if def.deps ~= nil then
        prefabs = {}
        for i, v in ipairs(def.deps) do
            table.insert(prefabs, v)
        end
    end
    if def.fx ~= nil then
        prefabs = prefabs or {}
        table.insert(prefabs, def.fx)
    end
    if def.fxmount ~= nil then
        prefabs = prefabs or {}
        table.insert(prefabs, def.fxmount)
    end
    if def.fx_over ~= nil then
        prefabs = prefabs or {}
        local fx_over_prefab = "fx_"..def.fx_over.."_over_book"
        table.insert(prefabs, fx_over_prefab)
        table.insert(prefabs, fx_over_prefab.."_mount")
    end
    if def.fx_under ~= nil then
        prefabs = prefabs or {}
        local fx_under_prefab = "fx_"..def.fx_under.."_under_book"
        table.insert(prefabs, fx_under_prefab)
        table.insert(prefabs, fx_under_prefab.."_mount")
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("ia_books")
        inst.AnimState:SetBuild("ia_books")
        inst.AnimState:PlayAnimation(def.name)

        MakeInventoryFloatable(inst, "med", nil, 0.75)

        inst:AddTag("book")
        inst:AddTag("bookcabinet_item")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        -----------------------------------

        inst.def = def
        inst.swap_build = "swap_ia_books"
        inst.swap_prefix = def.name

        inst:AddComponent("inspectable")
        inst:AddComponent("book")
        inst.components.book:SetOnRead(def.fn)
        inst.components.book:SetOnPeruse(def.perusefn)
        inst.components.book:SetReadSanity(def.read_sanity)
        inst.components.book:SetPeruseSanity(def.peruse_sanity)
        inst.components.book:SetFx(def.fx, def.fxmount)

        inst:AddComponent("inventoryitem")

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(def.uses)
        inst.components.finiteuses:SetUses(def.uses)
        inst.components.finiteuses:SetOnFinished(inst.Remove)

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.MED_FUEL

        MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
        MakeSmallPropagator(inst)

        --MakeHauntableLaunchOrChangePrefab(inst, TUNING.HAUNT_CHANCE_OFTEN, TUNING.HAUNT_CHANCE_OCCASIONAL, nil, nil, morphlist)
        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab(def.name, fn, assets, prefabs)
end

local books = {}
for i, v in ipairs(book_defs) do
    table.insert(books, MakeBook(v))
end
book_defs = nil
return unpack(books)
