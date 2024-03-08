import 'Corelibs/animation'

local gfx = playdate.graphics

Explosion = {}
Explosion.__index = Explosion

function Explosion.new()
    local imgTable, err = gfx.imagetable.new("images/explosion-table-15-15.png")
    assert(imgTable, err)

    local self = gfx.animation.loop.new(120, imgTable, false)
    self.x = -100   -- Start offscreen
    self.y = -100

    function self:update()
        if self:isValid() then
            self:draw(self.x - 7, self.y - 7)
        end
    end

    function self:explode(x, y)
        self.x = x
        self.y = y
        self.frame = 1
    end

    return self
end