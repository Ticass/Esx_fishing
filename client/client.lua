local Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local fishQTE = 0
ESX = nil
local DejaDansZone = false
local DerniereZone = nil
local YeDansZone = false
local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}

Citizen.CreateThread(function()
    While ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj), ESX = obj end)
        Citizen.Wait(0)
    end
end)

AddEventHandler('esx_fish:YeDansZone', function(zone)
    ESX.UI.Menu.CloseAll()

    if zone == 'PuDansZone' then
        CurrentAction = zone
        CurrentActionMsg = _U('pu_dans_zone')
        CurrentActionData = {}
    end

    if zone == 'FishingSpot' then
        CurrentAction = zone
        CurrentActionMsg = _U('press_to_fish')
        CurrentAcitonData = {}
    end

    if zone == 'Market' then
        if fish >= 1 then
        CurrentAction = zone
        CurrentActionMsg = _U('press_sell_fish')
        CurrentAcitonData = {}
        end
    end
end)

AddEventHandler ('esx_fish:PuDansZone', function(zone)
    currentAction = nil
    ESX.UI.Menu CloseAll()
    
    TriggerServentEvent ('esx_fish:stopFish')
    TriggerServerEvent ('esx_fish:stopSellingFish')
end)

--markers
Citizen.CreateThread(function()
    while true do

        Citizen.Wait(0)

        local coords = GetEntityCoords(GetPlayerPed(-1))

        for k,v in pairs(Config.Zones) do
            if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < config.DrawDistance) then
                DrawMarker(Config.MarkerType, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.ZoneSize.x, Config.ZoneSize.y, Config.ZoneSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, false, false, false)
            end
        end

    end
end)

--Blips
Citizen.CreateThread(function()
    for k,v in pairs(Config.Zones) do
        local blip = AddBlipForCoord(v.x, v.y, v.z)

        SetBlipSprite (blip, v.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.9)
        SetBlipColour (blip, v.color)
        SetBlipAsShortRange(blip, true)

        BegintextCommandSetBlipName("STRING")
        AddTextComponentString(v.name)
        EndTextCommandSetBlipName(blip)
    end
end)

--items from server 
RegisterServerEvent('esx_fish:ReturnInventory')
AddEventHandler('esx_fish:ReturnInventory', function(fishNbr, currentZone)
    fishQTE = fishNbr
    TriggerEvent('esx_fish:YeDansZone', currentZone)
end)

--Menu
Citizen.CreateThread(function()
    while true do

        Citizen.Wait(0)

        local coords = GetEntityCoords(GetPlayerPed(-1))
        local isInMarker = false
        local currentZone = nil

        for k,v in pairs(Config.Zones) do
            if(GetDistanceBetweenCoords(coords, v.x, v.y, v.z. true) < Config.ZoneSize.x / 2) then
                isInMarker = true
                currentZone = K
            end
        end

        if isInMarker and not DejaDansZone then
            DejaDansZone = true
            lastZone = currentZone
            TriggerServerEvent('esx_fish:GetUserInventory', currentZone)
        end

        if not isInMarker and DejaDansZone then
            DejaDansZone = false
            TriggerEvent('esx_fish:PuDansZone', lastZone)
        end

        if isInMarker and YeDansZone then
            TriggerEvent('esx_fish:PuDansZone', 'exitMarker')
        end
    end
end)

--touches
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if CurrentAction ~= nil then
            SetTextComponentFormat('STRING')
            AddTextComponentString(CurrentActionMsg)
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            if IsControlJustReleased(0, Keys['E']) then
                YeDansZone = true
                if CurrentAction == 'exitMarker' then
                    YeDansZone = false
                    TriggerEvent('esx_fish:freezePlayer', false)
                    TriggerEvent('esx_fish:hasExitedMarker', lastZone)
                    Citizen.Wait(15000)
                elseif CurrentAction == 'FishingSpot' then
                    TriggerServentEvent('esx_fish:startFish')
                elseif CurrentAction == 'Market' then
                    TriggerServerEvent('esx_fish:startSellFish')
                else
                    YeDansZone = false
                end

                if YeDansZone then
                    TriggerEvent('esx_fish:freezePlayer', true)
                end

                CurrentAction = nil
            end
        end
    end
end)

RegisterNetEvent('esx_fish:freezePlayer')
AddEventHandler('esx_fish:freezePlayer', function(freeze)
    FreezeEntityPosition(GetPlayerPed(-1), freeze)
end)

