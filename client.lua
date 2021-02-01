----------------------------------------------------------------------
---------------MADE BY GK#8652 FOR SACRP KoTH FiveM-------------------
----------------------------------------------------------------------

RegisterNetEvent("OpenDailyRewards")
AddEventHandler("OpenDailyRewards", function(day)
    display = true
    SetNuiFocus(true, true)
    print(day)
    SendNUIMessage({
        type = "OpenDailyRewards",
        day = day,
    })
end)

RegisterNetEvent("output")
AddEventHandler("output", function(argument)
    TriggerEvent("chatMessage", "[Success]", {0,255,0}, argument)
end)

local display = false

RegisterCommand("daily", function(source, args)
    TriggerServerEvent("open-rewards-menu", source)
end)

--very important cb 
RegisterNUICallback("exit", function(data)
    TriggerEvent("CloseDailyRewards")
end)

-- this cb is used as the main route to transfer data back 
-- and also where we hanld the data sent from js
RegisterNUICallback("main", function(data)
    TriggerEvent("CloseDailyRewards")
end)

RegisterNUICallback("redeem", function(amount)
    print("reached client")
    TriggerServerEvent("dailyReward:redeem", amount)
end)

RegisterNetEvent("CloseDailyRewards")
AddEventHandler("CloseDailyRewards", function()
    display = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "CloseDailyRewards",
        status = false,
    })
end)

RegisterNetEvent("UpdateTime")
AddEventHandler("UpdateTime", function(timeToNextDay)
    SendNUIMessage({
        type = "UpdateTime",
        time = timeToNextDay,
    })
end)

Citizen.CreateThread(function()
    while display do
        Citizen.Wait(0)
        DisableControlAction(0, 1, display) -- LookLeftRight
        DisableControlAction(0, 2, display) -- LookUpDown
        DisableControlAction(0, 142, display) -- MeleeAttackAlternate
        DisableControlAction(0, 18, display) -- Enter
        DisableControlAction(0, 106, display) -- VehicleMouseControlOverride
    end
end)


Citizen.CreateThread(function()
    while display do
        Citizen.Wait(0)
        -- https://runtime.fivem.net/doc/natives/#_0xFE99B66D079CF6BC
        --[[ 
            inputGroup -- integer , 
	        control --integer , 
            disable -- boolean 
        ]]
        DisableControlAction(0, 1, display) -- LookLeftRight
        DisableControlAction(0, 2, display) -- LookUpDown
        DisableControlAction(0, 142, display) -- MeleeAttackAlternate
        DisableControlAction(0, 18, display) -- Enter
        DisableControlAction(0, 106, display) -- VehicleMouseControlOverride
    end
end)