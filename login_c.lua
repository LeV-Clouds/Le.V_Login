Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

local input = {utilisateur = "", mdp = ""}
local Pourcent = 0.0
local Spawning    = true
local JoueurCharge  = false

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    JoueurCharge = true
end)

AddEventHandler('playerSpawned', function()
	Citizen.CreateThread(function()
		while not JoueurCharge do
			Citizen.Wait(10)
		end
		if Spawning then
			ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
				if skin == nil then
				else
					TriggerEvent('skinchanger:loadSkin', skin)
					Camera()
				end
			end)
			Spawning = false
		end
	end)
end)

Citizen.CreateThread(function()

    RMenu.Add("core", "serveur_connexion", RageUI.CreateMenu("Base Stream", "none", 650, 350))
    RMenu:Get('core', 'serveur_connexion'):SetRectangleBanner(39, 41, 39, 100)
    RMenu:Get("core", "serveur_connexion").Closable = false

    while true do
       Wait(0)
        RageUI.IsVisible(RMenu:Get('core', 'serveur_connexion') , true, false, true, function()
            if connect == 1 then 
                RageUI.CenterButton("- ~y~Panel de connexion~s~ -", nil, {}, true, function(Hovered, Active, Selected)
                end)
                RageUI.Button("Nom d'utilisateur", nil, {RightLabel = input.utilisateur}, true, function(Hovered, Active, Selected)
                    if Selected then
                        input.utilisateur = KeyboardInput("Nom d'utilisateur : ", "", 15)
                    end
                end)
                RageUI.Button("Mot de passe", nil, {RightLabel = Click}, true, function(Hovered, Active, Selected)
                    if Selected then
                        input.mdp = KeyboardInput("Mot de passe : ", "", 15)
                        Click = ""
                        for i = 1, string.len(input.mdp), 1 do
                        Click = Click .. "*"
                        end
                    end
                end)
                RageUI.CenterButton("Accèdez aux intéraction", nil, {RightLabel = ">"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        if input.utilisateur == "" or input.mdp == "" then 
                            RageUI.Popup({message = "- ~r~Erreur~s~\n- Un champs est vide ..."})
                        else 
                            ESX.TriggerServerCallback("core:CheckId", function(Valide)
                                if Valide then
                                    progress = 1
                                else 
                                    RageUI.Popup({message = "- ~r~Erreur~s~\n- ~b~MDP/Utilisateur~s~ invalide ..."})
                                end
                            end, input.utilisateur, input.mdp)
                        end
                    end
                end)
            end
            if progress == 1 then
                RageUI.PercentagePanel(Pourcent or 0.0, "Connexion ... (" .. math.floor(Pourcent*100) .. "%)", "", "",  function(Hovered, Active, Percent)
                    if Pourcent < 1.0 then
                        Pourcent = Pourcent + 0.004
                    else
                        RageUI.Popup({message = "- ~y~Validation~s~\n- Vous êtes ~g~connecter~s~ ..."})
                        Pourcent = 0.0
                        connect = 0
                        progress = 0
                        infos = 1
                    end
                end)
            elseif infos == 1 then
                RageUI.Button("Connecter en tant que :  ~g~" .. input.utilisateur .. "~s~", nil, {}, true, function(Hovered, Active, Selected)
                end)
                RageUI.Button("Mot de passe actuel : ~b~" .. input.mdp .. "~s~", nil, {}, true, function(Hovered, Active, Selected)
                end)
                RageUI.Button("Modifier le mot de passe", nil, {}, true, function(Hovered, Active, Selected)
                    if Selected then
                        input.mdp = KeyboardInput("Mot de passe : ", "", 15)
                        if input.utilisateur == "" or input.mdp == "" then 
                            RageUI.Popup({message = "- ~r~Erreur~s~\n- Le champ est vide ..."})
                        else 
                            TriggerServerEvent("core:UpMdp", input.mdp)
                        end
                    end
                end)
                RageUI.Button("Accèdez à Los Santos", nil, {RightLabel = ">"}, true, function(Hovered, Active, Selected)
                    if Selected then
                        local coords = GetEntityCoords(GetPlayerPed(-1))
                        DoScreenFadeOut(1000)
                        Citizen.Wait(2000)
                        RenderScriptCams(false,  false,  0,  true,  true)
                        Wait(1000)
                        FreezeEntityPosition(GetPlayerPed(-1), false)
                        DisplayRadar(true)
                        SetEntityVisible(GetPlayerPed(-1), true, 0)
                        RageUI:CloseAll()
                        DoScreenFadeIn(2000)
                        SetEntityCoords(PlayerPedId(), ESX.PlayerData.coords.x, ESX.PlayerData.coords.y, ESX.PlayerData.coords.z, 0, 0, 0, 0)
                    end
                end)
            end
        end)
    end
end)


Camera = function()
    DoScreenFadeOut(1000)
    Wait(1000)
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityVisible(GetPlayerPed(-1), false, 0)
    SetEntityCoords(PlayerPedId(), -1682.43, -1239.73, 10.0)
    CamPre = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
    SetCamCoord(CamPre, -1682.43, -1239.73, 40.0)
    SetCamRot(CamPre, 0.0, 0.0, 358.21)
    SetCamFov(CamPre, 45.97)
    ShakeCam(CamPre, "HAND_SHAKE", 0.1)
    SetCamActive(CamPre, true)
    RenderScriptCams(true, false, 2000, true, true)
    connect = 1
    RageUI.Visible(RMenu:Get('core', 'serveur_connexion'), true)
    DisplayRadar(false)
    Wait(500)
    DoScreenFadeIn(1000) 
end

KeyboardInput = function(TextEntry, ExampleText, MaxStringLength)
	AddTextEntry('FMMC_KEY_TIP1', TextEntry .. '')
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLength)
	blockinput = true
	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		return result
	else
		Citizen.Wait(500)
		blockinput = false
		return nil
	end
end
