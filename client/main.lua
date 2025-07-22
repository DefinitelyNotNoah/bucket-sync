local function setClientTime(time)
    -- print('Setting Time: ' .. time.hour .. ':' .. time.minute .. ':' .. time.second)
    NetworkOverrideClockTime(time.hour, time.minute, time.second)
end

local function setClientWeather(weather)
    -- print('Setting Weather: ' .. weather)
    SetWeatherTypeNow(weather);
    SetWeatherTypeOverTime(weather, 0.0);

    SetForceVehicleTrails(string.lower(weather) == "xmas");
    SetForcePedFootstepsTracks(string.lower(weather) == "xmas");
end

local function setClientTimeScale(timeScale)
    -- print('Setting Time Scale: ' .. timeScale)
    SetTimeScale(timeScale)
end

local function setClientBlackout(condition)
    -- print('Setting Blackout: ' .. tostring(condition.all) .. ' ' .. tostring(condition.vehicleLights))
    SetArtificialLightsState(condition.all == "true")
    SetArtificialLightsStateAffectsVehicles(condition.vehicleLights == "true")
end

local function setFriendlyFire(condition)
    -- print('Setting Friendly Fire: ' .. tostring(condition))
    NetworkSetFriendlyFireOption(condition == 'true')
end

RegisterNetEvent('Sync-ClientEvent:SetTime', function(time)
    setClientTime(time)
end)

RegisterNetEvent('Sync-ClientEvent:SetWeather', function(weather)
    setClientWeather(weather)
end)

RegisterNetEvent('Sync-ClientEvent:SetTimeScale', function(timeScale)
    setClientTimeScale(timeScale)
end)

RegisterNetEvent('Sync-ClientEvent:SetBlackout', function(condition)
    setClientBlackout(condition)
end)

RegisterNetEvent('Sync-ClientEvent:SetFriendlyFire', function(condition)
    setFriendlyFire(condition)
end)

RegisterNetEvent('Sync-ClientEvent:VerifyIntegrity', function(data)
    -- Time
    local hour = GetClockHours()
    local minute = GetClockMinutes()

    -- If the time is over the bucket time by an hour, update the time.
    -- Calculate the difference in minutes
    local timeDiff = math.abs((hour * 60 + minute) - (data.Time.hour * 60 + data.Time.minute))

    if timeDiff >= 60 then
        print('Time is not equal to bucket time, updating time.')
        setClientTime(data.Time)
    end

    -- Weather
    if not IsPrevWeatherType(data.Weather) then
        setClientWeather(data.Weather)
        print('Weather is not equal to bucket weather, updating weather to. ' .. data.Weather)
    end

    -- Time Scale
    setClientTimeScale(data.TimeScale)

    -- Blackout
    setClientBlackout(data.Blackout)

    -- Friendly Fire
    setFriendlyFire(data.FriendlyFire)
end)

-- Commands to test integrity system
-- RegisterCommand('setfaketime', function(source, args, raw)
--     local hour = tonumber(args[1])
--     local minute = tonumber(args[2])
--     local second = tonumber(args[3])
--     local time = { hour = hour, minute = minute, second = second }
--     print('Setting Time: ' .. time.hour .. ':' .. time.minute .. ':' .. time.second)
--     setClientTime(time)
-- end, false)

-- RegisterCommand('setfakeweather', function(source, args, raw)
--     local weather = args[1]
--     setClientWeather(weather)
-- end, false)

-- RegisterCommand('setfaketimescale', function(source, args, raw)
--     local timeScale = tonumber(args[1])
--     print('Setting Time Scale: ' .. timeScale)
--     if timeScale then
--         SetTimeScale(timeScale)
--     end
-- end, false)