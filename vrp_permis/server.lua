local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vrp_permis")

vRPSpermis = {}
Tunnel.bindInterface("vrp_permis",vRPSpermis)
Proxy.addInterface("vrp_permis",vRPSpermis)
vRPCpermis = Tunnel.getInterface("vrp_permis","vrp_permis")

function vRPSpermis.vworld(type)
    player = source
    local user_id = vRP.getUserId({player})
    if player ~= nil then 
        if type ~= nil then
            if type == "DMV" then
                random = math.random(50,100)
                SetPlayerRoutingBucket(player, random)
            elseif type == "Normal" then
                    SetPlayerRoutingBucket(player, 0)
            elseif type == "Trecut" then
                vRPclient.notify(source,{"Ai primit permisul"})
                exports.ghmattimysql:execute("UPDATE vrp_users SET permis = 1 WHERE id = @user_id",{["@user_id"] = user_id}, function(data)end)
            end
        end
    end
end

AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
    if first_spawn then 
        local rows = exports.ghmattimysql:executeSync('SELECT permis FROM `vrp_users` WHERE id = @user_id', {["@user_id"] = user_id})
        if rows[1].permis == 1 then
            vRPCpermis.playerSpawned(source,{true})
        end
    end
end)

local cere_permis = {function(player,choice) 
    local user_id = vRP.getUserId({player})
    vRPclient.getNearestPlayer(player,{10},function(nplayer)
        local nuser_id = vRP.getUserId({nplayer})
        if nuser_id ~= nil then
            vRPclient.notify(player,{"Ceri ~g~licenta~w~..."})
            vRP.request({nplayer,"Vrei sa ii arati politstului licenta ?",15,function(nplayer,ok)
                if ok then
                    local rows = exports.ghmattimysql:executeSync('SELECT permis FROM `vrp_users` WHERE id = @user_id', {["@user_id"] = user_id})
                    if rows[1].permis == 1 then
                        vRPclient.notify(player,{"PERMIS : ~g~DA"})
                    else
                        vRPclient.notify(player,{"PERMIS : ~r~NU"})
                    end
                else
                    vRPclient.notify(player,{"A refuzat sa iti arate licenta"})
                end
            end})
        else
            vRPclient.notify(player,{"Ceri ~g~permisul ~w~jucatorului"})
        end
    end)
end,"Cere licenta de condus unui jucator"}

local confisca_permis = {function(player,choice) 
    local user_id = vRP.getUserId({player})
    vRPclient.getNearestPlayer(player,{10},function(nplayer)
        local nuser_id = vRP.getUserId({nplayer})
        if nuser_id ~= nil then
            vRP.request({player,"Vrei sa confisti licenta lui : "..nuser_id.." ?",15,function(player,ok)
                if ok then
                    exports.ghmattimysql:execute("UPDATE vrp_users SET permis = 0 WHERE id = @user_id",{["@user_id"] = nuser_id}, function(data)end)
                    vRPclient.notify(nplayer,{"Ti-a fost confiscata licenta de condus"})
                else
                    vRPclient.notify(player,{"Ai anulat"})
                end
            end})
        end
    end)
end,"Confisca licenta de condus celui mai apropriat jucator"}


vRP.registerMenuBuilder({"police", function(add,data)
	local user_id = vRP.getUserId({data.player})
	if user_id ~= nil then
	  local choices = {}
	  if vRP.isUserInFaction({user_id,"Politie"}) then
        choices["Cere permisul"] = cere_permis
        choices["Confisca permisul"] = confisca_permis
	  end
	  add(choices)
	end
end})
