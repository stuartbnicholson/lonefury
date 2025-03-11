-- State: Game instructions before game starts.

local pd = playdate
local gfx = pd.graphics

local font = Assets.getFont('images/Xevious-2x-table-8-8.png')
local baseImg = Assets.getImage('images/baseHorizontal.png')
local enemy1Img = Assets.getImagetable('images/enemy-table-15-15.png'):getImage(1)
local enemy2Img = Assets.getImagetable('images/enemy2-table-15-15.png'):getImage(1)
local mineImg = Assets.getImage('images/mine.png')
local asteroidImg = Assets.getImage('images/asteroid.png')
local playerImg = Assets.getImage('images/playerLife.png')

local TIMEOUT_MS = 1200 * 5

StateInstructions = {}
StateInstructions.__index = StateInstructions

function StateInstructions.new()
    local self = setmetatable({}, StateInstructions)

    return self
end

function StateInstructions:start()
    self.started = pd.getCurrentTimeMilliseconds()
end

function StateInstructions:update()
    Starfield:update()
    Dashboard:update()

    -- Display instructions and scores
    baseImg:draw(48, 25)
    enemy1Img:draw(68, 108)
    enemy2Img:draw(68 + 20, 106)
    mineImg:draw(78, 132)
    asteroidImg:draw(78, 152)
    playerImg:draw(78, 188)

    gfx.setFont(font)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText('DESTROY\nBASES!', 128, 22)
    gfx.drawText(SCORE_ENEMYBASE_SPHERE .. '**SPHERE\n' .. SCORE_ENEMYBASE_ONESHOT .. '**BASE', 128, 26 + 36)
    gfx.drawText(SCORE_ENEMY .. ' PTS', 128, 108)
    gfx.drawText(SCORE_MINE .. ' PTS', 128, 132)
    gfx.drawText(SCORE_ASTEROID .. ' PTS', 128 + 13, 154)
    gfx.drawText('LIFE**' .. SCORE_EXTRALIFE, 128, 188)
    gfx.setImageDrawMode(gfx.kDrawModeCopy)

    if pd.buttonIsPressed(pd.kButtonA|pd.kButtonB|pd.kButtonUp|pd.kButtonDown|pd.kButtonLeft|pd.kButtonRight) then
        StateStart:start()
        return StateStart
    elseif pd.getCurrentTimeMilliseconds() - self.started > TIMEOUT_MS then
        StateHighscore:start(true)
        return StateHighscore
    else
        return self
    end
end
