import 'dashboard'
import 'starfield'
import 'stateMenu'
import 'stateCredits'
import 'stateGame'
import 'stateDead'
import 'stateGameOver'

local pd = playdate
local gfx = pd.graphics

-- TODO: The game state machine
StateMenu = StateMenu.new()
StateCredits = StateCredits.new()
StateGame = StateGame.new()
StateDead = StateDead.new()
StateGameOver = StateGameOver.new()

local currentState = StateMenu

-- Common assets
Font = gfx.font.new("images/Nontendo-Bold-2x-table-20-26.png") -- From play.date SDK resources
assert(Font, 'Failed to load font')

Dashboard = Dashboard.new()
Starfield = Starfield.new()

function playdate.update()
    currentState = currentState:update()
end