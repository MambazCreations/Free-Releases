local sharkLocation = nil
local activeLoans = {}

QBCore = exports['qb-core']:GetCoreObject()

-- ✅ Load existing loans on resource start
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        MySQL.query('SELECT * FROM loans', {}, function(loans)
            for _, loan in ipairs(loans) do
                activeLoans[loan.citizenid] = loan.amount
            end
        end)
    end
end)

RegisterNetEvent('loanshark:openShark', function()
    if not sharkLocation then
        sharkLocation = Config.Locations[math.random(#Config.Locations)]
        print(("%.2f, %.2f, %.2f"):format(sharkLocation.x, sharkLocation.y, sharkLocation.z))
        TriggerClientEvent('loanshark:spawnPed', -1, sharkLocation)
    end
end)

RegisterNetEvent('loanshark:closeShark', function()
    sharkLocation = nil
    TriggerClientEvent('loanshark:removePed', -1)
end)

RegisterNetEvent('loanshark:takeLoan', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local totalRepayment = math.floor(amount * (1 + Config.InterestRate))
    local repaymentDeadline = os.time() + (Config.RepaymentTime * 60) -- in seconds

    if Player then
        activeLoans[Player.PlayerData.citizenid] = totalRepayment
        Player.Functions.AddMoney('cash', amount)

        MySQL.query('INSERT INTO loans (citizenid, amount, deadline) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE amount = ?, deadline = ?',
            {Player.PlayerData.citizenid, totalRepayment, repaymentDeadline, totalRepayment, repaymentDeadline}
        )
    end
end)

RegisterNetEvent('loanshark:repayLoan', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if activeLoans[Player.PlayerData.citizenid] and Player.Functions.GetMoney('cash') >= activeLoans[Player.PlayerData.citizenid] then
        Player.Functions.RemoveMoney('cash', activeLoans[Player.PlayerData.citizenid])

        MySQL.query('DELETE FROM loans WHERE citizenid = ?', {
            Player.PlayerData.citizenid
        })

        activeLoans[Player.PlayerData.citizenid] = nil
        TriggerClientEvent('loanshark:loanRepaid', src)
    end
end)

-- ✅ Check for overdue loans and send NPCs
CreateThread(function()
    while true do
        local currentTime = os.time()

        MySQL.query('SELECT * FROM loans', {}, function(loans)
            for _, loan in ipairs(loans) do
                if loan.deadline <= currentTime then
                    local player = QBCore.Functions.GetPlayerByCitizenId(loan.citizenid)
                    if player then
                        TriggerClientEvent('loanshark:startHunt', player.PlayerData.source)
                        MySQL.query('DELETE FROM loans WHERE citizenid = ?', {loan.citizenid})
                        activeLoans[loan.citizenid] = nil
                    end
                end
            end
        end)

        Wait(60000) -- Check every 60 seconds
    end
end)

RegisterNetEvent('loanshark:playerLoaded', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player then
        MySQL.query('SELECT amount FROM loans WHERE citizenid = ?', {Player.PlayerData.citizenid}, function(result)
            if result[1] then
                activeLoans[Player.PlayerData.citizenid] = result[1].amount
                TriggerClientEvent('loanshark:setActiveLoan', src, result[1].amount)
            end
        end)
    end
end)
