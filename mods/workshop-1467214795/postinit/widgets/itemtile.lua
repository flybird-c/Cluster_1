local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local UIAnim = require("widgets/uianim")
local Image = require("widgets/image")
local Text = require("widgets/text")

----------------------------------------------------------------------------------------
local ItemTile = require("widgets/itemtile")

--separate so we can refresh our stuff once on init
local function Refresh_IA(self, ...)
    if self.ismastersim then
        if self.obsidian_charge ~= nil and self.item.components.obsidiantool ~= nil then
            local charge, maxcharge = self.item.components.obsidiantool:GetCharge()
            self.obsidian_charge:GetAnimState():SetPercent("anim", charge / maxcharge)
        end

        if self.invspace ~= nil and self.item.components.inventory then
            self.invspace:GetAnimState():SetPercent("anim", self.item.components.inventory:NumItems() / self.item.components.inventory.maxslots)
        end

        if self.fusebg ~= nil and self.item.components.fuse and self.item.components.fuse.consuming then
            self:SetFuse(self.item.components.fuse.fusetime)
        end
    elseif self.item.replica.inventoryitem ~= nil then
        self.item.replica.inventoryitem:DeserializeUsage()
    end
end

local _Refresh = ItemTile.Refresh
function ItemTile:Refresh(...)
    _Refresh(self, ...)
	Refresh_IA(self, ...)
end


local _StartDrag = ItemTile.StartDrag
function ItemTile:StartDrag(...)
    _StartDrag(self, ...)
    if self.item.replica.inventoryitem ~= nil then -- HACK HACK: items without an inventory component won't have any of these
        if self.obsidian_charge ~= nil then
            self.obsidian_charge:Hide()
        end
        if self.invspacechange ~= nil then
            self.invspace:Hide()
        end
        if self.fusebg ~= nil then
            self.fusebg:Hide()
        end
    end
end

function ItemTile:SetFuse(time)
    if not self.isactivetile then
        self.fusebg:Show()
    end
    if not self.fuse then
        self.fuse = self:AddChild(Text(NUMBERFONT, 50))
        if JapaneseOnPS4 and JapaneseOnPS4() then
            self.fuse:SetHorizontalSqueeze(0.7)
        end
        self.fuse:SetPosition(5,0,0)
    end

    local val_to_show = time
    if val_to_show > 0 and val_to_show < 1 then
        val_to_show = 1
    end
    self.fuse:SetString(string.format("%2.0f", val_to_show))
end

function ItemTile:RemoveFuse()
    if self.fuse then
        self.fuse:Kill()
        self.fuse = nil
    end
    self.fusebg:Hide()
end


----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddClassPostConstruct("widgets/itemtile", function(widget)
    if widget.item:HasTag("show_invspace") then
        widget.invspace = widget:AddChild(UIAnim())
        widget.invspace:GetAnimState():SetBank("trawlnet_meter")
        widget.invspace:GetAnimState():SetBuild("trawlnet_meter")
        widget.invspace:SetClickable(false)
    end

    if widget.item:HasTag("obsidiantool") then
        widget.obsidian_charge = widget:AddChild(UIAnim())
        widget.obsidian_charge:GetAnimState():SetBank("obsidian_tool_meter")
        widget.obsidian_charge:GetAnimState():SetBuild("obsidian_tool_meter")
        widget.obsidian_charge:SetClickable(false)
    end

    if widget.item:HasTag("fuse") then
        widget.fusebg = widget:AddChild(Image(HUD_ATLAS, "resource_needed.tex"))
        widget.fusebg:SetClickable(false)
        widget.fusebg:Hide()
    end

    if widget.item:HasTag("gourmetfood") then
        widget.gourmetstar = widget:AddChild(Image("images/hud/ia_hud.xml", "gourmetstar.tex"))
        widget.gourmetstar:SetPosition(20,-20,0) --right bottom corner
        widget.gourmetstar:SetClickable(false)
    end

    --I HATE THIS, but idk how else to ensure proper ordering of these, without nasty hacks. -Z
    if widget.obsidian_charge then widget.obsidian_charge:MoveToBack() end
    if widget.invspace then widget.invspace:MoveToBack() end
    if widget.spoilage then widget.spoilage:MoveToBack() end
    if widget.fusebg then widget.fusebg:MoveToBack() end
    if widget.bg then widget.bg:MoveToBack() end

    if widget.invspace then
        widget.inst:ListenForEvent("invspacechange", function(invitem, data)
    		widget.invspace:GetAnimState():SetPercent("anim", data.percent)
    	end, widget.item)
    end

    if widget.obsidian_charge then
        widget.inst:ListenForEvent("obsidianchargechange", function(invitem, data)
    		widget.obsidian_charge:GetAnimState():SetPercent("anim", data.percent)
    	end, widget.item)
    end

    if widget.fusebg then
        widget.inst:ListenForEvent("fusechange", function(invitem, data)
            widget:SetFuse(data.time)
            if data.time == 0 then
                widget:RemoveFuse()
            end
        end, widget.item)
    end

    Refresh_IA(widget)
end)
