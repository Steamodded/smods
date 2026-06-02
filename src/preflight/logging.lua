--- STEAMODDED CORE
--- MODULE LOGGING

function initializeSocketConnection()
    local socket = require("socket")
    local tcp = assert(socket.tcp())
    tcp:settimeout(1)
    local succ = tcp:connect("localhost", 53153)
    if not succ then
        print("Failed to connect to the debug server")
    else
        tcp:settimeout(5) -- Longer timeout for sending
        client = tcp
    end
end

-- message, logger in this order to preserve backward compatibility
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

function sendMessageToConsole(level, logger, message)
    level = level or "DEBUG"
    logger = logger or "DefaultLogger"
    message = message or "Default log message"
    date = os.date('%Y-%m-%d %H:%M:%S')
    print(date .. " :: " .. level .. " :: " .. logger .. " :: " .. message)
        if client then
        -- naive way to separate the logs if the console receive multiple logs at the same time
        client:send(date .. " :: " .. level .. " :: " .. logger .. " :: " .. message .. "ENDOFLOG")
    end
end

initializeSocketConnection()

-- Use the function to send messages
sendDebugMessage("Steamodded Debug Socket started !", "DebugConsole")


-----------------------------------------------
---------------MOD LOGGING END-----------------
