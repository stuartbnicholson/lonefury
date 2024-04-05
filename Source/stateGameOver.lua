-- State: Player is dead and has no lives left, but enemies and bullets are still in flight.
import 'CoreLibs/timer'

local pd = playdate
local gfx = pd.graphics

local font = Assets.getFont('images/Xevious-2x-table-16-16.png')

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

    pd.timer.updateTimers()

    gfx.pushContext()
    gfx.setFont(font)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    gfx.drawText('GAME OVER', (VIEWPORT_WIDTH >> 1) - 71, (VIEWPORT_HEIGHT >> 1) - 7)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText('GAME OVER', (VIEWPORT_WIDTH >> 1) - 72, (VIEWPORT_HEIGHT >> 1) - 8)
    gfx.popContext()

    if self.timerComplete then
        return StateMenu
    else
        return self
    end
end