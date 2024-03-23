import 'dashboard'
import 'starfield'
import 'levelManager'
import 'soundManager'
import 'stateMenu'
import 'stateCredits'
import 'stateStart'
import 'stateGame'
import 'stateDead'
import 'stateRespawn'
import 'stateGameOver'

local pd = playdate
local gfx = pd.graphics

-- Managers
LevelManager = LevelManager.new()
SoundManager = SoundManager.new()

-- TODO: The game state machine
StateMenu = StateMenu.new()
StateCredits = StateCredits.new()
StartStart = StateStart.new()
StateGame = StateGame.new()
StateDead = StateDead.new()
StateRespawn = StateRespawn.new()
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

-- Common WorldUpdate that most States will use
function WorldUpdate()
    Starfield:update()
    gfx.sprite.update()

    ExplosionsUpdate()
    EnemyBigBulletsUpdate()
    Dashboard:update()
end