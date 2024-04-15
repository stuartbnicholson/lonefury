import 'assets'
import 'dashboard'
import 'starfield'
import 'poolManager'
import 'levelManager'
import 'soundManager'
import 'stateMenu'
import 'stateCredits'
import 'stateStart'
import 'stateGame'
import 'stateNewLevel'
import 'stateDead'
import 'stateRespawn'
import 'stateGameOver'

local pd = playdate
local gfx = pd.graphics

-- Asset management
Assets.preloadImages({
    'images/title.png',
    'images/alert.png',
    'images/cross.png',
    -- Obstacles
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
    'images/enemy2-table-15-15.png',
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
Assets.preloadFonts({
    'images/Xevious-2x-table-16-16.png',
    'images/Xevious-Score-table-8-16.png'
})

-- Managers
PoolManager = PoolManager.new()
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
    playdate.timer.updateTimers()

    Starfield:update()
    gfx.sprite.update()

    ExplosionsUpdate()
    Dashboard:update()
end

-- From https://sdk.play.date/2.4.2/Inside%20Playdate.html
-- This function relies on the use of timers, so the timer core library
-- must be imported, and updateTimers() must be called in the update loop
function ScreenShake(shakeTime, shakeMagnitude)
    -- Creating a value timer that goes from shakeMagnitude to 0, over
    -- the course of 'shakeTime' milliseconds
    local shakeTimer = pd.timer.new(shakeTime, shakeMagnitude, 0)
    -- Every frame when the timer is active, we shake the screen
    shakeTimer.updateCallback = function(timer)
        -- Using the timer value, so the shaking magnitude
        -- gradually decreases over time
        local magnitude = math.floor(timer.value)
        local shakeX = math.random(-magnitude, magnitude)
        local shakeY = math.random(-magnitude, magnitude)
        pd.display.setOffset(shakeX, shakeY)
    end
    -- Resetting the display offset at the end of the screen shake
    shakeTimer.timerEndedCallback = function()
        pd.display.setOffset(0, 0)
    end
end
