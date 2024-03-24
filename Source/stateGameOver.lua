-- State: Player is dead and has no lives left, but enemies and bullets are still in flight.
import 'CoreLibs/timer'

local pd = playdate
local gfx = pd.graphics

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

    self.timerComplete = false
    self.timer:reset()
    self.timer:start()
end

function StateGameOver:update()
    -- Player is STILl dead, the world STILL goes on without them.
    WorldUpdate()

    pd.timer.updateTimers()

    gfx.pushContext()
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.setFont(Font)
    gfx.drawText('GAME OVER', (VIEWPORT_WIDTH >> 1) - 59, (VIEWPORT_HEIGHT >> 1) - 10) --118 x 20
    gfx.popContext()

    if self.timerComplete then
        return StateMenu
    else
        return self
    end
end