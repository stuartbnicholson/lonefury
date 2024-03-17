import "CoreLibs/sprites"
import "bullet"

local gfx = playdate.graphics

Player = {}
Player.__index = Player

function Player:new()
    local SPEED <const> = 5.0

    local img, err = gfx.image.new(15, 15)
    assert(img, err)

    local self = gfx.sprite:new(img)
    local imgTable, err = gfx.imagetable.new("images/player-table-15-15.png") 
    assert(imgTable, err)
    self.imgTable = imgTable
    self:setImage(self.imgTable:getImage(1))
    self:setTag(SPRITE_TAGS.player)
    self.angle = 0
    self:moveTo(200,120)
    self:setZIndex(100)
    self:setCollideRect(2, 2, 11, 11)
    self:setGroupMask(GROUP_PLAYER)
    self:setCollidesWithGroupsMask(GROUP_ENEMY)
    self:add()

    self.isAlive = true
    self.score = 0
    -- TODO: self.lives = 3

    self.bullets = {}
    self.bullets[1] = Bullet.new()
    self.bullets[2] = Bullet.new()

    function self:update()
        if self.isAlive then
            local _,_,c,n = self:checkCollisions(self:getPosition())            
            if n > 0 then
                for i = 1, #c do
                    if self:alphaCollision(c[i].other) then
                        -- The first real collision is sufficient to kill the player
                        self:collide()
                        break
                    end
                end
            end
        end
    end

    function self:scored(points)
        self.score += points
        
        -- TODO: Extra lives? Other bonuses? Difficulty increase?
    end

    function self:collide(other)
        self:setVisible(false)
        self.isAlive = false

        Explode(ExplosionSmall, self:getPosition())
    end

    function self:thrust()
        local deltaX = 0
        local deltaY = 0

        if self.isAlive then
            deltaX = -math.sin(math.rad(self.angle))
            deltaY = math.cos(math.rad(self.angle))
        end

        return deltaX, deltaY
    end
    
    function self:fire()
        if self.isAlive and self.bullets[1]:isVisible() == false and self.bullets[2]:isVisible() == false then
            local x, y = self:getPosition()
            local deltaX = -math.sin(math.rad(self.angle)) * SPEED
            local deltaY = math.cos(math.rad(self.angle)) * SPEED
            self.bullets[1]:fire(x, y, deltaX, deltaY)
            self.bullets[2]:fire(x, y, -deltaX, -deltaY)
        end
    end
    
    function self:left()
        if self.isAlive then
            if self.angle == 0 then
                self.angle = 360 - ROTATE_SPEED
            else
                self.angle -= ROTATE_SPEED
            end

            SetTableImage(self.angle, self, self.imgTable)
        end
    end
    
    function self:right()
        if self.isAlive then
            if self.angle == 360 - ROTATE_SPEED then
                self.angle = 0
            else
                self.angle += ROTATE_SPEED
            end

            SetTableImage(self.angle, self, self.imgTable)
        end
    end

    return self
end