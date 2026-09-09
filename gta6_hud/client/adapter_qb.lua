if HUD.Framework ~= 'qb' then return end

local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()

function HUD.IsLoggedIn()
    return LocalPlayer.state.isLoggedIn == true
end

function HUD.IsDead()
    local meta = PlayerData.metadata
    return meta ~= nil and (meta['isdead'] == true or meta['inlaststand'] == true)
end

function HUD.FrameworkNotify(text, ntype, length)
    QBCore.Functions.Notify(text, ntype, length)
end

local function readMetadata()
    local meta = PlayerData.metadata
    if not meta then return end
    HUD.Data.hunger = meta['hunger'] or HUD.Data.hunger
    HUD.Data.thirst = meta['thirst'] or HUD.Data.thirst
    HUD.Data.stress = meta['stress'] or HUD.Data.stress
end

local function readMoney()
    if PlayerData.money then
        HUD.Data.cash = PlayerData.money['cash'] or 0
        HUD.Data.bank = PlayerData.money['bank'] or 0
    end
end

readMetadata()
readMoney()

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    readMetadata()
    readMoney()
    Wait(2000)
    HUD.ApplySettings()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    PlayerData = {}
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
    readMetadata()
    readMoney()
end)

RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst)
    HUD.Data.hunger = newHunger
    HUD.Data.thirst = newThirst
end)

RegisterNetEvent('hud:client:UpdateStress', function(newStress)
    HUD.Data.stress = newStress
end)

RegisterNetEvent('seatbelt:client:ToggleSeatbelt', function()
    HUD.Data.seatbelt = not HUD.Data.seatbelt
end)

RegisterNetEvent('seatbelt:client:ToggleCruise', function()
    HUD.Data.cruise = not HUD.Data.cruise
end)

RegisterNetEvent('hud:client:UpdateNitrous', function(nitroLevel, active)
    HUD.Data.nos = nitroLevel
    HUD.Data.nitroActive = active
end)

RegisterNetEvent('hud:client:UpdateHarness', function(harnessHp)
    HUD.Data.hp = harnessHp
end)

RegisterNetEvent('qb-admin:client:ToggleDevmode', function()
    HUD.Data.dev = not HUD.Data.dev
end)

RegisterNetEvent('hud:client:ShowAccounts', function(mtype, amount)
    HUD.ShowAccount(mtype, amount)
end)

RegisterNetEvent('hud:client:OnMoneyChange', function(mtype, amount, isMinus)
    local money = PlayerData.money or {}
    HUD.MoneyChange(mtype, amount, isMinus, money['cash'] or HUD.Data.cash, money['bank'] or HUD.Data.bank)
end)

CreateThread(function()
    while true do
        Wait(1000)
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            local found = false
            for _, item in pairs(PlayerData.items or {}) do
                if item.name == 'harness' then found = true end
            end
            HUD.Data.harness = found
        end
    end
end)
