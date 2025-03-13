local ped = nil
local isLoanSharkOpen = false
local blip = nil
local activeLoan = false
local loanAmount = 0
local npcTargets = {}

function createBlip(location)
    if Config.ShowBlip then
        if blip and DoesBlipExist(blip) then
            RemoveBlip(blip)
        end

        blip = AddBlipForCoord(location.x, location.y, location.z)
        SetBlipSprite(blip, Config.BlipSprite)
        SetBlipColour(blip, Config.BlipColor)
        SetBlipScale(blip, Config.BlipScale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Loan Shark")
        EndTextCommandSetBlipName(blip)
    end
end

function removeBlip()
    if blip and DoesBlipExist(blip) then
        RemoveBlip(blip)
        blip = nil
    end
end

function openLoanMenu()
    if activeLoan then
        TriggerEvent('ox_lib:notify', {
            type = 'error',
            title = 'Loan Shark',
            description = 'You already have an active loan!'
        })
        return
    end

    local input = lib.inputDialog('Take a Loan', {
        {type = 'number', label = 'Loan Amount ($)', default = 1000, min = 100, max = Config.MaxLoanAmount}
    })

    if input and input[1] then
        local amount = tonumber(input[1])
        if amount > 0 then
            activeLoan = true
            loanAmount = amount
            TriggerServerEvent('loanshark:takeLoan', amount)
        else
            TriggerEvent('ox_lib:notify', {
                type = 'error',
                title = 'Invalid Amount',
                description = 'Amount must be greater than 0'
            })
        end
    end
end

function repayLoan()
    if not activeLoan then
        TriggerEvent('ox_lib:notify', {
            type = 'error',
            title = 'Loan Shark',
            description = 'You have no active loan!'
        })
        return
    end

    TriggerServerEvent('loanshark:repayLoan', loanAmount)
end

CreateThread(function()
    while true do
        local hour = GetClockHours()

        if (Config.OpenHours.start < Config.OpenHours.finish and hour >= Config.OpenHours.start and hour < Config.OpenHours.finish) or
           (Config.OpenHours.start > Config.OpenHours.finish and (hour >= Config.OpenHours.start or hour < Config.OpenHours.finish)) then
            if not isLoanSharkOpen then
                isLoanSharkOpen = true
                TriggerServerEvent('loanshark:openShark')
            end
        else
            if isLoanSharkOpen then
                isLoanSharkOpen = false
                TriggerServerEvent('loanshark:closeShark')
            end
        end

        Wait(1000)
    end
end)

RegisterNetEvent('loanshark:spawnPed', function(location)
    local model = GetHashKey(Config.PedModel)
    RequestModel(model)

    while not HasModelLoaded(model) do Wait(10) end

    if ped then DeleteEntity(ped) end

    ped = CreatePed(4, model, location.x, location.y, location.z - 1.0, location.h, true, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    createBlip(location)

    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'loanshark_interact',
            label = 'Take a Loan',
            icon = 'fa-solid fa-money-bill',
            distance = 2.0,
            onSelect = function()
                openLoanMenu()
            end
        },
        {
            name = 'loanshark_repay',
            label = 'Repay Loan',
            icon = 'fa-solid fa-money-bill-wave',
            distance = 2.0,
            onSelect = function()
                repayLoan()
            end
        }
    })
end)

RegisterNetEvent('loanshark:removePed', function()
    if ped then DeleteEntity(ped) end
    removeBlip()
end)

RegisterNetEvent('loanshark:loanRepaid', function()
    activeLoan = false
    loanAmount = 0
end)

-- ✅ Sync active loan on player load
RegisterNetEvent('loanshark:setActiveLoan', function(amount)
    if amount then
        activeLoan = true
        loanAmount = amount
    else
        activeLoan = false
        loanAmount = 0
    end
end)

-- ✅ Trigger loan sync when player spawns
CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) do Wait(100) end
    TriggerServerEvent('loanshark:playerLoaded')
end)

-- ✅ ✅ ✅ NPC ATTACK LOGIC ✅ ✅ ✅

RegisterNetEvent('loanshark:startHunt', function()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    for i = 1, Config.NPCCount do
        local model = GetHashKey(Config.PedModel)
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end

        local spawnCoords = GetOffsetFromEntityInWorldCoords(playerPed, math.random(-10, 10), math.random(-10, 10), 0)
        local npc = CreatePed(4, model, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, true, true)

        -- ✅ Configure NPC behavior and stats
        local weapon = GetHashKey(Config.NPCWeapons[math.random(#Config.NPCWeapons)])
        GiveWeaponToPed(npc, weapon, 9999, false, true)
        SetPedAccuracy(npc, Config.NPCDifficulty.accuracy)
        SetEntityHealth(npc, Config.NPCDifficulty.health)
        SetPedArmour(npc, Config.NPCDifficulty.armor)

        TaskCombatPed(npc, playerPed, 0, 16)
        SetPedAsEnemy(npc, true)
        SetPedRelationshipGroupHash(npc, GetHashKey("HATES_PLAYER"))
        SetPedCombatAbility(npc, 2)
        SetPedCombatMovement(npc, 2)
        SetPedCombatRange(npc, 2)

        table.insert(npcTargets, npc)
    end

    -- ✅ Cleanup when player dies or NPCs are killed
    CreateThread(function()
        while #npcTargets > 0 do
            if IsEntityDead(playerPed) then
                for _, npc in ipairs(npcTargets) do
                    if DoesEntityExist(npc) then
                        DeleteEntity(npc)
                    end
                end
                npcTargets = {}
            end
            Wait(1000)
        end
    end)
end)

RegisterNetEvent('loanshark:cleanupNPCs', function()
    for _, npc in ipairs(npcTargets) do
        if DoesEntityExist(npc) then
            DeleteEntity(npc)
        end
    end
    npcTargets = {}
end)
