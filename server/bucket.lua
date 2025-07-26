BucketManager = {}

local defaultBucket = 0

-- States
local states = {}
for _, state in ipairs(StateManager:getStateManagers()) do
    table.insert(states, {
        name = state.name,
        default = state.default
    })

    print('inserted state ' .. state.name .. ' with default value ' .. tostring(state.default))
end

function BucketManager:initBucket(bucket, lockdown)
    print('Initializing Bucket ' .. bucket)

    -- If the bucket already exists, return
    if GlobalState['Sync-GlobalState:Bucket' .. bucket] then
        print('Bucket ' .. bucket .. ' already exists, skipping initialization.')
        return
    end

    -- Save bucket to global list.
    if not GlobalState['Sync-GlobalState:InitializedBuckets'] then
        GlobalState:set('Sync-GlobalState:InitializedBuckets', { bucket }, false)
        print("Initialized Global Bucket List")
    else
        local buckets = GlobalState['Sync-GlobalState:InitializedBuckets']
        table.insert(buckets, bucket)
        GlobalState:set('Sync-GlobalState:InitializedBuckets', buckets, false)
        print("Inserting bucket into InitializedBuckets")
        print("Initialized Bucket Count: " .. #GlobalState['Sync-GlobalState:InitializedBuckets'])
    end

    -- Initialize Bucket
    GlobalState:set('Sync-GlobalState:Bucket' .. bucket, true)

    if lockdown == 'relaxed' or lockdown == 'strict' or lockdown == 'inactive' then
        SetRoutingBucketEntityLockdownMode(bucket, lockdown) -- lockdown
        print('Setting lockdown mode: ' .. lockdown)
    else
        print('Invalid lockdown mode specified.')
        return
    end

    -- Set default values for the bucket
    for _, state in ipairs(states) do
        GlobalState:set('Sync-GlobalState:Bucket' .. state.name .. bucket, state.default)

        print('Set ' .. state.name .. ' to ' .. tostring(state.default) .. ' for bucket ' .. bucket)
    end
end

function BucketManager:getBucketData(bucket)
    local data = {}

    for _, state in ipairs(states) do
        -- Do remember that the keys here will start with a capital letter
        data[state.name] = GlobalState['Sync-GlobalState:Bucket' .. state.name .. bucket]
    end

    -- print('Returning bucket data for bucket ' .. bucket .. ' with data: ' .. json.encode(data))
    return data
end

function BucketManager:getDefaultBucket()
    return defaultBucket
end

AddEventHandler('Sync-ServerEvent:InitBucket', function(bucket, lockdown)
    BucketManager:initBucket(bucket, lockdown)
end)

RegisterCommand('initbucket', function(source, args, raw)
    local bucket = tonumber(args[1])
    local lockdown = args[2]

    if not bucket then
        print('Usage: /initbucket [bucket] [lockdown]')
        return
    end

    BucketManager:initBucket(bucket, lockdown)
end, false)

RegisterCommand('totalbuckets', function(source, args, raw)
    local initializedBuckets = GlobalState['Sync-GlobalState:InitializedBuckets'] or {}
    print('Total initialized buckets: ' .. #initializedBuckets)
end, false)

-- Bucket Lockdown Command
RegisterCommand('setbucketlockdown', function(source, args, raw)
    local bucket = tonumber(args[1])
    local lockdown = args[2]

    if not bucket then
        print('Usage: /setbucketlockdown [bucket] [lockdown]')
        return
    end

    SetRoutingBucketEntityLockdownMode(bucket, lockdown)
end, false)

RegisterCommand('setbucketpop', function(source, args, raw)
    local bucket = tonumber(args[1])
    local population = tonumber(args[2])

    if not bucket or not population then
        print('Usage: /setbucketpop [bucket] [population]')
        return
    end

    if GlobalState['Sync-GlobalState:Bucket' .. bucket] then
        SetRoutingBucketPopulationEnabled(bucket, population > 0)
        print('Set population for bucket ' .. bucket .. ' to ' .. population)
    else
        print('Bucket ' .. bucket .. ' does not exist.')
    end
end, false)

return BucketManager -- Unnecessary, but it's here for consistency in regard to module convention
