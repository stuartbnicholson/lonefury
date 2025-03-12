import 'CoreLibs/animation'
import 'CoreLibs/crank'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/timer'
import 'CoreLibs/ui'

import 'utility'
import 'assets'
import 'asteroid'
import 'constants'
import 'dashboard'
import 'egg'
import 'enemy'
import 'enemyAI'
import 'enemyBase'
import 'enemyBaseHalf'
import 'enemyBaseZap'
import 'enemyBigBullet'
import 'enemyMonster'
import 'explosion'
import 'globals'
import 'highScoreManager'
import 'levelManager'
import 'levelRandomGenerator'
import 'lume'
import 'mine'
import 'mineExplosion'
import 'player'
import 'playerBullet'
import 'poolManager'
import 'soundManager'
import 'starfield'
import 'stateDead'
import 'stateGame'
import 'stateGameOver'
import 'stateHighscore'
import 'stateHighscoreEntry'
import 'stateInstructions'
import 'stateMenu'
import 'stateNewLevel'
import 'stateRespawn'
import 'stateStart'

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
    'images/alert.png',
    'images/dangerBar.png',
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
LevelGenerator = LevelRandomGenerator.new()
LevelManager = LevelManager.new(LevelGenerator)
SoundManager = SoundManager.new()
HighScoreManager = HighScoreManager.new()

-- The game state machine
StateMenu = StateMenu.new()
StateInstructions = StateInstructions.new()
StateHighscore = StateHighscore.new()
StateHighscoreEntry = StateHighscoreEntry.new()
StartStart = StateStart.new()
StateGame = StateGame.new()
StateDead = StateDead.new()
StateRespawn = StateRespawn.new()
StateGameOver = StateGameOver.new()

-- Load what few preferences we have
local prefs = pd.datastore.read()
if prefs then
    TitleMusic, _ = table.unpack(prefs)
end

Starfield = Starfield.new()

-- Set the starfield as the sprite background. See the play.date lua documentation.
-- This callback will have the clip rect set correctly so only what is required will redraw
gfx.sprite.setBackgroundDrawingCallback(
    function(x, y, w, h)
        Starfield.image:draw(0, 0)
    end
)

Dashboard = Dashboard.new()

-- Set the initial Game State
local currentState = StateMenu
-- local currentState = StateTest
currentState:start()

-- Add to the System Menu
function SetupMenu()
    local menu = pd.getSystemMenu()

    local menuItem1, error = menu:addCheckmarkMenuItem("title music", TitleMusic,
        function(value)
            TitleMusic = value
            SoundManager:titleMusic(TitleMusic)
        end)
    assert(menuItem1, error)

    if DEVELOPER_BUILD then
        local menuItem2, error = menu:addCheckmarkMenuItem("show fps", false,
            function(value)
                ShowFPS = value
            end)
        assert(menuItem2, error)
    end
end

SetupMenu()

local pauseImage = gfx.image.new(400, 240)
function pd.gameWillPause()
    gfx.pushContext(pauseImage)
    if ShowLevel then
        pauseImage:clear(gfx.kColorBlack)
        LevelGenerator.occupiedMap:draw(0, 0)
    else
        local destroyed = Player:getDestroyed()

        pauseImage:clear(gfx.kColorBlack)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        gfx.setFont(Assets.getFont('images/Xevious-table-8-8.png'))
        local smallTitle = Assets.getImage('images/smallTitle.png')
        local x = 10
        local y = 10
        smallTitle:draw(x, y)

        y = 73 + 8 + 16
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawText("BY: CRANEHED.ITCH.IO", x, y)
        y += 8 + 16

        gfx.drawText("LEVEL: ", x, y)
        x += 120
        gfx.drawText(LevelManager:getLevel(), x, y)

        x = 10
        y += 8 + 16
        gfx.drawText("DESTROYED", x, y)

        x = 10
        y += 16
        gfx.drawText("BASES:", x + 8, y)
        x += 120
        gfx.drawText(destroyed[EnemyBase], x, y)

        x = 10
        y += 16
        gfx.drawText("ENEMIES:", x + 8, y)
        x += 120
        gfx.drawText(destroyed[Enemy], x, y)

        x = 10
        y += 16
        gfx.drawText("ASTEROIDS:", x + 8, y)
        x += 120
        gfx.drawText(destroyed[Asteroid], x, y)

        x = 10
        y += 16
        gfx.drawText("EGGS:", x + 8, y)
        x += 120
        gfx.drawText(destroyed[Egg], x, y)

        x = 10
        y += 16
        gfx.drawText("MINES:", x + 8, y)
        x += 120
        gfx.drawText(destroyed[Mine], x, y)
    end
    gfx.popContext()
    pd.setMenuImage(pauseImage)
end

function pd.deviceDidUnlock()
    Dashboard:draw()
end

function pd.gameWillResume()
    Dashboard:draw()
end

function pd.gameWillTerminate()
    -- Save what few preferences we have
    pd.datastore.write({ TitleMusic, nil })

    pd.setMenuImage(nil)
end

local ms = pd.getCurrentTimeMilliseconds
function pd.update()
    local frameStart = ms()

    currentState = currentState:update()

    -- From: https://devforum.play.date/t/best-practices-for-managing-lots-of-assets/395
    Assets.lazyLoad(frameStart)
end

-- In-game states use this
function WorldUpdateInGame()
    gfx.setScreenClipRect(0, 0, VIEWPORT_WIDTH, VIEWPORT_HEIGHT)

    gfx.animation.blinker.updateAll()

    LevelManager.resetActiveCounts()
    Starfield:update()
    gfx.sprite.update()
    ExplosionsUpdate()
    LevelManager:update()
    Dashboard:update()
end

-- Non-game states use this
function WorldUpdateInTitles()
    gfx.setScreenClipRect(0, 0, VIEWPORT_WIDTH, VIEWPORT_HEIGHT)

    pd.timer.updateTimers()
    gfx.animation.blinker.updateAll()

    Starfield:update()
    gfx.sprite.update()
    ExplosionsUpdate()
    LevelManager:update()
    Dashboard:update()
end
