if HUD.Framework ~= 'esx' then return end

local ESX = exports['es_extended']:getSharedObject()
local loaded = ESX.PlayerLoaded == true
local accounts = { money = nil, bank = nil }

function HUD.IsLoggedIn()
    return loaded
end

function HUD.IsDead()
    return IsPedDeadOrDying(PlayerPedId(), true)
end

function HUD.FrameworkNotify(text, ntype, length)
    ESX.ShowNotification(text, ntype, length)
end

local function readAccounts(list)
    for _, account in pairs(list or {}) do
        if account.name == 'money' or account.name == 'bank' then
            accounts[account.name] = account.money
        end
    end
    HUD.Data.cash = accounts.money or 0
    HUD.Data.bank = accounts.bank or 0
end

if loaded then readAccounts(ESX.PlayerData and ESX.PlayerData.accounts) end

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    loaded = true
    readAccounts(xPlayer and xPlayer.accounts)
    Wait(2000)
    HUD.ApplySettings()
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    loaded = false
end)

RegisterNetEvent('esx:setAccountMoney', function(account)
    if account.name ~= 'money' and account.name ~= 'bank' then return end
    local previous = accounts[account.name]
    accounts[account.name] = account.money
    HUD.Data.cash = accounts.money or 0
    HUD.Data.bank = accounts.bank or 0
    if previous == nil or previous == account.money then return end
    local delta = account.money - previous
    HUD.MoneyChange(account.name == 'money' and 'cash' or 'bank', math.abs(delta), delta < 0, HUD.Data.cash, HUD.Data.bank)
end)

AddEventHandler('esx_status:onTick', function(data)
    for i = 1, #data do
        if data[i].name == 'hunger' then
            HUD.Data.hunger = math.floor(data[i].percent)
        elseif data[i].name == 'thirst' then
            HUD.Data.thirst = math.floor(data[i].percent)
        end
    end
end)

exports('SeatbeltState', function(state)
    HUD.Data.seatbelt = state == true
end)

exports('CruiseControlState', function(state)
    HUD.Data.cruise = state == true
end)

AddEventHandler('esx:exitedVehicle', function()
    HUD.Data.seatbelt = false
    HUD.Data.cruise = false
end)
