Config = {}

Config.Position = 'bottom-center'
Config.Duration = 6000
Config.MaxVisible = 5
Config.Scale = 0.5
Config.ZIndex = 99998
Config.Title = 'NOTIFICATION'
Config.DedupeWindow = 150
Config.HookQBCore = false
Config.HookESX = false

Config.Sound = {
    enabled = true,
    file = 'digital-quick-tone.ogg',
    volume = 0.1,
}

Config.Positions = {
    'top-left', 'top-center', 'top-right',
    'left-center', 'center', 'right-center',
    'bottom-left', 'bottom-center', 'bottom-right',
}

Config.Types = {
    car = { icon = 'car.png', color = '#c054f6' },
    error = { icon = 'error.png', color = '#ea3052' },
    heart = { icon = 'heart.png', color = '#af4ef6' },
    house = { icon = 'house.png', color = '#2da7f7' },
    info = { icon = 'info.png', color = '#c178f7' },
    location = { icon = 'location.png', color = '#c75cf6' },
    money = { icon = 'money.png', color = '#f5ae20' },
    objective = { icon = 'objective.png', color = '#765ef6' },
    question = { icon = 'question.png', color = '#2799f6' },
    success = { icon = 'success.png', color = '#45d577' },
    warning = { icon = 'warning.png', color = '#f58d1d' },
}

Config.Aliases = {
    primary = 'info',
    inform = 'info',
    information = 'info',
    warn = 'warning',
    fail = 'error',
    police = 'objective',
    ambulance = 'heart',
    cash = 'money',
    bank = 'money',
    vehicle = 'car',
    home = 'house',
    property = 'house',
    target = 'objective',
    mission = 'objective',
    gps = 'location',
}
