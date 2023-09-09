local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddPrefabPostInit("book_birds", function(inst)
    if TheWorld.ismastersim then
        local _onread = inst.components.book.onread
        function inst.components.book.onread(inst, reader, ...)
            local climate = GetClimate(reader)
            if IsClimate(climate, "volcano") then
                return false, "VOLCANO"
            elseif TheWorld.state.iswinter and IsIAClimate(climate) then
                return false, "NOBIRDS"
            end
            return _onread(inst, reader, ...)
        end
    end
end)
