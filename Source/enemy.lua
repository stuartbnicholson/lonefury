import "utility"

local gfx = playdate.graphics

Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y)
    local POINTS <const> = 5
    local SPEED <const> = 1.5

    local img, err = gfx.image.new(15, 15)
    assert(img, err)

    local self = gfx.sprite:new(img)
    local imgTable, err = gfx.imagetable.new("images/enemy-table-15-15.png")
    assert(imgTable, err)
    self.angle = 0
    self.imgTable = imgTable
    self:setImage(self.imgTable:getImage(1))
    self:setTag(SPRITE_TAGS.enemy)
    self:moveTo(x, y)
    self:setZIndex(15)
	self:setCollideRect(2, 2, 11, 10)
	self:setGroupMask(GROUP_ENEMY)
	self:setCollidesWithGroupsMask(GROUP_BULLET|GROUP_PLAYER)
    self:add()

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

    function self:doLOSChase()
        --[[
            Vector u, v;
            bool left = false;
            bool right = false;
            u = VRotate2D(-Predator.fOrientation,
            (Prey.vPosition - Predator.vPosition));
            u.Normalize();
            if (u.x < -_TOL)
            left = true;
            else if (u.x > _TOL)
            right = true;
            Predator.SetThrusters(left, right);
        ]]
    end

    function self:turnTowards(x, y, targetX, targetY, currentAngle)
        local angle = PointsAngle(x, y, targetX, targetY)

        -- Turn angle has to be divisble by ROTATE_SPEED so we have the appropriate image
        angle = self:roundToNearestMultiple(math.floor(angle), ROTATE_SPEED)

        -- TODO: Actually it doesn't matter really, turnRate only explodes if enemy is on top of player
        -- local turnRate = math.abs(currentAngle - angle) / ROTATE_SPEED

        return angle
    end

    function self:update()
        local playerX, playerY = GetPlayer():getPosition()
        local x, y = self:getPosition()
        
        self.angle = self:turnTowards(x - playerX, y - playerY, 0, 0, self.angle) -- Sprite vs world coords. Player is always 0,0
        SetTableImage(self.angle, self, self.imgTable)
    end
   
    function self:updateWorldPos(deltaX, deltaY)
        local x, y = self:getPosition()

        -- Combine world and enemy move
        local dX = -math.sin(math.rad(self.angle)) * SPEED
        local dY = math.cos(math.rad(self.angle)) * SPEED
        self:moveTo(x + deltaX - dX, y + deltaY - dY)
    end

    function self:bulletHit(x, y)
        Explode(self:getPosition())
        self:setVisible(false)
        self:remove()

        PlayerScore += POINTS
    end

    return self
end