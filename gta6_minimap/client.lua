local MAP_X, MAP_Y, MAP_W, MAP_H = -0.0045, 0.002, 0.170, 0.188888

local placement = ''

local function placeMinimap()
    local aspect = GetAspectRatio(false)
    SetScriptGfxAlign(76, 66)
    local origin = GetScriptGfxPosition(0.0, 0.0)
    ResetScriptGfxAlign()
    local key = ('%.4f|%.4f'):format(aspect, origin)
    if key == placement then return false end
    placement = key
    local scale = aspect > 0.0 and 1.7777 / aspect or 1.0
    SetMinimapComponentPosition('minimap', 'L', 'B', (origin + MAP_X) * scale - origin, MAP_Y, MAP_W, MAP_H)
    return true
end

local function loadMap()
    RequestStreamedTextureDict('gta6_graphics', false)
    local deadline = GetGameTimer() + 5000
    while not HasStreamedTextureDictLoaded('gta6_graphics') and GetGameTimer() < deadline do
        Wait(10)
    end
    AddReplaceTexture('platform:/textures/graphics', 'radarmasksm', 'gta6_graphics', 'radarmasksm')
    placement = ''
    placeMinimap()
    ReplaceHudColourWithRgba(142, 247, 115, 164, 255)
    SetBigmapActive(true, false)
    Wait(50)
    SetBigmapActive(false, false)
end

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    Wait(2000)
    loadMap()
end)

AddEventHandler('playerSpawned', function()
    Wait(2000)
    loadMap()
end)

CreateThread(function()
    while true do
        if placeMinimap() then
            SetBigmapActive(true, false)
            Wait(0)
        end
        SetBigmapActive(false, false)
        SetRadarZoom(1000)
        Wait(500)
    end
end)
