import 'CoreLibs/sprites'
import 'CoreLibs/timer'

local pd = playdate
local gfx = pd.graphics

StateDead = {}
StateDead.__index = StateDead

function StateDead.new()
    local self = setmetatable({}, StateDead)

    return self
end

function StateDead:start()
    print('StateDead start')

    self.timerComplete = false
    self.timer = pd.timer.new(3000, function() 
        self.timerComplete = true
        self.timer:remove() 
    end)
end

function StateDead:update()
    -- Player is dead, the world goes on without them. Press F for respects
    WorldUpdate()

    pd.timer.updateTimers()
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