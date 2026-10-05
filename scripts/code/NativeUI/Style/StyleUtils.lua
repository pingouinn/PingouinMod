local StyleExtractor = require("code/NativeUI/Style/StyleExtractor")

local StyleHelper = {}
local Cache = {}

--- Resolves a style identifier or asset path to a style UObject.
-- @param category (string) Style category, such as Button or Text.
-- @param stylePath (string|UObject) Style identifier, asset path, or style object.
-- @return (UObject|nil) Resolved style object, or nil when unavailable.
function StyleHelper.ResolveStyle(category, stylePath)
    if not stylePath then return nil end
    if Utils.IsValidObject(stylePath) then return stylePath end

    -- Cache paresseux par catégorie ("Button", "Text", etc.)
    if not Cache[category] or not next(Cache[category]) then
        Cache[category] = StyleExtractor.GetCachedStyleType(category) or {}
    end

    local path = Cache[category][stylePath] or stylePath
    local styleObj = StaticFindObject(path)

    if Utils.IsValidObject(styleObj) then
        return styleObj
    end

    return nil
end

return StyleHelper