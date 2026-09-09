local stations = {}
local stationKey = ''
local lastLog = {}

local function log(key, text)
    if not Config.Debug or lastLog[key] == text then return end
    lastLog[key] = text
    print(('[gta6_radio] %s'):format(text))
end
local shownUntil = 0
local visible = false
local lastCurrent = nil

local function buildStations()
    local list = {}
    local names = {}
    local count = GetNumUnlockedRadioStations()
    for i = 0, count - 1 do
        local name = GetRadioStationName(i)
        if name and name ~= '' then
            local label = GetLabelText(name)
            list[#list + 1] = { index = i, name = name, label = label ~= 'NULL' and label or name }
            names[#names + 1] = name
        end
    end
    list[#list + 1] = { index = 255, name = 'OFF', label = Config.OffLabel }
    local key = table.concat(names, '|')
    if key ~= stationKey then
        stationKey = key
        stations = list
        SendNUIMessage({ action = 'stations', stations = stations })
    end
end

local function currentIndex()
    local idx = GetPlayerRadioStationIndex()
    if idx == 255 or idx < 0 then return 255 end
    return idx
end

local function positionOf(index)
    for pos, s in ipairs(stations) do
        if s.index == index then return pos end
    end
    return #stations
end

local function tuneTo(pos)
    if pos < 1 then pos = #stations elseif pos > #stations then pos = 1 end
    local target = stations[pos]
    if not target then return end
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local before = GetPlayerRadioStationIndex()
    if target.index == 255 then
        SetRadioToStationName('OFF')
        SetVehRadioStation(vehicle, 'OFF')
    else
        SetVehicleRadioEnabled(vehicle, true)
        SetVehRadioStation(vehicle, target.name)
        SetRadioToStationName(target.name)
    end
    shownUntil = GetGameTimer() + Config.ShowTime
    if Config.Debug then
        SetTimeout(250, function()
            print(('[gta6_radio] tune -> %s (index %s): station index before %s, after %s, radioOn %s'):format(target.name, target.index, before, GetPlayerRadioStationIndex(), tostring(IsVehicleRadioEnabled(vehicle))))
        end)
    end
end

local function canUseRadio(ped)
    local inVehicle = IsPedInAnyVehicle(ped, false)
    local hasRadio = DoesPlayerVehHaveRadio()
    local vehicle = GetVehiclePedIsIn(ped, false)
    local seatOk = inVehicle and (GetPedInVehicleSeat(vehicle, -1) == ped or GetPedInVehicleSeat(vehicle, 0) == ped)
    log('can', ('canUseRadio: inVehicle %s, DoesPlayerVehHaveRadio %s, frontSeat %s, radioOn %s, stationIndex %s'):format(tostring(inVehicle), tostring(hasRadio), tostring(seatOk), tostring(inVehicle and IsVehicleRadioEnabled(vehicle)), GetPlayerRadioStationIndex()))
    return inVehicle and hasRadio and seatOk
end

RegisterNUICallback('ready', function(_, cb)
    SendNUIMessage({ action = 'config', top = Config.Top })
    stationKey = ''
    cb('ok')
end)

local function setVisible(state)
    if state == visible then return end
    visible = state
    SendNUIMessage({ action = 'radio', show = state, current = currentIndex() })
    if state then lastCurrent = currentIndex() end
end

SetUserRadioControlEnabled(true)

local wheelControls = { 81, 82, 14, 15, 16, 17, 241, 242 }

CreateThread(function()
    local wasInVehicle = false
    local wasHolding = false
    local selectedPos = 1
    while true do
        local ped = PlayerPedId()
        local usable = canUseRadio(ped)
        if usable then
            if not wasInVehicle then
                buildStations()
                wasInVehicle = true
            end
            local holding = false
            if Config.TakeOverControls then
                DisableControlAction(0, 85, true)
                holding = IsDisabledControlPressed(0, 85)
                log('hold', 'Q held: ' .. tostring(holding))
                if holding then
                    if not wasHolding then selectedPos = positionOf(currentIndex()) end
                    for _, control in ipairs(wheelControls) do DisableControlAction(0, control, true) end
                    local next = IsDisabledControlJustPressed(0, 242) or IsControlJustPressed(0, 175)
                    local prev = IsDisabledControlJustPressed(0, 241) or IsControlJustPressed(0, 174)
                    if next or prev then
                        log('press', ('input: next %s prev %s (242 %s, 241 %s, 81 %s, 82 %s, 14 %s, 15 %s, 175 %s, 174 %s) selected %s'):format(tostring(next), tostring(prev), tostring(IsDisabledControlJustPressed(0, 242)), tostring(IsDisabledControlJustPressed(0, 241)), tostring(IsDisabledControlJustPressed(0, 81)), tostring(IsDisabledControlJustPressed(0, 82)), tostring(IsDisabledControlJustPressed(0, 14)), tostring(IsDisabledControlJustPressed(0, 15)), tostring(IsControlJustPressed(0, 175)), tostring(IsControlJustPressed(0, 174)), selectedPos))
                        lastLog['press'] = nil
                    end
                    if next then
                        selectedPos = selectedPos + 1
                        if selectedPos > #stations then selectedPos = 1 end
                        tuneTo(selectedPos)
                    elseif prev then
                        selectedPos = selectedPos - 1
                        if selectedPos < 1 then selectedPos = #stations end
                        tuneTo(selectedPos)
                    end
                end
                wasHolding = holding
            else
                holding = IsControlPressed(0, 85)
            end
            local now = GetGameTimer()
            local current = currentIndex()
            if current ~= lastCurrent then
                log('cur', ('station index changed %s -> %s (%s)'):format(tostring(lastCurrent), current, GetPlayerRadioStationName() or 'nil'))
                lastCurrent = current
                shownUntil = now + Config.ShowTime
                if visible then SendNUIMessage({ action = 'radio', show = true, current = current }) end
            end
            if IsPauseMenuActive() then
                setVisible(false)
            else
                setVisible(holding or now < shownUntil)
            end
            Wait(0)
        else
            if wasInVehicle then
                wasInVehicle = false
                setVisible(false)
            end
            Wait(250)
        end
    end
end)
