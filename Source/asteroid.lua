import "CoreLibs/sprites"

local gfx = playdate.graphics

Asteroid = {}
Asteroid.__index = Asteroid

function Asteroid.new(x, y)
    local img, err = gfx.image.new("images/asteroid.png")
    assert(img, err)

    local self = gfx.sprite.new(img)
    self:moveTo(x, y)
    self:setZIndex(10)
    self:setCollideRect(2, 2, 12, 12)

    self:add()

    function self:updateWorldPos(deltaX, deltaY)
        local x, y = self:getPosition()
        self:moveTo(x + deltaX, y + deltaY)
    end

    return self
end