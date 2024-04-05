-- State: Player is starting a new level!

StateNewLevel = {}
StateNewLevel.__index = StateNewLevel

function StateNewLevel.new()
    local self = setmetatable({}, StateNewLevel)

    return self
end

function StateNewLevel:start()
    print('StateNewLevel start')
    MemoryCheck()

    LevelManager:nextLevel()
    Dashboard:drawPlayerScore()
    Dashboard:drawLivesMedals()
    Player:spawn()
end

function StateNewLevel:update()
    return StateSpawn
end