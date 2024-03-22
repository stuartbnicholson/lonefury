-- State: Game is in credit roll

StateCredits = {}
StateCredits.__index = StateCredits

function StateCredits.new()
    local self = setmetatable({}, StateCredits)

    return self
end

function StateCredits:update()
    return self
end