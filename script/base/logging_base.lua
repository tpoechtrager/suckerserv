local _ = require "underscore"

local is_authserver = (server.is_authserver or 0) == 1

local filename = "server"
local admin_filename = "admin"

if is_authserver then
    filename = "authserver"
end

local logfile = io.open("log/" .. filename .. ".log","a+")

function server.log(msg)
    assert(msg ~= nil)
    msg = server.filtertext(msg)
    logfile:write(os.date("[%a %d %b %X] ",os.time()))
    logfile:write(msg)
    logfile:write("\n")
    logfile:flush()
end

local admin_logfile = io.open("log/" .. admin_filename .. ".log","a+")

function server.admin_log(msg)
    assert(msg ~= nil)
    msg = server.filtertext(msg)
    admin_logfile:write(os.date("[%a %d %b %X] ",os.time()))
    admin_logfile:write(msg)
    admin_logfile:write("\n")
    admin_logfile:flush()
end

server.event_handler("shutdown", _.curry(logfile.close, logfile))
server.event_handler("shutdown", _.curry(admin_logfile.close, admin_logfile))

if not server.is_authserver then

    function server.log_status(msg)
        print(msg)
    end
    
    function server.log_error(error_message)
        
        if type(error_message) == "table" and type(error_message[1]) == "string" then
            error_message = error_message[1]
        end
        
        io.stderr:write(os.date("[%a %d %b %X] ",os.time()))
        io.stderr:write(error_message)
        io.stderr:write("\n")
        io.stderr:flush()
    end
end

