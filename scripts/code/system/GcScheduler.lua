-- This module provides periodic execution of registered GC functions.

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

-- Unregister a previously registered garbage collection function.
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

                local success, err = pcall(entry.fn)
                if not success then
                    print("[GCScheduler] Error during execution : " .. tostring(err))
                end
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