-- State: Player is dead and has no lives left, but enemies and bullets are still in flight.
import 'CoreLibs/timer'

local pd = playdate
local gfx = pd.graphics

local gameOverImg, err = gfx.image.new('images/gameOver.png')
assert(gameOverImg, err)

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

    gameOverImg:draw((VIEWPORT_WIDTH >> 1) - 59, (HALF_VIEWPORT_HEIGHT) - 10) --118 x 20

    if self.timerComplete then
        return StateMenu
    else
        return self
    end
end