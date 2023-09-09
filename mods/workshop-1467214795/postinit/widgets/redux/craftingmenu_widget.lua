local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------

local CraftingMenuWidget = require("widgets/redux/craftingmenu_widget")

local _UpdateFilterButtons = CraftingMenuWidget.UpdateFilterButtons

local function Refresh_CraftingMenuWidget(CraftingMenu)
    local rebuild_details_list = _UpdateFilterButtons
	if CraftingMenu.sort_class.Refresh == nil or not CraftingMenu.sort_class:Refresh() then
		if rebuild_details_list then
			CraftingMenu:ApplyFilters()
		else
			CraftingMenu.recipe_grid:RefreshView()
		end
		if CraftingMenu.crafting_hud:IsCraftingOpen() then
			CraftingMenu:OnCraftingMenuOpen(true)
		end
	end
	CraftingMenu.details_root:Refresh()
end

local jellybrainhat_change = false
CraftingMenuWidget.UpdateFilterButtons = function(self, ...)
    local builder = self.owner ~= nil and self.owner.replica.builder or nil
    if builder and builder.classified and builder.classified.isjellybrainhat:value() then
        self.crafting_station_filter:Show()
        Refresh_CraftingMenuWidget(self)

        jellybrainhat_change = true
    elseif jellybrainhat_change then
        self.crafting_station_filter:Hide()
        Refresh_CraftingMenuWidget(self)

        jellybrainhat_change = false
    else
        return _UpdateFilterButtons(self, ...)
    end
end
