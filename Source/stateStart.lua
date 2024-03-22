-- State: Player is starting a new game! Setup and opening music?

StateStart = {}
StateStart.__index = StateStart

function StateStart.new()
    local self = setmetatable({}, StateStart)

    return self
end

function StateStart:update()
    return self
end