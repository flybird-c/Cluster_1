local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local function LandFlyingBird(bird)
    bird.sg:RemoveStateTag("flying")
    if bird.Physics ~= nil then
        if bird.sg.statemem.collisionmask ~= nil then
            bird.Physics:SetCollisionMask(bird.sg.statemem.collisionmask)
        end
    end
end

local function RaiseFlyingBird(bird)
    bird.sg:AddStateTag("flying")
    if bird.Physics ~= nil then
        bird.sg.statemem.collisionmask = bird.Physics:GetCollisionMask()
        bird.Physics:ClearCollidesWith(COLLISION.LIMITS)
    end
end

local function Birdfn(inst)
    -- In SW all birds pass water boundrys (this is pretty bad)
    -- In DST only water birds pass water boundrys

    -- Here is a compromise so land birds dont get stuck on sw collisons

    if inst.states["glide"] then
        local _glide_onenter = inst.states["glide"].onenter
        inst.states["glide"].onenter = function(inst, ...)
            RaiseFlyingBird(inst)
            _glide_onenter(inst, ...)
        end
        local _glide_onexit = inst.states["glide"].onexit
        inst.states["glide"].onexit = function(inst, ...)
            LandFlyingBird(inst)
            _glide_onexit(inst, ...)
        end
    end

    if inst.states["flyaway"] then -- mutant birds dont fly away and thus lack this state
        local _flyaway_onenter = inst.states["flyaway"].onenter
        inst.states["flyaway"].onenter = function(inst, ...)
            RaiseFlyingBird(inst)
            _flyaway_onenter(inst, ...)
        end
        local _flyaway_onexit = inst.states["flyaway"].onexit
        inst.states["flyaway"].onexit = function(inst, ...)
            LandFlyingBird(inst)
            _flyaway_onexit(inst, ...)
        end
    end
end

IAENV.AddStategraphPostInit("bird", Birdfn)
IAENV.AddStategraphPostInit("bird_mutant", Birdfn)
