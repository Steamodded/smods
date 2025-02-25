---@meta SMODS.https

local https = {}

---@class Headers
---@field [string] string The headers.

---@class HttpsOptions
---@field headers? Headers Additional headers to add to the request as key-value pairs.
---@field method? "GET"|"POST"|"HEAD"|"PUT"|"DELETE"|"PATCH" HTTP method. If absent, it's either "GET" or "POST" depending on the data field.
---@field data? string Additional data to send as application/x-www-form-urlencoded (unless specified otherwise in Content-Type header).

---Make an http(s) request. Designed to work on more platforms out of the box, compared to Balatro's shipped https modules (which is only availible on Windows).
---The API is designed to mirror that of [lua-https](https://love2d.org/wiki/lua-https).
---@param url string The URL to request
---@param options? HttpsOptions Additional options for the request.
---@return number code HTTP status code, or 0 on failure.
---@return string|nil body The response body on success. Either nil or a description of the error on failure.
---@return Headers|nil headers HTTP response headers as key-value pairs, or nil on failure.
function https.request(url, options) end

---@alias Callback fun(code: number, body: string|nil, headers: Headers|nil)

---Make an async http(s) request. Designed to work on more platforms out of the box, compared to Balatro's shipped https modules (which is only availible on Windows).
---This API does not block with the request, and instead calls the passed callback when it's done.
---@param url string The URL to request
---@param optionsOrCallback HttpsOptions|Callback If callback is nil, this can be used as the callback. Otherwise used as options.
---@param callback? Callback The callback to call when the request is done. See https.request's return values for more info on passed arguments.
---@async
---@see https.request
function https.asyncRequest(url, optionsOrCallback, callback) end

return https
