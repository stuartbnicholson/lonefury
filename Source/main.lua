import 'stateGame'

-- TODO: The game state machine
local stateGame = StateGame.new()
local currentState = stateGame

function playdate.update()
    currentState:update()
end