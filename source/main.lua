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
import 'storylane'

local pd = playdate
local gfx = pd.graphics
local anim = gfx.animation
local timer = pd.timer

-- Asset management
Assets.preloadImages({
    'images/title.png',
    'images/smallTitle.png',
    'images/alert.png',
    'images/cross.png',
    -- Obstacles
    'images/asteroid.png',
    'images/egg.png',
    'images/mine.png',
    -- Bases
    'images/baseOccupied.png',
    'images/baseHorizontal.png',
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
    'images/enemy3-table-15-15.png',
    'images/enemyMonster-table-45-45.png',
    -- Bases
    'images/bigBullet-table-4-4.png',
    'images/baseZap-table-17-17.png',
    -- Dashboard
    'images/mapPlayer-table-7-6.png',
    'images/talkingHeads-table-32-32.png',
    'images/fade-table-32-32.png',
    -- Explosions
    'images/explosmall-table-15-15.png',
    'images/explomed-table-20-20.png',
    'images/explobase-table-72-72.png',
    -- Player
    'images/player-table-15-15.png',
    'images/playerBullet-table-6-6.png'
}
)
Assets.preloadFonts({
    'images/Xevious-2x-table-16-16.png',
    'images/Xevious-Score-table-8-16.png',
    'images/Xevious-table-8-8.png'
})

-- Managers
PoolManager = PoolManager.new()
LevelGenerator = LevelRandomGenerator.new()
LevelManager = LevelManager.new(LevelGenerator)
SoundManager = SoundManager.new()
HighScoreManager = HighScoreManager.new()
StoryManager = StoryLane.new()

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
local systemMenuOpen = false
function pd.gameWillPause()
    systemMenuOpen = true

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
    if not systemMenuOpen then
        Dashboard:draw()
        Dashboard:update()
    end
end

function pd.gameWillResume()
    Dashboard:draw()
    Dashboard:update()
    systemMenuOpen = false
end

function pd.gameWillTerminate()
    -- Save what few preferences we have
    pd.datastore.write({ TitleMusic, nil })

    pd.setMenuImage(nil)
end

local alwaysRedrawOn = false
local alwaysRedrawOnFrameCounter = 0
function pd.update()
    pd.resetElapsedTime()

    currentState = currentState:update()

    -- Adaptive sprite redraw management. This sprite 'dirtying' gets expensive with enough
    -- aliens and bullets on screen. If the frame rate dives we enable setAlwaysRedraw(true) which will
    -- result in computationally cheap full redraws at the cost of the battery. So we need to adaptively
    -- turn it off too.
    if alwaysRedrawOnFrameCounter > 0 then
        -- alwaysRedrawOn was changed recently, leave it on for several frames before we recheck
        alwaysRedrawOnFrameCounter -= 1
    else
        local elapsed = pd.getElapsedTime()
        if elapsed > 0.035 and not alwaysRedrawOn then
            alwaysRedrawOn = true
            alwaysRedrawOnFrameCounter = 15 -- Favour leaving it on if we hit a frame spike
            gfx.sprite.setAlwaysRedraw(alwaysRedrawOn)
        elseif elapsed < 0.028 and alwaysRedrawOn then
            alwaysRedrawOn = false
            alwaysRedrawOnFrameCounter = 3
            gfx.sprite.setAlwaysRedraw(alwaysRedrawOn)
        end
    end
end

-- In-game states use this, so watch what goes in here
function WorldUpdateInGame()
    gfx.setScreenClipRect(0, 0, VIEWPORT_WIDTH, VIEWPORT_HEIGHT)

    anim.blinker.updateAll()
    LevelManager.resetActiveCounts()

    gfx.sprite.update()
    Starfield:update()
    ExplosionsUpdate()
    LevelManager:update()
    Dashboard:update()
end

-- Non-game states use this, which includes the lazy asset loading out of the main game loop
function WorldUpdateInTitles()
    local frameStart = pd.getCurrentTimeMilliseconds()
    pd.resetElapsedTime()

    gfx.setScreenClipRect(0, 0, VIEWPORT_WIDTH, VIEWPORT_HEIGHT)

    timer.updateTimers()
    anim.blinker.updateAll()

    gfx.sprite.update()
    ExplosionsUpdate()
    LevelManager:update()
    Dashboard:update()

    -- From: https://devforum.play.date/t/best-practices-for-managing-lots-of-assets/395
    Assets.lazyLoad(frameStart)
end
