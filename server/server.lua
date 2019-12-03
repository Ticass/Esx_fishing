ESX = nil
local PlayerIsFishing = {}
local PlayerSellingFish = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--Peche
local function Fish(source)
    setTimeout(config.TimeToGet, function()
        if playerIsFishing[source] == true then
            local ESX.GetPlayerFromId(source)

            local fish = xPlayer.GetInventoryItem('fish')

            if fish.limit ~= -1 and fish.count >= fish.limit then
                TriggerClientEvent('esx.showNotification', source, _U(inv_full_fish))
            else
                xPlayer.addIventoryItem('fish', 1)
                Fish(source)
            end
        end
    end)
end

RegisterServerEvent ('esx_fish:startFish')
AddEventHandler ('esx_fish:startFish', function()

    local _source = source

    Fish[_source] = true
    TriggerClientEvent(esx.showNotification, _source,  _U,('fishing'))

    Fish(_source)

end)

RegisterServerEvent ('esx_fish:stopFish')
AddEventHandler ('esx_fish:stopfish', function()

    local _source = source
    Fish[_source] = false

end)
--Vente de poisson
local funcion SellFish(source)

if PlayerSellingFish[source] == true then
    local ESX.GetPlayerFromId(_source)

    local FishCount = xPlayer.GetinventoryItem('fish').count

    if FishCount == 0 then
        TriggerClientEvent ('esx.shownotification', _source, _U,('no_fish'))
    else
        xPlayer.removeInventoryItem('fish', 1)
        xPlayer.addMoney('100')
        TriggerClientEvent (esx.showNotification, _source, _U,('sold_one_fish'))
            end
        end
    end
end

RegisterServerEvent('esx_fish:startSellFish')
AddEventHandler ('esx_fish:startSellfish', function()
    
    local _source = source

    PlayerSellingFish[_source] = true
    
    TriggerClientEvent(esx.showNotification, _source, _U,('selling_fish'))

    SellFish(_source)

end)

RegisterServerEvent('esx_fish:stopSellFish')
AddEventHandler ('esx_fish:stopSellFish', function()

    local _source = source

    PlayerSellingFish[_source] = false
    
end)

