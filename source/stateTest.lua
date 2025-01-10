import 'CoreLibs/graphics'

import 'levelRandomGenerator'
import 'levelManager'

-- State: State used for dev scratchpad. Ignore any code included.
local pd = playdate
local gfx = pd.graphics

StateTest = {}
StateTest.__index = StateTest

function StateTest.new()
    local self = setmetatable({}, StateTest)

    return self
end

function StateTest:start()
    print('StateTest start')

    self.levelManager = LevelManager.new()
    self.levelGenerator = LevelRandomGenerator.new()

    self.levelGenerator:generate(self.levelManager)
end

function StateTest:update()
    pd.timer.updateTimers()

    gfx.clear(gfx.kColorBlack)
    self.levelGenerator.occupiedMap:draw(2, 2)

    return self
end
