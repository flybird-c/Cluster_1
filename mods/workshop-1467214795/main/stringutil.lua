local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

local MonkeyKing_endings = { "", "e", "h", }
local MonkeyKing_punc = {".", "?", "!"}

local function monkeykingstart()
    local str = "O"
    local l = math.random(2, 4)
    for i = 2, l do
        str = str..(math.random() > 0.3 and "o" or "a")
    end
    return str
end

local function monkeykingspace()
    local c = math.random()
    local str =
        (c <= .1 and "! ") or
        (c <= .2 and ". ") or
        (c <= .3 and "? ") or
        (c <= .4 and ", ") or
        " "
    return str
end

local monkeykingend = function()
    return MonkeyKing_endings[math.random(1,#MonkeyKing_endings)]
end

local function monkeykingpunc()
    return MonkeyKing_punc[math.random(1,#MonkeyKing_punc)]
end

--wilburspeech is different from wonkeyspeech
function CraftMonkeyKingSpeech()
    local length = math.random(6)
    local str = ""
    for i = 1, length do
        str = str..monkeykingstart()..monkeykingend()
        if i ~= length then
            str = str..monkeykingspace()
        end
    end
    return str..monkeykingpunc()
end
