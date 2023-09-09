local _Networking_Say = GLOBAL.Networking_Say
function GLOBAL.Networking_Say(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity, ...)
    local entity = GLOBAL.Ents[guid]

    if entity == nil or not entity:HasTag("monkeyking") then
        return _Networking_Say(guid, userid, name, prefab, message, colour, whisper, isemote, user_vanity, ...)
    end
    
    if message ~= nil and message:utf8len() > GLOBAL.MAX_CHAT_INPUT_LENGTH then
        return
    end

	local netid = GLOBAL.TheNet:GetNetIdForUser(userid)

    if not isemote and entity ~= nil and entity.components.talker ~= nil then
        entity.components.talker:Say(GLOBAL.CraftMonkeyKingSpeech() or "", nil, nil, nil, true, colour, TEXT_FILTER_CTX_CHAT, netid)
    end

    if message then
        GLOBAL.ChatHistory:OnSay(guid, userid, netid, name, prefab, message, colour, whisper, isemote, user_vanity)
    end
end
