-- The one and only Player sprite, which is a special case because it's controlled by player input
-- and it's being 'alive' or not is separated from sprite functionality so it can be animated re-spawning etc.
import "CoreLibs/sprites"
import 'assets'
import "playerBullet"

local gfx = playdate.graphics

Player = {}
Player.__index = Player

PLAYER_WIDTH = 15
PLAYER_HEIGHT = 15

local imgTable = Assets.getImagetable('images/player-table-15-15.png')

function Player:new()
    local SPEED <const> = 5.0

    local img, err = gfx.image.new(PLAYER_WIDTH, PLAYER_HEIGHT)
    assert(img, err)

    local self = gfx.sprite:new(img)
    self.imgTable = imgTable
    self:setTag(SPRITE_TAGS.player)
    -- While the player's worldX, worldY change, the player sprite never deviates from the centre of the Viewport.
    -- The Viewport also chases the player's worldX, worldY too.
    self:moveTo(HALF_VIEWPORT_WIDTH, HALF_VIEWPORT_HEIGHT)
    self:setZIndex(100)
    self:setCollideRect(2, 2, 11, 11)
    self:setGroupMask(GROUP_PLAYER)
    self:setCollidesWithGroupsMask(GROUP_ENEMY|GROUP_OBSTACLE)

    self.worldX = WORLD_PLAYER_STARTX
    self.worldY = WORLD_PLAYER_STARTY
    self.deltaX = 0
    self.deltaY = 0

    self.bullets = {}
    self.bullets[1] = PlayerBullet.new()
    self.bullets[2] = PlayerBullet.new()

    function self:reset()
        self:resetAngle()
        self.lives = 3
        self.score = 0
    end

    function self:getWorldPosition()
        return self.worldX, self.worldY
    end

    function self:getWorldDelta()
        return self.deltaX, self.deltaY
    end

    function self:resetAngle()
        self.angle = 0
        self:setImage(self.imgTable:getImage(1))
    end

    function self:spawn()
        assert(self.lives > 0)
        self.angle = 0
        SetTableImage(self.angle, self, self.imgTable)
        self.isAlive = true
        self:setVisible(true)

        self.worldX = WORLD_PLAYER_STARTX
        self.worldY = WORLD_PLAYER_STARTY

        -- TODO: add() is called multiple times. See StateRespawn. Is this an issue?
        self:add()
    end

    -- Only called if sprite is in sprite list
    function self:update()
        self.worldX -= self.deltaX * 2.0
        self.worldY -= self.deltaY * 2.0

        -- Decel rather than chop, zero once we're close enough
        if self.deltaX < 0.001 then
            self.deltaX = 0
        else
            self.deltaX *= 0.65
        end
        if self.deltaY < 0.001 then
            self.deltaY = 0
        else
            self.deltaY *= 0.65
        end

        if self.isAlive then
            local _,_,c,n = self:checkCollisions(self.x, self.y)
            if n > 0 then
                for i = 1, #c do
                    if self:alphaCollision(c[i].other) then
                        -- The first real collision is sufficient to kill the player
                        self:collide(c[i].other)
                        break
                    end
                end
            end
        end
    end

    function self:scored(points)
        self.score += points

        -- TODO: Extra lives? Other bonuses? Difficulty increase?

        Dashboard:drawPlayerScore()
    end

    function self:collide(other)
        self:remove()
        self.isAlive = false
        self.deltaX = 0
        self.deltaY = 0

        Explode(ExplosionSmall, self:getPosition())
    end

    function self:thrust()
        self.deltaX, self.deltaY = AngleToDeltaXY(self.angle)
    end

    function self:bulletHit(other, x, y)
        self:collide(other)
    end

    function self:fire()
        if self.bullets[1]:isVisible() == false and self.bullets[2]:isVisible() == false then
            SoundManager:playerShoots()
            local x, y = self:getPosition()
            local deltaX = -math.sin(math.rad(self.angle)) * SPEED
            local deltaY = math.cos(math.rad(self.angle)) * SPEED
            self.bullets[1]:fire(x, y, deltaX, deltaY)
            self.bullets[2]:fire(x, y, -deltaX, -deltaY)
        end
    end

    function self:left()
        if self.angle == 0 then
            self.angle = 360 - ROTATE_SPEED
        else
            self.angle -= ROTATE_SPEED
        end

        SetTableImage(self.angle, self, self.imgTable)
    end

    function self:right()
        if self.angle == 360 - ROTATE_SPEED then
            self.angle = 0
        else
            self.angle += ROTATE_SPEED
        end

        SetTableImage(self.angle, self, self.imgTable)
    end

    self:reset()
    return self
end