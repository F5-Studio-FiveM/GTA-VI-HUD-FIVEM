local icons = {}
for _, name in ipairs(Config.Icons) do
    icons[joaat(name)] = name
end

local hidden = {}
for _, hash in ipairs(Config.Hidden) do
    hidden[hash] = true
end

local iconOnlyGroups = {
    [`GROUP_MELEE`] = true,
    [`GROUP_UNARMED`] = true,
    [`GROUP_PARACHUTE`] = true,
    [`GROUP_STUNGUN`] = true,
}

local state = { visible = false, height = 0 }
local last = nil

local function broadcast()
    TriggerEvent('gta6_weaponhud:state', state.visible, state.height)
end

exports('GetState', function()
    return state.visible, state.height
end)

RegisterNUICallback('ready', function(_, cb)
    SendNUIMessage({ action = 'config', position = Config.Position })
    last = nil
    cb('ok')
end)

RegisterNUICallback('state', function(data, cb)
    state.visible = data.visible == true
    state.height = tonumber(data.height) or 0
    broadcast()
    cb('ok')
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        broadcast()
        SetTimeout(2000, broadcast)
    end
end)

local function readWeapon(ped)
    local weapon = GetSelectedPedWeapon(ped)
    if weapon == `WEAPON_UNARMED` or hidden[weapon] then return nil end
    local info = { icon = icons[weapon] }
    local group = GetWeapontypeGroup(weapon)
    if iconOnlyGroups[group] then return info end
    local total = GetAmmoInPedWeapon(ped, weapon)
    local _, clip = GetAmmoInClip(ped, weapon)
    if group == `GROUP_THROWN` or GetMaxAmmoInClip(ped, weapon, true) <= 0 then
        info.count = total
    else
        info.clip = clip
        info.reserve = math.max(total - clip, 0)
    end
    return info
end

CreateThread(function()
    while true do
        local info = readWeapon(PlayerPedId())
        local key = info and ('%s|%s|%s|%s'):format(info.icon or '', info.count or '', info.clip or '', info.reserve or '') or ''
        if key ~= last then
            last = key
            SendNUIMessage({ action = 'weapon', show = info ~= nil, data = info })
        end
        Wait(info and 100 or 250)
    end
end)

CreateThread(function()
    local paused = false
    while true do
        Wait(250)
        local now = IsPauseMenuActive()
        now = now == true or now == 1
        if now ~= paused then
            paused = now
            SendNUIMessage({ action = 'visible', state = not paused })
        end
    end
end)

if Config.HideNative then
    CreateThread(function()
        while true do
            HideHudComponentThisFrame(2)
            Wait(0)
        end
    end)
end
