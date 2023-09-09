OnUnloadMod = function()
    local servercreationscreen --= GLOBAL.TheFrontEnd:GetActiveScreen()
    for _, screen in pairs(GLOBAL.TheFrontEnd.screenstack) do
        if screen.name == "ServerCreationScreen" then
            servercreationscreen = screen
            break
        end
    end

    if not servercreationscreen or not servercreationscreen.world_tabs then
        return
    end

    local forest_tab = servercreationscreen.world_tabs[1]
    local cave_tab = servercreationscreen.world_tabs[2]
    if forest_tab then
        for _, v in ipairs(forest_tab.worldsettings_widgets) do
            v:OnPresetButton()
        end
    end

    if cave_tab then
        for _, v in ipairs(cave_tab.worldsettings_widgets) do
            v:OnPresetButton()
        end

        local sublevel_adder_overlay = cave_tab.sublevel_adder_overlay
        if sublevel_adder_overlay then
            if sublevel_adder_overlay.actions.items[1] then
                cave_tab.sublevel_adder_overlay.actions.items[1]:SetPosition(0, 0)
            end

            if sublevel_adder_overlay.actions.items[2] then
                cave_tab.sublevel_adder_overlay.actions.items[2]:Hide()
            end
        end
    end
end
