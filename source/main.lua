import 'assets'
import 'constants'
import 'globals'
import 'dashboard'
import 'starfield'
import 'poolManager'
import 'levelDefGenerator'
import 'levelRandomGenerator'
import 'levelManager'
import 'soundManager'
import 'highScoreManager'
import 'stateMenu'
import 'stateInstructions'
import 'stateHighscore'
import 'stateHighscoreEntry'
import 'stateStart'
import 'stateGame'
import 'stateNewLevel'
import 'stateDead'
import 'stateRespawn'
import 'stateGameOver'
import 'stateTest'

local pd = playdate
local gfx = pd.graphics

-- Asset management
Assets.preloadImages({
    'images/title.png',
    'images/alert.png',
    'images/cross.png',
    -- Obstacles
    'images/asteroid.png',
    'images/egg.png',
    -- Bases
    'images/baseQuarterVert.png',
    'images/baseGunVert.png',
    'images/baseQuarterHoriz.png',
    'images/baseGunHoriz.png',
    'images/baseRuin1.png',
    'images/baseRuin2.png',
    'images/baseSphereMask.png',
    -- New bases
    'images/baseHalfVert.png',
    'images/baseHalfHoriz.png',
    'images/baseGunShieldVert.png',
    'images/baseGunShieldHoriz.png',
    -- Dashboard
    'images/dashboard.png',
    'images/playerLife.png',
    'images/medal1.png',
    'images/medal5.png'
})
Assets.preloadImagetables({
    'images/enemy-table-15-15.png',
    'images/enemy2-table-15-15.png',
    'images/exhaust-table-16-16.png',
    'images/enemyMonster-table-45-45.png',
    -- Bases
    'images/bigBullet-table-4-4.png',
    'images/baseZap-table-11-11.png',
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
-- LevelGenerator = LevelDefGenerator.new()
LevelGenerator = LevelRandomGenerator.new()
LevelManager = LevelManager.new(LevelGenerator)
SoundManager = SoundManager.new()
HighScoreManager = HighScoreManager.new()

-- TODO: The game state machine
StateMenu = StateMenu.new()
StateInstructions = StateInstructions.new()
StateHighscore = StateHighscore.new()
StateHighscoreEntry = StateHighscoreEntry.new()
StartStart = StateStart.new()
StateGame = StateGame.new()
StateDead = StateDead.new()
StateRespawn = StateRespawn.new()
StateGameOver = StateGameOver.new()
StateTest = StateTest.new()

-- Set the initial Game State
local currentState = StateMenu
-- local currentState = StateTest
currentState:start()

Dashboard = Dashboard.new()
Starfield = Starfield.new()

-- Add to the System Menu
function SetupMenu()
    local menu = pd.getSystemMenu()

    local menuItem, error = menu:addCheckmarkMenuItem("Show FPS", false,
        function(value)
            ShowFPS = value
        end)

    local menuItem2, error = menu:addCheckmarkMenuItem("Show Level", false,
        function(value)
            ShowLevel = value
        end)
end

SetupMenu()

local pauseImage = gfx.image.new(400, 240)
function pd.gameWillPause()
    if ShowLevel then
        pauseImage:clear(gfx.kColorBlack)
        gfx.pushContext(pauseImage)
        LevelGenerator.occupiedMap:draw(0, 0)
        gfx.popContext()
        pd.setMenuImage(pauseImage)
    else
        pd.setMenuImage(nil)
    end
end

local ms = pd.getCurrentTimeMilliseconds
function pd.update()
    local frameStart = ms()

    currentState = currentState:update()

    -- From: https://devforum.play.date/t/best-practices-for-managing-lots-of-assets/395
    Assets.lazyLoad(frameStart)
end

-- Common WorldUpdate that most States will use
function WorldUpdate()
    -- Reset activity counts
    ActiveEnemy = 0
    ActiveVisibleEnemy = 0
    ActiveEnemyFormations = 0
    ActiveEnemyBases = 0
    ActiveVisibleEnemyBases = 0

    -- Update all the things
    pd.timer.updateTimers()
    gfx.animation.blinker.updateAll()
    Starfield:update()
    gfx.sprite.update()
    ExplosionsUpdate()
    LevelManager:update()
    Dashboard:update()

    if pd.getCurrentTimeMilliseconds() % 1000 < 10 then
        print('Active ', ActiveEnemy, ActiveEnemyFormations, ActiveEnemyBases, ActiveVisibleEnemyBases)
    end
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
