StateGameOver = {}
StateGameOver.__index = StateGameOver

function StateGameOver.new()
    local self = setmetatable({}, StateGameOver)

    return self
end

function StateGameOver:update()
    return self
end