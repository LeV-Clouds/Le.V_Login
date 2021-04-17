ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterServerCallback("core:CheckId", function(source, CallBack, utilisateur, mdp)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT * FROM login_infos WHERE license = "' .. xPlayer.identifier .. '" AND utilisateur = @utilisateur AND mdp = @mdp ', {["@utilisateur"] = utilisateur, ["@mdp"] = mdp}, function(Get)
        if Get[1] == nil then
            CallBack(false)
        else 
            CallBack(true)
        end
    end)
end)

RegisterServerEvent("core:UpMdp")
AddEventHandler("core:UpMdp", function(mdp)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.execute('UPDATE login_infos SET mdp = "' .. mdp .. '" WHERE license = "' .. xPlayer.identifier .. '"', {})
end)