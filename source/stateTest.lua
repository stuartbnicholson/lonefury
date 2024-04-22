import 'enemyBase'

-- State: Special test state used for dev
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

    self.newBase = EnemyBase.new(false)
    self.newBase:spawn(0, 0, 1, 1500)
    self.newBase:setVisible(true)
end

function StateTest:update()
    pd.timer.updateTimers()

    gfx.clear(gfx.kColorBlack)
    gfx.sprite.update()

    return self
end