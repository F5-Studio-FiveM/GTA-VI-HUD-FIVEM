HUD = {
    Framework = 'none',
    Menu = {},
    Reset = {},
    Data = {
        hunger = 100,
        thirst = 100,
        stress = 0,
        seatbelt = false,
        cruise = false,
        showSeatbelt = true,
        nos = -1,
        nitroActive = false,
        harness = false,
        hp = 100,
        dev = false,
        cash = 0,
        bank = 0,
    },
    Cinematic = 0,
}

for key, value in pairs(Config.Menu) do HUD.Menu[key] = value end

if GetResourceState('qbx_core') == 'started' then
    HUD.Framework = 'qbx'
elseif GetResourceState('qb-core') == 'started' then
    HUD.Framework = 'qb'
elseif GetResourceState('es_extended') == 'started' then
    HUD.Framework = 'esx'
else
    print('^3[gta6_hud]^7 no framework detected, ensure gta6_hud after qbx_core, qb-core or es_extended')
end

function HUD.IsLoggedIn()
    return true
end

function HUD.IsDead()
    return false
end

function HUD.Notify(text, ntype, length)
    if GetResourceState('gta6_notify') == 'started' then
        return exports.gta6_notify:Notify(text, ntype, length)
    end
    if HUD.FrameworkNotify then HUD.FrameworkNotify(text, ntype, length) end
end

function HUD.MoneyChange(mtype, amount, isMinus, cash, bank)
    HUD.Data.cash = cash
    HUD.Data.bank = bank
    SendNUIMessage({
        action = 'updatemoney',
        cash = math.floor(cash),
        bank = math.floor(bank),
        amount = math.floor(amount),
        minus = isMinus,
        type = mtype,
    })
end

function HUD.ShowAccount(mtype, amount)
    SendNUIMessage({ action = 'show', type = mtype, amount = math.floor(amount) })
end

local function playSound(name, volume)
    if GetResourceState('interact-sound') == 'started' then
        TriggerServerEvent('InteractSound_SV:PlayOnSource', name, volume)
    end
end

local function checklistSound()
    if HUD.Menu.isListSoundsChecked then playSound('shiftyclick', 0.5) end
end

local function saveSettings()
    SetResourceKvp('gta6_hud_settings', json.encode(HUD.Menu))
end

local function cinematicShow(enable)
    SetBigmapActive(true, false)
    Wait(0)
    SetBigmapActive(false, false)
    HUD.Cinematic = enable and 0.2 or 0
end

local function pushSetting(key, value)
    SendNUIMessage({ action = 'setting', key = key, value = value })
end

local function loadSettings(settings)
    for key, value in pairs(settings) do
        if HUD.Menu[key] ~= nil then HUD.Menu[key] = value end
    end
    cinematicShow(HUD.Menu.isCinematicModeChecked)
    for key, value in pairs(HUD.Menu) do pushSetting(key, value) end
end

local NAV_KEYS = { 'recalc', 'proceed', 'left', 'right', 'straight', 'sharpLeft', 'sharpRight', 'arrived', 'm', 'km', 'ft', 'mi' }
local SECTION_KEYS = { 'map', 'compass', 'status', 'vehicle', 'sound', 'cinematic' }

local function localeGroup(prefix, keys)
    local out = {}
    for i = 1, #keys do out[keys[i]] = Locale(prefix .. keys[i]) end
    return out
end

local function menuText()
    local options = {}
    for key in pairs(Config.Menu) do options[key] = Locale('option_' .. key) end
    return {
        title = Locale('menu_title'),
        restart = Locale('menu_restart'),
        reset = Locale('menu_reset'),
        sections = localeGroup('section_', SECTION_KEYS),
        options = options,
    }
end

function HUD.ApplySettings()
    local saved = GetResourceKvpString('gta6_hud_settings')
    local ok, decoded = pcall(json.decode, saved or '')
    loadSettings(ok and type(decoded) == 'table' and decoded or Config.Menu)
    SendNUIMessage({
        action = 'config',
        unit = Config.UseMPH and 'MPH' or 'KMH',
        fullHealthInVehicle = Config.ShowFullHealthInVehicle == true,
        vehicleHealthTimeout = Config.VehicleHealthTimeout,
        vehicleHealthLow = Config.VehicleHealthLow,
        statusTimeout = Config.StatusTimeout,
        statusAlways = Config.ShowStatusAlways == true,
        locale = Config.Locale,
        nav = localeGroup('nav_', NAV_KEYS),
        navUnits = Config.NavUnits,
        menu = menuText(),
    })
    Wait(500)
    TriggerEvent('hud:client:LoadMap')
end

local function resetCaches()
    for i = 1, #HUD.Reset do HUD.Reset[i]() end
end

RegisterNUICallback('nuiReady', function(_, cb)
    cb('ok')
    resetCaches()
    HUD.ApplySettings()
end)

local showMenu = false

RegisterCommand('hudmenu', function()
    if showMenu then return end
    if HUD.Menu.isOpenMenuSoundsChecked then playSound('monkeyopening', 0.5) end
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })
    showMenu = true
end)

RegisterKeyMapping('hudmenu', Locale('menu_keymap'), 'keyboard', Config.OpenMenu)

RegisterNUICallback('closeMenu', function(_, cb)
    if HUD.Menu.isOpenMenuSoundsChecked then playSound('catclosing', 0.05) end
    showMenu = false
    SetNuiFocus(false, false)
    cb('ok')
end)

local function restartHud()
    if HUD.Menu.isResetSoundsChecked then playSound('airwrench', 0.1) end
    HUD.Notify(Locale('hud_restart'), 'error')
    resetCaches()
    HUD.ApplySettings()
    HUD.Notify(Locale('hud_start'), 'success')
end

RegisterNUICallback('restartHud', function(_, cb)
    cb('ok')
    restartHud()
end)

RegisterCommand('resethud', restartHud)

RegisterNUICallback('resetStorage', function(_, cb)
    cb('ok')
    if HUD.Menu.isResetSoundsChecked then playSound('airwrench', 0.1) end
    DeleteResourceKvp('gta6_hud_settings')
    loadSettings(Config.Menu)
    TriggerEvent('hud:client:LoadMap')
end)

local toggles = {
    showOutMap = 'isOutMapChecked',
    showOutCompass = 'isOutCompassChecked',
    showFollowCompass = 'isCompassFollowChecked',
    showFuelAlert = 'isLowFuelChecked',
    showCinematicNotif = 'isCinematicNotifChecked',
    dynamicHealth = 'isDynamicHealthChecked',
    dynamicArmor = 'isDynamicArmorChecked',
    dynamicHunger = 'isDynamicHungerChecked',
    dynamicThirst = 'isDynamicThirstChecked',
    dynamicStress = 'isDynamicStressChecked',
    dynamicOxygen = 'isDynamicOxygenChecked',
    changeFPS = 'isChangeFPSChecked',
    dynamicEngine = 'isDynamicEngineChecked',
    dynamicNitro = 'isDynamicNitroChecked',
    showCompassBase = 'isCompassShowChecked',
    showStreetsNames = 'isShowStreetsChecked',
    showPointerIndex = 'isPointerShowChecked',
    showDegreesNum = 'isDegreesShowChecked',
    changeCompassFPS = 'isChangeCompassFPSChecked',
    openMenuSounds = 'isOpenMenuSoundsChecked',
    resetHudSounds = 'isResetSoundsChecked',
    checklistSounds = 'isListSoundsChecked',
    HideMap = 'isHideMapChecked',
}

for callback, key in pairs(toggles) do
    RegisterNUICallback(callback, function(_, cb)
        HUD.Menu[key] = not HUD.Menu[key]
        checklistSound()
        saveSettings()
        cb('ok')
    end)
end

RegisterNUICallback('cinematicMode', function(_, cb)
    if HUD.Menu.isCinematicModeChecked then
        cinematicShow(false)
        HUD.Menu.isCinematicModeChecked = false
        if HUD.Menu.isCinematicNotifChecked then HUD.Notify(Locale('cinematic_off'), 'error') end
    else
        cinematicShow(true)
        HUD.Menu.isCinematicModeChecked = true
        if HUD.Menu.isCinematicNotifChecked then HUD.Notify(Locale('cinematic_on')) end
    end
    checklistSound()
    saveSettings()
    cb('ok')
end)

RegisterNetEvent('hud:client:ToggleHealth', function()
    HUD.Menu.isDynamicHealthChecked = not HUD.Menu.isDynamicHealthChecked
    pushSetting('isDynamicHealthChecked', HUD.Menu.isDynamicHealthChecked)
    checklistSound()
    saveSettings()
end)

RegisterNetEvent('hud:client:Notify', function(text, ntype, length)
    HUD.Notify(text, ntype, length)
end)

RegisterNetEvent('hud:client:ToggleShowSeatbelt', function()
    HUD.Data.showSeatbelt = not HUD.Data.showSeatbelt
end)

CreateThread(function()
    while true do
        if HUD.Cinematic > 0 then
            DrawRect(0.0, 0.0, 2.0, HUD.Cinematic, 0, 0, 0, 255)
            DrawRect(0.0, 1.0, 2.0, HUD.Cinematic, 0, 0, 0, 255)
            Wait(0)
        else
            Wait(250)
        end
    end
end)
