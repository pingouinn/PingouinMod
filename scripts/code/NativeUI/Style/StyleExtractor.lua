local StyleExtractor = {}

StyleExtractor.CachedStyles = {}

--- Analyzes an asset path to extract its style category and clean key.
-- @param fullClassPath (string) The full Unreal asset path
-- @return (string|nil) The style category (e.g., "Text", "Button") and the clean key (e.g., "Style_Text_Header1")
local function ResolveStyleMetadata(fullClassPath)
    local assetName = fullClassPath:match("%.([^%.]+)$") or fullClassPath:match("/([^/%.]+)$")
    if not assetName then return nil, nil end

    local cleanKey = assetName:gsub("_C$", "")
    
    -- Extract the category from the clean key, e.g., "Style_Text_Header1" -> "Text"
    local rawCategory = cleanKey:match("^Style_([^_]+)")
    if not rawCategory then return nil, nil end

    -- Remove the "Base" suffix from the category if present, e.g., "TextBase" -> "Text"
    local category = rawCategory:gsub("Base$", "")
    if category == "" then
        category = rawCategory -- Fallback to raw category if clean category is empty
    end

    return category, cleanKey
end

--- Scans the entire GUObjectArray to extract all style assets and cache them.
-- @param dumpFile (string|nil) Optional file to dump the global documentation.
-- @return (table) Cached styles organized by category.
function StyleExtractor.ScanAll(dumpFile)
    if not ForEachUObject then
        print("[PingouinMod ERROR] ForEachUObject is not available !")
        return StyleExtractor.CachedStyles
    end

    local totalCount = 0

    ForEachUObject(function(obj)
        local ok, fullName = pcall(function() return obj:GetFullName() end)
        if not ok or not fullName then return end

        if fullName:find("^BlueprintGeneratedClass%s+/Game/")
           and fullName:find("/UI/Styles/")
           and fullName:find("Style_") then

            local fullClassPath = fullName:match("^BlueprintGeneratedClass%s+(%S+)")
            if fullClassPath then
                local category, cleanKey = ResolveStyleMetadata(fullClassPath)

                if category and cleanKey then
                    if not StyleExtractor.CachedStyles[category] then
                        StyleExtractor.CachedStyles[category] = {}
                    end

                    if not StyleExtractor.CachedStyles[category][cleanKey] then
                        StyleExtractor.CachedStyles[category][cleanKey] = fullClassPath
                        totalCount = totalCount + 1
                    end
                end
            end
        end
    end)

    print(string.format("[PingouinMod] Scanned %d styles on %d categories.",
        totalCount, #StyleExtractor.GetAvailableCachedStylesTypes()))

    if dumpFile and totalCount > 0 then
        local f = io.open(dumpFile, "w")
        if f then
            f:write("-- Dump of all cached styles\nreturn {\n")
            for cat, styles in pairs(StyleExtractor.CachedStyles) do
                f:write(string.format("    [\"%s\"] = {\n", cat))
                for k, v in pairs(styles) do
                    f:write(string.format("        [\"%s\"] = \"%s\",\n", k, v))
                end
                f:write("    },\n")
            end
            f:write("}\n")
            f:close()
            print("[PingouinMod] Global dump generated : " .. dumpFile)
        end
    end

    return StyleExtractor.CachedStyles
end

--- Gets cached styles for a category, scanning on demand when necessary.
-- @param styleType (string) The style category (e.g., "Text", "Button").
-- @return (table) Cached styles indexed by clean style key.
function StyleExtractor.GetCachedStyleType(styleType)
    if not StyleExtractor.CachedStyles[styleType] then
        if not ForEachUObject then
            StyleExtractor.CachedStyles[styleType] = {}
            return StyleExtractor.CachedStyles[styleType]
        end
        -- If the category is not cached, we scan the GUObjectArray for this specific style type
        local targetPattern = "Style_" .. styleType
        local found = {}

        ForEachUObject(function(obj)
            local ok, fullName = pcall(function() return obj:GetFullName() end)
            if ok and fullName
               and fullName:find("^BlueprintGeneratedClass%s+/Game/")
               and fullName:find("/UI/Styles/")
               and fullName:find(targetPattern, 1, true) then

                local path = fullName:match("^BlueprintGeneratedClass%s+(%S+)")
                if path then
                    local _, cleanKey = ResolveStyleMetadata(path)
                    if cleanKey then found[cleanKey] = path end
                end
            end
        end)

        StyleExtractor.CachedStyles[styleType] = found
    end

    return StyleExtractor.CachedStyles[styleType]
end

--- Returns all cached styles organized by category.
-- @return (table) A table of cached styles organized by category.
function StyleExtractor.GetAllCachedStyles()
    return StyleExtractor.CachedStyles
end

--- Returns all cached style categories.
-- @return (table) A table containing the available style categories.
function StyleExtractor.GetAvailableCachedStylesTypes()
    local types = {}
    for k in pairs(StyleExtractor.CachedStyles) do
        table.insert(types, k)
    end
    return types
end

--- Returns the cached styles for a specific category.
-- @param styleType (string) The style category (e.g., "Text", "Button").
-- @return (table) A table of cached styles for the specified category, or nil if the category does not exist.
setmetatable(StyleExtractor, {
    __index = function(t, key)
        local category = key:match("^Cache(%w+)Styles$")
        if category then
            return function() return t.GetCachedStyleType(category) end
        end
        return nil
    end
})

-- Populate the cache when the module is loaded.
StyleExtractor.ScanAll()

return StyleExtractor