Config = {}
Config.OpenMenu = 'I'
Config.StressChance = 0.1
Config.UseMPH = true
Config.MinimumStress = 50
Config.MinimumSpeedUnbuckled = 50
Config.MinimumSpeed = 100
Config.DisableStress = false
Config.ShowCompass = true
Config.ShowFullHealthInVehicle = false
Config.VehicleHealthTimeout = 6000
Config.VehicleHealthLow = 50
Config.StatusTimeout = 6000
Config.ShowStatusAlways = false

Config.ShowZone = true
Config.ShowNavigation = true

Config.Locale = 'en'
Config.NavUnits = 'imperial'

Config.WhitelistedWeaponArmed = {
    [`weapon_petrolcan`] = true,
    [`weapon_hazardcan`] = true,
    [`weapon_fireextinguisher`] = true,
    [`weapon_dagger`] = true,
    [`weapon_bat`] = true,
    [`weapon_bottle`] = true,
    [`weapon_crowbar`] = true,
    [`weapon_flashlight`] = true,
    [`weapon_golfclub`] = true,
    [`weapon_hammer`] = true,
    [`weapon_hatchet`] = true,
    [`weapon_knuckle`] = true,
    [`weapon_knife`] = true,
    [`weapon_machete`] = true,
    [`weapon_switchblade`] = true,
    [`weapon_nightstick`] = true,
    [`weapon_wrench`] = true,
    [`weapon_battleaxe`] = true,
    [`weapon_poolcue`] = true,
    [`weapon_briefcase`] = true,
    [`weapon_briefcase_02`] = true,
    [`weapon_garbagebag`] = true,
    [`weapon_handcuffs`] = true,
    [`weapon_bread`] = true,
    [`weapon_stone_hatchet`] = true,
    [`weapon_grenade`] = true,
    [`weapon_bzgas`] = true,
    [`weapon_molotov`] = true,
    [`weapon_stickybomb`] = true,
    [`weapon_proxmine`] = true,
    [`weapon_snowball`] = true,
    [`weapon_pipebomb`] = true,
    [`weapon_ball`] = true,
    [`weapon_smokegrenade`] = true,
    [`weapon_flare`] = true
}

Config.WhitelistedWeaponStress = {
    [`weapon_petrolcan`] = true,
    [`weapon_hazardcan`] = true,
    [`weapon_fireextinguisher`] = true
}

Config.VehClassStress = {
    ['0'] = true,
    ['1'] = true,
    ['2'] = true,
    ['3'] = true,
    ['4'] = true,
    ['5'] = true,
    ['6'] = true,
    ['7'] = true,
    ['8'] = true,
    ['9'] = true,
    ['10'] = true,
    ['11'] = true,
    ['12'] = true,
    ['13'] = false,
    ['14'] = false,
    ['15'] = false,
    ['16'] = false,
    ['18'] = false,
    ['19'] = false,
    ['20'] = false,
    ['21'] = false
}

Config.WhitelistedVehicles = {
}

Config.WhitelistedJobs = {
    ['leo'] = true,
    ['ambulance'] = true
}

Config.Intensity = {
    ['blur'] = {
        [1] = {
            min = 50,
            max = 60,
            intensity = 1500,
        },
        [2] = {
            min = 60,
            max = 70,
            intensity = 2000,
        },
        [3] = {
            min = 70,
            max = 80,
            intensity = 2500,
        },
        [4] = {
            min = 80,
            max = 90,
            intensity = 2700,
        },
        [5] = {
            min = 90,
            max = 100,
            intensity = 3000,
        },
    }
}

Config.EffectInterval = {
    [1] = {
        min = 50,
        max = 60,
        timeout = math.random(50000, 60000)
    },
    [2] = {
        min = 60,
        max = 70,
        timeout = math.random(40000, 50000)
    },
    [3] = {
        min = 70,
        max = 80,
        timeout = math.random(30000, 40000)
    },
    [4] = {
        min = 80,
        max = 90,
        timeout = math.random(20000, 30000)
    },
    [5] = {
        min = 90,
        max = 100,
        timeout = math.random(15000, 20000)
    }
}

Config.Menu = {
    isOutMapChecked = false,
    isOutCompassChecked = false,
    isCompassFollowChecked = true,
    isOpenMenuSoundsChecked = true,
    isResetSoundsChecked = true,
    isListSoundsChecked = true,
    isLowFuelChecked = true,
    isCinematicNotifChecked = true,
    isDynamicHealthChecked = true,
    isDynamicArmorChecked = true,
    isDynamicHungerChecked = true,
    isDynamicThirstChecked = true,
    isDynamicStressChecked = true,
    isDynamicOxygenChecked = true,
    isChangeFPSChecked = true,
    isHideMapChecked = false,
    isDynamicEngineChecked = true,
    isDynamicNitroChecked = true,
    isChangeCompassFPSChecked = true,
    isCompassShowChecked = true,
    isShowStreetsChecked = true,
    isPointerShowChecked = true,
    isDegreesShowChecked = true,
    isCinematicModeChecked = false,
}

Config.CustomWeaponHud = true

Config.WeaponHudHidden = {
    `weapon_unarmed`,
}

Config.WeaponIcons = {
    'gadget_parachute',
    'weapon_advancedrifle',
    'weapon_appistol',
    'weapon_assaultrifle',
    'weapon_assaultrifle_mk2',
    'weapon_assaultshotgun',
    'weapon_assaultsmg',
    'weapon_autoshotgun',
    'weapon_ball',
    'weapon_bat',
    'weapon_battleaxe',
    'weapon_bottle',
    'weapon_bullpuprifle',
    'weapon_bullpuprifle_mk2',
    'weapon_bullpupshotgun',
    'weapon_bzgas',
    'weapon_carbinerifle',
    'weapon_carbinerifle_mk2',
    'weapon_ceramicpistol',
    'weapon_combatmg',
    'weapon_combatmg_mk2',
    'weapon_combatpdw',
    'weapon_combatpistol',
    'weapon_combatshotgun',
    'weapon_compactlauncher',
    'weapon_compactrifle',
    'weapon_crowbar',
    'weapon_dagger',
    'weapon_dbshotgun',
    'weapon_doubleaction',
    'weapon_fireextinguisher',
    'weapon_firework',
    'weapon_flare',
    'weapon_flaregun',
    'weapon_flashlight',
    'weapon_gadgetpistol',
    'weapon_golfclub',
    'weapon_grenade',
    'weapon_grenadelauncher',
    'weapon_grenadelauncher_smoke',
    'weapon_gusenberg',
    'weapon_hammer',
    'weapon_hatchet',
    'weapon_hazardcan',
    'weapon_heavypistol',
    'weapon_heavyrifle',
    'weapon_heavyshotgun',
    'weapon_heavysniper',
    'weapon_heavysniper_mk2',
    'weapon_hominglauncher',
    'weapon_knife',
    'weapon_knuckle',
    'weapon_machete',
    'weapon_machinepistol',
    'weapon_marksmanpistol',
    'weapon_marksmanrifle',
    'weapon_marksmanrifle_mk2',
    'weapon_mg',
    'weapon_microsmg',
    'weapon_militaryrifle',
    'weapon_minigun',
    'weapon_minismg',
    'weapon_molotov',
    'weapon_musket',
    'weapon_navyrevolver',
    'weapon_nightstick',
    'weapon_petrolcan',
    'weapon_pipebomb',
    'weapon_pistol',
    'weapon_pistol50',
    'weapon_pistol_mk2',
    'weapon_poolcue',
    'weapon_precisionrifle',
    'weapon_proxmine',
    'weapon_pumpshotgun',
    'weapon_pumpshotgun_mk2',
    'weapon_railgun',
    'weapon_raycarbine',
    'weapon_rayminigun',
    'weapon_raypistol',
    'weapon_revolver',
    'weapon_revolver_mk2',
    'weapon_rpg',
    'weapon_sawnoffshotgun',
    'weapon_smg',
    'weapon_smg_mk2',
    'weapon_smokegrenade',
    'weapon_sniperrifle',
    'weapon_snowball',
    'weapon_snspistol',
    'weapon_snspistol_mk2',
    'weapon_specialcarbine',
    'weapon_specialcarbine_mk2',
    'weapon_stickybomb',
    'weapon_stone_hatchet',
    'weapon_stungun',
    'weapon_switchblade',
    'weapon_tacticalrifle',
    'weapon_unarmed',
    'weapon_vintagepistol',
    'weapon_wrench',
}
