--[[
Copyright (C) 2018, 2019 Zarklord

This file is part of Gem Core.

The source code of this program is shared under the RECEX
SHARED SOURCE LICENSE (version 1.0).
The source code is shared for referrence and academic purposes
with the hope that people can read and learn from it. This is not
Free and Open Source software, and code is not redistributable
without permission of the author. Read the RECEX SHARED
SOURCE LICENSE for details
The source codes does not come with any warranty including
the implied warranty of merchandise.
You should have received a copy of the RECEX SHARED SOURCE
LICENSE in the form of a LICENSE file in the root of the source
directory. If not, please refer to
<https://raw.githubusercontent.com/Recex/Licenses/master/SharedSourceLicense/LICENSE.txt>
]]

local MakeGemFunction, DeleteGemFunction = gemrun("gemfunctionmanager")
MakeGemFunction("overridesblocker", function() end, true)

if not IsTheFrontEnd then
    return
end

local WorldGenOptions = Class(function(self, modname)
    assert(KnownModIndex:DoesModExistAnyVersion(modname), "modname "..modname.." must refer to a valid mod!")
    self.modname = modname
end, nil, {})
function WorldGenOptions.AddGroup() end
function WorldGenOptions.AddItemToGroup() end
function WorldGenOptions.RemoveGroup() end
function WorldGenOptions.RemoveItemFromGroup() end
function WorldGenOptions.ReorderGroup() end
function WorldGenOptions.ReorderItem() end
function WorldGenOptions.SetGroupProperty() end
function WorldGenOptions.SetItemProperty() end
function WorldGenOptions.GetGroupProperty() end
function WorldGenOptions.GetItemProperty() end
function WorldGenOptions.ListenForEvent() end
function WorldGenOptions.RemoveEventCallback() end
function WorldGenOptions.SetOptionValue() end
function WorldGenOptions.GetOptionValue() end
function WorldGenOptions:__index(name)
    return GEMENV.GetCustomizeDescription(name) or getmetatable(self)[name]
end

local memoized_wgo = {}

local args = {...}
local functionname = args[1]
local modname = args[2]

MakeGemFunction(functionname, function(fname, mname, ...)
    memoized_wgo[mname] = memoized_wgo[mname] or WorldGenOptions(mname)
    return memoized_wgo[mname]
end, true)

memoized_wgo[modname] = WorldGenOptions(modname)
return memoized_wgo[modname]