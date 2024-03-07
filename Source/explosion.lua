local gfx = playdate.graphics

Explosion = {}
Explosion.__index = Explosion

function Explosion.new()
    local imgTable, err = gfx.imagetable.new("images/explosion-table-15-15.png")
    assert(imgTable, err)

    -- TODO: Perhaps a frame timer instead of an animation loop...since we don't want to loop?
    local self = gfx.animation.loop.new(100, imgTable, false)
    self.x = 0
    self.y = 0

    function self:update()
        self:draw(self.x, self.y)
    end

    function self:explode(x, y)
        self.x = x
        self.y = y
    end

    return self
end