local gfx = playdate.graphics

Enemy = {}
Enemy.__index = Enemy

function Enemy.new(x, y)
    local POINTS <const> = 5
    local SPEED <const> = 1.5
    -- Turn angle somewhat isn't req'd. If we're chasing the player, their turn speed controls the rate the angle changes.
    -- However if we want enemies to turn slower than the player, it IS req'd, otherwise it's too easy for them to overhaul the player.
    local TURN_ANGLE <const> = 3

    local img, err = gfx.image.new("images/enemy.png")
    assert(img, err)

    local self = gfx.sprite.new(img)
    self:moveTo(x, y)
    self:setRotation(0)
    self:setZIndex(15)
	self:setCollideRect(2, 2, 12, 11)
	self:setGroupMask(GROUP_ENEMY)
	self:setCollidesWithGroupsMask(GROUP_BULLET|GROUP_PLAYER)

    self:add()

    function self:turnTowards(x, y, targetX, targetY, currentAngle)
        local angle = math.deg(math.atan(targetY - y, targetX - x))
        angle += 90 -- TODO: Why is this +90 req'd? Something in the way math.atan works?

        -- TODO: Why is it so hard to limit the turn angle??!

        return angle
    end

    function self:update()
        -- Turn towards the player
        local playerX, playerY = getPlayer():getPosition()
        local x, y = self:getPosition()
        local targetAngle = self:turnTowards(x - playerX, y - playerY, 0, 0, self:getRotation()) -- Sprite vs world coords. Player is always 0,0
        self:setRotation(targetAngle) 

        local deltaX = -math.sin(math.rad(targetAngle)) * SPEED
        local deltaY = math.cos(math.rad(targetAngle)) * SPEED
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