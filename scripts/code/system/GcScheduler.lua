--- GcScheduler.lua is a system module that manages the scheduling and execution of garbage collection functions in a Lua environment. It allows for the registration of functions to be executed at specified intervals, with optional staggering to avoid simultaneous execution. The module provides methods to register, unregister, and update the scheduled functions, ensuring efficient memory management in applications.
-- @author PingouinTheDev

local Types = require("code/utils/Types")
local GCScheduler = {}
GCScheduler.gcFunctions = {}

--- Register a garbage collection function to be executed periodically.
-- @param gcFunction (function) The function to be executed for garbage collection.
-- @param interval (number) The time interval in seconds between executions of the function.
-- @param stagger (boolean) If true, the initial execution of the function will be staggered by a random offset within the interval.
function GCScheduler.RegisterGC(gcFunction, interval, stagger)
    local initialOffset = stagger and (math.random() * interval) or 0
    table.insert(GCScheduler.gcFunctions, {
        fn = gcFunction,
        interval = interval,
        timer = initialOffset
    })
end

--- Unregister a previously registered garbage collection function.
-- @param gcFunction (function) The function to be unregistered.
function GCScheduler.UnregisterGC(gcFunction)
    for i = #GCScheduler.gcFunctions, 1, -1 do
        if GCScheduler.gcFunctions[i].fn == gcFunction then
            table.remove(GCScheduler.gcFunctions, i)
            break
        end
    end
end

--- Update function to be called every frame to check if any registered GC functions need to be executed.
-- @param deltaTime (number) The time elapsed since the last frame, in seconds.
function GCScheduler.Update(deltaTime)
    -- Iterate by index avoiding issues with table modification during iteration
    for i = 1, #GCScheduler.gcFunctions do
        local entry = GCScheduler.gcFunctions[i]
        if entry then
            entry.timer = entry.timer + deltaTime
            if entry.timer >= entry.interval then
                entry.timer = entry.timer - entry.interval

                Types.TryCall("Execute scheduled garbage collection", entry.fn)
            end
        end
    end
end

-- Runs the GCScheduler update in a loop with a fixed delta time of 0.016 seconds (approximately 60 FPS).
LoopAsync(16, function() 
    GCScheduler.Update(0.016)
    return false
end)

return GCScheduler