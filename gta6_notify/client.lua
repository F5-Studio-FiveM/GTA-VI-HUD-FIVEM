local config = Config
local positions = {}
for _, name in ipairs(config.Positions) do positions[name] = true end

local function resolveType(name)
    name = type(name) == 'string' and name:lower() or 'info'
    name = config.Aliases[name] or name
    if not config.Types[name] then name = 'info' end
    return name
end

local lastKey, lastAt = nil, 0

local function show(data)
    if type(data) ~= 'table' then data = { message = data } end
    local message = data.message or data.text or data.msg
    if type(message) ~= 'string' or message == '' then return end
    local key = message .. '|' .. tostring(data.type) .. '|' .. tostring(data.title or data.caption)
    local now = GetGameTimer()
    if (config.DedupeWindow or 0) > 0 and key == lastKey and now - lastAt < config.DedupeWindow then return end
    lastKey, lastAt = key, now
    local preset = config.Types[resolveType(data.type)]
    SendNUIMessage({
        action = 'notify',
        message = message,
        title = data.title or data.caption or config.Title,
        icon = data.icon or preset.icon,
        color = data.color or preset.color,
        duration = tonumber(data.duration or data.length) or config.Duration,
        position = positions[data.position] and data.position or config.Position,
        sound = data.sound == nil and (preset.sound or config.Sound.file) or data.sound,
    })
end

exports('Notify', function(a, b, c)
    if type(a) == 'table' then return show(a) end
    if type(b) == 'number' and type(c) == 'string' then return show({ type = a, duration = b, message = c }) end
    show({ message = a, type = b, duration = c })
end)

RegisterNetEvent('gta6_notify:client:notify', show)

RegisterNUICallback('ready', function(_, cb)
    cb({ scale = config.Scale, maxVisible = config.MaxVisible, position = config.Position, duration = config.Duration, soundEnabled = config.Sound.enabled, volume = config.Sound.volume })
end)

CreateThread(function()
    local paused = false
    while true do
        Wait(250)
        local state = IsPauseMenuActive()
        local now = state == true or state == 1
        if now ~= paused then
            paused = now
            SendNUIMessage({ action = 'visible', state = not paused })
        end
    end
end)

RegisterCommand('gta6notify', function(_, args)
    show({ type = args[1], position = args[2], message = ('Test powiadomienia typu %s'):format(resolveType(args[1])) })
end)

if config.HookQBCore then
    RegisterNetEvent('QBCore:Notify', function(text, ntype, length)
        if type(text) == 'table' then
            show({ message = text.text, title = text.caption, type = ntype, duration = length })
        else
            show({ message = text, type = ntype, duration = length })
        end
    end)
end

if config.HookESX and GetCurrentResourceName() ~= 'esx_notify' then
    RegisterNetEvent('esx:showNotification', function(msg, ntype, length)
        show({ message = msg, type = ntype, duration = length })
    end)
    RegisterNetEvent('esx:showAdvancedNotification', function(title, _, msg)
        show({ title = title, message = msg })
    end)
end

if config.ZIndex and SetNuiZindex then
    CreateThread(function()
        while true do
            SetNuiZindex(config.ZIndex)
            Wait(250)
        end
    end)
end
