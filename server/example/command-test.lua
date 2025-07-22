RegisterCommand('settime', function(source, args, raw)
    local bucket = args[1]
    local hour = tonumber(args[2])
    local minute = tonumber(args[3])
    local second = tonumber(args[4])

    print('Set time: ' .. hour .. ':' .. minute .. ':' .. second .. ' for bucket: ' .. bucket)
    TriggerEvent('Sync-ServerEvent:SetTime', bucket, { hour = hour, minute = minute, second = second })
end, true)

RegisterCommand('setweather', function(source, args, raw)
    local bucket = args[1]
    local weather = args[2]

    print('Set weather: ' .. weather .. ' for bucket: ' .. bucket)
    TriggerEvent('Sync-ServerEvent:SetWeather', bucket, weather)
end, true)

RegisterCommand('settimescale', function(source, args, raw)
    local bucket = args[1]
    local timeScale = tonumber(args[2])

    print('Set time scale: ' .. timeScale .. ' for bucket: ' .. bucket)
    TriggerEvent('Sync-ServerEvent:SetTimeScale', bucket, timeScale)
end, true)

RegisterCommand('setblackout', function(source, args, raw)
    local bucket = args[1]
    local all = args[2]
    local vehicleLights = args[3]

    print('Set blackout: all=' .. tostring(all) .. ', vehicleLights=' .. tostring(vehicleLights) .. ' for bucket: ' .. bucket)
    TriggerEvent('Sync-ServerEvent:SetBlackout', bucket, { all = all, vehicleLights = vehicleLights })
end, true)

RegisterCommand('setfriendlyfire', function(source, args, raw)
    local bucket = args[1]
    local condition = args[2]

    print('Set friendly fire: ' .. tostring(condition) .. ' for bucket: ' .. bucket)
    TriggerEvent('Sync-ServerEvent:SetFriendlyFire', bucket, condition)
end, true)