PlayerManager = {}

function PlayerManager:setToBucket(playerId, bucket)
    -- Check if bucket is initialized.
    if not
        GlobalState['Sync-GlobalState:Bucket' .. bucket] then
        print('Bucket ' .. bucket .. ' is not initialized.')
        return
    end

    print('Setting player ' .. playerId .. ' to bucket ' .. bucket)
    Player(playerId).state:set('Sync-PlayerState:Bucket', bucket, false)
    SetPlayerRoutingBucket(playerId, bucket)
    TriggerClientEvent('Sync-ClientEvent:VerifyIntegrity', playerId, BucketManager:getBucketData(bucket))
end

AddEventHandler('Sync-ServerEvent:SetPlayerToBucket', function(playerId, bucket)
    PlayerManager:setToBucket(playerId, bucket)
end)

RegisterCommand('setbucket', function(source, args, raw)
    local playerId = tonumber(args[1])
    local bucket = tonumber(args[2])

    if not playerId or not bucket then
        print('Usage: /setbucket [playerId] [bucket]')
        return
    end

    PlayerManager:setToBucket(playerId, bucket)
end, false)

RegisterCommand('setfakebucket', function(source, args, raw)
    local bucket = tonumber(args[2])
    local playerId = tonumber(args[1])

    if not bucket then
        print('Usage: /setfakebucket [playerId] [bucket]')
        return
    end

    SetPlayerRoutingBucket(tostring(playerId), bucket)
end, false)

return PlayerManager
