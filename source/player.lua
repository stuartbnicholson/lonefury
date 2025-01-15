-- The one and only Player sprite, which is a special case because it's controlled by player input
-- and it's being 'alive' or not is separated from sprite functionality so it can be animated re-spawning etc.
import 'CoreLibs/sprites'

import 'assets'

local pd = playdate
local gfx = pd.graphics
local geom = pd.geometry

PLAYER_WIDTH = 15
PLAYER_HEIGHT = 15
local SPEED <const> = 3.5
local FWD_BULLET_SPEED <const> = 10.0
local REAR_BULLET_SPEED <const> = FWD_BULLET_SPEED - SPEED
local FIRE_MS = 330

local imgTable = Assets.getImagetable('images/player-table-15-15.png')

local SHOW_EXHAUST <const> = false
local exhaustTable = Assets.getImagetable('images/exhaust-table-16-16.png')

local frameCount = 0

Player = {}
Player.__index = Player

function Player:new()
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
    self:setCollidesWithGroupsMask(GROUP_ENEMY|GROUP_ENEMY_BASE|GROUP_OBSTACLE)

    self.worldV = geom.vector2D.new(WORLD_PLAYER_STARTX, WORLD_PLAYER_STARTY)
    self.deltaX = 0
    self.deltaY = 0
    self.lastFiredMs = 0

    function self:reset()
        self:resetAngle()
        self.lives = 3
        self.bonusLives = 0
        self.score = 0
        self.shotsFired = 0
        self.shotsHit = 0
    end

    function self:getWorldV()
        return self.worldV
    end

    function self:getWorldDelta()
        return self.deltaX, self.deltaY
    end

    function self:resetAngle()
        self.angle = 0
        self:setImage(self.imgTable:getImage(1))
    end

    function self:getAngle()
        return self.angle
    end

    function self:spawn()
        assert(self.lives > 0)
        self.angle = 0
        SetTableImage(self.angle, self, self.imgTable)
        self:setVisible(true)

        self.worldV.dx = WORLD_PLAYER_STARTX
        self.worldV.dy = WORLD_PLAYER_STARTY

        -- TODO: add() is called multiple times. See StateRespawn. Is this an issue?
        self:add()
    end

    function self:alive()
        return self.isAlive
    end

    function self:makeAlive()
        -- Spawning isn't the same as being alive!
        self:setVisible(true)
        self.isAlive = true
    end

    -- Only called if sprite is in sprite list
    function self:update()
        frameCount += 1

        self.worldV.dx -= self.deltaX * SPEED
        self.worldV.dy -= self.deltaY * SPEED

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
            local _, _, c, n = self:checkCollisions(self.x, self.y)
            if n > 0 then
                for i = 1, #c do
                    if self:alphaCollision(c[i].other) == true then
                        -- The first real collision is sufficient to kill the player
                        self:collide(c[i].other)
                        break
                    end
                end
            end

            -- TODO: Draw some exhaust
            if SHOW_EXHAUST then
                exhaustTable:drawImage(1 + frameCount % 12, self.x - 8, self.y + 7)
            end
        end
    end

    function self:getScore()
        return self.score
    end

    function self:scored(points)
        self.score += points

        -- Player has scored, ergo they've hit something
        self.shotsHit += 1

        -- TODO: HERE: Extra lives? Other bonuses? Difficulty increase?
        -- Add an extra life every X points, have to track them separately so we don't add too many!

        Dashboard:drawPlayerScore()
    end

    function self:collide(other)
        self:remove()
        self.isAlive = false
        self.deltaX = 0
        self.deltaY = 0

        -- Special case: colliding with a mine detonates it
        if other:getTag() == SPRITE_TAGS.mine then
            other:explode()
        end

        SoundManager:playerDies()
        Explode(ExplosionSmall, self.worldV.dx, self.worldV.dy, true)
    end

    function self:thrust()
        self.deltaX, self.deltaY = AngleToDeltaXY(self.angle)
    end

    function self:bulletHit(other, x, y)
        self:collide(other)
    end

    function self:fire()
        -- If we haven't fired recently we can fire
        local now = pd.getCurrentTimeMilliseconds()
        if now - self.lastFiredMs >= FIRE_MS then
            -- If we can find two free player bullets, we can fire
            local bullets = PoolManager:freeInPool(PlayerBullet, 2)
            if bullets and #bullets == 2 then
                SoundManager:playerShoots()
                local deltaX = -math.sin(math.rad(self.angle))
                local deltaY = math.cos(math.rad(self.angle))
                -- Forward
                bullets[1]:spawn(self.worldV.dx, self.worldV.dy, self.angle, -deltaX * FWD_BULLET_SPEED,
                    -deltaY * FWD_BULLET_SPEED)
                -- Rear
                bullets[2]:spawn(self.worldV.dx, self.worldV.dy, self.angle, deltaX * REAR_BULLET_SPEED,
                    deltaY * REAR_BULLET_SPEED)
                self.lastFiredMs = now
                self.shotsFired += 1
            end
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
