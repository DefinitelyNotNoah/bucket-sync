-- Initialize bucket on server start.
BucketManager:initBucket(BucketManager:getDefaultBucket(), 'inactive') -- Default is inactive.

AddEventHandler('playerJoining', function()
    local defaultBucket = BucketManager:getDefaultBucket()

    -- Set player to default bucket
    print('Player: ' .. source .. ' joined, setting to default bucket: ' .. defaultBucket)
    PlayerManager:setToBucket(source, defaultBucket)
end)

-- Keep track of every player's environment to ensure that they are in the correct state.
CreateThread(function()
    while true do
        -- Loop through all players, and if the player's bucket is not equal to the bucket they are in,
        -- set them to their assigned bucket.
        for _, player in ipairs(GetPlayers()) do
            local assignedBucket = Player(player).state['Sync-PlayerState:Bucket']
            local currentBucket = GetPlayerRoutingBucket(player)
            if currentBucket ~= assignedBucket then
                PlayerManager:setToBucket(player, assignedBucket)
                print('Player was in a invalid bucket, setting to assigned bucket.')
            end
        end

        -- Loop through all initialized buckets and verify the integrity of the bucket.
        local buckets = GlobalState['Sync-GlobalState:InitializedBuckets']
        for _, bucket in ipairs(buckets) do
            local bucketData = BucketManager:getBucketData(bucket)
            for _, player in ipairs(GetPlayers()) do
                local playerId = tonumber(player)
                if Player(player).state['Sync-PlayerState:Bucket'] == bucket then
                    -- GetPlayers() returns a table of strings, so we need to convert the player to a number.
                    if playerId then
                        TriggerClientEvent('Sync-ClientEvent:VerifyIntegrity', playerId, bucketData)
                    end
                end
            end

            -- Update Bucket Time
            local bucketTime = GlobalState['Sync-GlobalState:BucketTime' .. bucket]

            bucketTime.minute = bucketTime.minute + 1
            if bucketTime.minute >= 60 then
                bucketTime.minute = 0
                bucketTime.hour = bucketTime.hour + 1
            end

            if bucketTime.hour >= 24 then
                bucketTime.hour = 0
            end

            GlobalState:set('Sync-GlobalState:BucketTime' .. bucket, bucketTime)
        end
        Wait(2000)
    end
end)
