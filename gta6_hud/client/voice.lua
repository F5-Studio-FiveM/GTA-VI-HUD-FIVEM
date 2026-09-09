local VOICE_MODES = 3
local defaultIndex = GetConvarInt('voice_defaultVoiceMode', 2)
local radioActive = false
local last = {}

AddEventHandler('pma-voice:radioActive', function(state)
    radioActive = state
end)

HUD.Reset[#HUD.Reset + 1] = function()
    last = {}
end

CreateThread(function()
    while true do
        Wait(50)
        local proximity = LocalPlayer.state['proximity']
        local index = proximity and proximity.index or defaultIndex
        local level = math.min(index / VOICE_MODES, 1.0)
        local talking = NetworkIsPlayerTalking(PlayerId())
        local radio = LocalPlayer.state['radioChannel']
        if last.level ~= level or last.talking ~= talking or last.radio ~= radio or last.radioActive ~= radioActive then
            last.level, last.talking, last.radio, last.radioActive = level, talking, radio, radioActive
            SendNUIMessage({
                action = 'voice',
                level = level,
                talking = talking,
                radio = radio,
                radioActive = radioActive,
            })
        end
    end
end)
