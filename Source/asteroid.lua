import "CoreLibs/sprites"

local gfx = playdate.graphics

Asteroid = {}
Asteroid.__index = Asteroid

local asteroidImg, err = gfx.image.new("images/asteroid.png")
assert(asteroidImg, err)

function Asteroid.new(x, y)
    local POINTS <const> = 5

    local self = gfx.sprite.new(asteroidImg)
    self:moveTo(x, y)
    self:setZIndex(10)
    self:setCollideRect(2, 2, 12, 12)
    self:setGroupMask(GROUP_ENEMY)
    self:setCollidesWithGroupsMask(GROUP_PLAYER|GROUP_BULLET)

    self:add()

    function self:updateWorldPos(deltaX, deltaY)
        local x, y = self:getPosition()
        self:moveTo(x + deltaX, y + deltaY)
    end

    function self:bulletHit(x, y)
        Explode(ExplosionSmall, self:getPosition())
        self:setVisible(false)
        self:remove()

        GetPlayer():scored(POINTS)
    end

    return self
end