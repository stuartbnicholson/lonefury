-- State: Player is dead and has no lives left, but enemies and bullets are still in flight.
import 'CoreLibs/timer'

local pd = playdate
local gfx = pd.graphics

local font = Assets.getFont('images/Xevious-2x-table-16-16.png')
local smallFont = Assets.getFont('images/Xevious-table-8-8.png')

StateGameOver = {}
StateGameOver.__index = StateGameOver

function StateGameOver.new()
    local self = setmetatable({}, StateGameOver)

    self.timer = pd.timer.new(3000,
        function()
            self.timerComplete = true
        end
    )
    self.timer.discardOnCompletion = false
    self.timer:pause()

    return self
end

function StateGameOver:start()
    if DEVELOPER_BUILD then MemoryCheck() end

    self.timerComplete = false
    self.timer:reset()
    self.timer:start()
end

function StateGameOver:update()
    -- Player is STILl dead, the world STILL goes on without them.
    WorldUpdateInTitles()

    gfx.pushContext()
    gfx.setFont(font)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.fillRect((VIEWPORT_WIDTH >> 1) - 73, (VIEWPORT_HEIGHT >> 1) - 27, 67, 16)
    gfx.fillRect((VIEWPORT_WIDTH >> 1) - 73 + 87, (VIEWPORT_HEIGHT >> 1) - 27, 67, 16)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText('GAME OVER', (VIEWPORT_WIDTH >> 1) - 72, (VIEWPORT_HEIGHT >> 1) - 26)

    local shots = (Player.shotsFired > 999 and 999) or Player.shotsFired
    local text = 'SHOTS:' .. shots
    gfx.setFont(smallFont)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.fillRect((VIEWPORT_WIDTH >> 1) - 72, (VIEWPORT_HEIGHT >> 1) + 1, gfx.getTextSize(text) + 2, 9)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText(text, (VIEWPORT_WIDTH >> 1) - 71, (VIEWPORT_HEIGHT >> 1) + 2)

    local hits = (Player.shotsHit > 999 and 999) or Player.shotsHit
    text = 'HITS:' .. hits
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.fillRect((VIEWPORT_WIDTH >> 1) + 13, (VIEWPORT_HEIGHT >> 1) + 1, gfx.getTextSize(text) + 2, 9)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText(text, (VIEWPORT_WIDTH >> 1) + 14, (VIEWPORT_HEIGHT >> 1) + 2)

    local percent = "0.00"
    if shots > 0 then
        percent = string.format("%.2f", (hits / shots) * 100.0)
    end
    text = 'PERCENT:' .. percent
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.fillRect((VIEWPORT_WIDTH >> 1) - 72, (VIEWPORT_HEIGHT >> 1) + 21, gfx.getTextSize(text) + 2, 9)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText(text, (VIEWPORT_WIDTH >> 1) - 71, (VIEWPORT_HEIGHT >> 1) + 22)
    gfx.popContext()

    if self.timerComplete then
        if HighScoreManager:isHighScore(Player.score) then
            StateHighscoreEntry:start()
            return StateHighscoreEntry
        else
            StateHighscore:start(true)
            return StateHighscore
        end
    else
        return self
    end
end
