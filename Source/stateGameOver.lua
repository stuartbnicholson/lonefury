-- State: Player is dead and has no lives left, but enemies and bullets are still in flight.

StateGameOver = {}
StateGameOver.__index = StateGameOver

function StateGameOver.new()
    local self = setmetatable({}, StateGameOver)

    return self
end

function StateGameOver:start()
    print('StateGameOver start')
end

function StateGameOver:update()
    return self
end