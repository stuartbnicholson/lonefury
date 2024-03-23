-- State: Player is respawning for another round
import 'CoreLibs/animation'

local pd = playdate
local gfx = pd.graphics

StateRespawn = {}
StateRespawn.__index = StateRespawn

local playerLifeImg, err = gfx.image.new('images/playerLife.png')
assert(playerLifeImg, err)

function StateRespawn.new()
    local self = setmetatable({}, StateRespawn)

    self.blinker = gfx.animation.blinker.new(800, 400, false, 3)
    self.blinker:stop()

    return self
end

function StateRespawn:start()
    print('StateRespawn start')
    -- TODO: Recenter world, make sure player isn't near anything dangerous

    Dashboard:drawLivesMedals()
    self.blinker:start()
end

function StateRespawn:update()
    WorldUpdate()

    gfx.animation.blinker.updateAll()
    if self.blinker.running then 
        if self.blinker.on then
            playerLifeImg:draw(1 + (WORLD_WIDTH >> 1) - (PLAYER_WIDTH >> 1), 1 + (WORLD_HEIGHT >> 1) - (PLAYER_HEIGHT >> 2))
        end
    else
        StateGame:start()
        return StateGame
    end

    return self
end