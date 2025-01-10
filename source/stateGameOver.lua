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
    print('StateGameOver start')
    MemoryCheck()

    self.timerComplete = false
    self.timer:reset()
    self.timer:start()
end

function StateGameOver:update()
    -- Player is STILl dead, the world STILL goes on without them.
    WorldUpdate()

    gfx.pushContext()
    gfx.setFont(font)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.drawText('GAME OVER', (VIEWPORT_WIDTH >> 1) - 71, (VIEWPORT_HEIGHT >> 1) - 7)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText('GAME OVER', (VIEWPORT_WIDTH >> 1) - 72, (VIEWPORT_HEIGHT >> 1) - 8)

    local shots = (Player.shotsFired > 999 and 999) or Player.shotsFired
    gfx.setFont(smallFont)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.drawText('SHOTS:' .. shots, (VIEWPORT_WIDTH >> 1) - 70, (VIEWPORT_HEIGHT >> 1) + 18)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText('SHOTS:' .. shots, (VIEWPORT_WIDTH >> 1) - 71, (VIEWPORT_HEIGHT >> 1) + 20)

    local hits = (Player.shotsHit > 999 and 999) or Player.shotsHit
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.drawText('HITS:' .. hits, (VIEWPORT_WIDTH >> 1) + 13, (VIEWPORT_HEIGHT >> 1) + 18)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText('HITS:' .. hits, (VIEWPORT_WIDTH >> 1) + 14, (VIEWPORT_HEIGHT >> 1) + 20)

    local percent = "0.00"
    if shots > 0 then
        percent = string.format("%.2f", (hits / shots) * 100.0)
    end
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.drawText('PERCENT:' .. percent, (VIEWPORT_WIDTH >> 1) - 70, (VIEWPORT_HEIGHT >> 1) + 36)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText('PERCENT:' .. percent, (VIEWPORT_WIDTH >> 1) - 71, (VIEWPORT_HEIGHT >> 1) + 40)
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
