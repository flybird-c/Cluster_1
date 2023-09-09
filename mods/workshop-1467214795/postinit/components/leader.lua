local IAENV = env
GLOBAL.setfenv(1, GLOBAL)

----------------------------------------------------------------------------------------
local Leader = require("components/leader")

function Leader:HibernateFollower(follower, hibernate)
    if follower.components.follower then
        follower.components.follower:HibernateLeader(hibernate)
    end
end

function Leader:HibernateLandFollowers(hibernate)
    for k,v in pairs(self.followers) do
        if not k:CanOnWater() then
            self:HibernateFollower(k, hibernate)
        end
    end
end

function Leader:HibernateWaterFollowers(hibernate)
    for k,v in pairs(self.followers) do
        if not CanOnLand(k) then
            self:HibernateFollower(k, hibernate)
        end
    end
end
