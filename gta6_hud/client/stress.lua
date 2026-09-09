if (HUD.Framework ~= 'qb' and HUD.Framework ~= 'qbx') or Config.DisableStress then return end

local speedMultiplier = Config.UseMPH and 2.23694 or 3.6

CreateThread(function()
    while true do
        if HUD.IsLoggedIn() then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                local veh = GetVehiclePedIsIn(ped, false)
                local vehClass = GetVehicleClass(veh)
                local speed = GetEntitySpeed(veh) * speedMultiplier
                if Config.VehClassStress[tostring(vehClass)] and not Config.WhitelistedVehicles[GetEntityModel(veh)] then
                    local stressSpeed = Config.MinimumSpeed
                    if vehClass ~= 8 and not HUD.Data.seatbelt then
                        stressSpeed = Config.MinimumSpeedUnbuckled
                    end
                    if speed >= stressSpeed then
                        TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                    end
                end
            end
        end
        Wait(10000)
    end
end)

CreateThread(function()
    while true do
        if HUD.IsLoggedIn() then
            local ped = PlayerPedId()
            local weapon = GetSelectedPedWeapon(ped)
            if weapon ~= `WEAPON_UNARMED` then
                if IsPedShooting(ped) and not Config.WhitelistedWeaponStress[weapon] and math.random() < Config.StressChance then
                    TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                end
            else
                Wait(1000)
            end
        end
        Wait(0)
    end
end)

local function blurIntensity(level)
    for _, v in pairs(Config.Intensity['blur']) do
        if level >= v.min and level <= v.max then return v.intensity end
    end
    return 1500
end

local function effectInterval(level)
    for _, v in pairs(Config.EffectInterval) do
        if level >= v.min and level <= v.max then return v.timeout end
    end
    return 60000
end

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local stress = HUD.Data.stress
        local interval = effectInterval(stress)
        if stress >= 100 then
            local blur = blurIntensity(stress)
            local falls = math.random(2, 4)
            local ragdoll = falls * 1750
            TriggerScreenblurFadeIn(1000.0)
            Wait(blur)
            TriggerScreenblurFadeOut(1000.0)
            if not IsPedRagdoll(ped) and IsPedOnFoot(ped) and not IsPedSwimming(ped) then
                SetPedToRagdollWithFall(ped, ragdoll, ragdoll, 1, GetEntityForwardVector(ped), 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
            end
            Wait(1000)
            for _ = 1, falls do
                Wait(750)
                DoScreenFadeOut(200)
                Wait(1000)
                DoScreenFadeIn(200)
                TriggerScreenblurFadeIn(1000.0)
                Wait(blur)
                TriggerScreenblurFadeOut(1000.0)
            end
        elseif stress >= Config.MinimumStress then
            local blur = blurIntensity(stress)
            TriggerScreenblurFadeIn(1000.0)
            Wait(blur)
            TriggerScreenblurFadeOut(1000.0)
        end
        Wait(interval)
    end
end)
