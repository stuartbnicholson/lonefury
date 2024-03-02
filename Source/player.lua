import "CoreLibs/sprites"
import "bullet"

local gfx = playdate.graphics
local ROTATE_SPEED = 10

Player = {}
Player.__index = Player

function Player:new()
    local SPEED <const> = 5.0

    local img, err = gfx.image.new("images/player.png")
    assert(img, err)

    local self = gfx.sprite:new(img)
    self:moveTo(200,120)
    self:setZIndex(100)
    self:setCollideRect(1, 1, 14, 14)
    self:setGroupMask(GROUP_PLAYER)
    self:setCollidesWithGroupsMask(GROUP_ENEMY)
    self:add()

    self.bullets = {}
    self.bullets[1] = Bullet.new()
    self.bullets[2] = Bullet.new()

    function self:thrust()
        local angle = self:getRotation()
        local deltaX = -math.sin(math.rad(angle))
        local deltaY = math.cos(math.rad(angle))
    
        return deltaX, deltaY
    end
    
    function self:fire()
        if self.bullets[1]:isVisible() == false and self.bullets[2]:isVisible() == false then
            local x, y = self:getPosition()
            local angle = self:getRotation()
            local deltaX = -math.sin(math.rad(angle)) * SPEED
            local deltaY = math.cos(math.rad(angle)) * SPEED 
            self.bullets[1]:fire(x, y, deltaX, deltaY, angle)
            self.bullets[2]:fire(x, y, -deltaX, -deltaY, -angle)
        end
    end
    
    function self:left()
        self:setRotation(self:getRotation() - ROTATE_SPEED)
    end
    
    function self:right()
        self:setRotation(self:getRotation() + ROTATE_SPEED)
    end

    return self
end