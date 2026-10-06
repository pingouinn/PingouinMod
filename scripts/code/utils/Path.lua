--- Path.lua provides utility functions for handling file paths, including sanitization and dynamic loading of UE4SS dump files. It ensures compatibility with different path formats and manages the loading of large Lua files by adjusting their scope.
-- @author PingouinTheDev

local Path = {}

--- Corrects the path separators in a given path string.
-- @param path (string) The path with \
-- @return (string) The cleaned path with /
function Path.SanitizePath(path)
    if type(path) ~= "string" then return nil end
    return (path:gsub("\\", "/"))
end

--- Retrieves the mod folder path from a script's full path.
-- @param scriptFullPath (string) The full path of the script
-- @return (string) The mod folder path
function Path.GetModFolder(scriptFullPath)
    return scriptFullPath:match("^(.*)/PingouinMod/") or ""
end

--- Dynamically requires a UE4SS dump file, patching it to use global variables, because it overlaps the 200 local limit.
-- @param filePath (string) The file path to the UE4SS dump Lua file
-- @return (table) The environment table containing the dumped variables, or nil and an error
function Path.RequireUE4SSDump(filePath)
    local file = io.open(filePath, "rb")
    if not file then return nil, "[PingouinMod] File not found: " .. filePath end
    local content = file:read("*a")
    file:close()
    if type(content) ~= "string" then
        return nil, "[PingouinMod] Failed to read file: " .. tostring(filePath)
    end

    local environment = {}
    setmetatable(environment, {__index = _G})
    local chunk, err = load(content:gsub("local ", ""), filePath, "t", environment)
    if not chunk then return nil, "Erreur de compilation : " .. tostring(err) end
    chunk()
    return environment
end

return Path