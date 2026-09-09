local framework
if GetResourceState('qbx_core') == 'started' then
    framework = 'qbx'
elseif GetResourceState('qb-core') == 'started' then
    framework = 'qb'
else
    return
end

local QBCore = framework == 'qb' and exports['qb-core']:GetCoreObject() or nil

local function getPlayer(src)
    if framework == 'qbx' then return exports.qbx_core:GetPlayer(src) end
    return QBCore.Functions.GetPlayer(src)
end

local function showAccount(src, mtype)
    local Player = getPlayer(src)
    if not Player then return end
    TriggerClientEvent('hud:client:ShowAccounts', src, mtype, Player.PlayerData.money[mtype])
end

if framework == 'qb' then
    QBCore.Commands.Add('cash', 'Check Cash Balance', {}, false, function(source)
        showAccount(source, 'cash')
    end)
    QBCore.Commands.Add('bank', 'Check Bank Balance', {}, false, function(source)
        showAccount(source, 'bank')
    end)
    QBCore.Commands.Add('dev', 'Enable/Disable developer Mode', {}, false, function(source)
        TriggerClientEvent('qb-admin:client:ToggleDevmode', source)
    end, 'admin')
else
    RegisterCommand('cash', function(source)
        showAccount(source, 'cash')
    end, false)
    RegisterCommand('bank', function(source)
        showAccount(source, 'bank')
    end, false)
    RegisterCommand('dev', function(source)
        TriggerClientEvent('qb-admin:client:ToggleDevmode', source)
    end, true)
end

local function validAmount(amount)
    amount = tonumber(amount)
    if not amount or amount ~= amount or amount <= 0 or amount > 100 then return nil end
    return amount
end

local function setStress(src, Player, newStress)
    if newStress < 0 then newStress = 0 end
    if newStress > 100 then newStress = 100 end
    Player.Functions.SetMetaData('stress', newStress)
    TriggerClientEvent('hud:client:UpdateStress', src, newStress)
end

RegisterNetEvent('hud:server:GainStress', function(amount)
    if Config.DisableStress then return end
    amount = validAmount(amount)
    if not amount then return end
    local src = source
    local Player = getPlayer(src)
    if not Player then return end
    local job = Player.PlayerData.job or {}
    if Config.WhitelistedJobs[job.type] or Config.WhitelistedJobs[job.name] then return end
    setStress(src, Player, (Player.PlayerData.metadata['stress'] or 0) + amount)
    TriggerClientEvent('hud:client:Notify', src, Locale('stress_gain'), 'error', 1500)
end)

RegisterNetEvent('hud:server:RelieveStress', function(amount)
    if Config.DisableStress then return end
    amount = validAmount(amount)
    if not amount then return end
    local src = source
    local Player = getPlayer(src)
    if not Player then return end
    setStress(src, Player, (Player.PlayerData.metadata['stress'] or 0) - amount)
    TriggerClientEvent('hud:client:Notify', src, Locale('stress_removed'))
end)
