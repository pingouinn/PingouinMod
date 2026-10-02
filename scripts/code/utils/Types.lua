local Types = {}

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

return Types