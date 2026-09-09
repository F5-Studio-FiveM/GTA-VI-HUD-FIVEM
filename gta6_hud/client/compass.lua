if not Config.ShowCompass then return end

local prevBaseplate = {}

local function updateBaseplate(data)
    local changed = false
    for k, v in pairs(data) do
        if prevBaseplate[k] ~= v then
            changed = true
            break
        end
    end
    prevBaseplate = data
    if not changed then return end
    SendNUIMessage({
        action = 'baseplate',
        show = data[1],
        street1 = data[2],
        street2 = data[3],
        showCompass = data[4],
        showStreets = data[5],
        showPointer = data[6],
        showDegrees = data[7],
    })
end

local lastCrossroadUpdate = 0
local crossroads = { '', '' }

local function getCrossroads(ped)
    local now = GetGameTimer()
    if now - lastCrossroadUpdate > 1500 then
        local pos = GetEntityCoords(ped)
        local street1, street2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
        lastCrossroadUpdate = now
        crossroads = { GetStreetNameFromHashKey(street1), GetStreetNameFromHashKey(street2) }
    end
    return crossroads
end

local function round(value)
    return math.floor(value + 0.5)
end

local lastHeading = -1

HUD.Reset[#HUD.Reset + 1] = function()
    prevBaseplate = {}
    lastHeading = -1
    lastCrossroadUpdate = 0
end

CreateThread(function()
    while true do
        Wait(HUD.Menu.isChangeCompassFPSChecked and 50 or 0)
        if HUD.IsLoggedIn() then
            local ped = PlayerPedId()
            local menu = HUD.Menu
            local heading
            if menu.isCompassFollowChecked then
                heading = round(360.0 - ((GetGameplayCamRot(0).z + 360.0) % 360.0))
            else
                heading = round(360.0 - GetEntityHeading(ped))
            end
            if heading == 360 then heading = 0 end
            local inVehicle = IsPedInAnyVehicle(ped, false)
            if (inVehicle or menu.isOutCompassChecked) and heading ~= lastHeading then
                lastHeading = heading
                SendNUIMessage({ action = 'update', value = heading })
            end
            if inVehicle then
                local streets = getCrossroads(ped)
                updateBaseplate({
                    true,
                    streets[1],
                    streets[2],
                    menu.isCompassShowChecked,
                    menu.isShowStreetsChecked,
                    menu.isPointerShowChecked,
                    menu.isDegreesShowChecked,
                })
            elseif menu.isOutCompassChecked then
                updateBaseplate({ true, '', '', true, false, menu.isPointerShowChecked, menu.isDegreesShowChecked })
            else
                updateBaseplate({ false })
            end
        end
    end
end)
