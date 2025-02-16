import 'CoreLibs/sprites'
import 'CoreLibs/timer'

local pd = playdate
local gfx = pd.graphics

StateDead = {}
StateDead.__index = StateDead

function StateDead.new()
    local self = setmetatable({}, StateDead)

    self.timer = pd.timer.new(3000,
        function()
            self.timerComplete = true
        end
    )
    self.timer.discardOnCompletion = false
    self.timer:pause()

    return self
end

function StateDead:start()
    self.timerComplete = false
    self.timer:reset()
    self.timer:start()
end

function StateDead:update()
    -- Player is dead, the world goes on without them. Press F for respects
    WorldUpdateInTitles()

    if self.timerComplete then
        if Player.lives > 1 then
            Player.lives -= 1
            StateRespawn:start()
            return StateRespawn
        else
            StateGameOver:start()
            return StateGameOver
        end
    else
        return self
    end
end
