---@meta nativefs

--- NativeFS annotations
--- Partially based on (and depends on) love.filesystem annotations. 

local nativefs = {}

---@class File: love.File

---@param name string The name of the file.
---@return File file New File object.
function nativefs.newFile(name) end

---@param filepath string Path to the file. 
---@return string|love.FileData? data The file data.
---@return string? error
function nativefs.newFileData(filepath) end

---@param archive string
---@param mountPoint string
---@param appendToPath? boolean
---@return boolean success
function nativefs.mount(archive, mountPoint, appendToPath) end

---@param archive string
---@return boolean success
function nativefs.unmount(archive) end

---@param containerOrName string
---@param nameOrSize? number|string
---@param sizeOrNil? number|nil
---@return string|love.FileData?
---@return number|string? size Returns as string if error
function nativefs.read(containerOrName, nameOrSize, sizeOrNil) end

---@param name string
---@param data string
---@param size? number|"all"
---@return boolean
---@return string? error
function nativefs.write(name, data, size) end

---@param name string
---@param data string
---@param size? number|"all"
---@return boolean
---@return string? error
function nativefs.append(name, data, size) end

---@param name string
---@return function iterator # Iterates over each line
function nativefs.lines(name) end

---@param name string
---@return function? chunk
---@return string? error
function nativefs.load(name) end

---@return string cwd Current working directory
function nativefs.getWorkingDirectory() end

---@param path string
---@return boolean
---@return string? error
function nativefs.setWorkingDirectory(path) end

---@return string[]
function nativefs.getDriveList() end

---@param path string
---@return boolean 
---@return string? error
function nativefs.createDirectory(path) end

---@param name string
---@return boolean 
---@return string? error
function nativefs.remove(name) end

---@param dir string
---@return string[] files
function nativefs.getDirectoryItems(dir) end

---@param path string
---@param filtertype? love.FileType
---@return table|{type: love.FileType, size: number, modtime: number}[] info_array
function nativefs.getDirectoryItemsInfo(path, filtertype) end

---@param path string
---@param filtertype? love.FileType
---@return table|{type: love.FileType, size: number, modtime: number} info
function nativefs.getInfo(path, filtertype) end

---@param path string
---@return string
--- Given a file path, looks for a valid file path that is equivalent to the input up to case. Does nothing on case insensitive filesystems.
function nativefs.getNormalizedPath(path) end


return nativefs