StateManager = {}
StateManager.__index = StateManager
StateManager.states = {}

local GLOBAL_STATE = 'Sync-GlobalState:Bucket'
local PLAYER_STATE = 'Sync-PlayerState:Bucket'
local SERVER_EVENT = 'Sync-ServerEvent:Set'
local CLIENT_EVENT = 'Sync-ClientEvent:Set'

function StateManager:new(name, default)
    local instance = setmetatable({}, StateManager)
    instance.name = name
    instance.default = default

    -- Event Handler
    AddEventHandler(SERVER_EVENT .. name, function(bucket, value)
        instance:set(bucket, value)
    end)

    -- Insert into static states.
    table.insert(StateManager.states, instance)

    print('Created State Manager for ' .. name .. ' with default value ' .. tostring(default))
    print(GLOBAL_STATE .. name)
    print(SERVER_EVENT .. name)
    print(CLIENT_EVENT .. name)

    return instance
end

function StateManager:set(bucket, value)
    GlobalState:set(GLOBAL_STATE .. self.name .. bucket, value)

    -- Loop through all players inside the bucket and update players instantly using state through VerifyIntegrity
    for _, player in ipairs(GetPlayers()) do
        local playerId = tonumber(player)
        if Player(player).state[PLAYER_STATE] == tonumber(bucket) then
            if playerId then
                -- Loop through bucket data ensure we have proper data
                print('Setting ' .. self.name .. ' for player ' .. playerId .. ' to ' .. tostring(value))
                TriggerClientEvent(CLIENT_EVENT .. self.name, playerId, value)
            end
        end
    end
end

function StateManager:getStateManagers()
    return StateManager.states
end

-- State Managers
TimeState = StateManager:new('Time', { hour = 12, minute = 0, second = 0 })
WeatherState = StateManager:new('Weather', 'EXTRASUNNY')
TimeScaleState = StateManager:new('TimeScale', 1.0)
BlackoutState = StateManager:new('Blackout', { all = false, vehicleLights = false })
FriendlyFireState = StateManager:new('FriendlyFire', false)

return StateManager
