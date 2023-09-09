local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Follower = require("components/follower")

local _SetLeader = Follower.SetLeader
function Follower:SetLeader(...)
    self.previousleader = self.leader
    _SetLeader(self, ...)
end

function Follower:HibernateLeader(hibernate)
    if hibernate == false then

        self.leader = self.hibernatedleader
        self.hibernatedleader = nil

        if self.leader and (self.leader:HasTag("player") or self.leader:HasTag("follower_leash")) then 
            self:StartLeashing()
        end
    elseif self.hibernatedleader ~= nil then
        print("!!ERROR: Leader Already Hibernated")
    elseif hibernate then
        self.hibernatedleader = self.leader
        self.leader = nil
        self:StopLeashing()
    end
end

function Follower:SetFollowExitDestinations(exit_list)
    self.exit_destinations = exit_list
end

function Follower:CanFollowLeaderThroughExit(exit_destination)
    local canFollow = false
    for k,v in ipairs(self.exit_destinations) do
        if v == exit_destination then
            canFollow = true
        end
    end
    return canFollow
end

----------------------------------------------------------------------------------------
--Try to initialise all functions locally outside of the post-init so they exist in RAM only once
----------------------------------------------------------------------------------------

IAENV.AddComponentPostInit("follower", function(cmp)
    cmp.previousleader = nil
    cmp.hibernatedleader = nil
    cmp.exit_destinations = { EXIT_DESTINATION.LAND }
end)
