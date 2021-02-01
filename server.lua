----------------------------------------------------------------------
---------------MADE BY GK#8652 FOR SACRP KoTH FiveM-------------------
----------------------------------------------------------------------

RegisterCommand("save", function(source, args)
    local argString = table.concat(args, " ")
    MySQL.Async.fetchAll("INSERT INTO main (id, name, args) VALUES(@source, @name, @args)",     
    --[[ 
        (id, name, args)
        These are the columns (in our database) we will be insterting the data into  
    ]]
    {["@source"] = GetPlayerIdentifiers(source)[1], ["@name"] = GetPlayerName(source), ["@args"] = argString},
        --[[ 
            Here we are defining the '@' variables to in-game native functions
         ]]
        function (result)
        TriggerClientEvent("output", source, "^2".. argString.. "^0")

    end)
end)

RegisterCommand("get", function(source, args)
    local argString = table.concat(args, " ")
    MySQL.Async.fetchAll("SELECT * FROM main ORDER BY id DESC LIMIT 1",{},
    function(result)
        local string = ("^3(" .. result[1].name .. ") - ^8" .. result[1].id .. "^0: " .. result[1].args)
        TriggerClientEvent("output", source, string)
    end)
end)

RegisterNetEvent("open-rewards-menu")
AddEventHandler("open-rewards-menu", function(param)
    local user = source
    local license = GetPlayerIdentifiers(user)[1]
    local newUser = false
    
    MySQL.ready(function ()
        MySQL.Async.fetchAll('SELECT EXISTS(SELECT * from dailyrewards WHERE license = @license)', { ['@license'] = license },
        function(output)
            --format the string to get just the 0 or 1
            output = json.encode(output)
            output = string.sub(output, string.find(output,":%d}"))
            output = string.sub(output, string.find(output,"%d"))
            if output == '0' then
                MySQL.Async.insert('INSERT INTO dailyrewards (license, rewardDay, redeemed) VALUES (@license, @rewardDay, @redeemed)',
                { ['license'] = license, ['rewardDay'] = 1, ['redeemed'] = 0})
                TriggerClientEvent("OpenDailyRewards", user, "#day1-lock")
                newUser = true
            end
        end)
    end)
    if newUser == false then
        MySQL.ready(function ()
            MySQL.Async.fetchAll('SELECT rewardDay FROM dailyrewards WHERE license = @license AND redeemed = 0', { ['@license'] = license}, 
            function(rewardDay)
                if next(rewardDay) ~= nil then
                    rewardDay = json.encode(rewardDay)
                    rewardDay = string.sub(rewardDay, string.find(rewardDay,":%d}"))
                    rewardDay = string.sub(rewardDay, string.find(rewardDay,"%d"))
                    rewardDay = "#day" .. tostring(rewardDay) .. "-lock"
                end
                TriggerClientEvent("OpenDailyRewards", user, rewardDay)
            end)
        end)
    end
end)

Citizen.CreateThread(function()
  while true do
    local file = LoadResourceFile(GetCurrentResourceName(),"html/date.txt")
    date = os.date("%d")
    if file ~= date then
        -- !change me to where date.txt is located relative to this file!
        SaveResourceFile(GetCurrentResourceName(),"html/date.txt",date,-1)
        print("^0^4It's a new day!^0")
        MySQL.ready(function ()
            MySQL.Async.transaction({
                'UPDATE dailyrewards SET rewardDay = rewardDay + 1, redeemed = 0 WHERE redeemed = 1 AND NOT rewardDay = 7',
                'UPDATE dailyrewards SET rewardDay = 1, redeemed = 0 WHERE redeemed = 1 AND rewardDay = 7'},{}
            )
        end)
    end
    Citizen.Wait(60000)
  end
end)

Citizen.CreateThread(function()
    while true do
        --[[
        local hour = math.floor(23 - os.date("%H"))
        local min = math.floor(60 - os.date("%M"))
        local sec = math.floor(60 - os.date("%S"))
        local timeList = ["hour","min","sec"]
        for _, p in ipairs(timeList) do
            print(p)
        end
        ]]--
        timeToNextDay = math.floor(23 - os.date("%H")) .. ":" .. math.floor(60 - os.date("%M")) .. ":" .. math.floor(60 - os.date("%S"))
        TriggerClientEvent("UpdateTime", -1, timeToNextDay)
        Citizen.Wait(1000)
    end
end)

RegisterNetEvent("dailyReward:redeem")
AddEventHandler("dailyReward:redeem", function(amount)
    print("someone tried to redeem ",amount)
    user = source
    local license = GetPlayerIdentifiers(user)[1]
    MySQL.ready(function ()
        MySQL.Async.transaction({
            'UPDATE dailyrewards SET redeemed = 1 WHERE license = @license'},
            { ['@license'] = license }
        )
    end)
    print("triggering server CloseDailyRewards")
    TriggerClientEvent("CloseDailyRewards", user)
end)