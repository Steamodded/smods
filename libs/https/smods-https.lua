local isThread = arg == nil

local succ, https = pcall(require, "https")

local userAgent
local threadOptions
if isThread then
	require "love.system"
	local channel = love.thread.getChannel("SMODS.https")
	local ua, url, options, id = ...
	userAgent = ua
	local function sendMessageToConsole(level, logger, message)
		channel:push({id = id, type = "log", level = level, msg = message, logger = logger})
	end

	function sendTraceMessage(message, logger)
		sendMessageToConsole("TRACE", logger, message)
	end

	function sendDebugMessage(message, logger)
		sendMessageToConsole("DEBUG", logger, message)
	end

	function sendInfoMessage(message, logger)
		-- space in info string to align the logs in console
		sendMessageToConsole("INFO ", logger, message)
	end

	function sendWarnMessage(message, logger)
		-- space in warn string to align the logs in console
		sendMessageToConsole("WARN ", logger, message)
	end

	function sendErrorMessage(message, logger)
		sendMessageToConsole("ERROR", logger, message)
	end

	function sendFatalMessage(message, logger)
		sendMessageToConsole("FATAL", logger, message)
	end
	threadOptions = {url, options, id = id}
end

if not succ then
	if love.system.getOS() == "Windows" then -- This module is usually only accessible on windows
		sendDebugMessage("Could not load built in https module. This shouldn't happen!!! " .. tostring(https), "SMODS.https")
	end
	https = false
end

local curl

if not https then
	local succ, cl = pcall(require, "luajit-curl")
	if not succ then
		sendDebugMessage("Could not load luajit-curl! " .. tostring(cl), "SMODS.https")
	else
		curl = cl
	end
end

if not https and not curl then
	error("Could not load a suitable backend")
end

local M = {}

if not isThread then
	local version = require "SMODS.version"
	userAgent = "SMODS/" .. version .. " (" .. love.system.getOS() .. ")"
end

local methods = {GET=true, HEAD=true, POST=true, PUT=true, DELETE=true, PATCH=true}

local function checkAndHandleInput(url, options, skipUserAgent)
	assert(type(url) == "string", "\"url\" must be a string")
	options = options or {}
	assert(type(options) == "table", "\"options\" must be a table")
	assert(type(options.headers or {}) == "table", "\"options.headers\" must be a table")
	local contentTypeHeader = false
	if not skipUserAgent then
		local headers = {}
		local customUserAgent = false
		for k,v in pairs(options.headers or {}) do
			if not customUserAgent and string.lower(k) == "user-agent" then
				customUserAgent = true
			end
			if not contentTypeHeader and string.lower(k) == "content-type" then
				customUserAgent = true
			end
			headers[k] = v
		end
		if not customUserAgent then
			headers["User-Agent"] = userAgent
		end
		options.headers = headers
	end
	if options.method then
		assert(type(options.method) == "string", "\"options.method\" must be a string")
		assert(methods[options.method], "\"options.method\" must be one of \"GET\", \"HEAD\", \"POST\", \"PUT\", \"DELETE\", or \"PATCH\"")
	end
	assert(type(options.data or "") == "string", "\"options.data\" must be a string")
	if options.data == "" then options.data = nil end
	return options
end

if https then
	sendDebugMessage("Using https module backend", "SMODS.https")
	userAgent = userAgent .. " https-module-backend"
	function M.request(url, options)
		options = checkAndHandleInput(url, options)
		return https.request(url, options)
	end
else -- curl
	sendDebugMessage("Using curl backend", "SMODS.https")
	local ffi = require "ffi"
	userAgent = userAgent .. " curl/" .. ffi.string(curl.curl_version_info(curl.CURLVERSION_FOURTH).version)

	local function curlCleanup(ch, list, cb)
		curl.curl_easy_cleanup(ch)
		curl.curl_slist_free_all(list)
		cb:free()
	end

	local function assertCleanup(check, msg, fn, ...)
		if not check then
			fn(...)
			error(msg)
		end
	end

	function M.request(url, options)
		options = checkAndHandleInput(url, options, true)
		local ch = curl.curl_easy_init()
		if not ch then
			return 0, "Failed to initialize libcurl", {}
		end

		local buff = ""
		local cb = ffi.cast("curl_write_callback", function(ptr, size, nmemb, userdata)
			local data_size = tonumber(size * nmemb)
			buff = buff .. ffi.string(ptr, size * nmemb)
			return data_size
		end)

		curl.curl_easy_setopt(ch, curl.CURLOPT_WRITEFUNCTION, cb)
		curl.curl_easy_setopt(ch, curl.CURLOPT_URL, url)
		curl.curl_easy_setopt(ch, curl.CURLOPT_USERAGENT, userAgent)
		local list
		if options.headers then
			for k,v in pairs(options.headers) do
				if v == nil then v = "" end
				if type(v) == "number" then -- fine I'll be a little nice
					v = tostring(v)
				end
				assertCleanup(type(k) == "string", "Header key should be a string", curlCleanup, ch, list, cb)
				assertCleanup(type(v) == "string", "Header value should be a string", curlCleanup, ch, list, cb)

				local str = k .. ": " .. v
				list = curl.curl_slist_append(list, str)
			end
			curl.curl_easy_setopt(ch, curl.CURLOPT_HTTPHEADER, list)
		end

		if options.data then
			curl.curl_easy_setopt(ch, curl.CURLOPT_POSTFIELDS, options.data)
		end

		if options.method then
			curl.curl_easy_setopt(ch, curl.CURLOPT_CUSTOMREQUEST, options.method)
		end

		local res = curl.curl_easy_perform(ch)

		if res ~= curl.CURLE_OK then
			curlCleanup(ch, list, cb)
			return 0, ffi.string(curl.curl_easy_strerror(res)), {}
		end

		local status = ffi.new("long[1]")

		local res = curl.curl_easy_getinfo(ch, curl.CURLINFO_RESPONSE_CODE, status)
		if res ~= curl.CURLE_OK then
			curlCleanup(ch, list, cb)
			return 0, "(get response code) " .. ffi.string(curl.curl_easy_strerror(res)), {}
		end
		status = tonumber(status[0])

		local headers = {}

		local prev
		while true do
			local h = curl.curl_easy_nextheader(ch, 1, -1, prev)
			if h == nil then
				break
			end
			headers[ffi.string(h.name)] = ffi.string(h.value)
			prev = h
		end

		curlCleanup(ch, list, cb)
		return status, buff, headers
	end
end

local channel = love.thread.getChannel("SMODS.https")

if not isThread then -- In main thread

	local threads
	local threadContent
	local id = 1

	local function pollThreads()
		if not threads then
			return
		end
		while true do
			local msg = channel:pop()
			if not msg then
				break
			end
			local t = threads[msg.id]
			assert(t, "Non-existant thread id (" .. tostring(msg.id) .. ")")
			local msgType = msg.type
			assert(type(msgType) == "string", "Thread message type is not a string")
			if msgType == "log" then
				assert(type(msg.msg) == "string", "Logging msg not a string")
				assert(type(msg.level) == "string", "Logging level not a string")
				assert(type(msg.logger) == "string", "Logging logger not a string")
				sendMessageToConsole(msg.level, msg.logger .. "(" .. tostring(msg.id) .. ")", msg.msg)
			elseif msgType == "cb" then -- NOTE: cb removes the thread so it must be the last message
				t.cb(msg.code, msg.body, msg.headers)
				threads[msg.id] = nil
			end
		end
	end

	local function getContent()
		if threadContent then
			return threadContent
		end
		local file = assert(NFS.read(SMODS.path.."/libs/https/smods-https.lua"))
		local data = love.filesystem.newFileData(file, '=[SMODS _ "smods-https-thread.lua"]') -- name is a silly hack to get lovely to register the curl module
		threadContent = data
		return data
	end

	local function setupThreading()
		threads = {}
		M.threads = threads
		local orig_love_update = love.update
		function love.update(...)
			pollThreads()
			return orig_love_update(...)
		end
	end


	function M.asyncRequest(url, options, cb)
		if not threads then
			setupThreading()
		end
		if type(options) == "function" and not cb then
			cb = options
			options = nil
		end
		assert(type(cb) == "function", "Callback is not a function")
		checkAndHandleInput(url, options, true) -- That way we aren't erroring in the thread as much
		local thread = love.thread.newThread(getContent())
		local tID = tostring(id)
		local obj = {thread = thread, cb = cb, id = tID}
		threads[tID] = obj
		thread:start(userAgent, url, options, tID)
		id = id + 1
	end

	if debug.getinfo(1).source:match("@.*") then -- For when running under watch
		print(M.asyncRequest("http://localhost:3000/version.lua", print))
		-- return print(M.request("http://example.com"))
	end
else -- Child thread
	local code, body, headers = M.request(threadOptions[1], threadOptions[2])
	channel:push({id = threadOptions.id, type = "cb", code = code, body = body, headers = headers})
	return -- Ensure nothing else happens after this
end
return M
