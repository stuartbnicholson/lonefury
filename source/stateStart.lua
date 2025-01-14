-- State: Player is starting a new game! Setup and opening music?

StateStart = {}
StateStart.__index = StateStart

function StateStart.new()
    local self = setmetatable({}, StateStart)

    return self
end

function StateStart:start()
    print('StateStart start')
    MemoryCheck()

    SoundManager:introMusic(false)
    LevelManager:reset()
    Player:reset()
    Dashboard:drawPlayerScore()
    Dashboard:drawLivesMedals()
end

function StateStart:update()
    StateRespawn:start()
    return StateRespawn
end
