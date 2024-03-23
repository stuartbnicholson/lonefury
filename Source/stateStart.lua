-- State: Player is starting a new game! Setup and opening music?

StateStart = {}
StateStart.__index = StateStart

function StateStart.new()
    local self = setmetatable({}, StateStart)

    return self
end

function StateStart:start()
    print('StateStart start')

    LevelManager:reset()
    Player.lives = 3
    Dashboard:drawLivesMedals()
    Player:spawn()
end

function StateStart:update()
    return StateGame
end