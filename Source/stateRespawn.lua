-- State: Player is respawning for another round
import 'CoreLibs/animation'

local pd = playdate
local gfx = pd.graphics

StateRespawn = {}
StateRespawn.__index = StateRespawn

function StateRespawn.new()
    local self = setmetatable({}, StateRespawn)

    self.blinker = gfx.animation.blinker.new(600, 600, false, 4)
    self.blinker:stop()

    return self
end

function StateRespawn:start()
    print('StateRespawn start')
    -- TODO: Recenter world, make sure player isn't near anything dangerous

    Player:resetAngle()
    Player:add()
    Dashboard:drawLivesMedals()
    self.blinker:start()
end

function StateRespawn:update()
    WorldUpdate()

    gfx.animation.blinker.updateAll()
    if self.blinker.running then 
        if self.blinker.on then
            Player:setVisible(true)
        else
            Player:setVisible(false)
        end
    else
        StateGame:start()
        return StateGame
    end

    return self
end