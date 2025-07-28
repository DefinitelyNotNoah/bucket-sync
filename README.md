### 🌍 BucketSync, a bucket-based environment synchronization resource for FiveM, built for developers.

BucketSync is a designed to give you complete control over your server's environment, providing a server-authoritative system for synchronizing time, weather, and other world states across all players.
Its core purpose is to allow for instanced zones using FiveM's routing bucket system, enabling different players to exist in separate "worlds" with unique environmental conditions simultaneously.

### ✨ Features
 * **Server-Authoritative Synchronization:** All state changes are controlled by the server, providing a single source of truth and preventing client-side manipulation.

 * **Routing Buckets**: Create and manage multiple routing buckets, each with its own independent time, weather, and game rules. Ideal for minigames, instanced housing, or separate roleplay scenarios.

 * **Dynamic State Management**: Time progresses naturally in each bucket, and server admins can dynamically change any state variable (like weather) on the fly.

 * **Anti-Tampering**: BucketSync includes a built-in integrity check that ensures players remain in their assigned routing bucket, preventing them from going into other buckets unauthorized, or tampering with environment values that differ from what is set on server-side. A main loop on the server periodically sends state data to clients in each bucket via a VerifyIntegrity event, ensuring everyone stays synchronized.

### 🌦️ Synced States (❌ = TODO)
* ✅ Weather
* ✅ Time
* ✅ Time Scale
* ✅ Blackout
* ✅ Friendly Fire
* ❌ Timecycle

### 📝 Install
* Download [Latest Release](https://github.com/DefinitelyNotNoah/bucket-sync/releases/)
* Drop `bucketsync` into your resource directory.
* Add `ensure bucketsync` to your server.cfg file.

## Client Events
  Events follow the format `[RESOURCE_NAME]-[CLIENT/SERVER]:[EVENT_NAME]`

**`Sync-ClientEvent:VerifyIntegrity`**  
> Sends server data to clients to synchronize their environment to the values the server has set.

## Server Events
You will mainly be executing server events. Client events are executed inside Sync-ClientEvent:VerifyIntegrity on a 2-second interval server-side. Meaning that no matter what client events get executed, it'll always be overridden by server-side state after 2 seconds.

**`Sync-ServerEvent:InitBucket [bucket: int] [lockdownMode: [strict | relaxed | inactive]`**  
> Initializes a routing bucket server-wide. 2nd argument is lockdown mode, and is represented as a string.

**`Sync-ServerEvent:SetPlayerToBucket [playerId: int] [bucket: int]`**  
> Assigns a client's routing bucket to the bucket provided.

**`Sync-ServerEvent:SetTime [bucket: int] [hour: int] [minute: int] [second: int]`**  
> Sets the time on a routing bucket.

**`Sync-ServerEvent:SetWeather [bucket: int] [weatherType: string]`**  
> Sets the time on a routing bucket. View weather types here https://docs.fivem.net/natives/?_0x29B487C359E19889

**`Sync-ServerEvent:SetTimeScale [bucket: int] [amount float]`**  
> Sets the time scale on a routing bucket. Any value less than 1.0 will slow the game down for every client inside the bucket. No change will occur with values past 1.0. Minimum is 0.0.

**`Sync-ServerEvent:SetBlackout [bucket: int] [allLights: boolean] [includeVehicleLights: boolean]`**  
> Sets blackout condition on a routing bucket. Will turn of all lights for all clients in-game.

**`Sync-ServerEvent:SetFriendlyFire [bucket: int] [condition: boolean]`**  
> Set friendly-fire option on a routing bucket.


## Server-Side Commands
Commands that were made for testing.

**`initbucket [bucket] [lockdownMode: strict | relaxed | inactive]`**  
> Initializes a routing bucket server-wide. Must be used before utilizing the bucket.

**`setbucketpop [bucket] [population: int]`**  
> Set's the population on a routing bucket, any over 0 is considered true.

**`setbucketlockdown [bucket] [lockdownMode: strict | relaxed | inactive]`**  
> Set's the lockdown mode for a routing bucket. 2nd argument is lockdown mode, and is represented as a string.

**`setbucket [playerId: int] [bucket: int]`**  
> Assigns a client's routing bucket to the bucket provided.

## Global States
The entire resource is built around the concept of global states, which are stored in a global state bag. This allows for easy access to the current state of all routing buckets and their properties, as well as prioritize data integrity across resource restarts.  

Each bucket in BucketSync is represented as an object with the following properties:
```json
{
    "FriendlyFire": false
    "Time": {
        "hour": 12,
        "minute": 0,
        "second": 0
    },
    "Weather": "EXTRASUNNY",
    "TimeScale": 1.0,
    "Blackout": {
        "all": false,
        "vehicleLights": false
    },
}
```

Developers will only need to worry about the `Sync-GlobalState:InitializedBuckets` state to find the total amount of buckets that have been initialized through the server's runtime. Every other GlobalState will lack documentation since it's meant to be used internally by the resource. However, feel free to view the source code to see how the resource uses the global states.

**`Sync-GlobalState:InitializedBuckets`**  
Holds an integer array of all initialized buckets e.g. [0, 1, 2, 3, 4]
```lua
-- Lua
local initializedBuckets = GlobalState['Sync-GlobalState:InitializedBuckets'] or {}
print('Total initialized buckets: ' .. #initializedBuckets)
```
```cs 
// C# Mono v2
object[] buckets = StateBag.Global.Get("Sync-GlobalState:InitializedBuckets");
if (buckets != null)
{
    Debug.WriteLine("Bucket Length: " + buckets.Length);
}
```

## Example Resource
A server-side lua file demonstrating usage has been provided at `example/command-test.lua`
```lua
RegisterCommand('settime', function(source, args, raw)
    local bucket = args[1]
    local hour = tonumber(args[2])
    local minute = tonumber(args[3])
    local second = tonumber(args[4])

    print('Set time: ' .. hour .. ':' .. minute .. ':' .. second)
    TriggerEvent('Sync-ServerEvent:SetTime', bucket, { hour = hour, minute = minute, second = second })
end, true)

RegisterCommand('setweather', function(source, args, raw)
    local bucket = args[1]
    local weather = args[2]

    TriggerEvent('Sync-ServerEvent:SetWeather', bucket, weather)
end, true)

RegisterCommand('settimescale', function(source, args, raw)
    local bucket = args[1]
    local timeScale = tonumber(args[2])

    TriggerEvent('Sync-ServerEvent:SetTimeScale', bucket, timeScale)
end, true)

RegisterCommand('setblackout', function(source, args, raw)
    local bucket = args[1]
    local all = args[2]
    local vehicleLights = args[3]

    TriggerEvent('Sync-ServerEvent:SetBlackout', bucket, { all = all, vehicleLights = vehicleLights })
end, true)

RegisterCommand('setfriendlyfire', function(source, args, raw)
    local bucket = args[1]
    local condition = args[2]

    TriggerEvent('Sync-ServerEvent:SetFriendlyFire', bucket, condition)
end, true)
```

## Showcase
[![View Video](https://i.ibb.co/RkmV0gxT/p8vj04.jpg)](https://streamable.com/p8vj04)

## Note
This resource has not been tested for production, or large scale servers. Performance metrics are unknown.







