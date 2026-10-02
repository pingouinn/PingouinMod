local Types = require("code/utils/Types")
local Math = {}

--- Teleports the player to a specified position and rotation.
-- @param Position (table) A table with X, Y, Z fields representing the current position
-- @param Rotation (table) A table with Pitch, Yaw, Roll fields representing the target rotation
-- @param distance (number) Distance to offset in the direction vector
-- @return (number, number, number) The new X, Y, Z coordinates after applying the offset
function Math.GetPositionInFront(Position, Rotation, distance)
    local KsmMath = UEHelpers:GetKismetMathLibrary()
    if not Types.IsValidObject(KsmMath) then print("[PingouinMod] KismetMathLibrary not valid\n") return Position end
    local AddValue = KsmMath:Multiply_VectorFloat(KsmMath:GetForwardVector(Rotation), distance)
    return KsmMath:Add_VectorVector(Position, AddValue)
end

--- Computes the forward vector from pitch and yaw angles.
-- @param Rotation (table) A table with Pitch, Yaw, Roll fields
-- @return (table) A table representing the forward vector with X, Y, Z fields
function Math.GetForwardVector(Rotation)
    local KsmMath = UEHelpers:GetKismetMathLibrary()
    if not Types.IsValidObject(KsmMath) then print("[PingouinMod] KismetMathLibrary not valid\n") return {X = 0, Y = 0, Z = 0} end
    return KsmMath:GetForwardVector(Rotation)
end

--- Checks if two locations are approximately equal within a given tolerance.
-- @param locA (table) First location with X, Y, Z fields
-- @param locB (table) Second location with X, Y, Z fields
-- @param tolerance (number) The maximum allowed difference for each coordinate
-- @return (boolean) True if locations are approximately equal, false otherwise
function Math.CheckLocationEquality(locA, locB, tolerance)
    if locA == nil or locB == nil then return false end
    tolerance = tolerance or 0.01
    return math.abs(locA.X - locB.X) <= tolerance and
           math.abs(locA.Y - locB.Y) <= tolerance and
           math.abs(locA.Z - locB.Z) <= tolerance
end

return Math