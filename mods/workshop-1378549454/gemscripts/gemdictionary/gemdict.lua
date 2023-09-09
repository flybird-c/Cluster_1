--[[
Copyright (C) 2020 Zarklord

This file is part of Gem Core.

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
gemrun("gemdictionary/ingredient")
gemrun("gemdictionary/recipe")
gemrun("gemdictionary/ui")
gemrun("gemdictionary/loot")
local IngredientAllocator = gemrun("gemdictionary/ingredientallocator")

local function crafting_priority_fn(a, b)
    if a.stacksize == b.stacksize then
        return a.slot < b.slot
    end
    return a.stacksize < b.stacksize --smaller stacks first
end

-- CONTAINER --
local Container = require("components/container")

function Container:FindCraftingItems(fn, reverse_search_order)
    local items = {}
    for i = 1, self.numslots do
        local v = self.slots[i]
        if v ~= nil and fn(v) then
            table.insert(items, {
                item = v,
                stacksize = GetStackSize(v),
                slot = reverse_search_order and (self.numslots - (i - 1)) or i,
            })
        end
    end
    table.sort(items, crafting_priority_fn)
    local crafting_items = {}
    for i, v in ipairs(items) do
        table.insert(crafting_items, v.item)
    end

    return crafting_items
end

local Container_Replica = require("components/container_replica")

function Container_Replica:FindCraftingItems(fn, reverse_search_order)
    if self.inst.components.container then
        return self.inst.components.container:FindCraftingItems(fn, reverse_search_order)
    elseif self.classified then
        return self.classified:FindCraftingItems(fn, reverse_search_order)
    else
        return {}
    end
end

local function FindCraftingItems_Container(inst, fn, reverse_search_order)
    local items = {}
    local numslots = #inst._items
    for i, v in ipairs(inst._items) do
        local item = (inst._itemspreview and inst._itemspreview[i]) or (not inst._itemspreview and v:value()) or nil
        if item ~= nil and fn(item) then
            table.insert(items, {
                item = item,
                stacksize = GetStackSize(item),
                slot = reverse_search_order and (numslots - (i - 1)) or i,
            })
        end
    end
    table.sort(items, crafting_priority_fn)
    local crafting_items = {}
    for i, v in ipairs(items) do
        table.insert(crafting_items, v.item)
    end

    return crafting_items
end

GEMENV.AddPrefabPostInit("container_classified", function(inst)
    if not TheWorld.ismastersim then
        inst.FindCraftingItems = FindCraftingItems_Container

        local SlotItem = UpvalueHacker.GetUpvalue(inst.ConsumeByName, "SlotItem")
        local PushItemLose = UpvalueHacker.GetUpvalue(inst.ConsumeByName, "PushItemLose")
        local PushStackSize = UpvalueHacker.GetUpvalue(inst.ConsumeByName, "PushStackSize")
        function inst.ConsumeByItem(inst, item, amount)
            if amount <= 0 then
                return
            end

            for i, v in ipairs(inst._items) do
                local _item = v:value()
                if _item == item then
                    local stacksize = item.replica.stackable ~= nil and item.replica.stackable:StackSize() or 1
                    if stacksize <= amount then
                        PushItemLose(inst, SlotItem(item, i))
                    else
                        PushStackSize(inst, nil, item, stacksize - amount, true)
                    end
                    return
                end
            end
        end
    end
end)
-- CONTAINER END --

-- INVENTORY --
local Inventory = require("components/inventory")

function Inventory:FindCraftingItems(fn)
    local overflow = self:GetOverflowContainer()
    local crafting_items = {}

    for container_inst in pairs(self.opencontainers) do
        local container = container_inst.components.container or container_inst.components.inventory
        if container and container ~= overflow and not container.excludefromcrafting and container.FindCraftingItems then
            for k, v in pairs(container:FindCraftingItems(fn, true)) do
                table.insert(crafting_items, v)
            end
        end
    end

    local items = {}
    for i = 1, self.maxslots do
        local v = self.itemslots[i]
        if v and fn(v) then
            table.insert(items, {
                item = v,
                stacksize = GetStackSize(v),
                slot = i,
            })
        end
    end
    table.sort(items, crafting_priority_fn)
    for i, v in ipairs(items) do
        table.insert(crafting_items, v.item)
    end

    if overflow and overflow.FindCraftingItems then
        for k, v in pairs(overflow:FindCraftingItems(fn)) do
            table.insert(crafting_items, v)
        end
    end

    if self.activeitem and fn(self.activeitem) then
        table.insert(crafting_items, self.activeitem)
    end

    return crafting_items
end

local Inventory_Replica = require("components/inventory_replica")

function Inventory_Replica:FindCraftingItems(fn)
    if self.inst.components.inventory then
        return self.inst.components.inventory:FindCraftingItems(fn)
    elseif self.classified then
        return self.classified:FindCraftingItems(fn)
    else
        return {}
    end
end

local function FindCraftingItems_Inventory(inst, fn)
    local overflow = inst:GetOverflowContainer()
    local crafting_items = {}


    local inventory_replica = inst and inst._parent and inst._parent.replica.inventory
    local containers = inventory_replica and inventory_replica:GetOpenContainers()

    if containers then
        for container_inst in pairs(containers) do
            local container = container_inst.replica.container or container_inst.replica.inventory
            if container and container ~= overflow and not container.excludefromcrafting and container.FindCraftingItems then
                for k, v in pairs(container:FindCraftingItems(fn, true)) do
                    table.insert(crafting_items, v)
                end
            end
        end
    end

    local items = {}
    for i, v in ipairs(inst._items) do
        local item = (inst._itemspreview and inst._itemspreview[i]) or (not inst._itemspreview and v:value()) or nil
        if item ~= nil and (inst._itemspreview ~= nil or item ~= inst._activeitem) and fn(item) then
            table.insert(items, {
                item = item,
                stacksize = GetStackSize(item),
                slot = i,
            })
        end
    end
    table.sort(items, crafting_priority_fn)
    for i, v in ipairs(items) do
        table.insert(crafting_items, v.item)
    end

    if overflow and overflow.FindCraftingItems then
        for k, v in pairs(overflow:FindCraftingItems(fn)) do
            table.insert(crafting_items, v)
        end
    end

    if inst._activeitem and fn(inst._activeitem) then
        table.insert(crafting_items, inst._activeitem)
    end

    return crafting_items
end

GEMENV.AddPrefabPostInit("inventory_classified", function(inst)
    if not TheWorld.ismastersim then
        inst.FindCraftingItems = FindCraftingItems_Inventory

        local SlotItem = UpvalueHacker.GetUpvalue(inst.RemoveIngredients, "ConsumeByName", "SlotItem")
        local PushItemLose = UpvalueHacker.GetUpvalue(inst.RemoveIngredients, "ConsumeByName", "PushItemLose")
        local PushStackSize = UpvalueHacker.GetUpvalue(inst.RemoveIngredients, "ConsumeByName", "PushStackSize")
        local PushNewActiveItem = UpvalueHacker.GetUpvalue(inst.RemoveIngredients, "ConsumeByName", "PushNewActiveItem")
        function inst.ConsumeByItem(inst, item, amount, overflow, containers)
            if amount <= 0 then
                return
            end

            for i, v in ipairs(inst._items) do
                local _item = v:value()
                if _item == item then
                    local stacksize = item.replica.stackable ~= nil and item.replica.stackable:StackSize() or 1
                    if stacksize <= amount then
                        PushItemLose(inst, SlotItem(item, i))
                    else
                        PushStackSize(inst, item, stacksize - amount, true)
                    end
                    return
                end
            end

            if inst._activeitem == item then
                local stacksize = inst._activeitem.replica.stackable ~= nil and inst._activeitem.replica.stackable:StackSize() or 1
                if stacksize <= amount then
                    PushNewActiveItem(inst)
                else
                    PushStackSize(inst, item, stacksize - amount, true)
                end
                return
            end

            if overflow ~= nil then
                overflow:ConsumeByItem(item, amount)
            end

            if containers then
                for container_inst in pairs(containers) do
                    local container = container_inst.replica.container or container_inst.replica.inventory
                    if container and container.classified and container.classified ~= overflow and not container.excludefromcrafting then
                        container.classified:ConsumeByItem(item, amount)
                    end
                end
            end
        end

        local _RemoveIngredients = inst.RemoveIngredients
        function inst.RemoveIngredients(inst, recipe, ingredientmod, ...)
            if inst:IsBusy() then
                return false
            end
            local overflow = inst:GetOverflowContainer()
            overflow = overflow and overflow.classified or nil
            if overflow ~= nil and overflow:IsBusy() then
                return false
            end

            local inventory_replica = inst and inst._parent and inst._parent.replica.inventory
            local containers = inventory_replica and inventory_replica:GetOpenContainers()

            local ingredients = IngredientAllocator(recipe):GetRecipeIngredients(inst._parent, ingredientmod)
            for item, ents in pairs(type(ingredients) ~= "table" and {} or ingredients) do
                for k, v in pairs(ents) do
                    inst:ConsumeByItem(k, v, overflow, containers)
                end
            end
            return true
        end
    end
end)
-- INVENTORY END --

-- BUILDER --
local Builder = require("components/builder")

local _GetIngredients = Builder.GetIngredients
function Builder:GetIngredients(recname, ...)
    local recipe = AllRecipes[recname]
    if recipe then
        local ingredients
        ingredients, self.ingredientsdata = IngredientAllocator(recipe):GetRecipeIngredients(self.inst, self.ingredientmod)
        return type(ingredients) ~= "table" and {} or ingredients
    end
end

local _Builder_HasIngredients = Builder.HasIngredients
function Builder:HasIngredients(recipe, ...)
    local has_ingredients = _Builder_HasIngredients(self, recipe, ...)
    if has_ingredients and not self.freebuildmode then
        if type(recipe) == "string" then
            recipe = GetValidRecipe(recipe)
        end
        if recipe and recipe:HasGemDictIngredients() and not IngredientAllocator(recipe):GetRecipeIngredients(self.inst, self.ingredientmod, true) then
            return false
        end
    end
    return has_ingredients
end

local _Builder_DoBuild = Builder.DoBuild
function Builder:DoBuild(recname, pt, rotation, skin, ...)
    local recipe = GetValidRecipe(recname)

    local _product
    local crafted_prefabs = {}
    if recipe then
        _product = rawget(recipe, "product")
        recipe.product = gemrun("getspecialprefab", recipe.product, function(pref)
            table.insert(crafted_prefabs, pref)
        end)
    end
    local retvals = {_Builder_DoBuild(self, recname, pt, rotation, skin, ...)}

    for i, v in ipairs(crafted_prefabs) do
        if v:IsValid() then
            if self.ingredientsdata then
                v:AddComponentAtRuntime("gemdict_craftinginfo")
                v.components.gemdict_craftinginfo.ingredientsdata = deepcopy(self.ingredientsdata)
            end

            for i, fn in ipairs(recipe.modifiedoutputfns or {}) do
                fn(v)
            end
        end
    end

    if recipe then
        gemrun("getspecialprefab", recipe.product)
        recipe.product = _product
    end

    self.ingredientsdata = nil
    return unpack(retvals)
end

local _Builder_OnSave = Builder.OnSave
function Builder:OnSave(...)
    local retvals = {_Builder_OnSave(self, ...)}
    local data = retvals[1]
    data.gemdict_buffered_builds = self.gemdict_buffered_builds
    return unpack(retvals)
end

local _Builder_OnLoad = Builder.OnLoad
function Builder:OnLoad(data, ...)
    _Builder_OnLoad(self, data, ...)
    for k, v in pairs(data.gemdict_buffered_builds or {}) do
        if self:IsBuildBuffered(k) then
            self.gemdict_buffered_builds[k] = v
        end
    end
end

GEMENV.AddComponentPostInit("builder", function(self)
    self.gemdict_buffered_builds = {}
end)

local Builder_Replica = require("components/builder_replica")

local _Builder_Replica_SetIsBuildBuffered = Builder_Replica.SetIsBuildBuffered
function Builder_Replica:SetIsBuildBuffered(recipename, isbuildbuffered, ...)
    local builder = self.inst.components.builder
    if builder then
        if isbuildbuffered == true and builder.ingredientsdata then
            builder.gemdict_buffered_builds[recipename] = builder.ingredientsdata
            builder.ingredientsdata = nil
        elseif builder.gemdict_buffered_builds[recipename] then
            builder.ingredientsdata = builder.gemdict_buffered_builds[recipename]
            builder.gemdict_buffered_builds[recipename] = nil
        end
    end
    return _Builder_Replica_SetIsBuildBuffered(self, recipename, isbuildbuffered, ...)
end

local _Builder_Replica_HasIngredients = Builder_Replica.HasIngredients
function Builder_Replica:HasIngredients(recipe, ...)
    local has_ingredients = _Builder_Replica_HasIngredients(self, recipe, ...)
    if has_ingredients and self.inst.components.builder == nil and self.classified and not self.classified.isfreebuildmode:value() then
        if type(recipe) == "string" then
            recipe = GetValidRecipe(recipe)
        end
        if recipe and recipe:HasGemDictIngredients() and not IngredientAllocator(recipe):GetRecipeIngredients(self.inst, self:IngredientMod(), true) then
            return false
        end
    end
    return has_ingredients
end

-- BUILDER END --