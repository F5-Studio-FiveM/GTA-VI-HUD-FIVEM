if not Config.CustomWeaponHud then return end

local icons = {}
for _, name in ipairs(Config.WeaponIcons) do
    icons[joaat(name)] = name
end

local hidden = {}
for _, hash in ipairs(Config.WeaponHudHidden) do
    hidden[hash] = true
end

local iconOnlyGroups = {
    [`GROUP_MELEE`] = true,
    [`GROUP_UNARMED`] = true,
    [`GROUP_PARACHUTE`] = true,
    [`GROUP_STUNGUN`] = true,
    [`GROUP_PETROLCAN`] = true,
}

local last = nil

HUD.Reset[#HUD.Reset + 1] = function()
    last = nil
end

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
    while true do
        HideHudComponentThisFrame(2)
        Wait(0)
    end
end)
