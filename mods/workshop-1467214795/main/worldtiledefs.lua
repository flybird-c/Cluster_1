local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local _PlayFootstep = PlayFootstep
function PlayFootstep(inst, volume, ispredicted, ...)
    if inst == nil or inst.SoundEmitter == nil then
        return _PlayFootstep(inst, volume, ispredicted, ...)
    end

    local _snowlevel = rawget(TheWorld.state, "snowlevel")
    local _wetness = rawget(TheWorld.state, "wetness")

    if IsInIAClimate(inst) then
        TheWorld.state.snowlevel = 0
        TheWorld.state.wetness = TheWorld.state.islandwetness
    end

    -- In sw flood they forgot to add custom sounds for flood and just use web sounds...
    -- So use mudsounds instead!
    if TheWorld.state.wetness <= 15 
    and ((inst.components.slowingobjectmanager ~= nil and inst.components.slowingobjectmanager:IsSlowing()
    or inst.player_classified ~= nil and inst.player_classified.slowing_object:value()) 
    or (TheWorld.components.flooding and TheWorld.components.flooding:IsPointOnFlood(inst.Transform:GetWorldPosition()))) then
        TheWorld.state.wetness = 16 --Use mudsounds
    end

    local _PlaySound = nil
    local _PlaySoundWithParams = nil
    if inst.footstep_overridefn then
        _PlaySound = SoundEmitter.PlaySound
        function SoundEmitter:PlaySound(soundname, ...)
            return _PlaySound(self, self == inst.SoundEmitter and inst:footstep_overridefn(soundname) or soundname, ...)
        end

        _PlaySoundWithParams = SoundEmitter.PlaySoundWithParams
        function SoundEmitter:PlaySoundWithParams(soundname, ...)
            return _PlaySoundWithParams(self, self == inst.SoundEmitter and inst:footstep_overridefn(soundname) or soundname, ...)
        end
    end

    -- TODO add flood and tar sounds
    local rets = {_PlayFootstep(inst, volume, ispredicted, ...)}

    if _PlaySound ~= nil then
        SoundEmitter.PlaySound = _PlaySound
    end
    if _PlaySoundWithParams ~= nil then
        SoundEmitter.PlaySoundWithParams = _PlaySoundWithParams
    end

    TheWorld.state.snowlevel = _snowlevel
    TheWorld.state.wetness = _wetness

    return unpack(rets)
end

