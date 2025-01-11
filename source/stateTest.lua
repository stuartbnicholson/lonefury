import 'CoreLibs/graphics'

import 'levelRandomGenerator'
import 'levelManager'

-- State: State used for dev scratchpad. Ignore any code included.
local pd = playdate
local gfx = pd.graphics

local font = Assets.getFont('images/Xevious-table-8-8.png')

StateTest = {}
StateTest.__index = StateTest

function StateTest.new()
    local self = setmetatable({}, StateTest)

    return self
end

-- Mock Level Manager for testing LevelRandomGenerator
LevelManagerMock = {}
LevelManagerMock.__index = LevelManagerMock

function LevelManagerMock.new()
    local self = setmetatable({}, LevelManagerMock)

    self.level = 1
    PoolManager:reset()

    return self
end

function LevelManagerMock:getLevel()
    return self.level
end

function LevelManagerMock:setLevel(level)
    if self.level > 0 then
        self.level = level
    end
end

function LevelManagerMock:addToLevel(x, y, objClass, objInst)
end

function StateTest:start()
    print('StateTest start')

    self.levelManager = LevelManagerMock.new()
    self.levelGenerator = LevelRandomGenerator.new()

    self.levelGenerator:generate(self.levelManager)
end

function StateTest:update()
    pd.timer.updateTimers()

    gfx.pushContext()
    gfx.clear(gfx.kColorBlack)
    self.levelGenerator.occupiedMap:draw(2, 2)

    gfx.setColor(gfx.kColorWhite)
    gfx.drawRect(1, 1, 181, 181)

    gfx.setFont(font)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText("LEVEL: " .. self.levelManager:getLevel(), 2, 190)
    gfx.popContext()
    if pd.buttonJustPressed(pd.kButtonUp) then
        self.levelManager:setLevel(self.levelManager:getLevel() + 1)
        self.levelGenerator:generate(self.levelManager)
    elseif pd.buttonJustPressed(pd.kButtonDown) then
        self.levelManager:setLevel(self.levelManager:getLevel() - 1)
        self.levelGenerator:generate(self.levelManager)
    elseif pd.buttonJustPressed(pd.kButtonA) then
        self.levelGenerator:generate(self.levelManager)
    end

    return self
end
