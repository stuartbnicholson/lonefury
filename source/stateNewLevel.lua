-- State: Player is starting a new level!

local gfx = playdate.graphics

StateNewLevel = {}
StateNewLevel.__index = StateNewLevel

function StateNewLevel.new()
    local self = setmetatable({}, StateNewLevel)

    return self
end

function StateNewLevel:start()
    -- if DEVELOPER_BUILD then MemoryCheck() end

    LevelManager:nextLevel()

    gfx.setScreenClipRect(400 - DASH_WIDTH, 0, DASH_WIDTH, VIEWPORT_HEIGHT)
    Dashboard:drawPlayerScore()
    Dashboard:drawLivesMedals()
    gfx.setScreenClipRect(0, 0, VIEWPORT_WIDTH, VIEWPORT_HEIGHT)

    Player:spawn()
end

function StateNewLevel:update()
    StateRespawn:start()
    return StateRespawn
end
