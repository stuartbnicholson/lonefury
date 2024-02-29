import "CoreLibs/sprites"
import "imageLoader"

local gfx = playdate.graphics

Asteroid = {}
Asteroid.__index = Asteroid

function Asteroid.new(x, y)
    local self = setmetatable({}, Asteroid)

    local img = loadImage("images/asteroid.png")
    self.sprite = gfx.sprite.new(img)
    self.sprite:moveTo(x, y)
    self.sprite:setZIndex(10)
    self.sprite:add()

    return self
end

function Asteroid:update(deltaX, deltaY)
    local x, y = self.sprite:getPosition()
    self.sprite:moveTo(x + deltaX, y + deltaY)
end