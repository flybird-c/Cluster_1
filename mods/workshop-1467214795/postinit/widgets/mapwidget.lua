local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

-------------------------------------------------------------------------------------------

IAENV.AddClassPostConstruct("widgets/mapwidget", function (widget)
    if IsInIAClimate(widget.owner) then
        widget.bg:SetTexture("images/hud/hud_shipwrecked.xml", "map_shipwrecked.tex")
    else
        widget.bg:SetTexture("images/hud.xml", "map.tex")
    end
end)