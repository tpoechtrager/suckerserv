--[[
    set player status to invadmin or invadmin at connect
]]

local auth_domains = table_unique(server.parse_list(server["auth_domains"]))

if not auth_domains
then
    server.log_error("auth privileges: no domains set")
    return
end

local function set_priv(cn, priv, user_id)
    if (priv == "admin") then
        server.set_invisible_admin(cn)
        server.player_msg(cn, string.format(server.invadmin_activation_message))
        server.log(user_id .. " playing as " .. server.player_name(cn) .. "(" .. cn .. ") used auth to claim invadmin.")
    elseif (priv == "master") then
        server.set_invisible_master(cn)
        server.player_msg(cn, string.format(server.invmaster_activation_message))
        server.log(user_id .. " playing as " .. server.player_name(cn) .. "(" .. cn .. ") used auth to claim invmaster.")
    end
end

server.event_handler("connect", function(cn)
    if not server.is_bot(cn)
    then
        local sid = server.player_sessionid(cn)
        server.sleep(2000, function()
            if server.valid_cn(cn) and (sid == server.player_sessionid(cn))
            then
                if server.player_priv_code(cn) < 2
                then
                    for _, domain in pairs(auth_domains)
                    do
                        auth.send_request(cn, domain, function(cn, user_id, domain, status)
                            if (sid == server.player_sessionid(cn)) and (status == auth.request_status.SUCCESS) and not (server.player_priv_code(cn) == 2)
                            then			    
                                auth.query_id(user_id, domain, function(result, priv)
                                    if result and (sid == server.player_sessionid(cn)) and not (server.player_priv_code(cn) == 2) then
                                        set_priv(cn, priv, user_id)
                                    end
                                end)
                            end
                        end)
                    end
                end
            end
        end)
    end
end)
