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

local IngredientUI = require("widgets/ingredientui")

--sub ingredient hover
local is_subcraft_ingredients = nil
local visible_subingredients = nil

--pin slot hover
local is_pinslot_ingredients = nil
local visible_pinslot = nil

local _IngredientUI_ctor = IngredientUI._ctor
function IngredientUI._ctor(self, ...)
    _IngredientUI_ctor(self, ...)

    if self.ongainfocus and self.onlosefocus then
        local _ongainfocus = self.ongainfocus
        self.ongainfocus = function(...)
            is_subcraft_ingredients = true
            return _ongainfocus(...)
        end

        local _onlosefocus = self.onlosefocus
        self.onlosefocus = function(...)
            if self.ingredients == visible_subingredients then
                visible_subingredients = nil
                self.owner:PushEvent("gemdict_hideoverlay")
                if self.owner.HUD:IsCraftingOpen() then
                    self.owner:PushEvent("gemdict_craftinghud_showoverlay")
                else
                    self.owner:PushEvent("gemdict_pinslot_showoverlay")
                end
            end
            return _onlosefocus(...)
        end
    end
end

function IngredientUI:UpdateQuantity(quantity, on_hand, has_enough, builder)
    if builder ~= nil then
        quantity = math.round(quantity * builder:IngredientMod())
    end
    local hud_atlas = resolvefilepath("images/hud.xml")
    self:SetTextures(hud_atlas, has_enough and "inv_slot.tex" or "resource_needed.tex")
    if self.quant then
        self.quant:SetString(string.format("%d/%d", on_hand, quantity))
        if has_enough then
            self.quant:SetColour(255/255, 255/255, 255/255, 1)
        else
            self.quant:SetColour(255/255, 155/255, 155/255, 1)
        end
    end
end

local GemDictIngredientUI = require("widgets/gemdictingredientui")
local IngredientAllocator = gemrun("gemdictionary/ingredientallocator")

local function ImageTableContainsImage(imagetable, image)
    for i, v in ipairs(imagetable) do
        if v.image == image then
            return i
        end
    end
    return true
end

local CraftingMenuIngredients = require("widgets/redux/craftingmenu_ingredients")

local startidx
local localdata
local SetRecipeEnv = setmetatable({
    ipairs = function(t, ...)
        if not localdata then return ipairs(t, ...) end
        local self = localdata.self
        local recipe = localdata.recipe

        if t == recipe.tech_ingredients then
            --if t is ever == to my modified tech ingredients table, replace it with the proper value before iterating
            t = localdata._tech_ingredients
            recipe.tech_ingredients = localdata._tech_ingredients
        elseif t == recipe.ingredients then
            --obtain the index where recipe.ingredients start.
            startidx = #self.ingredient_widgets + 1
        elseif t == recipe.character_ingredients then
            local owner = localdata.owner
            local builder = owner.replica.builder

            --get the local variables from __MakeIngredientList
            local root, w, half_div, offset, quant_text_scale, allow_ingredient_crafting
            local stacklevel = 2
            while debug.getinfo(stacklevel, "n") ~= nil do
                root = LocalVariableHacker.GetLocalVariable(stacklevel, "root")
                w = LocalVariableHacker.GetLocalVariable(stacklevel, "w")
                half_div = LocalVariableHacker.GetLocalVariable(stacklevel, "half_div")
                offset = LocalVariableHacker.GetLocalVariable(stacklevel, "offset")
                quant_text_scale = LocalVariableHacker.GetLocalVariable(stacklevel, "quant_text_scale")
                allow_ingredient_crafting = LocalVariableHacker.GetLocalVariable(stacklevel, "allow_ingredient_crafting")
                if root ~= nil and w ~= nil and half_div ~= nil and offset ~= nil and quant_text_scale ~= nil and allow_ingredient_crafting ~= nil then
                    break
                end
                stacklevel = stacklevel + 1
            end

            local ingredientdata = IngredientAllocator(recipe):GetRecipePopupIngredients(owner, builder:IngredientMod())

            --update recipe.ingredients, if some of the items it thought were avaliable actually weren't
            for i = startidx, #self.ingredient_widgets do
                local ingredient = recipe.ingredients[1 + (i - startidx)]
                local _ingredientdata = ingredientdata[ingredient]
                self.ingredient_widgets[i]:UpdateQuantity(ingredient.amount, _ingredientdata.num_found, _ingredientdata.has, builder)

                if self.is_sub_ingredients then
                    for item, count in pairs(_ingredientdata.items) do
                        item:PushEvent("gemdict_setstate", count)
                    end
                elseif self.is_pin_ingredients then
                    for item, count in pairs(_ingredientdata.items) do
                        item:PushEvent("gemdict_pinslot_setstate", count)
                    end
                else
                    for item, count in pairs(_ingredientdata.items) do
                        item:PushEvent("gemdict_craftinghud_setstate", count)
                    end
                end
            end

            for i, v in ipairs(recipe.gemdict_ingredients) do
                local _ingredientdata = ingredientdata[v]
                local images, names, counts = v:GetImages(not _ingredientdata.has, _ingredientdata.num_found, not _ingredientdata.nomix and _ingredientdata.has or false)
                if _ingredientdata.nomix then
                    for i1, v1 in ipairs(_ingredientdata) do
                        for item, count in pairs(v1.items) do
                            local image = item.replica.inventoryitem:GetImage()
                            local index = ImageTableContainsImage(images, image)
                            if index then
                                counts[index].on_hand = v1.num_found
                                counts[index].has_enough = v1.has
                            else
                                table.insert(images, {image = image, atlas = item.replica.inventoryitem:GetAtlas()})
                                table.insert(names, item:GetBasicDisplayName())
                                table.insert(counts, {on_hand = v1.num_found, has_enough = v1.has})
                            end

                            if self.is_sub_ingredients then
                                item:PushEvent("gemdict_setstate", count)
                            elseif self.is_pin_ingredients then
                                item:PushEvent("gemdict_pinslot_setstate", count)
                            else
                                item:PushEvent("gemdict_craftinghud_setstate", count)
                            end
                        end
                    end
                else
                    --obtain inv images, and names from val, and use them if they aren't already present in the list of images.
                    for item, count in pairs(_ingredientdata.items) do
                        local image = item.replica.inventoryitem:GetImage()
                        if not ImageTableContainsImage(images, image) then
                            table.insert(images, {image = image, atlas = item.replica.inventoryitem:GetAtlas()})
                            table.insert(names, item:GetBasicDisplayName())
                            table.insert(counts, {on_hand = _ingredientdata.num_found, has_enough = _ingredientdata.has})
                        end

                        if self.is_sub_ingredients then
                            item:PushEvent("gemdict_setstate", count)
                        elseif self.is_pin_ingredients then
                            item:PushEvent("gemdict_pinslot_setstate", count)
                        else
                            item:PushEvent("gemdict_craftinghud_setstate", count)
                        end
                    end
                end

                --sub ingredient crafting is currently too complicated, for the moment its not allowed.
                --local ingredient_recipe_data = allow_ingredient_crafting and owner.HUD.controls.craftingmenu:GetRecipeState(v.type) or nil

                local ing = root:AddChild(GemDictIngredientUI(images, v.amount, counts, names, owner, v.type, quant_text_scale, nil))

                if GetGameModeProperty("icons_use_cc") then
                    ing.ing:SetEffect("shaders/ui_cc.ksh")
                end
                if self.num_items > 1 and #self.ingredient_widgets > 0 then
                    offset = offset + half_div
                end
                ing:SetPosition(offset, 0)
                offset = offset + w + half_div
                table.insert(self.ingredient_widgets, ing)
            end

            LocalVariableHacker.SetLocalVariable(stacklevel, "offset", offset)
        end
        return ipairs(t, ...)
    end
}, {__index = _G, __newindex = _G})
setfenv(CraftingMenuIngredients.SetRecipe, SetRecipeEnv)

local craftinghighlight = GEMENV.GetModConfigData("craftinghighlight", true)

local _SetRecipe = CraftingMenuIngredients.SetRecipe
function CraftingMenuIngredients:SetRecipe(recipe, ...)
    localdata = nil

    local owner = self.owner

    if is_subcraft_ingredients then
        visible_subingredients = self
        self.is_sub_ingredients = true
        is_subcraft_ingredients = nil
    elseif is_pinslot_ingredients then
        visible_pinslot = self
        self.is_pin_ingredients = true
        is_pinslot_ingredients = nil
    end

    if not craftinghighlight and not recipe:HasGemDictIngredients() then
        if self.is_sub_ingredients then
            owner:PushEvent("gemdict_hideoverlay")
        elseif self.is_pin_ingredients then
            owner:PushEvent("gemdict_pinslot_hideoverlay")
        else
            owner:PushEvent("gemdict_craftinghud_hideoverlay")
        end
        return _SetRecipe(self, recipe, ...)
    end

    if self.is_sub_ingredients then
        owner:PushEvent("gemdict_setoverlay")
    elseif self.is_pin_ingredients then
        owner:PushEvent("gemdict_pinslot_setoverlay")
    else
        owner:PushEvent("gemdict_craftinghud_setoverlay")
        if owner.HUD:IsCraftingOpen() then
            owner:PushEvent("gemdict_craftinghud_showoverlay")
        end
    end

    localdata = {self = self, recipe = recipe, owner = owner}

    --increase the size of the tech ingredients table so the ui spaces the ingredients properly.
    localdata._tech_ingredients = recipe.tech_ingredients
    recipe.tech_ingredients = ExtendedArray({}, {true}, #recipe.tech_ingredients + #recipe.gemdict_ingredients)
    --this will get reset back properly in the ipairs metatable function replacement above

    return _SetRecipe(self, recipe, ...)
end

--on open, show for current recipe
--on hover, show sub recipe
--stop hover, show for current recipe
--on click, show recipe

--3 states:
--state > 0, show consumecount, and hide overlay
--state == false, hide consumecount, show overlay
--state == nil or state == 0, hide consumecount, hide overlay
local function SetGemDictState(self, state)
    self.gemdict_ingredientoverlay:Hide()
    self.gemdict_consumecount:Hide()
    if state ~= nil then
        if not state then
            self.gemdict_ingredientoverlay:Show()
            self.gemdict_ingredientoverlay:MoveToFront()

            if self.quantity ~= nil then
                self.quantity:MoveToFront()
            end
        elseif state > 0 then
            self.gemdict_consumecount:Show()
            self.gemdict_consumecount:MoveToFront()
            self.gemdict_consumecount:SetString(tostring(state))
        end
    end
end

local function Refresh(self, ...)
    local state
    if self.showing_craftinghud_state then
        state = self.item._gemdict_craftinghud_state
    elseif self.item._gemdict_state ~= nil then
        state = self.item._gemdict_state
    else
        state = self.item._gemdict_pinslot_state
    end
    self:SetGemDictState(state)
end

local Text = require("widgets/text")
local Image = require("widgets/image")

GEMENV.AddClassPostConstruct("widgets/itemtile", function(self)
    self.gemdict_ingredientoverlay = self:AddChild(Image("images/gemdict_ui.xml", "gemdict_ingredientoverlay.tex"))
    self.gemdict_ingredientoverlay:SetTint(255/255, 255/255, 255/255, 0.5)
    self.gemdict_ingredientoverlay:SetClickable(false)
    self.gemdict_ingredientoverlay:Hide()

    self.gemdict_consumecount = self:AddChild(Text(NUMBERFONT, 36))
    self.gemdict_consumecount:SetPosition(24, 16, 0)
    self.gemdict_consumecount:SetClickable(false)
    self.gemdict_consumecount:Hide()

    self.inst:ListenForEvent("gemdict_setstate", function(invitem, state)
        self.showing_craftinghud_state = false
        invitem._gemdict_state = state and ((invitem._gemdict_state or 0) + state) or state
        self:SetGemDictState(invitem._gemdict_state)
    end, self.item)

    self.inst:ListenForEvent("gemdict_pinslot_setstate", function(invitem, state)
        invitem._gemdict_pinslot_state = state and ((invitem._gemdict_pinslot_state or 0) + state) or state
        self:SetGemDictState(invitem._gemdict_pinslot_state)
    end, self.item)

    self.inst:ListenForEvent("gemdict_pinslot_showstate", function(invitem)
        self:SetGemDictState(invitem._gemdict_pinslot_state)
    end, self.item)

    self.inst:ListenForEvent("gemdict_craftinghud_setstate", function(invitem, state)
        invitem._gemdict_craftinghud_state = state and ((invitem._gemdict_craftinghud_state or 0) + state) or state
        if self.showing_craftinghud_state then
            self:SetGemDictState(invitem._gemdict_craftinghud_state)
        end
    end, self.item)

    self.inst:ListenForEvent("gemdict_craftinghud_showstate", function(invitem)
        self.showing_craftinghud_state = true
        self:SetGemDictState(invitem._gemdict_craftinghud_state)
    end, self.item)

    self.inst:ListenForEvent("gemdict_craftinghud_hidestate", function(invitem)
        self.showing_craftinghud_state = false
        self:SetGemDictState(nil)
    end, self.item)

    local _Refresh = self.Refresh
    function self:Refresh(...)
        _Refresh(self, ...)
        Refresh(self, ...)
    end

    local _StartDrag = self.StartDrag
    function self:StartDrag(...)
        _StartDrag(self, ...)
        self:SetGemDictState(nil)
    end

    self.SetGemDictState = SetGemDictState

    Refresh(self)
end)

local function SetItemlessGemDictState(self, state)
    if state == false then
        self.gemdict_ingredientoverlay:Show()
        self.gemdict_ingredientoverlay:MoveToFront()
    elseif state == nil then
        self.gemdict_ingredientoverlay:Hide()
    end
end

local function ForwardEventToItem(self, listen_event, send_event, itemless_state, send_state)
    self.inst:ListenForEvent(listen_event, function()
        local item = self.tile and self.tile.item
        if type(item) == "table" then
            item:PushEvent(send_event, send_state)
        else
            self:SetItemlessGemDictState(FunctionOrValue(itemless_state))
        end
    end, self.owner)
end

GEMENV.AddClassPostConstruct("widgets/itemslot", function(self)
    self.gemdict_ingredientoverlay = self:AddChild(Image("images/gemdict_ui.xml", "gemdict_ingredientoverlay.tex"))
    self.gemdict_ingredientoverlay:SetTint(255/255, 255/255, 255/255, 0.5)
    self.gemdict_ingredientoverlay:SetClickable(false)
    self.gemdict_ingredientoverlay:Hide()

    ForwardEventToItem(self, "gemdict_craftinghud_setoverlay", "gemdict_craftinghud_setstate", function() if self.owner.HUD:IsCraftingOpen() then return false end return nil end, false)
    ForwardEventToItem(self, "gemdict_craftinghud_showoverlay", "gemdict_craftinghud_showstate", false)
    ForwardEventToItem(self, "gemdict_craftinghud_hideoverlay", "gemdict_craftinghud_hidestate", nil)

    ForwardEventToItem(self, "gemdict_pinslot_setoverlay", "gemdict_pinslot_setstate", false, false)
    ForwardEventToItem(self, "gemdict_pinslot_showoverlay", "gemdict_pinslot_showstate", false)
    ForwardEventToItem(self, "gemdict_pinslot_hideoverlay", "gemdict_pinslot_setstate", nil, nil)

    ForwardEventToItem(self, "gemdict_setoverlay", "gemdict_setstate", false, false)
    ForwardEventToItem(self, "gemdict_hideoverlay", "gemdict_setstate", nil, nil)

    local _SetTile = self.SetTile
    function self:SetTile(tile, ...)
        if tile then
            self:SetItemlessGemDictState()
        end
        return _SetTile(self, tile, ...)
    end

    self.SetItemlessGemDictState = SetItemlessGemDictState
end)

local CraftingMenuHUD = require("widgets/redux/craftingmenu_hud")
local _Open = CraftingMenuHUD.Open
function CraftingMenuHUD:Open(search, ...)
    if self:IsCraftingOpen() then
        return _Open(self, search, ...)
    end
    self.owner:PushEvent("gemdict_craftinghud_showoverlay")
    return _Open(self, search, ...)
end

local _Close = CraftingMenuHUD.Close
function CraftingMenuHUD:Close(...)
    self.owner:PushEvent("gemdict_craftinghud_hideoverlay")
    return _Close(self, ...)
end

local PinSlot = require("widgets/redux/craftingmenu_pinslot")
local _MakeRecipePopup = PinSlot.MakeRecipePopup
function PinSlot:MakeRecipePopup(...)
    local retvals = {_MakeRecipePopup(self, ...)}

    local root = retvals[1]

    if root then
        local _ShowPopup = root.ShowPopup
        root.ShowPopup = function(popup_self, recipe, ...)
            is_pinslot_ingredients = recipe ~= nil or nil
            return _ShowPopup(popup_self, recipe, ...)
        end

        local _HidePopup = root.HidePopup
        root.HidePopup = function(popup_self, ...)
            if popup_self.ingredients == visible_pinslot then
                visible_pinslot = nil
                self.owner:PushEvent("gemdict_pinslot_hideoverlay")
            end
            return _HidePopup(popup_self, ...)
        end
    end

    return unpack(retvals)
end