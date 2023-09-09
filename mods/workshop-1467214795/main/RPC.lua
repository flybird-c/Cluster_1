local AddModRPCHandler = AddModRPCHandler
local AddShardModRPCHandler = AddShardModRPCHandler
GLOBAL.setfenv(1, GLOBAL)

local function printinvalid(rpcname, player)
    print(string.format("Invalid %s RPC from (%s) %s", rpcname, player.userid or "", player.name or ""))

    --This event is for MODs that want to handle players sending invalid rpcs
    TheWorld:PushEvent("invalidrpc", { player = player, rpcname = rpcname })

    if BRANCH == "dev" then
        --Internal testing
        assert(false, string.format("Invalid %s RPC from (%s) %s", rpcname, player.userid or "", player.name or ""))
    end
end

AddModRPCHandler("Island Adventure", "ForceUpdateFacing", function(player, direction)
    --print("Received ForceUpdateFacing request...")
    player.Transform:SetRotation(direction)
    player.components.sailor:AlignBoat()
    if player.player_classified then
        player.player_classified.facingsynced:set_local(true)
        player.player_classified.facingsynced:set(true)
    end
end)

AddModRPCHandler("Island Adventure", "ClientRequestDisembark", function(player)
    player:PushEvent("hitcoastline")
end)

AddModRPCHandler("Island Adventure", "BoatEquipActiveItem", function(player, container)
    if container ~= nil then
        container.components.container:BoatEquipActiveItem()
    end
end)

AddModRPCHandler("Island Adventure", "SwapBoatEquipWithActiveItem", function(player, container)
    if container ~= nil then
        container.components.container:SwapBoatEquipWithActiveItem()
    end
end)

AddModRPCHandler("Island Adventure", "TakeActiveItemFromBoatEquipSlot", function(player, eslot, container)
    if not checknumber(eslot) then
        printinvalid("TakeActiveItemFromBoatEquipSlot", player)
        return
    end
    if container ~= nil then
        container.components.container:TakeActiveItemFromBoatEquipSlotID(eslot)
    end
end)

AddShardModRPCHandler("Island Adventure", "AppeaseVolcano", function(shardid, appeasesegs)
    local vm = TheWorld.components.volcanomanager
    if vm then
        vm:Appease(appeasesegs)
    end
end)
