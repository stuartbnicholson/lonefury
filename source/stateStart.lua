-- State: Player is starting a new game! Setup and opening music?

local gfx = playdate.graphics

StateStart = {}
StateStart.__index = StateStart

function StateStart.new()
    local self = setmetatable({}, StateStart)

    return self
end

function StateStart:start()
    -- if DEVELOPER_BUILD then MemoryCheck() end

    SoundManager:titleMusic(false)
    LevelManager:reset()
    Player:reset()

    gfx.setScreenClipRect(400 - DASH_WIDTH, 0, DASH_WIDTH, VIEWPORT_HEIGHT)
    Dashboard:drawPlayerScore()
    Dashboard:drawLivesMedals()
    gfx.setScreenClipRect(0, 0, VIEWPORT_WIDTH, VIEWPORT_HEIGHT)
end

function StateStart:update()
    StateRespawn:start()
    return StateRespawn
end
