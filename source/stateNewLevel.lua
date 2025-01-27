-- State: Player is starting a new level!

StateNewLevel = {}
StateNewLevel.__index = StateNewLevel

function StateNewLevel.new()
    local self = setmetatable({}, StateNewLevel)

    return self
end

function StateNewLevel:start()
    if DEVELOPER_BUILD then MemoryCheck() end

    LevelManager:nextLevel()
    Dashboard:drawPlayerScore()
    Dashboard:drawLivesMedals()
    Player:spawn()
end

function StateNewLevel:update()
    StateRespawn:start()
    return StateRespawn
end
