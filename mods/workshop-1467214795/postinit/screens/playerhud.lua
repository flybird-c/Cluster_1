local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local ContainerWidget = require("widgets/containerwidget")
local PoisonOver = require("widgets/poisonover")
local BoatOver = require("widgets/boatover")
local UIAnim = require("widgets/uianim")
local PlayerHud = require("screens/playerhud")

local _CreateOverlays = PlayerHud.CreateOverlays
function PlayerHud:CreateOverlays(owner, ...)
    _CreateOverlays(self, owner, ...)

    self.poisonover = self.overlayroot:AddChild(PoisonOver(owner))
    self.boatover = self.overlayroot:AddChild(BoatOver(owner))

    self.smoke = self.overlayroot:AddChild(UIAnim())
    self.smoke:SetClickable(false)
    self.smoke:SetHAnchor(ANCHOR_MIDDLE)
    self.smoke:SetVAnchor(ANCHOR_MIDDLE)
    self.smoke:GetAnimState():SetBank("clouds_ol")
    self.smoke:GetAnimState():SetBuild("clouds_ol")
    self.smoke:GetAnimState():PlayAnimation("idle", true)
    self.smoke:GetAnimState():SetMultColour(1, 1, 1, 0)
    self.smoke:Hide()
end

function PlayerHud:GetOpenContainerWidgets()
    return self.controls.containers
end

function PlayerHud:OpenBoat(boat, sailing)
    if boat then
        local boatwidget = nil
        if sailing then
            self.controls.inv.boatwidget = self.controls.inv.root:AddChild(ContainerWidget(self.owner))
            boatwidget = self.controls.inv.boatwidget
            boatwidget:SetScale(1)
            boatwidget.scalewithinventory = false
            boatwidget:MoveToBack()
            boatwidget.inv_boatwidget = true
            self.controls.inv:Rebuild()
        else
            boatwidget = self.controls.containerroot:AddChild(ContainerWidget(self.owner))
        end

        boatwidget:Open(boat, self.owner, not sailing)

        for k,v in pairs(self.controls.containers) do
            if v.container then
                if v.parent == boatwidget.parent or k == boat then
                    v:Close()
                end
            else
                self.controls.containers[k] = nil
            end
        end

        self.controls.containers[boat] = boatwidget
    end
end

function PlayerHud:UpdateSmoke(rate)
    --local vm = TheWorld.components.volcanomanager
    if self.smoke and rate then
        if rate > 0.0 then
            local g = 0.5
            local a = math.sin(PI * rate)
            self.smoke:Show()
            self.smoke:GetAnimState():SetMultColour(g, g, g, a)
            --[[
            local x, y, z = GetPlayer().Transform:GetLocalPosition()
			local dist = vm:GetDistanceFromVolcano(x, y, z)
			local distMax = 250 * TILE_SCALE
			local distMin = 25 * TILE_SCALE

			--print(string.format("%f < %f\n", dist, distMax))
			if dist < distMax then
				local p = 1 - easing.outCubic(dist - distMin, 0, 1, distMax - distMin)
				local g = easing.inOutSine(dist - distMin, 0.25, 0.5, distMax - distMin)
				--print(string.format("(%f, %f)\n", g, p))

				self.smoke:Show()
				self.smoke:GetAnimState():SetMultColour(g, g, g, p)
			else
				self.smoke:Hide()
			end
            --]]
        else
            self.smoke:Hide()
        end
    end
end