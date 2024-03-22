StateDead = {}
StateDead.__index = StateDead

function StateDead.new()
    local self = setmetatable({}, StateDead)

    return self
end

function StateDead:update()
    -- TODO: Now this gets interesting. We probably don't want a 'StateDead' because the rest of the game has to keep running

    return self
end