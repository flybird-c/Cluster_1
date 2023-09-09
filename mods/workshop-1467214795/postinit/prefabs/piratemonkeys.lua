local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

local function MakeSpeechFn()
    local _speech_override_fn = nil
    local function speech_override_fn(inst, speech, ...)
        if ThePlayer ~= nil and ThePlayer:HasTag("monkeyking") then
            return speech
        elseif _speech_override_fn ~= nil then
            return _speech_override_fn(inst, speech, ...)
        end 
    end
    
    local function fn(inst)
        if not _speech_override_fn then
            _speech_override_fn = inst.speech_override_fn
        end
        inst.speech_override_fn = speech_override_fn
    end

    return fn
end

IAENV.AddPrefabPostInit("prime_mate", MakeSpeechFn())
IAENV.AddPrefabPostInit("powder_monkey", MakeSpeechFn())
IAENV.AddPrefabPostInit("monkeyqueen", MakeSpeechFn())