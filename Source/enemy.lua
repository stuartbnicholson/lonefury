local gfx = playdate.graphics

Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y)
    local POINTS <const> = 5
    local ROTATE_SPEED <const> = 15
    local SPEED <const> = 1.5

    local img, err = gfx.image.new(15, 15)
    assert(img, err)

    local self = gfx.sprite:new(img)
    local imgTable, err = gfx.imagetable.new("images/enemy-table-15-15.png")
    assert(imgTable, err)
    self.angle = 0
    self.imgTable = imgTable
    self:setImage(self.imgTable:getImage(1))
    self:moveTo(x, y)
    self:setZIndex(15)
	self:setCollideRect(2, 2, 12, 11)
	self:setGroupMask(GROUP_ENEMY)
	self:setCollidesWithGroupsMask(GROUP_BULLET|GROUP_PLAYER)

    self:add()

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

    function self:roundToNearestMultiple(number, multiple)
        local sign = number >= 0 and 1 or -1
        number = math.abs(number)
        local remainder = number % multiple
        if remainder >= multiple / 2 then
            number = number + multiple - remainder
        else
            number = number - remainder
        end
        return sign * number
    end

    function self:turnTowards(x, y, targetX, targetY, currentAngle)
        local angle = math.deg(math.atan(targetY - y, targetX - x))
        angle += 90 -- TODO: Why is this +90 req'd? Something in the way math.atan works?

        if angle < 0 then
            angle += 360
        end
        
        -- Turn angle has to be divisble by ROTATE_SPEED so we have the appropriate image
        angle = self:roundToNearestMultiple(math.floor(angle), ROTATE_SPEED)

        -- TODO: Actually it doesn't matter really, turnRate only explodes if enemy is on top of player
        -- local turnRate = math.abs(currentAngle - angle) / ROTATE_SPEED

        return angle
    end

    function self:update()
        -- Turn towards the player
        local playerX, playerY = getPlayer():getPosition()
        local x, y = self:getPosition()
        
        self.angle = self:turnTowards(x - playerX, y - playerY, 0, 0, self.angle) -- Sprite vs world coords. Player is always 0,0
        self:setTableImage()

        local deltaX = -math.sin(math.rad(self.angle)) * SPEED
        local deltaY = math.cos(math.rad(self.angle)) * SPEED
        self:moveTo(x - deltaX, y - deltaY)
    end
   
    function self:updateWorldPos(deltaX, deltaY)
        local x, y = self:getPosition()
        self:moveTo(x + deltaX, y + deltaY)
    end

    function self:bulletHit()
        -- TODO: Some animation here
        self:setVisible(false)
        self:remove()

        PlayerScore += POINTS
    end

    return self
end