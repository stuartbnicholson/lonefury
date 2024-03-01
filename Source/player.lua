import "CoreLibs/sprites"

local gfx = playdate.graphics
local ROTATE_SPEED = 10

Player = {}
Player.__index = Player

function Player:new()
    local img, err = gfx.image.new("images/player.png")
    assert(img, err)

    local self = gfx.sprite:new(img)
    self:moveTo(200,120)
    self:setZIndex(100)
    self:setCollideRect(1, 1, 14, 14)

    self:add()

    function self:thrust()
        local rot = self:getRotation()
        local deltaX = -math.sin(math.rad(rot))
        local deltaY = math.cos(math.rad(rot))
    
        return deltaX, deltaY
    end
    
    function self:fire()
        -- TODO
    end
    
    function self:left()
        self:setRotation(self:getRotation() - ROTATE_SPEED)
    end
    
    function self:right()
        self:setRotation(self:getRotation() + ROTATE_SPEED)
    end

    return self
end