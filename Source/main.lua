import 'assets'
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

-- Asset management
Assets.preloadImages({
    'images/asteroid.png',
    -- Bases
    'images/baseQuarterVert.png',
    'images/baseGunVert.png',
    'images/baseQuarterHoriz.png',
    'images/baseGunHoriz.png',
    'images/baseRuin1.png',
    'images/baseRuin2.png',
    'images/baseSphereMask.png',
    -- Dashboard
    'images/dashboard.png',
    'images/playerLife.png',
    'images/medal1.png',
    'images/medal5.png'
})
Assets.preloadImagetables({
    'images/enemy-table-15-15.png',
    -- Bases
    'images/bigBullet-table-4-4.png',
    -- Dashboard
    'images/mapPlayer-table-7-6.png',
    -- Explosions
    'images/explosmall-table-15-15.png',
    'images/explomed-table-20-20.png',
    'images/explobase-table-72-72.png',
    -- Player
    'images/player-table-15-15.png'
}
)

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

local ms = pd.getCurrentTimeMilliseconds
function playdate.update()
    local frameStart = ms()

    currentState = currentState:update()

    -- From: https://devforum.play.date/t/best-practices-for-managing-lots-of-assets/395
    Assets.lazyLoad(frameStart)
end

-- Common WorldUpdate that most States will use
function WorldUpdate()
    Starfield:update()
    gfx.sprite.update()

    ExplosionsUpdate()
    Dashboard:update()
end