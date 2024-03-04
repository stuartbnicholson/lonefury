import "CoreLibs/sprites"
import "bullet"

local gfx = playdate.graphics

Player = {}
Player.__index = Player

function Player:new()
    local ROTATE_SPEED <const> = 15
    local SPEED <const> = 5.0

    local img, err = gfx.image.new(15, 15)
    assert(img, err)

    local self = gfx.sprite:new(img)
    local imgTable, err = gfx.imagetable.new("images/player-table-15-15.png") 
    assert(imgTable, err)
    self.imgTable = imgTable
    self:setImage(self.imgTable:getImage(1))
    self.angle = 0
    self:moveTo(200,120)
    self:setZIndex(100)
    self:setCollideRect(1, 1, 14, 14)
    self:setGroupMask(GROUP_PLAYER)
    self:setCollidesWithGroupsMask(GROUP_ENEMY)
    self:add()

    self.bullets = {}
    self.bullets[1] = Bullet.new()
    self.bullets[2] = Bullet.new()

    function self:update()
        local _,_,c,n = self:checkCollisions(self:getPosition())
        
        if n > 0 then
            -- TODO: Player collides with anything they die
        end
    end

    function self:thrust()
        local deltaX = -math.sin(math.rad(self.angle))
        local deltaY = math.cos(math.rad(self.angle))

        return deltaX, deltaY
    end
    
    function self:fire()
        if self.bullets[1]:isVisible() == false and self.bullets[2]:isVisible() == false then
            local x, y = self:getPosition()
            local deltaX = -math.sin(math.rad(self.angle)) * SPEED
            local deltaY = math.cos(math.rad(self.angle)) * SPEED 
            self.bullets[1]:fire(x, y, deltaX, deltaY)
            self.bullets[2]:fire(x, y, -deltaX, -deltaY)
        end
    end
    
    function self:setTableImage()
        -- Flip image table images to save image table space
        if self.angle <= 90 then
            local i = 1 + (self.angle / ROTATE_SPEED)
            self:setImage(self.imgTable:getImage(i))
        elseif self.angle <= 180 then
            local i = 8 - ((self.angle - 90) / ROTATE_SPEED)
            self:setImage(self.imgTable:getImage(i), gfx.kImageFlippedY)
        elseif self.angle <= 270 then
            local i = 1 + (self.angle - 180) / ROTATE_SPEED
            self:setImage(self.imgTable:getImage(i), gfx.kImageFlippedXY)
        else
            local i = 8 - (self.angle - 270) / ROTATE_SPEED
            self:setImage(self.imgTable:getImage(i), gfx.kImageFlippedX)
        end
    end

    function self:left()
        if self.angle == 0 then
            self.angle = 360 - ROTATE_SPEED
        else
            self.angle -= ROTATE_SPEED
        end

        self:setTableImage()
    end
    
    function self:right()
        if self.angle == 360 - ROTATE_SPEED then
            self.angle = 0
        else
            self.angle += ROTATE_SPEED
        end

        self:setTableImage()
    end

    return self
end