local speedMultiplier = Config.UseMPH and 2.23694 or 3.6

local prevPlayer = {}

local function updatePlayerHud(data)
    local changed = false
    for k, v in pairs(data) do
        if prevPlayer[k] ~= v then
            changed = true
            break
        end
    end
    prevPlayer = data
    if not changed then return end
    SendNUIMessage({
        action = 'hudtick',
        show = data[1],
        dynamicHealth = data[2],
        dynamicArmor = data[3],
        dynamicHunger = data[4],
        dynamicThirst = data[5],
        dynamicStress = data[6],
        dynamicOxygen = data[7],
        dynamicEngine = data[8],
        dynamicNitro = data[9],
        health = data[10],
        playerDead = data[11],
        armor = data[12],
        thirst = data[13],
        hunger = data[14],
        stress = data[15],
        armed = data[16],
        oxygen = data[17],
        parachute = data[18],
        nos = data[19],
        cruise = data[20],
        nitroActive = data[21],
        harness = data[22],
        hp = data[23],
        engine = data[24],
        dev = data[25],
        underwater = data[26],
    })
end

local prevVehicle = {}
local namedVehicle, vehicleMake, vehicleModel = nil, '', ''

local function getVehicleName(vehicle)
    if vehicle ~= namedVehicle then
        namedVehicle = vehicle
        local model = GetEntityModel(vehicle)
        local displayName = GetDisplayNameFromVehicleModel(model)
        local make = GetLabelText(GetMakeNameFromVehicleModel(model))
        local name = GetLabelText(displayName)
        vehicleMake = make ~= 'NULL' and make or ''
        vehicleModel = name ~= 'NULL' and name or displayName
    end
    return vehicleMake, vehicleModel
end

local function updateVehicleHud(data)
    local changed = false
    for k, v in pairs(data) do
        if prevVehicle[k] ~= v then
            changed = true
            break
        end
    end
    prevVehicle = data
    if not changed then return end
    SendNUIMessage({
        action = 'car',
        show = data[1],
        seatbelt = data[2],
        speed = data[3],
        fuel = data[4],
        altitude = data[5],
        showAltitude = data[6],
        showSeatbelt = data[7],
        make = data[8],
        model = data[9],
        zone = data[10],
        navDir = data[11],
        navDist = data[12],
    })
end

local lastZoneUpdate = 0
local lastZone = ''

local function getZoneName(ped)
    if not Config.ShowZone then return '' end
    local now = GetGameTimer()
    if now - lastZoneUpdate > 1500 then
        lastZoneUpdate = now
        local pos = GetEntityCoords(ped)
        local label = GetLabelText(GetNameOfZone(pos.x, pos.y, pos.z))
        lastZone = label ~= 'NULL' and label or ''
    end
    return lastZone
end

local navDir, navDist = 0, 0
local navTurns = { [3] = true, [4] = true, [6] = true, [7] = true }

local function navTarget()
    local blip = GetFirstBlipInfoId(8)
    if not DoesBlipExist(blip) then return nil end
    local coord = GetBlipInfoIdCoord(blip)
    local found, node = GetClosestVehicleNode(coord.x, coord.y, coord.z, 1, 3.0, 0)
    return found and node or coord
end

CreateThread(function()
    local prevPos, prevDir = nil, 0
    while true do
        Wait(200)
        local pos = GetEntityCoords(PlayerPedId())
        local target = Config.ShowNavigation and IsWaypointActive() and navTarget() or nil
        if not target then
            navDir, navDist, prevDir = 0, 0, 0
        elseif #(vector2(pos.x, pos.y) - vector2(target.x, target.y)) < 25.0 then
            navDir, navDist, prevDir = 9, 0, 9
        else
            GenerateDirectionsToCoord(target.x, target.y, target.z, true)
            Wait(0)
            local _, direction, _, junction = GenerateDirectionsToCoord(target.x, target.y, target.z, true)
            if direction ~= 0 then navDir = direction end
            local metres = junction / 10
            if not navTurns[navDir] then
                navDist = 0
            elseif metres > 0 then
                navDist = math.floor(metres + 0.5)
            elseif navDir ~= prevDir then
                navDist = 0
            elseif prevPos then
                navDist = math.max(0, navDist - math.floor(#(vector2(pos.x, pos.y) - vector2(prevPos.x, prevPos.y)) + 0.5))
            end
            prevDir = navDir
        end
        prevPos = pos
    end
end)

local lastFuelUpdate = 0
local lastFuelVehicle = 0
local lastFuel = 100

local function getFuelLevel(vehicle)
    local now = GetGameTimer()
    if vehicle ~= lastFuelVehicle or now - lastFuelUpdate > 2000 then
        lastFuelUpdate = now
        lastFuelVehicle = vehicle
        local ok, fuel = pcall(function() return exports['LegacyFuel']:GetFuel(vehicle) end)
        lastFuel = math.floor(ok and tonumber(fuel) or GetVehicleFuelLevel(vehicle))
    end
    return lastFuel
end

local function getParachute(ped)
    local state = GetPedParachuteState(ped)
    if state == 1 or state == 2 then return state end
    return -1
end

local loggedOutSent = false

HUD.Reset[#HUD.Reset + 1] = function()
    prevPlayer = {}
    prevVehicle = {}
    namedVehicle = nil
    loggedOutSent = false
end

CreateThread(function()
    local wasInVehicle = false
    while true do
        Wait(HUD.Menu.isChangeFPSChecked and 500 or 50)
        if HUD.IsLoggedIn() then
            loggedOutSent = false
            local ped = PlayerPedId()
            local playerId = PlayerId()
            local menu = HUD.Menu
            local d = HUD.Data
            local show = not IsPauseMenuActive() and HUD.Cinematic == 0
            local weapon = GetSelectedPedWeapon(ped)
            local armed = weapon ~= `WEAPON_UNARMED` and not Config.WhitelistedWeaponArmed[weapon]
            local underwater = IsEntityInWater(ped)
            local oxygen = underwater and GetPlayerUnderwaterTimeRemaining(playerId) * 10 or 100 - GetPlayerSprintStaminaRemaining(playerId)
            local vehicle = GetVehiclePedIsIn(ped, false)
            local inVehicle = IsPedInAnyVehicle(ped, false) and not IsThisModelABicycle(GetEntityModel(vehicle))
            local dead = IsEntityDead(ped) or HUD.IsDead()
            local engine = 100
            local speed = 0
            if inVehicle then
                engine = GetVehicleEngineHealth(vehicle) / 10
                if engine ~= engine then engine = 0 end
                speed = math.ceil(GetEntitySpeed(vehicle) * speedMultiplier)
            end
            DisplayRadar(HUD.Cinematic == 0 and ((inVehicle and not menu.isHideMapChecked) or (not inVehicle and menu.isOutMapChecked)))
            updatePlayerHud({
                show,
                menu.isDynamicHealthChecked,
                menu.isDynamicArmorChecked,
                menu.isDynamicHungerChecked,
                menu.isDynamicThirstChecked,
                menu.isDynamicStressChecked,
                menu.isDynamicOxygenChecked,
                menu.isDynamicEngineChecked,
                menu.isDynamicNitroChecked,
                GetEntityHealth(ped) - 100,
                dead,
                GetPedArmour(ped),
                d.thirst,
                d.hunger,
                d.stress,
                armed,
                math.floor(oxygen),
                getParachute(ped),
                inVehicle and d.nos or -1,
                d.cruise,
                d.nitroActive,
                d.harness,
                d.hp,
                math.floor(engine),
                d.dev,
                underwater,
            })
            if inVehicle then
                wasInVehicle = true
                local air = IsPedInAnyHeli(ped) or IsPedInAnyPlane(ped)
                local make, model = getVehicleName(vehicle)
                updateVehicleHud({
                    show,
                    d.seatbelt,
                    speed,
                    getFuelLevel(vehicle),
                    math.ceil(GetEntityCoords(ped).z * 0.5),
                    air,
                    d.showSeatbelt and not air,
                    make,
                    model,
                    getZoneName(ped),
                    navDir,
                    navDist,
                })
            elseif wasInVehicle then
                wasInVehicle = false
                prevVehicle = {}
                SendNUIMessage({ action = 'car', show = false, left = true })
                d.seatbelt = false
                d.cruise = false
                d.harness = false
            end
        elseif not loggedOutSent then
            loggedOutSent = true
            SendNUIMessage({ action = 'hudtick', show = false })
        end
    end
end)

CreateThread(function()
    while true do
        Wait(10000)
        if HUD.IsLoggedIn() and HUD.Menu.isLowFuelChecked then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                if not IsThisModelABicycle(GetEntityModel(vehicle)) and getFuelLevel(vehicle) <= 20 then
                    HUD.Notify(Locale('low_fuel'), 'error')
                    Wait(60000)
                end
            end
        end
    end
end)
