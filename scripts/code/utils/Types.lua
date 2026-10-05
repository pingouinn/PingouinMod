local Types = {}
local textLibrary = nil
local unpackValues = table.unpack or unpack

--- Packs variadic values while preserving trailing nil values.
-- @param ... (any) Values to pack.
-- @return (table) Packed values and their count.
local function PackValues(...)
    return {n = select("#", ...), ...}
end

local TEXT_LIBRARY_PATH = "/Script/Engine.Default__KismetTextLibrary"

--- Checks if an object is valid (not nil and not destroyed).
-- @param object (UObject) The object to check
-- @return (boolean) True if the object is valid, false otherwise
function Types.IsValidObject(object)
    if not object then return false end
    local success, valid = pcall(function() return object:IsValid() end)
    return success and valid == true
end

--- Unwraps a value returned through a UE4SS remote parameter.
-- @param value (any) A direct value or a UE4SS remote parameter
-- @return (any) The unwrapped value, or the original value when unchanged
function Types.UnwrapValue(value)
    if not value then return nil end
    local success, unwrappedValue = pcall(function() return value:get() end)
    if success and unwrappedValue and unwrappedValue ~= value then return unwrappedValue end
    return value
end

--- Reads a numeric value returned directly or wrapped by UE4SS.
-- @param value (any) A number or UE4SS numeric parameter
-- @return (number|nil) The numeric value, or nil when unavailable
function Types.ReadNumber(value)
    value = Types.UnwrapValue(value)
    if type(value) == "number" then return value end
    return nil
end

--- Reads one component from a vector returned by UE4SS.
-- @param vector (FVector|UScriptStruct) The vector to inspect
-- @param component (string) The component name, such as X, Y, or Z
-- @return (number|nil) The component value, or nil when unavailable
function Types.ReadVectorComponent(vector, component)
    vector = Types.UnwrapValue(vector)
    if not vector then return nil end
    local success, value = pcall(function() return vector[component] end)
    if not success then return nil end
    return Types.ReadNumber(value)
end

--- Reads and normalizes a three-dimensional vector.
-- @param vector (FVector|UScriptStruct|table) The vector to read
-- @return (table|nil) A table with numeric X, Y, and Z fields, or nil when invalid
function Types.ReadVector(vector)
    vector = Types.UnwrapValue(vector)
    if not vector then return nil end
    local x = Types.ReadVectorComponent(vector, "X")
    local y = Types.ReadVectorComponent(vector, "Y")
    local z = Types.ReadVectorComponent(vector, "Z")
    if type(vector) == "table" then
        x, y, z = x or Types.ReadNumber(vector[1]), y or Types.ReadNumber(vector[2]), z or Types.ReadNumber(vector[3])
    end
    if not x or not y or not z then return nil end
    return {X = x, Y = y, Z = z}
end

--- Normalizes a vector represented as a table with named keys.
-- @param value (table) The vector to normalize
-- @param namedKeys (table) A table containing the names of the keys to use for the vector components
-- @return (table|nil) A normalized vector table with the same named keys, or nil if the input is invalid
function Types.NormalizeVector(value, namedKeys)
    if type(value) ~= "table" then return nil end
    local first, second, third = value[namedKeys[1]], value[namedKeys[2]], value[namedKeys[3]]
    if first == nil then first, second, third = value[1], value[2], value[3] end
    first, second, third = tonumber(first), tonumber(second), tonumber(third)
    if first == nil or second == nil or third == nil then return nil end
    return {[namedKeys[1]] = first, [namedKeys[2]] = second, [namedKeys[3]] = third}
end

--- Converts a Lua value to an Unreal FText.
-- @param value (any) Text content to convert.
-- @return (FText|nil) The converted text, or nil when the text library is unavailable.
function Types.ToFText(value)
    if not Types.IsValidObject(textLibrary) then
        local success, library = pcall(function()
            return StaticFindObject(TEXT_LIBRARY_PATH)
        end)
        textLibrary = success and library or nil
    end

    if not Types.IsValidObject(textLibrary) then return nil end

    local success, text = pcall(function()
        return textLibrary:Conv_StringToText(tostring(value or ""))
    end)
    if not success then return nil end
    return text
end

--- Executes a protected operation and reports failures with a consistent prefix.
-- @param operationName (string) Operation description used in the error message.
-- @param callback (function) Operation to execute.
-- @return (boolean, any) Success state and callback results or error message.
function Types.TryCall(operationName, callback)
    if type(callback) ~= "function" then
        return false, "callback must be a function"
    end

    local results = PackValues(pcall(callback))
    if not results[1] then
        print(string.format("[PingouinMod Error] %s: %s", operationName, tostring(results[2])))
        return false, results[2]
    end

    return true, unpackValues(results, 2, results.n)
end

--- Constructs a UE4SS object, retrying with the extended signature when needed.
-- @param objectClass (UClass) Class to instantiate.
-- @param outer (UObject) Memory owner for the new object.
-- @return (UObject|nil) Constructed object, or nil when construction fails.
function Types.ConstructObject(objectClass, outer)
    if not StaticConstructObject or not Types.IsValidObject(objectClass) or not Types.IsValidObject(outer) then
        return nil
    end

    local success, instance = Types.TryCall("StaticConstructObject", function()
        return StaticConstructObject(objectClass, outer)
    end)
    if success and Types.IsValidObject(instance) then return instance end

    success, instance = Types.TryCall("StaticConstructObject extended signature", function()
        return StaticConstructObject(objectClass, outer, nil, 0, 0, false, nil)
    end)
    if success and Types.IsValidObject(instance) then return instance end
    return nil
end



return Types